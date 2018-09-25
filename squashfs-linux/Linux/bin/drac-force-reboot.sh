#!/bin/sh
set +x

i=0
maxlom=`grep -c ncsi /proc/net/dev`
while [ $i -lt $maxlom ]; do
  echo unblocking ncsi$i interface
  /usr/bin/libncsitest 11 $i 0 1
  i=`expr $i + 1`
done

# set core file to none
echo /dev/null > /proc/sys/kernel/core_pattern
echo "Starting long running stops now..."
systemctl stop idracMonitor

# The removal is just the unblock the issue. (BITS158656)
# But we need to find out why it is not flushing the changes even waiting for 5 secs.
# We need to comup with a mechanism to force flush all the data before rebooting instead of waiting it to do that.
# We have time limitation in reboot so waiting will cause more issues.
#systemctl stop cfgbkup.service
#JIT-100704 send alert
[ -f /flash/data0/features/platform-modular ] && echo "Sending alert" && /usr/bin/IPMICmd 0x20 0x30 0x00 0x97 0x00 0x00 0x00 0x00 0x80 0x00 0x00 0x00 0

cd /lib/systemd/system
systemctl stop *.timer
killall -9 raclogd jdaemon
systemctl stop dsm-sa-datamgr &
dm_pid=$!
systemctl stop credential-vault-13g  # this forces 12g sync as the 12g service
systemctl stop fullfw_app
systemctl stop mrcached
systemctl stop OSInterface
systemctl stop apw_hndlr.socket
systemctl stop fmgr.socket
systemctl stop wsman.socket

#wait for pending config changes
CFG_TMP_LOC=/tmp/cfgbkp
CFG_CHANGED=cfgupdate
WAIT_FOR_CHANGES=cfgchanges

echo "Wait for pending config changes ..."
while [ -f $CFG_TMP_LOC/$CFG_CHANGED -o -f $CFG_TMP_LOC/$WAIT_FOR_CHANGES ]
do
   sleep 1
done


systemctl stop credential-vault-13g  # this forces 12g sync as the 12g service depends on the 13g service (requires/after)


# Waiting for DM was not deterministic, so sleep for now
sleep 5
#wait $dm_pid
echo "Now issuing reboot!"
systemctl reboot -f
