#!/etc/bash

fd_usage_id()
{
	total_descriptors=0
	files=0
	sockets=0
	pipes=0
    pid=$1
    ls -l /proc/$pid/fd > /tmp/fd.out
    while read field1 field2 field3 field4 field5 field6 field8 field9 field10 field11
    do
		file_name=`echo $field11 | cut -c 4-`\
		prefix4=${file_name:0:4}
		#prefix6=${file_name:0:6}
		let "total_descriptors = $total_descriptors + 1"
		if [ $prefix4 = "sock" ]; then
			let "sockets = $sockets + 1"
		fi
		if [ $prefix4 = "pipe" ]; then
			let "pipes = $pipes + 1"
		fi
        echo $field1,$field10,$file_name >> /tmp/fd_usage_details.csv
    done </tmp/fd.out
	let "files = $total_descriptors - $sockets - $pipes"
}

#Script Main
    if [ -n "$1" ]; then
        iteration=$1
    else
        iteration=0
    fi
    timestamp=`date`
    build=`head -1 /etc/fw_ver`
    if [ $iteration -eq 0 ]; then
        echo "Proc ID,Proc Name,Total Descriptors,Files,Sockets,Pipes,Iteration,Timestamp,Build" > /tmp/fd_usage.csv
		echo > /tmp/fd_usage_details.csv
        echo "File Descriptors Usage"
        echo "Generating /tmp/fd_usage.csv, /tmp/fd_usage_details.csv file"
    fi
    echo "FD Usage Iteration $iteration, $timestamp"
    # Processes
    for folder in $( ls /proc );
    do
        if [ $folder -eq $folder 2> /dev/null ]; then
            if [ -d "/proc/$folder/fd" ]; then
                pid=$folder
				echo Iteration: $iteration>> /tmp/fd_usage_details.csv
				echo Process: $pid $proc_name >> /tmp/fd_usage_details.csv
                proc_name=$( cat /proc/$pid/cmdline | sed 's/,/_/g' )
                fd_usage_id $pid
				echo >> /tmp/fd_usage_details.csv
                echo "$pid,$proc_name,$total_descriptors,$files,$sockets,$pipes,$iteration,$timestamp,$build" >> /tmp/fd_usage.csv
                echo -n "."
            fi
        fi
    done
    #echo >> /tmp/fd_usage.csv

    echo
    echo "Done"
