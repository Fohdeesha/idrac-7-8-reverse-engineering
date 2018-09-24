#!/bin/sh

#touch /tmp/hotplug.log

if [ -e /tmp/hotplug.log ]; then
	debug_file=/tmp/hotplug.log
else
	debug_file=/dev/null
fi

echo "Hotplug $1: $ACTION $DEVPATH" >> $debug_file

#vFlash needs to auto-attach after reboot of iDrac. This portion sets the parameters
#The script needs to get called with a parameter "boot" during startup.
if [ "$1" == "boot" ]; then
    echo -e "iDrac booting up. Autoattach vflash partitions..." >> $debug_file
    bitmap_cfg=`readcfg -g16456 -f8`
    sig_cfg=`readcfg -g16456 -f9`
    tmpfile="/tmp/signature.tmp"
    sigfile="/tmp/vfk/ManagedStoreID.xml.sig"

    if [ "${sig_cfg:0:12}" == "Signature_1=" ]
    then
        echo -e "bitmap_cfg=$bitmap_cfg\nsig_cfg=$sig_cfg\nbitmap=${bitmap_cfg:9}" >> $debug_file
        echo -n "${sig_cfg:12}" > $tmpfile
        diff=`cmp $sigfile $tmpfile`
        echo -e "Comparing signatures... diff=$diff" >> $debug_file

        #Wait until the DM Stage 2 is up and running
        # the huge sleep here is to wait until DM stage2 is completely loaded. 
        # A shorter sleep with retries does not seem to be working
        #sleep 60
    
        # If sigfile and cfglib match, then vfctrl attach the bitmap present in cfglib after a sleep. 
        [ "$diff" == "" ] && [ "${bitmap_cfg:0:9}" == "Bitmap_1=" ] && (sleep 60) && (/sbin/vfctrl attach "${bitmap_cfg:9}" >> $debug_file;)
        rm $tmpfile
    fi
fi

#if [ `expr "$DEVPATH"x : /block/mmcblk[12]x` == 0 ]; then exit; fi
#Fix for the broken hotplug code
var=`echo $DEVPATH | grep /block/mmcblk[12]`
if [ "$var" == "" ]; then exit; fi

/etc/sysapps_script/maser_info.sh $DEVPATH
device=/dev/`basename $DEVPATH`

if [ "$ACTION" == add ]; then
	mknod $device b `sed 's/:/ /' /sys/$DEVPATH/dev`
	mount -t vfat -o noatime $device /tmp/vfk
	echo vfctrl in $DEVPATH >> $debug_file
	/sbin/vfctrl in
else
	echo vfctrl out $DEVPATH >> $debug_file
	/sbin/vfctrl out
fi
