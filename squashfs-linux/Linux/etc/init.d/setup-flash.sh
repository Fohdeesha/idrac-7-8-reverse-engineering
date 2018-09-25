#!/bin/sh

# /var/log is not yet present, so we have to log to /tmp for now. This runs early enough in boot that it isn't a security problem.
# ALSO: logging to journal slows things down, so log to file
exec > /tmp/setup-flash.log 2>&1
set -e
set -x

# this file is a combination of cfg-lib-init, fullfw_init, create_symbolic_links
# Theory of operation:
#  1) don't ever fail
#  2) under normal circumstances, never write to flash

# hook to install any files on startup
setup_thermal_config()
{
    persmodpath=/flash/data0/persmod/ThermalConfig.txt
    dracpath=/etc/default/ipmi/default/ThermalConfig.txt
    [ ! -e /flash/pd0/ipmi/${systemname}/ThermalConfig.txt ] || dracpath=/flash/pd0/ipmi/${systemname}/ThermalConfig.txt
    if [ -e $persmodpath ] ; then
        PersmodVer=$(grep TEMPLATE_REVISION_NUM $persmodpath | sed 's/.*\([X,x]\)\([0-9][0-9]\).*/\2/')
        DRACThermalFileVer=`grep TEMPLATE_REVISION_NUM $dracpath | sed 's/.*\([X,x]\)\([0-9][0-9]\).*/\2/' `
        if [ $PersmodVer -le $DRACThermalFileVer ] ; then
            echo "Thermal Config from Identity Module Installed"
            conditional_link $persmodpath /flash/data0/BMC_Data/ThermalConfig.txt
        else
            echo "Thermal Config from Identity Module with version" $PersmodVer "is greater than the iDRAC supported version" $DRACThermalFileVer
            echo "Thermal Config from Identity Module could not be installed"
            conditional_link $dracpath /flash/data0/BMC_Data/ThermalConfig.txt
        fi
    else
        conditional_link $dracpath /flash/data0/BMC_Data/ThermalConfig.txt
    fi
}

# only re-create the link if the symlink is wrong
CREATED_LINK=0
conditional_link() {
    # you can use 'stat' or -ef
    #if [ "$(stat -L -c "%d:%i" $1)" != "$(stat -L -c "%d:%i" $2)" ]; then
    if ! [ $1 -ef $2 ]; then
        echo "Target doesn't match, re-creating symlink: $1 $2"
        ln -sf $1 $2
        CREATED_LINK=1
    fi
}

conditional_mkdir() {
    [ -e $1 ] || echo "Creating directory: $1"
    [ -e $1 ] || mkdir -p $1
}

conditional_copy() {
    if [ -e $1 -a ! -e $2 ]; then
        cp $1 $2
    fi
}

copy_if_differ() {
  # if exist and size is greater than 0
  if [ -s $1 ]; then
    if diff -Nq $1 $2
    then
        cp -f $1 $2
    fi
  fi
}

conditional_touch() {
    for file in $*
    do
        if [ ! -e $file ]; then
            touch $file
        fi
    done
}

cleanup_cache() {
    rm -rf /flash/data0/features
    # remove the links in /flash/data0/config
    if [ -e /flash/data0/config ]; then
        LINKS_LIST=`find /flash/data0/config/ -type l`
        for LINKS in $LINKS_LIST
            do
                rm -f $LINKS
            done
    fi
    # remove the links in /flash/data0/BMC_Data
    if [ -e /flash/data0/BMC_Data ]; then
        LINKS_LIST=`find /flash/data0/BMC_Data/ -type l`
        for LINKS in $LINKS_LIST
            do
                rm -f $LINKS
            done
    fi
}

##############################################################################
# script start
##############################################################################

# for logging purposes. This can be commented out for a-rev
date

# setup system name and platform type
systemname=$(get-system-name)
systemname=`/usr/bin/get-system-name`
(MemAccess PLATFORM_TYPE)
PLATFORM_TYPE=$?
PLATFORM_TYPE_MONOLITHIC=0
PLATFORM_TYPE_MODULAR=1

sysid=$(/etc/default/ipmi/systemID)
cached_id=$(cat /flash/data0/features/system-id  || echo "does not exist")
build_no=$(head -5 /etc/fw_ver)
cached_build_no=$(head -5 /flash/data0/features/fw_ver || echo "does not exist")

