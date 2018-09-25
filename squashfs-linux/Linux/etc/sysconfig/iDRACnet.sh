#!/bin/sh

export DEBUG=
dbecho ()
{
	if [ ! -z "${DEBUG}" ]; then
		echo "${1}"
	fi
}

enable_isc_dhcp() {
    cnt=0
    while [ ${cnt} -le 5 ] ; do
        sleep 2
        HWADDR=`/sbin/ifconfig ${IFNAME} | grep ${IFNAME} | awk '{print $5}'`
		CONFIG_DHCP_BOOL_OPT16_OPT17=`/avct/sbin/aim_config_get_bool dhcp_bool_opt60_opt43`
		CONFIG_DHCP_BOOL_OPT39=`/avct/sbin/aim_config_get_bool dhcp_bool_opt12`
		MANAGEMENT_CONTROLLER_ID=`/avct/sbin/aim_config_get_str aim_management_controller_id_str`

        if [ "${HWADDR}" != "00:00:00:00:00:00" ]; then
            rm -rf /tmp/dhclient_params
            echo "IFNAME=${IFNAME}" > /tmp/dhclient_params
			echo "HOSTNAME=${HOST_NAME}" >> /tmp/dhclient_params
			echo "DOMAINNAME=${DOMAIN_NAME}" >> /tmp/dhclient_params
			echo "CONFIG_DHCP_BOOL_OPT16_OPT17=${CONFIG_DHCP_BOOL_OPT16_OPT17}" >> /tmp/dhclient_params
			echo "CONFIG_DHCP_BOOL_OPT39=${CONFIG_DHCP_BOOL_OPT39}" >> /tmp/dhclient_params
			echo "MANAGEMENT_CONTROLLER_ID='${MANAGEMENT_CONTROLLER_ID}'" >> /tmp/dhclient_params
            DHCP_PID=$(ps -T | grep "dhclient_daemon" | grep -v "grep dhclient_daemon" | awk '{print $1}')
            if [ "${DHCP_PID}x" = "x" ] ; then
                touch /tmp/dhclient_need_start
            else  
				kill -SIGUSR1 ${DHCP_PID}    
            fi
            break
        fi
        cnt=`expr ${cnt} + 1`
    done
}

release_isc_dhcp() {
    cnt=0
    while [ ${cnt} -le 5 ] ; do
        sleep 2
        HWADDR=`/sbin/ifconfig ${IFNAME} | grep ${IFNAME} | awk '{print $5}'`

        if [ "${HWADDR}" != "00:00:00:00:00:00" ]; then
            rm -rf /tmp/dhclient_params
            echo "IFNAME=${IFNAME}" > /tmp/dhclient_params
            DHCP_PID=$(ps -T | grep "dhclient_daemon" | grep -v "grep dhclient_daemon" | awk '{print $1}')
            if [ "${DHCP_PID}x" != "x" ] ; then 
				kill -SIGUSR2 ${DHCP_PID}
            fi
            break
        fi
        cnt=`expr ${cnt} + 1`
    done
}

# TODO: See if we should be forcing the format of the link local address
config_lladdr()
{
	dbecho "configuring $1 Link-Local address"
	IFMAC=`ifconfig $1 | grep HWaddr | awk  '{ print $5 }'`
	dbecho "$1 MAC address is : $IFMAC"

	MAC1=`echo $IFMAC | cut -d: -f1`
	MAC2=`echo $IFMAC | cut -d: -f2`
	MAC3=`echo $IFMAC | cut -d: -f3`
	MAC4=`echo $IFMAC | cut -d: -f4`
	MAC5=`echo $IFMAC | cut -d: -f5`
	MAC6=`echo $IFMAC | cut -d: -f6`

	LLXOR2=0x0002
	MAC1=0x$MAC1
	let MAC1^=$LLXOR2
	MAC1=`printf "%x" $MAC1`

	LLADDR=FE80::$MAC1$MAC2:$MAC3"FF":"FE"$MAC4:$MAC5$MAC6
	dbecho "$1 Link-Local address is : $LLADDR"
	ip -6 addr add $LLADDR/64 dev $IFNAME

	return
}

check_ipv6_static_setting() {
    DO_STATIC_IPV6_ADDR="false"
    if [[ "${V6_ADDR1}" != "::" ]]; then
        DO_STATIC_IPV6_ADDR=`ifconfig | grep "${V6_ADDR1}/${V6_PREFIX1}"`
    fi

    if [[ "${V6_ADDR1}" != "${OLD_V6_ADDR1}" ]] || \
       [[ "${V6_PREFIX1}" != "${OLD_V6_PREFIX1}" ]] || \
       [[ "${DO_STATIC_IPV6_ADDR}" == "" ]]
    then
        dbecho "Removing old IPv6 global address #1 ${OLD_V6_ADDR1}/${OLD_V6_PREFIX1}..."
        ip -6 addr del ${OLD_V6_ADDR1}/${OLD_V6_PREFIX1} dev ${IFNAME}
        dbecho "Adding new IPv6 global address #1 ${V6_ADDR1}/${V6_PREFIX1}..."
        ip -6 addr add ${V6_ADDR1}/${V6_PREFIX1} dev ${IFNAME}
    fi

    DO_STATIC_IPV6_GATEWAY="false"
    if [[ "${V6_GATEWAY}" != "::" ]]; then
        DO_STATIC_IPV6_GATEWAY=`ip -6 route| grep "default via ${V6_GATEWAY} dev ${IFNAME}"`
    fi

    if [[ "${V6_GATEWAY}" != "${OLD_V6_GATEWAY}" ]] || \
       [[ "${DO_STATIC_IPV6_GATEWAY}" == "" ]]
    then
        dbecho "Removing old IPv6 default gateway ${OLD_V6_GATEWAY}..."
        ip -6 route del ::/0 via ${OLD_V6_GATEWAY} dev ${IFNAME} metric 1
        dbecho "Adding new IPv6 default gateway ${V6_GATEWAY}..."
        ip -6 route add ::/0 via ${V6_GATEWAY} dev ${IFNAME} metric 1
    fi
}

dbecho
dbecho "#########################################################"
dbecho "# NETWORK CONFIG SCRIPT START"
dbecho "#########################################################"
DEDICATE_MAC=eth0
NCSI_MAC=eth1
NCSI_MAC_DCS=eth2
ETHTOOL_IFNAME=eth0
CONF_DIR=/tmp/network_config
FLASH_DIR=/etc/sysconfig/network_config/
CONF_FILE=iDRACnet.conf
OLD_CONF_DIR=/tmp/network_config
OLD_CONF_FILE=iDRACnet.old
NIC_SELECT_FILE=NICSwitch.conf
DHCP_PROV_FILE=DHCPprov.conf
OLD_DHCP_PROV_FILE=DHCPprov.conf.old

RESOLV_CONF=/etc/resolv.conf
RESOLV_TEMP=/tmp/resolv.temp
ISC_TEXT="#--- Needed for dhclient (DO NOT REMOVE) ---"

SCRIPT_DIR=/etc/sysconfig/network_script

dcs_val=0x`MemAccess2 -rb -a 0x1400000A -c 1|grep -i 0x1400000A | cut -f3 -d ' '`
dcs_type=`echo $(( dcs_val & 8 ))` 
#########################################################
# Be kind to NFS installations
#########################################################
if grep nfsroot= /proc/cmdline > /dev/null; then
	# NOTE: S_3152_OSINET.sh grabs NFS configuration from /proc/cmdline
	dbecho "NFS detected, skipping network configuration..."
	exit 0
fi

#########################################################
# Read settings from last run
#########################################################
if [[ -e ${OLD_CONF_DIR}/${OLD_CONF_FILE} ]]; then
	dbecho "Reading old configuration..."
	source ${OLD_CONF_DIR}/${OLD_CONF_FILE}
else
    dbecho "First time run this script, set old config as IFACE_ENABLED=no"
    OLD_IFACE_ENABLED=no
fi

