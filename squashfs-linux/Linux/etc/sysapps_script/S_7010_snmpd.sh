#!/bin/sh
# note: assume start argument only called on boot time

init() {
	if [ -d /flash/data0/etc/snmp ]; then
		rm -rf /etc/snmp
	else
		mv /etc/snmp /flash/data0/etc
	fi

	ln -s /flash/data0/etc/snmp /etc/snmp
	
}

start() {
	sh /etc/sysapps_script/snmpd.startup start
}

stop() {
	sh /etc/sysapps_script/snmpd.startup stop
}

restart() {
	sh /etc/sysapps_script/snmpd.startup restart
}

case "$1" in
	start)
		init
		start
		;;
	stop)
		stop
		;;
	reset)
		stop
		;;
	restart)
		restart
		;;
	*)
		echo $"Usage: $0 {start|stop|reset|restart}"
		exit 1
esac

exit $?
