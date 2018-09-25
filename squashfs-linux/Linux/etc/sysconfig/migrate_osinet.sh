#!/bin/bash

#	16438	NIC	21		- user setting
#	16439	IPv4	8
#	16440	IPv6	24
#	16442	NICStatic	2	- Not used
#	16443	IPv4Static	6	- user setting
#	16444	IPv6Static	6	- user setting
GRP_NIC="16438"
GRP_IPv4="16439"
GRP_IPv6="16440"
GRP_NICStatic="16442"
GRP_IPv4Static="16443"
GRP_IPv6Static="16444"

#	1:Enable
#	2:MACAddress
#	3:Selection
#	4:Failover
#	5:Speed
#	6:Autoneg
#	7:Duplex
#	8:MTU
#	9:DNSRegister
#	10:DNSRacName
#	11:DNSDomainFromDHCP
#	12:DNSDomainName
#	13:VLanEnable
#	14:VLanPriority
#	15:VLanID
#	16:DNSDomainNameFromDHCP
#	17:AutoDetect
#	18:DedicatedNICScanTime
#	19:SharedNICScanTime
#	20:AutoConfig
#	21:VLanSetting

# IFACE_ENABLED VLAN_ENABLED MAC VLAN_ID VLAN_PRIORITY ENET_AUTONEG_ENABLED ENET_SPEED ENET_DUPLEX MTU NET_MODE HOST_NAME DOMAIN_NAME DOMAIN_FROM_DHCP_ENABLED DDNS_ENABLED 
# AUTO=0 AUTO_DEDICATED=5 AUTO_SHARED=30 AUTO_NET_MODE=0
# /flash/data0/config/network_config/DHCPprov.conf
# DHCP_PROV
#AUTO_VLAN_SETTING=0

convert()
{
    shopt -s nocasematch
    local retval
    if [ -z $1 ]; then
	retval=0
    elif [[ "$1" == "yes" ]]; then
	retval=1
    elif [[ "$1" == "no" ]]; then
	retval=0
#    elif [[ $1 == *[[:digit:]]* ]]; then
#	retval=$1
    else
	retval=$1
    fi
    echo $retval
}

if [ -e /flash/data0/config/network_config/iDRACnet.conf ]; then
    source /flash/data0/config/network_config/iDRACnet.conf
    if [ -e /flash/data0/config/network_config/NICSwitch.conf ]; then
	source /flash/data0/config/network_config/NICSwitch.conf
    fi
    if [ -e /flash/data0/config/network_config/DHCPprov.conf ]; then
	source /flash/data0/config/network_config/DHCPprov.conf
    fi
    SEL=`expr $NET_MODE / 6 + 1`
    FAIL=`expr $NET_MODE % 6`
    lst=( `convert $IFACE_ENABLED`  `convert $MAC` $SEL $FAIL  `convert $ENET_SPEED`  `convert $ENET_AUTONEG_ENABLED`  `convert $ENET_DUPLEX`  `convert $MTU`  `convert $DDNS_ENABLED`  `convert $HOST_NAME`  `convert $DOMAIN_FROM_DHCP_ENABLED`  `convert $DOMAIN_NAME`  `convert $VLAN_ENABLED`  `convert $VLAN_PRIORITY`  `convert $VLAN_ID`  `convert $DOMAIN_FROM_DHCP_ENABLED`  $AUTO  $AUTO_DEDICATED  $AUTO_SHARED  `convert $DHCP_PROV`  `convert $VLAN_ENABLED` )
    typlst=( `grep $GRP_NIC /flash/data0/config/gencfgfld.txt | cut -d: -f2` )
    
#    printf "%s\n" "${typlst[@]}" 
    i=1
    for val in "${lst[@]}"
    do
	rdval=`readcfg -g $GRP_NIC -f $i | xargs |cut -d= -f2`
	if [[ "$rdval" != "$val" ]]; then
	echo  $i $val
	if [[ "${typlst[ `expr $i - 1` ]}" == "CFG_STRING" ]] && [[ ${lst[ `expr $i - 1` ]} == 0 ]] ; then
#	    echo $i empty
	    writecfg -g $GRP_NIC -e 1 -f $i -v""
	else
#	    echo $i ${lst[`expr $i - 1` ]}
	    writecfg -g $GRP_NIC -e 1 -f $i -v$val
	fi
	fi
	i=`expr $i + 1`
    done
# V4_ENABLED V4_DHCP_ENABLED V4_ADDR V4_NETMASK V4_GATEWAY V4_DNS_FROM_DHCP_ENABLED V4_DNS1 V4_DNS2
# readcfg -g 16439
#	1	Enable
#	2	DHCPEnable
#	3	Address
#	4	Netmask
#	5	Gateway
#	6	DNSFromDHCP
#	7	DNS1
#	8	DNS2
    i=1
    lst=( `convert $V4_ENABLED` `convert $V4_DHCP_ENABLED` `convert $V4_ADDR` `convert $V4_NETMASK` `convert $V4_GATEWAY` `convert $V4_DNS_FROM_DHCP_ENABLED` `convert $V4_DNS1` `convert $V4_DNS2` )
    for val in "${lst[@]}"
    do
	rdval=`readcfg -g $GRP_IPv4 -f $i | xargs |cut -d= -f2`
	if [[ "$rdval" != $val ]]; then
	    echo  $i $val
	    writecfg -g $GRP_IPv4 -e 1 -f $i -v$val
	fi
	i=`expr $i + 1`
    done

# V6_ENABLED V6_AUTOCONF_ENABLED V6_ADDR1 V6_PREFIX1 V6_ADDR_LINK V6_GATEWAY V6_DNS_FROM_DHCP_ENABLED V6_DNS1 V6_DNS2
# readcfg -g 16440
#	1	Enable
#	2	AutoConfig
#	3	DNSFromDHCP6
#	4	Address1
#	5	Gateway
#	6	LinkLocalAddress
#	7	PrefixLength
#	8	DNS1
#	9	DNS2
    i=1
    lst=( `convert $V6_ENABLED` `convert $V6_AUTOCONF_ENABLED` `convert $V6_DNS_FROM_DHCP_ENABLED` `convert $V6_ADDR1` `convert $V6_GATEWAY` `convert $V6_ADDR_LINK` `convert $V6_PREFIX1` `convert $V6_DNS1` `convert $V6_DNS2` )
    for val in "${lst[@]}"
    do
        rdval=`readcfg -g $GRP_IPv6 -f $i | xargs |cut -d= -f2`
        if [[ "$rdval" != $val ]]; then
	    echo  $i $val
	    writecfg -g $GRP_IPv6 -e 1 -f $i -v$val
	fi
	i=`expr $i + 1`
    done
fi
