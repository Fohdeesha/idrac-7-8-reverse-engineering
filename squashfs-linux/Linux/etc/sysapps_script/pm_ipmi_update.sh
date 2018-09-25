#!/bin/sh
# This Parses the ipmioem.conf file at the location specified by PM_IPMI_CONF
# The structure of PM_ALERT_CONF is as follows
#
# OEMIpmiOverLanEnable=
# OEMVflashEnable=
# OEMFrontPanelEnable=
#
# If the above format changes, please change the file parsing suitably

# OEMIpmiOverLanEnable - Accepts the following
# 0 - Disable IPMI Over LAN
# 1 - Enable IPMI Over LAN
# 
# OEMVflashEnable - Accepts the following
# 0 - Disable VFlash
# 1 - Enable VFlash
#
# OEMFrontPanelAccess - Accepts the following
# 0 - Front Panel full access
# 1 - Front Panel view-only
# 2 - Front Panel locked 
#
# Return Values
# This script returns a 9 byte mask. 
# 0 in the byte position 'm' denotes the success of 'm'th command
# 1 in the byte position 'm' denotes the failure of 'm'th command

# Byte Postion Discription for return values
# 0 - Enable / Disable IPMI over LAN (LSB)
# 1 - Enable / Disable Vflash 
# 2 - Enable / Disable Front Panel


# Example return Values
# 001
# - Enable / Disable IPMI over LAN Failed

source /etc/sysapps_script/pm_logger.sh
PM_IPMI_CONF=/flash/data0/persmod/ipmioem.conf
# EXIT_CODE : Allocated Exit codes 191 to 220 for this File.
EXIT_CODE=0
RET0=0
RET1=0
RET2=0

