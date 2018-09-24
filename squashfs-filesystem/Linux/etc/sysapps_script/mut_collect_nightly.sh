#!/bin/sh

# This process is started by the mut_collect.service
# It sleeps for one hour and checks if MUT.DAT is greater than 1MB. If so, runs aggregateMUT collect.
# Runs aggregateMUT collect at 11:59pm every day irrespective of size of MUT.DAT
# If the collection files take up more then 1024k, the oldest files will be deleted
# one by one until the size < 1024k

MUT_FILE=/tmp/mut/MUT.DAT
IDRAC_FIRST_POWER_ON_TIME_FILE=/flash/data3/iDRACFirstPowerOnTime.txt

# wait until mmc1/mut is available
while [ ! -d /mmc1/mut ]
do
    sleep 10
done

cd /mmc1/mut
while true
do  tgt=$(date -d "23:59:00" +%s)
read x
    cur=$(date +%s)
    let dur=$tgt-$cur
    if [ "$dur" -le "0" ]
    then
        sleep 60
        continue
    fi
    if [ "$dur" -gt "3600" ]
    then
        let size=0
        if [ -f $MUT_FILE ]
        then
            size=$(stat -c%s "$MUT_FILE")
        fi
        if [ "$size" -gt "1048576" ]
        then
            /usr/bin/aggregateMUT collect
        fi
        sleep 3600
        continue
    fi
    sleep $dur
    /usr/bin/aggregateMUT collect

    if [ ! -f $IDRAC_FIRST_POWER_ON_TIME_FILE ]; then
		/usr/bin/iDRACFirstPowerOnTime
	else
		echo "Not running the idracFirstPowerOnTime binary"
	fi

    while true
    do
        lsize=$(du -sk | cut -f1)
        if [ "$lsize" -ge "1024" ]
        then
            ls -t -1 | tail -n 1 | xargs rm -f
            if [[ $? -ne 0 ]]
            then
                # abort if rm somehow failed
                break;
            fi
        else
            break
        fi
    done
done