dbecho "OLD_IFACE_ENABLED=${OLD_IFACE_ENABLED}"
dbecho "OLD_MAC=${OLD_MAC}"
dbecho "OLD_NET_MODE=${OLD_NET_MODE}"
dbecho "OLD_ENET_AUTONEG_ENABLED=${OLD_ENET_AUTONEG_ENABLED}"
dbecho "OLD_ENET_SPEED=${OLD_ENET_SPEED}"
dbecho "OLD_ENET_DUPLEX=${OLD_ENET_DUPLEX}"
dbecho "OLD_MTU=${OLD_MTU}"
dbecho "OLD_HOST_NAME=${OLD_HOST_NAME}"
dbecho "OLD_DOMAIN_NAME=${OLD_DOMAIN_NAME}"
dbecho "OLD_VLAN_ENABLED=${OLD_VLAN_ENABLED}"
dbecho "OLD_VLAN_PORT=${OLD_VLAN_PORT}"
dbecho "OLD_VLAN_ID=${OLD_VLAN_ID}"
dbecho "OLD_VLAN_PRIORITY=${OLD_VLAN_PRIORITY}"
dbecho "OLD_V4_ENABLED=${OLD_V4_ENABLED}"
dbecho "OLD_V6_ENABLED=${OLD_V6_ENABLED}"
dbecho "OLD_DDNS_ENABLED=${OLD_DDNS_ENABLED}"
dbecho "OLD_DOMAIN_FROM_DHCP_ENABLED=${OLD_DOMAIN_FROM_DHCP_ENABLED}"
dbecho "OLD_V4_DHCP_ENABLED=${OLD_V4_DHCP_ENABLED}"
dbecho "OLD_V4_ADDR=${OLD_V4_ADDR}"
dbecho "OLD_V4_NETMASK=${OLD_V4_NETMASK}"
dbecho "OLD_V4_DNS_FROM_DHCP_ENABLED=${OLD_V4_DNS_FROM_DHCP_ENABLED}"
dbecho "OLD_V4_GATEWAY=${OLD_V4_GATEWAY}"
dbecho "OLD_V4_DNS1=${OLD_V4_DNS1}"
dbecho "OLD_V4_DNS2=${OLD_V4_DNS2}"
dbecho "OLD_V6_ADDR1=${OLD_V6_ADDR1}"
dbecho "OLD_V6_PREFIX1=${OLD_V6_PREFIX1}"
dbecho "OLD_V6_ADDR2=${OLD_V6_ADDR2}"
dbecho "OLD_V6_ADDR_LINK=${OLD_V6_ADDR_LINK}"
dbecho "OLD_V6_DNS1=${OLD_V6_DNS1}"
dbecho "OLD_V6_DNS2=${OLD_V6_DNS2}"
dbecho "OLD_V6_AUTOCONF_ENABLED=${OLD_V6_AUTOCONF_ENABLED}"
dbecho "OLD_V6_DNS_FROM_DHCP_ENABLED=${OLD_V6_DNS_FROM_DHCP_ENABLED}"
dbecho "OLD_V6_GATEWAY=${OLD_V6_GATEWAY}"
dbecho "OLD_IPV6_HEADER_STATIC_TRAFFIC_CLASS=${OLD_IPV6_HEADER_STATIC_TRAFFIC_CLASS}"
dbecho "OLD_IPV6_HEADER_STATIC_HOP_LIMIT=${OLD_IPV6_HEADER_STATIC_HOP_LIMIT}"
dbecho "OLD_IPV6_DHCPV6_STATIC_DUIDS0=${OLD_IPV6_DHCPV6_STATIC_DUIDS0}"
dbecho "OLD_IPV6_DHCPV6_DYNAMIC_DUIDS0=${OLD_IPV6_DHCPV6_DYNAMIC_DUIDS0}"
dbecho "OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL=${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}"
dbecho "OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS=${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}"
dbecho "OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS=${OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}"
dbecho "OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH=${OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH}"
dbecho "OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE=${OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}"
dbecho "OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS=${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}"
dbecho "OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS=${OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}"
dbecho "OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH=${OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH}"
dbecho "OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE=${OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}"

#########################################################
# Read current settings
#########################################################
# set network config files to default if they don't exist
if [ ! -e ${CONF_DIR}/${NIC_SELECT_FILE} ]; then
  dbecho "Uh oh, couldn't find auto nic settings."
  # disable autonic
  AUTO=0
  AUTO_DEDICATED=0
  AUTO_SHARED=0
  AUTO_NET_MODE=0
else
  dbecho "Reading autonic configuration..."
  source ${CONF_DIR}/${NIC_SELECT_FILE}

  dbecho "AUTODETECT=${AUTO}"
  dbecho "DEDICATED_UP_SCAN=${AUTO_DEDICATED}"
  dbecho "DEDICATED_DOWN_SCAN=${AUTO_SHARED}"
  dbecho "AUTO_NET_MODE=${AUTO_NET_MODE}"
fi

# set DHCP config default if file does not exist
if [ ! -e ${FLASH_DIR}/${DHCP_PROV_FILE} ]; then
  dbecho "Uh oh, couldn't find dhcp settings. copying from flash data"
  # set dhcp prov to disable
  CURRENT_DHCP_PROV=0
  PREVIOUS_DHCP_PROV=0
else
  dbecho "Reading dhcp configuration..."
  source ${FLASH_DIR}/${DHCP_PROV_FILE}
  CURRENT_DHCP_PROV=${DHCP_PROV}
  if [ ! -e ${CONF_DIR}/${OLD_DHCP_PROV_FILE} ]; then
      PREVIOUS_DHCP_PROV=0
  else
      DHCP_PROV=0
      # special case for Enable once after reset. do not restart udhcpc
      if [[ "${CURRENT_DHCP_PROV}" == "2" ]]; then
	  PREVIOUS_DHCP_PROV="2"
      else
      	source ${CONF_DIR}/${OLD_DHCP_PROV_FILE}
      	PREVIOUS_DHCP_PROV=${DHCP_PROV}
      fi
  fi
  dbecho "PREVIOUS_DHCP_PROV=${PREVIOUS_DHCP_PROV}"
  dbecho "CURRENT_DHCP_PROV=${CURRENT_DHCP_PROV}"
  
  if [[ "${CURRENT_DHCP_PROV}" != "${PREVIOUS_DHCP_PROV}" ]]
  then
	# overwrite old conf file 
        cp -f ${FLASH_DIR}/${DHCP_PROV_FILE} ${CONF_DIR}/${OLD_DHCP_PROV_FILE}
	if [[ "${CURRENT_DHCP_PROV}" == "1" ]] || \
	   [[ "${CURRENT_DHCP_PROV}" == "3" ]]
	then
		VENDOR_OPT_FIELD="\-O vendopts"
	fi
  fi
fi

if [ ! -e ${CONF_DIR}/${CONF_FILE} ]; then
	dbecho "Uh oh, couldn't find network settings."
	# exit with non-zero will cause osinet retry
	exit 1
fi

dbecho "Reading curent configuration..."
source ${CONF_DIR}/${CONF_FILE}

# Force using static ipv6 setting from FLASH_DIR instead of CONF_DIR
V6_ADDR1=`cat ${FLASH_DIR}/${CONF_FILE} | grep V6_ADDR1 | cut -d"=" -f2`
V6_PREFIX1=`cat ${FLASH_DIR}/${CONF_FILE} | grep V6_PREFIX1 | cut -d"=" -f2`
V6_GATEWAY=`cat ${FLASH_DIR}/${CONF_FILE} | grep V6_GATEWAY | cut -d"=" -f2`

if [[ "${AUTO}" == "1" ]]; then
  NET_MODE="${AUTO_NET_MODE}"
fi

# Adjust VLAN_ENABLED based on VLAN_PORT
if [[ "${VLAN_ENABLED}" == "yes" ]]; then
    if [[ ${VLAN_PORT} -eq 1 && ${NET_MODE} -ne 0 ]] || [[ ${VLAN_PORT} -eq 2 && ${NET_MODE} -eq 0 ]] ; then
        VLAN_ENABLED="no"
        echo "disabling VLAN till NET_MODE/VLAN_PORT is changed"
    fi
fi

dbecho "IFACE_ENABLED=${IFACE_ENABLED}"
dbecho "VLAN_ENABLED=${VLAN_ENABLED}"
dbecho "VLAN_PORT=${VLAN_PORT}"
dbecho "VLAN_ID=${VLAN_ID}"
dbecho "VLAN_PRIORITY=${VLAN_PRIORITY}"
dbecho "ENET_AUTONEG_ENABLED=${ENET_AUTONEG_ENABLED}"
dbecho "ENET_SPEED=${ENET_SPEED}"
dbecho "ENET_DUPLEX=${ENET_DUPLEX}"
dbecho "MTU=${MTU}"
dbecho "NET_MODE=${NET_MODE}"
dbecho "HOST_NAME=${HOST_NAME}"
dbecho "DOMAIN_NAME=${DOMAIN_NAME}"
dbecho "DOMAIN_FROM_DHCP_ENABLED=${DOMAIN_FROM_DHCP_ENABLED}"
dbecho "DDNS_ENABLED=${DDNS_ENABLED}"
dbecho "V4_ENABLED=${V4_ENABLED}"
dbecho "V4_DHCP_ENABLED=${V4_DHCP_ENABLED}"
dbecho "V4_ADDR=${V4_ADDR}"
dbecho "V4_NETMASK=${V4_NETMASK}"
dbecho "V4_GATEWAY=${V4_GATEWAY}"
dbecho "V4_DNS_FROM_DHCP_ENABLED=${V4_DNS_FROM_DHCP_ENABLED}"
dbecho "V4_DNS1=${V4_DNS1}"
dbecho "V4_DNS2=${V4_DNS2}"
dbecho "V6_ENABLED=${V6_ENABLED}"
dbecho "V6_AUTOCONF_ENABLED=${V6_AUTOCONF_ENABLED}"
dbecho "V6_ADDR1=${V6_ADDR1}"
dbecho "V6_PREFIX1=${V6_PREFIX1}"
dbecho "V6_ADDR_LINK=${V6_ADDR_LINK}"
dbecho "V6_GATEWAY=${V6_GATEWAY}"
dbecho "V6_DNS_FROM_DHCP_ENABLED=${V6_DNS_FROM_DHCP_ENABLED}"
dbecho "V6_DNS1=${V6_DNS1}"
dbecho "V6_DNS2=${V6_DNS2}"
dbecho "IPV6_HEADER_STATIC_TRAFFIC_CLASS=${IPV6_HEADER_STATIC_TRAFFIC_CLASS}"
dbecho "IPV6_HEADER_STATIC_HOP_LIMIT=${IPV6_HEADER_STATIC_HOP_LIMIT}"
dbecho "IPV6_DHCPV6_STATIC_DUIDS0=${IPV6_DHCPV6_STATIC_DUIDS0}"
dbecho "IPV6_DHCPV6_DYNAMIC_DUIDS0=${IPV6_DHCPV6_DYNAMIC_DUIDS0}"
dbecho "IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL=${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}"
dbecho "IPV6_STATIC_ROUTER_ONE_IP_ADDRESS=${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}"
dbecho "IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS=${IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}"
dbecho "IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH=${IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH}"
dbecho "IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE=${IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}"
dbecho "IPV6_STATIC_ROUTER_TWO_IP_ADDRESS=${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}"
dbecho "IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS=${IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}"
dbecho "IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH=${IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH}"
dbecho "IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE=${IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}"

