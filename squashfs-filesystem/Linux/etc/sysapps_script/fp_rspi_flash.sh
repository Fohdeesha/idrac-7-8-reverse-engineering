#!/bin/sh

# NOTE- This scripts mounts jffs2 filesystem on Front Panel RSPI flash device.
 
ERROR_FILE="flash/data3/error.txt"
FP_STATUS_FILE="/tmp/fpflashlog"
FPFLASHIMG="/flash/data3/.fpflash.img"
FP_FLASH_DIR="/flash/data3/fpflash/"

if [ -e /dev/mtdblock9 ] ; then
   echo "`date`: /dev/mtdblock9 exists. mount /dev/mtdblock9 to /flash/data3">>${FP_STATUS_FILE}
   
   mount -t jffs2 -o noatime /dev/mtdblock9 /flash/data3 || \
   (echo "`date`: mount /dev/mtdblock9 failed. formatting and retrying..">>${FP_STATUS_FILE}; flash_eraseall -j /dev/mtd9; mount -t jffs2 -o noatime /dev/mtdblock9 /flash/data3 )
   
   #format if image file exists
   if [ -e ${FPFLASHIMG} ]
   then
   	echo "`date`: ${FPFLASHIMG} exists. formating and remounting..">>${FP_STATUS_FILE}
   	umount /flash/data3; flash_eraseall -j /dev/mtd9; mount -t jffs2 -o noatime /dev/mtdblock9 /flash/data3;
   fi
   
   if [ -e ${ERROR_FILE} ] ; then
   	   echo "`date`: Error! ${ERROR_FILE} exists. /dev/mtdblock9 mount to /flash/data3 failed!!">>${FP_STATUS_FILE}
   	   exit 1
   fi  
   
   if [ ! -e ${FP_FLASH_DIR} ]
   then
   	echo "`date`: mkdir ${FP_FLASH_DIR}">>${FP_STATUS_FILE}  
	mkdir ${FP_FLASH_DIR} || exit 1
   fi
   
   echo "`date`: mount /dev/mtdblock9 on /flash/data3 success">>${FP_STATUS_FILE}
fi
