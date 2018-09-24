# Start the VKVM_PM Interface component
# Startup Dependency: logging

RETVAL=0
modulename="/sbin/vkvm_pm"
rootname="vkvm_pm"
version="2.2.0"

start() {
	cnt=$(ps | grep -c $modulename)

	if [ $cnt -le 1 ]
	then
		echo "start $rootname version: $version"
		#
		# For debug mode, the component must be started in background.
		# If NOT debug mode (default), the component should be started
		# in foreground (it will fork a child and then exit).
		#
		# For debug mode, uncomment the following line and comment out
		# the line after it.
		# $modulename -d &
		$modulename 
	else
		echo "$modulename already running"
		echo
	fi
	return $RETVAL
}

stop() {
	killall -9 $rootname
	# remove receive message queue
	rm -rf /dev/mqueue/AIM-MQ35010
}

restart() {
	stop
	start
}

reset() {
	stop
}

status_at() {
	cnt=$(ps | grep -c $modulename)

	if [ $cnt -gt 1 ]
	then
		echo -n "$modulename running"
		echo
	else
		echo -n "$modulename not running"
		echo
	fi
}

version() {
        echo "$rootname version: $version"
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
version)
	version
	;;
*)
	echo $"Usage: $0 {start|stop|restart|reset|status|version}"
	exit 1
esac

exit $?
exit $RETVAL
