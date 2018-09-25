#!/bin/sh
#
# /sbin/ifplugd -i eth0 -afqI -u5 -d30 -miff
# arg1 - start, stop, restart
#set -e

SCRIPT_FOLDER=/usr/etc/autonic

NIC_SWITCH_SETTINGS=/etc/sysconfig/network_config/NICSwitch.conf
TMP_NIC_SWITCH_SETTINGS=/tmp/network_config/NICSwitch.conf
SCAN_SCRIPT=${SCRIPT_FOLDER}/DedicatedNICScan.sh
CONTROL_SCRIPT=${SCRIPT_FOLDER}/DedicatedNICControl.sh
IFPLUGD_ACTION_SCRIPT=${SCRIPT_FOLDER}/ifplugd_run_script.sh
MANUAL_IFPLUGD_SCRIPT=${SCRIPT_FOLDER}/manual_ifplugd.sh

AUTO=0
AUTO_DEDICATED=5
AUTO_SHARED=30
AUTO_NET_MODE=0
AUTO_VLAN_SETTING=0

print_fn() {
    echo "AUTO=$AUTO"
    echo "AUTO_DEDICATED=$AUTO_DEDICATED"
    echo "AUTO_SHARED=$AUTO_SHARED"
    echo "AUTO_NET_MODE=$AUTO_NET_MODE"
    echo "AUTO_VLAN_SETTING=$AUTO_VLAN_SETTING"
}

write_fn(){
    echo "AUTO=$AUTO" > ${TMP_NIC_SWITCH_SETTINGS}
    echo "AUTO_DEDICATED=$AUTO_DEDICATED" >> ${TMP_NIC_SWITCH_SETTINGS}
    echo "AUTO_SHARED=$AUTO_SHARED" >> ${TMP_NIC_SWITCH_SETTINGS}
    echo "AUTO_NET_MODE=$AUTO_NET_MODE" >> ${TMP_NIC_SWITCH_SETTINGS}
    echo "AUTO_VLAN_SETTING=$AUTO_VLAN_SETTING" >> ${TMP_NIC_SWITCH_SETTINGS}

    cp -f ${TMP_NIC_SWITCH_SETTINGS} ${NIC_SWITCH_SETTINGS}
}

config_fn() {
# Read current settings
if [[ -e ${TMP_NIC_SWITCH_SETTINGS} ]]; then
  source ${TMP_NIC_SWITCH_SETTINGS}
else
  echo "${TMP_NIC_SWITCH_SETTINGS} not found"
  if [[ -e ${NIC_SWITCH_SETTINGS} ]]; then
    echo "Found backup.."
    cp -f ${NIC_SWITCH_SETTINGS} ${TMP_NIC_SWITCH_SETTINGS}
    source ${TMP_NIC_SWITCH_SETTINGS}
  else
    echo "Generate defaults .."
    write_fn
  fi
fi
}

netmode_fn () {
  echo "update auto-netmode"
  AUTO_NET_MODE=$1
  write_fn
}

start_fn() {
  AUTO=1
  AUTO_DEDICATED=$1
  AUTO_SHARED=$2
  AUTO_NET_MODE=$3
  AUTO_VLAN_SETTING=$4
  write_fn

  sh ${CONTROL_SCRIPT} start
  if ifplugd -i eth0 -c
  then
    /sbin/ifplugd -i eth0 -k
  fi
  /sbin/ifplugd -i eth0 -fpqI -u${AUTO_DEDICATED} -d${AUTO_SHARED} -r ${IFPLUGD_ACTION_SCRIPT}
  sh ${MANUAL_IFPLUGD_SCRIPT} eth0 ${AUTO_DEDICATED} ${AUTO_SHARED} &
}

stop_fn() {
  AUTO=0
  AUTO_DEDICATED=$1
  AUTO_SHARED=$2
  AUTO_NET_MODE=$3
  AUTO_VLAN_SETTING=$4
  write_fn

  if ifplugd -i eth0 -c
  then
    /sbin/ifplugd -i eth0 -k
  fi
}

case "$1" in
    start)
	if [ -z "$5" ] ; then
	  echo "$0 $1 <uptime> <downtime> <auto-netmode> <auto-vlansetting>"
	  exit 1
	fi
	config_fn
        start_fn $2 $3 $4 $5
        ;;
    stop)
	if [ -z "$5" ] ; then
	  echo "$0 $1 <uptime> <downtime> <auto-netmode> <auto-vlansetting>"
	  exit 1
	fi
	config_fn
	print_fn
        stop_fn $2 $3 $4 $5
        ;;
    netmode)
	if [ -z "$2" ] ; then
	  echo "$0 $1 <auto-netmode>"
	  exit 1
	fi
	config_fn
        netmode_fn $2
        ;;
    config)
        config_fn
        ;;
    *)
        echo "Usage: $0 {start|stop|netmode|config} <uptime> <downtime> <net-mode> <vlansetting>"
	echo -e "options:\n\tstart - start scanning dedicated NIC port"
	echo -e "\tstop - stop scanning dedicated NIC port"
	echo -e "\tnetmode - updates netmode for autonic"
	echo -e "\tconfig - copies persistent storage to temp, create default if not available"
        exit 1
        ;;
esac
exit $?

