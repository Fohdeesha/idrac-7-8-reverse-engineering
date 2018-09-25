# Start sfcbd

RETVAL=0
modulename="/usr/sbin/sfcbd"
rootname="sfcbd"

start() {
   cnt=$(ps -T | grep -c $modulename)
   
   if [ $cnt -le 1 ]
   then
      $modulename -d
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
      killall -9 $rootname
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

