#!/bin/sh

PM_RE_CONF=/flash/data0/persmod/reoem.conf
source /etc/sysapps_script/pm_logger.sh
# EXIT_CODE : Allocated Exit codes 101 to 130 for this File.
EXIT_CODE=0	
AUTO_DISC_DISABLED=0
LINE_LEN=28
INP_MAX=255

usrstr() {
	# REOEMProvisioningServer="Pick the String between Quotes"
	USR_INP=`awk -F "=" '/REOEMProvisioningServer/{print $2}' $1 | tr -d '"'`
	USR_LEN=${#USR_INP}
	# It supports only 255 Characters for Provisioning Server 
	# So trim it, if it exceeds 255.
	if [ $USR_LEN -gt $INP_MAX ]; then
		USR_INP=`echo $USR_INP | cut -c -$INP_MAX`
		USR_LEN=${#USR_INP}
	fi
	USR_LEN_HEX=$(printf "%x\n" $USR_LEN)

	if [ -n "$USR_LEN" ]; then

		CMD_PART="IPMICmd 0x20 0x30 0x00 0xa3 0x07"
		exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xa3 0x07 0x00 0x01 $USR_LEN_HEX" 101
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
		
		STR_END_POINT=0
		USR_STR_OFF=1
		while [[ $USR_LEN -gt $STR_END_POINT ]]; do

			STR_START_POINT=$(($STR_END_POINT+1))
			NEXT_END_POINT=$(($STR_END_POINT+$LINE_LEN))

			if [ $USR_LEN -lt $NEXT_END_POINT ]; then
				
				USR_STR=`echo $USR_INP | cut -c $STR_START_POINT-$USR_LEN | hexdump -v -e ' 1/1 "%02X" " "'`
			else
				USR_STR=`echo $USR_INP | cut -c $STR_START_POINT-$NEXT_END_POINT | hexdump -v -e ' 1/1 "%02X" " "'`
			fi

			STR_END_POINT=$NEXT_END_POINT

			TRIM=$((${#USR_STR}-3))
			USR_STR=`echo $USR_STR | cut -c -$TRIM`
			USR_STR_LEN=${#USR_STR}
			USR_STR_LEN=$(($USR_STR_LEN+1))
			USR_STR_LEN_FIN=$(($USR_STR_LEN/3))
			USR_STR_LEN_FIN_HEX=$(printf "%x\n" $USR_STR_LEN_FIN)
			USR_STR_OFF_HEX=$(printf "%x\n" $USR_STR_OFF)

			FULL_CMD=$CMD_PART" ""0x"$USR_STR_OFF_HEX" "$USR_STR_LEN_FIN_HEX" "$USR_STR
			exec_ipmi_cmd "$FULL_CMD" 102
			ret_val=$?
			if [ $ret_val -ne 0 ] ; then
				EXIT_CODE=$ret_val
			fi
			
			USR_STR_OFF=$(($USR_STR_OFF+$LINE_LEN))
		done
	fi
}

if [ -f $PM_RE_CONF ] ; then

	usrstr $PM_RE_CONF
	
	REAUTODISC=`awk -F "=" '/REOEMAutoDiscovery/{print $2}' $PM_RE_CONF`

	if [ $(($REAUTODISC)) -ne 1 ]; then
		REAUTODISC=$AUTO_DISC_DISABLED
	fi

	FULL_CMD="IPMICmd 0x20 0x30 0x00 0xa3 0x01 ""0x"$REAUTODISC
	exec_ipmi_cmd "$FULL_CMD" 103
	ret_val=$?
	if [ $ret_val -ne 0 ] ; then
		EXIT_CODE=$ret_val
	fi
	

else
	EXIT_CODE=104
fi
echo $EXIT_CODE
return $EXIT_CODE
