#!/bin/sh
IPV6_MODULE="/usr/local/lib/modules/ipv6.ko"
DHCP6C_SCRIPT="/etc/sysconfig/network_script/dhcp6c_script"
RESOLV_CONF="/etc/resolv.conf"

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

# if dhcp6c is enable, start it up
DHCPCENABLE=`grep -m 1 "^DHCPCENABLE=" ${DEST_FILE} | cut -c 13-`
case "$DHCPCENABLE" in
    all)
        echo -n "turning on RA and starting dhcp6c to get IP and DNS..."; echo
        echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
        $DHCP6C_SCRIPT start all $IFNAME
        ;;
    ip)
        echo -n "turning on RA and starting dhcp6c to get IP only..."; echo
        echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
        $DHCP6C_SCRIPT start ip $IFNAME
        ;;
    dns)
        echo -n "turning on RA and starting dhcp6c to get DNS only..."; echo
        echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
        $DHCP6C_SCRIPT start dns $IFNAME
        ;;
    no)
        echo -n "dhcp6c disabled..."; echo
        ;;
    *)
        echo -n "cannot start dhcp6c due to invalid option..."; echo
        ;;
esac

# setup IPv6 global address; if no static IP available, turn on RA
if ! [ "$DHCPCENABLE" = "all" -o "$DHCPCENABLE" = "ip" ]; then
    IPV6GLOBALADDR=`grep -m 1 "^IPV6GLOBALADDR=" ${DEST_FILE} | cut -c 16-`
    IPV6GLOBALPREFIX=`grep -m 1 "^IPV6GLOBALPREFIX=" ${DEST_FILE} | cut -c 18-`
    if [ "x$IPV6GLOBALADDR" != "x" -a "x$IPV6GLOBALPREFIX" != "x" ]; then
        echo -n "setting IPv6 global address $IPV6GLOBALADDR/$IPV6GLOBALPREFIX..."; echo
        ip -6 addr add $IPV6GLOBALADDR/$IPV6GLOBALPREFIX dev $IFNAME
# design change - only turn on RA when DHCP is on
#    else
#        echo "no static IP... turning on RA..."
#        echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
    fi
fi

# setup IPv6 default gateway
IPV6DEFGW=`grep -m 1 "^IPV6DEFGW=" ${DEST_FILE} | cut -c 11-`
if [ "x$IPV6DEFGW" != "x" ]; then 
    echo -n "setting IPv6 default gateway $IPV6DEFGW..."; echo
    ip -6 route add ::/0 via $IPV6DEFGW dev $IFNAME
fi

# add IPv6 primary and secondary DNS
if [ ! "$DHCPCENABLE" = "all" -o "$DHCPCENABLE" = "dns" ]; then
    IPV6PRIDNS=`grep -m 1 "^IPV6PRIDNS=" ${DEST_FILE} | cut -c 12-`
    if [ "x$IPV6PRIDNS" != "x" ]; then
        echo -n "adding IPv6 primary DNS $IPV6PRIDNS..."; echo
        echo "nameserver $IPV6PRIDNS" >> $RESOLV_CONF
    fi

    IPV6SECDNS=`grep -m 1 "^IPV6SECDNS=" ${DEST_FILE} | cut -c 12-`
    if [ "x$IPV6SECDNS" != "x" ]; then
        echo -n "adding IPv6 secondary DNS $IPV6SECDNS..."; echo
        echo "nameserver $IPV6SECDNS" >> $RESOLV_CONF
    fi
fi

# end of set_v6lan.sh