if [ -f $PM_IPMI_CONF ] ; then

        USR_INP=`awk -F "=" '/OEMIpmiOverLanEnable/{print $2}' $PM_IPMI_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
		RET01="00"
		RET02="00"
		NonVolatileStore=40
		VolatileStore=80
		EnableIPMIOverLan=02
		DisableIPMIOverLan=f8
		
		#get current volatile and non-volatile settings so that we dont overwrite
		RET03=`IPMICmd 20 06 00 41 01 40`
		RET04=`IPMICmd 20 06 00 41 01 80`

                RET05=`echo $RET03 | cut -c 35-37`		#byte1 non-volatile (completion code)	
                RET06=`echo $RET04 | cut -c 35-37`		#byte1 volatile (completion code)

                if [[ $RET05 != "00" -o $RET06 != "00" ]]; then
			echo "OEMIpmiOverLanEnable: IPMICmd did not return SUCCESS"
					debug_log "IPMICmd Failed : OEMIpmiOverLanEnable Failed "
                        EXIT_CODE=191
						
                else
                	RET07=`echo $RET03 | cut -c 40-41`	#byte2 non-volatile (channel access)
                	RET08=`echo $RET04 | cut -c 40-41`	#byte2 volatile (channel access)

			CurrNonVolatileSetting=$((0x$RET07&0x07))
			CurrVolatileSetting=$((0x$RET08&0x07))

                	if [[ $USR_INP == 1 ]]; then
				#send enable ipmi cmd only when current setting is NOT enabled
                        	if [[ $CurrNonVolatileSetting != 2 ]]; then
					EnableNonVolatile=$(((0x$NonVolatileStore|0x$RET07)|0x$EnableIPMIOverLan))
					EnableNonVolatile=$(printf "%x\n" $EnableNonVolatile)
                        		RET01=`IPMICmd 20 06 00 40 01 $EnableNonVolatile 04`
                        		RET01=`echo $RET01 | cut -c 35-37`
                        	fi

                        	if [[ $CurrVolatileSetting != 2 ]]; then
					EnableVolatile=$(((0x$VolatileStore|0x$RET08)|0x$EnableIPMIOverLan))
					EnableVolatile=$(printf "%x\n" $EnableVolatile)
                        		RET02=`IPMICmd 20 06 00 40 01 $EnableVolatile 04`
                        		RET02=`echo $RET02 | cut -c 35-37`
                        	fi
                	elif [[ $USR_INP == 0 ]]; then
				#send disable ipmi cmd only when current setting is NOT disable
                        	if [[ $CurrNonVolatileSetting != 0 ]]; then
					DisableNonVolatile=$(((0x$NonVolatileStore|0x$RET07)&0x$DisableIPMIOverLan))
					DisableNonVolatile=$(printf "%x\n" $DisableNonVolatile)
                        		RET01=`IPMICmd 20 06 00 40 01 $DisableNonVolatile 04`
                        		RET01=`echo $RET01 | cut -c 35-37`
                        	fi

                        	if [[ $CurrVolatileSetting != 0 ]]; then
					DisableVolatile=$(((0x$VolatileStore|0x$RET08)&0x$DisableIPMIOverLan))
					DisableVolatile=$(printf "%x\n" $DisableVolatile)
                        		RET02=`IPMICmd 20 06 00 40 01 $DisableVolatile 04`
                        		RET02=`echo $RET02 | cut -c 35-37`
                        	fi
			else
				echo "Error! Unknown setting for OEMIpmiOverLanEnable."
				
				EXIT_CODE=192
                	fi

                        if [[ $RET01 != "00" -o $RET02 != "00" ]]; then
				echo "OEMIpmiOverLanEnable: IPMICmd did not return SUCCESS"
							debug_log "IPMICmd Failed : OEMIpmiOverLanEnable Failed "
                                EXIT_CODE=193
                        fi
		fi
        fi

        USR_INP=`awk -F "=" '/OEMVflashEnable/{print $2}' $PM_IPMI_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
		RET01="00"

                if [[ $USR_INP == 1 ]]; then
                        RET01=`IPMICmd 20 30 00 A4 01 01 00 00`
                        RET01=`echo $RET01 | cut -c 35-37`
                elif [[ $USR_INP == 0 ]]; then
                        RET01=`IPMICmd 20 30 00 A4 01 00 00 00`
                        RET01=`echo $RET01 | cut -c 35-37`
		else
			echo "Error! Unknown setting for OEMVflashEnable."
			EXIT_CODE=194
                fi

                if [[ $RET01 != "00" ]]; then
			echo "OEMVflashEnable: IPMICmd did not return SUCCESS"
					debug_log "IPMICmd Failed : OEMVflashEnable Failed " 
                    EXIT_CODE=195
                fi
        fi

        USR_INP=`awk -F "=" '/OEMFrontPanelAccess/{print $2}' $PM_IPMI_CONF | tr -d '"'`
        if [ -n "$USR_INP" ]; then
		RET01="00"

                if [[ $USR_INP == 0 ]]; then
                        RET01=`IPMICmd 20 06 00 58 e7 00 00 00 00`
                        RET01=`echo $RET01 | cut -c 35-37`
                elif [[ $USR_INP == 1 ]]; then
                        RET01=`IPMICmd 20 06 00 58 e7 00 01 00 00`
                        RET01=`echo $RET01 | cut -c 35-37`
                elif [[ $USR_INP == 2 ]]; then
                        RET01=`IPMICmd 20 06 00 58 e7 00 02 00 00`
                        RET01=`echo $RET01 | cut -c 35-37`
		else
			echo "Error! Unknown setting for OEMFrontPanelAccess."
			EXIT_CODE=196
                fi

                if [[ $RET01 != "00" ]]; then
					echo "OEMFrontPanelAccess: IPMICmd did not return SUCCESS"
					debug_log "IPMICmd Failed : OEMFrontPanelAccess Failed " 
                        EXIT_CODE=197
                fi
        fi
fi


echo $EXIT_CODE
return $EXIT_CODE
