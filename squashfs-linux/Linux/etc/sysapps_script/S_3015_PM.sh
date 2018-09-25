#!/bin/sh
# Start the PM Interface component

RETVAL=0
modulename="/avct/sbin/pm"
rootname="pm"

start() {
	cnt=$(ps -T | grep -c $modulename)

	if [ $cnt -le 1 ]
	then
		$modulename &
	else
		echo "$modulename already running"
		echo
	fi
	return $RETVAL
}

stop() {
	killall -9 $rootname
}

restart() {
	stop
	start
}

reset() {
	stop
}

status_at() {
	cnt=$(ps -T | grep -c $modulename)

	if [ $cnt -gt 1 ]
	then
		echo -n "$modulename running"
		echo
	else
		echo -n "$modulename not running"
		echo
	fi
}

case "$1" in
start)
	start
	;;
stop)
	stop
	;;
reset)
	reset
	;;
restart)
	restart
	;;
status)
	status_at
	;;
*)
	echo $"Usage: $0 {start|stop|restart|reset|status}"
	exit 1
esac

exit $?
exit $RETVAL