######################################
# Store current settings for next run
######################################

if [[ ! -e ${OLD_CONF_DIR} ]]; then
	mkdir -p ${OLD_CONF_DIR}
fi

echo "OLD_IFACE_ENABLED=${IFACE_ENABLED}" > ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_MAC=${MAC}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_NET_MODE=${NET_MODE}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_ENET_AUTONEG_ENABLED=${ENET_AUTONEG_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_ENET_SPEED=${ENET_SPEED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_ENET_DUPLEX=${ENET_DUPLEX}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_MTU=${MTU}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_HOST_NAME=${HOST_NAME}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_DOMAIN_NAME=${DOMAIN_NAME}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_VLAN_ENABLED=${VLAN_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_VLAN_PORT=${VLAN_PORT}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_VLAN_ID=${VLAN_ID}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_VLAN_PRIORITY=${VLAN_PRIORITY}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V4_ENABLED=${V4_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_ENABLED=${V6_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_DDNS_ENABLED=${DDNS_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_DOMAIN_FROM_DHCP_ENABLED=${DOMAIN_FROM_DHCP_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}

echo "OLD_V4_DHCP_ENABLED=${V4_DHCP_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V4_ADDR=${V4_ADDR}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V4_NETMASK=${V4_NETMASK}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V4_DNS_FROM_DHCP_ENABLED=${V4_DNS_FROM_DHCP_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V4_GATEWAY=${V4_GATEWAY}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V4_DNS1=${V4_DNS1}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V4_DNS2=${V4_DNS2}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}

echo "OLD_V6_ADDR1=${V6_ADDR1}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_PREFIX1=${V6_PREFIX1}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_ADDR2=${V6_ADDR2}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_ADDR_LINK=${V6_ADDR_LINK}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_DNS1=${V6_DNS1}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_DNS2=${V6_DNS2}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_AUTOCONF_ENABLED=${V6_AUTOCONF_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_DNS_FROM_DHCP_ENABLED=${V6_DNS_FROM_DHCP_ENABLED}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_V6_GATEWAY=${V6_GATEWAY}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}

echo "OLD_IPV6_HEADER_STATIC_TRAFFIC_CLASS=${IPV6_HEADER_STATIC_TRAFFIC_CLASS}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_HEADER_STATIC_HOP_LIMIT=${IPV6_HEADER_STATIC_HOP_LIMIT}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_DHCPV6_STATIC_DUIDS0=${IPV6_DHCPV6_STATIC_DUIDS0}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_DHCPV6_DYNAMIC_DUIDS0=${IPV6_DHCPV6_DYNAMIC_DUIDS0}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL=${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS=${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS=${IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH=${IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE=${IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS=${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS=${IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH=${IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}
echo "OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE=${IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}

echo "OLD_FILE_COMPLETE=TRUE" >> ${OLD_CONF_DIR}/${OLD_CONF_FILE}

#############################
# Dedicated NIC power
#############################
if [[ ${NET_MODE} == 0 ]] || [[ -e /flash/data0/features/platform-modular ]] || [[ ${AUTO} == 1 ]] ; then
    echo "Enable Dedicated NIC"
    /usr/bin/DedicatedNICControl.sh start
    ifconfig eth0 up
else
    echo "Disable Dedicated NIC"
    ifplugd -i eth0 -k
    ifconfig eth0 down
    /usr/bin/DedicatedNICControl.sh stop
    ifconfig eth1 up
fi

#############################
# Calulate DDNS States
#############################

#========================================================
# IPv4
#========================================================

OLD_V4_DDNS_ENABLED=no
V4_DDNS_ENABLED=no
V4_DDNS_NEED_UNREGISTER=no
V4_DDNS_NEED_REGISTER=no

# Determine previous IPv4 DDNS registration status
if [[ "${OLD_DDNS_ENABLED}" == "yes" ]] && \
   [[ "${OLD_V4_ENABLED}" == "yes" ]]   && \
   [[ "${OLD_V4_DNS1}" != "0.0.0.0" ]]  && \
   [[ "${OLD_HOST_NAME}" != "" ]]       && \
   [[ "${OLD_DOMAIN_NAME}" != "" ]]     && \
   [[ "${OLD_V4_ADDR}" != "0.0.0.0" ]]
then
	OLD_V4_DDNS_ENABLED=yes
fi

# NOTE: DDNS_ENABLED implies the interface and family are also enabled as well as address, server, domain name and host name
if [[ "${DDNS_ENABLED}" == "yes" ]] && \
   [[ "${V4_ENABLED}" == "yes" ]]   && \
   [[ "${V4_DNS1}" != "0.0.0.0" ]]  && \
   [[ "${HOST_NAME}" != "" ]]       && \
   [[ "${DOMAIN_NAME}" != "" ]]     && \
   [[ "${V4_ADDR}" != "0.0.0.0" ]]
then
	V4_DDNS_ENABLED=yes
	
	# We need to register if anything is changed or if DDNS was previously disabled
	if [[ "${OLD_HOST_NAME}" != "${HOST_NAME}" ]]     || \
	   [[ "${OLD_DOMAIN_NAME}" != "${DOMAIN_NAME}" ]] || \
	   [[ "${OLD_V4_ADDR}" != "${V4_ADDR}" ]]         || \
	   [[ "${OLD_V4_DNS1}" != "${V4_DNS1}" ]]         || \
	   [[ "${OLD_V4_DDNS_ENABLED}" == "no" ]]
	then
		V4_DDNS_NEED_REGISTER=yes
	fi
fi

# We need to unregister if we previously registered and either we need to register or DDNS is now disabled
if [[ "${OLD_V4_DDNS_ENABLED}" == "yes" ]]; then
    if [[ "${V4_DDNS_NEED_REGISTER}" == "yes" ]] || \
       [[ "${V4_DDNS_ENABLED}" != "yes" ]]
    then
        V4_DDNS_NEED_UNREGISTER=yes
    fi
fi

dbecho "OLD_V4_DDNS_ENABLED=${OLD_V4_DDNS_ENABLED}"
dbecho "V4_DDNS_ENABLED=${V4_DDNS_ENABLED}"
dbecho "V4_DDNS_NEED_UNREGISTER=${V4_DDNS_NEED_UNREGISTER}"
dbecho "V4_DDNS_NEED_REGISTER=${V4_DDNS_NEED_REGISTER}"

if [[ -e /avct/sbin/fmchk ]]; then
	ddnsfebvalue=`/avct/sbin/fmchk ddns -d 1`
else
	ddnsfebvalue=1
fi
if [[ ${ddnsfebvalue} == 1 ]] || \
   [[ ${ddnsfebvalue} == -1 ]]
then
	if [[ "${V4_DDNS_NEED_UNREGISTER}" == "yes" ]]; then
		FQDN=${OLD_HOST_NAME}.${OLD_DOMAIN_NAME}
                dbecho "iDRACnet.sh unregister: OLD_V4_DNS1=${OLD_V4_DNS1}"
                dbecho "iDRACnet.sh unregister: V4_DNS1=${V4_DNS1}"
                echo "update delete ${FQDN} A" > /tmp/ddns
		echo "send" >> /tmp/ddns
		echo "update delete $(ip2dns ${OLD_V4_ADDR}) PTR" >> /tmp/ddns
		echo "send" >> /tmp/ddns
	
		if [ ! -z "${DEBUG}" ]; then
			echo "--- IPv4 DDNS unregister script ---"
			cat /tmp/ddns
			echo "-----------------------------------"
		fi
		/usr/bin/nsupdate -t 10 -v /tmp/ddns
	fi
fi


#########################################################
# Set up LAN Interface
#########################################################
# Get platform id.  240 = Bluefish, 242 = Sneetch, 255 = Eval board
MemTest PLATFORM_ID > /dev/null
PLATFORM_ID=$?

MemAccess PLATFORM_TYPE > /dev/null
PLATFORM_TYPE=$?

if [[ "$PLATFORM_TYPE" == "1" ]]; then
  dbecho "Modular platform.  Checking for new MAC...."
  CURRENT_MAC=`ifconfig | grep eth2.4003 | awk '{print $5}'`
  if [[ "${CURRENT_MAC}" != "${MAC}" ]]; then
    dbecho "Disabling all network interfaces and changing the MAC ${MAC}(iDRAC flex address)..."
    # detach slave interfaces form bond0 and update MAC address
    /etc/sysapps_script/network_dev_init.sh
    # Attach slave devices
    /etc/sysconfig/NICSelection.sh ${NET_MODE} ${AUTO}
    IFACE_CHANGED="yes"
# Update CMC routing table with new MAC address		
    arping -f -I eth2.4003 -c 50 169.254.31.40
  else
    dbecho "MAC address didn't change"
  fi
fi

if [[ "${IFACE_ENABLED}" == "no" ]] \
   || [[ "${NET_MODE}" != "${OLD_NET_MODE}" ]]
then
	dbecho "Disabling all network interfaces..."
	# remove slave devices
	ifconfig bond0 up
	ifconfig bond0 0.0.0.0
	if grep -Fq "Slave Interface" /proc/net/bonding/bond0; then
	    cat /proc/net/bonding/bond0 | grep "Slave Interface" | cut -d" " -f3 | xargs ifenslave -d bond0
	fi

	ifconfig bond0 down
	if [[ "$PLATFORM_TYPE" != "1" ]]; then	
		ifconfig ${DEDICATE_MAC} down
	else 
		ifconfig ${DEDICATE_MAC} up
		ifconfig ${DEDICATE_MAC} 0.0.0.0
	fi
	
	# For IPv6 disable stateless autoconfig on all interfaces by default
	if [[ -e /proc/sys/net/ipv6/conf/default/accept_ra ]]; then
		echo 1 > /proc/sys/net/ipv6/conf/default/accept_ra
	fi

	if [[ -e /proc/sys/net/ipv6/conf/default/accept_ra_pinfo ]]; then
		echo 0 > /proc/sys/net/ipv6/conf/default/accept_ra_pinfo
	fi
	if [[ -e /proc/sys/net/ipv6/conf/default/accept_ra_defrtr ]]; then
		echo 0 > /proc/sys/net/ipv6/conf/default/accept_ra_defrtr
	fi
	if [[ -e /proc/sys/net/ipv6/conf/default/accept_ra_rtr_pref ]]; then
		echo 0 > /proc/sys/net/ipv6/conf/default/accept_ra_rtr_pref
	fi
    
	
	# Kill any dynamic address daemons
	if [[ "${OLD_V4_DHCP_ENABLED}" == "yes" ]]; then
		killall udhcpc
	fi
	if [[ "${OLD_V6_AUTOCONF_ENABLED}" == "yes" ]]; then
		PID=$(pidof dhclient)
		if [[ "${PID}" != "" ]]; then
			release_isc_dhcp
			sleep 3
			killall dhclient
			sleep 3
		fi
    fi
fi

DEV_IFNAME="bond0"
if [[ "${IFACE_ENABLED}" == "no" ]]; then
    dbecho "Networking disabled"
    exit 0
else
    if [[ "${OLD_IFACE_ENABLED}" == "no" ]] || [[ "${NET_MODE}" != "${OLD_NET_MODE}" ]]; then        

        /etc/sysconfig/NICSelection.sh ${NET_MODE} ${AUTO}
	#########################################################
	# Check if fail to bring up network device
	#########################################################
	if [ $? != 0 ]; then
	    echo "Error - schedule to restart network device"
	    sed -i -e 's/OLD_NET_MODE=[0-9]/OLD_NET_MODE=N\/A/g' ${OLD_CONF_DIR}/${OLD_CONF_FILE}
	    exit 1
	fi
        # if bond0 is used, it needs to be up before ${DEDICATE_MAC} in order to 
        # hold link-local address
            ip -6 addr flush ${DEDICATE_MAC}
            ifconfig bond0 down
            ifconfig bond0 up
            ip -6 addr flush bond0
        
        IFACE_CHANGED="yes"
    fi
    if [[ "${V4_ENABLED}" == "yes" ]] && [[ "${OLD_V4_ENABLED}" == "no" ]]; then
        SET_IPV4_TO_NONE="yes"
    fi
fi

#########################################################
# Apply VLAN settings
#########################################################
if [[ "$PLATFORM_TYPE" != "1" ]] || [[ ${NET_MODE} != 0 ]] ; then
	if [[ "${VLAN_ENABLED}" == "yes" ]]; then
		IFNAME="${DEV_IFNAME}.${VLAN_ID}"

		if [[ "${OLD_VLAN_ENABLED}" != "yes" ]] || [[ "${VLAN_ID}" != "${OLD_VLAN_ID}" ]] || [[ "${IFACE_CHANGED}" == "yes" ]]; then
			if ! ifconfig -a | grep -q ${IFNAME} ; then
				dbecho "Creating VLAN interface ${IFNAME}..."
				vconfig add ${DEV_IFNAME} ${VLAN_ID}
			fi
	
			# Remove all unwanted VLAN interfaces
			for VLANIF in $(ifconfig -a | grep -e "${DEV_IFNAME}\." | grep -v "${IFNAME}" | cut -d" " -f1); do
				ifconfig ${DEV_IFNAME} down
				ifconfig ${VLANIF} down
				dbecho "Removing VLAN interface ${VLANIF}"
				vconfig rem ${VLANIF}
				ifconfig ${DEV_IFNAME} up
			done
	
			# Flush addresses from DEV_IFNAME
			ip -4 addr flush dev ${DEV_IFNAME}
			ip -6 addr flush dev ${DEV_IFNAME}
			ip -6 addr flush dev ${VLANIF}

			IFACE_CHANGED="yes"
		fi

		if [[ "${VLAN_PRIORITY}" != "${OLD_VLAN_PRIORITY}" ]] || [[ "${IFACE_CHANGED}" == "yes" ]]; then
			ifconfig ${DEV_IFNAME} down
			ifconfig ${VLANIF} down
			dbecho "Setting VLAN priority ${IFNAME}"
			for i in $(seq 0 7)
			do
				vconfig set_egress_map ${IFNAME} $i ${VLAN_PRIORITY}	
			done
			ifconfig ${DEV_IFNAME} up

			# Flush addresses from DEV_IFNAME
			ip -4 addr flush dev ${DEV_IFNAME}
			ip -6 addr flush dev ${DEV_IFNAME}
			ip -6 addr flush dev ${VLANIF}

			IFACE_CHANGED="yes"
		fi
	else
		IFNAME=${DEV_IFNAME}
		
		if [[ "${OLD_VLAN_ENABLED}" != "no" ]]; then
			# Remove all VLAN interfaces
			for VLANIF in $(ls -l /proc/net/vlan/ | grep ${DEV_IFNAME} | awk '{print $9}'); do
				ip -6 addr flush dev ${VLANIF}
				ifconfig ${DEV_IFNAME} down
				ifconfig ${VLANIF} down
				dbecho "Removing VLAN interface ${VLANIF}"
				vconfig rem ${VLANIF}
				ifconfig ${DEV_IFNAME} up
			done
		
			IFACE_CHANGED="yes"
		fi
	fi
else
	IFNAME=${DEV_IFNAME}

	if [[ "${VLAN_ENABLED}" != "${OLD_VLAN_ENABLED}" ]] || [[ "${VLAN_ID}" != "${OLD_VLAN_ID}" ]]; then
		ip -4 addr flush dev ${DEV_IFNAME}
		ip -6 addr flush dev ${DEV_IFNAME}

		IFACE_CHANGED="yes"
	fi
fi


#########################################################
# Determine if the interface has changed
#########################################################
if [[ "${IFACE_CHANGED}" == "yes" ]]; then
	# Mark everything as changed
	OLD_IFACE_ENABLED="no"
	OLD_MAC="N/A"
	OLD_NET_MODE="N/A"
	OLD_ENET_AUTONEG_ENABLED="N/A"
	OLD_ENET_SPEED="N/A"
	OLD_ENET_DUPLEX="N/A"
	OLD_MTU="N/A"
	OLD_HOST_NAME="N/A"
	OLD_DOMAIN_NAME="N/A"
	OLD_VLAN_ENABLED="N/A"
	OLD_VLAN_PORT="N/A"
	OLD_VLAN_ID="N/A"
	OLD_V4_ENABLED="N/A"
	OLD_V6_ENABLED="N/A"
	OLD_DDNS_ENABLED="N/A"
	OLD_DOMAIN_FROM_DHCP_ENABLED="N/A"
	
	OLD_V4_DHCP_ENABLED="N/A"
	OLD_V4_ADDR="N/A"
	OLD_V4_NETMASK="N/A"
	OLD_V4_DNS_FROM_DHCP_ENABLED="N/A"
	OLD_V4_GATEWAY="N/A"
	OLD_V4_DNS1="N/A"
	OLD_V4_DNS2="N/A"

	OLD_V6_ADDR1="N/A"
	OLD_V6_PREFIX1="N/A"
	OLD_V6_ADDR2="N/A"
	OLD_V6_ADDR_LINK="N/A"
	OLD_V6_DNS1="N/A"
	OLD_V6_DNS2="N/A"
	OLD_V6_AUTOCONF_ENABLED="N/A"
	OLD_V6_DNS_FROM_DHCP_ENABLED="N/A"
	OLD_V6_GATEWAY="N/A"
	OLD_IPV6_HEADER_STATIC_TRAFFIC_CLASS="N/A"
	OLD_IPV6_HEADER_STATIC_HOP_LIMIT="N/A"
	OLD_IPV6_DHCPV6_STATIC_DUIDS0="N/A"
	OLD_IPV6_DHCPV6_DYNAMIC_DUIDS0="N/A"
	OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL="N/A"
	OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS="N/A"
	OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS="N/A"
	OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH="N/A"
	OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE="N/A"
	OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS="N/A"
	OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS="N/A"
	OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH="N/A"
	OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE="N/A"
fi

if [[ "${SET_IPV4_TO_NONE}" == "yes" ]]; then
	# Mark everything as changed
	#OLD_IFACE_ENABLED="no"
	OLD_MAC="N/A"
	OLD_NET_MODE="N/A"
	OLD_ENET_AUTONEG_ENABLED="N/A"
	OLD_ENET_SPEED="N/A"
	OLD_ENET_DUPLEX="N/A"
	OLD_MTU="N/A"
	OLD_HOST_NAME="N/A"
	OLD_DOMAIN_NAME="N/A"
	OLD_VLAN_ENABLED="N/A"
	OLD_VLAN_PORT="N/A"
	OLD_VLAN_ID="N/A"
	OLD_V4_ENABLED="N/A"
	#OLD_V6_ENABLED="N/A"
	OLD_DDNS_ENABLED="N/A"
	OLD_DOMAIN_FROM_DHCP_ENABLED="N/A"
	
	OLD_V4_DHCP_ENABLED="N/A"
	OLD_V4_ADDR="N/A"
	OLD_V4_NETMASK="N/A"
	OLD_V4_DNS_FROM_DHCP_ENABLED="N/A"
	OLD_V4_GATEWAY="N/A"
	OLD_V4_DNS1="N/A"
	OLD_V4_DNS2="N/A"
fi

/etc/sysconfig/eth0_speed_setting.sh
if [[ $? != 0 ]]; then
        echo "error setting speed"
        exit 1
fi

#########################################################
# Apply common settings
#########################################################
# TODO: See if this is for mode 0 only as well
if [[ "${IFACE_ENABLED}" == "yes" ]] && [[ "${MTU}" != "${OLD_MTU}" ]]; then
	dbecho "Setting network MTU to ${MTU}..."
	ifconfig ${DEV_IFNAME} mtu ${MTU}

	#According to RFC2460, IPv6 requires that every link in the internet have an MTU of 1280 octets or greater.
	if [ ${MTU} -ge 1280 ] && [ ${OLD_MTU} -lt 1280 ]; then
        if [[ "${V6_ENABLED}" == "yes" ]] ; then
			PID=$(pidof dhclient)
			if [[ "${PID}" != "" ]]; then
				release_isc_dhcp
				sleep 1
				killall dhclient
				sleep 1
				PID=""
			fi
			dbecho "cleaning stale global address for ${IFNAME}."
			ip -6 address flush ${IFNAME};
			config_lladdr ${IFNAME}

			dbecho "Adding new IPv6 global address #1 ${V6_ADDR1}/${V6_PREFIX1}..."
			ip -6 addr add ${V6_ADDR1}/${V6_PREFIX1} dev ${IFNAME}
			dbecho "Adding new IPv6 default gateway ${V6_GATEWAY}..."
			ip -6 route add ::/0 via ${V6_GATEWAY} dev ${IFNAME} metric 1

			if  [[ "${V6_AUTOCONF_ENABLED}" == "yes" ]] ; then
				enable_isc_dhcp
				sleep 3
			    if  [[ ${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL} -gt 1 ]] ; then
				dbecho "Enabling stateless auto configuration..."
				if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra ]]; then
					echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
				fi
				if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_pinfo ]]; then
					echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_pinfo
				fi
				if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_defrtr ]]; then
					echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_defrtr
				fi
				if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_rtr_pref ]]; then
					echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_rtr_pref
				fi
                            fi
			#elif [[ "${V6_AUTOCONF_ENABLED}" == "no" ]]; then
			#	dbecho "Adding new IPv6 global address #1 ${V6_ADDR1}/${V6_PREFIX1}..."
			#	ip -6 addr add ${V6_ADDR1}/${V6_PREFIX1} dev ${IFNAME}
			#	dbecho "Adding new IPv6 default gateway ${V6_GATEWAY}..."
			#	ip -6 route add ::/0 via ${V6_GATEWAY} dev ${IFNAME} metric 1
			fi
        fi
	fi
