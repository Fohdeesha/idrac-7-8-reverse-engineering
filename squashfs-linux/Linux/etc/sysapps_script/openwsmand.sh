# Start sfcbd

RETVAL=0
modulename="/sbin/avct_wsman"
rootname="avct_wsman"

start() {
   cnt=$(ps -T | grep -c $modulename)
   
   if [ $cnt -le 1 ]
   then
      $modulename -r0
   else
      echo "$modulename already running"
      echo
   fi
   return $RETVAL
}

stop() {
   cnt=$(ps -T | grep -c $modulename)

   if [ $cnt -gt 1 ]
   then
      pkill $rootname
   fi
}

status() {
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
   status)
      status
      ;;
   reset)
      stop
      start
      ;;
   reload|restart)
      stop
      start
      ;;
   *)
      start
esac

exit $?
exit $RETVAL