if [ "$build_no" != "$cached_build_no" ] || [ "$sysid" != "$cached_id" ]; then
    cleanup_cache
fi

# Dirty work around to remove any previously existing _1 backup files
if [ -f /flash/data1/config/_1 ] ; then
   rm -rf /flash/data1/config/_1
fi

# delete unwanted files
size=`df -k | grep /flash/data0 | xargs | cut -d" " -f5 | cut -d"%" -f1`
if [ $size -gt 95 ]; then
   /etc/cleanup_scripts/flash/BMC_Data.sh
   /etc/cleanup_scripts/flash/config.sh

fi
# JIT-26584 find and delete any stray core files in /flash/data0/home (any files bigger than 100k)
/bin/find /flash/data0/home -size +100k -delete -print ||:
echo "find on /flash/data0/home returned $?"

# normal case is NO config corruption, so let's optimize that
# start readcfg early and cross fingers. If we touch anything, we have to
# re-run readcfg. It wastes time to re-run, but should be a rare thing.
RERUN_READCFG=0
if [ -f /flash/data0/config/gencfggrp.txt ]; then
    readcfg -g9 &
else
    RERUN_READCFG=1
fi

conditional_mkdir /flash/data0/fsdf
conditional_mkdir /flash/data0/dhcp
conditional_mkdir /flash/data1/LCL
conditional_mkdir /flash/data0/etc
conditional_mkdir /flash/data0/tm
if [ ! -e /flash/data0/tm/localtime ]; then
    ln -s /etc/zoneinfo/CST6CDT /flash/data0/tm/localtime
fi
conditional_mkdir /flash/data0/oem_ps
conditional_copy /etc/default/ipmi/default/NVRAM_SEL00.dat /flash/data0/oem_ps/NVRAM_SEL00.dat

for file in group passwd shadow hosts
do
    conditional_copy /etc/default/${file} /flash/data0/etc/${file}
    mount --bind /flash/data0/etc/${file} /etc/${file}
done

# make /etc/services writeable and persistent
conditional_copy /etc/services.default /flash/data0/etc/services
conditional_link /flash/data0/etc/services /etc/services

# /flash/data0/home/root is the root dir for ssh session. Create it if does not exist
conditional_mkdir /flash/data0/home/root

# default case is no change
USER_LIST="root racuser user1 avahi sshd messagebus _lldpd"
GROUP_LIST="messagebus tty dialout kmem video audio lp disk floppy cdrom tape utmp adm avahi _lldpd"
for group in ${GROUP_LIST}
do
    if ! /bin/grep -q $group /flash/data0/etc/group; then
        /bin/grep $group /etc/default/group >> /flash/data0/etc/group ||:
    fi
done
for file in passwd shadow ; do
    for user in ${USER_LIST}
    do
        if ! /bin/grep -q $user /flash/data0/etc/${file}; then
             /bin/grep $user /etc/default/${file} >> /flash/data0/etc/${file} ||:
        fi
    done
done

# TODO: optimize this out
conditional_touch /flash/data0/oem_ps/maserinit

##############################################################################
# Setup /flash/data0/BMC_Data
##############################################################################
BMCDIR=/flash/data0/BMC_Data
conditional_mkdir $BMCDIR
for copyfile in NVRAM_PrivateStorage00.dat NVRAM_FRU00.dat NVRAM_Storage00.dat
do
    if [ -e $BMCDIR/$copyfile ]; then
        continue
    fi
    conditional_copy /flash/pd0/ipmi/$systemname/$copyfile $BMCDIR/$copyfile
    conditional_copy /etc/default/ipmi/default/$copyfile   $BMCDIR/$copyfile
done

conditional_link /flash/data0/oem_ps/NVRAM_SEL00.dat $BMCDIR/NVRAM_SEL00.dat

binfiles=$(cd /etc/default/ipmi/default; echo *.bin; cd /flash/pd0/ipmi/$systemname; echo *.bin)
for file in \
    ThermalData.txt   \
    bmcsetting    \
    NVRAM_SDR00.dat   \
    drvsetting.dat    \
    $binfiles
do
    if [ -e /flash/pd0/ipmi/$systemname/$file ]; then
        conditional_link /flash/pd0/ipmi/$systemname/$file $BMCDIR/$file
    else
        conditional_link /etc/default/ipmi/default/$file $BMCDIR/$file
    fi
