#!/bin/sh

id=`/etc/default/ipmi/getsysid`
(while [ 1 ]; do
    if [ -e /flash/data0/BMC_Data/Platform_data_exist ] ; then
        if [ ! -d /flash/pd0/ipmi ] ; then \
            echo Platform data missing!; \
            rm -f /flash/data0/BMC_Data/Platform_data_exist; \
			cd /flash/data0/config/; ln -sf /etc/default/ipmi/${id}/cfgfld.txt
            cd /flash/data0/BMC_Data/; cp -f /etc/default/ipmi/${id}/*.dat ./; \
            ln -sf /etc/default/ipmi/${id}/bmcsetting ./; \
            for file in /etc/default/ipmi/${id}/*.bin ; do
                ln -sf ${file} ./
            done ; \
            killall -9 fullfw; \
            sleep 3; \
            /etc/sysapps_script/S_3150_fullfw_app.sh restart; \
        fi
    fi
    sleep 5
done) &
