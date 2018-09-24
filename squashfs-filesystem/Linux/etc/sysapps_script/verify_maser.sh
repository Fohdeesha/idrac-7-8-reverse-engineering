#!/bin/sh


source /etc/sysapps_script/pm_logger.sh

# run lookaside copy if it exists (optimization to remove S_3900_verify_devices.sh)
if [ -f /flash/data0/oem_ps/verify_maser.sh ]; then
    exec sh /flash/data0/oem_ps/verify_maser.sh check
fi

MASER_ROOT=/mmc1/
MASER_ZIP_DIR=/maser-zip/
SYS_SRV_IMG=$2
MASER_IMAGE=$2
SPI_ROOT=/flash/data0/oem_ps/
SPI_ROOT1=/flash/data1/
LCL_IMAGE=$SPI_ROOT1/lcl.img
LCL_MOUNT_POINT=/tmp/LCL
EXIT_CODE=0
MASER_RECOVERY=$SPI_ROOT/maser_in_recovery
#MASER_OOB=/mmc1/MASER_UEFI_OOB
PM_DATA=pm.tar.gz
PM_INFO=pm_info

DD='dd bs=4096'
if [ -e /bin/dd.coreutils ]; then
    DD="dd.coreutils conv=sparse bs=4096"
fi

# define required image sizes in MegaBytes(MB) below
MAS001_MB=50
MAS002_MB=15
MAS005_MB=500
MAS021_MB=300
MAS022_MB=250
MAS023_MB=1
MAS024_MB=10
MAS025_MB=60
MAS026_MB=5

MASER_IMAGES="mas001.img mas002.img mas005.img mas021.img mas022.img mas024.img mas025.img mas026.img"

DIAGS_PART="mas002.img"
DIAGS_SCRIPT="/etc/sysapps_script/rSPIDiags.sh"

# This is the % tolerance allowed.
MARGIN=6

# Script Cleanups: 29 April 2014 by Michael Brown
#   1) Remove `date` and extra echo - spawns extra processes in early boot, slowing the boot process
#   2) convert GLOBAL MASER_ROOT and image_name to local variables passed in - preparation for parallelization
#   3) in calculations for MIN/MAX MB, eliminate superflouous `` and expr calls and just use $(( ))
#   4) when unzipping, don't copy then unzip, use a pipe to save FS space
#   5) updates to mountMaser to not need/use third parameter

