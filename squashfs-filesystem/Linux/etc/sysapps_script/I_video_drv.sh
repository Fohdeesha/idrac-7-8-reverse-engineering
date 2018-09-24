#!/bin/sh

MODULEDIR="/lib/modules"
MODULE="aess_video"
DEVDIR="/dev/avct"
insmod $MODULEDIR/$MODULE.ko || exit
dev_major=`grep $MODULE /proc/devices | awk '{print $1}'`
if [ "$dev_major" = "" ]; then exit; fi
mkdir -p $DEVDIR
mknod $DEVDIR/video c $dev_major 0
