#!/bin/sh
# Start the OSINET Interface component

exec > /var/log/osinet.log 2>&1
set -x

nfsdefaults()
{
    if grep -q ip= /proc/cmdline; then
        kernel_cli_ip=$(cat /proc/cmdline | sed 's/.*ip=\([[:alnum:]:.]\+\).*/\1/')
        V4_ADDR=$(echo $kernel_cli_ip | cut -d: -f1)
        nfs_server_ip=$(echo $kernel_cli_ip | cut -d: -f2)
        V4_GATEWAY=$(echo $kernel_cli_ip | cut -d: -f3)
        V4_NETMASK=$(echo $kernel_cli_ip | cut -d: -f4)
        interface=$(echo $kernel_cli_ip | cut -d: -f6)
        sed -i -e "/^V4_ADDR=/s/=.*/=$V4_ADDR/; \
                /^V4_GATEWAY=/s/=.*/=$V4_GATEWAY/; \
                /^V4_NETMASK=/s/=.*/=$V4_NETMASK/" \
                $1
    fi
}

start() {
    # Get platform id.  240 = Bluefish, 242 = Sneetch, 255 = Eval board
	PLATFORM_ID=$(cat /flash/data0/features/memaccess-platform-id)
	PLATFORM_TYPE=$(cat /flash/data0/features/memaccess-platform-type)
    PLATFORM_TYPE_MONOLITHIC=0
    PLATFORM_TYPE_MODULAR=1

	# Remove bonding modules for eval boards (loaded in systemd_modules_ipmi.sh)
	if  [[ "$PLATFORM_ID" = "255" ]]; then
        rmmod bonding
	fi

	# clear temporary network configuration file
    mkdir -p /var/run/network_config
    ln -s /var/run/network_config /tmp/network_config

    # set up rewriteable
    cp -a /etc/sysconfig/network_script_default/* /etc/sysconfig/network_script/.

	# Clear resolv.conf
	> /etc/resolv.conf

        IDRACNET_DEFAULT=/flash/data0/config/network_config/iDRACnet.default
	if [ ! -e ${IDRACNET_DEFAULT} ]; then
		mkdir -p /flash/data0/config/network_config/
		systemname=`/etc/default/ipmi/getsysid`
                cp /flash/pd0/network_config/${systemname}/iDRACnet.default ${IDRACNET_DEFAULT}

		if [ $PLATFORM_TYPE -eq $PLATFORM_TYPE_MODULAR ]; then
	                if [ ! -e ${IDRACNET_DEFAULT} ]; then
                            cp /flash/pd0/network_config/Mojo/iDRACnet.default ${IDRACNET_DEFAULT}
                        fi

			MemAccess BLADE_ID > /dev/null
			BLADEID=$?
			CPLD_Byte_40=`MemAccess -rb 0x14000040 | grep 0x14000040 | awk '{print $3}'`
			SLED_PRES_N=`printf "0x%02x" $(( 0x$CPLD_Byte_40 & 0x02 ))`

			if [ "0x00" == "$SLED_PRES_N" ] ; then
				echo "SLED NOT PRESENT"
				Is_quarter_height_blade=0
			else
				   echo "SLED Present"
				Is_quarter_height_blade=1
			fi
			if [ $Is_quarter_height_blade -eq 1 ]; then
				MemAccess DEF_IP > /dev/null
				BLADEID=$?
			fi
			IP_ORIG=`awk -F "=" '/V4_ADDR/{print $2}' ${IDRACNET_DEFAULT}`
			IP_BASE1=`awk -F "=" '/V4_ADDR/{print $2}' ${IDRACNET_DEFAULT}  | awk -F "." '{print $1"."$2"."$3"."}'`
			IP_BASE2=`awk -F "=" '/V4_ADDR/{print $2}' ${IDRACNET_DEFAULT}  | awk -F "." '{print $4}'`
			IP_NEW=`echo ${IP_BASE1}$(($BLADEID+$IP_BASE2))`
			sed -i /V4_ADDR/s/"${IP_ORIG}"/"${IP_NEW}"/ ${IDRACNET_DEFAULT}
                else
	                if [ ! -e ${IDRACNET_DEFAULT} ]; then
                            cp /flash/pd0/network_config/Orca/iDRACnet.default ${IDRACNET_DEFAULT}
                        fi
		fi

                # if the service tag is available, then append it to the default idrac hostname
                HOST_NAME_ORIG=`awk -F "=" '/HOST_NAME/{print $2}' ${IDRACNET_DEFAULT}`
                if [[ "${HOST_NAME_ORIG}" == "idrac" ]] && [[ -e /tmp/sysinfo_nodeid ]]; then
                    SERVICE_TAG=`cat /tmp/sysinfo_nodeid`
                    HOST_NAME="${HOST_NAME_ORIG}-${SERVICE_TAG}"
                    sed -i /HOST_NAME/s/"${HOST_NAME_ORIG}"/"${HOST_NAME}"/ ${IDRACNET_DEFAULT}
                fi

		# apply the PM settings
		if [ -f /flash/data0/persmod/iDRACnet.delta ] ;  then
		    source /etc/sysapps_script/pm_network_delta_update.sh ${IDRACNET_DEFAULT} /flash/data0/persmod/iDRACnet.delta
		fi

		# setflag that we are in default
		# TODO: Explain story here
		writecfg -g 1103 -e 1 -f 1 -v1
	fi

        IDRACNET_CONF=/flash/data0/config/network_config/iDRACnet.conf
	if [ ! -e ${IDRACNET_CONF} ]; then
                cp ${IDRACNET_DEFAULT} ${IDRACNET_CONF}
	fi

        IDRACNET_CONF=/flash/data0/config/network_config/iDRACnet.conf
	if [ ! -e ${IDRACNET_CONF} ]; then
                cp ${IDRACNET_DEFAULT} ${IDRACNET_CONF}
	fi

	# check for NFS defaults
        nfsdefaults ${IDRACNET_CONF}

	return 0
}

case "$1" in
start)
	start
	;;
reset)
	;;
*)
	echo $"Usage: $0 {start|reset}"
	exit 1
esac

exit 0