done

# this may come from platform data, above. if it's not linked/copied above, do
# it here
if [ ! -e /flash/pd0/ipmi/${systemname}/oemdef.bin ] ; then
    if [ $PLATFORM_TYPE -eq $PLATFORM_TYPE_MODULAR ]; then
        conditional_link /flash/pd0/ipmi/Mojo/oemdef.bin $BMCDIR/oemdef.bin
    else
        conditional_link /flash/pd0/ipmi/Orca/oemdef.bin $BMCDIR/oemdef.bin
    fi
fi

# Only the Orac device id is updated for the release, so specifically link it in (needs to be run after the for loop above to link correctly)
if [ -e /flash/pd0/ipmi/Orca/ID_devid.bin ] ; then
    conditional_link /flash/pd0/ipmi/Orca/ID_devid.bin $BMCDIR/ID_devid.bin
fi

# Table override
table_override_files="IO_fl.bin IS_fl.bin IO_api.bin NVRAM_SDR00.dat"
for file in $table_override_files ; do
    if [ -f /flash/data0/persmod/${file} ]; then
        conditional_link /flash/data0/persmod/${file} $BMCDIR/${file}
    fi
done

setup_thermal_config

##############################################################################
# set up /flash/data0/config. From old cfg-lib-init
# check config backup and recover config, if necessary.
# also perform default setup, if necessary
##############################################################################

conditional_mkdir /flash/data0/config
conditional_mkdir /flash/data1/config ||:
conditional_mkdir /flash/data0/config/network_config
conditional_mkdir /flash/data0/sysconfig

# delete any old backups in legacy location
[ ! -e /flash/data0/cfgbkp ] || rm -rf /flash/data0/cfgbkp

BACKUP_PATH=/mmc1/cfgbkp
BACKUP_FILENAME=cfgbkp.tar.bz2
BACKUP_MD5SUM=${BACKUP_FILENAME}.md5
BACKUP_CONTENTS_MD5SUM=cfgbkp-contents.md5
BACKUP_FILE_LIST=$BACKUP_PATH/cfgfiles.lst

CREATED_LINK=0
RESTORE_CONFIG=0
conditional_mkdir $BACKUP_PATH

# check if config matches the saved md5sum of the config. if it doesn't match,
# there has been some sort of corruption, and we have to either restore from
# backup, or reset to defaults
if [ -f $BACKUP_FILE_LIST -a -f $BACKUP_PATH/$BACKUP_CONTENTS_MD5SUM ]
then
    CONTENTS_MD5=$(cat $(cat $BACKUP_FILE_LIST)|md5sum |awk '{print $1}')
    if [ "$CONTENTS_MD5" != "$(awk '{print $1}' $BACKUP_PATH/$BACKUP_CONTENTS_MD5SUM)" ]
    then
        # data is bad
        RESTORE_CONFIG=1
    fi
else
    # if we don't have a backup present, this could be first boot after
    # upgrade, so can't reset to defaults immediately
    mkdir -p $BACKUP_PATH

    # touch a null contents MD5SUM. If system hangs and can't boot due to
    # corrupted config, we will reset to defaults on the next boot
    touch $BACKUP_PATH/$BACKUP_CONTENTS_MD5SUM
    touch $BACKUP_FILE_LIST
fi

if [ $RESTORE_CONFIG -eq 1 ]
then
    # Check md5sum of backup tarball.
    if [ "$(awk '{print $1}' $BACKUP_PATH/$BACKUP_MD5SUM)" == "$(md5sum $BACKUP_PATH/$BACKUP_FILENAME | awk '{print $1}')" ]
    then
        # backup tarball is good, so lets recover from it
        echo "Corruption detected, restoring backup files."
        wait
        RERUN_READCFG=1
        tar -xjf $BACKUP_PATH/$BACKUP_FILENAME -C / ||:
        echo "Data recovered from backup data."
    else
        # backup tar md5sum doesn't check out, get rid of backup. We also know
        # config is corrupted, so RESET TO DEFAULTS
        rm -rf $BACKUP_PATH
        rm -rf /flash/data0/config
        mkdir /flash/data0/config
    fi
fi

cfgdir=/flash/data0/config
for file in lmcfg.txt platcfggrp.txt platcfgfld.txt cfgfld.txt  \
    cfggrp.txt gencfggrp.txt \
    gencfgfld.txt \
    nonpmaltdefaults.txt    \
    altdefaults.txt
