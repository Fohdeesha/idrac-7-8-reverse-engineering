# Start the avct_server and maser_attach scripts

RETVAL=0
#modulename="/bin/XXXXX"
#rootname="XXXXX"

start() {
    /etc/sysapps_script/S_4000_APS.sh start
    /etc/sysapps_script/S_4100_maser_attch.sh start
	return $RETVAL
}

stop() {
    /etc/sysapps_script/S_4000_APS.sh stop
    /etc/sysapps_script/S_4100_maser_attch.sh stop
}

restart() {
	stop
	start
}

reset() {
	stop
}

status_at() {
    /etc/sysapps_script/S_4000_APS.sh status
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
