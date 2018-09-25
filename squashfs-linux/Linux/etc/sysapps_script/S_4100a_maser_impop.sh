#!/bin/sh

RETVAL=0
ids="001 002 005 021 022 024 025"
VMRDY_BIT=2
MASER_READY_FILE="/tmp/maser_ready"

check_ready() 
{
    let try_max=90
    let try_count=1
    let RETVAL=0
		let vmrdy=0
    while [ ${try_count} -le ${try_max} ]; do 
	vmrdy=`shmread -i $VMRDY_BIT | grep 0x`
        if [[ $vmrdy = 0x00 ]]; then
            sleep 1
        else
            echo "VMedia is ready in ${try_count} seconds"
            return $RETVAL
        fi
        let try_count++
    done
    echo "ERROR: VMedia NOT ready in 90 seconds"

		echo "Retrying once"
		echo "Retried starting APS" > /mmc1/aps.restart
		systemctl restart aps
		sleep 5
		vmrdy=`shmread -i $VMRDY_BIT | grep 0x`
		[[ $vmrdy = 0x00 ]] || { echo "VMedia is ready " ;  return $RETVAL; }

		RETVAL=1
			return $RETVAL
}

add_file() {
    let RETVAL=0
    if [ "$2" != "025"   ]; then
        if [ -e /mmc1/$1$2.img ]; then
          echo "$1$2.img found in mmc1"
        else
      	  echo "$1$2 missing in mmc1. Recreate it."
      	  dd if=/dev/zero of=/tmp/$1$2.img count=1
        fi
        for j in $(seq 0 10); do
					echo "Adding MAS$2 to map, Attempt: $j"
					/bin/avct_control --file=/mmc1/$1$2.img --store=1 --id=$3 --size=0 imgcreate
					echo "Return Code: $?"
					exist=`avct_control imginfo | grep MAS$2 | sed 's/^.*Name=//' | sed 's/\.//'`
					if [ ! -z ${exist} ] ; then echo "Success" ; break ; else echo "Failed" ; sleep 1 ; fi
				done
				exist=`avct_control imginfo | grep MAS$2 | sed 's/^.*Name=//' | sed 's/\.//'`
				if [ ! -z ${exist} ] ; then echo "Success" ; else echo "Failed to add $1$2 to store" ; RETVAL=1 ; fi
    else
        if [ -e /mmc1/$1$2.img ]; then
          echo "$1$2.img found in mmc1"
    	else
      	  echo "$1$2 missing in mmc1. Recreate it."
      	  dd if=/dev/zero of=/tmp/$1$2.img count=1
    	fi
      for j in $(seq 0 10); do
				echo "Adding MAS$2 to map, Attempt: $j"
        /bin/avct_control --file=/mmc1/$1$2.img --store=4 --id=$3 --size=0 imgcreate
				echo "Return Code: $?"
				exist=`avct_control imginfo | grep MAS$2 | sed 's/^.*Name=//' | sed 's/\.//'`
				if [ ! -z ${exist} ] ; then echo "Success" ; break ; else echo "Failed" ; sleep 1 ; fi
      done
			exist=`avct_control imginfo | grep MAS$2 | sed 's/^.*Name=//' | sed 's/\.//'`
			if [ ! -z ${exist} ] ; then echo "Success" ; else echo "Failed to add $1$2 to store" ; RETVAL=1 ; fi
    fi
    return $RETVAL
}

del_file() {
    /bin/avct_control --img=$1 imgdelete 2>&1 > /dev/null
}

start() {
	check_ready
	if [ $RETVAL -eq 0 ]; then
		for id in ${ids}; do
			add_file mas ${id} MAS${id}
			if [ $RETVAL -ne 0 ]; then
				return $RETVAL
			fi
		done
		# set MASER_READY
		rm -f /flash/data0/oem_ps/maserinit
		if [ ! -e "/flash/data0/oem_ps/maserinit" ] ; then
			#echo "MASER READY BIT SET"
			/bin/shmwrite -i 6 1 > /dev/null 2>&1
            touch $MASER_READY_FILE
		fi
	fi
#  prepare the console preview folder
	if [ ! -e /tmp/preview ] ; then
		mkdir -p /tmp/preview
		ln -s /usr/local/www/images/nosignal.png /tmp/preview/scapture0.png
	fi
	let RETVAL=0
	return $RETVAL
}

stop() {
	check_ready
	if [ $RETVAL -eq 0 ]; then
		list=`avct_control imginfo | grep MAS | awk '{print $3}' | cut -d= -f2 | cut -d, -f1`
		for id in ${list}; do
			del_file $id
		done
	fi
}

check() {
	for id in ${ids}; do
		if [ -e /tmp/mas$id.img ]; then
			file=`avct_control imginfo | grep MAS$id | awk '{print $3}' | cut -d= -f2 | cut -d, -f1`
			del_file $file
			add_file mas $id MAS$id
			rm -f /tmp/mas$id.img
		fi
	done
}

case "$1" in
	start)
		start
		if [ $RETVAL -ne 0 ]; then
			if [ ! -e /tmp/aps_restart ]; then
				echo "Restarting APS after MASER image addition failure"
				systemctl restart aps
				touch /tmp/aps_restart
			fi
		fi
		;;
	stop)
		stop
		;;
	reset)
		stop
		;;
	restart)
		stop
		start
		;;
	check)
		check
		;;
	*)
		echo $"Usage: $0 {start|stop|reset|restart}"
		exit 1
esac

exit $?
