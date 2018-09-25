#!/bin/sh
#
# /etc/init.d/avahi-daemon start
# arg1 - start, stop, restart

#set -e

if [ "0" == `grep avahi /etc/passwd | wc -l` ]; then
  echo "user avahi not found. creating...."
#  adduser -H avahi
fi

usbenable() {
  usb1pid=$(ps | grep udhcpd | awk '/u[d]hcpd_usb1.conf/{print $1}')
  kill -9 $usb1pid
  sleep 2
  ifconfig usb1 add fe80::1234/64 up
  usbip=169.254.0.3
  ifconfig usb1 $usbip
  baseaddr="$(echo $usbip | cut -d. -f1-3)"
  echo $baseaddr.$lsv
  lsv=`echo $usbip | cut -d. -f4`
  lsv=$(( $lsv + 1 ))
  echo "start $baseaddr.$lsv" > /tmp/udhcpd_usb1.conf
  lsv=$(( $lsv + 1 ))
  echo "end $baseaddr.$lsv" >> /tmp/udhcpd_usb1.conf
  echo "interface       usb1" >> /tmp/udhcpd_usb1.conf
  echo "lease_file /var/lib/udhcpc/udhcpd.leases" >> /tmp/udhcpd_usb1.conf
  echo "option  subnet  255.255.255.0" >> /tmp/udhcpd_usb1.conf
  echo "option  domain  local" >> /tmp/udhcpd_usb1.conf
  touch /var/lib/udhcpc/udhcpd.leases
  route del -net 169.254.0.0 netmask 255.255.0.0 usb1
  route add -net 169.254.0.4 netmask 255.255.255.255 dev usb1
  /sbin/udhcpd -S /tmp/udhcpd_usb1.conf
  /bin/arping -f -b -U -s $usbip -c 3 -f -I usb1 $usbip
#  cp -f /etc/sysconfig/avahi/usbnic_avahi-daemon.conf /etc/avahi/avahi-daemon.conf
#  /etc/init.d/avahi-daemon restart
}

disable() {
   if grep -q usb1 /proc/net/dev ; then
	ifconfig usb1 down
   fi
   usb1pid=$(ps | grep udhcpd | awk '/u[d]hcpd_usb1.conf/{print $1}')
   kill -9 $usb1pid
   rm /tmp/udhcpd_usb1.conf
}

status() {
   /etc/init.d/avahi-daemon status
   cat /etc/avahi/avahi-daemon.conf | grep allow-interfaces | cut -d "=" -f2
}

case "$1" in
    start)
        usbenable
        ;;
    stop)
        disable
        ;;
    status)
        status
	;;
    *)
	echo "enable/ disable name resolution with host OS"
        echo "Usage: $0 {start|stop|status}" 
	echo -e "options:\n\tstart - enable name resolution"
	echo -e "\tstop - disable name resolution"
	echo -e "\tstatus - status of name resolution"
        exit 1
        ;;
esac
exit $?
