#!/bin/sh
RETVAL=0

start() {
	running=`ps|grep /usr/sbin/ipmiextd|grep -v grep`
        if [ ! -z "$running" ]; then
                echo "!!!!! ipmiext already running"
                exit 0
        fi

	echo ""
	echo "######## start ipmiextd ########"
	echo ""

        /usr/sbin/ipmiextd > /dev/null
        RETVAL=$?
        if [ $RETVAL != 0 ]; then
#		echo "done"
#        else
		echo "FAILED retval = $RETVAL"
        fi
        return $RETVAL
}

stop() {
	killall -2 ipmiextd
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
	sleep 1
	start
}
case "$1" in
start)
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
	echo "Usage: $0 {start|stop|restart}"
	exit 1
esac
exit $?
exit $RETVALETVAL
