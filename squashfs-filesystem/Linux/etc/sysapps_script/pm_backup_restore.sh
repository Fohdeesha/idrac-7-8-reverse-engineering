#!/bin/sh
source /etc/sysapps_script/pm_logger.sh
PM_DEST_FILE="/tmp/pm_backup.tgz"
PM_PTN=/tmp/pmmount
FLAG_DIR=/flash/data0/oem_ps
PM_BACKUP=0
PM_RESTORE=0
EXIT_CODE=0
PM_BACKUP_FRU=0
show_usage() 
{
	echo "Usage: `basename $0` -b "
	echo "       `basename $0` -r "
	echo "       `basename $0` -f <Fru file name to backup> "

}
#mount mas026
mount_pm_ptn1()
{
	res=`mount|grep ${PM_PTN}`
	if [ -z "$res" ] ; then
		if [ ! -d ${PM_PTN} ] ; then
			mkdir ${PM_PTN}
			echo "Creating pmmount dir "
		fi
		echo "mounting : /mmc1/mas026.img ${PM_PTN}"
		/etc/sysapps_script/mountMaser.sh /mmc1/mas026.img ${PM_PTN} /tmp/mountresult
		if [ $? -ne 0 ]	
		then
				return 1
		fi
	else
		echo "Already mounted"
	fi
	return 0
}
#unmount mas026
unmount_pm_ptn1()
{
	sync
	echo "unmounting : ${PM_PTN}"
	umount ${PM_PTN}
	rmdir ${PM_PTN}
}

pm_backup()
{
	#mount mas026 partition on /tmp/pmmount
	mount_pm_ptn1
	if [ $? -ne 0 ]	
	then
		debug_log "PM Backup Restore : mas026 mount failed !"
		EXIT_CODE=3	  		
	else
		echo "mount successful "
		#create zipped pm package 
		echo "creating $PM_DEST_FILE"
		tar cjf $PM_DEST_FILE ${PM_PTN}
		FILESIZE=$(stat -c%s "$PM_DEST_FILE")
		if [ "$FILESIZE" -gt 500000 ]
		then
			debug_log "PM Backup Restore : Backup file size is greater than 500KB.Deleting backup file. !"
			rm -f $PM_DEST_FILE
			EXIT_CODE=4
		fi
	#unmount mas026 partition
	unmount_pm_ptn1
	fi
	return $EXIT_CODE
}

pm_restore()
{
	mount_pm_ptn1
	if [ $? -ne 0 ]	
	then
		debug_log "PM Backup Restore : mas026 mount failed !"
		EXIT_CODE=3	 
	else
		cp $PM_PTN $PM_PTN.org
		echo "Extracting $PM_DEST_FILE....." 
		tar xjf $PM_DEST_FILE -C /
		if [ $? -eq 0 ]	# Check if file unzipped successfully
		then
						
			echo "Restore PM in Progress....."
			echo "fffffffffffffffffffffffffffffffe" > ${FLAG_DIR}/pm_update_available
			cp -a ${PM_PTN}/pm/pm_info ${FLAG_DIR}/
			
			/etc/sysapps_script/persmod_setup.sh install
			if [ $? -ne 0 ]	
			then
				echo "Restore PM Failed....."
				cp -r  $PM_PTN.org/* $PM_PTN/
				
			else
				echo "Restore PM Completed,iDRAC reset needed"
				
			fi
			
		else
			debug_log "PM Backup Restore : Can't Restore PM, Unzip $PM_DEST_FILE failed !"
			cp -r  $PM_PTN.org/* $PM_PTN/
			EXIT_CODE=5
		fi
		rm  -rf $PM_PTN.org		#remove temp backup
		unmount_pm_ptn1
	fi
	return $EXIT_CODE
}

fru_backup()
{
	debug_log "PM Backup Restore: Executing Fru backup "
	if [ -f $1 ] ;  then
		mount_pm_ptn1
		debug_log "PM Backup Restore: Copying $1 to $PM_PTN/pm/idrac "
		cp -f $1 $PM_PTN/pm/idrac/InitFRUInfo
		cp -f $1 /flash/data0/persmod/InitFRUInfo
		unmount_pm_ptn1
		pm_backup
		if [ $? -eq 0 ]	; then
			debug_log "PM Backup Restore: Taking PM Backup! "
			exec_ipmi_cmd "IPMICmd 20 30 0 d0 0 15 10 0 0 0 10 0 0 0 10 0 0 0 0 0 0 0 0 0 0 0" 221
			ret_val=$?
			if [ $ret_val -eq 0 ] ; then
				debug_log "PM Install : PM Backup Completed!"
			else
				debug_log "PM Install : PM Backup Failed!"
			fi
		fi
		rm -f $1
	fi
}


if [ $# -eq 0 ]
then
	show_usage
	exit 1
fi

while getopts "h?brf:" opt; do
	case "$opt" in
		h|\?)
		show_usage
		exit 0
		;;
	b)
		PM_BACKUP=1
		;;
	r)
		PM_RESTORE=1
		;;
	f)
		PM_BACKUP_FRU=1
		PM_FRU_FILE=$OPTARG
		;;
	esac
done

if [ $PM_BACKUP -eq 1 ] && [ $PM_RESTORE -eq 1 ];then
	echo "Error: Only one of -b or -r may be specified"
	exit 2
elif [ $PM_BACKUP_FRU -eq 1 ];then
	fru_backup $PM_FRU_FILE
	
elif [ $PM_BACKUP -eq 1 ] ;then
	pm_backup

elif [ $PM_RESTORE -eq 1 ] ;then
	pm_restore
else
	echo "Error: One of -b or -r must be specified"
	EXIT_CODE=4
fi

exit $EXIT_CODE
