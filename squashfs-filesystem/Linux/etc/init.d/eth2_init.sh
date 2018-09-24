#!/bin/sh
# this only runs on modular (ConditionPathExists=/flash/data0/features/platform-modular)
[ ! -e /flash/data0/features/script-debug ] || set -x

    ifconfig eth2 down
CPLD_Byte_40=`MemAccess -rb 0x14000040 | grep 0x14000040 | awk '{print $3}'`
SLED_PRES_N=`printf "0x%02x" $(( 0x$CPLD_Byte_40 & 0x02 ))`

if [ "0x00" == "$SLED_PRES_N" ] ; then
    echo "SLED NOT PRESENT"
    Is_quarter_height_blade=0
else
    echo "SLED Present"
    Is_quarter_height_blade=1
fi

# bring up eth2, which isn't always applicable and can fail (applicable to modular, dcs)
    ifconfig eth2 hw ether ${mac1} up ||:
    vconfig add eth2 4003

    MemAccess BLADE_ID > /dev/null
    BLADEID=$?
    if [ $Is_quarter_height_blade -eq 1 ]; then
        MemAccess VLAN_ID > /dev/null
        VLAN_ID=$?
        VLANIP=${VLAN_ID}
    else
        VLANIP=${BLADEID}
    fi
    echo BLADEID: ${BLADEID} VLANIP: ${VLANIP}

    echo VLANIP=$VLANIP >> /var/run/features/modular-env
    ifconfig eth2.4003 169.254.31.$VLANIP netmask 255.255.255.0

