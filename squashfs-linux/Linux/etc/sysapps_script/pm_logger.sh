#!/bin/sh

export PM_DEBUG_LOG=/flash/data0/oem_ps/pm_debug.log

debug_log()
{
	FILESIZE=$(stat -c%s "$PM_DEBUG_LOG")
	if [ ! -f $PM_DEBUG_LOG ] ; then
		touch ${PM_DEBUG_LOG}	
	fi
	if [ "$FILESIZE" -gt 4000 ]
	then
        echo "Backup file size is greater than 4KB.Deleting backup file."
        rm -f $PM_DEBUG_LOG
        echo "PM Debug log : Restarted" > ${PM_DEBUG_LOG}
	fi
	echo " [`date`] : $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" >> ${PM_DEBUG_LOG}
}
      
# b $1 : IPMI commad to execute
# $2 : return value if IPMICmd command fails.
# Return 0 if IPMICmd success. 
exec_ipmi_cmd()
{
	FULL_CMD=$1
	RET1=`$FULL_CMD`
	echo $RET1
	RET1=`echo $RET1 | cut -c 35-37`
	if [ $RET1 != "00" ]; then
		debug_log "IPMICmd Failed : Cmd Num, $2   $FULL_CMD Return Value $RET1! "
		return $2
	fi
#	debug_log "IPMICmd Suc : Cmd num, $2 $FULL_CMD Return Value $RET1! " 
	return 0
	
}

# Fun to log exit code in LC log messages.
check_for_errors()
{
	# $1 : Error Code
	if [ $# -ne 1 ] 
	then
		debug_log "check_for_errors : Only one argument supported"
		return
	 fi		
	EXIT_STATUS=$1
	if [ $EXIT_STATUS -ne 0 ]
	then
		if [ $EXIT_STATUS -gt 0 ] && [ $EXIT_STATUS -le 32 ]; then
			debug_log "PM Install Failed with ERROR_CODE $EXIT_STATUS"
			echo "PM Install Failed with ERROR_CODE $EXIT_STATUS"
		elif [ $EXIT_STATUS -gt 32 ] && [ $EXIT_STATUS -lt 256 ]; then 
			debug_log "PM Install Completed with ERROR $EXIT_STATUS"
			echo "PM Install Completed with ERROR $EXIT_STATUS"
		else
			debug_log "PM Install Completed with UNKNOWN ERROR_CODE $EXIT_STATUS"
			echo "PM Install Completed with UNKNOWN ERROR_CODE $EXIT_STATUS"
		fi
	else
		debug_log "PM Install Completed Successfully"
		echo "PM Install Completed Successfully"
	fi	
	pmutil command=lclog errorcode=$EXIT_STATUS
	ret_val=$?
	if [ $ret_val -ne 0 ] ; then
		debug_log "LC logging failed with ERROR CODE $ret_val"
	fi
}
