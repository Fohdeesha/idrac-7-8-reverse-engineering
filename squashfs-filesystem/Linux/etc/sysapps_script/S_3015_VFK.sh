#!/bin/sh
# Start the PM Interface component

RETVAL=0
modulename="/sbin/vfk"
rootname="vfk"

start() {
	if pidof $rootname > /dev/null; then
		echo "$rootname already running"
	else
		# Determine if we don't support muxing
#		DUMMY=$(grep "Secure" /messages/* | tail -c 2)
#		echo "DUMMY='${DUMMY}'"
#		if [[ "${DUMMY}" != "x" ]]; then
#			echo "Starting VFK in non-mux mode..."
#			if [[ -e /mmc1/ameasd.img ]]; then
#				/avct/sbin/aim_config_set_bool ameastatus_bool_amea_sd_present true false
#			else
#				/avct/sbin/aim_config_set_bool ameastatus_bool_amea_sd_present false false
#			fi
#			$modulename -evb &
#		else
			$modulename &
#		fi
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
	if pidof $rootname > /dev/null; then
		echo "$rootname running"
	else
		echo "$rootname not running"
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
