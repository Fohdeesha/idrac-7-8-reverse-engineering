RETVAL=0

srcdir="/etc/default"
destdir="/flash/data0/etc"

exec_fmgr="/avct/sbin/fmgr"
exec_fmchk="/avct/sbin/fmchk"

start() {
	if [ ! -f "$destdir/fake_feb.txt" ]; then
		cp $srcdir/fake_feb.txt $destdir
	fi

	fmgr_running=`ps | grep fmgr | grep -v "\[fmgr\]" | grep -v S_9300_fmgr | grep -v grep`
	dsm_running=`ps | grep dsm_sa_datamgrd | grep -v grep`
	
	if [ ! -z "$dsm_running" ]; then
		echo "DM running"
		if [ ! -z "$fmgr_running" ]; then
			# FM/DM running. Send LM FEB update event
			echo "FM running"
			echo "#### Update LM FEB ####"
			$exec_fmchk -l
			
		else
			# DM running/FM not running. start with LM FEB
			echo "FM not running"
			echo "#### start fmgr with LM FEB ####"
#			$exec_fmgr -f 
			$exec_fmgr 
		fi
	else
		echo "DM not running"
		if [ ! -z "$fmgr_running" ]; then
			# DM not running/FM running. stop
			echo "FM running"
			echo "#### fmgr is running already!! ####"		
		else
			# DM/FM not running. start fmgr with fake FEB
			echo "FM not running"
			$exec_fmgr -f 
		fi
	fi
	# sleep 5
	# problem fixed. comment this out
#	/etc/sysapps_script/clp_shell.sh 
}

stop() {
	# Use -9 will not exexute exit_handle() and cause semaphore leak
	killall fmgr
}

restart() {
	stop
	sleep 3
	killall -9 fmgr
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
