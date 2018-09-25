#!/bin/sh
# Start the usb_app component
# Startup Dependency: usbmux_drv

RETVAL=0
modulename="/bin/usb_app"
rootname="usb_app"

#
# updates global variable FULLFEATUES
#
start() {
	cnt=$(ps -T | grep -c $modulename)

	if [ $cnt -le 1 ]
	then
                #
                # For debug mode, the component must be started in background.
                # If NOT debug mode (default), the component should be started
                # in foreground (it will fork a child and then exit).
                #
                # For debug mode, uncomment the following line and comment out
                # the entire if statement after it
                # $modulename -d [n] &
                $modulename &
	else
		echo "$modulename already running"
		echo
	fi


	return $RETVAL
}

stop() {
	killall -INT $rootname
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

exit $RETVAL