fi

# NOTE: The host name may be blank
if [[ "${IFACE_ENABLED}" == "yes" ]] && [[ "${HOST_NAME}" != "${OLD_HOST_NAME}" ]]; then 
	dbecho "Setting host name to '${HOST_NAME}'..."
	hostname ${HOST_NAME}
	sed "4,\${a127.0.0.1	${HOST_NAME}
		d}" /etc/hosts > /tmp/hosts.$$
	mv /tmp/hosts.$$ /flash/data0/etc/hosts
	# Using FLASH location as /etc/hosts is a symbolic link
	# Modifications for DF510763
fi

# NOTE: OSINET startup script clears domainname so initial OLD_DOMAIN_NAME="" is always correct
if [[ "${IFACE_ENABLED}" == "yes" ]] && [[ "${DOMAIN_NAME}" != "${OLD_DOMAIN_NAME}" ]]; then
	dbecho "Setting DOMAIN_NAME to \"${DOMAIN_NAME}\"..."
	echo ${DOMAIN_NAME} > /proc/sys/kernel/domainname
fi

# Create a default resolv.conf if one doesn't exist
if [[ "${IFACE_ENABLED}" == "yes" ]]; then
    if [[ ! -e ${RESOLV_CONF} ]] || \
       [[ "${DOMAIN_NAME}" != "${OLD_DOMAIN_NAME}" ]] || \
       [[ "${V4_DNS1}" != "${OLD_V4_DNS1}" ]] || \
       [[ "${V4_DNS2}" != "${OLD_V4_DNS2}" ]] || \
       [[ "${V6_DNS1}" != "${OLD_V6_DNS1}" ]] || \
       [[ "${V6_DNS2}" != "${OLD_V6_DNS2}" ]]
    then
    	dbecho "Creating resolv.conf..."
        
    	# Create blank resolv.conf
    	echo -n "" > ${RESOLV_TEMP}
        
    	# Add search line to new resolv.conf
    	if [[ "${DOMAIN_NAME}" != "" ]]; then
    		echo "search ${DOMAIN_NAME}" >> ${RESOLV_TEMP}
    	fi
    	
    	if [[ "${V4_ENABLED}" == "yes" ]]; then
    		if [[ "${V4_DNS1}" != "0.0.0.0" ]]; then
    			echo "nameserver ${V4_DNS1}" >> ${RESOLV_TEMP}
    		fi
    	
    		if [[ "${V4_DNS2}" != "0.0.0.0" ]]; then
    			echo "nameserver ${V4_DNS2}" >> ${RESOLV_TEMP}
    		fi
    	fi

    	if [[ "${V6_ENABLED}" == "yes" ]]; then
    		if [[ "${V6_DNS1}" != "::" ]]; then
    			echo "nameserver ${V6_DNS1}" >> ${RESOLV_TEMP}
    		fi
    	
    		if [[ "${V6_DNS2}" != "::" ]]; then
    			echo "nameserver ${V6_DNS2}" >> ${RESOLV_TEMP}
    		fi
    	fi
    	
    	echo "nameserver ::" >> ${RESOLV_TEMP}
    	echo "${ISC_TEXT}" >> ${RESOLV_TEMP}
    	
    	# Write new resolv.cong
    	cat ${RESOLV_TEMP} > ${RESOLV_CONF}
    	rm ${RESOLV_TEMP}		
    fi
