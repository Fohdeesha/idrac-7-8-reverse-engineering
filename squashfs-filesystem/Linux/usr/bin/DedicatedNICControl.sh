#!/bin/sh
#
# /sbin/ifplugd -i eth0 -afqI -u5 -d30 -miff
# arg1 - start, stop, restart

#set -e

/usr/local/bin/testgpio 1 166 3 1 > /dev/null
DedicatedStatus=`/usr/local/bin/testgpio 0 166 0 | grep GPIO166 | cut -d" " -f5`
enable() {
  if [ "$DedicatedStatus" = "0" ]; then
    logger -s "Enable Dedicated NIC"
    /usr/local/bin/testgpio 1 166 3 1 > /dev/null
    /usr/local/bin/testgpio 1 166 0 1
    ifconfig eth0 up
  fi
}

disable() {
  if [ "$DedicatedStatus" = "1" ]; then
    logger -s "Disable Dedicated NIC"
    ifconfig eth0 down
    /usr/local/bin/testgpio 1 166 3 1 > /dev/null
    /usr/local/bin/testgpio 1 166 0 0
  fi
}

status() {
  if [ "$DedicatedStatus" = "0" ]; then
    echo "Dedicated NIC Disabled"
  else
    echo "Dedicated NIC Enabled"
  fi
}

case "$1" in
    start)
        enable
        ;;
    stop)
        disable
        ;;
    status)
        status
	;;
    active)
	cat /proc/net/bonding/bond0 | grep "Currently Active Slave" | cut -d" " -f4
	;;
    restart)
        disable
	sleep 5
        enable
        ;;
    *)
	echo "Enable/ disable Dedicated NIC and up the interface"
        echo "Usage: $0 {start|stop|status|active|restart}" 
	echo -e "options:\n\tstart - enable dedicated NIC port"
	echo -e "\tstop - disable dedicated NIC port"
	echo -e "\trestart - disable and then enable dedicated NIC port"
	echo -e "\tstatus - status of dedicated NIC port"
	echo -e "\tactive - tells us which interface bonded to bond0 driver"
        exit 1
        ;;
esac
exit $?

