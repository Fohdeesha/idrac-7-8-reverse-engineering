#!/bin/sh
# Start the Application MCTPD component

RETVAL=0
modulename="/bin/mctpd"
#enablelog="debugcontrol -s 10 -l 4 -0 2"
start() {
	
	cnt=$(ps -T | grep -c $modulename 2>/dev/null)
	$enablelog
	if [ $cnt -le 1 ] ;  then
		$modulename &
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
