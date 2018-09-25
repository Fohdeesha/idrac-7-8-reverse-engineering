#!/etc/bash

EMMCLOGS=/flash/data1/mmc_stats.log
if [ -n "$1" ]; then
    iteration=$1
else
    iteration=0
fi
timestamp=`date`
build=`head -1 /etc/fw_ver`
echo "eMMC Usage Iteration $iteration, $timestamp"
if [ $iteration -eq 0 ]; then
    echo "Reads,Writes,Erases,Iteration,Timestamp,Build" > /tmp/emmc_usage.csv
    echo "Generating /tmp/emmc_usage.csv file"
    if [ -e "${EMMCLOGS}" ]; then
        rm -f $EMMCLOGS
    fi
    mmc_stats
else
    if [ -e "${EMMCLOGS}" ]; then
        rm -f $EMMCLOGS
    fi
    mmc_stats
    let "reads = $( cat $EMMCLOGS | sed 's/,/ /g' | awk '{print $1}' )"
    let "writes = $( cat $EMMCLOGS | sed 's/,/ /g' | awk '{print $2}' )"
    let "erases = $( cat $EMMCLOGS | sed 's/,/ /g' | awk '{print $3}' )"
    echo "$reads,$writes,$erases,$iteration,$timestamp,$build" >> /tmp/emmc_usage.csv
fi
echo
echo "Done"
