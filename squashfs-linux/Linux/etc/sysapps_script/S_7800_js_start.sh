#! /bin/sh

# process the staled download jobs first
if [ -e /flash/data0/oem_ps/re_queue ]
then
    /bin/mv -f /flash/data0/oem_ps/re_queue /flash/data0/oem_ps/re_queue_fail
    /etc/sysapps_script/re_x_dload.sh &
fi

if ps |grep -v grep| grep jdaemon > /dev/null
then
        echo "jdaemon is running already"
else
        echo "Starting jdaemon ---"
        /bin/jdaemon 
        echo "Started jdaemon"
fi

# reconnect to Network ISO upon iDRAC reset if the credentials are saved
if [ -e /flash/data0/oem_ps/connect_network_iso_credentials ]
then
        /bin/osdinst ConnectNetworkISOImage &
fi

