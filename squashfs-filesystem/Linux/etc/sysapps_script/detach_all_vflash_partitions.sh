#!/bin/sh
#check if vflash is enabled
enable=`racadm getconfig -g cfgvflashsd | grep -i cfgvflashsdenable | cut -d= -f2`
if [ 0 -eq ${enable} ] ; then
	exit
fi

#find out how many partitions are attached
listParts=`racadm vflashpartition list | grep "Attached" | awk '{ print $1 }' `

#detach partitions if attached
for i in ${listParts} ; do
	racadm config -g cfgvflashpartition -i $i -o cfgVFlashPartitionAttachState 0
	sleep 1
done
    

