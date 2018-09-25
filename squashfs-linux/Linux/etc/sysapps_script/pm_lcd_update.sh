#!/bin/sh

# This Parses the lcd.conf file at the location specified by PM_LCD_CONF
# The structure of PM_LCD_CONF is as follows
#
# LCDOEMControl=0
# LCDOEMLit=0
# LCDOEMHomeMsgSelector=4
# LCDOEMErrorDisplay=1
# LCDOEMBanner="User String Betweeen Quotes _MAX_ 62 Chars"
# LCDOEMBrand="User Brand Between Quotes"
# LCDOEMModel="User Model Between Quotes"
#
# If the above format changes, please change the file parsing suitably

# LCDOEMControl - Controls OEM Takeover of LCD. Accepts the following
# 0 - No OEM Takeover
# 1 - OEM Takeover

# LCDOEMLit - Controls the LCD Backlight Color. Accepts the following (This script does not care)
# 0 - Blue
# 1 - Amber

# LCDOEMHomeMsgSelector - Controls the Home Screen Display Options. Accepts the following,
# 0 - OEM User Defined String, defined by the string LCDOEMBanner
# 1 - System Model. The string defined by LCDOEMModel will be displayed on the LCD Home, else the BIOS Model Name will be used
# 2 - None. With this, LCD Home Screen will be turned off
# 3 - IDRAC IPv4 Address (Display Disabled if interface disabled)
# 4 - IDRAC MAC Address
# 5 - Hostname (Blank if not present)
# 6 - Service Tag
# 7 - IPv6 Address (Display Disabled if interface disabled)
# 8 - Ambient Temperature in Centigrade
# 9 - Ambient Temperature in Farheniet
# 10 - System Power Consumption in Watts
# 11 - System Power Consumption in BTU/hr
# 12 - Asset Tag
# 13 - Auto Discovery Status
# 14 - Auto Discovery Time Remaining
# 15 - Auto Discovery Complete
# 16 - Auto Discovery Error

# LCDOEMErrorDisplay - Controls Error Dsiplay Format. Accepts the following,
# 0 - SEL
# 1 - Simple

# LCDOEMBanner - Controls the User Defined String. MAX 62 Chars BETWEEN QUOTES.

# LCDOEMBrand - Controls the Brand for OEM. (This script does not care)

# LCDOEMModel - Controls the Model for OEM.



# NOTE: LCD Home Screen Selection is based on IPMI OEM Command, Set System Information (NetFn = App (06), Cmd = 58h) 
#	Subcommand: Front Panel String (0xc1) and Front Panel (0xc2)
# 	If they change, this script needs to be changed
#	YOU HAVE BEEN FOREWARNED
#	Refer iDRAC OEM IPMI Commands Specification

PM_LCD_CONF=/flash/data0/persmod/lcdoem.conf

INP_MAX=62
STR1_MIN_LEN=0
STR1_MAX_LEN=14
STR2_MIN_LEN=$(($STR1_MAX_LEN+1))
STR2_MAX_LEN=30
STR3_MIN_LEN=$(($STR2_MAX_LEN+1))
STR3_MAX_LEN=46
STR4_MIN_LEN=$(($STR3_MAX_LEN+1))

ERR_DSP_SEL=0
ERR_DSP_SIMPLE=1
	
