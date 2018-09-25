#!/bin/sh
#
# /etc/init.d/avahi-daemon start
# arg1 - start, stop, restart

#set -e

if grep -c usb0 /proc/net/dev ; then
    ifconfig usb0 down
    rmmod g_ether
fi

# This sleep is for DM to update cfglib
sleep 2

# PTCapability_1=1
# AdminState_1=0
# OsIpAddress_1=0.0.0.0
# PTMode_1=1
# UsbNicIpAddress_1=169.254.0.1
# grep OS-BMC /flash/data0/config/gencfggrp.txt | cut -d: -f1
OSBMC=16437
readcfg -g ${OSBMC} > /tmp/osbmcpt.txt
sync
source /tmp/osbmcpt.txt
rm -f /tmp/osbmcpt.txt
# send command only if in LOM PT
if [ $AdminState_1 -ne 1 ] || [ $PTMode_1 -ne 1 ]; then
	echo "usbnic is not enabled.. Exiting.."
	exit 1
fi

   host_mac_from_cmd_line=$mac2
   idrac_mac_from_cmd_line=$mac1

#######################################################################################
#
#          Adding Dell Prefix to MACaddress of the iDRAC usb0 interface
#
#######################################################################################

idrac_usb0_mac_addr_byte1=`echo $mac2 | cut -d: -f1`
idrac_usb0_mac_addr_byte2=`echo $mac2 | cut -d: -f2`
idrac_usb0_mac_addr_byte3=`echo $mac2 | cut -d: -f3`
idrac_usb0_mac_addr_byte4=`echo $mac2 | cut -d: -f4`
idrac_usb0_mac_addr_byte5=`echo $mac2 | cut -d: -f5`
idrac_usb0_mac_addr_byte6=`echo $mac2 | cut -d: -f6`

idrac_mac_last3_byte=$idrac_usb0_mac_addr_byte4$idrac_usb0_mac_addr_byte5$idrac_usb0_mac_addr_byte6

add_dell_prifix_to_idrac_mac=`printf "%x" $((0x${idrac_mac_last3_byte} + 0x000100))`


new_idrac_usb0_mac_addr_byte4=`echo $add_dell_prifix_to_idrac_mac | cut -c1``echo $add_dell_prifix_to_idrac_mac | cut -c2`
new_idrac_usb0_mac_addr_byte5=`echo $add_dell_prifix_to_idrac_mac | cut -c3``echo $add_dell_prifix_to_idrac_mac | cut -c4`
new_idrac_usb0_mac_addr_byte6=`echo $add_dell_prifix_to_idrac_mac | cut -c5``echo $add_dell_prifix_to_idrac_mac | cut -c6`

idrac_new_mac_addr=$idrac_usb0_mac_addr_byte1:$idrac_usb0_mac_addr_byte2:$idrac_usb0_mac_addr_byte3:$new_idrac_usb0_mac_addr_byte4:$new_idrac_usb0_mac_addr_byte5:$new_idrac_usb0_mac_addr_byte6

while [ $idrac_mac_from_cmd_line == $idrac_new_mac_addr ] || [ $host_mac_from_cmd_line == $idrac_new_mac_addr ] ; do
        new_mac_conflict=`printf "%x" $((0x${add_dell_prifix_to_idrac_mac} + 0x000001))`
	new_idrac_usb0_mac_addr_byte4=`echo $add_dell_prifix_to_idrac_mac | cut -c1``echo $new_mac_conflict | cut -c2`
        new_idrac_usb0_mac_addr_byte5=`echo $add_dell_prifix_to_idrac_mac | cut -c3``echo $new_mac_conflict | cut -c4`
        new_idrac_usb0_mac_addr_byte6=`echo $add_dell_prifix_to_idrac_mac | cut -c5``echo $new_mac_conflict | cut -c6`
        idrac_new_mac_addr=$idrac_usb0_mac_addr_byte1:$idrac_usb0_mac_addr_byte2:$idrac_usb0_mac_addr_byte3:$new_idrac_usb0_mac_addr_byte4:$new_idrac_usb0_mac_addr_byte5:$new_idrac_usb0_mac_addr_byte6
done

#######################################################################################


  if [[ -n "$host_mac_from_cmd_line" ]]; then
	host_mac=$host_mac_from_cmd_line
  else
  	if [ -f /flash/data0/oem_ps/host_usb_mac ]; then
        	host_mac=`cat /flash/data0/oem_ps/host_usb_mac`
  	else
  		addr0=$(hexdump -n1 -e '/1 "%02X"' /dev/random)
        	while [ $((0x${addr0} & 0x01)) == 1 ]; do
                	addr0=$(hexdump -n1 -e '/1 "%02X"' /dev/random)
                	echo "$addr0"
        	done

        	host_usbnic_mac=$addr0$(hexdump -n5 -e '/1 ":%02X"' /dev/random)
        	while [ $host_usbnic_mac == "00:00:00:00:00:00" ]; do
                	addr0=$(hexdump -n1 -e '/1 "%02X"' /dev/random)
                	while [ $((0x${addr0} & 0x01)) == 1 ]; do
                        	addr0=$(hexdump -n1 -e '/1 "%02X"' /dev/random)
                        	echo "$addr0"
                	done
                	host_usbnic_mac=$(hexdump -n5 -e '/1 "%02X"' /dev/random)

                	echo " check for zero address"
                	echo $host_usbnic_mac

        	done

        	echo $host_usbnic_mac >/flash/data0/oem_ps/host_usb_mac
  	fi

  	host_mac=`cat /flash/data0/oem_ps/host_usb_mac`
  fi

# Bring up usb-nic
  echo "The host mac address is "$host_mac
  insmod /lib/modules/g_ether.ko dev_addr=$idrac_new_mac_addr, host_addr=$host_mac;
  sleep 2
  ifconfig usb0 add fe80::1234/64 up

  usbip=$UsbNicIpAddress_1
  ifconfig usb0 $usbip
  baseaddr="$(echo $usbip | cut -d. -f1-3)"
  echo $baseaddr.$lsv
  lsv=`echo $usbip | cut -d. -f4`
  if [ "$usbip" == "169.254.0.2" ]; then
     lsv=5
  else
     lsv=$(( $lsv + 1 ))
  fi
  hostip=$baseaddr.0

# frame dhcp server config file
  UDHCPDDIR=/tmp/udhcpd
  mkdir -p ${UDHCPDDIR}
  echo "start $baseaddr.$lsv" > ${UDHCPDDIR}/udhcpd_usb0.conf
  lsv=$(( $lsv + 1 ))
  echo "end $baseaddr.$lsv" >> ${UDHCPDDIR}/udhcpd_usb0.conf
  echo "interface       usb0" >> ${UDHCPDDIR}/udhcpd_usb0.conf
  echo "lease_file ${UDHCPDDIR}/udhcpd.leases" >> ${UDHCPDDIR}/udhcpd_usb0.conf
  echo "pidfile /var/run/udhcpd_usb0.pid" >> ${UDHCPDDIR}/udhcpd_usb0.conf
  echo "option  subnet  255.255.255.0" >> ${UDHCPDDIR}/udhcpd_usb0.conf
  echo "option  domain  local" >> ${UDHCPDDIR}/udhcpd_usb0.conf
  touch ${UDHCPDDIR}/udhcpd.leases
  route del -net 169.254.0.0 netmask 255.255.0.0 usb0
  route add -net $hostip netmask 255.255.0.0 dev usb0
