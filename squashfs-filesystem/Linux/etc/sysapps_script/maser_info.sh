#!/bin/sh

KINGSTON_MID="0x000041"
KINGSTON_OID="0x3432"
STEC_MID="0x000013"
STEC_OID="0x4b47"
STEC_OLD_MID="0x000051"
STEC_OLD_OID="0x5360"

check_license()
{
	license=1
	return

	NAME=`cat /sys/$1/device/name`
	device_type=`cat /sys/$1/device/type`
	MID=`cat /sys/$1/device/manfid`
	OID=`cat /sys/$1/device/oemid`
	card_size_sectors=`cat /sys/$1/size`
	card_size_MB=`expr ${card_size_sectors} / 2048`
	if  [ "$NAME" == "DELL1" ] || [ "$NAME" == "dell1" ]
	then
		license=1
	else
		if [ "$MID" == $KINGSTON_MID ] && [ "$OID" == $KINGSTON_OID ] && [ $card_size_MB -gt 900 ] && [ $card_size_MB -lt 1024 ]
		then
			license=1
		fi
		if [ "$MID" == $STEC_MID ] && [ "$OID" == $STEC_OID ] && [ $card_size_MB -gt 900 ] && [ $card_size_MB -lt 1024 ]
		then
			license=1
		fi
		if [ "$MID" == $STEC_OLD_MID ] && [ "$OID" == $STEC_OLD_OID ] && [ $card_size_MB -gt 900 ] && [ $card_size_MB -lt 1024 ]
		then
			license=1
		fi
		
	fi
}

add_record()
{
	device_type=`cat /sys/$1/device/type`
	card_size_MB=`expr \`cat /sys/$1/size\` / 2048`
	rd_only=`cat /sys/$1/ro`
#	rd_only=0
#	if [ -e /sys/$1/device/state ]; then
#		rd_only=`cut -c 5 /sys/$1/device/state`
#	fi
	echo "$MASER_TYPE $device_type 1 $license $card_size_MB $rd_only" > /tmp/maser$MASER_TYPE.info
}

#echo \# storage_type card_type card_pres size\(MB\)

exit_num=0

if [ $1 ]; then
	devpath=$1
else
	devpath=/block/mmcblk1
	MASER_TYPE=0
	if [ -d /sys/block/mmcblk$MASER_TYPE ]; then
		license=1
		add_record /block/mmcblk$MASER_TYPE
		rm -f /tmp/maserinfoerror$MASER_TYPE
	else
		echo "error $MASER_TYPE"
		touch /tmp/maserinfoerror$MASER_TYPE
		exit_num=1
	fi
fi

MASER_TYPE=1
if [ -d /sys/$devpath ]; then
    /avct/sbin/aim_config_set_bool ameastatus_bool_amea_sd_present true
	check_license $devpath
	add_record $devpath
	rm -f /tmp/maserinfoerror$MASER_TYPE
else
    /avct/sbin/aim_config_set_bool ameastatus_bool_amea_sd_present false
	echo "error $MASER_TYPE"
	touch /tmp/maserinfoerror$MASER_TYPE
	rm -f /tmp/maser$MASER_TYPE.info
	exit_num=1
fi

exit $exit_num
