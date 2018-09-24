#/bin/sh
#
#Summary-   This script stops the WSMAN file log.
# 
debugcontrol -d L2NFS >/dev/null 2>&1
/etc/sysapps_script/Start_L2NFS.sh stop >/dev/null 2>&1
sleep 10
umount /tmp/L2NFS
rmdir /tmp/L2NFS
rmdir /tmp/L2NFS_LOG
/etc/sysapps_script/wsman_decrypt.sh >/dev/null 2>&1