clean_up_mmc1 ()
{
	# fix DF338876: customer issue - maser recovery fails because no space on /mmc1
	rm -rf $MASER_ROOT/lost\+found
	rm -f $MASER_ROOT/*.gz
}

set_corruption_state ()
{
    local image_name=$1
	echo "***Set Corruption State $image_name Begin****"
	case "$image_name" in
		mas001.img)
			echo "Set MASER recovery file"
			touch $MASER_RECOVERY
		;;
		*)
#			echo "Set OOB revovery file"
#			touch $MASER_OOB
		;;
	esac
	echo "***Set Corruption State Complete****"
}

reset_corruption_state ()
{
	if [ -f $MASER_RECOVERY ]
	then
        writecfg -g16640 -f4 -v0   # clear LC_ATTRIBUTES_LCSTATE_OFFSET
		rm -f $MASER_RECOVERY
		echo "MASER recovery flag deleted by reset_corruption_state()"
	fi
}

apac_lcl_inventory ()
{
	for image_name in $MASER_IMAGES; do
		if [ $MASER_IMAGE == $image_name ]; then
			added=1
			inventory_in_lcl
		fi
	done
	if [ $added != 1 ]; then
		case $MASER_IMAGE in
		all)
			for image_name in $MASER_IMAGES; do
				inventory_in_lcl
			done
		;;
		*)
			echo "Invalid Image name $MASER_IMAGE" >> $SPI_ROOT/create_inventory_error
			EXIT_CODE=2
		;;
		esac
	fi
}

inventory_in_lcl ()
{
    echo "INVENTORYING $MASER_ROOT/$image_name "
    if ! /etc/sysapps_script/mountMaser.sh $MASER_ROOT$image_name /tmp/masmount
    then
        echo  "Mounting MASER image $image_name failed... inventorying"
        echo  "Mounting MASER image $image_name failed... inventorying" >> $SPI_ROOT/create_inventory_error
        EXIT_CODE=2
    fi

    if [ ! -d /tmp/lclapp ]
    then
        mkdir /tmp/lclapp
    else
        rm -f /tmp/lclapp/$image_name.xml #Fix for DF454550.  Only delete the specific package.xml
    fi

    if [ -f /tmp/masmount/Tools/iuconfig.xml ]
    then
        cp -f /tmp/masmount/Tools/iuconfig.xml /tmp/lclapp/iuconfig.xml
    else
        echo  "iuconfig.xml file not found for $image_name.....inventory error"
        echo  "iuconfig.xml file not found for $image_name.....inventory error" >> $SPI_ROOT/create_inventory_error
        EXIT_CODE=2
    fi

    if [ -f /tmp/masmount/package.xml ]
    then
        cp -f /tmp/masmount/package.xml /tmp/lclapp/$image_name.xml
    else
        echo  "package.xml file not found for $image_name.....inventory error"
        echo  "package.xml file not found for $image_name.....inventory error" >> $SPI_ROOT/create_inventory_error
        EXIT_CODE=2
    fi

    lcllibtest IDRAC APAC /tmp/lclapp

    umount /tmp/masmount
}


check_lcl_mount ()
{
	echo "***Check LCL Mount Begin****"
	if [ -f $LCL_IMAGE ]
	then
		echo "LCL image found..."
		#check size
	else
		echo "$LCL_IMAGE not found. Creating."
        cat MASER_ZIP_DIR/lcl.img.gz | gzip -d -c | $DD > $SPI_ROOT1/lcl.img
		if [ -f $SPI_ROOT1/lcl.img ]
		then
			echo "Create $LCL_IMAGE Success!"
		else
			echo "Create $LCL_IMAGE Failed!"
		fi
	fi
	if ! mount | grep -q /tmp/LCL
	then
		echo "LCL not mounted creating /tmp/LCL mount..."
		/etc/sysapps_script/mountMaser.sh $LCL_IMAGE $LCL_MOUNT_POINT
	fi
	echo "***Check LCL Mount Complete****"
}

create_image ()
{
    local MASER_ROOT=$1
    local image_name=$2
	echo "***Creating image $image_name Begin****"
    rm -f $MASER_ROOT/$image_name
	echo "Uncompressing $MASER_ZIP_DIR/$image_name.gz to $MASER_ROOT"
	if [ -f $MASER_ZIP_DIR/$image_name.gz ]
	then
		if ! cat $MASER_ZIP_DIR/$image_name.gz | gzip -d -c | $DD > $MASER_ROOT/$image_name
		then
			case "$image_name" in
				mas001.img)
					redownloader ADDLCLMSG "RED091" &
				;;
			esac
		fi
		if [ -f $MASER_ROOT/$image_name ]
		then
			echo "$MASER_ROOT/$image_name created!"
		fi
	else
		echo "$MASER_ZIP_DIR/$image_name.gz not present!"
		EXIT_CODE=2
		case "$image_name" in
			mas001.img)
				redownloader ADDLCLMSG "RED091" &
			;;
		esac
	fi
	echo "***Creating image $image_name Complete****"
    echo "Created a new MASER image: $image_name" >> /tmp/idrac_boot_notes
}

uefi_force_sync ()
{
    local MASER_ROOT=$1
    local image_name=$2
	echo "Syncing $image_name"
    create_image $MASER_ROOT $image_name
}

# Rebuild mas001
# Reuse code by calling a function instead of copy/paste.
# This requires unmounting the currently mounted mas001, rebuilding it,
# mounting the new copy on the old mount location, and then updating the
# dependent files.
# The arguments are passed in to keep the variable names the same and in
# case we want or need to do a similar thing with a different image.
umount_rebuild_remount_and_copy_new()
{
    local MASER_ROOT=$1
    local image_name=$2
    local masmount=$3

    echo "umount_rebuild_remount_and_copy_new $MASER_ROOT $image_name $masmount"

    umount $masmount

    uefi_force_sync $MASER_ROOT $image_name

    if ! /etc/sysapps_script/mountMaser.sh $MASER_ROOT$image_name $masmount
    then
        umount $masmount 2>&1 > /dev/null
        echo  "Mounting MASER image $image_name failed..."
        # We just tried to recreate the image so that isn't an option.
        set_corruption_state $image_name
        EXIT_CODE=2
        return
    fi

    # Copy the new versions of these files.
    if [ -f $masmount/Tools/iuconfig.xml ]
    then
        cp -f $masmount/Tools/iuconfig.xml /tmp/lclapp/iuconfig.xml 2>&1 > /dev/null
    fi
    if [ -f $masmount/package.xml ]
    then
        cp -f $masmount/package.xml /tmp/lclapp/$image_name.xml 2>&1 > /dev/null
    fi
    if [ -f "$masmount/CAPUSC" ]
    then
        cp $masmount/CAPUSC /flash/data0/oem_ps
    else
        echo "CAPUSC file NOT present"
    fi
}

check_mount ()
{
    local MASER_ROOT=$1
    local image_name=$2
    echo "***Check Mount $image_name Begin****"
    masmount=$(mktemp -d /tmp/masmount-XXXXXX)
    if ! /etc/sysapps_script/mountMaser.sh $MASER_ROOT$image_name $masmount
    then
        umount $masmount 2>&1 > /dev/null
        echo  "Mounting MASER image $image_name failed... recreating"
        set_corruption_state $image_name
        create_image $MASER_ROOT $image_name
    else
        if [ ! -d /tmp/lclapp ]
        then
            mkdir /tmp/lclapp 2>&1 > /dev/null
        fi
        if [ -f $masmount/Tools/iuconfig.xml ]
        then
            cp -f $masmount/Tools/iuconfig.xml /tmp/lclapp/iuconfig.xml 2>&1 > /dev/null
        fi
        if [ -f $masmount/package.xml ]
        then
            cp -f $masmount/package.xml /tmp/lclapp/$image_name.xml 2>&1 > /dev/null
        fi
        case "$image_name" in
            mas025.img)
                if [ ! -d $masmount/ConfigDB ]; then
                    echo "Creating ConfigDB..."
                    tar zxf $MASER_ZIP_DIR/ConfigDB.tar.gz -C $masmount/
                    echo "Done Creating ConfigDB..."
                fi
#                lcllibtest CHECKSSIB $masmount/
#                if [ $? -ne 0 ]
#                then
#                    echo "SSIB tasks not present!"
#                else
#                    echo "SSIB tasks present!"
#                    touch /tmp/launch_ssm
#                fi
                ;;
            mas001.img)
                if [ -f "$masmount/CAPUSC" ]
                then
                    cp $masmount/CAPUSC /flash/data0/oem_ps
                else
                    echo "CAPUSC file NOT present"
                fi

                #
                # 13g idrac image includes USC/LC, so we should make sure the
                #   idrac fw LC and MMC LC are synched
                #
                if [ -f "$masmount/Tools/version_d.txt" ]
                then
                    installedLC=$(cat $masmount/Tools/version_d.txt | tr -d '\r\n" ')
                    rootfsLC=$(head -n 2 /etc/fw_ver  | tail -n 1 | tr -d '\r\n" ')
                    if [ "$installedLC" != "$rootfsLC" ]
                    then
                        echo  "Installed LC Version: $installedLC"
                        echo  "Firmware  LC Version: $rootfsLC"
                        umount_rebuild_remount_and_copy_new $MASER_ROOT $image_name $masmount
                    else
                   		if [ -f $MASER_RECOVERY ]
                        then
                            echo  "MASER in recovery mode, force sync and clear state"
                            umount_rebuild_remount_and_copy_new $MASER_ROOT $image_name $masmount
                            if [ "0" -eq "$EXIT_CODE" ]; then
                                reset_corruption_state
                            fi
                        fi
                    fi
                else
                    echo  "Unable to read installed LC version_d.txt ... recreating"
                    umount_rebuild_remount_and_copy_new $MASER_ROOT $image_name $masmount
                fi
                ;;
            *)
                ;;
        esac
        umount $masmount
    fi

    rmdir $masmount
    echo "***Check Mount $image_name Complete****"
}

check_size()
{
    local MASER_ROOT=$1
    local image_name=$2
	IMAGE_PATH=$MASER_ROOT/$image_name
	IMG_Size=`ls -lrt $IMAGE_PATH 2>/dev/null |awk '{print $5}'`
	SIZE_MB=$(( ${IMG_Size:=0} /(1024 * 1024)))
	case "$image_name" in
	mas001.img)
		MAX_MB=$(( MAS001_MB + (MARGIN * MAS001_MB)/100 ))
		MIN_MB=$(( MAS001_MB - (MARGIN * MAS001_MB)/100 ))
		;;
	mas002.img)
		MAX_MB=$(( MAS002_MB + (MARGIN * MAS002_MB)/100 ))
		MIN_MB=$(( MAS002_MB - (MARGIN * MAS002_MB)/100 ))
		;;
	mas005.img)
		MAX_MB=$(( MAS005_MB + (MARGIN * MAS005_MB)/100 ))
		MIN_MB=$(( MAS005_MB - (MARGIN * MAS005_MB)/100 ))
		;;
	mas021.img)
		MAX_MB=$(( MAS021_MB + (MARGIN * MAS021_MB)/100 ))
		MIN_MB=$(( MAS021_MB - (MARGIN * MAS021_MB)/100 ))
		;;
	mas022.img)
		MAX_MB=$(( MAS022_MB + ($MARGIN * $MAS022_MB)/100 ))
		MIN_MB=$(( MAS022_MB - ($MARGIN * $MAS022_MB)/100 ))
		;;
	mas024.img)
		MAX_MB=$(( MAS024_MB + ($MARGIN * $MAS024_MB)/100 ))
		MIN_MB=$(( MAS024_MB - ($MARGIN * $MAS024_MB)/100 ))
		SIZE_MB=$(( IMG_Size /(1000 * 1000)))
		;;
	mas025.img)
		MAX_MB=$(( MAS025_MB + (MARGIN * MAS025_MB)/100 ))
		MIN_MB=$(( MAS025_MB - (MARGIN * MAS025_MB)/100 ))
		SIZE_MB=$(( IMG_Size /(1000 * 1000)))
		;;
	mas026.img)
		MAX_MB=$(( MAS026_MB + (MARGIN * MAS026_MB)/100 ))
		MIN_MB=$(( MAS026_MB - (MARGIN * MAS026_MB)/100 ))
		SIZE_MB=$(( IMG_Size /(1000 * 1000)))
		;;
	*)
		echo  "$MASER_IMAGE" >> /tmp/maser_image_invalid
		return
		;;
	esac

	echo "Size of $IMAGE_PATH is $SIZE_MB. Range is ${MIN_MB}-${MAX_MB}"
	if [ $SIZE_MB -gt $MAX_MB -o $SIZE_MB -lt $MIN_MB ]
	then
		echo "out of range... Creating new."
		create_image $MASER_ROOT $image_name
	fi
}

rebuild()
{
  local part=$1
  local freeLoop=`losetup -f`
  case "$part" in
  21)
    echo "Formatting MAS021"
    losetup $freeLoop -o 32256 /mmc1/mas0${part}.img && mkfs.vfat -n MAS0${part} -F 16 $freeLoop 307100 || EXIT_CODE=1
    EXIT_CODE=0
    echo "Result $EXIT_CODE"
  ;;
  *)
  ;;
  esac
}

check_diags()
{
	DIAGS_PART="/mmc1/mas002.img"
	DIAGS_MNT=/tmp/rSPI
	DIAGS_LOG=/tmp/diags_results
	DIAGS_VER=/tmp/DiagsVersion
	DIAGS_SPI_CRC=/tmp/DiagsCRC
	SHASTA_CHECK=/tmp/shasta
	DIAGS_PAYLOAD=/tmp/DiagsBkp
	diagsSPICrc=4294967295

#	DIAGS_PAYLOAD=$(mktemp /tmp/diags-payload-XXXXXX)
#    	TEMPFILES="$TEMPFILES $DIAGS_PAYLOAD"

    	DIAGS_CRC=$(mktemp /tmp/diags-02-crc-XXXXXX)
    	TEMPFILES="$TEMPFILES $DIAGS_CRC"
    	trap 'rm -rf $TEMPFILES' EXIT

	#For 12G the file will not exist
	echo "" > $DIAGS_LOG
	if [ ! -e $SHASTA_CHECK ]
	then
		echo "12G system detected. Exiting"
		return 0 
	fi
	if [ -e $DIAGS_SPI_CRC ] ; then
		diagsSPICrc=`cat $DIAGS_SPI_CRC`	
	fi	
    	rm -f $DIAGS_PAYLOAD
	if ! mkdir $DIAGS_MNT; then
		echo "Diags mkdir failed"
		return 1
	fi
	if ! /etc/sysapps_script/mountMaser.sh $DIAGS_PART $DIAGS_MNT; then
			rm -rf $DIAGS_MNT $DIAGS_TMP
			echo  "Mounting Diags image failed"
			return 2
	fi
	if [ ! -e "$DIAGS_MNT/package.xml" ] ; then
		umount -d $DIAGS_MNT
		rm -rf $DIAGS_MNT $DIAGS_TMP
		echo "Valid Diags Payload NOT Found"

		#Send update cmd to erase Diags in RSPI if CRC in RSPI is NOT 0xFFFFFFFF
#		if [ $diagsSPICrc -ne 4294967295 ] ; then
#			echo "RSPI has valid Diags. Send update cmd to clear RSPI DIags"
#			IPMICmd 20 30 0 d0 0 15 10 0 0 0 10 0 0 0 04 0 0 0 0 0 0 0 0 0 0 0
#		fi
		return 3
	fi
	cd $DIAGS_MNT
	res=`tar cf $DIAGS_PAYLOAD *`
	vendorVer=`xmllint --xpath '//SoftwareComponent/@vendorVersion' package.xml | tr -d 'vendorVersion=" '`
	dellVer=`xmllint --xpath '//SoftwareComponent/@dellVersion' package.xml | tr -d 'dellVersion=" '`
	echo "$vendorVer,$dellVer" > $DIAGS_VER
	cd -
	umount -d $DIAGS_MNT
	rm -rf $DIAGS_MNT
	if [ x != x"$res" ] ; then
		echo "Tarring Diags failed"
		rm -f $DIAGS_PAYLOAD $DIAGS_VER
		return 4
	fi
	#compressing changes CRC everytime, so not compressing
	#gzip -c $DIAGS_TMP > $DIAGS_PAYLOAD
	/bin/cksum $DIAGS_PAYLOAD | sed 's/ .*$//' | tr -d '\n' > $DIAGS_CRC
	if [ 0 != $? ] ; then
		echo "Diags cksum failed"
		rm -f $DIAGS_PAYLOAD $DIAGS_VER
		return 5
	fi
	
	if [ -e $DIAGS_SPI_CRC ] ; then
		if diff -q $DIAGS_SPI_CRC $DIAGS_CRC 2>/dev/null ; then
			echo "rSPI and MAS002 Diags CRCs are same. Do Nothing" >> $DIAGS_LOG
			rm -f $DIAGS_PAYLOAD $DIAGS_VER
		else
			echo "rSPI and MAS002 Diags CRCs differ. Sending IPMI command" >> $DIAGS_LOG
			echo "rSPI CRC = `cat $DIAGS_SPI_CRC`" >> $DIAGS_LOG
			echo "MAS002 CRC = `cat $DIAGS_CRC`" >> $DIAGS_LOG
			IPMICmd 20 30 0 d0 0 15 10 0 0 0 10 0 0 0 04 0 0 0 0 0 0 0 0 0 0 0 >> $DIAGS_LOG
		fi
	else
		echo "rSPI Diags CRC file is not present." >> $DIAGS_LOG		
	fi
}

check_file ()
{
    local MASER_ROOT=$1
    local image_name=$2
    local verbose=$3
    if [ "$verbose" = "verbose" ]; then
        set -x
    fi
    echo "***Check MASER image $image_name Begin: $(date) ****"

    check_size $MASER_ROOT $image_name
    check_mount $MASER_ROOT $image_name

    #rSPI Diags implementation
    if [ "$DIAGS_PART" == "$image_name" ]
    then
        check_diags
    fi
    echo "***Check MASER image $image_name Complete: $(date) ****"
}

create_lcl ()
{
    check_file $SPI_ROOT1 lcl.img
}

check_lcl ()
{
    echo " ***Check LCL Begin****"
    if [ -f $LCL_IMAGE ]
    then
        echo "LCL image found..."
    else
        echo "$LCL_IMAGE not found. Creating."
        cat MASER_ZIP_DIR/lcl.img.gz | gzip -d -c | $DD > $SPI_ROOT1/lcl.img
        if [ -f $SPI_ROOT1/lcl.img ]
        then
            echo "Success creating $LCL_IMAGE"
        else
            echo "Failed creating $LCL_IMAGE"
        fi
    fi
    if ! mount | grep -q /tmp/LCL > /dev/null 2>&1
    then
        echo "LCL not mounted creating /tmp/LCL mount..."
        /etc/sysapps_script/mountMaser.sh $LCL_IMAGE $LCL_MOUNT_POINT
    fi
    echo "Creating Soft link..."
    ln -sf $LCL_IMAGE /mmc1/mas023.img
    echo "***Check LCL Complete****"
}

check_all_maser ()
{
    echo "Checking MASER images..."
    clean_up_mmc1 &

    for image_name in $MASER_IMAGES; do
        echo "Checking ${image_name}"
        if [ -e /flash/data0/features/serialize_maser_check ]; then
            # not in background
            check_file $MASER_ROOT $image_name
        else
            # in parallel. Since we interleave output in the parallel case,
            # serialize each check to it's own log file so we can read them and
            # check for errors
            check_file $MASER_ROOT $image_name verbose > /var/log/verify_maser-$image_name.log 2>&1 &
        fi
    done

    # wait for all the checks to finish
    wait

    # Check mas027
    if [ -d "/mmc2" ] ; then
        # fix the corrupted links in /mmc1/mas027/mas027
        if [ -L "/mmc1/mas027/mas027" ] ; then
            echo "BUG.. circular link found in /mmc1/mas027/mas027. So removing it"
            rm -f /mmc1/mas027/mas027
        fi
        if [ ! -d "/mmc2/mas027" ] ; then
            echo "/mmc2/mas027 does not exist. Creating it"
            mkdir /mmc2/mas027
        fi
        if [ ! -L "/mmc1/mas027" ] ; then
            echo "Link /mmc1/mas027 -> /mmc2/mas027 does not exist. Creating it"
            ln -sf /mmc2/mas027 /mmc1/mas027
        fi
        if [ -f "/mmc2/mas027/package.xml" ] ; then
            echo "Copying file /mmc2/mas027/package.xml exists. Copying to /tmp/lclapp/mas027.img.xml"
            cp /mmc2/mas027/package.xml /tmp/lclapp/mas027.img.xml
        fi
    fi
    echo "Finished checking MASER images..."

#   #***** MAS023 CHECK SHOULD ALWAYS BE LAST *****
#   echo "Checking ${image_name} (LCL)"
#   check_lcl
#    echo "  done"
}

validate_image ()
{
    case "$MASER_IMAGE" in
        mas001)
            ;;
        mas002)
            ;;
        mas005)
            ;;
        mas021)
            ;;
        mas022)
            ;;
        mas023)
            ;;
        mas024)
            ;;
        mas025)
            ;;
        mas026)
            ;;
        *)
            echo  "$MASER_IMAGE" >> /tmp/maser_image_invalid
            ;;
    esac
}

force_create ()
{
    echo "Force Create entry for $MASER_IMAGE..."

    case "$MASER_IMAGE" in
        mas023)
            echo "Deleting $MASER_IMAGE"
            rm -f $MASER_ROOT/$MASER_IMAGE.img
            rm -f $LCL_IMAGE
            check_lcl
            ;;
        all)
            echo "Deleting all masxxx images"
            rm -f $MASER_ROOT/*.img
            rm -f $LCL_IMAGE
            check_all_maser
            ;;
        *)
            rm -f /tmp/maser_image_invalid
            validate_image
            if [ -f /tmp/maser_image_invalid ]
            then
                EXIT_CODE=2
            else
								/bin/shmwrite -i 6 0 > /dev/null 2>&1
                echo "Deleting $MASER_IMAGE"
                rm -f $MASER_ROOT/$MASER_IMAGE.img
                check_file $MASER_ROOT $MASER_IMAGE.img
                /bin/shmwrite -i 6 1 > /dev/null 2>&1 
            fi
            ;;
    esac
    echo "force Create complete..."
}

help ()
{
	echo "**************************************************************************************"
	echo " This script is used to check and create supported MASER images."
	echo " Supported MASER images: mas001, mas002, mas003, mas025, mas005,mas021, mas022"
	echo " Usage: all arguments are lower case"
	echo " Arg1 = force : Forces creation of image specified in Arg2."
	echo " Arg1 = inventory : inventory in lcl of image specified in Arg2."
	echo " Arg1 = check : Will only check for image existance and if not present will create them."
	echo " Arg1 = validate : Will validate if the specified MASER image is supported "
	echo " Arg1 = uefi_begin : Accepts the path to image Field service UEFI image file."
	echo " Arg1 = uefi_end : Will set the flag indicating UEFI update is completed this will reset the"
	echo "        recovery flag and let BIOS allow launchig  UEFI via F10"
	echo " Arg2 = MASER image name (mas001 , mas002 etc) or System Services (UEFI)image path"
	echo " 	      MASER image name or all is used when Arg1 is force/inventory "
	echo "        UEFI image path is used when Arg1 is uefi_begin"
	echo "**************************************************************************************"
}

init_maser_map ()
{
	avct_control imgdelete --img 1
	avct_control imgdelete --img 2
	avct_control imgdelete --img 3
	avct_control imgdelete --img 4
	avct_control imgdelete --img 5
	avct_control imgdelete --img 6
	avct_control imgdelete --img 7
	avct_control imgdelete --img 8
	/etc/sysapps_script/S_4100_maser_attch.sh start
	avct_control imginfo >> /tmp/uefi_update_process
}

pm_update ()
{
	
	echo "PM update : Started" > ${PM_DEBUG_LOG}
	echo "[`date`] pm_begin_check: $SYS_SRV_IMG " > /tmp/pm_update_process
	if [ -f $SYS_SRV_IMG ]
	then
				
		dd if=$SYS_SRV_IMG of=/tmp/$PM_INFO bs=64 skip=8 count=1
		#Uninstall PM
        u=`dd if=/tmp/$PM_INFO bs=1 count=1 skip=36 2> /dev/null | hexdump  -e '1/1 "%d" "\n"'`
		if [ $? -ne 0 ]
		then
			echo "[`date`] Failed! --dd if=$SYS_SRV_IMG of=/tmp/$PM_INFO bs=64 skip=8 count=1--" >> /tmp/pm_update_process
			EXIT_CODE=2
			debug_log "PM update : failed in dd command to get pm info! "
			
		else
			# checking forced bit
			f=`dd if=/tmp/$PM_INFO bs=1 count=1 skip=35 2> /dev/null | hexdump  -e '1/1 "%d" "\n"'`
			echo "[`date`] Forced bit : $f " >> /tmp/pm_update_process
			if [ -f $SPI_ROOT/$PM_INFO ]
			then
				echo "$SPI_ROOT/$PM_INFO exists" >> /tmp/pm_update_process
				if [ $f -eq 0 ]
				then
					# Get new Rebrand Name
					dd if=/tmp/$PM_INFO bs=1 count=16 skip=19 of=/tmp/nrbname
					echo "[`date`] New Rebrand Name: " >> /tmp/pm_update_process
					cat /tmp/nrbname >> /tmp/pm_update_process
					# Get existing Rebrand Name
					dd if=$SPI_ROOT/$PM_INFO bs=1 count=16 skip=19 of=/tmp/orbname
					echo "[`date`] Existing Rebrand Name: " >> /tmp/pm_update_process
					cat /tmp/orbname >> /tmp/pm_update_process
					cmp -s /tmp/nrbname /tmp/orbname
					if [ $? -ne 0 ]
					then
						echo "[`date`] Rebrand Names differ, Forced bit not set.  Update not allowed" >> /tmp/pm_update_process
						EXIT_CODE=3
						rm -f /tmp/nrbname /tmp/orbname
						debug_log "PM update: failed! Rebrand Names Differ"
						return
					else
						echo "[`date`]     Rebrand Names match.  Updating" >> /tmp/pm_update_process
				                if [ $u -eq 1 ]
                				then
                        			echo "Uninstalling PM"
									debug_log "PM update: Uninstalling PM"
                        			/etc/sysapps_script/persmod_setup.sh uninstall
                        			return
                				fi
					fi
				else
					if [ $u -eq 1 ]
                			then
                        		echo "Uninstalling PM"
								debug_log "PM update: Uninstalling PM"
                        		/etc/sysapps_script/persmod_setup.sh uninstall
                        		return
                	fi
				fi
			else
					if [ $f -eq 0 ]
                       then
                             echo "[`date`] Forced bit not set.  Update not allowed" >> /tmp/pm_update_process
							 EXIT_CODE=4
                             debug_log "PM update: failed! Forced bit not set"
                             return
                    fi
			fi
			dd if=$SYS_SRV_IMG of=/tmp/$PM_DATA bs=64 skip=9
			if [ $? -ne 0 ]
			then
				echo "[`date`] Failed! --dd if=$SYS_SRV_IMG of=/tmp/$PM_DATA bs=64 skip=9--" >> /tmp/pm_update_process
				EXIT_CODE=5
				debug_log "PM update: failed in dd command to extract pm payload!"
				
			fi
		fi
		echo "rm -f $SYS_SRV_IMG" >> /tmp/pm_update_process
		rm -f $SYS_SRV_IMG
		if [ -f /tmp/$PM_DATA ]
		then
			echo "[`date`] Successfully Created /tmp/$PM_DATA" >> /tmp/pm_update_process
			gunzip /tmp/$PM_DATA
			if [ $? -ne 0 ]
			then
				echo "[`date`] gunzip /tmp/$PM_DATA failed..." >> /tmp/pm_update_process
				EXIT_CODE=6
				debug_log "PM update: failed in gunzip!"
				return
			else
				echo "[`date`] gunzip /tmp/$PM_DATA success..." >> /tmp/pm_update_process
				mkdir /tmp/pmmount
				touch $SPI_ROOT/pm_disabled
				if ! /etc/sysapps_script/mountMaser.sh /mmc1/mas026.img /tmp/pmmount
				then
					echo "[`date`] mounting MAS026 failed" >> /tmp/pm_update_process
					EXIT_CODE=7
					debug_log "PM update: failed in mas026 mount!"
					rm /tmp/pm.tar /tmp/$PM_INFO >> /tmp/pm_update_progress
					return
				else
					echo "[`date`] mount MAS026 success! Clearing PM Data..." >> /tmp/pm_update_process
					rm -rf /tmp/pmmount/*
					touch $SPI_ROOT/pm_unpop
					cd /tmp/pmmount/
					echo "[`date`] Extracting PM Data..." >> /tmp/pm_update_process
					echo "[`date`] tar -xvf /tmp/pm.tar" >> /tmp/pm_update_process
					tar -xvf /tmp/pm.tar >> /tmp/pm_update_process
					if [ $? -ne 0 ]
					then
						echo "[`date`] tar -xvf /tmp/pm.tar failed..." >> /tmp/pm_update_process
						EXIT_CODE=8
						debug_log "PM update: failed in tar -xvf!"
						rm /tmp/pm.tar /tmp/$PM_INFO >> /tmp/pm_update_progress
						return
					else
						echo "[`date`] tar -xvf success..." >> /tmp/pm_update_process
						# check for top level pm dir
						stat -t pm 2>&1 | grep -q "No such file"
						if [ $? -eq 0 ]
						then
							echo "[`date`] Invalid PM image..." >> /tmp/pm_update_process
							rm -rf  /tmp/pmmount/* >> /tmp/pm_update_process
							EXIT_CODE=9
							debug_log "PM update: failed Invalid PM image!"
							return
						else
							rm -f $SPI_ROOT/pm_unpop
							rm -f $SPI_ROOT/pm_info
							mv /tmp/pm_info $SPI_ROOT
							rm -f $SPI_ROOT/pm_disabled
							# check version of new and old pm image and set available flag
							echo "fffffffffffffffffffffffffffffffe" > $SPI_ROOT/pm_update_available
							echo "Done!" >> /tmp/pm_update_process
						fi
					fi
					cd /tmp
				fi
				/etc/sysapps_script/persmod_setup.sh install /tmp/pmmount
				sync
				umount /tmp/pmmount
				rm -rf /tmp/pmmount
			fi
		else
			echo "[`date`] PM Data update: failed! $PM_DATA file not found!" >> /tmp/pm_update_process
			EXIT_CODE=10
			debug_log "PM update: failed! $PM_DATA file not found!"
			return
		fi
		echo "[`date`] rm -f /tmp/pm.tar" >> /tmp/pm_update_process
		rm /tmp/pm.tar
	else	
		echo "[`date`] PM Data image $SYS_SRV_IMG not found..." >> /tmp/pm_update_process
		echo "[`date`] Please specify a valid image file path" >> /tmp/pm_update_process
		debug_log "PM update: Please specify a valid image file path!"
		EXIT_CODE=11
	fi
	
}


uefi_complete_task ()
{
	echo "[`date`] UEFI complete request" >> /tmp/uefi_update_process
	rm -f $MASER_RECOVERY
#	touch $MASER_OOB
	echo "[`date`] rm -f $MASER_RECOVER[`date`] Y " >> /tmp/uefi_update_process
#	echo "[`date`] touch $MASER_OOB" >> /tmp/uefi_update_process
	image_name=mas001.img
	inventory_in_lcl
}

uefi_begin_check ()
{
    echo "[`date`] uefi_begin_check: $SYS_SRV_IMG " > /tmp/uefi_update_process
    if [ -f $SYS_SRV_IMG ]
    then
        touch $SPI_ROOT/maserdisabled
        lcllibtest EVENT 1 "Field Service update: started!" &
        echo "[`date`] MASER in recovery mode!" >> /tmp/uefi_update_process
        echo "[`date`] Force creating MAS001..." >> /tmp/uefi_update_process
        MASER_IMAGE=mas001
        force_create
        mkdir /tmp/masmount
        if ! /etc/sysapps_script/mountMaser.sh /mmc1/mas001.img /tmp/masmount
        then
            echo "[`date`] mounting MAS001 failed" >> /tmp/uefi_update_process
            EXIT_CODE=2
            lcllibtest EVENT 1 "Field Service update: failed in mas001 mount!" &
        else
            echo "[`date`] mount MAS001 success! Updating System Services Image..." >> /tmp/uefi_update_process
            dd if=$SYS_SRV_IMG of=/tmp/uefi.tar.gz bs=512 skip=1
            if [ $? -ne 0 ]
            then
                echo "[`date`] Failed! --dd if=$SYS_SRV_IMG of=/tmp/uefi.tar.gz bs=512 skip=1--" >> /tmp/uefi_update_process
                EXIT_CODE=2
                lcllibtest EVENT 1 "Field Service update: failed in dd command!" &
            else
                echo "[`date`] rm -f $SYS_SRV_IMG" >> /tmp/uefi_update_process
                rm -f $SYS_SRV_IMG
                if [ -f /tmp/uefi.tar.gz ]
                then
                    echo "[`date`] Successfully Created /tmp/masmount/uefi.tar.gz" >> /tmp/uefi_update_process
                    gunzip /tmp/uefi.tar.gz
                    if [ $? -ne 0 ]
                    then
                        echo "[`date`] gunzip /tmp/uefi.tar.gz failed..." >> /tmp/uefi_update_process
                        EXIT_CODE=2
                        lcllibtest EVENT 1 "Field Service update: failed in gunzip!" &
                        rm -f /tmp/uefi.tar.gz
                    else
                        echo "[`date`] gunzip /tmp/uefi.tar.gz success..." >> /tmp/uefi_update_process
                        cd /tmp/masmount/
                        echo "[`date`] tar -xvf /tmp/uefi.tar" >> /tmp/uefi_update_process
                        tar -xvf /tmp/uefi.tar >> /tmp/uefi_update_process
                        cd /tmp
                        if [ $? -ne 0 ]
                        then
                            echo "[`date`] tar -xvf /tmp/uefi.tar failed..." >> /tmp/uefi_update_process
            								umount /tmp/masmount
                            EXIT_CODE=2
                            lcllibtest EVENT 1 "Field Service update: failed in tar -xvf!" &
                        else
                            echo "[`date`] tar -xvf success..." >> /tmp/uefi_update_process
                            echo "[`date`] rm -f /tmp/uefi.tar" >> /tmp/uefi_update_process
                            ls -lrt /tmp/masmount >> /tmp/uefi_update_result
                            cp -f /tmp/masmount/CAPUSC /flash/data0/oem_ps
                            echo "[`date`] Removing MASER Recovery and Disable state files..." >> /tmp/uefi_update_process
														umount -d /tmp/masmount
                            uefi_complete_task
                            init_maser_map
                            echo "[`date`] Done!" >> /tmp/uefi_update_process
                            lcllibtest EVENT 1 "Field Service update: success!" &
                        fi
                        echo "[`date`] rm -f /tmp/uefi.tar" >> /tmp/uefi_update_process
                        rm -f /tmp/uefi.tar
                    fi
                else
                    echo "[`date`] Field Service update: failed! uefi.zip file not found!" >> /tmp/uefi_update_process
                    EXIT_CODE=2
                    lcllibtest EVENT 1 "Field Service update: failed! zip file not found!" &
                fi
            fi
        fi
        rm -f $SPI_ROOT/maserdisabled
    else
        echo "[`date`] System Services image $SYS_SRV_IMG not found..." >> /tmp/uefi_update_process
        echo "[`date`] Please specify a valid image file path" >> /tmp/uefi_update_process
        EXIT_CODE=2
    fi
}

[ -d $SPI_ROOT ] || mkdir $SPI_ROOT

case "$1" in
	force)
		rm -f $SPI_ROOT/maser_create_force
		rm -f /tmp/force_create_end
		touch $SPI_ROOT/maserdisabled
		force_create
		rm -f $SPI_ROOT/maserdisabled
		touch /tmp/force_create_end
	;;
	check)
		check_all_maser
	;;
        rebuild_part)
          rebuild 21
        ;;
	diags)
		check_diags
	;;
	validate)
		rm -r /tmp/maser_image_invalid
		validate_image
	;;
	uefi_end)
		uefi_complete_task
	;;
	uefi_begin)
	uefi_begin_check
	;;
	pm_begin)
	pm_update
	if [ $EXIT_CODE -ne 0 ]
	then
		check_for_errors $EXIT_CODE
	fi
	;;
	inventory)
		apac_lcl_inventory
	;;
	check_recovery)
		if [ -f $MASER_RECOVERY ]
		then
			echo "In Receovery"
			exit 0
		else
			echo "Not In Reccovery"
			exit 0
		fi
	;;
	*)
		help
		EXIT_CODE=1
	;;
esac

exit $EXIT_CODE
