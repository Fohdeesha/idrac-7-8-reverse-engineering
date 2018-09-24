#!/bin/sh
# note:  assume start argument only called on boot time
#        Add Serial Application for Blade Server 2010/09/24
modulename="/sbin/telnetd"
rootname="telnetd"
TELNETD_ENABLED=`/avct/sbin/aim_config_get_bool pm_bool_telnet_enabled`
TELNETD_PORT=`/avct/sbin/aim_config_get_int pm_int_telnet_port`
TELNETD_SESSION_TIMEOUT=`/avct/sbin/aim_config_get_int pm_int_telnet_session_timeout`
MemAccess PLATFORM_TYPE > /dev/null
PLATFORM_TYPE=$?
start() {
  
  cnt=$(ps -T | grep -c $modulename)

  if [ $cnt -le 1 ]
  then
    # test if the variable is null is true
    if [ $TELNETD_ENABLED ] && [ $TELNETD_ENABLED == "true" ]; then
      $modulename -p $TELNETD_PORT -t $TELNETD_SESSION_TIMEOUT
    fi
    touch /var/run/utmp

    #bind Telnetd to VLAN:2100 to service Serial Redirect, Blade only
    if [ "$PLATFORM_TYPE" == "1" ]; then
	MemAccess VLAN_ID > /dev/null
	VLAN_ID=$?
	VLANIP=${VLAN_ID}
      $modulename -B -b 169.254.31.$VLANIP:2100 -l /etc/sysapps_script/SerRedir.sh -t $TELNETD_SESSION_TIMEOUT
    fi

  else
     echo "$modulename already running"
     echo
  fi
}

stop() {
  cnt=$(ps -T | grep -c $modulename)

  if [ $cnt -gt 1 ]
  then
    killall -9 $rootname
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
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo $"Usage: $0 {start|stop|reset|restart}"
    exit 1
esac

RETVAL=0
exit $?
