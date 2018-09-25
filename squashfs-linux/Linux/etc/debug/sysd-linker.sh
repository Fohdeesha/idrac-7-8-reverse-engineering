#!/bin/sh
#SCRIPT: identifies new service files and enables

libdir=/lib/systemd/system/
psdir=/flash/data0/debug/systemd/system/
etcdir=/etc/systemd/system/
serv_list=""
for i in $psdir/*.service
do
     fname=`basename $i`
     if [ ! -f $libdir/$fname ]; then
         echo $fname
	 serv_list="$fname "
     fi
done
mount $psdir $libdir
/bin/systemctl --system daemon-reload
if [[ "$serv_list" != "" ]]; then
	/bin/systemctl enable $serv_list
fi
