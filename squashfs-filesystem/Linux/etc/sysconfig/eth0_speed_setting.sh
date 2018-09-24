#!/bin/sh

wait_for_iface()
{
loop=30
while [ $loop -gt 0 ]
do
    /sbin/ifplugstatus -q $1
    case $? in
    0)
        echo "success"
    ;;
    1)
        echo "error"
    ;;
    2)
        echo "link detect"
        break
    ;;
    3)
        echo "unplugged"
    ;;
    esac
    loop=$(( $loop - 1 ))
    sleep 1
done

if [ $loop -le 0 ]; then
    exit 1
fi
}

wait_fot_ethtool()
{
loop=30

while [[ "Unknown!" == "`ethtool eth0 | grep Speed | awk '{printf $2}'`" ]]
do
	echo "Wait for ethtool to get ready"
	if [ $loop -gt 0 ]; then
		loop=$(( $loop - 1 ))
	else
		exit 1
	fi
done	
}

MemAccess PLATFORM_TYPE > /dev/null
PLATFORM_TYPE=$?
if [[ "$PLATFORM_TYPE" == "1" ]]; then
	echo "For Modular Always set the speed to Manual, 100Mbps, Full duplex"
#	wait_for_iface eth0
	wait_fot_ethtool
	/usr/sbin/ethtool -s eth0 autoneg off speed 100 duplex full
else
#########################################################
# Apply Ethernet settings (Dell 12G use ETHTOOL_IFNAME, not IFNAME)
#########################################################
    if [[ -e /tmp/network_config/iDRACnet.conf ]]; then
    	source /tmp/network_config/iDRACnet.conf
    	if [[ -e /tmp/network_config/NICSwitch.conf ]]; then
	    source /tmp/network_config/NICSwitch.conf
	    if [[ "${AUTO}" == "1" ]]; then
	    	NET_MODE="${AUTO_NET_MODE}"
	    fi
    	fi
    	if [[ "${IFACE_ENABLED}" == "yes" ]] && [[ "${NET_MODE}" == "0" ]]; then
	    wait_fot_ethtool
	    if [[ "${ENET_AUTONEG_ENABLED}" == "yes" ]]; then
		ethtool -s eth0 autoneg on
	    else
		ethtool -s eth0 autoneg off speed ${ENET_SPEED} duplex ${ENET_DUPLEX}
	    fi
    	fi
    fi
fi
exit 0