SELECT_USR_STR=0
SELECT_SYS_MODEL=1
SELECT_NONE=2
SELECT_IDRAC_IPV4=3
SELECT_IDRAC_MAC=4
SELECT_HOSTNAME=5
SELECT_SERVICE_TAG=6
SELECT_IDRAC_IPV6=7
SELECT_TEMP_IN_CENTIGRADE=8
SELECT_TEMP_IN_FARHENIET=9
SELECT_POWR_IN_WATTS=10
SELECT_POWR_IN_BTU_PER_HR=11
SELECT_ASSET_TAG=12
SELECT_AUTO_DISC_STATUS=13
SELECT_AUTO_DISC_TIME_REM=14
SELECT_AUTO_DISC_COMPLETE=15
SELECT_AUTO_DISC_ERR=16
# EXIT_CODE : Allocated Exit codes 33 to 70 for this File.
EXIT_CODE=0	
source /etc/sysapps_script/pm_logger.sh
usrstr() {
	# LCDOEMBanner="Pick the String between Quotes"
	USR_INP=`awk -F "=" '/LCDOEMBanner/{print $2}' $1 | tr -d '"'`
	USR_LEN=${#USR_INP}
	# LCD supports only 62 Characters for Home Screen. 
	# So trim it, if it exceeds 62.
	if [ $USR_LEN -gt $INP_MAX ]; then
		USR_INP=`echo $USR_INP | cut -c -$INP_MAX`
		USR_LEN=${#USR_INP}
	fi

	if [ -n "$USR_LEN" ]; then
		# LCD Limitation - First 14 Bytes in 1st IPMICmd
		if [[ $USR_LEN -gt 0 && $USR_LEN -le $STR1_MAX_LEN ]]; then
			USR_STR1=`echo $USR_INP | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR1_LEN=$((${#USR_STR1}-4))
			USR_STR1=`echo $USR_STR1 | cut -c -$USR_STR1_LEN`
		# LCD Limitation - Next 16 Bytes in 2nd IPMICmd
		elif [[ $USR_LEN -gt $STR1_MAX_LEN && $USR_LEN -le $STR2_MAX_LEN ]]; then
			USR_STR1=`echo $USR_INP | cut -c -$STR1_MAX_LEN | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR1_LEN=$((${#USR_STR1}-4))
			USR_STR1=`echo $USR_STR1 | cut -c -$USR_STR1_LEN`

			USR_STR2=`echo $USR_INP | cut -c $STR2_MIN_LEN- | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR2_LEN=$((${#USR_STR2}-4))
			USR_STR2=`echo $USR_STR2 | cut -c -$USR_STR2_LEN`
		# LCD Limitation - Next 16 Bytes in 3nd IPMICmd
		elif [[ $USR_LEN -gt $STR2_MAX_LEN && $USR_LEN -le $STR3_MAX_LEN ]]; then
			USR_STR1=`echo $USR_INP | cut -c -$STR1_MAX_LEN | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR1_LEN=$((${#USR_STR1}-4))
			USR_STR1=`echo $USR_STR1 | cut -c -$USR_STR1_LEN`

			USR_STR2=`echo $USR_INP | cut -c $STR2_MIN_LEN-$STR2_MAX_LEN | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR2_LEN=$((${#USR_STR2}-4))
			USR_STR2=`echo $USR_STR2 | cut -c -$USR_STR2_LEN`

			USR_STR3=`echo $USR_INP | cut -c $STR3_MIN_LEN- | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR3_LEN=$((${#USR_STR3}-4))
			USR_STR3=`echo $USR_STR3 | cut -c -$USR_STR3_LEN`
		# LCD Limitation - Last 16 Bytes in 4th IPMICmd
		elif [[ $USR_LEN -gt $STR3_MAX_LEN && $USR_LEN -le $INP_MAX ]]; then
			USR_STR1=`echo $USR_INP | cut -c -$STR1_MAX_LEN | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR1_LEN=$((${#USR_STR1}-4))
			USR_STR1=`echo $USR_STR1 | cut -c -$USR_STR1_LEN`
		
			USR_STR2=`echo $USR_INP | cut -c $STR2_MIN_LEN-$STR2_MAX_LEN | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR2_LEN=$((${#USR_STR2}-4))
			USR_STR2=`echo $USR_STR2 | cut -c -$USR_STR2_LEN`

			USR_STR3=`echo $USR_INP | cut -c $STR3_MIN_LEN-$STR3_MAX_LEN | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR3_LEN=$((${#USR_STR3}-4))
			USR_STR3=`echo $USR_STR3 | cut -c -$USR_STR3_LEN`

			USR_STR4=`echo $USR_INP | cut -c $STR4_MIN_LEN- | hexdump -v -e ' 1/1 "%02X" " "'`
			USR_STR4_LEN=$((${#USR_STR4}-4))
			USR_STR4=`echo $USR_STR4 | cut -c -$USR_STR4_LEN`
		fi
	fi

	USR_STR1_LEN=${#USR_STR1}
	USR_STR1_LEN=$(($USR_STR1_LEN+1))
	USR_STR1_LEN_FIN=$(($USR_STR1_LEN/3))
	USR_STR_LEN_FIN=$USR_STR1_LEN_FIN

	if [ -n "$USR_STR2" ]
	then
		USR_STR2_LEN=${#USR_STR2}
		USR_STR2_LEN=$(($USR_STR2_LEN+2))
		USR_STR2_LEN_FIN=$(($USR_STR2_LEN/3))
		USR_STR_LEN_FIN=$(($USR_STR_LEN_FIN+$USR_STR2_LEN_FIN))

	fi

	if [ -n "$USR_STR3" ]
	then
		USR_STR3_LEN=${#USR_STR3}
		USR_STR3_LEN=$(($USR_STR3_LEN+2))
		USR_STR3_LEN_FIN=$(($USR_STR3_LEN/3))
		USR_STR_LEN_FIN=$(($USR_STR_LEN_FIN+$USR_STR3_LEN_FIN))

	fi

	if [ -n "$USR_STR2" ]
	then
		USR_STR4_LEN=${#USR_STR4}
		USR_STR4_LEN=$(($USR_STR4_LEN+2))
		USR_STR4_LEN_FIN=$(($USR_STR4_LEN/3))
		USR_STR_LEN_FIN=$(($USR_STR_LEN_FIN+$USR_STR4_LEN_FIN))

	fi


	USR_STR_LEN_HEX=$(printf "%x\n" $USR_STR_LEN_FIN)
	CMD_PART="IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00"
	FULL_CMD=$CMD_PART" ""0x"$USR_STR_LEN_HEX" "$USR_STR1
	echo $FULL_CMD
	exec_ipmi_cmd "$FULL_CMD" 33
	ret_val=$?
	if [ $ret_val -ne 0 ] ; then
      EXIT_CODE=$ret_val
	fi
	
	if [ -n "$USR_STR2" ]; then
		CMD_PART="IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x01"
		FULL_CMD=$CMD_PART" "$USR_STR2
		echo $FULL_CMD
		exec_ipmi_cmd "$FULL_CMD" 34
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi

	if [ -n "$USR_STR3" ]; then
		CMD_PART="IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x02"
		FULL_CMD=$CMD_PART" "$USR_STR3
		echo $FULL_CMD
		exec_ipmi_cmd "$FULL_CMD" 35
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi

	if [ -n "$USR_STR4" ]; then
		CMD_PART="IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x03"
		FULL_CMD=$CMD_PART" "$USR_STR4
		echo $FULL_CMD
		exec_ipmi_cmd "$FULL_CMD" 36
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
}

if [ -f $PM_LCD_CONF ] ; then
	LCDHOMESEL=`awk -F "=" '/LCDOEMHomeMsgSelector/{print $2}' $PM_LCD_CONF`
	LCDERRDISPLAY=`awk -F "=" '/LCDOEMErrorDisplay/{print $2}' $PM_LCD_CONF`

	if [ $LCDERRDISPLAY -ne $ERR_DSP_SIMPLE ]; then
		LCDERRDISPLAY=$ERR_DSP_SEL
	fi

	if [ $LCDHOMESEL -eq $SELECT_USR_STR ]; then
		usrstr $PM_LCD_CONF
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 37
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_SYS_MODEL ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 38
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_NONE ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x02 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 39
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_IDRAC_IPV4 ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x04 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 40
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_IDRAC_MAC ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 41
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_HOSTNAME ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x10 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 42
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_SERVICE_TAG ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x20 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 43
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_IDRAC_IPV6 ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x40 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 44
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_TEMP_IN_CENTIGRADE ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x80 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 45
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_TEMP_IN_FARHENIET ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x80 0x00 0x00 0x00 0x02 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 46
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_POWR_IN_WATTS ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x00 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 47
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_POWR_IN_BTU_PER_HR ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x00 0x01 0x00 0x00 0x01 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 48
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_ASSET_TAG ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x00 0x02 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 49
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_AUTO_DISC_STATUS ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x00 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 50
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_AUTO_DISC_TIME_REM ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x01 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 51
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_AUTO_DISC_COMPLETE ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x02 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 52
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ $LCDHOMESEL -eq $SELECT_AUTO_DISC_ERR ]; then
		IPMICmd 0x20 0x06 0x00 0x58 0xc1 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xc2 0x03 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 $LCDERRDISPLAY 0x00" 53
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
fi
return $EXIT_CODE