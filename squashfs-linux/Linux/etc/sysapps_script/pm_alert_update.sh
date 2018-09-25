#!/bin/sh
# This Parses the alertoem.conf file at the location specified by PM_ALERT_CONF
# The structure of PM_ALERT_CONF is as follows
#
# OEMPEFAlertEnable=
# OEMIPV4AlertIPAddr1=
# OEMIPV4IPAddr1Enable=
# OEMIPV4AlertIPAddr2=
# OEMIPV4IPAddr2Enable=
# OEMIPV4AlertIPAddr3=
# OEMIPV4IPAddr3Enable=
# OEMIPV4AlertIPAddr4=
# OEMIPV4IPAddr4Enable=
# OEMAlertCommunityString=
#
# If the above format changes, please change the file parsing suitably

# OEMPEFAlertEnable - Platform Event Filter (PEF) Alerts. Accepts the following
# 0 - Disable PEF
# 1 - Enable PEF

# OEMIPV4AlertIPAddr1, OEMIPV4AlertIPAddr2, OEMIPV4AlertIPAddr3, OEMIPV4AlertIPAddr4
#  - Controls the IPV4 Alert Trap Settings. Accepts IPv4 Address in DOTTED DECIMAL NOTATION ONLY

# OEMIPV4IPAddr1Enable, OEMIPV4IPAddr2Enable, OEMIPV4IPAddr3Enable, OEMIPV4IPAddr4Enable
# - controls the respective alert destinations. Accepts the following
# 0 - Disables it
# 1 - Enables it

# OEMAlertCommunityString -controls the Community String Setting. Accpets a maximum of 18 characters between quotes

# Return Values
# This script returns a 9 byte mask. 
# 0 in the byte position 'm' denotes the success of 'm'th command
# 1 in the byte position 'm' denotes the failure of 'm'th command

# Byte Postion Discription for return values
# 0 - Enable / Disable PEF Alerts (LSB)
# 1 - Set IPV4 Address for Alert 1
# 2 - Set IPV4 Address for Alert 2
# 3 - Set IPV4 Address for Alert 3
# 4 - Set IPV4 Address for Alert 4
# 5 - Enable / Disable IPV4 Alert 1
# 6 - Enable / Disable IPV4 Alert 2
# 7 - Enable / Disable IPV4 Alert 3
# 8 - Enable / Disable IPV4 Alert 4
# 9 - Set Community String (MSB)

# Example return Values
# 1001001000
# - Set IPV4 Address for Alert 3 Failed, and
# - Enable / Disable IPV4 Alert 2 Failed, and
# - Set Community String Failed

