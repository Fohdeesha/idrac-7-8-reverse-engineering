#!/bin/sh

CONFIG_FILE=/flash/data0/etc/syslog.conf
SERVICES_FILE=/flash/data0/etc/services
PID_FILE=/var/run/syslogd.pid
AIM_SERVICE=/sbin/aim

if [ -z $2 ]; then
	FM_STATUS=`/avct/sbin/fmchk rsyslog -d 1`
else
	FM_STATUS=$2
fi

create_config() {

	/bin/MemTest IS_AMEA_BOARD_EXIST > /dev/null
	AMEA_CARD_PRESENT=1
#	AMEA_CARD_PRESENT=$?
#	AMEA_CARD_PRESENT=$(/avct/sbin/aim_config_get_bool ameastatus_bool_amea_present || echo false)

	cnt=$(ps -T | grep -c "$AIM_SERVICE")

	if [ $cnt -gt 1 ]
	then
    SYSLOG_REMOTE_ENABLED=$(/avct/sbin/aim_config_get_bool pm_bool_remote_syslog_enable || echo false)
	else
	  SYSLOG_REMOTE_ENABLED=false
		echo "$0: $AIM_SERVICE not running"
	fi

	if [ "${AMEA_CARD_PRESENT}" == "1" ] && [ "${SYSLOG_REMOTE_ENABLED}" == "true" ] && [ "${FM_STATUS}" == "1" ]; then
    SYSLOG_REMOTE_SERVER1=$(/avct/sbin/aim_config_get_str pm_str_remote_syslog_server1)
    SYSLOG_REMOTE_SERVER2=$(/avct/sbin/aim_config_get_str pm_str_remote_syslog_server2)
    SYSLOG_REMOTE_SERVER3=$(/avct/sbin/aim_config_get_str pm_str_remote_syslog_server3)
  fi

    (
	echo 'kern.*;syslog.*			/dev/console'
	echo '*.info;kern.*;syslog.*;cron.none;local1.!info;local2.!info;local3.!info;local4.!info	/messages/messages'
	echo 'kern.crit			/var/log/coredump.log'
	echo '*.emerg 			*'
	echo 'local1.*			/dev/console'
	echo 'local2.*			/tmp/idraclogs'
	echo 'local3.*			/mmc1/idraclogs'
	if [ "${AMEA_CARD_PRESENT}" == "1" ] && [ "${SYSLOG_REMOTE_ENABLED}" == "true" ] && [ "${FM_STATUS}" == "1" ]; then
	    if [ "${SYSLOG_REMOTE_SERVER1}" != "" ] ; then
		echo "local4,local5.*			@$SYSLOG_REMOTE_SERVER1"
	    fi
	    if [ "${SYSLOG_REMOTE_SERVER2}" != "" ] ; then
		echo "local4,local5.*			@$SYSLOG_REMOTE_SERVER2"
	    fi
	    if [ "${SYSLOG_REMOTE_SERVER3}" != "" ] ; then
		echo "local4,local5.*			@$SYSLOG_REMOTE_SERVER3"
	    fi
	fi
	echo ''
    ) > ${CONFIG_FILE}.tmp

    mv ${CONFIG_FILE}.tmp ${CONFIG_FILE}

}

create_services() {
    SYSLOG_REMOTE_UDP=$(/avct/sbin/aim_config_get_int pm_int_remote_syslog_udp || echo 514)

# assumes that syslog is the only service using /etc/services:
# otherwise we need an sed script
    rm -f ${SERVICES_FILE}
    echo "syslog          ${SYSLOG_REMOTE_UDP}/udp" > ${SERVICES_FILE}
    echo "ntp             123/tcp" >> ${SERVICES_FILE}
    echo "ntp             123/udp" >> ${SERVICES_FILE}

    if [ ! -h /etc/services ] ; then
	rm -f /etc/services
	ln -fs ${SERVICES_FILE} /etc/services
    fi
}

start() {
#    [ -f ${CONFIG_FILE} ] || create_config
    create_config

    if [ ! -f ${SERVICES_FILE} ] ; then
	create_services
    fi

    if [ ! -h /etc/services ] ; then
	rm -f /etc/services
	ln -fs ${SERVICES_FILE} /etc/services
    fi

#	if ! cat /proc/modules | grep -q ipv6; then
#          insmod /usr/local/lib/modules/ipv6.ko
#    fi

    if [ "x${1}" != "xskip" ]; then
     systemctl start syslog.service
#    /sbin/syslogd -m 0 -f ${CONFIG_FILE} > /dev/null 2>&1
#    /sbin/klogd
    fi
}

softstart() {
		stop
		start
}

stop() {
     systemctl stop syslog.service
#    killall syslogd
#    killall klogd
}

case "$1" in
    init)
    echo initialize syslogd
    start "skip"
    ;;

    start)
    echo starting syslogd
    start
    ;;

    stop)
    echo stopping syslogd
    stop
    ;;

    restart)
    stop
    sleep 1
    start
    ;;

    reconfig)
    create_config
    create_services
    sleep 1
    softstart
    ;;

    softstart)
    softstart
    ;;
    *)
    echo $"Usage: $0 {start|stop|restart|softstart}"
    RETVAL=1

esac

exit $RETVAL




