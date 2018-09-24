#!/etc/bash
if [ -z "$1" ]; then
    echo "Usage: idrac_performance.sh cycle_interval(s) no_cycles <2nd storage location>"
    exit
fi
if [ -z "$2" ]; then
    echo "Usage: idrac_performance.sh cycle_interval(s) no_cycles <2nd storage location>"
    exit
fi
# cycle_interval = 10 minutes (600 seconds)
cycle_interval=$1
# because of the scripts execution time, the time interval between iteration is about 15 minutws
# no_cycles = 4 * 7 * 24 * 4 = 2688 for about 1 month, 32256 for about one year
no_cycles=$2
echo ""
echo "**************************************************"
echo "             iDRAC PERFORMANCE"
echo "**************************************************"
echo "Cycle interval: $cycle_interval sec, No cycles: $no_cycles"
echo ""
echo "iDRAC Performance" > /tmp/idrac_performance.txt
for (( cycle_index=0; cycle_index<$no_cycles; cycle_index++ ))
do
    timestamp=`date`
    echo "iDRAC PERFORMANCE: Performance measurement $cycle_index, $timestamp"
    echo "iDRAC PERFORMANCE: Performance measurement $cycle_index, $timestamp" >> /tmp/idrac_performance.txt
    timestamp1=`date`
    echo "  $timestamp1 - CPU usage ..."
    cpu_usage.sh $cycle_index >> /tmp/idrac_performance.txt
    sleep 10
    timestamp1=`date`
    echo "  $timestamp1 - Mem usage ..."
    mem_usage.sh $cycle_index >> /tmp/idrac_performance.txt
    sleep 10
    timestamp1=`date`
    echo "  $timestamp1 - Sem usage ..."
    sem_usage.sh $cycle_index >> /tmp/idrac_performance.txt
    sleep 10
    timestamp1=`date`
    echo "  $timestamp1 - FD usage ..."
    fd_usage.sh $cycle_index >> /tmp/idrac_performance.txt
    sleep 10
    timestamp1=`date`
    echo "  $timestamp1 - eMMC usage ..."
    emmc_usage.sh $cycle_index >> /tmp/idrac_performance.txt
    if [ -n "$3" ]; then
        cp /tmp/cpu_usage.csv $3
        cp /tmp/mem_usage*.csv $3
        cp /tmp/sem_usage.csv $3
        cp /tmp/fd_usage.csv $3
        cp /tmp/emmc_usage.csv $3
        cp /tmp/idrac_performance.txt $3
    fi
    sleep $cycle_interval
done
echo ""
echo "**************************************************"
echo "            END iDRAC PERFORMANCE"
echo "**************************************************"
echo ""

