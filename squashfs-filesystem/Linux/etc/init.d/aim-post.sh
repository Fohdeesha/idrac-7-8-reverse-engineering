#!/bin/sh
exec > /var/log/aim.log 2>&1
set -x

# former stuff from fullfw_init, detect amea, et al
echo "start at $(date)"


#  Reset the bios SEL set block
/avct/sbin/aim_config_set_bool set_sel_time_block false false

#echo "================================="
#echo "AMEA card is present or not      "
#echo "================================="
#echo "Read CPLD Offset 0x21 Bit 3"
CPLD_Byte_21=`MemAccess -rb 0x14000021 | grep 0x14000021 | awk '{print $3}'`
AMEA_PRES_N=`printf "0x%02x" $(( 0x$CPLD_Byte_21 & 0x08 ))`

if [ "0x00" == "$AMEA_PRES_N" ] ; then
	/avct/sbin/aim_config_set_bool ameastatus_bool_12G_amea_present true
else
	/avct/sbin/aim_config_set_bool ameastatus_bool_12G_amea_present false
fi

/avct/sbin/aim_config_set_bool ameastatus_bool_amea_present true
/etc/sysapps_script/maser_info.sh

PLATFORM_ID_INT_HEX=`/etc/default/ipmi/systemID`
PLATFORM_ID_INT=`printf "%d" 0x${PLATFORM_ID_INT_HEX}`
PLATFORM_ID_STR=`/etc/default/ipmi/getsysid`

/avct/sbin/aim_config_set_int platform_int_id ${PLATFORM_ID_INT} false
/avct/sbin/aim_config_set_str platform_str_id ${PLATFORM_ID_STR} false

# duplicate address detection
/usr/bin/ipv6_accept_dad_enable.script

if [ -e /flash/data0/features/platform-modular ]; then
    # set the platform type to be modular
    /avct/sbin/aim_config_set_bool platform_bool_is_blade true false

    (MemAccess BLADE_ID > /dev/null)
    BLADEID=$?

    # Set AIM variable for blade slot location  
    /avct/sbin/aim_config_set_int blade_int_slot_number $BLADEID

    # Create this variable so the get RFS request early in iDRAC boot doesn't fail
    /avct/sbin/aim_config_set_bool pm_bool_rfs_enabled false false
else

    # set the platform type to be monolithic
    /avct/sbin/aim_config_set_bool platform_bool_is_blade false false
fi


# script for DCS specific initialization
# needs to run after config_lib and AIM are initialized.
if [ -e /flash/data0/features/dcs ]
then
	PLATFORM_ID=$(cat /flash/data0/features/memaccess-platform-id)
	if  [[ "$PLATFORM_ID" = "99" ]]; then
     echo "This is Metallica"
     echo "setting dcsgui to 1"
     /avct/sbin/aim_config_set_int gui_int_control_dcsgui 1
     echo "setting csior to 0"
     writecfg -g 16640 -e 1 -f 1 -v"0"
     echo "setting lc to disabled"
     writecfg -g 16640 -e 1 -f 4 -v"1"
	fi
fi

mv /tmp/mount.log /var/log/ ||:

echo "end at $(date)"
