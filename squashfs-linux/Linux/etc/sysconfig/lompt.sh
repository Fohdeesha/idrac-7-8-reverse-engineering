#!/bin/sh -x
# PTCapability_1=1
# AdminState_1=0
# OsIpAddress_1=0.0.0.0
# PTMode_1=1
# UsbNicIpAddress_1=169.254.0.1
# grep OS-BMC /flash/data0/config/gencfggrp.txt | cut -d: -f1

#sleep is to consolidate changes
sleep 10

OSBMC=16437
# clear all IPs assigned to ncsi
for dev in $(ls /sys/class/net/ | grep ncsi | sort);
do
    # Configuring/clearing an ip on an interface will bring it up,
    # so only clear those that are already up
    if [ `ifconfig | grep $dev | wc -l` -gt 0 ]; then
        ifconfig $dev 0.0.0.0;
    fi
done;

# exit if not enabled
readcfg -g ${OSBMC} > /tmp/osbmcpt.txt
source /tmp/osbmcpt.txt
if [ $AdminState_1 -ne 1 ] || [ $PTMode_1 -ne 0 ] ; then
    echo "lompt not fully configured"
    echo "AdminState=$AdminState_1 PTMode=$PTMode_1 OsIpAddress=${OsIpAddress_1}"
    i=0
    for dev in $( ls /sys/class/net/ | grep ncsi | sort )
    do
	# just disable passthrough
	# do not unblock. it will be taken care by osinet code
	/usr/bin/libncsitest 13 $i 0 100
        i=`expr $i + 1`
    done
  
    exit 0
fi

# wait for PT Capability if busy
while [[ ${PTCapability_1} -eq 2 ]]
do
    sleep 5
    readcfg -g ${OSBMC} > /tmp/osbmcpt.txt
    source /tmp/osbmcpt.txt
done

# exit if pt not capable
if [[ ${PTCapability_1} -eq 0 ]]; then
    echo "PT not capable"
    exit 0
fi

# Extract IP address
echo "Extracting IP address from bond0"
source /tmp/idrac_ipaddress
ipaddr=${V4_ADDR}
if [[ ${ipaddr} == "" ]] || [[ ${ipaddr} == "0.0.0.0" ]] ; then
    echo "IP address not ready"
    exit 0
fi

i=0
for dev in $( ls /sys/class/net/ | grep ncsi | sort )
do
    # sleep for '5' sec, before applying lom settings
    # sleep 5
	echo "configuring NDC to enable pass-through"
	/usr/bin/libncsitest 13 $i 1 100

	if grep -q eth0 /sys/class/net/bond0/bonding/slaves  \
		&& [[ "${OsIpAddress_1}" != "0.0.0.0" ]] ; then

	  ifplugstatus -aq $dev
	  if [[ $? -eq 2 ]]; then
	    # found link if ret value is 2
	    # nic selection is in Dedicated; osinet already blocks through net2bmc. We need not have to do again.
	    # echo "configuring NDC to Block net2bmc for $dev"
  	    # /usr/bin/libncsitest 11 $i 1 1
	
	    echo "configuring IP address on $dev"
            ifconfig $dev ${ipaddr} up
	    rip=`route -n | grep ncsi | xargs | cut -d" " -f1`
	    rnm=`route -n | grep ncsi | xargs | cut -d" " -f3`
	
	    echo "configuring route for ${OsIpAddress_1}"
	    route del -net ${rip} netmask ${rnm} dev $dev
	    route add -net ${OsIpAddress_1} netmask 255.255.255.255 dev $dev
	    arping -f -b -U -s ${ipaddr} -c 3 -f -I $dev ${OsIpAddress_1}
            break
	  else
	    # Bring down interface if no link available
	    # BITS247859. NCSI driver sends packet to first available nic, irrespective of cable presence
            ifconfig $dev down
          fi

	fi
    i=`expr $i + 1`
done

rm -f /tmp/osbmcpt.txt
