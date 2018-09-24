#!/bin/sh

source /tmp/network_config/iDRACnet.conf
iface=bond0
if [[ $VLAN_ENABLED == "yes"  ]]; then
   iface=bond0.$VLAN_ID
fi

echo "stopping osinet"
systemctl stop osinet
sleep 5
echo "interface: $iface"

echo "================= Broadcast response  ======================="
# broadcast packets to see if works
Bcast=`ifconfig ${iface} | grep inet | xargs | cut -d" " -f3| cut -d: -f2`
ping $Bcast -b -c 2
#ifconfig bond0 | grep inet | xargs | cut -d" " -f4

echo "================= arp response  ======================="
# Check if arp works
arping -b -U -s ${V4_ADDR} -c 3 -f -I ${iface} ${V4_GATEWAY}

echo "================= dhcp test ======================="
> /tmp/dhcp.out
PLD_Byte_21=`MemAccess -rb 0x14000021 | grep 0x14000021 | awk '{print $3}'`
AMEA_PRES_N=`printf "0x%02x" $(( 0x$CPLD_Byte_21 & 0x08 ))`

if [ "0x00" == "$AMEA_PRES_N" ] ; then
  /usr/bin/DedicatedNICControl.sh start
  ifconfig eth0 up
  udhcpc -i eth0 -t 5 -q -R -a -s /etc/debug/udhcpc_response.sh -vv
fi

i=0
for dev in $( ls /sys/class/net/ | grep ncsi | sort )
do
  # unblock the net2bmc flow
  /usr/bin/libncsitest 11 $i 0 1
  ifplugstatus -aq $dev
  if [[ $? -eq 2 ]]; then
  # found link if ret value is 2
    udhcpc -i $dev -q -R -t 5 -q -R -a -s /etc/debug/udhcpc_response.sh -vv
  else
    ifconfig $dev down
  fi
  i=`expr $i + 1`
done

systemctl start osinet
