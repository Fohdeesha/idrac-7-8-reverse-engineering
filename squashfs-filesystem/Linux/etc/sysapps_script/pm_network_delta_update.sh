#!/bin/sh


update() {
	IFACE_ENABLED=`awk -F "=" '/IFACE_ENABLED/{print $2}' $1`
	VLAN_ENABLED=`awk -F "=" '/VLAN_ENABLED/{print $2}' $1`
	VLAN_ID=`awk -F "=" '/VLAN_ID/{print $2}' $1`
	VLAN_PRIORITY=`awk -F "=" '/VLAN_PRIORITY/{print $2}' $1`
	ENET_AUTONEG_ENABLED=`awk -F "=" '/ENET_AUTONEG_ENABLED/{print $2}' $1`
	ENET_SPEED=`awk -F "=" '/ENET_SPEED/{print $2}' $1`
	ENET_DUPLEX=`awk -F "=" '/ENET_DUPLEX/{print $2}' $1`
	MTU=`awk -F "=" '/MTU/{print $2}' $1`
	NET_MODE=`awk -F "=" '/NET_MODE/{print $2}' $1`
	HOST_NAME=`awk -F "=" '/HOST_NAME/{print $2}' $1`
	DOMAIN_NAME=`awk -F "=" '/DOMAIN_NAME/{print $2}' $1`
	DOMAIN_FROM_DHCP_ENABLED=`awk -F "=" '/DOMAIN_FROM_DHCP_ENABLED/{print $2}' $1`
	DDNS_ENABLED=`awk -F "=" '/DDNS_ENABLED/{print $2}' $1`
	V4_ENABLED=`awk -F "=" '/V4_ENABLED/{print $2}' $1`
	V4_DHCP_ENABLED=`awk -F "=" '/V4_DHCP_ENABLED/{print $2}' $1`
	V4_ADDR=`awk -F "=" '/V4_ADDR/{print $2}' $1`
	V4_NETMASK=`awk -F "=" '/V4_NETMASK/{print $2}' $1`
	V4_GATEWAY=`awk -F "=" '/V4_GATEWAY/{print $2}' $1`
	V4_DNS_FROM_DHCP_ENABLED=`awk -F "=" '/V4_DNS_FROM_DHCP_ENABLED/{print $2}' $1`
	V4_DNS1=`awk -F "=" '/V4_DNS1/{print $2}' $1`
	V4_DNS2=`awk -F "=" '/V4_DNS2/{print $2}' $1`
	V6_ENABLED=`awk -F "=" '/V6_ENABLED/{print $2}' $1`
	V6_AUTOCONF_ENABLED=`awk -F "=" '/V6_AUTOCONF_ENABLED/{print $2}' $1`
	V6_ADDR1=`awk -F "=" '/V6_ADDR1/{print $2}' $1`
	V6_PREFIX1=`awk -F "=" '/V6_PREFIX1/{print $2}' $1`
	V6_ADDR_LINK=`awk -F "=" '/V6_ADDR_LINK/{print $2}' $1`
	V6_GATEWAY=`awk -F "=" '/V6_GATEWAY/{print $2}' $1`
	V6_DNS_FROM_DHCP_ENABLED=`awk -F "=" '/V6_DNS_FROM_DHCP_ENABLED/{print $2}' $1`
	V6_DNS1=`awk -F "=" '/V6_DNS1/{print $2}' $1`
	V6_DNS2=`awk -F "=" '/V6_DNS2/{print $2}' $1`


	IFACE_ENABLED_NEW=`awk -F "=" '/IFACE_ENABLED/{print $2}' $2`
	VLAN_ENABLED_NEW=`awk -F "=" '/VLAN_ENABLED/{print $2}' $2`
	VLAN_ID_NEW=`awk -F "=" '/VLAN_ID/{print $2}' $2`
	VLAN_PRIORITY_NEW=`awk -F "=" '/VLAN_PRIORITY/{print $2}' $2`
	ENET_AUTONEG_ENABLED_NEW=`awk -F "=" '/ENET_AUTONEG_ENABLED/{print $2}' $2`
	ENET_SPEED_NEW=`awk -F "=" '/ENET_SPEED/{print $2}' $2`
	ENET_DUPLEX_NEW=`awk -F "=" '/ENET_DUPLEX/{print $2}' $2`
	MTU_NEW=`awk -F "=" '/MTU/{print $2}' $2`
	NET_MODE_NEW=`awk -F "=" '/NET_MODE/{print $2}' $2`
	HOST_NAME_NEW=`awk -F "=" '/HOST_NAME/{print $2}' $2`
	DOMAIN_NAME_NEW=`awk -F "=" '/DOMAIN_NAME/{print $2}' $2`
	DOMAIN_FROM_DHCP_ENABLED_NEW=`awk -F "=" '/DOMAIN_FROM_DHCP_ENABLED/{print $2}' $2`
	DDNS_ENABLED_NEW=`awk -F "=" '/DDNS_ENABLED/{print $2}' $2`
	V4_ENABLED_NEW=`awk -F "=" '/V4_ENABLED/{print $2}' $2`
	V4_DHCP_ENABLED_NEW=`awk -F "=" '/V4_DHCP_ENABLED/{print $2}' $2`
	V4_ADDR_NEW=`awk -F "=" '/V4_ADDR/{print $2}' $2`
	V4_NETMASK_NEW=`awk -F "=" '/V4_NETMASK/{print $2}' $2`
	V4_GATEWAY_NEW=`awk -F "=" '/V4_GATEWAY/{print $2}' $2`
	V4_DNS_FROM_DHCP_ENABLED_NEW=`awk -F "=" '/V4_DNS_FROM_DHCP_ENABLED/{print $2}' $2`
	V4_DNS1_NEW=`awk -F "=" '/V4_DNS1/{print $2}' $2`
	V4_DNS2_NEW=`awk -F "=" '/V4_DNS2/{print $2}' $2`
	V6_ENABLED_NEW=`awk -F "=" '/V6_ENABLED/{print $2}' $2`
	V6_AUTOCONF_ENABLED_NEW=`awk -F "=" '/V6_AUTOCONF_ENABLED/{print $2}' $2`
	V6_ADDR1_NEW=`awk -F "=" '/V6_ADDR1/{print $2}' $2`
	V6_PREFIX1_NEW=`awk -F "=" '/V6_PREFIX1/{print $2}' $2`
	V6_ADDR_LINK_NEW=`awk -F "=" '/V6_ADDR_LINK/{print $2}' $2`
	V6_GATEWAY_NEW=`awk -F "=" '/V6_GATEWAY/{print $2}' $2`
	V6_DNS_FROM_DHCP_ENABLED_NEW=`awk -F "=" '/V6_DNS_FROM_DHCP_ENABLED/{print $2}' $2`
	V6_DNS1_NEW=`awk -F "=" '/V6_DNS1/{print $2}' $2`
	V6_DNS2_NEW=`awk -F "=" '/V6_DNS2/{print $2}' $2`

	if [ $IFACE_ENABLED_NEW ] ; then
		sed -i /IFACE_ENABLED/s/"${IFACE_ENABLED}"/"${IFACE_ENABLED_NEW}"/ $1
	fi
	if [ $VLAN_ENABLED_NEW ] ; then
        	sed -i /VLAN_ENABLED/s/"${VLAN_ENABLED}"/"${VLAN_ENABLED_NEW}"/ $1
	fi
	if [ $VLAN_ID_NEW ] ; then
	        sed -i /VLAN_ID/s/"${VLAN_ID}"/"${VLAN_ID_NEW}"/ $1
	fi
	if [ $VLAN_PRIORITY_NEW ] ; then
        	sed -i /VLAN_PRIORITY/s/"${VLAN_PRIORITY}"/"${VLAN_PRIORITY_NEW}"/ $1
	fi
	if [ $ENET_AUTONEG_ENABLED_NEW ] ; then
	        sed -i /ENET_AUTONEG_ENABLED/s/"${ENET_AUTONEG_ENABLED}"/"${ENET_AUTONEG_ENABLED_NEW}"/ $1
	fi
	if [ $ENET_SPEED_NEW ] ; then
	        sed -i /VLAN_ENABLED/s/"${ENET_SPEED}"/"${ENET_SPEED_NEW}"/ $1
	fi
	if [ $ENET_DUPLEX_NEW ] ; then
	        sed -i /ENET_DUPLEX/s/"${ENET_DUPLEX}"/"${ENET_DUPLEX_NEW}"/ $1
	fi
	if [ $MTU_NEW ] ; then
	        sed -i /MTU/s/"${MTU}"/"${MTU_NEW}"/ $1
	fi
	if [ $NET_MODE_NEW ] ; then
        	sed -i /NET_MODE/s/"${NET_MODE}"/"${NET_MODE_NEW}"/ $1
	fi
	if [ $HOST_NAME_NEW ] ; then
        	sed -i /HOST_NAME/s/"${HOST_NAME}"/"${HOST_NAME_NEW}"/ $1
	fi
	if [ $DOMAIN_NAME_NEW ] ; then
	        sed -i /DOMAIN_NAME/s/"${DOMAIN_NAME}"/"${DOMAIN_NAME_NEW}"/ $1
	fi
	if [ $DOMAIN_FROM_DHCP_ENABLED_NEW ] ; then
        	sed -i /DOMAIN_FROM_DHCP_ENABLED/s/"${DOMAIN_FROM_DHCP_ENABLED}"/"${DOMAIN_FROM_DHCP_ENABLED_NEW}"/ $1
	fi
	if [ $DDNS_ENABLED_NEW ] ; then
        	sed -i /DDNS_ENABLED/s/"${DDNS_ENABLED}"/"${DDNS_ENABLED_NEW}"/ $1
	fi
	if [ $V4_ENABLED_NEW ] ; then
	        sed -i /V4_ENABLED/s/"${V4_ENABLED}"/"${V4_ENABLED_NEW}"/ $1
	fi
	if [ $V4_DHCP_ENABLED_NEW ] ; then
	        sed -i /V4_DHCP_ENABLED/s/"${V4_DHCP_ENABLED}"/"${V4_DHCP_ENABLED_NEW}"/ $1
	fi
	if [ $V4_ADDR_NEW ] ; then
	        sed -i /V4_ADDR/s/"${V4_ADDR}"/"${V4_ADDR_NEW}"/ $1
	fi
	if [ $V4_NETMASK_NEW ] ; then
	        sed -i /V4_NETMASK/s/"${V4_NETMASK}"/"${V4_NETMASK_NEW}"/ $1
	fi
	if [ $V4_GATEWAY_NEW ] ; then
	        sed -i /V4_GATEWAY/s/"${V4_GATEWAY}"/"${V4_GATEWAY_NEW}"/ $1
	fi
	if [ $V4_DNS_FROM_DHCP_ENABLED_NEW ] ; then
	        sed -i /V4_DNS_FROM_DHCP_ENABLED/s/"${V4_DNS_FROM_DHCP_ENABLED}"/"${V4_DNS_FROM_DHCP_ENABLED_NEW}"/ $1
	fi
	if [ $V4_DNS1_NEW ] ; then
	        sed -i /V4_DNS1/s/"${V4_DNS1}"/"${V4_DNS1_NEW}"/ $1
	fi
	if [ $V4_DNS2_NEW ] ; then
	        sed -i /V4_DNS2/s/"${V4_DNS2}"/"${V4_DNS2_NEW}"/ $1
	fi
	if [ $V6_ENABLED_NEW ] ; then
	        sed -i /V6_ENABLED/s/"${V6_ENABLED}"/"${V6_ENABLED_NEW}"/ $1
	fi
	if [ $V6_AUTOCONF_ENABLED_NEW ] ; then
	        sed -i /V6_AUTOCONF_ENABLED/s/"${V6_AUTOCONF_ENABLED}"/"${V6_AUTOCONF_ENABLED_NEW}"/ $1
	fi
	if [ $V6_ADDR1_NEW ] ; then
	        sed -i /V6_ADDR1/s/"${V6_ADDR1}"/"${V6_ADDR1_NEW}"/ $1
	fi
	if [ $V6_PREFIX1_NEW ] ; then
	        sed -i /V6_PREFIX1/s/"${V6_PREFIX1}"/"${V6_PREFIX1_NEW}"/ $1
	fi
	if [ $V6_ADDR_LINK_NEW ] ; then
	        sed -i /V6_ADDR_LINK/s/"${V6_ADDR_LINK}"/"${V6_ADDR_LINK_NEW}"/ $1
	fi
	if [ $V6_GATEWAY_NEW ] ; then
	        sed -i /V6_GATEWAY/s/"${V6_GATEWAY}"/"${V6_GATEWAY_NEW}"/ $1
	fi
	if [ $V6_DNS_FROM_DHCP_ENABLED_NEW ] ; then
	        sed -i /V6_DNS_FROM_DHCP_ENABLED/s/"${V6_DNS_FROM_DHCP_ENABLED}"/"${V6_DNS_FROM_DHCP_ENABLED_NEW}"/ $1
	fi
	if [ $V6_DNS1_NEW ] ; then
        	sed -i /V6_DNS1/s/"${V6_DNS1}"/"${V6_DNS1_NEW}"/ $1
	fi
	if [ $V6_DNS2_NEW ] ; then
        	sed -i /V6_DNS2/s/"${V6_DNS2}"/"${V6_DNS2_NEW}"/ $1
	fi
}


update $1 $2
