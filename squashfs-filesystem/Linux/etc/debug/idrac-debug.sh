#!/bin/sh

COUNT=0
if [ -e /flash/data0/debug/idrac-debug ]; then
        source /flash/data0/debug/idrac-debug
	if [[ $COUNT == 0 ]]; then
	    rm -f /flash/data0/debug/idrac-debug
	    if [ -d /flash/data0/debug/systemd/system ]; then
		rm -rf /flash/data0/debug/systemd
	    fi
	    exit 0
	else
	    COUNT=$(( $COUNT - 1 ))
	    echo "COUNT=$COUNT" > /flash/data0/debug/idrac-debug
	    if [ -d /flash/data0/debug/systemd/system ]; then
		/etc/debug/sysd-linker.sh
	    fi
	fi
fi
