#!/bin/sh
# Nothing in this script relies on A) kernel loadable modules, B) volatile
# files or directories so it can run *very* early in boot when not much else is
# going on
#
# the reason behind this script is that "ifconfig eth1 up" for the first time
# takes 3-4 seconds. We can get that back by doing it in parallel with some of
# the early boot
#
# if this optimization doesn't work out, we can just fold this back into
# osinet.sh, where it all came from

# output to journal
set -x

/usr/bin/DedicatedNICControl.sh start
# sometimes the NIC will be busy and throw an error.
# bring down eth0 interface before applying mac.
ifconfig eth0 down
# sleep not necessary. just a precaution
sleep 2

# Bring up DNIC only if available
CPLD_Byte_21=`MemAccess -rb 0x14000021 | grep 0x14000021 | awk '{print $3}'`
AMEA_PRES_N=`printf "0x%02x" $(( 0x$CPLD_Byte_21 & 0x08 ))`

if [ "0x00" == "$AMEA_PRES_N" ] ; then
    ifconfig eth0 hw ether ${mac1} up
else
    # GUI has dependency of reading MAC from eth0 interface.
    # raised a CR to change API. after that following line can be removed.
    ifconfig eth0 hw ether ${mac1}
fi

# bring up eth1, which brings up NCSI interfaces. Do this now takes 3 seconds
ifconfig eth1 hw ether ${mac1} up
# check for Manufacture bit and retry only if NOT set
MFR_BYTE=`MemAccess -rb 0x14000000 | grep 0x14000000 | cut -d" " -f10`
MFR_BIT=`printf "0x%02x" $(( 0x${MFR_BYTE} & 0x02 ))`
if [ "0x00" == "$MFR_BIT" ] ; then
  # retry eth1 bring up if no ncsi interfaces found
  # retry mechanism to address NDC limitatiton where sometimes no ncsi devices shows up
  # do not remove this
  i=1
  while [ `grep -c ncsi /proc/net/dev` -eq 0 ] ; do
    ifconfig eth1 down
    sleep 5
    ifconfig eth1 hw ether ${mac1} up
    sleep 1
    i=`expr $i + 1`
    echo "retrying eth1 $i" >> /tmp/net_init.log
    if [[ $i -gt 2 ]]; then
        break
    fi
  done
else
  echo "Manufacture bit set" >> /tmp/net_init.log
fi


#eth2 should come up after eth1 for DCS Platforms.
if [ -e /flash/data0/features/dcs ]; then
    if [ "$(cat /flash/data0/features/system-name)" == "Pounce" ]; then
        if [ "$(readcfg -g16486 -f2)" == "CustomMezzCardPresence_1=1" ]; then
            ifconfig eth2 hw ether ${mac1} up
        fi
    elif [ "$(cat /flash/data0/features/system-name)" != "Pounceport" ]; then
        ifconfig eth2 hw ether ${mac1} up
    fi
fi

# Check for HW Arbitration bit for shared LOM
maxlom=0
hwarbit=`cat /sys/bus/platform/drivers/ncsi_protocol/ncsi_device_number | xargs | cut -d" " -f13`
if [[ $hwarbit == 1 ]] ; then
  maxlom=`grep -c ncsi /proc/net/dev`
else
 if [ -e /flash/data0/features/dcs ]; then
   maxlom=2
 else
  maxlom=0
 fi
fi
if [ ${maxlom} -gt 4 ]; then
  maxlom=4
fi
aim_config_set_int NumOfEmbdLOMs ${maxlom}

# setup MAC address
i=0
maxlom=`grep -c ncsi /proc/net/dev`
while [ $i -lt ${maxlom} ]; do
    echo Configure ncsi$i interface
    ifconfig ncsi${i} hw ether ${mac1}
    i=`expr $i + 1`
done

# limit ECHO REPLY responses
mask=$(cat /proc/sys/net/ipv4/icmp_ratemask)
mask=$(( ${mask} | 1 ))
echo ${mask} > /proc/sys/net/ipv4/icmp_ratemask

# Clear system hostname
echo "" > /proc/sys/kernel/domainname

# removed the grep test for already present rules here since we don't
# re-run this script under any circumstances except development (saves
# several seconds)
iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
iptables -A OUTPUT -p icmp --icmp-type timestamp-reply -j DROP

# block all external Avahi traffic. allow on usb interfaces only.
# drop it on bond0 or any vlan
iptables -A INPUT -p udp -i usb0 --dport 5353 -j ACCEPT
iptables -A INPUT -p udp -i usb0 --dport 5355 -j ACCEPT
iptables -A INPUT -p udp -i usb1 --dport 5353 -j ACCEPT
iptables -A INPUT -p udp -i usb1 --dport 5355 -j ACCEPT
iptables -A INPUT -p udp --dport 5353 -j DROP
iptables -A INPUT -p udp --dport 5355 -j DROP

iptables -A OUTPUT -p udp -o usb0 --sport 5353 -j ACCEPT
iptables -A OUTPUT -p udp -o usb0 --sport 5355 -j ACCEPT
iptables -A OUTPUT -p udp -o usb1 --sport 5353 -j ACCEPT
iptables -A OUTPUT -p udp -o usb1 --sport 5355 -j ACCEPT
iptables -A OUTPUT -p udp --sport 5353 -j DROP
iptables -A OUTPUT -p udp --sport 5355 -j DROP

ip6tables -A INPUT -p udp -i usb0 --dport 5353 -j ACCEPT
ip6tables -A INPUT -p udp -i usb0 --dport 5355 -j ACCEPT
ip6tables -A INPUT -p udp -i usb1 --dport 5353 -j ACCEPT
ip6tables -A INPUT -p udp -i usb1 --dport 5355 -j ACCEPT
ip6tables -A INPUT -p udp --dport 5353 -j DROP
ip6tables -A INPUT -p udp --dport 5355 -j DROP

ip6tables -A OUTPUT -p udp -o usb0 --sport 5353 -j ACCEPT
ip6tables -A OUTPUT -p udp -o usb0 --sport 5355 -j ACCEPT
ip6tables -A OUTPUT -p udp -o usb1 --sport 5353 -j ACCEPT
ip6tables -A OUTPUT -p udp -o usb1 --sport 5355 -j ACCEPT
ip6tables -A OUTPUT -p udp --sport 5353 -j DROP
ip6tables -A OUTPUT -p udp --sport 5355 -j DROP