fi

#########################################################
# Set up IPv4 network
#########################################################
if [[ "${V4_ENABLED}" == "no" ]]; then
	dbecho "IPv4 disabled"
	ifconfig ${IFNAME} 0.0.0.0 
fi

UDHCPC_SCRIPT=/etc/sysconfig/network_script/udhcpc/osinet.script

#========================================================
# Handle DHCPv4
#========================================================
# NOTE: *** Very important we don't create a loop here where DHCP is started then calls avctifconfig which starts DHCP again ***
PID=$(pidof udhcpc)

UDHCPC_CHECK=`ps -T | grep "udhcpc -i" | grep -v "grep udhcpc -i"`
if [[ "${UDHCPC_CHECK}" == "" ]]; then
        PID=
fi

if [[ "${V4_DHCP_ENABLED}" == "yes" ]]; then
	#Need to start if DHCP enabled and not running
	#Need to restart if domain-from-dhcp, dns-from-dhcp, or interface have changed
	if [[ "${DOMAIN_FROM_DHCP_ENABLED}" != "${OLD_DOMAIN_FROM_DHCP_ENABLED}" ]] || \
	   [[ "${V4_DNS_FROM_DHCP_ENABLED}" != "${OLD_V4_DNS_FROM_DHCP_ENABLED}" ]] || \
	   [[ "${HOST_NAME}" != "${OLD_HOST_NAME}" ]] || \
	   [[ "${VENDOR_OPT_FIELD}" != "" ]] || \
   	   [[ "${IFACE_CHANGED}" == "yes" ]]
	then
		NEED_RESTART=yes
	else
		NEED_RESTART=no
	fi
	
	if [[ "${V4_ENABLED}" == "yes" ]] && [[ "${OLD_V4_ENABLED}" == "no" ]]
	then
		NEED_RESTART=yes
	fi
	
        if [ "${HOST_NAME}" != "" ]; then
        HOST_NAME_OPTION="-H ${HOST_NAME}"
        else
        HOST_NAME_OPTION=
        fi

	if [[ "${PID}" != "" ]] && [[ "${NEED_RESTART}" == "yes" ]]; then
		# Currently running for a different interface so kill it
		dbecho "Killing stale DHCPv4 client..."
		killall udhcpc
		PID=""
	fi
	
	if [[ "${V4_ENABLED}" == "yes" ]] && [[ "${PID}" == "" ]]; then
	    dbecho "IPv4 Enabled and Starting DHCPv4 client..."

            #OPT12:-H or -x
            CONFIG_DHCP_BOOL_OPT12=`/avct/sbin/aim_config_get_bool dhcp_bool_opt12`
            #OPT60:-V OPT43:-y
            CONFIG_DHCP_BOOL_OPT60_OPT43=`/avct/sbin/aim_config_get_bool dhcp_bool_opt60_opt43` 
            #RANDOM_BACK_OFF:-z //0xff not support, 0 disable, 1 enable
            CONFIG_DHCP_BOOL_RANDOM_BACK_OFF=`/avct/sbin/aim_config_get_bool dhcp_bool_random_back_off` 
            #PACKET_TIMEOUT:-T
            CONFIG_DHCP_INT_PACKET_TIMEOUT=`/avct/sbin/aim_config_get_int dhcp_int_packet_timeout`
            #RETRY_TIMEOUT:-m
            CONFIG_DHCP_INT_RETRY_TIMEOUT=`/avct/sbin/aim_config_get_int dhcp_int_retry_timeout`
            #WAIT_INTERVAL:-A
            CONFIG_DHCP_INT_WAIT_INTERVAL=`/avct/sbin/aim_config_get_int dhcp_int_wait_interval`

            MANAGEMENT_CONTROLLER_ID=`/avct/sbin/aim_config_get_str aim_management_controller_id_str`                       

            UDHCPC_OPT12=""
            UDHCPC_OPT60_OPT43=""
            if [[ "${CONFIG_DHCP_BOOL_OPT12}" == "true" ]] && [[ "${CONFIG_DHCP_BOOL_OPT60_OPT43}" == "true" ]]; then
                if [[ "${MANAGEMENT_CONTROLLER_ID}" != "" ]]; then
                    UDHCPC_OPT12="-x hostname:${MANAGEMENT_CONTROLLER_ID}"
                else
                    HWADDR=`/sbin/ifconfig ${IFNAME} | grep ${IFNAME} | awk '{print $5}' | sed -e 's/:/-/g' `
                    [ "${HWADDR}" != "" ] && UDHCPC_OPT12="-x hostname:DCMI${HWADDR}"
                fi
                UDHCPC_OPT60_OPT43="-V DCMI36465:1.5 -y 2.00"

            elif [[ "${CONFIG_DHCP_BOOL_OPT12}" != "true" ]] && [[ "${CONFIG_DHCP_BOOL_OPT60_OPT43}" == "true" ]]; then
                [ "${HOST_NAME}" != "" ] && UDHCPC_OPT12="-x hostname:${HOST_NAME}"
                UDHCPC_OPT60_OPT43="-V DCMI36465:1.5 -y 2.00"

            elif [[ "${CONFIG_DHCP_BOOL_OPT12}" == "true" ]] && [[ "${CONFIG_DHCP_BOOL_OPT60_OPT43}" != "true" ]]; then
                if [[ "${MANAGEMENT_CONTROLLER_ID}" != "" ]]; then
                    UDHCPC_OPT12="-x hostname:${MANAGEMENT_CONTROLLER_ID}"
                else
                    HWADDR=`/sbin/ifconfig ${IFNAME} | grep ${IFNAME} | awk '{print $5}' | sed -e 's/:/-/g' `
                    [ "${HWADDR}" != "" ] && UDHCPC_OPT12="-x hostname:DCMI${HWADDR}"
                fi
                UDHCPC_OPT60_OPT43="-V iDRAC"

            elif [[ "${CONFIG_DHCP_BOOL_OPT12}" != "true" ]] && [[ "${CONFIG_DHCP_BOOL_OPT60_OPT43}" != "true" ]]; then
                [ "${HOST_NAME}" != "" ] && UDHCPC_OPT12="-x hostname:${HOST_NAME}"
                UDHCPC_OPT60_OPT43="-V iDRAC"
            fi

            UDHCPC_OPT_RANDOM_BACK_OFF=""
            [ "${CONFIG_DHCP_BOOL_RANDOM_BACK_OFF}" == "false" ] && UDHCPC_OPT_RANDOM_BACK_OFF="-z 0"
            [ "${CONFIG_DHCP_BOOL_RANDOM_BACK_OFF}" == "true" ] && UDHCPC_OPT_RANDOM_BACK_OFF="-z 1"
            
            UDHCPC_OPT_PACKET_TIMEOUT=""
            [ "${CONFIG_DHCP_INT_PACKET_TIMEOUT}" != "" ] && UDHCPC_OPT_PACKET_TIMEOUT="-T ${CONFIG_DHCP_INT_PACKET_TIMEOUT}"

            UDHCPC_OPT_RETRY_TIMEOUT=""
            [ "${CONFIG_DHCP_INT_RETRY_TIMEOUT}" != "" ] && UDHCPC_OPT_RETRY_TIMEOUT="-m ${CONFIG_DHCP_INT_RETRY_TIMEOUT}"

            UDHCPC_OPT_WAIT_INTERVAL=""
            [ "${CONFIG_DHCP_INT_WAIT_INTERVAL}" != "" ] && UDHCPC_OPT_WAIT_INTERVAL="-A ${CONFIG_DHCP_INT_WAIT_INTERVAL}"

            UDHCPC_OPT_DCMI="${UDHCPC_OPT_RANDOM_BACK_OFF} ${UDHCPC_OPT60_OPT43} ${UDHCPC_OPT12} ${UDHCPC_OPT_PACKET_TIMEOUT} ${UDHCPC_OPT_RETRY_TIMEOUT} ${UDHCPC_OPT_WAIT_INTERVAL}"
            dbecho "UDHCPC_OPT_DCMI=${UDHCPC_OPT_DCMI}"
	    killall -9 udhcpc
	    #udhcpc -i ${IFNAME} ${HOST_NAME_OPTION} -V "iDRAC" "${VENDOR_OPT_FIELD}" -s ${UDHCPC_SCRIPT} &
	    udhcpc -i ${IFNAME} ${UDHCPC_OPT_DCMI} "${VENDOR_OPT_FIELD}" -s ${UDHCPC_SCRIPT} -O msstaticroutes -O staticroutes &
	fi
