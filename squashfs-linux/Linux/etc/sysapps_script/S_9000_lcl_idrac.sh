#!/bin/sh
SPI_ROOT=/flash/data0/oem_ps
SPI_ROOT1=/flash/data1/
LCL_IMAGE=$SPI_ROOT1/lcl.img
LCL_MOUNT_POINT=/tmp/LCL
LCL_MOUNT_RESULT=/flash/data0/lclmountresult
LCL_MOUNT_SUCCESS=/tmp/lclmount_success

mount_lcl ()
{
	rm -f $LCL_MOUNT_SUCCESS 2>/dev/null
	mount | grep /tmp/LCL
        if [ $? -ne 0 ]
        then
                echo "LCL not mounted creating /tmp/LCL mount..."
                /etc/sysapps_script/mountMaser.sh $LCL_IMAGE $LCL_MOUNT_POINT $LCL_MOUNT_RESULT /dev/loop2
                sleep 1
								if [ ! -f $LCL_MOUNT_RESULT ]
								then
                	echo "LCL successfully mounted"
									touch $LCL_MOUNT_SUCCESS
								fi
				else
          echo "LCL successfully mounted"
					touch /$LCL_MOUNT_SUCCESS
        fi
#	losetup /dev/loop2 $LCL_IMAGE
#	mount -t vfat -o loop /dev/loop2 $LCL_MOUNT_POINT > $LCL_MOUNT_RESULT
#	/etc/sysapps_script/mountMaser.sh $LCL_IMAGE $LCL_MOUNT_POINT $LCL_MOUNT_RESULT /dev/loop2 
#	sleep 1
}

log_fw_ver ()
{
	head -1 /etc/fw_ver | cut -d '.' -f 1-2 | xargs -0 lcllibtest IDRAC IDRAC
	/etc/sysapps_script/maser_info.sh
}

log_app_ver ()
{
        lcllibtest IDRAC APAC /tmp/lclapp &
}

mkdir $LCL_MOUNT_POINT

if [ -f $LCL_IMAGE ] 
then
	mount_lcl 
	log_fw_ver
        log_app_ver
else
	echo "LCL image $LCL_IMAGE not found!" >> $LCL_MOUNT_RESULT
fi

