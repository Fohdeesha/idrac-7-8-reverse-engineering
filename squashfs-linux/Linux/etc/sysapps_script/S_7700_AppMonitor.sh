#!/bin/sh
# Start the Application Monitor component

RETVAL=0
modulename="/bin/AppMonitor"

start() {
	cnt=$(ps -T | grep -c $modulename 2>/dev/null)

	if [ $cnt -le 1 ] ;  then
		$modulename
	else
		echo "$modulename already running"
		echo
	fi
	return $RETVAL
}

stop() {
	pkill -f "$modulename "
}

restart() {
	stop
	start
}

status_at() {
	cnt=$(ps -T | grep -c $modulename 2>/dev/null)

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
	echo "Not support"
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
