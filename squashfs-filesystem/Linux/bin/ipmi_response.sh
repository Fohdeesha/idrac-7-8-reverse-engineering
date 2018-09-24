#!/bin/sh

echo "IPMI Response time test"
echo "Generating /tmp/ipmi_response.csv file"

# Run the ipmi commands multiple times, then do an average
no_cycles=10
rm -f /tmp/ipmi_exec_time.out
rm -f /tmp/ipmi_abs_time.out
for (( cycle_index=0; cycle_index<$no_cycles; cycle_index++ ))
do
    echo -n "."
    debugcontrol -i start > /tmp/ipmicmd.out
    index=0
    while read ifno[index] netfn[index] lun[index] cmd[index] data[index]
    do
        IPMICmd ${ifno[index]} ${netfn[index]} ${lun[index]} ${cmd[index]} ${data[index]} >> /tmp/ipmicmd.out
        let "index = $index + 1"
        #echo -n "."
    #done </tmp/ipmi_cmds_list
    done </bin/ipmi_cmds_list
    debugcontrol -i stop >> /tmp/ipmicmd.out
    trabdump -i ALL | grep "Execution Time:" | awk -v cycleindex="$cycle_index" '{print cycleindex " " $3}' >> /tmp/ipmi_exec_time.out
    trabdump -i ALL | grep "Absolute Time:" | awk -v cycleindex="$cycle_index" '{print cycleindex " " $3}' >> /tmp/ipmi_abs_time.out
done

index=0
prev_seq=0;
while read seq time
do
    if [ $seq -gt $prev_seq ]; then
        index=0;
        echo -n "."
    fi
    #echo "$seq $time"
    int_part=`echo $time | cut -d '.' -f1`
    dec_part=`echo $time | cut -d '.' -f2`
    if [ $int_part -gt 0 ]; then
        ttime=`echo $int_part$dec_part`
    else
        ttime=$dec_part
    fi
    # convert to microseconds
    let "ttime = $ttime * 10"
    if [ $seq -eq 0 ]; then
        let "exec_time[index] = $ttime"
    else
        let "exec_time[index]= ${exec_time[index]} + $ttime"
    fi
    #echo "$index ${exec_time[index]}"
    let "index = $index + 1"
    
    let "prev_seq = $seq"
done </tmp/ipmi_exec_time.out


index=0
prev_seq=0;
while read seq time
do
    if [ $seq -gt $prev_seq ]; then
        index=0;
        echo -n "."
    fi
    #echo "$seq $time"
    if [ $seq -eq 0 ]; then
        let "abs_time[index] = $time"
    else
        let "abs_time[index]= ${abs_time[index]} + $time"
    fi
    
    let "index = $index + 1"
    
    let "prev_seq = $seq"
done </tmp/ipmi_abs_time.out

let "no_logs = $( debugcontrol -i n | awk '{print $3}' )"
echo "NetFn,LUN,Cmd,Data,Exec Time[us],Abs Time[ms]" > /tmp/ipmi_response.csv
for (( index=0; index<$no_logs; index++ ))
do
    let "exec_time[index]= ${exec_time[index]} / $no_cycles"
    let "abs_time[index]= ${abs_time[index]} / $no_cycles"
    echo "${netfn[index]},${lun[index]},${cmd[index]},${data[index]},${exec_time[index]},${abs_time[index]}" >> /tmp/ipmi_response.csv
done
echo
echo "Done"
