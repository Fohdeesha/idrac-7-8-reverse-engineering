#!/bin/sh
# manual_ifplugd.sh 

if [[ -z $3 ]]; then
    echo "Usage: $0 <interface> <up scan> <down scan>"
    exit 1
fi

echo -n "manual ifplugd - "
AUTONIC_CONTROL_SCRIPT=/usr/etc/autonic/DedicatedNICControl.sh
AUTONIC_SWITCHER_SCRIPT=/usr/etc/autonic/autonicswitcher.sh

bond0_slave=`${AUTONIC_CONTROL_SCRIPT} active`
link=0
last_link=2
upcount=$2
downcount=$3
 
while [ $upcount -gt 0 ] && [ $downcount -gt 0 ] ;
do
    str=`/sbin/ifplugstatus $1 | cut -d" " -f2`
    if [[ $str == "link"  ]] ; then
	link=1
    else
    	link=0
    fi
    sleep 1
    echo -n "."
    
    if [[ ${link} != ${last_link} ]] ; then
    if [[ "${bond0_slave}" != "$1" ]] ; then
      # scan for dedicated nic
      dedicated_scan=1
      upcount=$2
      downcount=$3
    else
      # scan for shared nic
      dedicated_scan=0
      upcount=$3
      downcount=$2
    fi
    fi

    if [ ${dedicated_scan} == ${link} ]; then
	upcount=$(( $upcount - 1 ))
    else
	downcount=$(( $downcount - 1 ))
    fi

    last_link=$link
done

echo "."
logger -s "$1 ${link} event detected. sending request to autonic switcher"
echo "$(date): $0 ${link} " >> /tmp/autonic.log
sh ${AUTONIC_SWITCHER_SCRIPT} ${link}
