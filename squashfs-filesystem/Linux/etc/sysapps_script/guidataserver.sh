#!/bin/sh

start() {
	export CALLER=gui
	export DATA_SERVER_PORT=8195
	export AVCT_DEF_PROP_FILE=/usr/local/etc/appweb/default.properties
	export AVCT_MAP_PROP_FILE=/usr/local/etc/appweb/map.properties
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/appweb
	#export AVCT_DATASERVER_DEBUG=/tmp/dataserver.log
	if [ -e /flash/data0/debug/gds ]; then
		/usr/local/bin/guiDataServer -debug 1 &
	else
		/usr/local/bin/guiDataServer > /dev/null 2>&1 &
	fi
}

stop() {
# use -3 instead of -9 for semaphore cleanup
	killall -q -3 guiDataServer
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	reset)
		stop
		#start
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|reset}"
		exit 1
esac

exit 0