do
    if [ -e  /flash/data0/persmod/$file ]; then
        conditional_link /flash/data0/persmod/$file $cfgdir/$file
    elif [ -e /flash/pd0/config/$file ]; then
        conditional_link /flash/pd0/config/$file $cfgdir/$file
    elif [ -e /flash/pd0/ipmi/$systemname/$file ]; then
        conditional_link /flash/pd0/ipmi/$systemname/$file $cfgdir/$file
    elif [ -e /etc/default/config/$file ]; then
        conditional_link /etc/default/config/$file  $cfgdir/$file
    elif [ -e /etc/default/ipmi/default/$file ]; then
        conditional_link /etc/default/ipmi/default/$file $cfgdir/$file
    else
        echo "PANIC: Could not find a copy of $file to use."
    fi
done

#Below allows 12g system have different default values. link for 13g systems will be created above.
#For 12g the link willbe overwritten below. Checking for 12G can reuse code way below this script.
#That will require reordering the code in this script as this is close to  A-rev.
ChipId12g="0000311"
if /bin/MemAccess2 -rl -a ff000044 -c 1 | grep 0xff000044 | grep -q $ChipId12g
then
if [ "$sysid" != "72" ]
then
        conditional_link /etc/default/config/nonpm12galtdefaults.txt  $cfgdir/nonpmaltdefaults.txt
fi
fi


##############################################################################
#
# PANTERA HACK
# WARNING: if you use the pantera hack, your boot will be slower. Don't complain.
#
#Remove this after we have Pantera system. Till then any monolithic can
# be made as Pantera (only for applications)
##############################################################################
if [ "$systemname" = "Pantera" -o -e /flash/data0/dcs ]; then
    if [ -e /flash/pd0/ipmi/Pantera/oemdef.bin ]; then
        conditional_link /flash/pd0/ipmi/Pantera/oemdef.bin $BMCDIR/oemdef.bin
    fi
    if [ -e /flash/pd0/ipmi/Pantera/lmcfg.txt ]; then
        conditional_link /flash/pd0/ipmi/Pantera/lmcfg.txt $cfgdir/lmcfg.txt
    fi
fi


##############################################################################
# Network config files setup
##############################################################################
if [ $PLATFORM_TYPE -eq $PLATFORM_TYPE_MODULAR ]; then
    NET_CONFIG_SRC=Mojo
else
    NET_CONFIG_SRC=Orca
fi

##############################################################################
# Read Config recovery
##############################################################################
if [ $RERUN_READCFG -eq 1 -o $CREATED_LINK -eq 1 ]; then
    wait  # make sure all background processes kicked off previously in this script have completed
    readcfg -g9 & # do it in the background while we finish out the script
fi

##############################################################################
#Create mas027
##############################################################################
# some systems have old core files on mmc2
rm -f /mmc2/core*

if conditional_mkdir /mmc2/mas027
then
    conditional_link /mmc2/mas027 /mmc1/mas027
else
    echo "/mmc2 could not create /mmc2/mas027. Most likely problem is a full filesystem"
fi

# license manager setup
conditional_copy /etc/default/fake_feb.txt /flash/data0/etc/fake_feb.txt

##############################################################################
# feature detection
# - one time stuff we shouldnt have to run on every boot: system name, id,
# modular/monolithic, dcs
# - once we lay down these feature flags, no need to ever touch them again, so
# we are optimizing this such that the normal case is that we don't run
# anything except stat() calls
##############################################################################

conditional_mkdir /flash/data0/features

if [ ! -e /flash/data0/features/system-name ]; then
    echo ${systemname} > /flash/data0/features/system-name
fi

if [ ! -e /flash/data0/features/system-id ]; then
    echo ${sysid} > /flash/data0/features/system-id
fi

conditional_copy /etc/fw_ver /flash/data0/features/fw_ver

if [ ! -e /flash/data0/features/shasta -a ! -e /flash/data0/features/not-shasta ]; then
    # Detect SHASTA and create flag file
    ShastaChipId="00003120"
    if /bin/MemAccess2 -rl -a ff000044 -c 1 | grep 0xff000044 | grep -q $ShastaChipId
    then
        echo "Shasta chip ID detected"
        conditional_touch /flash/data0/features/shasta
    else
        echo "Shasta chip ID not detected"
        conditional_touch /flash/data0/features/not-shasta
    fi