PM_ALERT_CONF=/flash/data0/persmod/alertoem.conf
source /etc/sysapps_script/pm_logger.sh
# EXIT_CODE : Allocated Exit codes 161 to 190 for this File.
EXIT_CODE=0
COMM_STR_MAX=18
if [ -f $PM_ALERT_CONF ] ; then

        USR_INP=`awk -F "=" '/OEMPEFAlertEnable/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                
                if [ $(($USR_INP)) -ne 1 ]; then
                        RET01=`IPMICmd 20 06 00 40 01 7a 04`
                        RET02=`IPMICmd 20 06 00 40 01 ba 04`
                else

                        RET01=`IPMICmd 20 06 00 40 01 5a 04`
                        RET02=`IPMICmd 20 06 00 40 01 9a 04`
                fi
                        RET01=`echo $RET01 | cut -c 35-37`
                        RET02=`echo $RET02 | cut -c 35-37`

                        if [[ $RET01 != "00" -o $RET02 != "00" ]]; then
                                EXIT_CODE=161
                        fi
        fi

        USR_INP=`awk -F "=" '/OEMIPV4AlertIPAddr1/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                RET1=0
                IP_OCT1=`echo $USR_INP | awk -F. '{print $1}'`
                IP_OCT1=$(printf "%x\n" $IP_OCT1)
                IP_OCT2=`echo $USR_INP | awk -F. '{print $2}'`
                IP_OCT2=$(printf "%x\n" $IP_OCT2)
                IP_OCT3=`echo $USR_INP | awk -F. '{print $3}'`
                IP_OCT3=$(printf "%x\n" $IP_OCT3)
                IP_OCT4=`echo $USR_INP | awk -F. '{print $4}'`
                IP_OCT4=$(printf "%x\n" $IP_OCT4)
                exec_ipmi_cmd "IPMICmd 20 0c 00 01 01 13 01 00 00 $IP_OCT1 $IP_OCT2 $IP_OCT3 $IP_OCT4 00 00 00 00 00 00" 162
				ret_val=$?
				if [ $ret_val -ne 0 ] ; then
					EXIT_CODE=$ret_val
				fi
                
        fi
        USR_INP=`awk -F "=" '/OEMIPV4AlertIPAddr2/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                RET2=0
                IP_OCT1=`echo $USR_INP | awk -F. '{print $1}'`
                IP_OCT1=$(printf "%x\n" $IP_OCT1)
                IP_OCT2=`echo $USR_INP | awk -F. '{print $2}'`
                IP_OCT2=$(printf "%x\n" $IP_OCT2)
                IP_OCT3=`echo $USR_INP | awk -F. '{print $3}'`
                IP_OCT3=$(printf "%x\n" $IP_OCT3)
                IP_OCT4=`echo $USR_INP | awk -F. '{print $4}'`
                IP_OCT4=$(printf "%x\n" $IP_OCT4)
                exec_ipmi_cmd "IPMICmd 20 0c 00 01 01 13 02 00 00 $IP_OCT1 $IP_OCT2 $IP_OCT3 $IP_OCT4 00 00 00 00 00 00" 163
                ret_val=$?
				if [ $ret_val -ne 0 ] ; then
					EXIT_CODE=$ret_val
				fi
                
        fi
        USR_INP=`awk -F "=" '/OEMIPV4AlertIPAddr3/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                RET3=0
                IP_OCT1=`echo $USR_INP | awk -F. '{print $1}'`
                IP_OCT1=$(printf "%x\n" $IP_OCT1)
                IP_OCT2=`echo $USR_INP | awk -F. '{print $2}'`
                IP_OCT2=$(printf "%x\n" $IP_OCT2)
                IP_OCT3=`echo $USR_INP | awk -F. '{print $3}'`
                IP_OCT3=$(printf "%x\n" $IP_OCT3)
                IP_OCT4=`echo $USR_INP | awk -F. '{print $4}'`
                IP_OCT4=$(printf "%x\n" $IP_OCT4)
                exec_ipmi_cmd "IPMICmd 20 0c 00 01 01 13 03 00 00 $IP_OCT1 $IP_OCT2 $IP_OCT3 $IP_OCT4 00 00 00 00 00 00" 164
                ret_val=$?
				if [ $ret_val -ne 0 ] ; then
					EXIT_CODE=$ret_val
				fi
                
        fi
        USR_INP=`awk -F "=" '/OEMIPV4AlertIPAddr4/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                RET4=0
                IP_OCT1=`echo $USR_INP | awk -F. '{print $1}'`
                IP_OCT1=$(printf "%x\n" $IP_OCT1)
                IP_OCT2=`echo $USR_INP | awk -F. '{print $2}'`
                IP_OCT2=$(printf "%x\n" $IP_OCT2)
                IP_OCT3=`echo $USR_INP | awk -F. '{print $3}'`
                IP_OCT3=$(printf "%x\n" $IP_OCT3)
                IP_OCT4=`echo $USR_INP | awk -F. '{print $4}'`
                IP_OCT4=$(printf "%x\n" $IP_OCT4)
                exec_ipmi_cmd "IPMICmd 20 0c 00 01 01 13 04 00 00 $IP_OCT1 $IP_OCT2 $IP_OCT3 $IP_OCT4 00 00 00 00 00 00" 165
                ret_val=$?
				if [ $ret_val -ne 0 ] ; then
					EXIT_CODE=$ret_val
				fi
              
        fi

        USR_INP=`awk -F "=" '/OEMIPV4IPAddr1Enable/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                RET5=0
                if [ $(($USR_INP)) -ne 1 ]; then
                        exec_ipmi_cmd "IPMICmd 20 04 00 12 09 01 10 11 00" 166
						ret_val=$?
						if [ $ret_val -ne 0 ] ; then
							EXIT_CODE=$ret_val
						fi
                else
                       	exec_ipmi_cmd "IPMICmd 20 04 00 12 09 01 18 11 00" 167
						ret_val=$?
						if [ $ret_val -ne 0 ] ; then
							EXIT_CODE=$ret_val
						fi
                fi
                        
        fi
        USR_INP=`awk -F "=" '/OEMIPV4IPAddr2Enable/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                RET6=0
                if [ $(($USR_INP)) -ne 1 ]; then
                        exec_ipmi_cmd "IPMICmd 20 04 00 12 09 02 10 11 00" 168
						ret_val=$?
						if [ $ret_val -ne 0 ] ; then
							EXIT_CODE=$ret_val
						fi
                else
                        exec_ipmi_cmd "IPMICmd 20 04 00 12 09 02 18 11 00" 169
						ret_val=$?
						if [ $ret_val -ne 0 ] ; then
							EXIT_CODE=$ret_val
						fi
                fi
                        
        fi
        USR_INP=`awk -F "=" '/OEMIPV4IPAddr3Enable/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                RET7=0
                if [ $(($USR_INP)) -ne 1 ]; then
                        exec_ipmi_cmd "IPMICmd 20 04 00 12 09 03 10 11 00" 170
						ret_val=$?
						if [ $ret_val -ne 0 ] ; then
							EXIT_CODE=$ret_val
						fi
                else
                        exec_ipmi_cmd "IPMICmd 20 04 00 12 09 03 18 11 00" 171
						ret_val=$?
						if [ $ret_val -ne 0 ] ; then
							EXIT_CODE=$ret_val
						fi
                fi
                        
        fi
        USR_INP=`awk -F "=" '/OEMIPV4IPAddr4Enable/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
                RET8=0
                if [ $(($USR_INP)) -ne 1 ]; then
                        exec_ipmi_cmd "IPMICmd 20 04 00 12 09 04 10 11 00" 172
						ret_val=$?
						if [ $ret_val -ne 0 ] ; then
							EXIT_CODE=$ret_val
						fi
                else
                       	exec_ipmi_cmd "IPMICmd 20 04 00 12 09 04 18 11 00" 173
						ret_val=$?
						if [ $ret_val -ne 0 ] ; then
							EXIT_CODE=$ret_val
						fi
                fi
                        
        fi
        COMM_STR=`awk -F "=" '/OEMAlertCommunityString/{print $2}' $PM_ALERT_CONF | tr -d '"'`
        if [ -n "$COMM_STR" ]; then
                
                COMM_STR_LEN=${#COMM_STR}
                # Community String supports only 18 Characters.
                # So trim it, if it exceeds 18.
                if [ $COMM_STR_LEN -gt $COMM_STR_MAX ]; then
                        COMM_STR=`echo $COMM_STR | cut -c -$COMM_STR_MAX`
                        COMM_STR_LEN=${#COMM_STR}
                fi
                COMM_STR=`echo $COMM_STR | hexdump -v -e ' 1/1 "%02X" " "'`
                TRIM=$((${#COMM_STR}-3))
                COMM_STR=`echo $COMM_STR | cut -c -$TRIM`

                i=$COMM_STR_LEN;
                while [[ $i -lt "$COMM_STR_MAX" ]]
                do
                        COMM_STR=$COMM_STR" 00"
                        i=$(($i+1))
                done
                exec_ipmi_cmd "IPMICmd 20 0c 00 01 01 10 $COMM_STR" 174
				ret_val=$?
				if [ $ret_val -ne 0 ] ; then
					EXIT_CODE=$ret_val
				fi
                
        fi
fi

echo $EXIT_CODE
return $EXIT_CODE
