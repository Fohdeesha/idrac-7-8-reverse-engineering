#!/bin/sh

# start syslog daemon
echo "Start syslog daemon ..."
rm -f /var/run/syslogd.pid
if [ -e /flash/data0/etc/syslog.conf ]
then
    /sbin/syslogd -m 0 -f /flash/data0/etc/syslog.conf
else
    /sbin/syslogd -m 0
fi