else
	if [[ "${PID}" != "" ]]; then
		dbecho "Killing DHCPv4 client..."
		kill ${PID}
	fi
fi
	
if [[ "${V4_ENABLED}" == "yes" ]]; then
	if [[ "${V4_ADDR}" != "${OLD_V4_ADDR}" ]] ||       \
	   [[ "${V4_NETMASK}" != "${OLD_V4_NETMASK}" ]] || \
	   [[ "${V4_GATEWAY}" != "${OLD_V4_GATEWAY}" ]]
	then
		dbecho "Setting IPv4 address to '${V4_ADDR}'"
		ifconfig ${IFNAME} ${V4_ADDR}

		if [[ "${V4_ADDR}" != "0.0.0.0" ]]; then
			dbecho "Setting IPv4 netmask to '${V4_NETMASK}'"	
			ifconfig ${IFNAME} netmask ${V4_NETMASK}
		fi

		if [[ "${V4_GATEWAY}" != "0.0.0.0" ]]; then
			dbecho "Setting IPv4 gateway to '${V4_GATEWAY}'"
			route add default gw ${V4_GATEWAY} ${IFNAME}
			arping -b -U -s ${V4_ADDR} -c 3 -f -I ${IFNAME} ${V4_GATEWAY}
		fi
	fi
fi

#========================================================
# Perform DDNS Update for IPv4
#========================================================

# Register with new server
if [[ -e /avct/sbin/fmchk ]]; then
	ddnsfebvalue=`/avct/sbin/fmchk ddns -d 1`
else
	ddnsfebvalue=1
fi
if [[ ${ddnsfebvalue} == 1 ]] || \
   [[ ${ddnsfebvalue} == -1 ]]
then
	if [[ "${V4_DDNS_NEED_REGISTER}" == "yes" ]]; then
		FQDN=${HOST_NAME}.${DOMAIN_NAME}
                dbecho "iDRACnet.sh register: OLD_V4_DNS1=${OLD_V4_DNS1}"
                dbecho "iDRACnet.sh register: V4_DNS1=${V4_DNS1}"
                echo "update add ${FQDN} 86400 A ${V4_ADDR}" > /tmp/ddns
		echo "send" >> /tmp/ddns
		echo "update add $(ip2dns ${V4_ADDR}) 86400 PTR ${FQDN}" >> /tmp/ddns
		echo "send" >> /tmp/ddns

		if [ ! -z "${DEBUG}" ]; then
			echo "--- IPv4 DDNS register script ---"
			cat /tmp/ddns
			echo "---------------------------------"
		fi
		/usr/bin/nsupdate -t 10 -v /tmp/ddns
	fi
