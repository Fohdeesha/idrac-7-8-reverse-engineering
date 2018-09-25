#!/bin/sh
# custom init script for cron on busybox on iDRAC

# notes:
#BusyBox v1.18.4 (2012-12-18 02:37:42 CST) multi-call binary.
#
#Usage: crond -fbS -l N -d N -L LOGFILE -c DIR
#
#        -f      Foreground
#        -b      Background (default)
#        -S      Log to syslog (default)
#        -l      Set log level. 0 is the most verbose, default 8
#        -d      Set log level, log to stderr
#        -L      Log to file
#        -c      Working dir
#

crond=/sbin/crond
crontab=/bin/crontab
cron_dir=/var/spool/cron
crontabs_link=$cron_dir/crontabs
crontabs_dir=/flash/data0/crontabs
mylogfile=/tmp/crond_custom.sh.log
fullpath=$crond

populate_environment()
{
    if [ ! -d $crontabs_dir ]; then
        mkdir -p $crontabs_dir
        chmod 755 $crontabs_dir
    fi
}

start()
{
    echo "Starting $fullpath: "
    if pgrep $fullpath; then
        # it is already running
        return 0
    fi
    $fullpath -b &
}

stop()
{
    echo "Stopping $fullpath: "
    pkill $fullpath
}

restart()
{
    echo "Restarting $fullpath: "
    stop
    start
}

status()
{
    if pgrep $fullpath; then
        echo "$fullpath is running."
    else
        echo "$fullpath is not running."
    fi
}

reload()
{
    echo "Reloading $fullpath: "
    pkill -HUP $fullpath
}

init()
{
 echo "initialized"
}

# Comment this out to make one less log file in /tmp.
# Uncomment for debug as needed.
## log that we ran with arguments
#echo running $0 $* >> $mylogfile

populate_environment

if [ $# -lt 1 ] ; then
    status
    exit #?
fi

case "$1" in
    start|stop|restart|status|reload|init)
        eval "$1"
        ;;
    *)
        echo "Command $1 not supported."
        exit 1
        ;;
esac

exit $?

# vim:expandtab:tabstop=4:shiftwidth=4
