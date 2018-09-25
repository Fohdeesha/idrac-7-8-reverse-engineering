#!/bin/sh

set -x

MASER_IMAGE=$1
MOUNT_POINT=$2
MOUNT_RESULT=$3
DEV_NAME=$4

if [ ! -d $MOUNT_POINT ]
then
        mkdir -p $MOUNT_POINT 
fi

partDes=`fdisk -lu $MASER_IMAGE | grep ^$MASER_IMAGE`
echo "$partDes"
boot=`echo "$partDes" | awk '{print $2}'`
echo "$boot"

case ${boot} in
    "*")
        echo Bootable image
        sector_start=$(echo "$partDes" | awk '{print $3}')
        ;;
    *)
        echo Non bootable image
        sector_start=$boot
        ;;
esac

sector_size=$(fdisk -lu $MASER_IMAGE 2>/dev/null | grep Units | cut -d '=' -f 3 | cut -d ' ' -f 2)

offset=$(( ${sector_start:-0} * ${sector_size:-0} ))
[ $sector_start -ne 0 ] || echo "image does not have MBR mounting as floppy"
echo Start Sector=$sector_start
echo Sector Size=$sector_size
echo mount offset=$offset

# This is an improved version of the old way of doing things. Instead of manual
# loop around losetup to get next free /dev/loop? device, use 'losetup -f' to
# get the next one. Quick and easy.
# Unfortunately, this method is far inferior to just using the implicit offset=
# parameter to mount, which is supported by util-linux mount, but not busybox
# mount. So, for now we have util-linux mount available, so we will use it.
#
#if ! losetup ${DEV_NAME:=$(losetup -f)} $MASER_IMAGE -o $offset
#then
#    echo "-- losetup $DEV_NAME $MASER_IMAGE -o $offset-- failed"
#    exit 1
#fi
#
#if ! mount -t vfat -o loop $DEV_NAME $MOUNT_POINT -oshortname=mixed
#    echo "-- mount failed"
#    exit 1
#fi

# util-linux supports -o offset= parameter, so it will implicitly and race-free
# setup loop device. If mount.util-linux is not available, use the code section above
if ! mount.util-linux -t vfat -o loop,offset=$offset $MASER_IMAGE $MOUNT_POINT -oshortname=mixed
then
    echo "-- mount failed"
    exit 1
fi

echo mount success!!!
exit 0