fi


# To invoke D & H ipChange
if [[ "${V4_ENABLED}" == "yes" ]]; then
       if [[ "${V4_ADDR}" != "${OLD_V4_ADDR}" ]] ||       \
          [[ "${V4_NETMASK}" != "${OLD_V4_NETMASK}" ]] || \
          [[ "${V4_GATEWAY}" != "${OLD_V4_GATEWAY}" ]]
       then
           if [[ "${V4_ADDR}" != "0.0.0.0" ]]; then
                echo "bring up IP change notification (${OLD_V4_ADDR} -> ${V4_ADDR})"
		echo "V4_ADDR=${V4_ADDR}" > /tmp/idrac_ipaddress
                systemctl restart idrac_discovery_ipchange.service
		# do not change sequence
		# TODO: Manage not to run in parallel
                systemctl restart lompt.service
           fi
       fi
fi

#########################################################
# Set up IPv6 network
#########################################################
if [[ -e /tmp/IPV6_GRANT_LICENSE ]]; then
    source /tmp/IPV6_GRANT_LICENSE
    rm -f /tmp/IPV6_GRANT_LICENSE
    dbecho "Revert OLD_V6_ENABLED: ${OLD_V6_ENABLED}"
fi

if [[ "${V6_ENABLED}" != "yes" ]]; then
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
else
    sysctl -w net.ipv6.conf.all.disable_ipv6=0
    sysctl -w net.ipv6.conf.default.disable_ipv6=0
fi

# if IPv6 is enabled
if [[ "${V6_ENABLED}" != "yes" ]]; then
	dbecho "IPv6 disabled"	
	PID=$(pidof dhclient)
	if [[ "${PID}" != "" ]]; then
		release_isc_dhcp
		sleep 3
		killall dhclient
		sleep 3
	fi	
	ip -6 address flush ${IFNAME};
	exit 0;
fi

IPV6_MODULE="/usr/local/lib/modules/ipv6.ko"
DHCP6C_SCRIPT="/etc/sysconfig/network_script/dhclient-script"

#========================================================
# Handle Link Local address
#========================================================
if [[ "${V6_ENABLED}" == "yes" ]] && [[ "${OLD_V6_ENABLED}" != "yes" ]]; then
	if ! ifconfig ${IFNAME} | grep -q "Scope:Link"; then
		dbecho "Generating a link local address for ${IFNAME}."
		config_lladdr ${IFNAME}
	fi
fi

#========================================================
# Handle auto configuration
#========================================================
# if dhclient is enable, start it up

if [[ "${V6_ENABLED}" == "yes" ]]; then
    DISABLE_RA="false"
    RELEASE_DHCP="false"
    FLUSH_IP="false"
    ADD_STATIC_IP="false"
    ADD_STATIC_GATEWAY="false"
    ENABLE_RA="false"

    if [[ "${V6_ADDR1}" != "${OLD_V6_ADDR1}" ]] || \
       [[ "${V6_PREFIX1}" != "${OLD_V6_PREFIX1}" ]]; then

        if [[ "${V6_AUTOCONF_ENABLED}" != "yes" ]]; then
            DISABLE_RA="true"
            RELEASE_DHCP="true"
            FLUSH_IP="true"
            ADD_STATIC_IP="true"
            ADD_STATIC_GATEWAY="true"
        elif [[ "${V6_AUTOCONF_ENABLED}" == "yes" ]]; then
            if [[ ${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL} -lt 2 ]]; then
                DISABLE_RA="true"
                FLUSH_IP="true"
                ADD_STATIC_IP="true"
                ADD_STATIC_GATEWAY="true"
            elif [[ ${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL} -gt 1 ]]; then
                FLUSH_IP="true"
                ADD_STATIC_IP="true"
                ADD_STATIC_GATEWAY="true"
                ENABLE_RA="true"
            fi
        fi
    fi

    if [[ "${V6_ENABLED}" == "yes" ]] && [[ "${OLD_V6_ENABLED}" != "yes" ]]; then
        if [[ "${V6_AUTOCONF_ENABLED}" != "yes" ]]; then
            DISABLE_RA="true"
            RELEASE_DHCP="true"
            FLUSH_IP="true"
            ADD_STATIC_IP="true"
            ADD_STATIC_GATEWAY="true"

        elif [[ "${V6_AUTOCONF_ENABLED}" == "yes" ]]; then
            if [[ ${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL} -lt 2 ]]; then
                DISABLE_RA="true"
                FLUSH_IP="true"
                ADD_STATIC_IP="true"
                ADD_STATIC_GATEWAY="true"
            elif [[ ${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL} -gt 1 ]]; then
                FLUSH_IP="true"
                ADD_STATIC_IP="true"
                ADD_STATIC_GATEWAY="true"
                ENABLE_RA="true"
            fi
        fi
    elif [[ "${V6_ENABLED}" == "yes" ]] && [[ "${OLD_V6_ENABLED}" == "yes" ]]; then
        if [[ "${V6_AUTOCONF_ENABLED}" == "yes" ]] && [[ "${OLD_V6_AUTOCONF_ENABLED}" != "yes" ]]; then
            FLUSH_IP="true"
            ADD_STATIC_IP="true"
            ADD_STATIC_GATEWAY="true"
            if [[ ${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL} -gt 1 ]] ; then
                ENABLE_RA="true"
            fi

        elif [[ "${V6_AUTOCONF_ENABLED}" == "no" ]] && [[ "${OLD_V6_AUTOCONF_ENABLED}" != "no" ]]; then
            DISABLE_RA="true"
            RELEASE_DHCP="true"
            FLUSH_IP="true"
            ADD_STATIC_IP="true"
            ADD_STATIC_GATEWAY="true"

        elif [[ "${V6_AUTOCONF_ENABLED}" == "yes" ]] && [[ "${OLD_V6_AUTOCONF_ENABLED}" == "yes" ]]; then
            if [[ ${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL} -lt 2 ]] && \
               [[ "${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" != "0" ]] && \
               [[ "${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" != "1" ]]; then
                DISABLE_RA="true"
                FLUSH_IP="true"
                ADD_STATIC_IP="true"
                ADD_STATIC_GATEWAY="true"
            elif [[ ${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL} -gt 1 ]] && \
                 [[ "${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" != "2" ]] && \
                 [[ "${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" != "3" ]]; then
                FLUSH_IP="true"
                ADD_STATIC_IP="true"
                ADD_STATIC_GATEWAY="true"
                ENABLE_RA="true"
            fi
        fi
    fi

    if [[ "${DISABLE_RA}" == "true" ]]; then
        dbecho "Disabling stateless auto configuration..."
        if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra ]]; then	    
            echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
        fi
        if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_pinfo ]]; then
            echo 0 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_pinfo
        fi
        if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_defrtr ]]; then
            echo 0 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_defrtr
        fi
        if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_rtr_pref ]]; then
            echo 0 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_rtr_pref
        fi	
    fi

    if [[ "${RELEASE_DHCP}" == "true" ]]; then
        PID=$(pidof dhclient)
        if [[ "${PID}" != "" ]]; then
            release_isc_dhcp
            sleep 3
            killall dhclient
            sleep 3
        fi
    fi

    if [[ "${FLUSH_IP}" == "true" ]]; then
        # since there should only be 1 link-local and 1 non link-local
        # address, we can just flush out all address then add them back
        dbecho "Removing all non link-local address"
        ip -6 addr flush ${IFNAME}
        config_lladdr ${IFNAME}
    fi

    if [[ "${ADD_STATIC_IP}" == "true" ]]; then
        dbecho "Adding new IPv6 global address #1 ${V6_ADDR1}/${V6_PREFIX1}..."
        ip -6 addr add ${V6_ADDR1}/${V6_PREFIX1} dev ${IFNAME}
    fi

    if [[ "${ADD_STATIC_GATEWAY}" == "true" ]]; then
        dbecho "Adding new IPv6 default gateway ${V6_GATEWAY}..."
        ip -6 route add ::/0 via ${V6_GATEWAY} dev ${IFNAME} metric 1
    fi

    if [[ "${ENABLE_RA}" == "true" ]]; then
        dbecho "Enabling stateless auto configuration..."
        if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra ]]; then
                echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
        fi
        if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_pinfo ]]; then
                echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_pinfo
        fi
        if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_defrtr ]]; then
                echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_defrtr
        fi
        if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_rtr_pref ]]; then
                echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/accept_ra_rtr_pref
        fi
    fi
fi

if [[ "${V6_ENABLED}" == "yes" ]]; then
    check_ipv6_static_setting

    if [[ -e /proc/sys/net/ipv6/conf/$IFNAME/hop_limit ]]; then
        dbecho "Set hop limit: ${IPV6_HEADER_STATIC_HOP_LIMIT}..."
        echo ${IPV6_HEADER_STATIC_HOP_LIMIT} > /proc/sys/net/ipv6/conf/$IFNAME/hop_limit
    fi
