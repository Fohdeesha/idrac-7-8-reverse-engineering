#/bin/sh
#
#Summary-  This script sets up the WSMAN log to NFS - thru FSD
# 
mkdir /tmp/L2NFS
mkdir /tmp/L2NFS_LOG
mount -t nfs 192.168.250.250:/a1s2df34 /tmp/L2NFS -o nolock 2>/dev/null
debugcontrol -l INF -s L2NFS >/dev/null 2>&1
/etc/sysapps_script/Start_L2NFS.sh start >/dev/null 2>&1
