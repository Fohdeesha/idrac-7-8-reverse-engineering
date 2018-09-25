#!/bin/sh
#/etc/sysapps_script/S_3050_serviceman.sh restart
/etc/sysapps_script/S_4000_RemotePresence.sh restart
/etc/sysapps_script/S_7010_snmpd.sh restart
/etc/sysapps_script/S_7015_telnetd_app.sh restart

systemctl restart sshd
