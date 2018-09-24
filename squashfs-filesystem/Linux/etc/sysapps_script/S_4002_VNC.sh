#!/bin/sh
# Start the avct_server component
# Startup Dependency: vnc-app
# Startup Dependency: video_drv
# Startup Dependency: usb_drv

RETVAL=0
modulename="/bin/fb_source"
rootname="fb_source"
modulename1="/bin/fb_vnc_server"
rootname1="fb_vnc_server"
vncstatus="/tmp/vnc_server_ready"
vncconnected="/tmp/vnc_client_connected"

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


        cnt=$(ps -T | grep -c $modulename1)

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
                $modulename1 &
        else
                echo "$modulename1 already running"
                echo
        fi


	return $RETVAL
}

stop() {
	rm $vncstatus
	rm $vncconnected   
	killall -INT $rootname1
	sleep 3
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

        cnt=$(ps -T | grep -c $modulename1)

        if [ $cnt -gt 1 ]
        then
                echo -n "$modulename1 running"
                echo
        else
                echo -n "$modulename1 not running"
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

