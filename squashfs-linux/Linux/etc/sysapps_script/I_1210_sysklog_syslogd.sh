#!/bin/sh
rm -f /var/run/syslogd.pid > /dev/null 2>&1
if [ ! -d /tmp/messages ]
then
	rm -f /tmp/messages
	mkdir /tmp/messages
fi

touch /messages/messages
chmod 644 /messages/messages
[ -d /var/log/raclogd/ ] || mkdir -p /var/log/raclogd/
touch /var/log/raclogd/raclog
chmod 644 /var/log/raclogd/raclog
touch /var/log/coredump.log
chmod 644 /var/log/coredump.log

if [ "x${1}" != "xskip" ]; then
	/etc/sysapps_script/syslog.sh start
fi
