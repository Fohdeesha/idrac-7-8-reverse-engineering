#!/bin/sh -e
# Start the OSINET Interface component

# This script will update MAC address only if required

ETH_INTERFACE_PROBE_2()
{
    INTERFACE=$1
    ifconfig ${INTERFACE} down hw ether ${2}
    for upnic in ${uplst}
    do
	if [[ "${upnic}" ==  "${INTERFACE}" ]]; then
	    ifconfig ${INTERFACE} up
	fi
    done
}

# always bringup eth1
ifconfig eth1 up

# this will limit no of nic selection in interfaces
if [ `grep -c ncsi /proc/net/dev` -gt 4 ]; then
  aim_config_set_int NumOfEmbdLOMs 4
else
  aim_config_set_int NumOfEmbdLOMs `grep -c ncsi /proc/net/dev`
fi

# detach all slave devices
if grep -Fq "Slave Interface" /proc/net/bonding/bond0; then
    ifconfig bond0 up
    cat /proc/net/bonding/bond0 | grep "Slave Interface" | cut -d" " -f3 | xargs ifenslave -d bond0
fi

# Get MAC address. The MAC will differs only on Modular
if [ -e /flash/data0/config/network_config/iDRACnet.conf ]; then
    source /flash/data0/config/network_config/iDRACnet.conf
fi

# use default MAC if not defined
if [[ -z ${MAC} ]]; then
    MAC=$mac2
fi

# get NIC list and their status. We will restore its settings.
ethlst=`grep eth /proc/net/dev| cut -d: -f1 | xargs`
ncsilst=`grep ncsi /proc/net/dev| cut -d: -f1 | xargs`
uplst=`ifconfig | grep HWaddr | cut -d" " -f1 | xargs`
fulllst="$ethlst $ncsilst"

# compare MAC address and update
for nic in ${fulllst}
do
    if grep -Fiq ${MAC} /sys/class/net/$nic/address ; then
	continue
    fi
    ETH_INTERFACE_PROBE_2 $nic ${MAC}
done

