#!/bin/sh
#
#Summary-   This script sets up the credential vault file system.
#
#Note-      Do not change the location of the credential vault.
#           The cv is specifically mounted at /flash/data0
#           Also please see end of script for debugging hints

# review feedback:
# X 13G only: remove any existing 12G CV file
# X Mount options: data=ordered for ext3
# X move flag for 13g creation from scratch to persistent store to deal with inopportune AC cycle
# X add detection/correction of corrupt image
# X more efficient sync
# - -ENOSPC handling for creation of image

# X Deal with complete failure to mount CV
#    -- other services have Requires=, so they will not start if this service fails

set -e
set -x

exec > /tmp/credential-vault.log 2>&1

#for debugging only
#exec >> /mmc1/credential-vault.log 2>&1
date

#Script Variables
CV_SIZE_MB_13G=6
LOOPDEV_13G="/dev/loop7"  # needs to match device in TABLE
TABLE_13G="0 12000 crypt aes-ecb-essiv:sha256 dfd078507dc33c9c669669be8a8dda51f3dce8d0205ab0e6802c3d9cfe683a6d 0 $LOOPDEV_13G 0"

CV_SIZE_MB_12G=1
LOOPDEV_12G="/dev/loop6"  # needs to match device in TABLE
TABLE_12G="0 2000 crypt aes-ecb-essiv:sha256 dfd078507dc33c9c669669be8a8dda51f3dce8d0205ab0e6802c3d9cfe683a6d 0 $LOOPDEV_12G 0"

