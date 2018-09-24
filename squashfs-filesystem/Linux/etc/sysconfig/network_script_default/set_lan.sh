#!/bin/sh

RESOLV_CONF=/etc/resolv.conf
UDHCPC_SCRIPT=/etc/sysconfig/network_script/udhcpc/default.script

if [ $# -lt 1 ]; then
        echo Usage: ${0##*/} \<Config File Name\> \<Interface Name\>
        exit 1
fi

DEST_FILE=$1

# only for old 1 parameter to new 2 parameters (need interface name)
# transition period 
if [ "x$2" != "x" ]; then
    IFNAME=$2
else
    IFNAME="eth0"
fi

# Set IP or start dhcpc, 0=disable, 1=enable
V4DHCP=`grep -m 1 "^DHCP=" ${DEST_FILE} | cut -c 6-`
if [ "x$V4DHCP" = "x1" ]; then
    echo "starting DHCP client..."
    pid=`pidof udhcpc`
    if [ "x$pid" != "x" ]; then
        kill $pid
        sleep 3
    fi
    udhcpc -i ${IFNAME} -s ${UDHCPC_SCRIPT} &
else
    V4IP=`grep -m 1 "^IPADDRESS=" ${DEST_FILE} | cut -c 11-`
    V4NETMASK=`grep -m 1 "^NETMASK=" ${DEST_FILE} | cut -c 9-`
    if [ "x$V4IP" != "x" -a "x$V4NETMASK" != "x" ]; then
        echo "set static IP"
        ifconfig ${IFNAME} $V4IP netmask $V4NETMASK
    else
        echo "missing IP or netmask, unable to set static IP"
        exit 1
    fi
fi

V4GATEWAY=`grep -m 1 "^GATEWAY=" ${DEST_FILE} | cut -c 9-`
if [ "x$V4GATEWAY" != "x" ]; then
    echo "Setting Gateway..."
    route add default gw $V4GATEWAY
fi

V4DNS1=`grep -m 1 "^DNSSERVER1=" ${DEST_FILE} | cut -c 12-`
if [ "x$V4DNS1" != "x" ]; then
    echo "Setting DNS server 1..."
    echo "nameserver $V4DNS1" >> $RESOLV_CONF
fi

V4DNS2=`grep -m 1 "^DNSSERVER2=" ${DEST_FILE} | cut -c 12-`
if [ "x$V4DNS2" != "x" -a "x$V4DNS2" != "x$V4DNS1" ]; then
    echo "Setting DNS server 2..."
    echo "nameserver $V4DNS2" >> $RESOLV_CONF
fi

# end of set_lan.sh

