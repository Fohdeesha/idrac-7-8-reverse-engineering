#!/bin/sh 

echo "================= Journalctl osinet,lompt,usb0 ======================="
journalctl -u osinet | cat
journalctl -u lompt | cat
journalctl -u usb0 | cat

echo "================= filesystem ======================="
ls /tmp/network_config/*
cat /tmp/network_config/*
ls /flash/data0/config/network_config/*
cat /flash/data0/config/network_config/*

echo "================= avctifconfig ======================="
avctifconfig "current"

echo "================= ifconfig ======================="
ifconfig
ifconfig -a
echo "ethtool eth0"
ethtool eth0

echo "=================  flags   ======================="
echo -n "########## NumOfEmbdLOMs: "
aim_config_get_int NumOfEmbdLOMs
echo ""
echo -n "########## osinet_bool_defect_lom: "
aim_config_get_bool osinet_bool_defect_lom 
echo ""
echo -n "########## osinet_bool_modular_lan_ready:"
aim_config_get_bool osinet_bool_modular_lan_ready
echo ""
echo -n "########## ameastatus_bool_12G_amea_present"
aim_config_get_bool ameastatus_bool_12G_amea_present
echo ""

echo "================= NCSI Test ======================="
libncsitest 0
i=0
for dev in $( ls /sys/class/net/ | grep ncsi | sort )
do
  echo "########## Link status $i"
  libncsitest 1 ${i} 3 1000
  i=`expr $i + 1`
done

echo "================= bonding driver  ======================="
echo "########## /proc/net/bonding/bond0"
cat /proc/net/bonding/bond0

echo "================= timings     ======================="
echo "########## cmdline"
cat /proc/cmdline
echo "########## network uptime"
cat /tmp/EVENT_NETCHANGE_ACTIVE
echo "########## /tmp/boottime"
cat /tmp/boottime
echo "########## autonic.log"
cat /tmp/autonic.log
echo "########## imcreadylog"
cat /tmp/imcreadylog

echo "================= MemAcceess     ======================="
MemAccess -rb 0x14000000
MemAccess -rb 0x14000040

echo "================= iptables     ======================="
iptables -L
