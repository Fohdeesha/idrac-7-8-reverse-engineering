#!/bin/sh
RETVAL=0

start() {
		if [ ! -d /flash/data0/raclogd ]; then
			mkdir -p /flash/data0/raclogd
		fi

        /usr/sbin/raclogd > /dev/null
        RETVAL=$?
        if [ $RETVAL != 0 ]; then
#		echo "done"
#        else
		echo "FAILED retval = $RETVAL"
        fi
        return $RETVAL
}

stop() {
	killall -9 raclogd
	RETVAL=$?
    	if [ $RETVAL != 0 ]; then
#		echo "done"
#    	else
		echo "FAILED retval = $RETVAL"
    	fi
	return $RETVAL
}

restart() {
	stop
	start
}

case "$1" in
start)
	start
	;;
stop)
	stop
	;;
restart)
	restart
	;;
*)
	echo "Usage: $0 {start|stop|restart}"
	exit 1
esac
exit $?
exit $RETVALETVAL
