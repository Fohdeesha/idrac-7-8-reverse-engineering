#!/bin/sh

# supress kernel output early
echo "1 4 1 7" > /proc/sys/kernel/printk
/bin/mount /tmp
exec > /tmp/mount.log 2>&1
set -x

/sbin/insmod  /lib/modules/aess_memdrv.ko &
/sbin/modprobe cryptodev
/sbin/modprobe sh_tsip &
#/bin/rm -f /dev/random
#/bin/ln -s hwrng /dev/random

. /etc/init.d/mount-functions.sh

ROOT_DEVICE=$(awk -F'root=/dev/' '{print $2}' /proc/cmdline | cut -d ' ' -f1)
NFSMOUNT=0
if grep nfsroot= /proc/cmdline > /dev/null; then
    NFSMOUNT=1
fi

# filesystems from /etc/fstab that are not already mounted, so we don't have to
# wait for systemd (optimization, not needed)
/bin/mount /var/volatile &

if [ $NFSMOUNT -eq 0 ]; then
    /bin/mount /mmc1 || recover_ext_fs /dev/mmcblk0p12 /mmc1 ext3  > /tmp/mount-mmc1.log 2>&1 &
    /bin/mount /mmc2 || recover_ext_fs /dev/mmcblk0p15 /mmc2 ext3  > /tmp/mount-mmc2.log 2>&1 &
    /bin/mount /mnt/cores || recover_ext_fs /dev/mmcblk0p13 /mnt/cores ext3  > /tmp/mount-cores.log 2>&1 &
    /bin/mount /flash/data0 || recover_ext_fs /dev/mmcblk0p11 /flash/data0 ext3 > /tmp/mount-data0.log 2>&1 &

    # Special handling needed for the times when the SPI flash (/flash/data1) has been detected as unresponsive
    #/bin/mount /flash/data1 || (/usr/sbin/flash_eraseall -j /dev/$(cat /proc/mtd | grep '"lcl"' | cut -d: -f1) && /bin/mount /flash/data1) > /tmp/mount-data1.log 2>&1 &

    /bin/mount /flash/data2 || recover_ext_fs /dev/mmcblk0p14 /flash/data2 ext2 > /tmp/mount-data2.log 2>&1 &
    # the fpspi device shows up later since it requires a separate device driver. We are going to let systemd mount that one for us.
    #/bin/mount /flash/data3 || (/usr/sbin/flash_eraseall -j /dev/$(cat /proc/mtd | grep '"fpspi"' | cut -d: -f1) && /bin/mount /flash/data3) > /tmp/mount-data3.log 2>&1 &

    if [ "$ROOT_DEVICE" == "mmcblk0p2" ]; then
        echo "mounting Platform Data 1 partition"
        /bin/mount /flash/pd9
    elif [ "$ROOT_DEVICE" == "mmcblk0p6" ]; then
        echo "mounting Platform Data 2 partition"
        /bin/mount /flash/pd10
    fi
fi

wait

#Special handling of the SPI flash if we detected the unresponsive state before this
#depends on the mmc being up and mounted, so needs to be after the above 'wait'
if [ $NFSMOUNT -eq 0 ]; then
   if [ -e /mmc1/SPI_shadow.bin ]; then
      echo "Detected SPI shadow.  Attempting to recover."
      # Blindly copy for now
      /usr/sbin/flash_eraseall /dev/$(cat /proc/mtd | grep '"lcl"' | cut -d: -f1)
      dd if=/mmc1/SPI_shadow.bin of=/dev/$(cat /proc/mtd | grep '"lcl"' | cut -d: -f1) skip=7168 bs=256 count=6144
      #remove the file
      rm -f /mmc1/SPI_shadow.bin
   fi
   /bin/mount /flash/data1 || (/usr/sbin/flash_eraseall -j /dev/$(cat /proc/mtd | grep '"lcl"' | cut -d: -f1) && /bin/mount /flash/data1) > /tmp/mount-data1.log 2>&1 &

fi
wait


# select proper platform data mount based on which rootfs we booted from
if [ "$ROOT_DEVICE" == "mmcblk0p2" ]; then
    echo "linking Platform Data 1 partition"
    ln -sf /flash/pd0 /tmp/pd0
    mount --bind /flash/pd9 /flash/pd0
elif [ "$ROOT_DEVICE" == "mmcblk0p6" ]; then
    echo "linking Platform Data 2 partition"
    ln -sf /flash/pd0 /tmp/pd0
    mount --bind /flash/pd10 /flash/pd0
fi

# Set up credential vault mount point here to save a few seconds
[ -e /flash/data0/cv ] || mkdir -p /flash/data0/cv

# run this in the background because it is SLOW! (3 second slowdown)
(
recover_ext_fs /dev/mmcblk0p8 /mnt/rawscratch ext3 327680  > /tmp/mount-rawscratch.log 2>&1
/bin/mount /mnt/scratchpad || recover_scratchpad
)&

OLD_MUT="/mmc1/mut"
DEST="/mmc2"
NEW_MUT="$DEST/mut"
#Move MUT directory from /mmc1 to /mmc2 and create link
if [ ! -L $OLD_MUT ]; then
  echo "=> MUT link doesn't exist"
	if [ -d $OLD_MUT ] && [ ! -d $NEW_MUT ] ; then
		mv $OLD_MUT $DEST
	fi
	if [ ! -d $NEW_MUT ] ; then
		mkdir $NEW_MUT
	fi
	ln -sf $NEW_MUT $OLD_MUT
else
	echo "=> MUT link exists, nothing to do"
fi

