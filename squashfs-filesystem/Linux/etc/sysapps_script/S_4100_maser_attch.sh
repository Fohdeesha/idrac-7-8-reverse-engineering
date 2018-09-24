#!/bin/sh

script="/etc/sysapps_script/S_4100a_maser_impop.sh"

case "$1" in
	start | stop | check)
		$script $1 &
		;;
	reset)
		$script stop
		;;
	restart)
		$script stop
		$script start &
		;;
	*)
		echo $"Usage: $0 {start|stop|reset|restart}"
		exit 1
esac

exit $?
