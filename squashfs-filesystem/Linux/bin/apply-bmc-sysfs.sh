#!/bin/sh
BMCSETTING_FILE=/flash/data0/BMC_Data/drvsetting.dat
SYSFS_FOLDER=/sys/bus/platform/drivers

for DEV_INDEX in `egrep -n  "\[aess_.*drv\]" ${BMCSETTING_FILE} | sed -r -e 's/([0~9]*):.*/\1 /'`
do
	Drv_Name=`sed -n "${DEV_INDEX}p" ${BMCSETTING_FILE} | sed -n -r -e  "s/\[(aess_.*drv)\]/\1/p" `
	#echo "Drv_Name=${Drv_Name}"	
	
	# Make sure there is end statement
	if ! egrep -q -n "${Drv_Name}_End" ${BMCSETTING_FILE} > /dev/null 
	then
        	echo "[${Drv_Name}] section without end statement!!!" ;  exit 
	fi 

	End_Line=`egrep -n "${Drv_Name}_End" ${BMCSETTING_FILE} | sed -n -r -e "s/([0~9]*):.*/\1/p"` 
	Start_Line=${DEV_INDEX} 
	Start_Line=$((Start_Line+1)) 

	#echo "---${Start_Line}---${End_Line}--"
	while [ ${End_Line} -gt ${Start_Line} ]
	do 	
		#echo "Start=${Start_line},End=${End_Line}" 
		Target=`sed -n "${Start_Line}p" ${BMCSETTING_FILE} | sed -n -r -e 's/(.*)=\"(.*)\"/\1/p'` 
		Value=`sed -n "${Start_Line}p" ${BMCSETTING_FILE} | sed -n -r -e 's/(.*)=\"(.*)\"/\2/p'` 
		#echo " echo ${Value} > ${SYSFS_FOLDER}/${Drv_Name}/${Target}" 
		echo ${Value} > ${SYSFS_FOLDER}/${Drv_Name}/${Target} 
		Start_Line=$((Start_Line+1)) 
	done
done 
