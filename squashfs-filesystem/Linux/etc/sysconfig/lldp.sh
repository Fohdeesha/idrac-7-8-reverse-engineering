#!/bin/sh
#
# /usr/sbin/lldpd -d -I eth0 -cefsk -M1 -u /var/run/lldpd.socket -m <idrac ip address>
# /usr/sbin/lldpd -d -I eth1 -cefsk -M1 -u /var/run/lldpd.socket -m <idrac ip address>
# 

LLDP_SETTINGS=/etc/sysconfig/network_config/lldp.conf
TMP_LLDP_SETTINGS=/tmp/network_config/lldp.conf

LLDPEnable=1

write_fn(){
    echo "LLDPEnable=$LLDPEnable" > ${TMP_LLDP_SETTINGS}
    cp -f ${TMP_LLDP_SETTINGS} ${LLDP_SETTINGS}
}

config_fn() {
# Read current settings
if [[ -e ${TMP_LLDP_SETTINGS} ]]; then
  source ${TMP_LLDP_SETTINGS}
else
  echo "${TMP_LLDP_SETTINGS} not found"
  if [[ -e ${LLDP_SETTINGS} ]]; then
    echo "Found backup.."
    cp -f ${LLDP_SETTINGS} ${TMP_LLDP_SETTINGS}
    source ${TMP_LLDP_SETTINGS}
  else
    echo "Generate defaults .."
    write_fn
  fi
fi
}

act_lldpd() {

	if [[ $LLDPEnable == 0 ]]; then
	    killall -9 lldpd
	else
	    if [ -z "$2" ] ; then
          	echo "lldp.sh read <netmode> <idrac ip address>"
          	exit 1
            fi

	    if [[ $1 == 0 ]]; then
		IFACE="eth0"
	    else
		IFACE="eth1"
	    fi

    	    if [ "0" == `grep _lldpd /etc/passwd | wc -l` ]; then
		echo "user _lldpd not found. creating...."
		adduser -SDH _lldpd
		addgroup _lldpd
	    fi	    

	    /usr/sbin/lldpd -I $IFACE -cefsk -M1 -u /var/run/lldpd.socket -m $2
	fi
}

case "$1" in
    enable)
	if [ -z "$2" ] ; then
          echo "$0 enable <value>"
          exit 1
        fi
	logger -s $0 $1 $2
	LLDPEnable=$2
	write_fn
	if [[ $LLDPEnable == 0 ]]; then
            killall -9 lldpd
	fi
	;;
    read)
	logger -s $0 $1 $2 $3
	source ${TMP_LLDP_SETTINGS}
	act_lldpd $2 $3
	;;
    config)
	logger -s $0 $1
        config_fn
        ;;
    *)
        echo "Usage: $0 {enable|read|config} <value> <idrac ip address>"
	echo -e "options:\n\tenable - (value)sets config value"
	echo -e "\tread - (netmode, idrac ip address)read config file and enable/disable lldp"
	echo -e "\tconfig - copies persistent storage to temp, create default if not available"
        exit 1
        ;;
esac
exit $?

