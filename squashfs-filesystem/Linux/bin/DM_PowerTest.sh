#!/bin/sh

#Local Variables
lpath=`pwd`
llogpath=/tmp/DM_PowerTest.log

clear
echo ""
echo "************************************************************************************"
echo "**************** This script logs the DM power data used by GUI ********************"
echo "************************** into DM_PowerTest.log  **********************************"
echo "************************************************************************************"
echo ""


#delete existing log file if present

delete_logfile_ifpresent()
{
	echo "Checking for file 'DM_PowerTest.log' if present ..."
	if [[ -f $llogpath ]]; then
	echo "Deleting 'DM_PowerTest.log' ..."
	rm -rf DM_PowerTest.log
	fi
}

#check and remove existing log file
delete_logfile_ifpresent

echo "Logging ..."


printf "************************************************************************************\n" >> $llogpath
printf "******************************** DM Power Data Logs ********************************\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath
printf "\n" >> $llogpath

printf "************************************************************************************\n" >> $llogpath
printf "******************************** NM Recovery Check *********************************\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "IPMICmd 20 2e 0 e1 2 18 1\n" >> $llogpath
IPMICmd 20 2e 0 e1 2 18 1 >> $llogpath
printf "\n" >> $llogpath

printf "\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf " Power Supply Obj(0x15) \n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath

dcetst32 command=oidview objtype=15 xmlbody=true  >> $llogpath

printf "\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf " Power Consumption Obj(0x28) \n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath

dcetst32 command=oidview objtype=28 xmlbody=true  >> $llogpath

printf "\n" >> $llogpath
printf "************************************************************************************\n"  >> $llogpath
printf " Power Consumption Statistics Obj(0x4b) \n" >> $llogpath
printf "************************************************************************************\n"  >> $llogpath
printf "\n" >> $llogpath

dcetst32 command=oidview objtype=4b xmlbody=true  >> $llogpath

printf "\n" >> $llogpath
printf "************************************************************************************\n"  >> $llogpath
printf " Server Power Group (0x4330) \n" >> $llogpath
printf "************************************************************************************\n"  >> $llogpath
printf "\n" >> $llogpath

dcetst32 command=datest daname=dceda omacmd=getchildlist ons="Root/MainSystemChassis/RACConfigRoot:1/RACServerPwr"  >>$llogpath

printf "\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf " Server Topology Group (0x4331) \n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath
dcetst32 command=datest daname=dceda omacmd=getchildlist ons="Root/MainSystemChassis/RACConfigRoot:1/ServerTopology"  >>$llogpath

printf "\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf " Voltage Objects (0x18) \n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath
dcetst32 command=oidview objtype=18 xmlbody=true  >> $llogpath

printf "\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf " Current Probes (0x19) \n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath

dcetst32 command=oidview objtype=19 xmlbody=true  >> $llogpath

printf "\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf " Redundancy Objects (0x2) \n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath
dcetst32 command=oidview objtype=2 xmlbody=true  >> $llogpath

printf "\n\n\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf " Power Shared Memory Data \n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath

printf "\n" >> $llogpath
printf "***** POWER CONFIG SECTION ***** \n" >> $llogpath
shmread -s5 -o0 -l200  >> $llogpath
printf "\n" >> $llogpath

printf "***** POWER REPORTING SECTION ***** \n" >> $llogpath
shmread -s6 -o0 -l200  >> $llogpath
printf "\n" >> $llogpath

printf "***** POWER CONFIG CLEAR SECTION ***** \n" >> $llogpath
shmread -s8 -o0 -l200  >> $llogpath
printf "\n" >> $llogpath

printf "***** POWER TOPOLOGY SECTION ***** \n" >> $llogpath
shmread -s9 -o0 -l600  >> $llogpath
printf "\n" >> $llogpath

printf "***** POWER SUPPLY SECTION ***** \n" >> $llogpath
shmread -s7 -o0 -l300  >> $llogpath
printf "\n" >> $llogpath

printf "\n\n\n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf " Config Lib Data \n" >> $llogpath
printf "************************************************************************************\n" >> $llogpath
printf "\n" >> $llogpath

printf " ***** POWER CONFIG SECTION ***** \n" >> $llogpath
readcfg -g17200 >> $llogpath
printf "\n" >> $llogpath

printf " ***** POWER CONFIG CLEAR SECTION ***** \n" >> $llogpath
readcfg -g20000 >> $llogpath
printf "\n" >> $llogpath

printf " ***** POWER TOPOLOGY SECTION ***** \n" >> $llogpath
readcfg -g17201 >> $llogpath
printf "\n" >> $llogpath

echo ""
echo "************************************************************************************"
echo "******************************* Script Ends **************************************** "
echo "************************************************************************************"
echo ""
exit 0