post_mount() {
    # recover from old implementation that left files hanging around
    rm -rf /flash/data0/.new_cv.img

    # POST setup file fixups
    mkdir -p /flash/13g-cv/BNR 2>/dev/null ||:

    if [ -e /flash/data0/etc/avctpasswd ]
    then
        #we either came from a very old 12g system that stored the passwords
        #in that location, or a newer 12g system that used that place
        #to handle credential vault corruption.  In either case, try to recover
        #any other files if the old 12g cv exists.  ensure_cv should allow
        #the 12g cv to be readable if possible
        touch /flash/13g-cv/need-sync
    fi
    mv /flash/data0/etc/avctpasswd /flash/13g-cv/. > /dev/null 2>&1 ||:
    chmod 640 /flash/13g-cv/avctpasswd ||:

    mv /flash/data0/oem_ps/certs/* /flash/13g-cv/. > /dev/null 2>&1 ||:

    # OS Interface setup, krb keytab upgrade handling
    if [ -f /flash/data0/etc/certs/krb_keytab ]; then
        mv /flash/data0/etc/certs/krb_keytab /flash/13g-cv/krb_keytab
        #same arguments as above with passwords for krb_keytab
        touch /flash/13g-cv/need-sync
 
    fi

    # For 13G, remove any old 12G CV image
    if [ -e /flash/data0/features/shasta ]; then
        rm -f /flash/data0/.cv.img
    fi

    # one time sync from 12G -> 13G at boot under LIMITED circumstances
    if [ -e /flash/data0/features/not-shasta ] &&
       [ -e /flash/data0/created-13g-cv-from-scratch -o -e /flash/13g-cv/need-sync ]
    then
        ensure_file /flash/data0/.cv.img 0 $CV_SIZE_MB_12G
        setup_cv /flash/data0/.cv.img $LOOPDEV_12G 12g_cv "$TABLE_12G" /flash/12g-cv ext2
        cp -a /flash/12g-cv/. /flash/13g-cv/.
        rm -f /flash/data0/created-13g-cv-from-scratch
        rm -f /flash/13g-cv/need-sync
        teardown_cv $LOOPDEV_12G 12g_cv  /flash/12g-cv
    fi
}


#For a cv at a given mount point, copy off the contents and
#recreate the cv with different key then copy the contents back
copy_cv() {

  local IMAGE_FILE=$1
  local LOOP_DEVICE=$2
  local MAP_DEVICE=$3
  local TABLE=$4
  local MOUNT_POINT=$5
  local FS_TYPE=$6
  local MOUNT_OPTIONS=$7
  local CV_SIZE=$8
  local MOD_OPTIONS=$9

  #Stash contents
  rm -rf /tmp/${MAP_DEVICE}
  mkdir /tmp/${MAP_DEVICE}
  cp -a ${MOUNT_POINT}/. /tmp/${MAP_DEVICE}/. 

  teardown_cv ${LOOP_DEVICE} ${MAP_DEVICE} ${MOUNT_POINT}
  #unload tsip module
  rmmod sh_tsip
  #restart the tsip with different key
  modprobe sh_tsip ${MOD_OPTIONS}

  rm -f ${IMAGE_FILE}
  ensure_file ${IMAGE_FILE} 0 ${CV_SIZE}
  setup_cv ${IMAGE_FILE} $LOOP_DEVICE $MAP_DEVICE "${TABLE}" $MOUNT_POINT $FS_TYPE "${MOUNT_OPTIONS}"

  cp -a /tmp/${MAP_DEVICE}/. ${MOUNT_POINT}/.
  rm -rf /tmp/${MAP_DEVICE}
}

find_cv_keys() {
    local IMAGE_FILE=$1
    local LOOP_DEVICE=$2
    local MAP_DEVICE=$3
    local TABLE=$4
    local MOUNT_POINT=$5
    local FS_TYPE=$6
    local MOUNT_OPTIONS=$7
    local CV_SIZE=$8

    if [ ! -e /tmp/SPIblk0.bin ]
    then
         dd if=/tmp/current_bootloader_key.bin of=/tmp/SPIblk0.bin bs=1 count=256 skip=4936
    fi
    if [ ! -e /tmp/SPIblk1.bin ]
    then
         dd if=/dev/mtdblock1 of=/tmp/SPIblk1.bin count=256 bs=1  skip=4936
    fi
    if [ ! -e /tmp/EMMCp1.bin ]
    then
         dd if=/dev/mmcblk0p3 of=/tmp/EMMCp1.bin count=256  bs=1 skip=4936
    fi
    if [ ! -e /tmp/EMMCp2.bin ]
    then
         dd if=/dev/mmcblk0p7 of=/tmp/EMMCp2.bin count=256  bs=1 skip=4936
    fi

    if  ! diff /tmp/SPIblk0.bin /tmp/SPIblk1.bin 
    then
        # SPI block n-1 is different add it to the list to try if current SPI fails
        KEY_TRY=" /dev/mtdblock1 "
        echo "SPIblk1 is different"
    fi
    if  ! diff /tmp/SPIblk0.bin /tmp/EMMCp1.bin 
    then
        # SPI block n-1 is different add it to the list to try if current SPI fails
        KEY_TRY=${KEY_TRY}" /dev/mmcblk0p3 "
        echo "EMMCp1 is different"
    fi
    if  ! diff /tmp/SPIblk0.bin /tmp/EMMCp2.bin 
    then
        # SPI block n-1 is different add it to the list to try if current SPI fails
        KEY_TRY=${KEY_TRY}" /dev/mmcblk0p7 "
        echo "EMMCp2 is different"
    fi

    echo "Trying keys: "${KEY_TRY}
    #Set up loopback device to use the image file as a block device
    losetup ${LOOP_DEVICE} ${IMAGE_FILE}

    #Create an encrypted representation of the block device created above
    dmsetup create ${MAP_DEVICE} --table "${TABLE}"
    if ! mount -o noatime $MOUNT_OPTIONS /dev/mapper/${MAP_DEVICE} ${MOUNT_POINT}
    then
        found=0
        #look for a bootloader that had created this cv
        for i in $KEY_TRY
        do
            teardown_cv ${LOOP_DEVICE} ${MAP_DEVICE} ${MOUNT_POINT}
            #unload tsip module
            rmmod sh_tsip
            #restart the tsip with the other key
            modprobe sh_tsip tsip_key=${i}

            #Set up loopback device to use the image file as a block device
            losetup ${LOOP_DEVICE} ${IMAGE_FILE}

            #Create an encrypted representation of the block device create above
            dmsetup create ${MAP_DEVICE} --table "${TABLE}"
            if  mount -o noatime $MOUNT_OPTIONS /dev/mapper/${MAP_DEVICE} ${MOUNT_POINT}
            then
                 echo "Found uboot key ${i}"
                 copy_cv  ${IMAGE_FILE} $LOOP_DEVICE $MAP_DEVICE "${TABLE}" $MOUNT_POINT $FS_TYPE "${MOUNT_OPTIONS}" $CV_SIZE 
                 #return to original state
                 teardown_cv ${LOOP_DEVICE} ${MAP_DEVICE} ${MOUNT_POINT}
                 #unload tsip module
                 rmmod sh_tsip
                 #restart the tsip with the original SPI key
                 modprobe sh_tsip
                 found=1
                 break; #Done
            fi
        done
        if [ "$found" -eq 0 ]
        then
           #didn't find it, reset tsip and we'll have to recreate unfortunately
           echo "Couldn't find cv key"

           #return to original state
           teardown_cv ${LOOP_DEVICE} ${MAP_DEVICE} ${MOUNT_POINT}
           #unload tsip module
           rmmod sh_tsip
           #restart the tsip with the original SPI key
           modprobe sh_tsip
        fi
    else
        #good cv, just tear it down and let the rest of the boot restore it
        teardown_cv ${LOOP_DEVICE} ${MAP_DEVICE} ${MOUNT_POINT}
    fi
}

setup_cv() {
    local IMAGE_FILE=$1
    local LOOP_DEVICE=$2
    local MAP_DEVICE=$3
    local TABLE=$4
    local MOUNT_POINT=$5
    local FS_TYPE=$6
    local MOUNT_OPTIONS=$7

    #Set up loopback device to use the image file as a block device
    losetup ${LOOP_DEVICE} ${IMAGE_FILE}

    #Create an encrypted representation of the block device create above
    dmsetup create ${MAP_DEVICE} --table "${TABLE}"
    if ! mount -o noatime $MOUNT_OPTIONS /dev/mapper/${MAP_DEVICE} ${MOUNT_POINT}
    then
        #Format it for ext2 fs
        mkfs.${FS_TYPE} /dev/mapper/${MAP_DEVICE}
        mount -o noatime $MOUNT_OPTIONS /dev/mapper/${MAP_DEVICE} ${MOUNT_POINT}
    fi

}

teardown_cv() {
    local LOOP_DEVICE=$1
    local MAP_DEVICE=$2
    local MOUNT_POINT=$3
    umount -f -l $MOUNT_POINT ||:
    dmsetup remove $MAP_DEVICE ||:
    losetup -d $LOOP_DEVICE ||:
}

do_key_update() {
# Updating the firmware, if the SPI keys are different, archive the current cv contents
        # and recreate with the new key
        if [ -e /tmp/new_bootloader_key ]
        then
            key_update=0
            dd if=/tmp/new_bootloader_key of=/tmp/NewKey.bin bs=1 count=256 skip=4936
            if [ -e /flash/data0/features/not-shasta ]
            then
                # 12g already had the new bootloader blasted into the SPI
                # we should have saved off a copy of the current
                # just check and see if we need to update
                if [ -e /tmp/SPIblk0.bin ]
                then
                    dd if=/tmp/current_bootloader_key.bin of=/tmp/SPIblk0.bin bs=1 count=256 skip=4936
                fi
                if ! diff /tmp/SPIblk0.bin /tmp/NewKey.bin
                then
                     key_update=1
                fi
            elif [ -e /flash/data0/features/shasta ]
            then
                #new_bootloader_key should have the uboot for the partition that will be booted
                #if it's version is different than the one in SPI it will become the new
                #key and we need to check if it's different than the current key we're using
                dd if=/tmp/new_bootloader_key of=/tmp/NewKeyVer.bin bs=1 count=12 skip=16
                dd if=/tmp/current_bootloader_key.bin of=/tmp/SPIblk0Ver.bin bs=1 count=12 skip=16
                if ! diff /tmp/SPIblk0Ver.bin /tmp/NewKeyVer.bin
                then
                   if ! diff /tmp/SPIblk0.bin /tmp/NewKey.bin
                   then
                      key_update=1
                   fi
                fi
            fi



            # If the bootloader is updating, and it has a new key
            # then regenerate the cv's with new bootloader key
            # that way we won't lose data
            if [ "$key_update" -eq 1 ]; then
                # Bootloader keys are different
                if ! umount /flash/data0/cv
                then
                   echo "Failed to umount CV " $?
                   #fuser -m /flash/data0/cv
                   #ps
                   # Hopefully something is just temporarily accessing the mount point
                   # give it a chance to complete and see if it can go on
                   umount -f -l /flash/data0/cv  ||:
                   sleep 2
                   sync

                fi
                copy_cv /mmc1/.cv.img $LOOPDEV_13G 13g_cv "$TABLE_13G" /flash/13g-cv ext3 "-o data=ordered" $CV_SIZE_MB_13G "tsip_key=/tmp/new_bootloader_key"
                if [ -e /flash/data0/features/not-shasta ]
                then
                    #if we're on 12g hw unload the cv so we can resync 12g cv with the new key
                    $0 stop_13g 
                    #12g should be readable with the current SPI key
                    #unload tsip module
                    rmmod sh_tsip
                    #restart the tsip with the original SPI key
                    modprobe sh_tsip tsip_key=/tmp/current_bootloader_key.bin
                    ensure_file /flash/data0/.cv.img 0 $CV_SIZE_MB_12G
                    setup_cv /flash/data0/.cv.img $LOOPDEV_12G 12g_cv "$TABLE_12G" /flash/12g-cv ext2
                    copy_cv /flash/data0/.cv.img $LOOPDEV_12G 12g_cv "$TABLE_12G" /flash/12g-cv ext2 "" $CV_SIZE_MB_12G "tsip_key=/tmp/new_bootloader_key"
                    teardown_cv $LOOPDEV_12G 12g_cv  /flash/12g-cv
                    # the tsip module should have the key to read both the 12g and 
                    # 13g cv's. Setup the 13g cv again and resync 13g->12g using below
                    setup_cv /mmc1/.cv.img $LOOPDEV_13G 13g_cv "$TABLE_13G" /flash/13g-cv ext3 "-o data=ordered"
                fi
            fi
        fi

}

. /etc/init.d/mount-functions.sh

case "$1" in
    start_13g)
        corrupt=0
        while true; do
            ensure_file /mmc1/.cv.img 0 $CV_SIZE_MB_13G /flash/data0/created-13g-cv-from-scratch
            setup_cv /mmc1/.cv.img $LOOPDEV_13G 13g_cv "$TABLE_13G" /flash/13g-cv ext3 "-o data=ordered"
            # detect corruption: if ls returns nonzero, something bad is happening
            # alternative: also have an "alarm" active
            if ! ls /flash/13g-cv/ > /dev/null; then
                corrupt=1
            fi
            if [ "$corrupt" -eq 1 ]; then
                teardown_cv $LOOPDEV_13G  13g_cv /flash/13g-cv
                # remove image file and re-create
                rm /mmc1/.cv.img
                continue
            fi
            break
        done
        mount --bind /flash/13g-cv /flash/data0/cv
        date
        post_mount &
        ;;
    stop_13g)

        # if we're on 13g hardware, then we need to check for a key update as copy_to_12g will not have been run
        if [ -e /flash/data0/features/shasta ]
        then
            do_key_update
        fi

        # none of these matter if they fail, hence ||:
        umount /flash/data0/cv  ||:
        teardown_cv $LOOPDEV_13G 13g_cv /flash/13g-cv
        ;;
    copy_to_12g)

        # check for key update and recreate the cv if necessary
        do_key_update
                
        #if the key was updated, then the result of do_key_update should have the correct key in for the driver
        #and we can copy as usual

        # TODO: need a smarter way of doing this. it needlessly writes to flash. rsync would be better
        ensure_file /flash/data0/.cv.img 0 $CV_SIZE_MB_12G
        setup_cv /flash/data0/.cv.img $LOOPDEV_12G 12g_cv "$TABLE_12G" /flash/12g-cv ext2
        cp -a /flash/13g-cv/. /flash/12g-cv/.
        teardown_cv $LOOPDEV_12G 12g_cv  /flash/12g-cv
        ;;
    reset)
        $0 stop_13g
        rm -f /mmc1/.cv.img
        rm -f /flash/data0/.cv.img
        ;;
    clear_cv_img)
	if [ -e /flash/data0/clr_cv_img ]; then
		rm -f /mmc1/.cv.img
		rm -f /flash/data0/clr_cv_img
        fi
        ;;
    ensure_cv)
        # Make this a pre condition to save time, during boot it should be the case 
        # automatically
        #umount /flash/data0/cv  ||:
        #Make sure both cv's are down
        #teardown_cv $LOOPDEV_13G 13g_cv /flash/13g-cv
        #teardown_cv $LOOPDEV_12G 12g_cv  /flash/12g-cv

        #save off a copy of the current uboot key in the SPI
        dd if=/dev/mtdblock0 of=/tmp/current_bootloader_key.bin bs=1 count=5632

        # BITS207441. Could be coming from a wave 2 system where this is hanging around, so remove it first
        if [ -e /flash/data0/created-13g-cv-from-scratch ]
        then
            rm -f /flash/data0/created-13g-cv-from-scratch
        fi
        ensure_file /mmc1/.cv.img 0 $CV_SIZE_MB_13G /flash/data0/created-13g-cv-from-scratch
        if [ ! -e /flash/data0/created-13g-cv-from-scratch ]
        then
            #Didn't create the cv from scratch, see if we need to convert from a known key to current SPI key
            find_cv_keys /mmc1/.cv.img $LOOPDEV_13G 13g_cv "$TABLE_13G" /flash/13g-cv ext3 "-o data=ordered" $CV_SIZE_MB_13G
	fi

        #See if there is a current 12g image we can look at
        if [ -e /flash/data0/.cv.img ]
        then
           find_cv_keys /flash/data0/.cv.img $LOOPDEV_12G 12g_cv "$TABLE_12G" /flash/12g-cv ext2 "" $CV_SIZE_MB_12G
        fi

	;;
    *)
        echo $"Usage: $0 {start_13g|stop_13g|reset_13g}"
        exit 1
esac

date
exit $?


#Debugging hints: This sections lists various outputs that may be seen on
#the serial console and attempts to describe the problem that has caused them
#previously

#Init Message-
#"device-mapper: table: 254:0: crypt: Block size of ESSIV cipher does not match IV size of block cipher"

#Problem-
#A crucial kernel module may not be loaded
#/lib/modules/cryptodev.ko
#/lib/modules/sh_tsip.ko

#Init Message-
#"bio too big device loop6 (8 > 0)"

#Problem-
#/flash/data/.cv.img file does not exist