fi    


if [[ "${V6_ENABLED}" == "yes" ]]; then

    REMOVE_STATIC_ROUTER="false"
    if [[ "${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" == "0" ]] || \
       [[ "${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" == "2" ]]; then

        if [[ "${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" != "0" ]] && \
           [[ "${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" != "2" ]]; then
            REMOVE_STATIC_ROUTER="true"
        fi
    fi
    
    if [[ "${REMOVE_STATIC_ROUTER}" == "true" ]]; then

        if [[ "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Removing old IPv6 static route one ${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}"
            ipstd -6 route del ${OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}/${OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH} via ${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} dev ${IFNAME}
        fi

        if [[ "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Removing old IPv6 static route two ${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}"
            ipstd -6 route del ${OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}/${OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH} via ${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} dev ${IFNAME}
        fi

        if [[ "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Removing old IPv6 static neighbor one ${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}... ${OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}"
            ipstd -6 neigh del ${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} lladdr ${OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS} dev ${IFNAME}
        fi

        if [[ "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Removing old IPv6 static neighbor two ${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}... ${OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}"
            ipstd -6 neigh del ${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} lladdr ${OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS} dev ${IFNAME}
        fi
    fi
fi

if [[ "${V6_ENABLED}" == "yes" ]]; then
    DO_STATIC_ROUTER_ONE="false"
    DO_STATIC_ROUTER_TWO="false"
    if [[ "${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" == "1" ]] || \
       [[ "${IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" == "3" ]]; then

        #if [[ "${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" == "0" ]] || \
        #   [[ "${OLD_IPV6_ROUTER_ADDRESS_CONFIGURATION_CONTROL}" == "2" ]]; then
        #    DO_STATIC_ROUTER_ONE="true"
        #    DO_STATIC_ROUTER_TWO="true"
        #fi

        DO_STATIC_ROUTER_ONE=`ip -6 route| grep "${IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}/${IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH} via ${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} dev ${IFNAME}"`
        DO_STATIC_ROUTER_TWO=`ip -6 route| grep "${IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}/${IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH} via ${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} dev ${IFNAME}"`
    fi

    if  [[ "${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" ]] || \
        [[ "${IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH}" != "${OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH}" ]] || \
        [[ "${IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}" != "${OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}" ]] || \
        [[ "${DO_STATIC_ROUTER_ONE}" == "" ]]
    then
        if [[ "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Removing old IPv6 static route one ${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}"
            ipstd -6 route del ${OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}/${OLD_IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH} via ${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} dev ${IFNAME}
        fi
        if [[ "${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Adding new IPv6 static route one ${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}"
            ipstd -6 route add ${IPV6_STATIC_ROUTER_ONE_PREFIX_VALUE}/${IPV6_STATIC_ROUTER_ONE_PREFIX_LENGTH} via ${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} dev ${IFNAME} metric 1
        fi	
    fi
    
    if  [[ "${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" ]] || \
        [[ "${IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH}" != "${OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH}" ]] || \
        [[ "${IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}" != "${OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}" ]] || \
        [[ "${DO_STATIC_ROUTER_TWO}" == "" ]]
    then
        if [[ "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Removing old IPv6 static route two ${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}"
            ipstd -6 route del ${OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}/${OLD_IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH} via ${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} dev ${IFNAME}
        fi
        if [[ "${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Adding new IPv6 static route two ${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}"
            ipstd -6 route add ${IPV6_STATIC_ROUTER_TWO_PREFIX_VALUE}/${IPV6_STATIC_ROUTER_TWO_PREFIX_LENGTH} via ${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} dev ${IFNAME} metric 1
        fi
    fi
    
    if  [[ "${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" ]] || \
        [[ "${DO_STATIC_ROUTER_ONE}" == "" ]]
    then
        if [[ "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Removing old IPv6 static neighbor one ${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}... ${OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}"
            ipstd -6 neigh del ${OLD_IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} lladdr ${OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS} dev ${IFNAME}
        fi
        
        if [[ "${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Adding new IPv6 static neighbor one ${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}...${IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}"
            ipstd -6 neigh replace ${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} lladdr ${IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS} dev ${IFNAME}
        fi
    else
        if [[ "${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS}" != "::" ]] && \
           [[ "${IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}" != "${OLD_IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}" ]]
        then
            dbecho "Replace IPv6 static neighbor one ${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} MAC to ${IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS}"
            ipstd -6 neigh replace ${IPV6_STATIC_ROUTER_ONE_IP_ADDRESS} lladdr ${IPV6_STATIC_ROUTER_ONE_MAC_ADDRESS} dev ${IFNAME}
        fi        
    fi
    
    if  [[ "${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" ]] || \
        [[ "${DO_STATIC_ROUTER_TWO}" == "" ]]
    then
        if [[ "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Removing old IPv6 static neighbor two ${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}... ${OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}"
            ipstd -6 neigh del ${OLD_IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} lladdr ${OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS} dev ${IFNAME}
        fi
        
        if [[ "${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "::" ]]
        then
            dbecho "Adding new IPv6 static neighbor two ${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}...${IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}"
            ipstd -6 neigh replace ${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} lladdr ${IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS} dev ${IFNAME}
        fi
    else        
        if [[ "${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "0000:0000:0000:0000:0000:0000:0000:0000" ]] && \
           [[ "${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS}" != "::" ]] && \
           [[ "${IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}" != "${OLD_IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}" ]]
        then
            dbecho "Replace IPv6 static neighbor two ${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} MAC to ${IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS}"
            ipstd -6 neigh replace ${IPV6_STATIC_ROUTER_TWO_IP_ADDRESS} lladdr ${IPV6_STATIC_ROUTER_TWO_MAC_ADDRESS} dev ${IFNAME}
        fi
    fi
fi

#========================================================
# Handle DHCPv6
#========================================================
if [[ "${V6_ENABLED}" != "yes" ]]; then
    exit 0;
fi

# NOTE: *** Very important we don't create a loop here where DHCP is started then calls av
PID=$(pidof dhclient)

UDHCPC6_CHECK=`ps -T | grep "dhclient -6" | grep -v "grep dhclient -6"`
if [[ "${UDHCPC6_CHECK}" == "" ]]; then
        PID=
fi

# DELL NETWORK REQUIREMENT: DELL doesn't support DNS only without autoconf
if [[ "${V6_AUTOCONF_ENABLED}" == "yes" ]]; then
	#Need to start if DHCP enabled and not running
	#Need to restart if domain-from-dhcp, dns-from-dhcp, ,domain name , hostname or interface (net mode + vlan enable + vlan id) have changed
	if [[ "${DOMAIN_FROM_DHCP_ENABLED}" != "${OLD_DOMAIN_FROM_DHCP_ENABLED}" ]] || \
	   [[ "${V6_DNS_FROM_DHCP_ENABLED}" != "${OLD_V6_DNS_FROM_DHCP_ENABLED}" ]] || \
	   [[ "${IFACE_CHANGED}" == "yes" ]] || \
	   [[ "${V6_AUTOCONF_ENABLED}" != "${OLD_V6_AUTOCONF_ENABLED}" ]] || \
	   [[ "${HOST_NAME}" != "${OLD_HOST_NAME}" ]] || \
	   [[ "${DOMAIN_NAME}" != "${OLD_DOMAIN_NAME}" ]] || \
           [[ "${V6_ADDR1}" != "${OLD_V6_ADDR1}" ]] || \
           [[ "${V6_PREFIX1}" != "${OLD_V6_PREFIX1}" ]] || \
           [[ "${FLUSH_IP}" == "true" ]]
	then
		NEED_RESTART=yes
	else
		NEED_RESTART=no
	fi
        DCMI_DHCPV6_ACTIVATE=`/avct/sbin/aim_config_get_bool dhcp_ipv6_restart`
        if [ "${DCMI_DHCPV6_ACTIVATE}"x == "true"x ]; then
                NEED_RESTART=yes
                /avct/sbin/aim_config_set_bool dhcp_ipv6_restart false false
        fi
	if [[ "${PID}" != "" ]] && [[ "${NEED_RESTART}" == "yes" ]]; then
		# Currently running for a different interface so kill it
		dbecho "Killing stale DHCPv6 client..."
		release_isc_dhcp
		sleep 3
		killall dhclient
		sleep 3
		PID=""

		# TODO: See if this sleep is necessary
		# sleep 3
	fi
	
	if [[ "${V6_ENABLED}" == "yes" ]] && [[ "${PID}" == "" ]]; then
		enable_isc_dhcp
		sleep 3
	fi
		
elif [[ "${PID}" != "" ]]; then
	dbecho "Killing DHCPv6 client..."
	release_isc_dhcp
	sleep 3
	killall dhclient
	sleep 3
fi

if [[ "${V6_ENABLED}" == "yes" ]]; then
    # release_isc_dhcp() will restart dhclient 
    # and flush all ipv6 address, 
    # so check ipv6 setting is necessary
    check_ipv6_static_setting
fi

dbecho "#########################################################"
dbecho "# NETWORK CONFIG SCRIPT END"
dbecho "#########################################################"
