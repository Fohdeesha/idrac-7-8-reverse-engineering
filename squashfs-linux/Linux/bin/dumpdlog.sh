#!/bin/sh
set +x
#echo -e "dumpdlog pid $$"

#nice
#echo "Reduce script scheduling priority "
renice -n +19 -p $$
#nice
echo -e "\nStart dumping iDRAC logs\n"

echo -e "iDRAC Uptime..\n"
uptime
date
echo ""
echo -e "\niDRAC Version Info...\n"
cat /etc/fw_ver
echo -e "\niDRAC System ID...\n"
cat /flash/data0/features/system-id
echo -e "\niDRAC System Name...\n"
cat /flash/data0/features/system-name
echo -e "\nKernel Command Line...\n"
cat /proc/cmdline
echo -e "\niDRAC Reset Cause...\n"
cat /proc/cmdline | awk  '{print $12}'
echo -e "\nTotal Processes.. \n"
ps | wc -l
echo -e "\nTotal Threads.. \n"
ps -T | wc -l
echo -e "\nMemory Information.. \n"
cat /proc/meminfo
echo -e "\n"
df -h
echo -e "\nMount Information.. \n"
mount
echo -e "\nLoop Devices.. \n"
losetup
echo -e "\n"
ps -wl | grep -v "UnpackAndShare" | grep -v "DownloadISOImage" | grep -v "DownloadISOToVFlash" \
           | grep -v "BootTONetworkISOImage" | grep -v "ConfigurableBootTONetworkISOImage" \
           | grep -v "ConnectNetworkISOImage" | grep -v "ConnectRFSISOImage"
echo -e "\nCore files.. \n"
ls -ls /mnt/cores/
echo -e "\nKernel Logs.. \n"
dmesg
echo -e "\niDRAC logs.. \n"
cat /tmp/idraclogs
echo -e "\nJournal logs.. \n"
nice -n +19 journalctl --no-pager
echo -e "\n ls -lsSh /tmp\n"
ls -lsSh /tmp/
echo -e "\nNetwork interfaces  \n"
ifconfig
echo ""
ifplugstatus
echo -e "\nDM Populator Start Stop logs  \n"
cat /tmp/dmpopstartstop.log
echo ""
cat /tmp/dmpopstartstop.log.1
echo -e "\n iDRAC Processes CPU Consumption..\n"
top -n 5 -d 2
echo -e "\n iDRAC Processes Memory Consumption..\n"
top -n 3 -d 2 -m
echo -e "\niDRAC Dump log operation completed\n"
