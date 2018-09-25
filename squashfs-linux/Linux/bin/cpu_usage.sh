#!/etc/bash
if [ -n "$1" ]; then
    iteration=$1
else
    iteration=0
fi
timestamp=`date`
build=`head -1 /etc/fw_ver`
if [ $iteration -eq 0 ]; then
    echo "Proc ID,Proc Name,CPU% x10,Iteration,Timestamp,Build" > /tmp/cpu_usage.csv
    echo "Generating /tmp/cpu_usage.csv file"
fi
echo "CPU Usage Iteration $iteration, $timestamp"
# Do not change no_cycle. it should be 10 so the output will be % * 10
no_cycles=10
let "last_cycle = $no_cycles - 1"
firstdata=1
for (( cycle_index=0; cycle_index<$no_cycles; cycle_index++ ))
do
    top -b -n 1 > /tmp/top.out
    startdata=0
    while read pid ppid user stat vsz mem cpuno cpu command xtra
    do
        if [ $startdata -eq 1 ] && [ ${#pid} -gt 0 ]; then
            #echo "$pid $ppid $user $stat $vsz $mem $cpu $command $xtra"
            #echo "vsz = $vsz"
            if [ $vsz = "<" ]; then
                #echo "vsz = $vsz"
                cpu=$command
                command=$xtra
            fi
            if [ $firstdata -eq 1 ]; then
                let "cpu_usage[$pid] = $(echo $cpu | cut -d % -f 1)"
                firstdata=0
            else
                let "cpu_usage[$pid] = ${cpu_usage[$pid]} + $(echo $cpu | cut -d % -f 1)"
            fi
            if [ $cycle_index -eq $last_cycle ]; then
                echo "$pid,$command,${cpu_usage[$pid]},$iteration,$timestamp,$build" >> /tmp/cpu_usage.csv
            fi
        fi
        if [ $startdata -eq 0 ]; then
            if [ $pid = "PID" ]; then
                startdata=1
            fi
        fi
    done </tmp/top.out
    echo -n "."
done
echo
echo "Done"