fi

if [ -e /flash/data0/features/shasta ]; then
    # back compat: remove after wave2 search/replace has fixed all refs
    ln -sf /flash/data0/features/shasta /tmp/shasta

    # The above ln can be removed after the refs have been fixed, but
    # the following shmwrites must remain
    echo 0x2 | shmwrite -s10 -o8 -l1
else
    echo 0x1 | shmwrite -s10 -o8 -l1

fi

if [ ! -e /flash/data0/features/memaccess-platform-id ]; then
    # parens to ensure we don't exit on non-zero return code
    (MemAccess PLATFORM_ID)
    echo $? > /flash/data0/features/memaccess-platform-id
fi

if [ `cat /flash/data0/features/memaccess-platform-id` -eq 113 ]; then
    conditional_touch /flash/data0/features/wcs
    echo "This is Nirvana, disabling power budget"
    writecfg -g 17203 -e 1 -f 1 -v"0"
fi

if [ `cat /flash/data0/features/memaccess-platform-id` -eq 116 ]; then
    conditional_touch /flash/data0/features/wcs
fi

# If we're configured for fips mode, make sure that the features file is in sync
if [ -e /flash/data0/oem_ps/fips.txt ]; then
   echo "LD_LIBRARY_PATH=/usr/fips" > /flash/data0/features/fips.txt
fi

# back compat: remove after wave2 search/replace has fixed all refs
ln -sf /flash/data0/features/system-id /tmp/platform_id

if [ ! -e /flash/data0/features/memaccess-platform-type ] ||
   [ ! -e /flash/data0/features/platform-modular -a ! -e /flash/data0/features/platform-monolithic ]
then
    # parens to ensure we don't exit on non-zero return code
    (MemAccess PLATFORM_TYPE)
    PLATFORM_TYPE=$?
    echo $PLATFORM_TYPE > /flash/data0/features/memaccess-platform-type
    if [ "$PLATFORM_TYPE" == "1" ]; then
        conditional_touch /flash/data0/features/platform-modular
    else
        conditional_touch /flash/data0/features/platform-monolithic
    fi
fi

# if modular, make sure eth2 is initialized
if [ -e /flash/data0/features/platform-modular ]; then
    conditional_touch /flash/data0/features/eth2-init
fi

###############################################
# DCS feature - sort of complicated... *sigh*
###############################################
if [ -e /flash/data0/dcs -a -e /flash/data0/features/not-dcs ]; then
    rm -f /flash/data0/features/not-dcs  /flash/data0/features/dcs
fi

if [ -e /flash/data0/dcs ]; then
    conditional_touch /flash/data0/dcs
fi

if [ ! -e /flash/data0/features/dcs -a ! -e /flash/data0/features/not-dcs ] ||
   [ -e /flash/data0/dcs ]
then
    dcs_val=0x`MemAccess2 -rb -a 0x1400000A -c 1|grep -i 0x1400000A | cut -f3 -d ' '`
    dcs_type=$(( dcs_val & 8 ))
    if [ $dcs_type -eq 8 -o -e /flash/data0/dcs ]; then
        conditional_touch /flash/data0/features/dcs
    else
        conditional_touch /flash/data0/features/not-dcs
    fi
fi

# Do the shmwrites for the DSC feature
if [ -e /flash/data0/features/dcs ]
then
     echo 0x2 | shmwrite -s10 -o7 -l1
else
    if [ -e /flash/data0/features/wcs ]
    then
        echo 0x3 | shmwrite -s10 -o7 -l1
    else
        echo 0x1 | shmwrite -s10 -o7 -l1
    fi
fi
###############################################

wait
if [ "$sysid" != "72" ] && [ -e /flash/data0/features/not-shasta ]
then
   writecfg -g 16394 -f 9 -v'1'
fi

##############################################################################
# DCS - Special handling for MaxNumberOfSessions
##############################################################################
wait
MAXSESSIONS_FLD=`readcfg -g 16393 -f 8 | cut -d "=" -f 2`
if [ $MAXSESSIONS_FLD -ne 8 ]; then
    writecfg -g 16393 -f 8 -v'8'
fi


# for logging purposes. This can be commented out for a-rev
echo "setup flash complete at $(date)"
