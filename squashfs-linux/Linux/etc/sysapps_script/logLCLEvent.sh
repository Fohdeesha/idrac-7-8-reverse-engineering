#!/bin/sh
reset_cause=$(cat /proc/cmdline | awk '{print $11}' | awk -F '=' '{print $2}')
if [ "$reset_cause" == "NMI_id_button" ]; then
  reset_cause="ID Button"
elif [ "$reset_cause" == "ewt0" ] || [ "$reset_cause" == "wdt0" ]; then
  reset_cause="watchdog"
elif [ "$reset_cause" == "board" ]; then
   if [ -e /mmc1/lclspi_mount_failed ]; then
	reset_cause="LCL SPI FS Recovery"
	rm -f /mmc1/lclspi_mount_failed
   elif [ -e /mmc1/fpspi_mount_failed ]; then
	reset_cause="FP SPI FS Recovery"
	rm -f /mmc1/fpspi_mount_failed
   else
	reset_cause="user initiated"
   fi
elif [ "$reset_cause" == "NMI" ]; then
  reset_cause="core"
fi
string1=$(echo -n $reset_cause | hexdump -e '32/1 "%02x "')
#echo $string1
string2=$(echo $string1 | awk 'NR==1{printf "%02x %s %s",NF+2,$0,"00 00"}')
#echo $string2
command="IPMICmd 20 30 0 aa 03 52 41 43 00 30 31 38 32"
fullcommand="$command $string2"
status=$($fullcommand)
