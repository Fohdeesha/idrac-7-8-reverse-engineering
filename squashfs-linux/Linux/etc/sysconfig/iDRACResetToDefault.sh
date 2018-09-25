#!/bin/sh

LOCKFILE=/var/lock/r2default.lock
FIPSMODECFG_FILE=/flash/data0/oem_ps/fips.txt
FIPSMODEFEATURE_FILE=/flash/data0/features/fips.txt

RM="/bin/rm -rf"
TOUCH=/bin/touch

# If SPI is in unresponsive state, and we're on 13g, just return
# since a reboot will lock the iDRAC
if [ -e /flash/data0/features/shasta ] &&
   [ -e /mmc1/SPI_shadow.bin ]; then
    exit 0
fi

# action starting
echo "Reset to Default action is starting ..."

# check lock file existed
if [ ! -e ${LOCKFILE} ]; then
	echo "${TOUCH} ${LOCKFILE}"
    ${TOUCH} ${LOCKFILE}
fi

#FIPS mode steps

if [ ! -e ${FIPSMODEFEATURE_FILE} ] &&
   [ -e ${FIPSMODECFG_FILE} ]; then
   #entering FIPS mode, create the feature file and
   #continue RTD
   echo "LD_LIBRARY_PATH=/usr/fips" > ${FIPSMODEFEATURE_FILE}
elif [ -e ${FIPSMODEFEATURE_FILE} ] &&
   [ -e ${FIPSMODECFG_FILE} ]; then
   #exiting FIPS mode
   #remove any traces, and log the event
   rm -f ${FIPSMODEFEATURE_FILE}
   rm -f ${FIPSMODECFG_FILE}
   dcitst command=lcltest messageID=SEC0703 agentID=66 category=5 severity=3
else
   #we were never in FIPS mode
   #remove any traces, just in case
   rm -f ${FIPSMODEFEATURE_FILE}
   rm -f ${FIPSMODECFG_FILE}
fi

echo "Restoring PM ..."
/etc/sysapps_script/pm_lcd_update.sh
/etc/sysapps_script/pm_power_update.sh
/etc/sysapps_script/pm_re_update.sh
/etc/sysapps_script/pm_lc_update.sh
/etc/sysapps_script/pm_alert_update.sh
/etc/sysapps_script/pm_ipmi_update.sh

cp -f /etc/def_ssh/* /etc/ssh/
rm -f /etc/ssh/ssh_host*
rm -rf /etc/sysconfig/network_config/*
rm -rf /etc/certs/*
rm -rf /flash/data0/home
/etc/init.d/credential-vault-13g.sh reset
rm -rf /flash/data0/aim/persistent
readcfg -s all
hostname ""
/etc/sysapps_script/wseventing_reset.sh
# check redfish subscription folder exists
if [ -e /flash/data0/redfish_subscriptions ]; then
	echo "redfish subscriptions folder found..."
	rm -rf /flash/data0/redfish_subscriptions
fi
cp /etc/default/eventfiltercfg32 /flash/data0/config/eventfilter32_1
#Set a flag so xmlconfig script will be executed during next reboot
touch /flash/data0/oem_ps/pm_rstd
echo "Reset action is done ..."
sleep 3

#For Greyjoy platforms
#remove pwd change flag when racreset is issued
pt_ID=$(get-system-id)
if [ "$pt_ID" == "7e" ] || [ "$pt_ID" == "7d" ]; then
	rm /flash/data0/change_idrac_def_pwd
fi

#Reboot iDRAC only if 13G HW
if [ -e /flash/data0/features/shasta ]; then
    echo "Rebooting iDRAC ..."
    /bin/drac-force-reboot.sh
fi
#Just restart iDRAC services if 12G HW
if [ -e /flash/data0/features/not-shasta ]; then
    #BITS197465: D1.2ES-12G-Reset to Default -  generating core, HW version shown UNKNOWN, unable to create new user
    #Need to clean-up AIM configuration
    systemctl stop aim.service
    rm -rf /tmp/aim
    rm -f /tmp/aim_running

    # stop osinet here
    systemctl stop osinet.service
    rm -rf /tmp/network_config/*
    rm -rf /etc/sysconfig/network_config/*

    readcfg -s all
    # kill ssh sessions for racuser
    systemctl stop sshd.service
    for row in `ps -T | grep "sshd: racuser" | awk '{print $1}'`
    do
        kill -9 $row  2> /dev/null
    done
    systemctl stop usb0.service
    #BITS259224 cleanup iptables when RTD
    ip6tables -F
    iptables -F
    iptables -X IP_range
#JIT-100704 send alert for 12G hardware. Similar line in drac-force-reboot.sh script, but that is only called for 13G hardware in the case of racresetcfg
[ -f /flash/data0/features/platform-modular ] && echo "Sending alert" && /usr/bin/IPMICmd 0x20 0x30 0x00 0x97 0x00 0x00 0x00 0x00 0x80 0x00 0x00 0x00 0    
    echo "Restarting iDRAC services ..."
    systemctl start restart-services.service
fi

# remove lock file
if [ -e ${LOCKFILE} ]; then
   echo "${RM} ${LOCKFILE}"
    ${RM} ${LOCKFILE}
fi

# action finished

