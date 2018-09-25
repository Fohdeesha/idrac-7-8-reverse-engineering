#!/etc/bash

mem_usage_id()
{
    pid=$1
    process_total=0
    executable_total=0
    while read field1 field2 field3 field4 field5 field6
    do
        if [ ${#field5} -gt 0 ]; then
            if [ ${field2:2:1} = "x" ]; then
                # executable
                executable=1
            else
                executable=0
            fi
        fi
        if [ $field1 = "Pss:" ]; then
            let "process_total = $process_total + $field2"
            let "allprocesses_total = $allprocesses_total + $field2"
            if [ $executable -eq 1 ]; then
                let "executable_total = $executable_total + $field2"
                let "allexecutable_total = $allexecutable_total + $field2"
            fi
        fi
    done </proc/$pid/smaps
}

#Script Main
    grand_total=0
    allprocesses_total=0
    allexecutable_total=0
    kernel_code=0
    kernel_data=0
    kernel_init=0
    kernel_usage=0
    slab_allocation=0
    tmp_allocation=0
    free_report_total=0
    free_report_used=0
    free_report_free=0
    free_report_shared=0
    free_report_buffers=0
    estimated_free=0

    if [ -n "$1" ]; then
        iteration=$1
    else
        iteration=0
    fi
    timestamp=`date`
    build=`head -1 /etc/fw_ver`
    if [ $iteration -eq 0 ]; then
        echo "Proc ID,Proc Name,Total Exec(K),Total Proc(K),Iteration,Timestamp,Build" > /tmp/mem_usage.csv
        echo "Memory Usage"
        echo "Generating /tmp/mem_usage.csv, /tmp/mem_usage1.csv, /tmp/mem_usage2.csv files"
    fi
    echo "Memory Usage Iteration $iteration, $timestamp"
    # Processes
    for folder in $( ls /proc );
    do
        if [ $folder -eq $folder 2> /dev/null ]; then
            if [ -f "/proc/$folder/smaps" ]; then
                pid=$folder
                proc_name=$( cat /proc/$pid/cmdline | sed 's/,/_/g' )
                mem_usage_id $pid
                echo "$pid,$proc_name,$executable_total,$process_total,$iteration,$timestamp,$build" >> /tmp/mem_usage.csv
                echo -n "."
            fi
        fi
    done
    #echo >> /tmp/mem_usage.csv
    echo "ALL,All processes,$allexecutable_total,$allprocesses_total,$iteration,$timestamp,$build" >> /tmp/mem_usage.csv

    # Kernel
    let "kernel_code = $( dmesg | grep Memory | awk '{print $4}' | sed 's/(//g' | sed 's/k//g' )"
    let "kernel_data = $( dmesg | grep Memory | awk '{print $7}' | sed 's/k//g' )"
    let "kernel_init = $( dmesg | grep Memory | awk '{print $9}' | sed 's/k//g' )"
    let "kernel_usage = $kernel_code + $kernel_data + $kernel_init"
    echo -n "."

    # Slab
    slab_allocation=$( awk '/Slab/ {print $2}' < /proc/meminfo )
    echo -n "."

    #  /tmp
    let "tmp_allocation = $( df -k | grep tmpfs | grep /tmp | awk '{print $2}' )"
    echo -n "."

    # Total
    let "grand_total = $allprocesses_total + kernel_usage + slab_allocation + tmp_allocation"

    # Linux free report
    let "free_report_total = $( free | grep Mem: | awk '{print $2}' )"
    let "free_report_used = $( free | grep Mem: | awk '{print $3}' )"
    let "free_report_free = $( free | grep Mem: | awk '{print $4}' )"
    let "free_report_shared = $( free | grep Mem: | awk '{print $5}' )"
    let "free_report_buffers = $( free | grep Mem: | awk '{print $6}' )"
    echo -n "."

    # Estimated Free
    let "estimated_free = $free_report_total - $grand_total"
    if [ $iteration -eq 0 ]; then
        echo "Component,Size(K),Iteration,Timestamp,Build" > /tmp/mem_usage1.csv
    fi
    echo "All processes,$allprocesses_total,$iteration,$timestamp,$build" >> /tmp/mem_usage1.csv
    echo "Kernel,$kernel_usage,$iteration,$timestamp,$build" >> /tmp/mem_usage1.csv
    echo "Slab allocation,$slab_allocation,$iteration,$timestamp,$build" >> /tmp/mem_usage1.csv
    echo "/tmp allocation,$tmp_allocation,$iteration,$timestamp,$build" >> /tmp/mem_usage1.csv
    echo "Total Memory,$free_report_total,$iteration,$timestamp,$build" >> /tmp/mem_usage1.csv
    echo "Total Usage,$grand_total,$iteration,$timestamp,$build" >> /tmp/mem_usage1.csv
    echo "Estimated Free,$estimated_free,$iteration,$timestamp,$build" >> /tmp/mem_usage1.csv
    #echo >> /tmp/mem_usage.csv

    if [ $iteration -eq 0 ]; then
        echo "Linux free report" > /tmp/mem_usage2.csv
        echo "Total(K),Used(K), Free(K), Shared(K), Buffers(K),Iteration,Timestamp,Build" >> /tmp/mem_usage2.csv
    fi
    echo "$free_report_total,$free_report_used,$free_report_free,$free_report_shared,$free_report_buffers,$iteration,$timestamp,$build" >> /tmp/mem_usage2.csv
    echo
    echo "Done"
