# Start the apwHdlrAgent

RETVAL=0
modulename="/usr/local/bin/apwHdlrAgent"
rootname="apwHdlrAgent"

start() {
	if pidof $rootname > /dev/null; then
		echo "$rootname is already running"
        echo
	else
			$modulename &
	fi
	return $RETVAL
}

stop() {
	killall $rootname
}

restart() {
	stop
	start
}

reset() {
	stop
}

status_at() {
	if pidof $rootname > /dev/null; then
		echo "$rootname is running"
        echo
	else
		echo "$rootname is not running"
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
