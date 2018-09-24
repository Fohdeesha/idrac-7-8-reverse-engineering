#!/bin/sh
d_start() {
echo $$ > /var/run/mod-mock.pid
MemAccess POWER_OVERRIDE > /dev/null
enable_lan=$?

Is_nicenabled=`racadm getconfig -g cfglannetworking -o cfgNicEnable | awk '{printf$1}'`
#echo $Is_nicenabled

if [ "$Is_nicenabled" == "1" ] ; then
config_lan=0
else
config_lan=1
fi

if [ "$enable_lan" == "1" ] ; then
/bin/IPMICmd 0x20 0x30 0 0xC9  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
if [ "$config_lan" == "1" ] ; then
sleep 2

echo "Platform is HiFi or PwrOn jumper is installed"
racadm config -g cfglannetworking -o cfgNicEnable 1
racadm config -g cfgLanNetworking  -o cfgNicIPv4Enable 1
racadm config -g cfgLanNetworking  -o cfgNicUseDhcp 1
racadm config -g cfgIpmiLan -o cfgIpmiLanEnable 1
fi
fi
}
case "$1" in
  start)
    d_start
    ;;
    
  *)
    d_start
    ;;

esac

