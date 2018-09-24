#!/bin/sh

# This Parses the poweroem.conf file at the location specified by POWER_OEM_CONF
# The structure of POWER_OEM_CONF is as follows
# 
# PowerLimitPolicyEnable=0
# MaxPowerLimit=432
# MaxPowerUnit=0
# PSUHotSpareEnable=0
# PrimaryPSU=1
# PFCEnable=0
#
# If the above format changes, please change the file parsing suitably

POWER_OEM_CONF=/flash/data0/persmod/poweroem.conf
source /etc/sysapps_script/pm_logger.sh
# EXIT_CODE : Allocated Exit codes 71 to 100 for this File.
EXIT_CODE=0
POL_ENABLED=1
POL_DISABLED=0

POWR_FACT_CORR_ENABLE=1
POWR_FACT_CORR_DISABLE=0

POWR_UNIT_WATT=0
POWR_UNIT_BTU_PER_HR=1

if [ -f $POWER_OEM_CONF ] ; then

	# POLICY_ENABLE - 1 (If Enabled) / 0 (If Not Enabled)
	POLICY_ENABLE=`awk -F "=" '/PowerLimitPolicyEnable/{print $2}' $POWER_OEM_CONF`
	# Max Power Limit in Decimal
	MAX_POWER_LIMIT=`awk -F "=" '/MaxPowerLimit/{print $2}' $POWER_OEM_CONF`
	# Max Power Unit - 0 (Watts) / 1 (BTU/hr) / 3 (Percentage)
	MAX_POWER_UNIT=`awk -F "=" '/MaxPowerUnit/{print $2}' $POWER_OEM_CONF`
	# Hot Spare - 1 (enabled) / 0 (Disabled)
	HOT_SPARE_ENABLE=`awk -F "=" '/PSUHotSpareEnable/{print $2}' $POWER_OEM_CONF`
	# Primary PSU - 01 (PSU 1 - 2 PSU Sys) / 02 (PSU 2 - 2 PSU Sys) / 05 (PSU 1 & 3 - 4 PSU Sys) / 0A (PSU 2 & 4 - 4 PSU Sys)
	PRIMARY_PSU=`awk -F "=" '/PrimaryPSU/{print $2}' $POWER_OEM_CONF`
	# Power Factor Correction Enable - 1 (Enabled) / 0 (Disabled)
	PFC_ENABLE=`awk -F "=" '/PFCEnable/{print $2}' $POWER_OEM_CONF`
	
	if [[ -n "$MAX_POWER_LIMIT" && -n $MAX_POWER_UNIT ]]; then

		MAX_POWER_MSB=$(($MAX_POWER_LIMIT/256))
		MAX_POWER_LSB=$(($MAX_POWER_LIMIT%256))

		# Convert them to Hex
		MAX_POWER_MSB=$(printf "%x\n" $MAX_POWER_MSB)
		MAX_POWER_LSB=$(printf "%x\n" $MAX_POWER_LSB)

		if [ $MAX_POWER_UNIT -ne $POWR_UNIT_BTU_PER_HR ]; then
			MAX_POWER_UNIT=$POWR_UNIT_WATT
		fi

		echo IPMICmd 0x20 0x06 0x00 0x58 0xEA $MAX_POWER_LSB $MAX_POWER_MSB $MAX_POWER_UNIT 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x06 0x00 0x58 0xEA $MAX_POWER_LSB $MAX_POWER_MSB $MAX_POWER_UNIT 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00" 71
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ -n "$POLICY_ENABLE" ]; then
		if [ $POLICY_ENABLE -ne $POL_ENABLED ]; then
			POLICY_ENABLE=$POL_DISABLED
		fi
		echo IPMICmd 0x20 0x30 0x00 0xBA 0x00 $POLICY_ENABLE
		exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xBA 0x00 $POLICY_ENABLE" 72
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [[ -n $PRIMARY_PSU && -n $HOT_SPARE_ENABLE ]]; then
		echo IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x04 0x05 0x00 0x00 0x00 0x05 0x00 $HOT_SPARE_ENABLE $PRIMARY_PSU 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x04 0x05 0x00 0x00 0x00 0x05 0x00 $HOT_SPARE_ENABLE $PRIMARY_PSU 0x00" 73
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi
	if [ -n $PFC_ENABLE ]; then
		if [ $PFC_ENABLE -ne $POWR_FACT_CORR_ENABLE ]; then
			PFC_ENABLE=$POWR_FACT_CORR_DISABLE
		fi
		echo IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x06 0x06 0x00 0x00 0x00 0x06 0x00 $PFC_ENABLE 0x00 0x00 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x06 0x06 0x00 0x00 0x00 0x06 0x00 $PFC_ENABLE 0x00 0x00 0x00" 74
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
	fi

	#Construct IPMI command to update iDRAC power table for PCI cards (GPU cards).
	#Support for 3 PCI cards is getting added in 13G RTS+. It could be expanded later if needed.
	#Details to construct the IPMI command would be present in "poweroem.conf" file in below format.Below is the example for
	#first PCI card configuration where 0xAB and 0xCD are hex values seperated by whitespace
	
	#PCI_Index_1=x		(x=index of GPGPU card in power table of platform)
	#PCI_VendorID_1=0xAB 0xCD
	#PCI_DeviceID_1=0xAB 0xCD
	#PCI_SubVendorID_1=0xAB 0xCD
	#PCI_SubDeviceID_1=0xAB 0xCD
	#PCI_PeakPower_1=0xAB 0xCD
	#PCI_Throttled_Power_1=0xAB 0xCD
	#PCI_Type_1=0x00         ( Type : 0x00=GPU,0x01=RAID,0x02=NDC,0x03=NIC/MEZZ,0x04=other PCIe cards)
	
		#PCI card 1 configuration
		PCI_INDEX=`awk -F "=" '/PCI_Index_1/{print $2}' $POWER_OEM_CONF`
		if [ $PCI_INDEX ];then
		echo PCI card1 config is present
		PCI_VENDORID=`awk -F "=" '/PCI_VendorID_1/{print $2}' $POWER_OEM_CONF`
		PCI_DEVICEID=`awk -F "=" '/PCI_DeviceID_1/{print $2}' $POWER_OEM_CONF`
		PCI_SUBVENDORID=`awk -F "=" '/PCI_SubVendorID_1/{print $2}' $POWER_OEM_CONF`
		PCI_SUBDEVICEID=`awk -F "=" '/PCI_SubDeviceID_1/{print $2}' $POWER_OEM_CONF`
		PCI_PEAKPOWER=`awk -F "=" '/PCI_PeakPower_1/{print $2}' $POWER_OEM_CONF`
		PCI_THROTTLEDPOWER=`awk -F "=" '/PCI_Throttled_Power_1/{print $2}' $POWER_OEM_CONF`
		PCI_TYPE=`awk -F "=" '/PCI_Type_1/{print $2}' $POWER_OEM_CONF`
		echo IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x15 0x15 0x00 0x00 0x00 0x15 0x00 0x00 $PCI_INDEX 0x01 0x05 $PCI_VENDORID $PCI_DEVICEID $PCI_SUBVENDORID $PCI_SUBDEVICEID $PCI_PEAKPOWER $PCI_THROTTLEDPOWER 0x00 $PCI_TYPE 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x15 0x15 0x00 0x00 0x00 0x15 0x00 0x00 $PCI_INDEX 0x01 0x05 $PCI_VENDORID $PCI_DEVICEID $PCI_SUBVENDORID $PCI_SUBDEVICEID $PCI_PEAKPOWER $PCI_THROTTLEDPOWER 0x00 $PCI_TYPE 0x00" 75
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
		fi
		#PCI card 2 configuration
		PCI_INDEX=`awk -F "=" '/PCI_Index_2/{print $2}' $POWER_OEM_CONF`
		if [ $PCI_INDEX ];then
		echo PCI card2 config is present
		PCI_VENDORID=`awk -F "=" '/PCI_VendorID_2/{print $2}' $POWER_OEM_CONF`
		PCI_DEVICEID=`awk -F "=" '/PCI_DeviceID_2/{print $2}' $POWER_OEM_CONF`
		PCI_SUBVENDORID=`awk -F "=" '/PCI_SubVendorID_2/{print $2}' $POWER_OEM_CONF`
		PCI_SUBDEVICEID=`awk -F "=" '/PCI_SubDeviceID_2/{print $2}' $POWER_OEM_CONF`
		PCI_PEAKPOWER=`awk -F "=" '/PCI_PeakPower_2/{print $2}' $POWER_OEM_CONF`
		PCI_THROTTLEDPOWER=`awk -F "=" '/PCI_Throttled_Power_2/{print $2}' $POWER_OEM_CONF`
		PCI_TYPE=`awk -F "=" '/PCI_Type_2/{print $2}' $POWER_OEM_CONF`
		echo IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x15 0x15 0x00 0x00 0x00 0x15 0x00 0x00 $PCI_INDEX 0x01 0x05 $PCI_VENDORID $PCI_DEVICEID $PCI_SUBVENDORID $PCI_SUBDEVICEID $PCI_PEAKPOWER $PCI_THROTTLEDPOWER 0x00 $PCI_TYPE 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x15 0x15 0x00 0x00 0x00 0x15 0x00 0x00 $PCI_INDEX 0x01 0x05 $PCI_VENDORID $PCI_DEVICEID $PCI_SUBVENDORID $PCI_SUBDEVICEID $PCI_PEAKPOWER $PCI_THROTTLEDPOWER 0x00 $PCI_TYPE 0x00" 76
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
		fi
		#PCI card 3 configuration
		PCI_INDEX=`awk -F "=" '/PCI_Index_3/{print $2}' $POWER_OEM_CONF`
		if [ $PCI_INDEX ];then
		echo PCI card3 config is present
		PCI_VENDORID=`awk -F "=" '/PCI_VendorID_3/{print $2}' $POWER_OEM_CONF`
		PCI_DEVICEID=`awk -F "=" '/PCI_DeviceID_3/{print $2}' $POWER_OEM_CONF`
		PCI_SUBVENDORID=`awk -F "=" '/PCI_SubVendorID_3/{print $2}' $POWER_OEM_CONF`
		PCI_SUBDEVICEID=`awk -F "=" '/PCI_SubDeviceID_3/{print $2}' $POWER_OEM_CONF`
		PCI_PEAKPOWER=`awk -F "=" '/PCI_PeakPower_3/{print $2}' $POWER_OEM_CONF`
		PCI_THROTTLEDPOWER=`awk -F "=" '/PCI_Throttled_Power_3/{print $2}' $POWER_OEM_CONF`
		PCI_TYPE=`awk -F "=" '/PCI_Type_3/{print $2}' $POWER_OEM_CONF`
		echo IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x15 0x15 0x00 0x00 0x00 0x15 0x00 0x00 $PCI_INDEX 0x01 0x05 $PCI_VENDORID $PCI_DEVICEID $PCI_SUBVENDORID $PCI_SUBDEVICEID $PCI_PEAKPOWER $PCI_THROTTLEDPOWER 0x00 $PCI_TYPE 0x00
		exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xCE 0x00 0x15 0x15 0x00 0x00 0x00 0x15 0x00 0x00 $PCI_INDEX 0x01 0x05 $PCI_VENDORID $PCI_DEVICEID $PCI_SUBVENDORID $PCI_SUBDEVICEID $PCI_PEAKPOWER $PCI_THROTTLEDPOWER 0x00 $PCI_TYPE 0x00" 77
		ret_val=$?
		if [ $ret_val -ne 0 ] ; then
			EXIT_CODE=$ret_val
		fi
		fi
fi

return $EXIT_CODE
