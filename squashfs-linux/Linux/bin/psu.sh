#!/etc/bash
# filename is psu.sh
# copy into /tmp folder
# cd /tmp
# tftp -g -r psu.sh 192.168.0.100
# chmod 777 psu.sh
# ./psu.sh
#
# craig_klein@Dell.com
# 7/30/13 5:25PM
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# ---------------------------------------------------------------------------------------------------------------------------------------------------
#######################################
Script="0"
Verbose="0"
Show="0"
PSU="0"
CLICmd=""
PSU1Addr="0xb0 0x09"
PSU2Addr="0xb0 0x0b"
SuppErr="0"
Version="1.5.1"

function SetPSUParameters
{
	DellPartNumber=$1
	
	echo
	echo "Dell part number of PSU $PSU is '$DellPartNumber'."

	if [ "$DellPartNumber" = "TW16K" ]; then
		
		Wattage="1600"
		Vin_min="90"
		Vin_max="264"
		Iin_max="10.0"
		Iin_max_ll="10.0"
		Pin_max="1920"
		Pin_max_ll="900"
		Iout_max="131"
		Vout_min="11.60"
		Vout_max="12.80"
		Pout_max="$Wattage"
		Pout_max_ll="800"
		VA_max="1920"
		Inrush_max="25"
		Vout_OV_Limit="14.25"
		Vout_UV_Limit="10.25"
		Tambient_min="10"
		Tambient_max="55"
		Features="0x1e"
		ACDropoutTimeMS="10"
		Efficiency_ll_Voltage="115"
		Efficiency_ll_10="80"
		Efficiency_ll_20="85"
		Efficiency_ll_50="88"
		Efficiency_ll_100="91"
		Efficiency_hl_Voltage="230"
		Efficiency_hl_10="87"
		Efficiency_hl_20="90"
		Efficiency_hl_50="94"
		Efficiency_hl_100="91"

	elif [ "$DellPartNumber" = "W12Y2" ]; then
		
		Wattage="1100"
		Vin_min="90"
		Vin_max="264"
		Iin_max="7.0"
		Iin_max_ll="13.7"
		Pin_max="1260"
		Pin_max_ll="1232"
		Iout_max="90.13"
		Vout_min="11.60"
		Vout_max="12.80"
		Pout_max="$Wattage"
		Pout_max_ll="1050"
		VA_max="1260"
		Inrush_max="25"
		Vout_OV_Limit="14.25"
		Vout_UV_Limit="10.25"
		Tambient_min="10"
		Tambient_max="50"
		Features="0x1e"
		ACDropoutTimeMS="10"
		Efficiency_ll_Voltage="115"
		Efficiency_ll_10="87"
		Efficiency_ll_20="91"
		Efficiency_ll_50="91.75"
		Efficiency_ll_100="89.5"
		Efficiency_hl_Voltage="230"
		Efficiency_hl_10="89"
		Efficiency_hl_20="93"
		Efficiency_hl_50="94.5"
		Efficiency_hl_100="92"

	elif [ "$DellPartNumber" = "KNHJV" ]; then

		Wattage="750"
		Vin_min="180"
		Vin_max="264"
		Iin_max="5.0"
		Iin_max_ll="NA"
		Pin_max="900"
		Pin_max_ll="NA"
		Iout_max="61.5"
		Vout_min="11.60"
		Vout_max="12.80"
		Pout_max="$Wattage"
		Pout_max_ll="NA"
		VA_max="900"
		Inrush_max="25"
		Vout_OV_Limit="14.25"
		Vout_UV_Limit="10.25"
		Tambient_min="10"
		Tambient_max="55"
		Features="0x3e"
		ACDropoutTimeMS="10"
		Efficiency_ll_Voltage="0"
		Efficiency_ll_10="0"
		Efficiency_ll_20="0"
		Efficiency_ll_50="0"
		Efficiency_ll_100="0"
		Efficiency_hl_Voltage="230"
		Efficiency_hl_10="90"
		Efficiency_hl_20="94"
		Efficiency_hl_50="96"
		Efficiency_hl_100="91"

	elif [ "$DellPartNumber" = "HTRH4" ] || [ "$DellPartNumber" = "G6W6K" ] || [ "$DellPartNumber" = "TPJ2X" ]; then
		
		Wattage="750"
		Vin_min="90"
		Vin_max="264"
		Iin_max="5.0"
		Iin_max_ll="10.0"
		Pin_max="900"
		Pin_max_ll="900"
		Iout_max="61.5"
		Vout_min="11.60"
		Vout_max="12.80"
		Pout_max="$Wattage"
		Pout_max_ll=$Pout_max
		VA_max="900"
		Inrush_max="25"
		Vout_OV_Limit="14.25"
		Vout_UV_Limit="10.25"
		Tambient_min="10"
		Tambient_max="55"
		Features="0x1e"
		ACDropoutTimeMS="10"
		Efficiency_ll_Voltage="115"
		Efficiency_ll_10="80"
		Efficiency_ll_20="88"
		Efficiency_ll_50="91.5"
		Efficiency_ll_100="89"
		Efficiency_hl_Voltage="230"
		Efficiency_hl_10="82"
		Efficiency_hl_20="90"
		Efficiency_hl_50="94"
		Efficiency_hl_100="91"

	elif [ "$DellPartNumber" = "9338D" ] || [ "$DellPartNumber" = "2FR04" ]; then
		
		Wattage="495"
		Vin_min="90"
		Vin_max="264"
		Iin_max="3.3"
		Iin_max_ll="6.6"
		Pin_max="594"
		Pin_max_ll="594"
		Iout_max="40.56"
		Vout_min="11.60"
		Vout_max="12.80"
		Pout_max="$Wattage"
		Pout_max_ll=$Pout_max
		VA_max="594"
		Inrush_max="25"
		Vout_OV_Limit="14.25"
		Vout_UV_Limit="10.25"
		Tambient_min="10"
		Tambient_max="55"
		Features="0x1e"
		ACDropoutTimeMS="10"
		Efficiency_ll_Voltage="115"
		Efficiency_ll_10="80"
		Efficiency_ll_20="88"
		Efficiency_ll_50="91.5"
		Efficiency_ll_100="89"
		Efficiency_hl_Voltage="230"
		Efficiency_hl_10="82"
		Efficiency_hl_20="90"
		Efficiency_hl_50="94"
		Efficiency_hl_100="91"
	else
		echo
		echo "Cannot determine Dell part number of PSU from FRU data."
		echo
		exit
	fi
}

function ListCommands ()
{
echo "
Supported commands are:

	page
	clear_faults
	page_plus_write
	page_plus_read
	capability
	query
	smbalert_mask
	coefficients
	fan_config_1_2
	fan_command_1
	fan_command_2
	fan_command_3
	fan_command_4
	vout_ov_fault_limit
	vout_uv_fault_limit
	iout_oc_fault_limit
	iout_oc_warn_limit
	iin_oc_warn_limit
	pin_op_warn_limit
	status_byte
	status_word
	status_vout
	status_iout
	status_input
	status_temperature
	status_cml
	status_other
	status_fans_1_2
	status_fans_3_4
	read_ein
	read_eout
	read_vin
	read_iin
	read_vout
	read_iout
	read_temperature_1
	read_temperature_2
	read_temperature_3
	read_fan_speed_1
	read_fan_speed_2
	read_fan_speed_3
	read_fan_speed_4
	read_pout
	read_pin
	pmbus_revision
	mfr_id
	mfr_model
	mfr_revision
	mfr_location
	mfr_date
	mfr_serial
	app_profile_support
	mfr_vin_min
	mfr_vin_max
	mfr_iin_max
	mfr_pin_max
	mfr_vout_min
	mfr_vout_max
	mfr_iout_max
	mfr_pout_max
	mfr_tambient_max
	mfr_tambient_min
	mfr_efficiency_ll
	mfr_efficiency_hl
	fru_data_offset
	read_fru_data
	mfr_efficiency_data
	mfr_max_temp_1
	mfr_max_temp_2
	mfr_device_code
	isp_key
	isp_status_cmd
	isp_memory_addr
	isp_memory
	fw_version
	system_led_cntl
	line_status
	tot_mfr_pout_max
	ocw_setting_write
	ocw_setting_read
	ocw_status
	ocw_counter
	mfr_rapidon_cntrl
	mfr_sleep_trip
	mfr_wake_trip
	mfr_trip_latency
	mfr_page
	mfr_pos_total
	mfr_pos_last
	clear_history
	pfc_disable
	peak_current_record
	psu_features
	mfr_sample_set
	latch_control
	psu_factory_mode
	psu_manufacturing
	ocw_setting_range
	firmware_update_capability
	firmware_update_status_flag
	mfr_hotspare_cntrl
	bootloader_version
	status_all
	smbalert_mask_all
	version
	clst
	ot

"
	echo
	echo "Syntax: './psu.sh <COMMAND> <PSU> [-show] [-verbose] [OPTIONS...]'"
	echo
	echo "        Where: PSU = <1|2>"
	echo
	echo "          -show    = Show IPMI commands."
	echo "          -verbose = Verbose mode."
	echo
	echo "        Options are command dependent."
	echo
	echo "Supported commands are listed above..."
	echo
	echo "Type :  './psu.sh <COMMAND>' for help on a particular command."
	echo
}

function Syntax()
{
	local CLICmd

	if [ -n "$1" ]; then
		CLICmd="$1"
	else
		ListCommands
		exit
	fi

	echo

	if [ "$CLICmd" = "page" ] || [ "$CLICmd" = "mfr_page" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <PAGE>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current page."
		echo "          -w : Write new page value."
		echo "               Follow with page to select as a decimal integer."
		echo
		exit
	elif [ "$CLICmd" = "status_all" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		exit
	elif [ "$CLICmd" = "smbalert_mask_all" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		exit
	elif [ "$CLICmd" = "psu_manufacturing" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <CONFIGURED|UNCONFIGURED>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current setting."
		echo "          -w : Write new MFR Fan Pin config setting value."
		echo "               Follow with page to select as a decimal integer."
		echo
		exit
	elif [ "$CLICmd" = "ocw_setting_range" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -o <1|2|3>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -o : OCW number for which to read threshold range and average window length."
		echo
		exit
	elif [ "$CLICmd" = "query" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -c <COMMAND>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -c : Command name to query support."
		echo
		exit
	elif [ "$CLICmd" = "page_plus_write" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -p <PAGE> -c <INPUT|TEMP|IOUT|CML|BYTE|VOUT|OCW> [-m <MASK>]'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -p : Page to write, integer format."
		echo "          -c : Status command to reset."
		echo "          -m : Hex mask for bit in status byte to reset."
		echo
		exit
	elif [ "$CLICmd" = "page_plus_read" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -p <PAGE> -c <INPUT|TEMP|IOUT|CML|WORD|BYTE|VOUT|OCW|ALL>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -p : Page to read."
		echo "          -c : Status command to read. 'ALL' will read all status registers."
		echo
		exit
	elif [ "$CLICmd" = "smbalert_mask" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r -p <PAGE> -c <INPUT|TEMP|IOUT|CML|VOUT>'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -r -c <fans_1_2|OTHER>'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <MASK> -p <PAGE> -c <INPUT|TEMP|IOUT|CML|VOUT>'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <MASK> -c <fans_1_2|OTHER>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current mask."
		echo "          -w : Write new mask. Follow with the new SMBAlert hex bit mask, with leading 0x"
		echo "          -p : Page to access."
		echo "          -c : Status command to read or write. 'ALL' will read all status register masks."
		echo
		exit
	elif [ "$CLICmd" = "coefficients" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -c <READ_EIN|READ_EOUT>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -c : Command to fetch coefficients for."
		echo
		exit
	elif [ "$CLICmd" = "fan_command_1" ] || [ "$CLICmd" = "fan_command_2" ] || [ "$CLICmd" = "fan_command_3" ] || [ "$CLICmd" = "fan_command_4" ]; then
		echo "Syntax:  './psu.sh $CLICmd <PSU> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <PSU> -w <PERCENT>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read psu fan speed."
		echo "          -w : Set psu fan speed."
		echo "               Follow with speed to set fan as a percentage of maximum speed, 0-100 integer."
		echo
		exit
	elif [ "$CLICmd" = "vout_ov_fault_limit" ] || [ "$CLICmd" = "vout_uv_fault_limit" ]; then
		echo "Syntax:  './psu.sh $CLICmd <PSU> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <PSU> -w <LIMIT>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current limit."
		echo "          -w : Write new limit value."
		echo "               Follow with limit value to set as a decimal number in volts."
		echo
		exit
	elif [ "$CLICmd" = "iout_oc_fault_limit" ] || [ "$CLICmd" = "iout_oc_warn_limit" ] || [ "$CLICmd" = "iin_oc_warn_limit" ] || [ "$CLICmd" = "pin_op_warn_limit" ]; then
		echo "Syntax:  './psu.sh $CLICmd <PSU> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <PSU> -w <LIMIT>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current limit."
		echo "          -w : Write new limit value."
		echo "               Follow with limit value to set as a decimal number in amps."
		echo
		exit
	elif [ "$CLICmd" = "status_vout" ] || [ "$CLICmd" = "status_iout" ] || [ "$CLICmd" = "status_input" ] || [ "$CLICmd" = "status_temperature" ] || [ "$CLICmd" = "status_cml" ] || [ "$CLICmd" = "status_byte" ]; then
		echo "Syntax:  './psu.sh $CLICmd <PSU> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <PSU> -w <MASK>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current status."
		echo "          -w : Reset status bits."
		echo "               Follow with a hex bit mask for resetting status bits, with a leading '0x'."
		echo
		exit
	elif [ "$CLICmd" = "status_other" ] || [ "$CLICmd" = "status_fans_1_2" ] || [ "$CLICmd" = "status_fans_3_4" ]; then
		echo "Syntax:  './psu.sh $CLICmd <PSU> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <PSU> -w <MASK>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current status."
		echo "          -w : Reset status bits."
		echo "               Follow with a hex bit mask for resetting status bits, with a leading '0x'."
		echo
		exit
	elif [ "$CLICmd" = "system_led_cntl" ]; then
		echo "Syntax:  './psu.sh $CLICmd <PSU> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <PSU> -s <SOLID|BLINK|OFF> -c <AMBER|GREEN>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current system LED control setting."
		echo "          -s : Setting to write for PSU LED system override state."
		echo "          -c : Color to set for LED when in system override state."
		echo
		exit
	elif [ "$CLICmd" = "ocw_setting_write" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -o <1|3> [-a <THRESH>] [-l <LENGTH>]'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -o : OCW number."
		echo "          -a : Assertion threshold in amps."
		echo "          -l : Window length in msec."
		echo
		exit
	elif [ "$CLICmd" = "ocw_setting_read" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -o <1|2|3>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -o : OCW number."
		echo
		exit
	elif [ "$CLICmd" = "ocw_status" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <MASK>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current status."
		echo "          -w : Reset status bits."
		echo "               Follow with hex mask for resetting status bits, with leading '0x'."
		echo
		exit
	elif [ "$CLICmd" = "mfr_rapidon_cntrl" ] || [ "$CLICmd" = "mfr_hotspare_cntrl" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <NORMAL|ATS|ROA>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current Rapid On state."
		echo "          -w : Write new Rapid On state."
		echo "               Follow with the new Rapid On setting."
		echo
		exit
	elif [ "$CLICmd" = "mfr_sleep_trip" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <PERCENT>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current value."
		echo "          -w : Write new value."
		echo "               Follow with new Sleep Trip value as a percentage 0-100."
		echo
		exit
	elif [ "$CLICmd" = "mfr_wake_trip" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <PERCENT>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current value."
		echo "          -w : Write new value."
		echo "               Follow with new Wake Trip value as a percentage 0-100."
		echo
		exit
	elif [ "$CLICmd" = "mfr_trip_latency" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <SECONDS>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current value."
		echo "          -w : Write new value."
		echo "               Follow with the new Trip Latency value in seconds as a decimal number."
		echo
		exit
	elif [ "$CLICmd" = "pfc_disable" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -v <FIXED|DYNAMIC> -p <ACTIVATE|DEACTIVATE>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current values."
		echo "          -v : Input bulk voltage setting to write."
		echo "          -p : PFC Disable Function setting to write."
		echo
		exit
	elif [ "$CLICmd" = "latch_control" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <LATCH|UNLATCH>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current latch_control value."
		echo "          -w : Write new latch_control value."
		echo "               Follow with the new IOUT OC Warning latch setting."
		echo
		exit
	elif [ "$CLICmd" = "psu_factory_mode" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -c <ENABLE|DISABLE> -b <ENABLE|DISABLE> -i <ENABLE|DISABLE> -f <ENABLE|DISABLE>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current values."
		echo "          -c : Write new 'Permission to clear Black Box' enable setting value."
		echo "          -b : Write new 'Black Box buffering' enable setting value."
		echo "          -i : Write new 'FRU image write access' enable setting value."
		echo "          -f : Write new 'Factory mode' enable setting value."
		echo
		exit
	elif [ "$CLICmd" = "fru_data_offset" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <ADDRESS>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current value."
		echo "          -w : Write new value."
		echo "               Follow with the new 16-bit FRU data address in hex, must be on 16 byte boundary, leading '0x'."
		echo
		exit
	elif [ "$CLICmd" = "peak_current_record" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read peak current value."
		echo "          -w : Reset peak current value."
		echo
		exit
	elif [ "$CLICmd" = "isp_memory_addr" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <ADDRESS>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read current value."
		echo "          -w : Write new value."
		echo "               Follow with the new ISP 16-bit memory data address in hex."
		echo "               It must be on 16 byte boundary, with a leading '0x'."
		echo
		exit
	elif [ "$CLICmd" = "isp_status_cmd" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> -r'"
		echo "              or"
		echo "         './psu.sh $CLICmd <1|2> -w <ISPCMD>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -r : Read ISP status."
		echo "          -w : Write ISP command."
		echo "               Follow with the ISP command to send in hex, with a leading '0x'."
		echo
		exit
	elif [ "$CLICmd" = "isp_key" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		exit
	elif [ "$CLICmd" = "clst" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2> [-d SECONDS] [-i SECONDS]'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		echo "          -d : Maximum CLST duration in seconds. Default = 5."
		echo "          -i : Maximum interval between CLST assertions. Default = 90."
		echo
		exit
 	elif [ "$CLICmd" = "clear_faults" ] || [ "$CLICmd" = "read_ein" ] || [ "$CLICmd" = "read_iin" ] || [ "$CLICmd" = "read_vin" ] || [ "$CLICmd" = "read_eout" ] || [ "$CLICmd" = "read_iout" ] || [ "$CLICmd" = "read_vout" ] || [ "$CLICmd" = "read_temperature_1" ] || [ "$CLICmd" = "read_temperature_2" ] || [ "$CLICmd" = "read_temperature_3" ] || [ "$CLICmd" = "read_fan_speed_1" ] || [ "$CLICmd" = "read_fan_speed_2" ] || [ "$CLICmd" = "read_fan_speed_3" ] || [ "$CLICmd" = "read_fan_speed_4" ] || [ "$CLICmd" = "mfr_iout_max" ] || [ "$CLICmd" = "fw_version" ] || [ "$CLICmd" = "mfr_pout_max" ] || [ "$CLICmd" = "mfr_efficiency_data" ] || [ "$CLICmd" = "mfr_max_temp_1" ] || [ "$CLICmd" = "mfr_max_temp_2" ] || [ "$CLICmd" = "read_eout" ] || [ "$CLICmd" = "read_temperature_1" ] || [ "$CLICmd" = "read_temperature_2" ] || [ "$CLICmd" = "read_temperature_3" ] || [ "$CLICmd" = "read_pout" ] || [ "$CLICmd" = "read_pin" ] || [ "$CLICmd" = "tot_mfr_pout_max" ] || [ "$CLICmd" = "mfr_pos_total" ] || [ "$CLICmd" = "mfr_pos_last" ] || [ "$CLICmd" = "clear_history" ] || [ "$CLICmd" = "psu_features" ] || [ "$CLICmd" = "mfr_sample_set" ] || [ "$CLICmd" = "capability" ] || [ "$CLICmd" = "fan_config_1_2" ] || [ "$CLICmd" = "pmbus_revision" ] || [ "$CLICmd" = "mfr_id" ] || [ "$CLICmd" = "mfr_model" ] || [ "$CLICmd" = "mfr_revision" ] || [ "$CLICmd" = "mfr_location" ] || [ "$CLICmd" = "mfr_date" ] || [ "$CLICmd" = "mfr_serial" ] || [ "$CLICmd" = "app_profile_support" ] || [ "$CLICmd" = "mfr_vin_min" ] || [ "$CLICmd" = "mfr_vin_max" ] || [ "$CLICmd" = "mfr_iin_max" ] || [ "$CLICmd" = "mfr_pin_max" ] || [ "$CLICmd" = "mfr_vout_min" ] || [ "$CLICmd" = "mfr_vout_max" ] || [ "$CLICmd" = "mfr_iout_max" ] || [ "$CLICmd" = "mfr_tambient_max" ] || [ "$CLICmd" = "mfr_tambient_min" ] || [ "$CLICmd" = "mfr_efficiency_ll" ] || [ "$CLICmd" = "mfr_efficiency_hl" ] || [ "$CLICmd" = "read_fru_data" ] || [ "$CLICmd" = "mfr_device_code" ] || [ "$CLICmd" = "fw_version" ] || [ "$CLICmd" = "isp_memory" ] || [ "$CLICmd" = "mfr_smbalert_mask" ] || [ "$CLICmd" = "line_status" ] || [ "$CLICmd" = "ocw_counter" ] || [ "$CLICmd" = "firmware_update_capability" ] || [ "$CLICmd" = "firmware_update_status_flag" ] || [ "$CLICmd" = "bootloader_version" ]; then
		echo "Syntax:  './psu.sh $CLICmd <1|2>'"
		echo
		echo "Where:    First parameter after the command is the PSU slot number."
		echo
		exit
	fi

	echo "Unknown command..."
	ListCommands
	echo
	exit
}

function IsDecimal()
{
	local -i Index=0

	if [ -n "$1" ]; then
		InputString=$1
	else
		echo
		echo "Empty string given as input to function 'IsDecimal'."
		exit
	fi

	while [[ $Index -lt ${#InputString} ]]; do

		if { [[ "${InputString:$Index:1}" < "0" ]] || [[ "${InputString:$Index:1}" > "9" ]]; } && [[ "${InputString:$Index:1}" != "." ]] && [[ "${InputString:$Index:1}" != "-" ]]; then
			return 0
		fi

		(( Index++ ))
	done

	return 1
}

function IsHexadecimal()
{
	local -i Index=2

	if [ -n "$1" ]; then
		InputString=$1
	else
		echo
		echo "Empty string given as input to function 'IsHexadecimal'."
		exit
	fi

	if [[ "${InputString:0:2}" != "0x" ]] && [[ "${InputString:0:2}" != "0X" ]]; then
		return 0
	fi

	while [[ $Index -lt ${#InputString} ]]; do
		if [[ "${InputString:$Index:1}" < "0" ]] || { [[ "${InputString:$Index:1}" > "9" ]] && [[ "${InputString:$Index:1}" < "A" ]]; } || { [[ "${InputString:$Index:1}" > "F" ]] && [[ "${InputString:$Index:1}" < "a" ]]; } || [[ "${InputString:$Index:1}" > "f" ]]; then
			return 0
		fi

		(( Index++ ))
	done

	return 1
}

function GetPSUAddress()
{
	if [ "$PSU" = "1" ]; then
		echo "$PSU1Addr"
	elif [ "$PSU" = "2" ]; then
		echo "$PSU2Addr"
	else
		echo
		echo "Invalid PSU slot number entered."
		Syntax $CLICmd
	fi
}

function ShowVersion
{
	echo
	echo "Version = $Version"
	echo
}
function CLIParse
{
	local -i Index=2
	local -i InputParmsCount
	local PSU
	local CLICmd

	InputParms[0]="$0"
	InputParms[1]="$1"
	InputParms[2]="$2"
	InputParms[3]="$3"
	InputParms[4]="$4"
	InputParms[5]="$5"
	InputParms[6]="$6"
	InputParms[7]="$7"
	InputParms[8]="$8"
	InputParms[9]="$9"
	InputParms[10]="${10}"
	InputParms[11]="${11}"
	InputParms[12]="${12}"
	(( InputParmsCount = $# ))

	if [[ $InputParmsCount -lt 1 ]]; then
		Syntax ""
	fi

	CLICmd="$(echo ${InputParms[1]} | tr '[A-Z]' '[a-z]')"

	if [ "$CLICmd" = "version" ]; then
		ShowVersion
		exit
	fi
	
	if [[ $InputParmsCount -eq 1 ]]; then
		Syntax $CLICmd
	fi

	while [[ $Index -le $InputParmsCount ]]; do

		InputParms[$Index]="$(echo ${InputParms[$Index]} | tr '[A-Z]' '[a-z]')"
		if [ "${InputParms[$Index]}" = "-show" ]; then
			Show="1"
		elif [ "${InputParms[$Index]}" = "-verbose" ]; then
			Verbose="1"
		fi

		(( Index++ ))
	done

	(( Index = 2 ))

	if [ -n "${InputParms[2]}" ]; then
		PSU="${InputParms[2]}"
		if [ "$PSU" != "1" ] && [ "$PSU" != "2" ]; then
			echo
			echo "Invalid PSU slot number entered."
			Syntax $CLICmd
		fi
	else
		Syntax $CLICmd
	fi

	if [ "$CLICmd" = "clst" ]; then
		Script="1"
		Verbose="0"

		local -i MaxInterval=17
		local -i MaxDuration=7

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-i" ]; then

				(( Index++ ))
				if [ -n "${InputParms[$Index]}" ]; then
					(( MaxInterval = ${InputParms[$Index]} ))
				else
					Syntax $CLICmd
				fi
			fi

			if [ "${InputParms[$Index]}" = "-d" ]; then

				(( Index++ ))
				if [ -n "${InputParms[$Index]}" ]; then
					(( MaxDuration = ${InputParms[$Index]} ))
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		echo
		if [[ $MaxInterval -eq 90 ]]; then
			echo "Using default value for Maximum CLST Interval = $MaxInterval seconds."
		else
			echo "Maximum CLST Interval = $MaxInterval seconds."
		fi
		if [[ $MaxDuration -eq 15 ]]; then
			echo "Using default value for Maximum CLST Duration = $MaxDuration seconds."
		else
			echo "Maximum CLST Duration = $MaxDuration seconds."
		fi
		
		CLST $PSU $MaxInterval $MaxDuration
		exit
	fi

	if [ "$CLICmd" = "ot" ]; then
		Script="1"
		Verbose="0"

		OverTemp $PSU
		exit
	fi

	if [ "$CLICmd" = "script" ]; then

		Script="1"
		Verbose="1"
		RunTestScript $PSU
	fi

	if [ "$CLICmd" = "fru_data_offset" ] || [ "$CLICmd" = "isp_memory_addr" ]; then

		local WR=""
		local MemAddr=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			elif [ "${InputParms[$Index]}" = "-w" ]; then
				WR="1"
				(( Index++ ))
				if [ -n "${InputParms[$Index]}" ]; then
					MemAddr="${InputParms[$Index]}"
					IsHexadecimal $MemAddr
					if [[ $? -ne 1 ]]; then
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		if { [ -z "$MemAddr" ] && [ "$WR" = "1" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		if [ "$CLICmd" = "fru_data_offset" ]; then
			fru_data_offset $PSU $WR $MemAddr
		else
			isp_memory_addr $PSU $WR $MemAddr
		fi

	elif [ "$CLICmd" = "query" ]; then

		local QryCmd=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-c" ]; then

				(( Index++ ))
				if [ -n "${InputParms[$Index]}" ]; then
					QryCmd="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		if [ -z "$QryCmd" ]; then
			Syntax $CLICmd
		fi

		query $PSU $QryCmd

	elif [ "$CLICmd" = "psu_manufacturing" ]; then

		local PinConfig=""
		local WR=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				if [ -n "${InputParms[$Index]}" ]; then
					PinConfig="${InputParms[$Index]}"
					WR="1"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then

					WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$PinConfig" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		psu_manufacturing $PSU $WR $PinConfig

	elif [ "$CLICmd" = "ocw_setting_range" ]; then

		local OCW=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-o" ]; then

				(( Index++ ))
				if [ -n "${InputParms[$Index]}" ]; then
					OCW="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		if [ -z "$OCW" ]; then
			Syntax $CLICmd
		fi

		ocw_setting_range $PSU $OCW

	elif [ "$CLICmd" = "page" ] || [ "$CLICmd" = "mfr_page" ]; then

		local WR=""
		local Page=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				WR="1"
				(( Index++ ))
				if [ -n "${InputParms[$Index]}" ]; then
					Page="${InputParms[$Index]}"
					IsDecimal $Page
					if [[ $? -ne 1 ]]; then
						IsHexadecimal $Page
						if [[ $? -ne 1 ]]; then
							echo
							echo "Invalid page number entered."
							Syntax $CLICmd
						fi
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then

				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$Page" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		if [ "$CLICmd" = "page" ]; then
			page $PSU $WR $Page
		else
			mfr_page $PSU $WR $Page
		fi

	elif [ "$CLICmd" = "page_plus_write" ]; then

		local Page=""
		local STSCmd=""
		local Mask=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-p" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					Page="${InputParms[$Index]}"
					IsDecimal $Page
					if [[ $? -ne 1 ]]; then
						IsHexadecimal $Page
						if [[ $? -ne 1 ]]; then
							echo
							echo "Invalid page number entered."
							Syntax $CLICmd
						fi
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-c" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					STSCmd="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-m" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					Mask="${InputParms[$Index]}"
					IsHexadecimal $Mask
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid mask entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		if [ -z "$STSCmd" ] || [ -z "$Page" ] || [ -z "$Mask" ]; then
			Syntax $CLICmd
		else
			page_plus_write $PSU $Page $STSCmd $Mask
		fi

	elif [ "$CLICmd" = "page_plus_read" ]; then

		local Page=""
		local STSCmd=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-p" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					Page="${InputParms[$Index]}"
					IsDecimal $Page
					if [[ $? -ne 1 ]]; then
						IsHexadecimal $Page
						if [[ $? -ne 1 ]]; then
							echo
							echo "Invalid page number entered."
							Syntax $CLICmd
						fi
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-c" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					STSCmd="${InputParms[$Index]}"
					if [ "$STSCmd" = "all" ]; then
						Page="0x00"
					fi
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		if [ -z "$STSCmd" ] || [ -z "$Page" ]; then
			Syntax $CLICmd
		else
			if [ "$STSCmd" = "all" ]; then
				status_all $PSU
			else
				page_plus_read $PSU $Page $STSCmd
			fi
		fi

	elif [ "$CLICmd" = "smbalert_mask" ]; then

		WR=""
		STSCmd=""
		Page="0"
		Mask=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-p" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then

					Page="${InputParms[$Index]}"
					IsDecimal $Page
					if [[ $? -ne 1 ]]; then

						IsHexadecimal $Page
						if [[ $? -ne 1 ]]; then
							echo
							echo "Invalid page number entered."
							Syntax $CLICmd
						fi
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-c" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					STSCmd="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"
				if [ -n "${InputParms[$Index]}" ]; then
					Mask="${InputParms[$Index]}"
					IsHexadecimal $Mask
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid mask entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then

				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && { [ -z "$Mask" ] || [ -z "$STSCmd" ] || [ -z "$Page" ];};} || [ -z "$WR" ] || { [ "$WR" = "0" ] && [ -z "$STSCmd" ];} then
			Syntax $CLICmd
		fi

		smbalert_mask $PSU $WR $Page $STSCmd $Mask

	elif [ "$CLICmd" = "coefficients" ]; then

		local CoefCmd=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-c" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					CoefCmd="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		if [ -z "$CoefCmd" ]; then
			Syntax $CLICmd
		fi

		coefficients $PSU $CoefCmd

	elif [ "$CLICmd" = "fan_command_1" ] || [ "$CLICmd" = "fan_command_2" ] || [ "$CLICmd" = "fan_command_3" ] || [ "$CLICmd" = "fan_command_4" ]; then

		local WR=""
		local Speed=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					Speed="${InputParms[$Index]}"
					IsDecimal $Speed
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid speed entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$Speed" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		if [ "$CLICmd" = "fan_command_1" ]; then
			fan_command_1 $PSU $WR $Speed
		elif [ "$CLICmd" = "fan_command_2" ]; then
			fan_command_2 $PSU $WR $Speed
		elif [ "$CLICmd" = "fan_command_3" ]; then
			fan_command_3 $PSU $WR $Speed
		elif [ "$CLICmd" = "fan_command_4" ]; then
			fan_command_4 $PSU $WR $Speed
		fi

	elif [ "$CLICmd" = "vout_ov_fault_limit" ] || [ "$CLICmd" = "vout_uv_fault_limit" ] || [ "$CLICmd" = "iout_oc_fault_limit" ] || [ "$CLICmd" = "iout_oc_warn_limit" ] || [ "$CLICmd" = "iin_oc_warn_limit" ] || [ "$CLICmd" = "pin_op_warn_limit" ]; then

		local WR=""
		local Limit=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					Limit="${InputParms[$Index]}"
					IsDecimal $Limit
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid limit entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$Limit" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		if [ "$CLICmd" = "vout_ov_fault_limit" ]; then
			vout_ov_fault_limit $PSU $WR $Limit
		elif [ "$CLICmd" = "vout_uv_fault_limit" ]; then
			vout_uv_fault_limit $PSU $WR $Limit
		elif [ "$CLICmd" = "iout_oc_fault_limit" ]; then
			iout_oc_fault_limit $PSU $WR $Limit
		elif [ "$CLICmd" = "iout_oc_warn_limit" ]; then
			iout_oc_warn_limit $PSU $WR $Limit
		elif [ "$CLICmd" = "iin_oc_warn_limit" ]; then
			iin_oc_warn_limit $PSU $WR $Limit
		else
			pin_op_warn_limit $PSU $WR $Limit
		fi

	elif [ "$CLICmd" = "status_vout" ] || [ "$CLICmd" = "status_word" ] || [ "$CLICmd" = "status_byte" ] || [ "$CLICmd" = "status_iout" ] || [ "$CLICmd" = "status_input" ] || [ "$CLICmd" = "status_temperature" ] || [ "$CLICmd" = "status_cml" ] || [ "$CLICmd" = "ocw_status" ]; then

		local WR=""
		local Mask=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					Mask="${InputParms[$Index]}"
					IsHexadecimal $Mask
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid mask entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$Mask" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		if [ "$CLICmd" = "status_vout" ]; then
			status_vout $PSU $WR $Mask
		elif [ "$CLICmd" = "status_iout" ]; then
			status_iout $PSU $WR $Mask
		elif [ "$CLICmd" = "status_word" ]; then
			status_word $PSU $WR $Mask 
		elif [ "$CLICmd" = "status_byte" ]; then
			status_byte $PSU $WR $Mask 
		elif [ "$CLICmd" = "status_temperature" ]; then
			status_temperature $PSU $WR $Mask
		elif [ "$CLICmd" = "status_input" ]; then
			status_input $PSU $WR $Mask
		elif [ "$CLICmd" = "status_cml" ]; then
			status_cml $PSU $WR $Mask
		else
			ocw_status $PSU $WR $Mask
		fi

	elif [ "$CLICmd" = "status_other" ] || [ "$CLICmd" = "status_fans_1_2" ] || [ "$CLICmd" = "status_fans_3_4" ]; then

		local WR=""
		local Mask=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					Mask="${InputParms[$Index]}"
					IsHexadecimal $Mask
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid mask entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$Mask" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		if [ "$CLICmd" = "status_other" ]; then
			status_other $PSU $WR $Mask
		elif [ "$CLICmd" = "status_fans_1_2" ]; then
			status_fans_1_2 $PSU $WR $Mask
		else
			status_fans_3_4 $PSU $WR $Mask
		fi

	elif [ "$CLICmd" = "system_led_cntl" ]; then

		WR=""
		State=""
		Color=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-s" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					State="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-c" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					Color="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && { [ -z "$Color" ] || [ -z "$State" ] ;};} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		system_led_cntl $PSU $WR $Color $State

	elif [ "$CLICmd" = "ocw_setting_write" ]; then

		local AvgWnd=""
		local AssnThr=""
		local OCW=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-o" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					OCW="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-a" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					AssnThr="${InputParms[$Index]}"
					IsDecimal $AssnThr
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid Assertion Threshold entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-l" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					AvgWnd="${InputParms[$Index]}"
					IsDecimal $AvgWnd
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid Averaging Window Length entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		if [ -z "$OCW" ] || [ -z "$AvgWnd" ] || [ -z "$AssnThr" ]; then
			Syntax $CLICmd
		fi

		ocw_setting_write $PSU $OCW $AssnThr $AvgWnd

	elif [ "$CLICmd" = "ocw_setting_read" ]; then

		local OCW=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-o" ]; then

				(( Index++ ))

				if [ -n "${InputParms[$Index]}" ]; then
					OCW="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			fi

			(( Index++ ))
		done

		if [ -z "$OCW" ]; then
			Syntax $CLICmd
		fi

		ocw_setting_read $PSU $OCW

	elif [ "$CLICmd" = "mfr_rapidon_cntrl" ] || [ "$CLICmd" = "mfr_hotspare_cntrl" ]; then

		local WR=""
		local RapidOn=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					RapidOn="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$RapidOn" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		mfr_rapidon_cntrl $PSU $WR $RapidOn

	elif [ "$CLICmd" = "mfr_sleep_trip" ] || [ "$CLICmd" = "mfr_wake_trip" ]; then

		local WR=""
		local Trip=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					Trip="${InputParms[$Index]}"
					IsDecimal $Trip
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid Trip Threshold value entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$Trip" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		if [ "$CLICmd" = "mfr_sleep_trip" ]; then
			mfr_sleep_trip $PSU $WR $Trip
		else
			mfr_wake_trip $PSU $WR $Trip
		fi

	elif [ "$CLICmd" = "peak_current_record" ]; then

		local WR=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		peak_current_record $PSU $WR

	elif [ "$CLICmd" = "mfr_trip_latency" ]; then

		local WR=""
		local Latency=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					Latency="${InputParms[$Index]}"
					IsDecimal $Latency
					if [[ $? -ne 1 ]]; then
						echo
						echo "Invalid Latency value entered."
						Syntax $CLICmd
					fi
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if { [ "$WR" = "1" ] && [ -z "$Latency" ];} || [ -z "$WR" ]; then
			Syntax $CLICmd
		fi

		mfr_trip_latency $PSU $WR $Latency

	elif [ "$CLICmd" = "pfc_disable" ]; then

		local WR=""
		local InpBV=""
		local PFCDis=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-v" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					InpBV="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-p" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					PFCDis="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if [ -z "$WR" ] || { [ "$WR" = "1" ] && { [ -z "$InpBV" ] || [ -z "$PFCDis" ];};} then
			Syntax $CLICmd
		fi

		pfc_disable $PSU $WR $InpBV $PFCDis

	elif [ "$CLICmd" = "latch_control" ]; then

		local WR=""
		local IoutWarnLatch=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					IoutWarnLatch="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if [ -z "$WR" ] || { [ "$WR" = "1" ] && [ -z "$IoutWarnLatch" ];} then
			Syntax $CLICmd
		fi

		latch_control $PSU $WR $IoutWarnLatch

	elif [ "$CLICmd" = "isp_status_cmd" ]; then

		local WR=""
		local ISPCmd=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-w" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					ISPCmd="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi

			(( Index++ ))
		done

		if [ -z "$WR" ] || { [ "$WR" = "1" ] && [ -z "$ISPCmd" ];} then
			Syntax $CLICmd
		fi

		isp_status_cmd $PSU $WR $ISPCmd

	elif [ "$CLICmd" = "psu_factory_mode" ]; then

		local WR=""
		local BBClear=""
		local BBSample=""
		local FRUImageWr=""
		local FactMode=""

		while [[ $Index -le $InputParmsCount ]]; do

			if [ "${InputParms[$Index]}" = "-c" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					BBClear="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-b" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					BBSample="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-i" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					FRUImageWr="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-f" ]; then

				(( Index++ ))
				WR="1"

				if [ -n "${InputParms[$Index]}" ]; then
					FactMode="${InputParms[$Index]}"
				else
					Syntax $CLICmd
				fi
			elif [ "${InputParms[$Index]}" = "-r" ]; then
				WR="0"
			fi
			
			(( Index++ ))
		done

		if [ -z "$WR" ] || { [ "$WR" = "1" ] && { [ -z "$BBClear" ] || [ -z "$BBSample" ] || [ -z "$FRUImageWr" ] || [ -z "$FactMode" ];};} then
			Syntax $CLICmd
		fi

		psu_factory_mode $PSU $WR $BBClear $BBSample $FRUImageWr $FactMode

	elif [ "$CLICmd" = "isp_key" ]; then
		isp_key $PSU
	elif [ "$CLICmd" = "clear_faults" ]; then
		clear_faults $PSU
	elif [ "$CLICmd" = "read_ein" ]; then
		read_ein $PSU
	elif [ "$CLICmd" = "read_iin" ]; then
		read_iin $PSU
	elif [ "$CLICmd" = "read_vin" ]; then
		read_vin $PSU
	elif [ "$CLICmd" = "read_eout" ]; then
		read_eout $PSU
	elif [ "$CLICmd" = "read_iout" ]; then
		read_iout $PSU
	elif [ "$CLICmd" = "read_vout" ]; then
		read_vout $PSU
	elif [ "$CLICmd" = "read_temperature_1" ]; then
		read_temperature_1 $PSU
	elif [ "$CLICmd" = "read_temperature_2" ]; then
		read_temperature_2 $PSU
	elif [ "$CLICmd" = "read_temperature_3" ]; then
		read_temperature_3 $PSU
	elif [ "$CLICmd" = "read_fan_speed_1" ]; then
		read_fan_speed_1 $PSU
	elif [ "$CLICmd" = "read_fan_speed_2" ]; then
		read_fan_speed_2 $PSU
	elif [ "$CLICmd" = "read_fan_speed_3" ]; then
		read_fan_speed_3 $PSU
	elif [ "$CLICmd" = "read_fan_speed_4" ]; then
		read_fan_speed_4 $PSU
	elif [ "$CLICmd" = "mfr_iout_max" ]; then
		mfr_iout_max $PSU
	elif [ "$CLICmd" = "fw_version" ]; then
		fw_version $PSU
	elif [ "$CLICmd" = "mfr_pout_max" ]; then
		mfr_pout_max $PSU
	elif [ "$CLICmd" = "mfr_efficiency_data" ]; then
		mfr_efficiency_data $PSU
	elif [ "$CLICmd" = "mfr_max_temp_1" ]; then
		mfr_max_temp_1 $PSU
	elif [ "$CLICmd" = "mfr_max_temp_2" ]; then
		mfr_max_temp_2 $PSU
	elif [ "$CLICmd" = "read_eout" ]; then
		read_eout $PSU
	elif [ "$CLICmd" = "read_temperature_1" ]; then
		read_temperature_1 $PSU
	elif [ "$CLICmd" = "read_temperature_2" ]; then
		read_temperature_2 $PSU
	elif [ "$CLICmd" = "read_temperature_3" ]; then
		read_temperature_3 $PSU
	elif [ "$CLICmd" = "read_pout" ]; then
		read_pout $PSU
	elif [ "$CLICmd" = "read_pin" ]; then
		read_pin $PSU
	elif [ "$CLICmd" = "tot_mfr_pout_max" ]; then
		tot_mfr_pout_max $PSU
	elif [ "$CLICmd" = "mfr_pos_total" ]; then
		mfr_pos_total $PSU
	elif [ "$CLICmd" = "mfr_pos_last" ]; then
		mfr_pos_last $PSU
	elif [ "$CLICmd" = "clear_history" ]; then
		clear_history $PSU
	elif [ "$CLICmd" = "psu_features" ]; then
		psu_features $PSU
	elif [ "$CLICmd" = "mfr_sample_set" ]; then
		mfr_sample_set $PSU
	elif [ "$CLICmd" = "capability" ]; then
		capability $PSU
	elif [ "$CLICmd" = "fan_config_1_2" ]; then
		fan_config_1_2 $PSU
	elif [ "$CLICmd" = "pmbus_revision" ]; then
		pmbus_revision $PSU
	elif [ "$CLICmd" = "mfr_id" ]; then
		mfr_id $PSU
	elif [ "$CLICmd" = "mfr_model" ]; then
		mfr_model $PSU
	elif [ "$CLICmd" = "mfr_revision" ]; then
		mfr_revision $PSU
	elif [ "$CLICmd" = "mfr_location" ]; then
		mfr_location $PSU
	elif [ "$CLICmd" = "mfr_date" ]; then
		mfr_date $PSU
	elif [ "$CLICmd" = "mfr_serial" ]; then
		mfr_serial $PSU
	elif [ "$CLICmd" = "app_profile_support" ]; then
		app_profile_support $PSU
	elif [ "$CLICmd" = "mfr_vin_min" ]; then
		mfr_vin_min $PSU
	elif [ "$CLICmd" = "mfr_vin_max" ]; then
		mfr_vin_max $PSU
	elif [ "$CLICmd" = "mfr_iin_max" ]; then
		mfr_iin_max $PSU
	elif [ "$CLICmd" = "mfr_pin_max" ]; then
		mfr_pin_max $PSU
	elif [ "$CLICmd" = "mfr_vout_min" ]; then
		mfr_vout_min $PSU
	elif [ "$CLICmd" = "mfr_vout_max" ]; then
		mfr_vout_max $PSU
	elif [ "$CLICmd" = "mfr_iout_max" ]; then
		mfr_iout_max $PSU
	elif [ "$CLICmd" = "mfr_tambient_max" ]; then
		mfr_tambient_max $PSU
	elif [ "$CLICmd" = "mfr_tambient_min" ]; then
		mfr_tambient_min $PSU
	elif [ "$CLICmd" = "mfr_efficiency_ll" ]; then
		mfr_efficiency_ll $PSU
	elif [ "$CLICmd" = "mfr_efficiency_hl" ]; then
		mfr_efficiency_hl $PSU
	elif [ "$CLICmd" = "read_fru_data" ]; then
		read_fru_data $PSU
	elif [ "$CLICmd" = "mfr_device_code" ]; then
		mfr_device_code $PSU
	elif [ "$CLICmd" = "fw_version" ]; then
		fw_version $PSU
	elif [ "$CLICmd" = "isp_memory" ]; then
		isp_memory $PSU
	elif [ "$CLICmd" = "mfr_smbalert_mask" ]; then
		mfr_smbalert_mask $PSU
	elif [ "$CLICmd" = "line_status" ]; then
		line_status $PSU
	elif [ "$CLICmd" = "ocw_counter" ]; then
		ocw_counter $PSU
	elif [ "$CLICmd" = "firmware_update_capability" ]; then
		firmware_update_capability $PSU
	elif [ "$CLICmd" = "firmware_update_status_flag" ]; then
		firmware_update_status_flag $PSU
	elif [ "$CLICmd" = "bootloader_version" ]; then
		bootloader_version $PSU
	elif [ "$CLICmd" = "smbalert_mask_all" ]; then
		smbalert_mask_all $PSU
	elif [ "$CLICmd" = "status_all" ]; then
		status_all $PSU
	else
		echo
		echo "unknown command"
		echo
		Syntax
	fi
}

function DecodeLinear16()
{
	local -i mantissa
	local Linear16
	local -i exponent
	local -i INT
	local -i DEC
	local FPString
	local -i FPStringLen

	if [[ $# -ne 2 ]]; then
		echo "Call made to function 'DecodeLinear16' with insufficient number of parameters ($#)."
		exit
	fi

	Linear16=$1
	(( exponent = 10#$2 ))

	(( mantissa = `expr 10#$(printf '%d\n' "$Linear16")` * 1000 ))

	(( INT = $mantissa / 2 ** $exponent ))
	(( INT = $INT / 1000 ))
	(( DEC = $mantissa / 2 ** $exponent + 5 ))
	(( DEC = $DEC % 1000 ))

	FPString=$(printf '%d.%2.2d' "$INT" "$DEC")
	FPStringLen=${#FPString}
	FPString=${FPString:0:FPStringLen-1}
	echo $FPString
}

function EncodeLinear16()
{
	local -i DecPtIndex
	local -i INT
	local -i DEC
	local -i mantissa
	local -i DecLEN
	local -i exp10
	local -i exponent
	local -i MULT
	local -i REM
	local Negative="0"

	if [[ $# -ne 2 ]]; then
		echo "Call made to function 'EncodeLinear16' with incorrect number of parameters ($#)."
		exit
	fi

	Linear16=$1
	exponent=$2

	if [ "${Linear16:0:1}" = "-" ]; then
		Negative=1
		Linear16="${Linear16:1}"
	fi

	DecPtIndex=$(expr index "$Linear16" ".")

	if [[ $DecPtIndex -eq 0 ]]; then
		(( INT = 10#$Linear16 ))
		(( DEC = 0 ))
		(( DecPtIndex = $(expr ${#Linear16}) ))
	elif [[ $DecPtIndex -eq 1 ]]; then
		(( DEC = 10#$Linear16 ))
		(( INT = 0 ))
	else
		(( INT = 10#${Linear16:0:$DecPtIndex-1} ))
		(( DEC = 10#${Linear16:$DecPtIndex} ))
	fi

	(( DecLEN = $(expr ${#Linear16}) - $DecPtIndex ))
	(( exp10 = 10 ** $DecLEN ))

	(( MULT = 2 ** $exponent ))

	(( mantissa = $INT * $MULT + ($DEC * $MULT) / $exp10 ))
	if [ "$Negative" = "1" ]; then
		(( mantissa = ($mantissa ^ 32767) + 1 ))
	fi

	echo $(printf '%4.4x\n' "$mantissa")
}

function DecodeLinear11()
{
	local -i mantissa
	local Linear11
	local -i exponent
	local -i INT
	local -i DEC
	local FPString
	local -i tenspower
	local NegativeMan="0"

	if [[ $# -lt 1 ]]; then
		echo "Call made to function 'DecodeLinear11' with insufficient number of parameters ($#)."
		exit
	fi

	Linear11=$1

	(( mantissa = 10#$(printf '%d\n' "$Linear11") ))
	(( mantissa = $mantissa & 2047 ))

	if [ $mantissa -gt 1023 ]; then
		(( mantissa = ($mantissa ^ 2047) + 1 ))
		NegativeMan="1"
	fi

	(( exponent = 10#$(printf '%d\n' "${Linear11:0:4}" ) ))
	(( exponent = $exponent >> 3 ))

	if [[ $exponent -gt 15 ]]; then

		(( DEC = 1 ))
		(( exponent = (exponent ^ 31) + 1 ))
		(( tenspower = -1 ))

		while [[ $DEC -ne 0 ]]; do
			(( tenspower++ ))
			(( DEC = ($mantissa * (10 ** $tenspower)) % (2 ** $exponent) ))
		done

		(( INT = (($mantissa * (10 ** $tenspower)) / (2 ** $exponent)) / (10 ** $tenspower) ))
		(( DEC = (($mantissa * (10 ** $tenspower)) / (2 ** $exponent)) % (10 ** $tenspower) ))

		Decimal="$DEC"


		while [[ ${#Decimal} -lt $tenspower ]]; do
			Decimal="0$Decimal"
		done

		FPString="$INT.$Decimal"
		if [[ $INT -ne 0 ]]; then

			if [[ ${#FPString} -gt 5 ]]; then

				(( LEN = ${#FPString} - 6 ))
				FPString=${FPString:0:5}

				(( DecPtIndex = $(expr index "$FPString" ".") ))
				(( Diff = ${#FPString} - DecPtIndex ))
				(( Decimal = 10#$Decimal + 5 * (10 ** LEN) ))

				FPString="$INT.$Decimal"
				FPString=${FPString:0:5}
			fi
		fi
		if [ "$NegativeMan" = "1" ]; then
			FPString="-$FPString"
		fi
	else
		(( INT = $mantissa * (2 ** $exponent) ))
		FPString="$INT"

		if [ "$NegativeMan" = "1" ]; then
			FPString="-$FPString"
		fi
	fi

	echo $FPString
}

function EncodeLinear11()
{
	local Linear11
	local NegativeMan="0"
	local NegativeExp="0"
	local -i DecPtIndex
	local -i INT
	local -i DEC
	local -i DecLEN
	local -i exp10
	local -i mantissa
	local -i exponent

	if [[ $# -ne 1 ]]; then
		echo "Call made to function 'EncodeLinear11' with insufficient number of parameters ($#)."
		exit
	fi

	Linear11=$1

	if [ "${Linear11:0:1}" = "-" ]; then
		NegativeMan="1"
		Linear11="${Linear11:1}"
	fi

	(( DecPtIndex = $(expr index "$Linear11" ".") ))

	if [[ $DecPtIndex -eq 0 ]]; then

		(( INT = 10#$Linear11 ))
		(( DEC = 0 ))
		(( DecPtIndex = ${#Linear11} ))

	elif [[ $DecPtIndex -eq 1 ]]; then
		(( DEC = $(expr 10#${Linear11:1}) ))
		(( INT = 0 ))
	else
		(( INT = 10#${Linear11:0:$DecPtIndex-1} ))
		(( DEC = 10#${Linear11:$DecPtIndex} ))
	fi

	(( DecLEN = $(expr ${#Linear11}) - $DecPtIndex ))

	(( exp10 = 10 ** $DecLEN ))

	(( mantissa = $INT + $DEC  / $exp10 ))

	if [[ $mantissa -gt 1023 ]]; then

		(( exponent = 0 ))

		while [[ $mantissa -ge 512 ]];	do
			(( exponent++ ))
			(( mantissa = $INT / (2 ** $exponent) + ($DEC / (2 ** $exponent)) / $exp10 ))
		done

	elif [[ $mantissa -ge 512 ]]; then

		(( exponent = 0 ))
		(( mantissa = $INT + $DEC / $exp10 ))
	else
		(( exponent = 0 ))
		(( mantissa = 1 ))

		while [[ $mantissa -lt 511 ]];	do
			(( exponent++ ))
			(( mantissa = $INT * (2 ** $exponent) + ($DEC * (2 ** $exponent)) / $exp10 ))
		done

		(( exponent = ( $exponent ^ 31 ) + 1 ))

	fi

	if [ "$NegativeMan" = "1" ]; then
		(( mantissa = ( $mantissa ^ 2047 ) + 1 ))
	fi

	if [[ $(( exponent & 1 )) = 1 ]]; then
		(( mantissa = $mantissa | 2048 ))
	fi

	(( exponent = $exponent >> 1 ))

	echo "$(printf '%1.1x' $exponent)$(printf '%3.3x' $mantissa)"
}

function FixedEncodeLinear11()
{
	local Negative="0"
	local Linear11
	local -i exponent
	local -i mantissa
	local -i INT
	local -i DEC
	local -i DecPtIndex
	local -i DecLEN
	local -i exp10

	if [[ $# -ne 2 ]]; then
		echo "Call made to function 'FixedEncodeLinear11' with insufficient number of parameters ($#)."
		exit
	fi

	Linear11=$1
	(( exponent = $2 ))

	if [ "${Linear11:0:1}" = "-" ]; then
		Negative="1"
		Linear11="${Linear11:1}"
	fi

	(( DecPtIndex = $(expr index "$Linear11" "." ) ))

	if [[ $DecPtIndex -eq 0 ]]; then
		(( INT = 10#$Linear11 ))
		(( DEC = 0 ))
	else
		if [[ $DecPtIndex -eq 1 ]]; then
			(( DEC = 10#$Linear11 ))
			(( INT = 0 ))
		else
			(( INT = 10#${Linear11:0:$DecPtIndex - 1} ))
			(( DEC = 10#${Linear11:$DecPtIndex} ))
		fi
	fi

	(( DecLEN = $(expr ${#Linear11}) - $DecPtIndex ))
	(( exp10 = 10 ** $DecLEN ))

	(( mantissa = $INT * (2 ** $exponent) + ($DEC * (2 ** $exponent)) / $exp10 ))

	if [[ "$Negative" = "1" ]]; then
		(( mantissa = ($mantissa ^ 2047) + 1 ))
	fi

	(( exponent = ( $exponent ^ 31 ) + 1 ))

	if [ $(( $exponent & 1 )) -eq 1 ]; then
		(( mantissa = $mantissa & 2048 ))
	fi

	(( exponent = $exponent >> 1 ))

	echo "$(printf '%1.1x\n' "$exponent")$(printf '%3.3x\n' "$mantissa"))"
}

function dec2bin()
{
 	local bin=""
    local padding=""
    local base2=(0 1)
	local Byte

	if [[ $# -ne 1 ]]; then
		echo "Call made to function 'dec2bin' with insufficient number of parameters ($#)."
		exit
	fi

	(( Byte = $1 ))

    while [[ $Byte -gt 0 ]]; do
		bin="${base2[$(($Byte % 2))]}$bin"
		(( Byte = $Byte / 2 ))
    done

	if [[ ${#bin} -eq 0 ]]; then
		bin="0"
	fi

    if [ $((8 - (${#bin} % 8))) -ne 8 ]; then
		printf -v padding '%*s' $((8 - (${#bin} % 8))) ''
		padding=${padding// /0}
    fi

	echo $padding$bin
}

function CompletionCodes()
{
	local CCRC=0
	local ErrorString
	
	if [[ $# -ne 1 ]]; then
		echo "Call made to function 'CompletionCodes' with insufficient number of parameters ($#)."
		exit
	fi

	CC="$1"

	if [ "$CC" = "0x80" ]; then
		ErrorString="Command response timeout. SMBUS device was not present."
	elif [ "$CC" = "0x81" ]; then
		ErrorString="Command not serviced. Not able to allocate the resources for serving this command at this time. Retry needed."
		(( CCRC = 1 ))
	elif [ "$CC" = "0x82" ]; then
		ErrorString="Illegal SMBUS PSU Address Command."
	elif [ "$CC" = "0xa1" ]; then
		ErrorString="Illegal SMBUS PSU Address Target Address."
	elif [ "$CC" = "0xa2" ]; then
		ErrorString="PEC error."
	elif [ "$CC" = "0xa3" ]; then
		ErrorString="Illegal First Register Offset."
	elif [ "$CC" = "0xa5" ]; then
		ErrorString="Unsupported Write Length."
	elif [ "$CC" = "0xa6" ]; then
		ErrorString="Unexpected Data Offset field value."
	elif [ "$CC" = "0xaa" ]; then
		ErrorString="SMBUS timeout."
		(( CCRC = 1 ))
	elif [ "$CC" = "0xc0" ]; then
		ErrorString="Node Busy. Command could not be processed because command processing resources are temporarily unavailable."
		(( CCRC = 1 ))
	elif [ "$CC" = "0xc1" ]; then
		ErrorString="Invalid Command."
	elif [ "$CC" = "0xc2" ]; then
		ErrorString="Command invalid for given LUN."
	elif [ "$CC" = "0xc3" ]; then
		ErrorString="Timeout while processing command. Response unavailable."
		(( CCRC = 1 ))
	elif [ "$CC" = "0xc4" ]; then
		ErrorString="Out of space. Command could not be completed because of a lack of storage space required to execute the given command operation."
	elif [ "$CC" = "0xc5" ]; then
		ErrorString="Reservation Cancelled or Invalid Reservation ID."
	elif [ "$CC" = "0xc6" ]; then
		ErrorString="Request data truncated."
	elif [ "$CC" = "0xc7" ]; then
		ErrorString="Request data length invalid."
	elif [ "$CC" = "0xc8" ]; then
		ErrorString="Request data field length limit exceeded."
	elif [ "$CC" = "0xc9" ]; then
		ErrorString="Parameter out of range. One or more parameters in the data field of the Request are out of range."
	elif [ "$CC" = "0xca" ]; then
		ErrorString="Cannot return number of requested data bytes."
	elif [ "$CC" = "0xcb" ]; then
		ErrorString="Requested Sensor, data, or record not present."
	elif [ "$CC" = "0xcc" ]; then
		ErrorString="Invalid data field in Request."
	elif [ "$CC" = "0xcd" ]; then
		ErrorString="Command illegal for specified sensor or record type."
	elif [ "$CC" = "0xce" ]; then
		ErrorString="Command response could not be provided."
		(( CCRC = 1 ))
	elif [ "$CC" = "0xcf" ]; then
		ErrorString="Cannot execute duplicated request."
	elif [ "$CC" = "0xd0" ]; then
		ErrorString="Command response could not be provided. SDR Repository in update mode."
	elif [ "$CC" = "0xd1" ]; then
		ErrorString="Command response could not be provided. Device in firmware update mode."
	elif [ "$CC" = "0xd2" ]; then
		ErrorString="Command response could not be provided. BMC initialization or initialization agent in progress."
	elif [ "$CC" = "0xd3" ]; then
		ErrorString="Destination unavailable. Cannot deliver request to selected destination."
	elif [ "$CC" = "0xd4" ]; then
		ErrorString="Cannot execute command due to insufficient privilege level or other security-based restriction."
	elif [ "$CC" = "0xd5" ]; then
		ErrorString="Cannot execute command. Command, or request parameter(s), not supported in present state."
	elif [ "$CC" = "0xd6" ]; then
		ErrorString="Cannot execute command. Parameter is illegal because command sub-function has been disabled or is unavailable."
	elif [ "$CC" = "0xff" ]; then
		ErrorString="Unspecified error."
	else
		ErrorString="Unknown Completion Code."
	fi

	if [ "$SuppErr" = "0" ]; then
		echo $ErrorString
	fi

	return $CCRC
}

function send_IPMICmd()
{
	local Cmd
	local CC
	local CMLCmd
	local CMLResponse
	local Byte
	local bin
	local -i RC=1
	local Resp
	local __Response=$2
	local -i Retries
	local Retry
	
	if [[ $# -ne 2 ]]; then
		echo "Call made to function 'send_IPMICmd' with insufficient number of parameters ($#)."
		exit
	fi

	Cmd="$1"
	(( Retries = 0 ))
	Retry="1"

	while [[ $RC -ne 0 ]] && [[ $Retries -le 10 ]] && [ "$Retry" = "1" ]; do
	
		(( RC = 0 ))
		if [[ $Retries -gt 0 ]]; then
		
			echo 
			echo "   Retrying command..."
			echo
			sleep 5
		fi

		Resp=$($Cmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

		if [ "$Show" = "1" ]; then
			echo "IPMI Cmd = ${Cmd:8}"
			echo "IPMI Rsp = $Resp"
			echo
		fi

		CC="${Resp:10:4}"

		if [ "$CC" != "0x00" ]; then
			if [ "$SuppErr" = "0" ]; then
			
				if [ "$Show" != "1" ]; then
					echo "IPMI Cmd = ${Cmd:8}"
					echo "IPMI Rsp = $Resp"
				fi

				echo "Error: Completion Code = $CC"
			fi
			
			(( RC = 1 ))
			CompletionCodes "$CC"
			Retry="$?"
		fi

		CMLCmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e ${Cmd:48:9} 0x00 0x04 0x02 0x06 0x02 0x00 0x7e"
		CMLResponse=$($CMLCmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

		CC="${CMLResponse:10:4}"
		if [ "$CC" != "0x00" ]; then
			if [ "$SuppErr" = "0" ]; then
				echo "IPMI Cmd = ${CMLCmd:8}"
				echo "IPMI Rsp = $CMLResponse"
				echo "Error while checking status: Completion Code = $CC"
			fi
			(( RC = 1 ))

			CompletionCodes "$CC"
			Retry="$?"
			if [ "$CC" != "0x80" ]; then
				clear_errors "${Cmd:48:9}" "0x00"
			fi
		else

			if [ "${CMLResponse:35:4}" != "0x00" ]; then
				if [ "$SuppErr" = "0" ]; then
					echo

					if [ "$Show" != "1" ]; then
						echo "IPMI Cmd = ${Cmd:8}"
						echo "IPMI Rsp = $Resp"
						echo
						echo "Communication Error detected on page 0 for previous command."
					else
						echo "Communication Error detected on page 0 for previous command."
						echo
						echo "IPMI Cmd = ${CMLCmd:8}"
						echo "IPMI Rsp = $CMLResponse"
					fi
				
					Byte=`expr $(printf '%d\n' ${CMLResponse:35:4})`
					bin=$(dec2bin $Byte)
					echo

					if [ "${bin:0:1}" = "1" ]; then
						echo "Slave received an invalid or unsupported command."
					fi
					if [ "${bin:1:1}" = "1" ]; then
						echo "IPM2 Data Format Error occurred.."
					fi
					if [ "${bin:2:1}" = "1" ]; then
						echo "Slave received an error PEC code."
					fi
					if [ "${bin:3:1}" = "1" ]; then
						echo "Error: bit 4 is undefined yet is asserted in response"
					fi
					if [ "${bin:4:1}" = "1" ]; then
						echo "Error: bit 3 is undefined yet is asserted in response"
					fi
					if [ "${bin:5:1}" = "1" ]; then
						echo "Error: bit 2 is undefined yet is asserted in response"
					fi
					if [ "${bin:6:1}" = "1" ]; then
						echo "Error: bit 1 is undefined yet is asserted in response"
					fi
					if [ "${bin:7:1}" = "1" ]; then
						echo "Error: bit 0 is undefined yet is asserted in response"
					fi
				fi

				clear_errors "${Cmd:48:9}" "0x00"
				(( RC = 1 ))
				Retry="0"
			fi

			CMLCmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e ${Cmd:48:9} 0x00 0x04 0x02 0x06 0x02 0x01 0x7e"
			CMLResponse=$($CMLCmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

			CC="${CMLResponse:10:4}"
			if [ "$CC" != "0x00" ]; then
				if [ "$SuppErr" = "0" ]; then
					echo "IPMI Cmd = ${CMLCmd:8}"
					echo "IPMI Rsp = $CMLResponse"
					echo "Error while checking status: Completion Code = $CC"
				fi
				
				(( RC = 1 ))

				CompletionCodes "$CC"
				Retry="$?"
				if [ "$CC" != "0x80" ]; then
					clear_errors "${Cmd:48:9}" "0x01"
				fi
			else

				if [ "${CMLResponse:35:4}" != "0x00" ]; then
					if [ "$SuppErr" = "0" ]; then
						echo

						if [ "$Show" != "1" ]; then
							echo "IPMI Cmd = ${Cmd:8}"
							echo "IPMI Rsp = $Resp"
							echo
							echo "Communication Error detected on page 1 for previous command."
						else
							echo "Communication Error detected on page 1 for previous command."
							echo
							echo "IPMI Cmd = ${CMLCmd:8}"
							echo "IPMI Rsp = $CMLResponse"
						fi
					
						Byte=`expr $(printf '%d\n' ${CMLResponse:35:4})`
						bin=$(dec2bin $Byte)
						echo

						if [ "${bin:0:1}" = "1" ]; then
							echo "Slave received an invalid or unsupported command."
						fi
						if [ "${bin:1:1}" = "1" ]; then
							echo "IPM2 Data Format Error occurred.."
						fi
						if [ "${bin:2:1}" = "1" ]; then
							echo "Slave received an error PEC code."
						fi
						if [ "${bin:3:1}" = "1" ]; then
							echo "Error: bit 4 is undefined yet is asserted in response"
						fi
						if [ "${bin:4:1}" = "1" ]; then
							echo "Error: bit 3 is undefined yet is asserted in response"
						fi
						if [ "${bin:5:1}" = "1" ]; then
							echo "Error: bit 2 is undefined yet is asserted in response"
						fi
						if [ "${bin:6:1}" = "1" ]; then
							echo "Error: bit 1 is undefined yet is asserted in response"
						fi
						if [ "${bin:7:1}" = "1" ]; then
							echo "Error: bit 0 is undefined yet is asserted in response"
						fi
					fi

					clear_errors "${Cmd:48:9}" "0x01"
					(( RC = 1 ))
					Retry="0"
				else

					Resp="${Resp#'0xbc 0xd9 0x00 0x57 0x01 0x00 '}"
					Resp="${Resp%%" "}"
				fi
			fi
		fi
		
		(( Retries++ ))
	done

	if [[ $RC = 0 ]]; then
		eval "$2='$Resp'"
	else
		eval "$2='Error'"
	fi

	return $RC
}

function clear_errors
{
	local PSUAddress=$1
	local Response
	local CC
	local -i RC=0
	local Cmd
	local CurrentPage="0x00"
	local PageToClear=$2

	if [ "$Verbose" = "1" ]; then
		echo "Clearing PSU faults."
		echo
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x00"
	Response=$($Cmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

	if [ "$Show" = "1" ]; then
		echo "IPMI Cmd = ${Cmd:8}"
		echo "IPMI Rsp = $Response"
		echo
	fi
	
	CC="${Response:10:4}"

	if [ "$CC" != "0x00" ]; then
		if [ "$SuppErr" = "0" ]; then
			if [ "$Show" != "1" ]; then
				echo "IPMI Cmd = ${Cmd:8}"
				echo "IPMI Rsp = $Response"
				echo
			fi
			
			echo "Error: Completion Code = $CC, setting page to default (0)."
			echo
			
			CompletionCodes "$CC"
		fi
		
		(( RC = 1 ))
	else
		if [ -n "$CurrentPage" ]; then
			CurrentPage="${Response:30:4}"
		else
			if [ "$SuppErr" = "0" ]; then
				echo
				echo "Current page could not be read."
				echo
			fi
			
			(( RC = 1 ))
		fi
	fi

	if [ "$CurrentPage" != "$PageToClear" ]; then
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x00 $PageToClear"
		Response=$($Cmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

		if [ "$Show" = "1" ]; then
			echo "IPMI Cmd = ${Cmd:8}"
			echo "IPMI Rsp = $Response"
			echo
		fi
		
		CC="${Response:10:4}"

		if [ "$CC" != "0x00" ]; then
			if [ "$SuppErr" = "0" ]; then
				if [ "$Show" != "1" ]; then
					echo "IPMI Cmd = ${Cmd:8}"
					echo "IPMI Rsp = $Response"
					echo
				fi
				
				echo "Error: Completion Code = $CC."
				echo
				
				CompletionCodes "$CC"
			fi
			
			(( RC = 1 ))
		fi
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x80 $PSUAddress 0x00 0x01 0x00 0x03"
	Response=$($Cmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

	if [ "$Show" = "1" ]; then
		echo "IPMI Cmd = ${Cmd:8}"
		echo "IPMI Rsp = $Response"
		echo
	fi
	
	CC="${Response:10:4}"

	if [ "$CC" != "0x00" ]; then
		if [ "$SuppErr" = "0" ]; then
			if [ "$Show" != "1" ]; then
				echo "IPMI Cmd = ${Cmd:8}"
				echo "IPMI Rsp = $Response"
				echo
			fi
			
			echo "Error: Completion Code = $CC."
			echo
			
			CompletionCodes "$CC"
		fi
		
		(( RC = 1 ))
	fi

	if [ "$CurrentPage" != "$PageToClear" ]; then
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x00 $CurrentPage"
		Response=$($Cmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

		if [ "$Show" = "1" ]; then
			echo "IPMI Cmd = ${Cmd:8}"
			echo "IPMI Rsp = $Response"
			echo
		fi
		
		CC="${Response:10:4}"

		if [ "$CC" != "0x00" ]; then
			if [ "$SuppErr" = "0" ]; then
				if [ "$Show" != "1" ]; then
					echo "IPMI Cmd = ${Cmd:8}"
					echo "IPMI Rsp = $Response"
					echo
				fi
				
				echo "Error: Completion Code = $CC."
				echo
				
				CompletionCodes "$CC"
			fi
			
			(( RC = 1 ))
		fi
	fi

	return $RC
}

function page()
{
	local -i RC=0
	local Cmd
	local PSU
	local PSUAddress
	local WR
	local Page
	local Response="none"

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'page' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "0" ]; then
		if [ "$Verbose" = "1" ]; then
			echo
			echo "page - Reading current PSU $PSU Page..."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x00"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then
			Page=$(printf '%d\n' $Response)
			echo "Page = $Page"
		fi

		if [[ $# -eq 3 ]] ; then
			eval "$3='$Response'"
		fi
	else

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'page' with insufficient number of parameters $#."
			exit
		fi

		Page=$3

		if [ "${Page:0:2}" != "0x" ]; then
			Page=$(printf '0x%2.2x\n' $Page)
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "page - Setting page number for PSU $PSU to $Page..."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x00 $Page"
 		send_IPMICmd "$Cmd" $Response
		RC=$?
	fi

	return $RC
}

function clear_faults
{
	local -i RC=0
	local Cmd
	local PSU
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'clear_faults' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "clear_faults - Clearing PSU faults for PSU $PSU..."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x80 $PSUAddress 0x00 0x01 0x00 0x03"
	send_IPMICmd "$Cmd" Response
	RC=$?
	return $RC
}

function page_plus_write
{
	local -i RC=0
	local Cmd
	local PSU
	local PSUAddress
	local Response
	local Page
	local STSCmd
	local Mask
	local STS

	if [[ $# -lt 4 ]] ; then
		echo "Call made to function 'page_plus_write' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	Page=$2
	STSCmd=$3
	Mask=$4

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "page_plus_write - Sending page_plus_write command to PSU $PSU for command 'status_$STSCmd' on page $Page with mask = '$Mask'."
	fi

	if [ "$STSCmd" = "byte" ]; then
		STS="0x78"
	elif [ "$STSCmd" = "vout" ]; then
		STS="0x7a"
	elif [ "$STSCmd" = "iout" ]; then
		STS="0x7b"
	elif [ "$STSCmd" = "input" ]; then
		STS="0x7c"
	elif [ "$STSCmd" = "temp" ]; then
		STS="0x7d"
	elif [ "$STSCmd" = "cml" ]; then
		STS="0x7e"
	elif [ "$STSCmd" = "ocw" ]; then
		STS="0xdd"
	else
		echo "page_plus_write: invalid status_command"
		RC=2
	fi

	if [ "${Page:0:2}" != "0x" ]; then
		Page=$(printf '0x%2.2x\n' $Page)
	fi

	if [[ $RC -eq 0 ]]; then
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x05 0x00 0x05 0x03 $Page $STS $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	fi

	return $RC
}


function page_plus_read
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Page
	local STSCmd
	local Bytes
	local Byte
	local Byte1
	local Byte2
	local STS
	local bin

	if [[ $# -lt 3 ]] ; then
		echo "Call made to function 'page_plus_read' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	Page=$2
	STSCmd=$3

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "page_plus_read - Sending page_plus_read command to PSU $PSU on page $Page for command 'status_$STSCmd'."
	fi

	Bytes="0x02"
	if [ "$STSCmd" = "byte" ]; then
		STS="0x78"
	elif [ "$STSCmd" = "word" ]; then
		STS="0x79"
		Bytes="0x03"
	elif [ "$STSCmd" = "vout" ]; then
		STS="0x7a"
	elif [ "$STSCmd" = "iout" ]; then
		STS="0x7b"
	elif [ "$STSCmd" = "input" ]; then
		STS="0x7c"
	elif [ "$STSCmd" = "temp" ]; then
		STS="0x7d"
	elif [ "$STSCmd" = "cml" ]; then
		STS="0x7e"
	elif [ "$STSCmd" = "ocw" ]; then
		STS="0xdd"
	else
		echo "page_plus_read: invalid status_command"
		RC=2
	fi

	if [ "${Page:0:2}" != "0x" ]; then
		Page=$(printf '0x%2.2x\n' $Page)
	fi

	if [[ $RC -eq 0 ]]; then

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e $PSUAddress 0x00 0x04 $Bytes 0x06 0x02 $Page $STS"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [ "$STSCmd" = "word" ]; then
				Byte=$(printf '%d\n' ${Response:5:4})
				bin=$(dec2bin $Byte)
				Byte1=$bin
				Byte=$(printf '%d\n' ${Response:10:4})
				bin=$(dec2bin $Byte)
				Byte2=$bin

				if [[ $# -eq 4 ]] ; then
					eval "$4='${Response:5:9}'"
				fi

				echo
				echo "Page $Page register 'status_$STSCmd' returned '$Byte1 $Byte2'b."
				echo

				echo "${Byte1:0:1} - Unit is too busy to respond to PMBus communications."
				echo "${Byte1:1:1} - This bit is asserted if the unit is not providing power to the output."
				echo "${Byte1:2:1} - An output overvoltage fault has occurred."
				echo "${Byte1:3:1} - An output overcurrent fault has occurred."
				echo "${Byte1:4:1} - An input undervoltage fault has occurred."
				echo "${Byte1:5:1} - A temperature fault or warning has occurred."
				echo "${Byte1:6:1} - A communications, memory or logic fault has occurred."
				echo "${Byte1:7:1} - Low Byte bit 0 is undefined."
				echo
				echo "${Byte2:0:1} - An output voltage fault or warning has occurred."
				echo "${Byte2:1:1} - An output current or output power fault or warning has occurred."
				echo "${Byte2:2:1} - An input voltage, input current, or input power fault or warning has occurred."
				echo "${Byte2:3:1} - High Byte bit 4 is undefined."
				echo "${Byte2:4:1} - The POWER_GOOD signal, if present, is negated."
				echo "${Byte2:5:1} - A fan or airflow fault or warning has occurred."
				echo "${Byte2:6:1} - An advanced feature event has occurred."
				echo "${Byte2:7:1} - High Byte bit 0 is undefined."
			else
				Byte=$(printf '%d\n' ${Response:5:4})

				bin=$(dec2bin $Byte)

				if [[ $# -eq 4 ]] ; then
					eval "$4='${Response:5:4}'"
				fi

				echo
				echo "Page $Page register 'status_$STSCmd' returned '${bin:0:4} ${bin:4:4}'b."
				echo

				if [ "$STSCmd" = "input" ]; then
					echo "${bin:0:1} - Bit 7 is undefined."
					echo "${bin:1:1} - Bit 6 is undefined."
					echo "${bin:2:1} - Line Input Undervoltage Warning."
					echo "${bin:3:1} - Line Input Undervoltage Fault."
					echo "${bin:4:1} - Unit Off for Low Input Voltage."
					echo "${bin:5:1} - Bit 2 is undefined."
					echo "${bin:6:1} - Input Overcurrent Warning."
					echo "${bin:7:1} - Input Overpower Warning."
				elif [ "$STSCmd" = "temp" ]; then
					echo "${bin:0:1} - Overtemperature Fault."
					echo "${bin:1:1} - Overtemperature Warning."
					echo "${bin:2:1} - Bit 5 is undefined."
					echo "${bin:3:1} - Bit 4 is undefined."
					echo "${bin:4:1} - Bit 3 is undefined."
					echo "${bin:5:1} - Bit 2 is undefined."
					echo "${bin:6:1} - Bit 1 is undefined."
					echo "${bin:7:1} - Bit 0 is undefined."
				elif [ "$STSCmd" = "iout" ]; then
					echo "${bin:0:1} - Output Overcurrent Fault."
					echo "${bin:1:1} - Bit 6 is undefined."
					echo "${bin:2:1} - PSU Primary Output Overcurrent Warning."
					echo "${bin:3:1} - Bit 4 is undefined."
					echo "${bin:4:1} - Bit 3 is undefined."
					echo "${bin:5:1} - Bit 2 is undefined."
					echo "${bin:6:1} - PSU Output Overpower Fault."
					echo "${bin:7:1} - PSU Output Overpower Warning."
				elif [ "$STSCmd" = "cml" ]; then
					echo "${bin:0:1} - Slave received an invalid or unsupported command."
					echo "${bin:1:1} - IPM2 Data Format Error."
					echo "${bin:2:1} - Slave received an error PEC code."
					echo "${bin:3:1} - Bit 4 is undefined."
					echo "${bin:4:1} - Bit 3 is undefined."
					echo "${bin:5:1} - Bit 2 is undefined."
					echo "${bin:6:1} - Bit 1 is undefined."
					echo "${bin:7:1} - Bit 0 is undefined."
				elif [ "$STSCmd" = "vout" ]; then
					echo "${bin:0:1} - Output Overvoltage Fault."
					echo "${bin:1:1} - Bit 6 is undefined."
					echo "${bin:2:1} - Bit 5 is undefined."
					echo "${bin:3:1} - Output Undervoltage Fault."
					echo "${bin:4:1} - Bit 3 is undefined."
					echo "${bin:5:1} - Supply has not been able to turn on and assert POK within 4 seconds."
					echo "${bin:6:1} - Bit 1 is undefined."
					echo "${bin:7:1} - Bit 0 is undefined."
				elif [ "$STSCmd" = "byte" ]; then
					echo "${bin:0:1} - Unit is too busy to respond to PMBus communications."
					echo "${bin:1:1} - The unit is not providing power to the output."
					echo "${bin:2:1} - An output overvoltage fault has occurred."
					echo "${bin:3:1} - An output overcurrent fault has occurred."
					echo "${bin:4:1} - An input undervoltage fault has occurred."
					echo "${bin:5:1} - A temperature fault or warning has occurred."
					echo "${bin:6:1} - A communications, memory or logic fault has occurred."
					echo "${bin:7:1} - Bit 0 is undefined."
				elif [ "$STSCmd" = "ocw" ]; then
					echo "${bin:0:1} - Bit 7 is undefined."
					echo "${bin:1:1} - Bit 6 is undefined."
					echo "${bin:2:1} - Bit 5 is undefined."
					echo "${bin:3:1} - Bit 4 is undefined."
					echo "${bin:4:1} - Bit 3 is undefined."
					echo "${bin:5:1} - OCW3 has occurred."
					echo "${bin:6:1} - OCW2 has occurred."
					echo "${bin:7:1} - OCW1 has occurred."
				fi
			fi
		fi
	fi
	
	echo
	return $RC
}

function status_all
{
	local -i RC=0
	local PSU
	local Page
	local STSCmd

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'status_all' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR="0"
	Page="0x00"
	STSCmd="input"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="temp"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="iout"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="cml"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="vout"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="ocw"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	
	Page="0x01"
	STSCmd="input"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="temp"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="iout"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="cml"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="vout"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="ocw"
	page_plus_read $PSU $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	status_fans_1_2 $PSU $WR
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	status_other $PSU $WR
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	
	return $RC
}

function firmware_update_capability
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin
	local Time

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'firmware_update_capability' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "firmware_update_capability - Reading PSU $PSU FW update capability."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x05 0xf2"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ RC -eq 0 ]]; then

		Byte=$(printf '%d\n' ${Response:5:4})

		bin=$(dec2bin $Byte)

		echo
		echo "Byte 1: '${bin:0:4} ${bin:4:4}'b"
		echo

		echo "${bin:0:1} - Bit 7 is reserved."
		echo "${bin:1:1} - Bit 6 is reserved."
		echo "${bin:2:1} - Bit 5 is reserved."
		echo "${bin:3:1} - Bit 4 is reserved."
		echo "${bin:4:1} - Bit 3 is reserved."

		if [ "${bin:5:1}" = "1" ]; then
			echo "${bin:5:1} - Primary firmware update is supported."
		else
			echo "${bin:5:1} - Primary firmware update is not supported."
		fi
		if [ "${bin:6:1}" = "1" ]; then
			echo "${bin:6:1} - 32-byte data blocks are supported."
		else
			echo "${bin:6:1} - 32-byte data blocks are not supported."
		fi
		if [ "${bin:7:1}" = "1" ]; then
			echo "${bin:7:1} - 16-byte data blocks are supported."
		else
			echo "${bin:7:1} - 16-byte data blocks are not supported."
		fi
		
		echo
		
		if [ "${Response:10:4}" = "0x00" ]; then

			echo "Time to erase firmware image in DSP’s non-volatile memory = 1500 msec \(system default\)"
		else
			Byte=$(printf '%d\n' ${Response:10:4})
				
			MultFP $Byte "100" Product
			Time="$Product"
			
			echo "Time to erase firmware image in DSP’s non-volatile memory = $Time msec"
			echo
		fi
		
		echo
		
		if [ "${Response:15:4}" = "0x00" ]; then

			echo "Time to write 16-byte block to DSP’s non-volatile memory = 10 msec \(system default\)"
		else
			Byte=$(printf '%d\n' ${Response:15:4})
				
			echo "Time to write 16-byte block to DSP’s non-volatile memory = $Byte msec"
			echo
		fi
		
		echo
		
		if [ "${Response:20:4}" = "0x00" ]; then

			echo "Time to write 32-byte block to DSP’s non-volatile memory = TBD msec \(system default\)"
		else
			Byte=$(printf '%d\n' ${Response:20:4})
			
			echo "Time to write 32-byte block to DSP’s non-volatile memory = $Byte msec"
			echo
		fi
		
		echo
	fi

	return $RC
}

function firmware_update_status_flag
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin
	local -i Resets

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'firmware_update_status_flag' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "firmware_update_status_flag - Reading PSU $PSU FW update status flag."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xf3"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ RC -eq 0 ]]; then

		Byte=$(printf '%d\n' ${Response:0:4})

		bin=$(dec2bin $Byte)

		echo
		echo "Returned: '${bin:0:4} ${bin:4:4}'b"
		echo

		echo "${bin:0:1} - Bit 7 is reserved."
		echo "${bin:1:1} - Bit 6 is reserved."
		if [ "${bin:2:1}" = "0" ] && [ "${bin:3:1}" = "0" ]; then
			(( Resets = 0 ))
		elif [ "${bin:2:1}" = "0" ] && [ "${bin:3:1}" = "1" ]; then
			(( Resets = 1 ))
		elif [ "${bin:2:1}" = "1" ] && [ "${bin:3:1}" = "0" ]; then
			(( Resets = 2 ))
		else
			(( Resets = 3 ))
		fi
		
		echo "Bits 5:4 - Sequence has been reset $Resets times."
		
		if [ "${bin:4:1}" = "1" ]; then
			echo "${bin:4:1} - Boot to PMOS mode has started."
		else
			echo "${bin:4:1} - Boot to PMOS mode has not started."
		fi
		if [ "${bin:5:1}" = "1" ]; then
			echo "${bin:5:1} - Primary firmware update has completed."
		else
			echo "${bin:5:1} - Primary firmware update has not completed."
		fi
		if [ "${bin:6:1}" = "1" ]; then
			echo "${bin:6:1} - Firmware image erasure operation has started."
		else
			echo "${bin:6:1} - Firmware image erasure operation has not started."
		fi
		if [ "${bin:7:1}" = "1" ]; then
			echo "${bin:7:1} - Boot to ISP mode has started."
		else
			echo "${bin:7:1} - Boot to ISP mode has not started."
		fi
		
		echo
	fi

	return $RC
}

function capability
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'capability' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "capability - Reading PSU $PSU capabilities."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x19"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		Byte=$(printf '%d\n' ${Response:0:4})

		bin=$(dec2bin $Byte)

		echo
		echo "Returned '${bin:0:4} ${bin:4:4}'b"
		echo

		if [ "${bin:0:1}" = "1" ]; then
			echo "${bin:0:1} - Packet Error Checking is supported ."
		else
			echo "${bin:0:1} - Packet Error Checking not supported."
		fi
		echo "${bin:1:1} - Bit 6 is reserved."
		if [ "${bin:2:1}" = "1" ]; then
			echo "${bin:2:1} - Maximum supported bus speed is 400 kHz."
		else
			echo "${bin:2:1} - Maximum supported bus speed is 100 kHz."
		fi
		if [ "${bin:3:1}" = "1" ]; then
			echo "${bin:3:1} - The device has a SMBALERT# pin and supports the SMBus Alert Response protocol."
		else
			echo "${bin:3:1} - The device does not have a SMBALERT# pin."
		fi
		echo "${bin:4:1} - Bit 3 is reserved."
		echo "${bin:5:1} - Bit 2 is reserved."
		echo "${bin:6:1} - Bit 1 is reserved."
		echo "${bin:7:1} - Bit 0 is reserved."
	fi

	return $RC
}

function query
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local QryCmd
	local STS
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'query' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	QryCmd=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "query - Querying PSU $PSU support for '$QryCmd' command."
	fi

	if [ "$QryCmd" = "page" ]; then
		STS="0x00"
	elif [ "$QryCmd" = "clear_faults" ]; then
		STS="0x03"
	elif [ "$QryCmd" = "page_plus_write" ]; then
		STS="0x05"
	elif [ "$QryCmd" = "page_plus_read" ]; then
		STS="0x06"
	elif [ "$QryCmd" = "capability" ]; then
		STS="0x19"
	elif [ "$QryCmd" = "query" ]; then
		STS="0x1a"
	elif [ "$QryCmd" = "smbalert_mask" ]; then
		STS="0x1b"
	elif [ "$QryCmd" = "coefficients" ]; then
		STS="0x30"
	elif [ "$QryCmd" = "fan_config_1_2" ]; then
		STS="0x3a"
	elif [ "$QryCmd" = "fan_command_1" ]; then
		STS="0x3b"
	elif [ "$QryCmd" = "fan_command_2" ]; then
		STS="0x3c"
	elif [ "$QryCmd" = "fan_config_3_4" ]; then
		STS="0x3d"
	elif [ "$QryCmd" = "fan_command_3" ]; then
		STS="0x3e"
	elif [ "$QryCmd" = "fan_command_4" ]; then
		STS="0x3f"
	elif [ "$QryCmd" = "vout_ov_fault_limit" ]; then
		STS="0x40"
	elif [ "$QryCmd" = "vout_uv_fault_limit" ]; then
		STS="0x44"
	elif [ "$QryCmd" = "iout_oc_fault_limit" ]; then
		STS="0x46"
	elif [ "$QryCmd" = "iout_oc_warn_limit" ]; then
		STS="0x4a"
	elif [ "$QryCmd" = "iin_oc_warn_limit" ]; then
		STS="0x5d"
	elif [ "$QryCmd" = "pin_op_warn_limit" ]; then
		STS="0x6b"
	elif [ "$QryCmd" = "status_byte" ]; then
		STS="0x78"
	elif [ "$QryCmd" = "status_word" ]; then
		STS="0x79"
	elif [ "$QryCmd" = "status_vout" ]; then
		STS="0x7a"
	elif [ "$QryCmd" = "status_iout" ]; then
		STS="0x7b"
	elif [ "$QryCmd" = "status_input" ]; then
		STS="0x7c"
	elif [ "$QryCmd" = "status_temperature" ]; then
		STS="0x7d"
	elif [ "$QryCmd" = "status_cml" ]; then
		STS="0x7e"
	elif [ "$QryCmd" = "status_other" ]; then
		STS="0x7f"
	elif [ "$QryCmd" = "status_fans_1_2" ]; then
		STS="0x81"
	elif [ "$QryCmd" = "status_fans_3_4" ]; then
		STS="0x82"
	elif [ "$QryCmd" = "read_ein" ]; then
		STS="0x86"
	elif [ "$QryCmd" = "read_eout" ]; then
		STS="0x87"
	elif [ "$QryCmd" = "read_vin" ]; then
		STS="0x88"
	elif [ "$QryCmd" = "read_iin" ]; then
		STS="0x89"
	elif [ "$QryCmd" = "read_vout" ]; then
		STS="0x8b"
	elif [ "$QryCmd" = "read_iout" ]; then
		STS="0x8c"
	elif [ "$QryCmd" = "read_temperature_1" ]; then
		STS="0x8d"
	elif [ "$QryCmd" = "read_temperature_2" ]; then
		STS="0x8e"
	elif [ "$QryCmd" = "read_temperature_3" ]; then
		STS="0x8f"
	elif [ "$QryCmd" = "read_fan_speed_1" ]; then
		STS="0x90"
	elif [ "$QryCmd" = "read_fan_speed_2" ]; then
		STS="0x91"
	elif [ "$QryCmd" = "read_fan_speed_3" ]; then
		STS="0x92"
	elif [ "$QryCmd" = "read_fan_speed_4" ]; then
		STS="0x93"
	elif [ "$QryCmd" = "read_pout" ]; then
		STS="0x96"
	elif [ "$QryCmd" = "read_pin" ]; then
		STS="0x97"
	elif [ "$QryCmd" = "pmbus_revision" ]; then
		STS="0x98"
	elif [ "$QryCmd" = "mfr_id" ]; then
		STS="0x99"
	elif [ "$QryCmd" = "mfr_model" ]; then
		STS="0x9a"
	elif [ "$QryCmd" = "mfr_revision" ]; then
		STS="0x9b"
	elif [ "$QryCmd" = "mfr_location" ]; then
		STS="0x9c"
	elif [ "$QryCmd" = "mfr_date" ]; then
		STS="0x9d"
	elif [ "$QryCmd" = "mfr_serial" ]; then
		STS="0x9e"
	elif [ "$QryCmd" = "app_profile_support" ]; then
		STS="0x9f"
	elif [ "$QryCmd" = "mfr_vin_min" ]; then
		STS="0xa0"
	elif [ "$QryCmd" = "mfr_vin_max" ]; then
		STS="0xa1"
	elif [ "$QryCmd" = "mfr_iin_max" ]; then
		STS="0xa2"
	elif [ "$QryCmd" = "mfr_pin_max" ]; then
		STS="0xa3"
	elif [ "$QryCmd" = "mfr_vout_min" ]; then
		STS="0xa4"
	elif [ "$QryCmd" = "mfr_vout_max" ]; then
		STS="0xa5"
	elif [ "$QryCmd" = "mfr_iout_max" ]; then
		STS="0xa6"
	elif [ "$QryCmd" = "mfr_pout_max" ]; then
		STS="0xa7"
	elif [ "$QryCmd" = "mfr_tambient_max" ]; then
		STS="0xa8"
	elif [ "$QryCmd" = "mfr_tambient_min" ]; then
		STS="0xa9"
	elif [ "$QryCmd" = "mfr_efficiency_ll" ]; then
		STS="0xaa"
	elif [ "$QryCmd" = "mfr_efficiency_hl" ]; then
		STS="0xab"
	elif [ "$QryCmd" = "fru_data_offset" ]; then
		STS="0xb0"
	elif [ "$QryCmd" = "read_fru_data" ]; then
		STS="0xb1"
	elif [ "$QryCmd" = "mfr_efficiency_offset" ]; then
		STS="0xb2"
	elif [ "$QryCmd" = "mfr_efficiency_data" ]; then
		STS="0xb3"
	elif [ "$QryCmd" = "mfr_max_temp_1" ]; then
		STS="0xc0"
	elif [ "$QryCmd" = "mfr_max_temp_2" ]; then
		STS="0xc1"
	elif [ "$QryCmd" = "mfr_device_code" ]; then
		STS="0xd0"
	elif [ "$QryCmd" = "isp_key" ]; then
		STS="0xd1"
	elif [ "$QryCmd" = "isp_status_cmd" ]; then
		STS="0xd2"
	elif [ "$QryCmd" = "isp_memory_addr" ]; then
		STS="0xd3"
	elif [ "$QryCmd" = "isp_memory" ]; then
		STS="0xd4"
	elif [ "$QryCmd" = "fw_version" ]; then
		STS="0xd5"
	elif [ "$QryCmd" = "system_led_cntl" ]; then
		STS="0xd7"
	elif [ "$QryCmd" = "line_status" ]; then
		STS="0xd8"
	elif [ "$QryCmd" = "tot_mfr_pout_max" ]; then
		STS="0xda"
	elif [ "$QryCmd" = "ocw_setting_write" ]; then
		STS="0xdb"
	elif [ "$QryCmd" = "ocw_setting_read" ]; then
		STS="0xdc"
	elif [ "$QryCmd" = "ocw_status" ]; then
		STS="0xdd"
	elif [ "$QryCmd" = "ocw_counter" ]; then
		STS="0xde"
	elif [ "$QryCmd" = "mfr_rapidon_cntrl" ]; then
		STS="0xe0"
	elif [ "$QryCmd" = "mfr_sleep_trip" ]; then
		STS="0xe1"
	elif [ "$QryCmd" = "mfr_wake_trip" ]; then
		STS="0xe2"
	elif [ "$QryCmd" = "mfr_trip_latency" ]; then
		STS="0xe3"
	elif [ "$QryCmd" = "mfr_page" ]; then
		STS="0xe4"
	elif [ "$QryCmd" = "mfr_pos_total" ]; then
		STS="0xe5"
	elif [ "$QryCmd" = "mfr_pos_last" ]; then
		STS="0xe6"
	elif [ "$QryCmd" = "clear_history" ]; then
		STS="0xe7"
	elif [ "$QryCmd" = "pfc_disable" ]; then
		STS="0xe8"
	elif [ "$QryCmd" = "psu_features" ]; then
		STS="0xeb"
	elif [ "$QryCmd" = "mfr_sample_set" ]; then
		STS="0xec"
	elif [ "$QryCmd" = "latch_control" ]; then
		STS="0xed"
	elif [ "$QryCmd" = "psu_factory_mode" ]; then
		STS="0xf0"
	elif [ -z "$STS" ]; then
		echo "query: invalid command queried."
		(( RC = 2 ))
	fi

	if [[ $RC -eq 0 ]]; then
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e $PSUAddress 0x00 0x03 0x02 0x1a 0x01 $STS"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='${Response:5:4}'"
			fi

			Byte=$(printf '%d\n' ${Response:5:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Returned '${bin:0:4} ${bin:4:4}'b"
			echo

			if [ "${bin:0:1}" != "1" ]; then
				echo "The '$QryCmd' command is not supported."
			else
				echo "The '$QryCmd' command is supported."

				if [ "${bin:1:1}" = "1" ]; then
					echo "The '$QryCmd' command is supported for write."
					if [ "${bin:2:1}" = "1" ]; then
						echo "The '$QryCmd' command is supported for read."
					else
						echo "The '$QryCmd' command is not supported for read."
					fi
				else
					echo "The '$QryCmd' command is not supported for write."
					if [ "${bin:2:1}" = "1" ]; then
						echo "The '$QryCmd' command is supported for read."
					else
						echo "The '$QryCmd' command is not supported for read."
						echo "Error. Command is supported but not for read nor write."
						echo "Error occurred."
						return
					fi
				fi

				if [ "${bin:3:1}" = "0" ] && [ "${bin:4:1}" = "0" ] && [ "${bin:5:1}" = "0" ]; then
					echo "Linear Data Format used."
				elif [ "${bin:3:1}" = "0" ] && [ "${bin:4:1}" = "0" ] && [ "${bin:5:1}" = "1" ]; then
						echo "16 bit signed number."
				elif [ "${bin:3:1}" = "0" ] && [ "${bin:4:1}" = "1" ] && [ "${bin:5:1}" = "0" ]; then
					echo "This combination of bits is reserved and hence invalid."
					(( RC = 1 ))
				elif [ "${bin:3:1}" = "0" ] && [ "${bin:4:1}" = "1" ] && [ "${bin:5:1}" = "1" ]; then
					echo "Direct Mode Format used."
				elif [ "${bin:3:1}" = "1" ] && [ "${bin:4:1}" = "0" ] && [ "${bin:5:1}" = "0" ]; then
					echo "8 bit unsigned number."
				elif [ "${bin:3:1}" = "1" ] && [ "${bin:4:1}" = "0" ] && [ "${bin:5:1}" = "1" ]; then
					echo "VID Mode Format used."
				elif [ "${bin:3:1}" = "1" ] && [ "${bin:4:1}" = "1" ] && [ "${bin:5:1}" = "0" ]; then
					echo "Manufacturer specific format used."
				elif [ "${bin:3:1}" = "1" ] && [ "${bin:4:1}" = "1" ] && [ "${bin:5:1}" = "1" ]; then
					echo "Command does not return numeric data or returns blocks of data."
				else
					echo "Invalid data returned."
					(( RC = 1 ))
				fi
				if [ "${bin:6:1}" = "1" ]; then
					(( RC = 1 ))
					echo "Error: bit 1 is reserved but is asserted in response"
				fi
				if [ "${bin:7:1}" = "1" ]; then
					(( RC = 1 ))
					echo "Error: bit 0 is reserved but is asserted in response"
				fi
			fi
		fi
	fi

	return $RC
}

function smbalert_mask_all
{
	local -i RC=0
	local PSU
	local Page
	local STSCmd

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'smbalert_mask_all' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR="0"
	Page="0x00"
	STSCmd="input"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="temp"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="iout"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="cml"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="vout"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	
	Page="0x01"
	STSCmd="input"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="temp"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="iout"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="cml"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="vout"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="fans_1_2"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	STSCmd="other"
	smbalert_mask $PSU $WR $Page $STSCmd
	if [[ $? -ne 0 ]]; then
		RC=$?
	fi
	
	return $RC
}

function smbalert_mask
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Page
	local STSCmd
	local Mask
	local STS
	local PagePlus
	local Byte
	local bin

	if [[ $# -lt 4 ]] ; then
		echo "Call made to function 'smbalert_mask' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2
	Page=$3
	STSCmd=$4

	PSUAddress=$(GetPSUAddress $PSU)

	PagePlus="1"

	if [ "${Page:0:2}" != "0x" ]; then
		Page=$(printf '0x%2.2x\n' $Page)
	fi

	if [ "$STSCmd" = "input" ]; then
		STS="0x7c"
	elif [ "$STSCmd" = "temp" ]; then
		STS="0x7d"
	elif [ "$STSCmd" = "iout" ]; then
		STS="0x7b"
	elif [ "$STSCmd" = "cml" ]; then
		STS="0x7e"
	elif [ "$STSCmd" = "vout" ]; then
		STS="0x7a"
	else
		PagePlus="0"
		if [ "$STSCmd" = "fans_1_2" ]; then
			STS="0x81"
		elif [ "$STSCmd" = "fans_3_4" ]; then
			STS="0x82"
		elif [ "$STSCmd" = "other" ]; then
			STS="0x7f"
		else
			echo "smbalert_mask: invalid status_command"
			(( RC = 1 ))
		fi
	fi

	if [[ $RC -eq 0 ]]; then
		if [ "$PagePlus" = "0" ]; then
			if [ "$WR" = "1" ]; then

				if [[ $# -lt 5 ]] ; then
					echo "Call made to function 'smbalert_mask' with insufficient number of parameters $#."
					exit
				fi

				Mask=$5

				if [ "$Verbose" = "1" ]; then
					echo
					echo "smbalert_mask - Writing SMBAlert mask '$Mask' for 'status_$STSCmd' command to PSU $PSU..."
				fi

				Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x1b $STS $Mask"
				send_IPMICmd "$Cmd" Response
				RC=$?
			else
				if [ "$Verbose" = "1" ]; then
					echo
					echo "smbalert_mask - Reading SMBAlert mask for 'status_$STSCmd' command from PSU $PSU..."
				fi

				Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e $PSUAddress 0x00 0x03 0x02 0x1b 0x01 $STS"
				send_IPMICmd "$Cmd" Response
				RC=$?
				if [[ $RC -eq 0 ]]; then

					if [[ $# -eq 5 ]] ; then
						eval "$5='${Response:5:4}'"
					fi

					Byte=$(printf '%d\n' ${Response:5:4})
					bin=$(dec2bin $Byte)

					echo
					echo "'status_$STSCmd' register SMBAlert mask = '${bin:0:4} ${bin:4:4}'b"
					echo

					if [ "$STSCmd" = "fans_1_2" ]; then
						echo "${bin:0:1} - Fan 1 fault."
						echo "${bin:1:1} - Fan 2 fault."
						echo "${bin:2:1} - Fan 1 warning."
						echo "${bin:3:1} - Fan 2 warning."
						echo "${bin:4:1} - Fan1 Speed Override condition."
						echo "${bin:5:1} - Fan2 Speed Override condition."
						echo "${bin:6:1} - Bit 1 is undefined."
						echo "${bin:7:1} - Bit 0 is undefined."
					elif [ "$STSCmd" = "fans_3_4" ]; then
						echo "${bin:0:1} - Fan 3 fault."
						echo "${bin:1:1} - Fan 4 fault."
						echo "${bin:2:1} - Fan 3 warning."
						echo "${bin:3:1} - Fan 4 warning."
						echo "${bin:4:1} - Fan3 Speed Override."
						echo "${bin:5:1} - Fan4 Speed Override."
						echo "${bin:6:1} - Bit 1 is undefined."
						echo "${bin:7:1} - Bit 0 is undefined."
					elif [ "$STSCmd" = "other" ]; then
						echo "${bin:0:1} - Bit 7 is undefined."
						echo "${bin:1:1} - Bit 6 is undefined."
						echo "${bin:2:1} - Bit 5 is undefined."
						echo "${bin:3:1} - Bit 4 is undefined."
						echo "${bin:4:1} - Bit 3 is undefined."
						echo "${bin:5:1} - Bit 2 is undefined."
						echo "${bin:6:1} - Bit 1 is undefined."
						echo "${bin:7:1} - A Primary Protection Trigger External Rapid On feature event."
					fi
				fi
			fi
		else
			if [ "$WR" = "1" ]; then
				if [[ $# -lt 5 ]] ; then
					echo "Call made to function 'smbalert_mask' with insufficient number of parameters $#."
					exit
				fi

				Mask=$5


				if [ "$Verbose" = "1" ]; then
					echo
					echo "smbalert_mask - Writing SMBAlert mask '$Mask' for 'status_$STSCmd' command on page $Page to PSU $PSU..."
				fi

				Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x06 0x00 0x05 0x04 $Page 0x1b $STS $Mask"
				send_IPMICmd "$Cmd" Response
				RC=$?
			else
				if [ "$Verbose" = "1" ]; then
					echo
					echo "smbalert_mask - Reading SMBAlert mask for 'status_$STSCmd' command on page $Page for PSU $PSU..."
				fi

				Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e $PSUAddress 0x00 0x05 0x02 0x06 0x03 $Page 0x1b $STS"
				send_IPMICmd "$Cmd" Response
				RC=$?
				if [[ $RC -eq 0 ]]; then

					if [[ $# -eq 5 ]] ; then
						eval "$5='${Response:5:4}'"
					fi

					Byte=$(printf '%d\n' ${Response:5:4})
					bin=$(dec2bin $Byte)

					echo
					echo "Page $Page 'status_$STSCmd' register SMBAlert mask = '${bin:0:4} ${bin:4:4}'b"
					echo

					if [ "$STSCmd" = "input" ]; then
						echo "${bin:0:1} - Bit 7 is undefined."
						echo "${bin:1:1} - Bit 6 is undefined."
						echo "${bin:2:1} - Line Input Undervoltage Warning."
						echo "${bin:3:1} - Line Input Undervoltage Fault."
						echo "${bin:4:1} - Unit Off for Low Input Voltage."
						echo "${bin:5:1} - Bit 2 is undefined."
						echo "${bin:6:1} - Input Overcurrent Warning."
						echo "${bin:7:1} - Input Overpower Warning."
					elif [ "$STSCmd" = "temp" ]; then
						echo "${bin:0:1} - Overtemperature Fault."
						echo "${bin:1:1} - Overtemperature Warning."
						echo "${bin:2:1} - Bit 5 is undefined."
						echo "${bin:3:1} - Bit 4 is undefined."
						echo "${bin:4:1} - Bit 3 is undefined."
						echo "${bin:5:1} - Bit 2 is undefined."
						echo "${bin:6:1} - Bit 1 is undefined."
						echo "${bin:7:1} - Bit 0 is undefined."
					elif [ "$STSCmd" = "iout" ]; then
						echo "${bin:0:1} - Output Overcurrent Fault."
						echo "${bin:1:1} - Bit 6 is undefined."
						echo "${bin:2:1} - PSU Primary Output Overcurrent Warning."
						echo "${bin:3:1} - Bit 4 is undefined."
						echo "${bin:4:1} - Bit 3 is undefined."
						echo "${bin:5:1} - Bit 2 is undefined."
						echo "${bin:6:1} - PSU Output Overpower Fault."
						echo "${bin:7:1} - PSU Output Overpower Warning."
					elif [ "$STSCmd" = "cml" ]; then
						echo "${bin:0:1} - Slave received an invalid or unsupported command is masked from asserting SMBAlert#"
						echo "${bin:1:1} - IPM2 Data Format Error."
						echo "${bin:2:1} - Slave received an error PEC code."
						echo "${bin:3:1} - Bit 4 is undefined."
						echo "${bin:4:1} - Bit 3 is undefined."
						echo "${bin:5:1} - Bit 2 is undefined."
						echo "${bin:6:1} - Bit 1 is undefined."
						echo "${bin:7:1} - Bit 0 is undefined."
					elif [ "$STSCmd" = "vout" ]; then
						echo "${bin:0:1} - Output Overvoltage Fault."
						echo "${bin:1:1} - Bit 6 is undefined."
						echo "${bin:2:1} - Bit 5 is undefined."
						echo "${bin:3:1} - Output Undervoltage Fault."
						echo "${bin:4:1} - Bit 3 is undefined."
						echo "${bin:5:1} - Supply has not been able to turn on and assert POK within 4 seconds."
						echo "${bin:6:1} - Bit 1 is undefined."
						echo "${bin:7:1} - Bit 0 is undefined."
					fi
				fi
			fi
		fi
	fi

	echo
	
	return $RC
}

function coefficients
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local STS
	local CoefCmd

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'coefficients' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	CoefCmd=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "coefficients - Reading PSU $PSU coefficients for command '$CoefCmd'."
	fi

	if [ "$CoefCmd" = "read_ein" ]; then
		STS="0x86"
	elif [ "$CoefCmd" = "read_eout" ]; then
		STS="0x87"
	else
		echo "coefficients: command '$CoefCmd' does not use DIRECT format"
		(( RC = 1 ))
	fi

	if [[ $RC -eq 0 ]]; then
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e $PSUAddress 0x00 0x04 0x06 0x30 0x02 $STS 0x01"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			echo
			echo "For command '$CoefCmd'"
			echo "m = $(printf '%d\n' ${Response:10:4}${Response:7:2})"
			echo "b = $(printf '%d\n' ${Response:20:4}${Response:17:2})"
			echo "R = $(printf '%d\n' ${Response:25:4})"
		fi
	fi

	return $RC
}

function psu_manufacturing
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local PinConfig
	local Mask

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'psu_manufacturing' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'psu_manufacturing' with insufficient number of parameters $#."
			exit
		fi

		PinConfig=$3
		
		if [ "$PinConfig" = "configured" ]; then
			Mask="0x01"
		elif [ "$PinConfig" = "unconfigured" ]; then
			Mask="0x00"
		else
			echo "Call made to function 'psu_manufacturing' with invalid pin configuration value '$PinConfig'."
			exit
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "psu_manufacturing - Setting PSU $PSU MFG Fan Pin Config setting to '$PinConfig'."
			echo
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0xf1 $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "psu_manufacturing - Reading PSU $PSU MFG Fan Pin Config setting."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xf1"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			echo
			if [ "$Response" = "0x01" ]; then
				echo "Manufacturing Fan Pin is configured for use by the end system."
			elif [ "$Response" = "0x00" ]; then
				echo "Manufacturing Fan Pin is not configured for use by end system."
			else
				echo "Received unknown value for Manufacturing Fan Pin configuration."
				RC=2
			fi
			
			echo
			
			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi			
		fi
	fi

	return $RC
}

function fan_command_1
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Speed

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'fan_command_1' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local LO

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'fan_command_1' with insufficient number of parameters $#."
			exit
		fi

		Speed=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "fan_command_1 - Setting PSU $PSU fan 1 speed to $Speed%."
		fi

		LO=$(printf '%x\n' "$Speed")
		if [ ${#LO} -lt 2 ]; then
			LO="0$LO"
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x3b 0x$LO 0x00"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "fan_command_1 - Reading PSU $PSU fan 1 speed."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x3b"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			Speed=$(printf '%d\n' "${Response:5:4}${Response:2:2}")
			echo
			echo "Fan speed = $Speed%"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$Speed'"
			fi
		fi
	fi

	return $RC
}

function fan_config_1_2
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local -i Tach
	local Byte
	local bin


	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'fan_config_1_2' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "fan_config_1_2 - Reading PSU $PSU fan configuration."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x3a"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		Byte=$(printf '%d\n' $Response)
		(( Tach = ("$Byte" & 0x30) >> 4 ))

		bin=$(dec2bin $Byte)

		echo
		echo "Returned '${bin:0:4} ${bin:4:4}'b"
		echo

		if [ "${bin:0:1}" = "1" ]; then
			echo "A Fan Is Installed In Position 1."
			if [ "${bin:1:1}" = "1" ]; then
				echo "Fan 1 Is Commanded In RPM."
			else
				echo "Fan 1 Is Commanded In Duty Cycle."
			fi

			echo "Fan 1 tachometer pulses $Tach times per revolution."
		else
			echo "No Fan Is Installed In Position 1."
		fi

		Byte=$(printf '%d\n' $Response)
		(( Tach = "$Byte" & 0x03 ))

		if [ "${bin:4:1}" = "1" ]; then
			echo "A Fan Is Installed In Position 2."
			if [ "${bin:5:1}" = "1" ]; then
				echo "Fan 2 Is Commanded In RPM."
			else
				echo "Fan 2 Is Commanded In Duty Cycle."
			fi


			echo "Fan 1 tachometer pulses $Tach times per revolution."
		else
			echo "No Fan Is Installed In Position 2."
		fi
	fi

	return $RC
}

function line_status
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin
	local InpVoltageType=""


	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'line_status' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "line_status - Reading PSU $PSU line status."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xd8"
	send_IPMICmd "$Cmd" Response
	RC=$?

	if [[ $RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		Byte=$(printf '%d\n' $Response)
		bin=$(dec2bin $Byte)

		echo
		echo "Returned '${bin:0:4} ${bin:4:4}'b"
		echo

		if [ "${bin:0:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Error: bit 7 is reserved, yet is asserted in response"
		fi
		if [ "${bin:1:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Error: bit 6 is reserved, yet is asserted in response"
		fi
		if [ "${bin:2:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Error: bit 6 is reserved, yet is asserted in response"
		fi
		if [ "${bin:3:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Error: bit 6 is reserved, yet is asserted in response"
		fi
		if [ "${bin:4:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Error: bit 6 is reserved, yet is asserted in response"
		fi

		if [ "${bin:5:1}" = "0" ] && [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "0" ]; then
			InpVoltageType="Low line, 50Hz, AC Present."
		elif [ "${bin:5:1}" = "0" ] && [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "1" ]; then
			InpVoltageType="No AC input."
		elif [ "${bin:5:1}" = "0" ] && [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "0" ]; then
			InpVoltageType="High line, 50Hz, AC Present."
		elif [ "${bin:5:1}" = "0" ] && [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "1" ]; then
			InpVoltageType="No DC input."
		elif [ "${bin:5:1}" = "1" ] && [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "0" ]; then
			InpVoltageType="Low line, 60Hz, AC Present."
		elif [ "${bin:5:1}" = "1" ] && [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "1" ]; then
			(( RC = 1 ))
			InpVoltageType="Error: value $Response is reserved."
			echo $InpVoltageType
		elif [ "${bin:5:1}" = "1" ] && [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "0" ]; then
			InpVoltageType="High line, 60Hz, AC Present."
		elif [ "${bin:5:1}" = "1" ] && [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "1" ]; then
			InpVoltageType="Input is DC."
		else
			(( RC = 2 ))
			echo "Error occurred decoding bits."
		fi
	fi
	if [[ $RC -eq 0 ]]; then
		echo $InpVoltageType
		if [[ $# -eq 2 ]] ; then
			eval "$2='$InpVoltageType'"
		fi
	fi

	return $RC
}

function vout_ov_fault_limit
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Limit
	local WR
	local -i exponent=9
	local TransformedString


	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'vout_ov_fault_limit' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'vout_ov_fault_limit' with insufficient number of parameters $#."
			exit
		fi

		Limit=$3
		if [ "$Verbose" = "1" ]; then
			echo
			echo "vout_ov_fault_limit - Writing PSU $PSU vout_ov_fault_limit to $Limit V."
		fi

		TransformedString=$(EncodeLinear16 $Limit $exponent)
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x40 0x${TransformedString:2:2} 0x${TransformedString:0:2}"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "vout_ov_fault_limit - Reading current PSU $PSU vout_ov_fault_limit value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x40"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear16 "${Response:5:4}${Response:2:2}" $exponent)
			echo
			echo "Vout Overvoltage Fault Limit = $TransformedString V"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$TransformedString'"
			fi
		fi
	fi

	return $RC
}

function vout_uv_fault_limit
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Limit
	local WR
	local -i exponent=9
	local TransformedString


	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'vout_uv_fault_limit' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'vout_uv_fault_limit' with insufficient number of parameters $#."
			exit
		fi

		Limit=$3
		if [ "$Verbose" = "1" ]; then
			echo
			echo "vout_uv_fault_limit - Writing PSU $PSU vout_uv_fault_limit to $Limit V."
		fi

		TransformedString=$(EncodeLinear16 $Limit $exponent)
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x44 0x${TransformedString:2:2} 0x${TransformedString:0:2}"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "vout_uv_fault_limit - Reading current PSU $PSU vout_uv_fault_limit value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x44"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear16 "${Response:5:4}${Response:2:2}" $exponent)
			echo
			echo "Vout Undervoltage Fault Limit = $TransformedString V"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$TransformedString'"
			fi
		fi
	fi

	return $RC
}

function iout_oc_fault_limit
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Limit
	local WR
	local -i exponent=9
	local TransformedString

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'iout_oc_fault_limit' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'iout_oc_fault_limit' with insufficient number of parameters $#."
			exit
		fi

		Limit=$3
		if [ "$Verbose" = "1" ]; then
			echo
			echo "iout_oc_fault_limit - Writing PSU $PSU iout_oc_fault_limit to $Limit A."
		fi

		TransformedString=$(EncodeLinear11 $Limit)
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x46 0x${TransformedString:2:2} 0x${TransformedString:0:2}"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "iout_oc_fault_limit - Reading current PSU $PSU iout_oc_fault_limit value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x46"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
			echo
			echo "Iout Overcurrent Fault Limit = $TransformedString A"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$TransformedString'"
			fi
		fi
	fi

	return $RC
}

function iout_oc_warn_limit
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Limit
	local WR
	local -i exponent=9
	local TransformedString

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'iout_oc_warn_limit' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'iout_oc_warn_limit' with insufficient number of parameters $#."
			exit
		fi

		Limit=$3
		
		if [ "$Verbose" = "1" ]; then
			echo
			echo "iout_oc_warn_limit - Writing PSU $PSU iout_oc_warn_limit to $Limit A."
		fi

		TransformedString=$(EncodeLinear11 $Limit)

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x4a 0x${TransformedString:2:2} 0x${TransformedString:0:2}"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "iout_oc_warn_limit - Reading current PSU $PSU iout_oc_warn_limit value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x4a"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
			echo
			echo "Iout Overcurrent Warning Limit = $TransformedString A"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$TransformedString'"
			fi
		fi
	fi

	return $RC
}

function iin_oc_warn_limit
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Limit
	local WR
	local -i exponent=9
	local TransformedString

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'iin_oc_warn_limit' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'iin_oc_warn_limit' with insufficient number of parameters $#."
			exit
		fi

		Limit=$3
		if [ "$Verbose" = "1" ]; then
			echo
			echo "iin_oc_warn_limit - Writing PSU $PSU iin_oc_warn_limit to $Limit A."
		fi

		TransformedString=$(EncodeLinear11 $Limit)

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x5d 0x${TransformedString:2:2} 0x${TransformedString:0:2}"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "iin_oc_warn_limit - Reading current PSU $PSU iin_oc_warn_limit value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x5d"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
			echo
			echo "Iin Overcurrent Warning Limit = $TransformedString A"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$TransformedString'"
			fi
		fi
	fi

	return $RC
}

function pin_op_warn_limit
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Limit
	local WR
	local -i exponent=9
	local TransformedString

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'pin_op_warn_limit' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'pin_op_warn_limit' with insufficient number of parameters $#."
			exit
		fi

		Limit=$3
		if [ "$Verbose" = "1" ]; then
			echo
			echo "pin_op_warn_limit - Writing PSU $PSU pin_op_warn_limit to $Limit W."
		fi

		TransformedString=$(EncodeLinear11 $Limit)

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x6b 0x${TransformedString:2:2} 0x${TransformedString:0:2}"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "pin_op_warn_limit - Reading current PSU $PSU pin_op_warn_limit value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x6b"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
			echo
			echo "Pin Overpower Warning Limit = $TransformedString W"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$TransformedString'"
			fi
		fi
	fi

	return $RC
}

function status_byte
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_byte' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'status_byte' with insufficient number of parameters $#."
			exit
		fi

		Mask=$3
		
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_byte - Clearing PSU $PSU status_byte."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x78 $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
	
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_byte - Reading PSU $PSU status_byte."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x78"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Unit is too busy to respond to PMBus communications."
			echo "${bin:1:1} - This bit is asserted if the unit is not providing power to the output."
			echo "${bin:2:1} - An output overvoltage fault has occurred."
			echo "${bin:3:1} - An output overcurrent fault has occurred."
			echo "${bin:4:1} - An input undervoltage fault has occurred."
			echo "${bin:5:1} - A temperature fault or warning has occurred."
			echo "${bin:6:1} - A communications, memory or logic fault has occurred."
			echo "${bin:7:1} - Bit 0 is undefined."
		fi

		echo
	fi
	
	return $RC
}

function status_word
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local Byte1
	local Byte2
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_word' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 4 ]] ; then
			echo "Call made to function 'status_word' with insufficient number of parameters $#."
			exit
		fi

		Mask="$3 $4"
		
		if [[ ${#Mask} -ne 9 ]]; then
			echo
			echo "Mask for status_word is two bytes. Enclose with quotation marks."
			exit
		fi
		
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_word - Clearing PSU $PSU status_word."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0x79 $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_word - Reading PSU $PSU status_word value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x79"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)
			Byte1=$bin
			Byte=$(printf '%d\n' ${Response:5:4})
			bin=$(dec2bin $Byte)
			Byte2=$bin

			echo
			echo "Register 'status_word' returned '${Byte1:0:4} ${Byte1:4:4} ${Byte2:0:4} ${Byte2:4:4}'b"
			echo

			echo "${Byte2:0:1} - An output voltage fault or warning has occurred."
			echo "${Byte2:1:1} - An output current or output power fault or warning has occurred."
			echo "${Byte2:2:1} - An input voltage, input current, or input power fault or warning has occurred."
			echo "${Byte2:3:1} - High Byte bit 4 is undefined."
			echo "${Byte2:4:1} - The POWER_GOOD signal, if present, is negated."
			echo "${Byte2:5:1} - A fan or airflow fault or warning has occurred."
			echo "${Byte2:6:1} - An advanced feature event has occurred."
			echo "${Byte2:7:1} - High Byte bit 0 is undefined."
			echo
			echo "${Byte1:0:1} - Unit is too busy to respond to PMBus communications."
			echo "${Byte1:1:1} - This bit is asserted if the unit is not providing power to the output."
			echo "${Byte1:2:1} - An output overvoltage fault has occurred."
			echo "${Byte1:3:1} - An output overcurrent fault has occurred."
			echo "${Byte1:4:1} - An input undervoltage fault has occurred."
			echo "${Byte1:5:1} - A temperature fault or warning has occurred."
			echo "${Byte1:6:1} - A communications, memory or logic fault has occurred."
			echo "${Byte1:7:1} - Low Byte bit 0 is undefined."
		fi
	fi

	echo
	return $RC
}

function status_vout
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Mask
	local Byte
	local Byte1
	local Byte2
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_vout' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'status_vout' with insufficient number of parameters $#."
			exit
		fi

		Mask=$3
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_vout - Clearing PSU $PSU status_vout."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x7a $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_vout - Reading PSU $PSU status_vout value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x7a"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Register 'status_vout' returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Output Overvoltage Fault."
			echo "${bin:1:1} - Bit 6 is undefined."
			echo "${bin:2:1} - Bit 5 is undefined."
			echo "${bin:3:1} - Output Undervoltage Fault."
			echo "${bin:4:1} - Bit 3 is undefined."
			echo "${bin:5:1} - PSU has not been able to turn on and assert POK within 4 seconds."
			echo "${bin:6:1} - Bit 1 is undefined."
			echo "${bin:7:1} - Bit 0 is undefined."
		fi
	fi

	echo
	return $RC
}

function status_iout
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Mask
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_iout' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'status_iout' with insufficient number of parameters $#."
			exit
		fi

		Mask=$3

		if [ -z "$Mask" ]; then
			Mask="0xff"
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_iout - Clearing PSU $PSU status_iout using a mask of $Mask."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x7b $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_iout - Reading PSU $PSU status_iout."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x7b"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Register 'status_iout' returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Output Overcurrent Fault."
			echo "${bin:1:1} - Bit 6 is undefined."
			echo "${bin:2:1} - PSU primary output overcurrent warning."
			echo "${bin:3:1} - Bit 4 is undefined."
			echo "${bin:4:1} - Bit 3 is undefined."
			echo "${bin:5:1} - Bit 2 is undefined."
			echo "${bin:6:1} - PSU output overpower fault."
			echo "${bin:7:1} - PSU output overpower warning."
		fi
	fi

	echo
	return $RC
}

function status_input
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Mask
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_input' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'status_input' with insufficient number of parameters $#."
			exit
		fi

		Mask=$3

		if [ -z "$Mask" ]; then
			Mask="0xff"
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_input - Clearing PSU $PSU status_input with mask of $Mask."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x7c $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_input - Reading PSU $PSU status_input."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x7c"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Register 'status_input' returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Bit 7 is undefined."
			echo "${bin:1:1} - Bit 6 is undefined."
			echo "${bin:2:1} - Line input undervoltage warning."
			echo "${bin:3:1} - Line input undervoltage fault."
			echo "${bin:4:1} - Supply is off or was not able to turn on due to low input voltage."
			echo "${bin:5:1} - Bit 2 is undefined."
			echo "${bin:6:1} - Input Overcurrent Warning Occurred."
			echo "${bin:7:1} - Input Overpower Warning Occurred."

		fi
	fi

	echo
	return $RC
}

function status_temperature
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Mask
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_temperature' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'status_temperature' with insufficient number of parameters $#."
			exit
		fi

		Mask=$3

		if [ -z "$Mask" ]; then
			Mask="0xff"
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_temperature - Clearing PSU $PSU status_temperature with mask of $Mask."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x7d $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_temperature - Reading PSU $PSU status_temperature."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x7d"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Register 'status_temperature' returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Overtemperature Fault Occurred."
			echo "${bin:1:1} - Overtemperature Warning Occurred."
			echo "${bin:2:1} - Bit 5 is undefined."
			echo "${bin:3:1} - Bit 4 is undefined."
			echo "${bin:4:1} - Bit 3 is undefined."
			echo "${bin:5:1} - Bit 2 is undefined."
			echo "${bin:6:1} - Bit 1 is undefined."
			echo "${bin:7:1} - Bit 0 is undefined."
		fi
	fi

	echo
	return $RC
}

function status_cml
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Mask
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_cml' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'status_cml' with insufficient number of parameters $#."
			exit
		fi

		Mask=$3

		if [ -z "$Mask" ]; then
			Mask="0xff"
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_cml - Clearing PSU $PSU status_cml with mask of $Mask."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x7e $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_cml - Reading PSU $PSU status_cml."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x7e"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})

			bin=$(dec2bin $Byte)

			echo
			echo "Register 'status_cml' returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Slave received an invalid or unsupported command."
			echo "${bin:1:1} - IPM2 Data Format Error occurred."
			echo "${bin:2:1} - Slave received an error PEC code."
			echo "${bin:3:1} - Bit 4 is undefined."
			echo "${bin:4:1} - Bit 3 is undefined."
			echo "${bin:5:1} - Bit 2 is undefined."
			echo "${bin:6:1} - Bit 1 is undefined."
			echo "${bin:7:1} - Bit 0 is undefined."
		fi
	fi

	echo
	return $RC
}

function status_other
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Mask
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_other' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local Mask

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'status_other' with insufficient number of parameters $#."
			exit
		fi

		Mask=$3

		if [ -z "$Mask" ]; then
			Mask="0xff"
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_other - Clearing PSU $PSU status_other with mask of $Mask."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x7f $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_other - Reading PSU $PSU status_other."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x7f"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})

			bin=$(dec2bin $Byte)

			echo
			echo "Register 'status_other' returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Bit 7 is undefined."
			echo "${bin:1:1} - Bit 6 is undefined."
			echo "${bin:2:1} - Bit 5 is undefined."
			echo "${bin:3:1} - Bit 4 is undefined."
			echo "${bin:4:1} - Bit 3 is undefined."
			echo "${bin:5:1} - Bit 2 is undefined."
			echo "${bin:6:1} - Bit 1 is undefined."
			echo "${bin:7:1} - A Primary Protection Trigger External Rapid On feature event has occurred."
		fi
	fi

	echo
	return $RC
}

function status_fans_1_2
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Mask
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'status_fans_1_2' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'status_fans_1_2' with insufficient number of parameters $#."
			exit
		fi

		Mask=$3

		if [ -z "$Mask" ]; then
			Mask="0xff"
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_fans_1_2 - Clearing PSU $PSU status_fans_1_2 with mask of $Mask."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0x81 $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "status_fans_1_2 - Reading PSU $PSU status_fans_1_2."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x81"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Register 'status_fans_1_2' returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Fan 1 fault occurred."
			echo "${bin:1:1} - Fan 2 fault occurred."
			echo "${bin:2:1} - Fan 1 warning occurred."
			echo "${bin:3:1} - Fan 2 warning occurred."
			echo "${bin:4:1} - Fan1 Speed Override condition occurred."
			echo "${bin:5:1} - Fan2 Speed Override condition occurred."
			echo "${bin:6:1} - Bit 1 is undefined."
			echo "${bin:7:1} - Bit 0 is undefined."
		fi
	fi

	echo
	return $RC
}

function read_ein
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local EnergyCount
	local RolloverCount
	local SampleCount

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_ein' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_ein - Reading PSU $PSU energy in."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x07 0x86"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		echo
		(( EnergyCount = $(printf '%d' "${Response:10:4}${Response:7:2}") ))
		echo "Energy Count = $EnergyCount"
		(( RolloverCount = $(printf '%d' "${Response:15:4}") ))
		echo "Rollover Count = $RolloverCount"
		(( SampleCount = $(printf '%d' "${Response:30:4}${Response:27:2}${Response:22:2}") ))
		echo "Sample Count = $SampleCount"
		if [[ $# -eq 4 ]] ; then
			eval "$2='$EnergyCount'"
			eval "$3='$RolloverCount'"
			eval "$4='$SampleCount'"
		fi
	fi

	return $RC
}

function read_eout
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local EnergyCount
	local RolloverCount
	local SampleCount

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_eout' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_eout - Reading PSU $PSU energy out."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x07 0x87"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		echo
		(( EnergyCount = $(printf '%d' "${Response:10:4}${Response:7:2}") ))
		echo "Energy Count = $EnergyCount"
		(( RolloverCount = $(printf '%d' "${Response:15:4}") ))
		echo "Rollover Count = $RolloverCount"
		(( SampleCount = $(printf '%d' "${Response:30:4}${Response:27:2}${Response:22:2}") ))
		echo "Sample Count = $SampleCount"
		if [[ $# -eq 4 ]] ; then
			eval "$2='$EnergyCount'"
			eval "$3='$RolloverCount'"
			eval "$4='$SampleCount'"
		fi
	fi

	return $RC
}

function read_vin
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_vin' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_vin - Reading PSU $PSU voltage in."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x88"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Voltage In = $TransformedString V"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_iin
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_iin' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_iin - Reading PSU $PSU current in."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x89"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Current In = $TransformedString A"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_vout
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString
	local -i exponent=9

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_vout' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_vout - Reading PSU $PSU voltage out."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x8b"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear16 "${Response:5:4}${Response:2:2}" $exponent)
		echo
		echo "Voltage Out = $TransformedString V"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_iout
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_iout' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_iout - Reading PSU $PSU current out."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x8c"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Current Out = $TransformedString A"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_temperature_1
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_temperature_1' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_temperature_1 - Reading PSU $PSU temperature at location 1."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x8d"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Temperature 1 = $TransformedString C"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_temperature_2
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_temperature_2' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_temperature_2 - Reading PSU $PSU temperature at location 2."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x8e"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Temperature 2 = $TransformedString C"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_temperature_3
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_temperature_3' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_temperature_3 - Reading PSU $PSU temperature at location 3."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x8f"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Temperature 3 = $TransformedString C"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_fan_speed_1
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_fan_speed_1' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_fan_speed_1 - Reading PSU $PSU fan 1 speed."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x90"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Fan 1 Speed = $TransformedString RPM"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_pout
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_pout' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_pout - Reading PSU $PSU power out."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x96"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Power Out = $TransformedString W"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function read_pin
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_pin' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_pin - Reading PSU $PSU power in."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0x97"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Power In = $TransformedString W"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function pmbus_revision
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'pmbus_revision' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "pmbus_revision - Reading PSU $PSU PMBus revision."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x98"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		if [ "${Response:0:4}" = "0x00" ]; then
			echo "PMBus revision = 1.0"
		elif [ "${Response:0:4}" = "0x11" ]; then
			echo "PMBus revision = 1.1"
		elif [ "${Response:0:4}" = "0x22" ]; then
			echo "PMBus revision = 1.2"
		else
			(( RC = 1 ))
			echo "Unknown PMBus revision."
		fi
	fi

	return $RC
}

function mfr_id
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_id' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_id - Reading PSU $PSU Mfr ID."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x0d 0x99"
	send_IPMICmd "$Cmd" Response
	RC=$?

	if [[ $RC -eq 0 ]]; then
		local -i CharNumber=0
		local CharBuf=""
		local -i INT
		local Char


		while [ $CharNumber -lt 12 ]; do
			(( CharNumber++ ))
			Char="${Response:$CharNumber*5+2:2}"
			INT=$(( $(printf '%d' "0x$Char") ))
			if [[ $INT -lt 32 ]] || [[ $INT -gt 126 ]]; then
				Char="."
			else
				Char=" $Char"
				Char="${Char// /\\x}"
				Char="$Char\\n"
				Char=$(printf "$Char")
			fi

			CharBuf="$CharBuf$Char"
		done

		echo "Mfr ID = '$CharBuf'"

		if [[ $# -eq 2 ]] ; then
			eval "$2='$CharBuf'"
		fi

	fi

	return $RC
}

function mfr_model
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_model' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_model - Reading PSU $PSU Mfr model."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x11 0x9a"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		local -i CharNumber=0
		local CharBuf=""
		local Char
		local -i INT


		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		while [ $CharNumber -lt 16 ]; do
			CharNumber=$CharNumber+1
			Char="${Response:$CharNumber*5+2:2}"
			(( INT = $(printf '%d' "0x$Char") ))
			if [[ $INT -lt 32 ]] || [[ $INT -gt 126 ]]; then
				Char="."
			else
				Char=" $Char"
				Char="${Char// /\\x}"
				Char="$Char\\n"
				Char=$(printf "$Char")
			fi

			CharBuf="$CharBuf$Char"
		done

		echo "Mfr model = '$CharBuf'"
	fi

	return $RC
}

function mfr_revision
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_revision' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_revision - Reading PSU $PSU Mfr revision."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x11 0x9b"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		local -i CharNumber=0
		local CharBuf=""
		local Char
		local -i INT

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		while [ $CharNumber -lt 16 ]; do
			CharNumber=$CharNumber+1
			Char="${Response:$CharNumber*5+2:2}"
			INT=$(printf '%d' "0x$Char")
			if [ $INT -lt 32 ] || [ $INT -gt 126 ]; then
				Char="."
			else
				Char=" $Char"
				Char="${Char// /\\x}"
				Char="$Char\\n"
				Char=$(printf "$Char")
			fi

			CharBuf="$CharBuf$Char"
		done

		echo "Mfr revision = '$CharBuf'"
	fi

	return $RC
}

function mfr_location
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_location' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_location - Reading PSU $PSU Mfr location."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x11 0x9c"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		local -i CharNumber=0
		local CharBuf=""
		local -i INT

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		while [ $CharNumber -lt 16 ]; do
			CharNumber=$CharNumber+1
			Char="${Response:$CharNumber*5+2:2}"
			INT=$(printf '%d' "0x$Char")
			if [ $INT -lt 32 ] || [ $INT -gt 126 ]; then
				Char="."
			else
				Char=" $Char"
				Char="${Char// /\\x}"
				Char="$Char\\n"
				Char=$(printf "$Char")
			fi

			CharBuf="$CharBuf$Char"
		done

		echo "Mfr location = '$CharBuf'"
	fi

	return $RC
}

function mfr_date
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_date' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_date - Reading PSU $PSU Mfr date."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x07 0x9d"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		local -i CharNumber=0
		local CharBuf=""
		local -i INT


		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		while [ $CharNumber -lt 6 ]; do
			CharNumber=$CharNumber+1
			Char="${Response:$CharNumber*5+2:2}"
			INT=$(printf '%d' "0x$Char")
			if [ $INT -lt 32 ] || [ $INT -gt 126 ]; then
				Char="."
			else
				Char=" $Char"
				Char="${Char// /\\x}"
				Char="$Char\\n"
				Char=$(printf "$Char")
			fi

			CharBuf="$CharBuf$Char"
			if [ $CharNumber -eq 2 ] || [ $CharNumber -eq 4 ]; then
				CharBuf="$CharBuf/"
			fi
		done

		echo "Mfr date = '$CharBuf'"
	fi

	return $RC
}

function mfr_serial
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_serial' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_serial - Reading PSU $PSU Mfr serial."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x0f 0x9e"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		local -i CharNumber=0
		local CharBuf=""
		local -i INT

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		while [ $CharNumber -lt 14 ]; do
			CharNumber=$CharNumber+1
			Char="${Response:$CharNumber*5+2:2}"
			INT=$(printf '%d' "0x$Char")
			if [ $INT -lt 32 ] || [ $INT -gt 126 ]; then
				Char="."
			else
				Char=" $Char"
				Char="${Char// /\\x}"
				Char="$Char\\n"
				Char=$(printf "$Char")
			fi

			CharBuf="$CharBuf$Char"
		done

		echo "Mfr serial = '$CharBuf'"
	fi

	return $RC
}

function app_profile_support
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'app_profile_support' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "app_profile_support - Reading PSU $PSU application profile support."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0x9f"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		echo "Application profile support = '$Response'"
	fi

	return $RC
}

function mfr_vin_min
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_vin_min' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_vin_min - Reading PSU $PSU Mfr minimum input voltage."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa0"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Mfr Vin minimum = $TransformedString V"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_vin_max
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_vin_max' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_vin_max - Reading PSU $PSU Mfr maximum input voltage."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa1"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Mfr Vin maximum = $TransformedString V"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_iin_max
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_iin_max' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_iin_max - Reading PSU $PSU Mfr maximum input current."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa2"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Mfr Iin maximum = $TransformedString A"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_pin_max
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_pin_max' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_pin_max - Reading PSU $PSU Mfr maximum input power."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa3"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Mfr Pin maximum = $TransformedString W"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_vout_min
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString
	local -i exponent=9

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_vout_min' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_vout_min - Reading PSU $PSU Mfr minimum output voltage."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa4"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear16 "${Response:5:4}${Response:2:2}" $exponent)
		echo
		echo "Mfr Vout minimum = $TransformedString V"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_vout_max
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString
	local exponent=9

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_vout_max' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_vout_max - Reading PSU $PSU Mfr maximum output voltage."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa5"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear16 "${Response:5:4}${Response:2:2}" $exponent)
		echo
		echo "Mfr Vout maximum = $TransformedString V"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_iout_max
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_iout_max' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_iout_max - Reading PSU $PSU Mfr maximum output current."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa6"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Mfr Maximum Current Rating = $TransformedString A"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_pout_max
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_pout_max' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_pout_max - Reading PSU $PSU Mfr maximum output power."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa7"
	send_IPMICmd "$Cmd" Response
	RC=$?

	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Mfr Power Capacity Rating = $TransformedString W"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_tambient_max
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_tambient_max' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_tambient_max - Reading PSU $PSU Mfr maximum ambient temperature."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa8"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Mfr maximum ambient temperature = $TransformedString C"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_tambient_min
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_tambient_min' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_tambient_min - Reading PSU $PSU Mfr minimum ambient temperature."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xa9"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo
		echo "Mfr minimum ambient temperature = $TransformedString C"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_efficiency_ll
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString
	local InputVoltage
	local OutputPower
	local Efficiency

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_efficiency_ll' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_efficiency_ll - Reading PSU $PSU Mfr low line efficiency."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x0f 0xaa"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		Response="${Response:5}"
		InputVoltage=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		Response="${Response:10}"
		OutputPower=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		Response="${Response:10}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")

		echo
		echo "The manufacturer low-line efficiency is given for an input voltage of $InputVoltage V."
		echo "At $OutputPower W, the efficiency is $TransformedString%"
		if [[ $# -eq 8 ]] ; then
			eval "$2='$InputVoltage'"
			eval "$3='$OutputPower'"
			eval "$4='$TransformedString'"
		fi

		Response="${Response:10}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		OutputPower=$TransformedString
		Response="${Response:10}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")

		echo "At $OutputPower W, the efficiency is $TransformedString%"
		if [[ $# -eq 8 ]] ; then
			eval "$5='$OutputPower'"
			eval "$6='$TransformedString'"
		fi

		Response="${Response:10}"
		OutputPower=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		Response="${Response:10}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")

		echo "At $OutputPower W, the efficiency is $TransformedString%"
		if [[ $# -eq 8 ]] ; then
			eval "$7='$OutputPower'"
			eval "$8='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_efficiency_hl
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString
	local InputVoltage
	local OutputPower

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_efficiency_hl' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_efficiency_hl - Reading PSU $PSU Mfr high line efficiency."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x0f 0xab"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		Response="${Response:5}"
		InputVoltage=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		Response="${Response:10}"
		OutputPower=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		Response="${Response:10}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")

		echo
		echo "The manufacturer high-line efficiency is given for an input voltage of $InputVoltage V."
		echo "At $OutputPower W, the efficiency is $TransformedString%"
		if [[ $# -eq 8 ]] ; then
			eval "$2='$InputVoltage'"
			eval "$3='$OutputPower'"
			eval "$4='$TransformedString'"
		fi

		Response="${Response:10}"
		OutputPower=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		Response="${Response:10}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")

		echo "At $OutputPower W, the efficiency is $TransformedString%"
		if [[ $# -eq 8 ]] ; then
			eval "$5='$OutputPower'"
			eval "$6='$TransformedString'"
		fi

		Response="${Response:10}"
		OutputPower=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		Response="${Response:10}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")

		echo "At $OutputPower W, the efficiency is $TransformedString%"
		if [[ $# -eq 8 ]] ; then
			eval "$7='$OutputPower'"
			eval "$8='$TransformedString'"
		fi
	fi

	return $RC
}

function fru_data_offset
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local MemAddr
	local WR

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'fru_data_offset' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'fru_data_offset' with insufficient number of parameters $#."
			exit
		fi

		MemAddr=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "fru_data_offset - Writing PSU $PSU FRU data pointer to $MemAddr."
		fi

		if [ -n "$MemAddr" ]; then

			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x04 0x00 0xb0 0x02 0x${MemAddr:4:2} 0x${MemAddr:2:2}"
			send_IPMICmd "$Cmd" Response
			RC=$?
		else
			echo "Bad FRU address : $MemAddr"
			(( RC = 1 ))
		fi
	else
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x03 0xb0"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			MemAddr="${Response:10:4}${Response:7:2}"
			echo "FRU Address Register = $MemAddr"
		fi
	fi

	return $RC
}

function CheckCheckSum
{
	local CheckSum
	local -i Sum=0
	local -i DecimalInt
	local -i Offset=0
	local Expected

	CheckSum=$1

	while [[ $Offset -lt ${#CheckSum} ]]; do
	
		DecimalInt=$(printf '%d' "0x${CheckSum:$Offset:2}" )
		(( OldSum = $Sum ))
		(( Sum = $Sum + $DecimalInt ))
		(( Sum = $Sum % 256 ))
		(( Offset = $Offset + 2 ))
	done
	
	if [[ $Sum -ne 0 ]]; then
	
		(( Offset = $Offset - 2 ))
		Expected=$(printf '%2.2x' $(( 256 - $OldSum )) )
		echo
		echo "Checksum mismatch: actual = '0x${CheckSum:$Offset:2}', expected = '0x$Expected'."
	fi
	
	return $Sum
}

function Hex2ASCII
{
	local -i CharNumber=0
	local CharBuf=""
	local -i INT
	local Char
	local HexString=$1
	while [[ $CharNumber -lt ${#HexString}/2 ]]; do

		Char="${HexString:$CharNumber*2:2}"
		(( INT = $(printf '%d' "0x$Char") ))
		if [ $INT -lt 32 ] || [ $INT -gt 126 ]; then
			Char="."
		else
			Char=" $Char"
			Char="${Char// /\\x}"
			Char="$Char\\n"
			Char=$(printf "$Char")
		fi
		CharBuf="$CharBuf$Char"
		(( CharNumber++ ))
	done

	eval "$2='$CharBuf'"

	return
}

function peak_current_record
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local -i exponent=2
	local TransformedString


	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'peak_current_record' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		Limit=$3
		if [ "$Verbose" = "1" ]; then
			echo
			echo "peak_current_record - Resetting PSU $PSU peak current record."
		fi

			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x06 0x00 0xe9 0x04 0xff 0xff 0xff 0xff"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "peak_current_record - Reading PSU $PSU peak current record."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x05 0xe9"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear16 "${Response:10:4}${Response:7:2}" $exponent)
			echo
			echo "Peak current            = $TransformedString A"
			if [[ $# -ge 3 ]] ; then
				eval "$3='$TransformedString'"
			fi
		fi
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear16 "${Response:20:4}${Response:17:2}" $exponent)
			echo
			echo "Historical peak current = $TransformedString A"
			if [[ $# -eq 4 ]] ; then
				eval "$4='$TransformedString'"
			fi
		fi
	fi

	return $RC
}

function read_fru_data
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local MemAddr
	local StringBuf
	local -i Retries
	local -i CharNumber
	local -i INT
	local CharBuf
	local Char
	local FormatVersion
	local UserAreaOffset
	local ChassisAreaOffset
	local BoardInfoOffset
	local ProductInfoArea
	local MultiRecordAreaOffset
	local CommonHeaderCheckSum
	local BoardInfoAreaFormatVersion
	local BoardInfoAreaLength
	local LanguageCode
	local ManufacturingDateAndTime
	local BoardManufacturerTypeAndLength
	local BoardManufacturer
	local BoardProductNameTypeAndLength
	local BoardProductName
	local BoardSerialNumberTypeAndLength
	local BoardSerialNumber
	local BoardPartNumberTypeAndLength
	local BoardPartNumber
	local FRUFileIDTypeAndLength
	local FRUFileIDData
	local EndOfFieldsIndicator
	local Reserved1
	local Reserved2
	local BoardAreaChecksum
	local InternalUseAreaFormatVersion
	local DELLFormatPresence
	local BoardInfoAreaPartNumberChecksum
	local ChassisInfoAreaPartNumberChecksum
	local ProductInfoAreaPartNumberChecksum
	local HeaderRevisionAndFlags
	local FeatureFlags
	local Units
	local EEPROMSize
	local HeaderLength
	local HeaderChecksum
	local ElementCount
	local ServiceTagType
	local ServiceTagOffset
	local AssetTagType
	local AssetTagOffset
	local Reserved3
	local RecordTypeID
	local RecordInfo
	local RecordDataLength
	local RecordDataChecksum
	local RecordHeaderChecksum
	local OverallCapacity
	local PeakVA
	local InrushCurrent
	local InrushIntervalInMS
	local LowEndInputVoltageRange1
	local HighEndInputVoltageRange1
	local LowEndInputVoltageRange2
	local HighEndInputVoltageRange2
	local LowEndInputFrequencyRange
	local HighEndInputFrequencyRange
	local ACDropoutTolerance
	local BinaryFlags
	local PeakWattage
	local CombinedWattage
	local PredictiveFailTachometerLowerThreshold
	local ServiceTagType1
	local ServiceTagOffset1
	local ServiceTagChecksum1
	local ServiceTagLength1
	local ServiceTag1
	local RelatedServiceTagCount
	local RelatedServiceTags
	local AssetTagType2
	local AssetTagOffset2
	local AssetTagChecksum2
	local AssetTagLength2
	local AssetTag2
	local Reserved
	local Minutes
	local Capacity
	local -i Seconds
	local MfrDate
	local ASCIIString="ASCIIString"
	local HexBuf
	local -i CharNumber
	local ConversionString
	local bin
	local Byte
	local Result="Result"
	local Tolerance="Tolerance"
	local _DateCmd

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'read_fru_data' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "read_fru_data - Reading PSU $PSU FRU data."
	fi

	local SaveVerbose="$Verbose"
	local SaveDebug="$Show"
	Verbose="0"
	Show="0"
	(( MemAddr = 0 ))

	echo
	StringBuf="    "
	while [ $MemAddr -lt 16 ]; do
		StringBuf=$(printf '%s %2.2X' "$StringBuf" "$MemAddr")
		(( MemAddr = $MemAddr + 1 ))
	done
	echo "$StringBuf"
	MemAddr=0
	while [ $MemAddr -lt 256 ]; do


		StringBuf=$(printf '%2.2x\n' "$MemAddr")

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x04 0x00 0xb0 0x02 0x$StringBuf 0x00"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -ne 0 ]]; then
			(( MemAddr = 256 ))
		else
			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x11 0xb1"
			send_IPMICmd "$Cmd" Response
			RC=$?
			if [[ $RC -eq 0 ]]; then
				SaveResponse="$Response"
				(( Retries = 0 ))

				Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x03 0xb0"
				send_IPMICmd "$Cmd" Response
				RC=$?
				if [ "${Response:5:9}" != "0x$StringBuf 0x00" ]; then
					if [ $Retries -gt 10 ]; then
						echo "Check of address after data read failed after $Retries retries."
						(( RC = 1 ))
						(( MemAddr = 256 ))
					fi

					(( Retries++ ))
				else
					Response="$SaveResponse"
					HexBuf=""
					(( CharNumber = 0 ))

					while [[ $CharNumber -lt 16 ]]; do

						(( CharNumber++ ))
						HexBuf="$HexBuf${Response:$CharNumber*5+2:2}"
					done

					Hex2ASCII "$HexBuf" ASCIIString

					echo "$StringBuf : ${Response:7:2} ${Response:12:2} ${Response:17:2} ${Response:22:2} ${Response:27:2} ${Response:32:2} ${Response:37:2} ${Response:42:2} ${Response:47:2} ${Response:52:2} ${Response:57:2} ${Response:62:2} ${Response:67:2} ${Response:72:2} ${Response:77:2} ${Response:82:2} | $ASCIIString"

					if [[ $MemAddr -eq 0 ]]; then
					
						FormatVersion="${Response:7:2}"
						UserAreaOffset="${Response:12:2}"
						ChassisAreaOffset="${Response:17:2}"
						BoardInfoOffset="${Response:22:2}"
						ProductInfoArea="${Response:27:2}"
						MultiRecordAreaOffset="${Response:32:2}"
						Reserved1="${Response:37:2}"
						CommonHeaderCheckSum="${Response:42:2}"
						BoardInfoAreaFormatVersion="${Response:47:2}"
						BoardInfoAreaLength="${Response:52:2}"
						LanguageCode="${Response:57:2}"
						ManufacturingDateAndTime="${Response:72:2}${Response:67:2}${Response:62:2}"
						BoardManufacturerTypeAndLength="${Response:77:2}"
						BoardManufacturer="${Response:82:2}"
					elif [[ $MemAddr -eq 16 ]]; then

						BoardManufacturer="$BoardManufacturer${Response:7:2}${Response:12:2}"
						BoardProductNameTypeAndLength="${Response:17:2}"
						BoardProductName="${Response:22:2}${Response:27:2}${Response:32:2}${Response:37:2}${Response:42:2}${Response:47:2}${Response:52:2}${Response:57:2}${Response:62:2}${Response:67:2}${Response:72:2}${Response:77:2}${Response:82:2}"
					elif [[ $MemAddr -eq 32 ]]; then

						BoardProductName="$BoardProductName${Response:7:2}${Response:12:2}${Response:17:2}${Response:22:2}${Response:27:2}${Response:32:2}${Response:37:2}${Response:42:2}${Response:47:2}${Response:52:2}${Response:57:2}${Response:62:2}${Response:67:2}${Response:72:2}${Response:77:2}${Response:82:2}"
					elif [[ $MemAddr -eq 48 ]]; then

						BoardProductName="$BoardProductName${Response:7:2}"
						BoardSerialNumberTypeAndLength="${Response:12:2}"
						BoardSerialNumber="${Response:17:2}${Response:22:2}${Response:27:2}${Response:32:2}${Response:37:2}${Response:42:2}${Response:47:2}${Response:52:2}${Response:57:2}${Response:62:2}${Response:67:2}${Response:72:2}${Response:77:2}${Response:82:2}"
					elif [[ $MemAddr -eq 64 ]]; then

						BoardPartNumberTypeAndLength="${Response:7:2}"
						BoardPartNumber="${Response:12:2}${Response:17:2}${Response:22:2}${Response:27:2}${Response:32:2}${Response:37:2}${Response:42:2}${Response:47:2}${Response:52:2}"
						
						FRUFileIDTypeAndLength="${Response:57:2}"
						FRUFileIDData="${Response:62:2}"
						EndOfFieldsIndicator="${Response:67:2}"
						Reserved2="${Response:72:2}${Response:77:2}"
						BoardAreaChecksum="${Response:82:2}"
					elif [[ $MemAddr -eq 80 ]]; then

						InternalUseAreaFormatVersion="${Response:7:2}"
						DELLFormatPresence="${Response:12:2}${Response:17:2}${Response:22:2}${Response:27:2}"
						BoardInfoAreaPartNumberChecksum="${Response:32:2}"
						ChassisInfoAreaPartNumberChecksum="${Response:37:2}"
						ProductInfoAreaPartNumberChecksum="${Response:42:2}"
						HeaderRevisionAndFlags="${Response:47:2}"
						FeatureFlags="${Response:52:2}"
						Units="${Response:57:2}"
						EEPROMSize="${Response:67:2}${Response:62:2}"
						HeaderLength="${Response:72:2}"
						HeaderChecksum="${Response:77:2}"
						ElementCount="${Response:82:2}"
					elif [[ $MemAddr -eq 96 ]]; then

						ServiceTagType="${Response:7:2}"
						ServiceTagOffset="${Response:17:2}${Response:12:2}"
						AssetTagType="${Response:22:2}"
						AssetTagOffset="${Response:32:2}${Response:27:2}"
						Reserved3="${Response:37:2}${Response:42:2}"
						RecordTypeID="${Response:47:2}"
						RecordInfo="${Response:52:2}"
						RecordDataLength="${Response:57:2}"
						RecordDataChecksum="${Response:62:2}"
						RecordHeaderChecksum="${Response:67:2}"
						OverallCapacity="${Response:77:2}${Response:72:2}"
						PeakVA="${Response:82:2}"
					elif [[ $MemAddr -eq 112 ]]; then

						PeakVA="${Response:7:2}$PeakVA"
						InrushCurrent="${Response:12:2}"
						InrushIntervalInMS="${Response:17:2}"
						LowEndInputVoltageRange1="${Response:27:2}${Response:22:2}"
						HighEndInputVoltageRange1="${Response:37:2}${Response:32:2}"
						LowEndInputVoltageRange2="${Response:47:2}${Response:42:2}"
						HighEndInputVoltageRange2="${Response:57:2}${Response:52:2}"
						LowEndInputFrequencyRange="${Response:62:2}"
						HighEndInputFrequencyRange="${Response:67:2}"
						ACDropoutTolerance="${Response:72:2}"
						BinaryFlags="${Response:77:2}"
						PeakWattage="${Response:82:2}"
					elif [[ $MemAddr -eq 128 ]]; then

						PeakWattage="${Response:7:2}$PeakWattage"
						CombinedWattage="${Response:22:2}${Response:17:2}${Response:12:2}"
						PredictiveFailTachometerLowerThreshold="${Response:27:2}"
						ServiceTagType1="${Response:32:2}"
						ServiceTagOffset1="${Response:42:2}${Response:37:2}"
						ServiceTagChecksum1="${Response:47:2}"
						ServiceTagLength1="${Response:52:2}"
						ServiceTag1="${Response:57:2}${Response:62:2}${Response:67:2}${Response:72:2}${Response:77:2}${Response:82:2}"
					elif [[ $MemAddr -eq 144 ]]; then

						ServiceTag1="$ServiceTag1${Response:7:2}"
						RelatedServiceTagCount="${Response:12:2}"
						RelatedServiceTags="${Response:17:2}${Response:22:2}${Response:27:2}${Response:32:2}${Response:37:2}${Response:42:2}${Response:47:2}"
						AssetTagType2="${Response:52:2}"
						AssetTagOffset2="${Response:62:2}${Response:57:2}"
						AssetTagChecksum2="${Response:67:2}"
						AssetTagLength2="${Response:72:2}"
						AssetTag2="${Response:77:2}${Response:82:2}"
					elif [[ $MemAddr -eq 160 ]]; then

						AssetTag2="$AssetTag2${Response:7:2}${Response:12:2}${Response:17:2}${Response:22:2}${Response:27:2}${Response:32:2}${Response:37:2}${Response:42:2}"
						Reserved="${Response:47:2}${Response:52:2}${Response:57:2}${Response:62:2}${Response:67:2}${Response:72:2}${Response:77:2}${Response:82:2}"
					else

						Reserved="$Reserved${Response:7:2}${Response:12:2}${Response:17:2}${Response:22:2}${Response:27:2}${Response:32:2}${Response:37:2}${Response:42:2}${Response:47:2}${Response:52:2}${Response:57:2}${Response:62:2}${Response:67:2}${Response:72:2}${Response:77:2}${Response:82:2}"
					fi
					(( MemAddr = $MemAddr + 16 ))
				fi
			else
				(( MemAddr = 256 ))
			fi
		fi

	done

	if [ "$FormatVersion" != "01" ]; then
		echo
		echo " *** Unexpected value at offset '00'h - Format version number ***"
		echo "Expected '0x01', read '0x$FormatVersion'."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
			echo
			echo "Offset '00'h: Format version number = 1"
			echo "   - (IPMI Platform Management FRU Information Storage Definition v1.0)."
	fi
	if [ "$UserAreaOffset" != "0a" ]; then
		echo
		echo " *** Unexpected value at offset '01'h ***"
		echo "Expected '0A'h, read '$UserAreaOffset'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '01'h: Internal User Area Starting Offset = (0Ah * 8) = '50'h."
	fi
	if [ "$ChassisAreaOffset" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '02'h - Chassis Info Area Starting Offset ***"
		echo "Expected '00'h, read '$ChassisAreaOffset'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '02'h: Chassis Info Area Starting Offset = '00'h (not used)."
	fi
	if [ "$BoardInfoOffset" != "01" ]; then
		echo
		echo " *** Unexpected value at offset '03'h - Board Info Area Starting Offset ***"
		echo "Expected '01'h, read '$BoardInfoOffset'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '03'h: Board Info Area Starting Offset = ('01'h * 8) = '08'h."
	fi
	if [ "$ProductInfoArea" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '04'h - Product Info Area Starting Offset ***"
		echo "Expected '00'h, read '$ProductInfoArea'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '04'h: Product Info Area Starting Offset = '00'h (not used)."
	fi
	if [ "$MultiRecordAreaOffset" != "0d" ]; then
		echo
		echo " *** Unexpected value at offset '05'h - Multi-Record Area Starting Offset ***"
		echo "Expected '0D'h, read '$MultiRecordAreaOffset'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '05'h: Multi-Record Area Starting Offset = ('0D'h * 8) = '68'h."
	fi
	if [ "$Reserved1" != "00" ]; then
		echo
		echo "Reserved word at offset '06'h should be '00'h, is instead '$Reserved1'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '06'h: Byte at offset '06'h is reserved ('00'h)."
	fi
	
	CheckSum="$FormatVersion$UserAreaOffset$ChassisAreaOffset$BoardInfoOffset$ProductInfoArea$MultiRecordAreaOffset$Reserved1$CommonHeaderCheckSum"
	
	CheckCheckSum $CheckSum
	if [[ $? -ne 0 ]]; then
		echo
		echo "***** CheckSum Error - Common Header Checksum, offset '07'h *****"
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '07'h: Common Header Checksum = '$CommonHeaderCheckSum'h, checksum verified."
	fi
	
	if [ "$BoardInfoAreaFormatVersion" != "01" ]; then
		echo
		echo " *** Unexpected value at offset '08'h - Board Info Area Format Version ***"
		echo "Expected '01'h, read '$BoardInfoAreaFormatVersion'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '08'h: Board Info Area Format Version = '$BoardInfoAreaFormatVersion'h."
	fi
	if [ "$BoardInfoAreaLength" != "09" ]; then
		echo
		echo " *** Unexpected value at offset '09'h - Board Info Area Length ***"
		echo "Expected '09'h, read '$BoardInfoAreaLength'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '09'h: Board Info Area Length = ('09'h * 8) = '72'h."
	fi
	if [ "$LanguageCode" != "00" ]; then
		echo
		echo " *** Unexpected value at offset 0Ah - Language Code ***"
		echo "Expected '09'h, read '$LanguageCode'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '0A'h: Language Code = '00'h (English)."
	fi
	
	Minutes=$(printf '%d' "0x$ManufacturingDateAndTime")
	(( Seconds = $Minutes * 60 + 820454400 ))
	_DateCmd="date -u -d @$Seconds"
	MfrDate=$($_DateCmd | tail -n 1)

	echo "Offset '0B'h: Manufacture Date And Time = $MfrDate"
	
#	echo "Manufacturing Date And Time = $Minutes minutes since 0:00 hrs on 1/1/96."

	if [ "$BoardManufacturerTypeAndLength" != "83" ]; then
		echo
		echo " *** Unexpected value at offset '0E'h - Board Manufacturer Type And Length ***"
		echo "Expected '83'h, read '$BoardManufacturerTypeAndLength'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '0E'h: Board Manufacturer Type And Length = '83'h"
		echo "   - (Manufacturer is specified in 6-bit ASCII packed and 3 bytes in length)."
	fi
	if [ "$BoardManufacturer" != "64c9b2" ]; then
		echo
		echo " *** Unexpected value at offset '0F'h - Board Manufacturer ***"
		echo "Expected '64C9B2'h, read '$BoardManufacturer'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '0F'h: Board Manufacturer = '64C9B2'h"
		echo "   - ('DELL' encoded in 6-bit ACSII packed format)."
	fi
	if [ "$BoardProductNameTypeAndLength" != "de" ]; then
		echo
		echo " *** Unexpected value at offset '12'h - Board Product Name Type And Length ***"
		echo "Expected 'DE'h, read '$BoardProductNameTypeAndLength'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '12'h: Board Product Name Type and Length = 'DE'h"
		echo "   - (Type code = English; number of data bytes = 30)."
	fi
	
	Hex2ASCII "$BoardProductName" ASCIIString
	echo "Offset '13'h: Board Product Name = '$ASCIIString'"
	
	if [ "$BoardSerialNumberTypeAndLength" != "ce" ]; then
		echo
		echo " *** Unexpected value at offset '31'h - Board Serial Number Type And Length ***"
		echo "Expected 'CE'h, read '$BoardSerialNumberTypeAndLength'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '31'h: Board Serial Number Type And Length = 'CE'h"
		echo "   - (Type code = English; number of data bytes = 14)."
	fi
	
	Hex2ASCII "$BoardSerialNumber" ASCIIString
	echo "Offset '32'h: Board Serial Number = '$ASCIIString'"
	
	if [ "$BoardPartNumberTypeAndLength" != "c9" ]; then
		echo
		echo " *** Unexpected value at offset '40'h - Board Part Number Type And Length ***"
		echo "Expected 'C9'h, read '$BoardPartNumberTypeAndLength'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '40'h: Board Part Number Type And Length = 'C9'h"
		echo "   - (Type code = English; number of data bytes = 9)."
	fi
	
	Hex2ASCII "$BoardPartNumber" ASCIIString
	echo "Offset '41'h: Board Part Number = '$ASCIIString'"
	
	if [[ $# -eq 2 ]]; then
	
		if [ "${ASCIIString:0:1}" = "0" ]; then
			ASCIIString="${ASCIIString:1:5}"
		else
			ASCIIString="${ASCIIString:0:5}"
		fi
		
		if [ "$2" != "$ASCIIString" ]; then
			echo
			echo "   - Board Part Number segment '$ASCIIString' does not match Dell part number '$2'."
			echo "++++++++++ Compare Error ++++++++++"
			echo
		else
			echo "   - Board Part Number segment '$ASCIIString' matches Dell mfr_id '$2'."
		fi
	fi
		
	if [ "$FRUFileIDTypeAndLength" != "c1" ]; then
		echo
		echo " *** Unexpected value at offset '4A'h - FRU File ID Type And Length ***"
		echo "Expected 'C1'h, read '$FRUFileIDTypeAndLength'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '4A'h: FRU File ID Type And Length = 'C1'h"
		echo "   - (Type code = English; number of data bytes = 1)."
	fi
	if [ "$FRUFileIDData" != "05" ]; then
		echo
		echo " *** Unexpected value at offset '4B'h - FRU File ID Data ***"
		echo "Expected '05'h, read '$FRUFileIDData'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '4B'h: FRU File ID Data = '05'h - ('05'h for 13G platform)."
	fi
	if [ "$EndOfFieldsIndicator" != "c1" ]; then
		echo
		echo " *** Unexpected value at offset '4C'h - End of Fields Indicator ***"
		echo "Expected 'C1'h, read '$EndOfFieldsIndicator'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '4C'h: End of Fields Indicator = 'C1'h."
	fi
	if [ "$Reserved2" != "0000" ]; then
		echo
		echo " *** Unexpected value at offset '4D'h - Reserved ***"
		echo "Expected '0000'h, read '$Reserved2'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '4D'h: Bytes at offsets '4D'h and '4E'h are reserved."
	fi

	CheckSum="$BoardInfoAreaFormatVersion$BoardInfoAreaLength$LanguageCode$ManufacturingDateAndTime$BoardManufacturerTypeAndLength$BoardManufacturer$BoardProductNameTypeAndLength$BoardProductName$BoardSerialNumberTypeAndLength$BoardSerialNumber$BoardPartNumberTypeAndLength$BoardPartNumber$FRUFileIDTypeAndLength$FRUFileIDData$EndOfFieldsIndicator$Reserved2$BoardAreaChecksum"
	
	CheckCheckSum $CheckSum
	if [[ $? -ne 0 ]]; then
		echo
		echo "***** CheckSum Error - Board Area Checksum, offset '4F'h *****"
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '4F'h: Board Area Checksum = '$BoardAreaChecksum'h, checksum verified."
	fi
	if [ "$InternalUseAreaFormatVersion" != "01" ]; then
		echo
		echo " *** Unexpected value at offset '50'h - Internal Use Area Format Version ***"
		echo "Expected '01'h, read '$InternalUseAreaFormatVersion'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '50'h: Internal Use Area Format Version = '01'h"
		echo "   - (IPMI Platform Management FRU Information Storage Definition v1.0)"
	fi
	if [ "$DELLFormatPresence" != "44454c4c" ]; then
		echo
		echo " *** Unexpected value at offset '51'h - DELL format Presence ***"
		echo "Expected '01'h, read '$DELLFormatPresence'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '51'h: DELL format Presence = '44454C4C'h (ASCII 'DELL')"
	fi
	if [ "$BoardInfoAreaPartNumberChecksum" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '55'h - Board Info Area Part Number Checksum ***"
		echo "Expected '00'h, read '$BoardInfoAreaPartNumberChecksum'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '55'h: Board Info Area Part Number Checksum = '00'h (Don't care)"
	fi
	if [ "$ChassisInfoAreaPartNumberChecksum" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '56'h - Chassis Info Area Part Number Checksum ***"
		echo "Expected '00'h, read '$ChassisInfoAreaPartNumberChecksum'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '56'h: Chassis Info Area Part Number Checksum = '00'h (Don't care)"
	fi
	if [ "$ProductInfoAreaPartNumberChecksum" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '57'h - Product Info Area Part Number Checksum ***"
		echo "Expected '00'h, read '$ProductInfoAreaPartNumberChecksum'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '57'h: Product Info Area Part Number Checksum = '00'h (Don't care)"
	fi
	if [ "$HeaderRevisionAndFlags" != "01" ]; then
		echo
		echo " *** Unexpected value at offset '58'h - Header Revision and Flags ***"
		echo "Expected '01'h, read '$HeaderRevisionAndFlags'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '58'h: Header Revision and Flags = '01'h (First version of this DELL Info header)."
	fi
	if [ "$FeatureFlags" != "02" ]; then
		echo
		echo " *** Unexpected value at offset '59'h - Feature Flags ***"
		echo "Expected '02'h, read '$FeatureFlags'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '59'h: Feature Flags = '02'h (DELL Info header checksum is valid)."
	fi
	if [ "$Units" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '5A'h - Feature Flags ***"
		echo "Expected '00'h, read '$Units'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '5A'h: Units = '00'h (1-byte units)."
	fi
	if [ "$EEPROMSize" != "0100" ]; then
		echo
		echo " *** Unexpected value at offset '5B'h - EEPROM Size ***"
		echo "Expected '0100'h, read '$EEPROMSize'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '5B'h: EEPROM Size = '0100'h (256 bytes)."
	fi
	if [ "$HeaderLength" != "16" ]; then
		echo
		echo " *** Unexpected value at offset '5D'h - Header Length ***"
		echo "Expected '16'h, read '$HeaderLength'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '5D'h: Dell Info Header Length = '16'h (22 bytes)."
	fi
	if [ "$HeaderChecksum" != "98" ]; then
		echo
		echo " *** Unexpected value at offset '5E'h - Header Checksum ***"
		echo "Expected '98'h, read '$HeaderChecksum'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '5E'h: Dell Info Header Checksum = '98'h."
	fi
	if [ "$ElementCount" != "02" ]; then
		echo
		echo " *** Unexpected value at offset '5F'h - Element Count ***"
		echo "Expected '02'h, read '$ElementCount'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '5F'h: Element Count = '02'h."
	fi
	if [ "$ServiceTagType" != "04" ]; then
		echo
		echo " *** Unexpected value at offset '60'h - Service Tag Type ***"
		echo "Expected '04'h, read '$ServiceTagType'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '60'h: Service Tag Type = '04'h."
	fi
	if [ "$ServiceTagOffset" != "0085" ]; then
		echo
		echo " *** Unexpected value at offset '61'h - Service Tag Offset ***"
		echo "Expected '0085'h, read '$ServiceTagOffset'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '61'h: Service Tag Offset = '0085'h."
	fi
	if [ "$AssetTagType" != "07" ]; then
		echo
		echo " *** Unexpected value at offset '63'h - Asset Tag Type ***"
		echo "Expected '07'h, read '$AssetTagType'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '63'h: Asset Tag Type = '07'h."
	fi
	if [ "$AssetTagOffset" != "009a" ]; then
		echo
		echo " *** Unexpected value at offset '64'h - Asset Tag Offset ***"
		echo "Expected '009A'h, read '$AssetTagOffset'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '64'h: Asset Tag Offset = '009A'h."
	fi
	if [ "$Reserved3" != "0000" ]; then
		echo
		echo " *** Unexpected value at offset '66'h - Reserved ***"
		echo "Expected '0000'h, read '$Reserved3'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '66'h: Bytes at offsets '66'h and '67'h are reserved."
	fi
	if [ "$RecordTypeID" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '68'h - Record Type ID ***"
		echo "Expected '00'h, read '$RecordTypeID'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '68'h: Record Type ID = '00'h (Power Supply Info)."
	fi
	if [ "$RecordInfo" != "82" ]; then
		echo
		echo " *** Unexpected value at offset '69'h - Record Info ***"
		echo "Expected '82'h, read '$RecordInfo'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '69'h: Record Info = '82'h"
		echo "   - (Bit 7 set indicates the last record in the list; Record Format Version = '2'h)."
	fi
	if [ "$RecordDataLength" != "18" ]; then
		echo
		echo " *** Unexpected value at offset '6A'h - Record Data Length ***"
		echo "Expected '18'h, read '$RecordDataLength'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '6A'h: Record Data Length = '18'h"
	fi
	
	CheckSum="$OverallCapacity$PeakVA$InrushCurrent$InrushIntervalInMS$LowEndInputVoltageRange1$HighEndInputVoltageRange1$LowEndInputVoltageRange2$HighEndInputVoltageRange2$LowEndInputFrequencyRange$HighEndInputFrequencyRange$ACDropoutTolerance$BinaryFlags$PeakWattage$CombinedWattage$PredictiveFailTachometerLowerThreshold$RecordDataChecksum"
	
	CheckCheckSum $CheckSum
	if [[ $? -ne 0 ]]; then
		echo
		echo "***** CheckSum Error - Record Data Checksum, offset '6B'h *****"
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '6B'h: Record Data Checksum = '$RecordDataChecksum'h, checksum verified."
	fi

	CheckSum="$RecordTypeID$RecordInfo$RecordDataLength$RecordDataChecksum$RecordHeaderChecksum"
	
	CheckCheckSum $CheckSum
	if [[ $? -ne 0 ]]; then
		echo
		echo "***** CheckSum Error - Record Header Checksum, offset '6C'h *****"
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '6C'h: Record Header Checksum = '$RecordHeaderChecksum'h, checksum verified."
	fi
	
	ConversionString=$(printf '%d' "0x$OverallCapacity")
	echo "Offset '6D'h: Overall Capacity = '$OverallCapacity'h ($ConversionString W)."
	if [ "$ConversionString" != "$Wattage" ] && [ "$Script" = "1" ]; then
		echo
		echo "Offset '6D'h: Overall Capacity ($ConversionString W) != PSU Wattage ($Wattage W)."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	fi
	
	ConversionString=$(printf '%d' "0x$PeakVA")
	echo "Offset '6F'h: Peak VA = '$PeakVA'h ($ConversionString VA)."

	if [ "$Script" = "1" ]; then
		MultFP $VA_max "0.02" Tolerance
		CheckFP $ConversionString $VA_max $Tolerance
		if [[ $? -ne 0 ]]; then
			echo
			echo "Peak VA ($ConversionString VA) != 1.18 x PSU Wattage ($Result VA)."
			echo "++++++++++ Compare Error ++++++++++"
			echo
			(( RC = 1 ))
		fi
	fi
	
	ConversionString=$(printf '%d' "0x$InrushCurrent")
	echo "Offset '71'h: Inrush Current = '$InrushCurrent'h ($ConversionString A)."

	if [ "$Script" = "1" ]; then
		GreaterOrEqualTo $ConversionString $Inrush_max
		if [[ $? -ne 0 ]]; then
			echo
			echo "Offset '71'h: Inrush Current ($ConversionString A) < Inrush_max ($Inrush_max A)"
			echo "++++++++++ Compare Error ++++++++++"
			echo
			(( RC = 1 ))
		fi
	fi
	
	ConversionString=$(printf '%d' "0x$InrushIntervalInMS")
	echo "Offset '72'h: Inrush Interval = '$InrushIntervalInMS'h ($ConversionString msec)."

	if [ "$Script" = "1" ]; then
		GreaterOrEqualTo $ConversionString "10"
		if [[ $? -ne 0 ]]; then
			echo
			echo "Inrush Interval ($ConversionString msec) < 10 msec."
			echo "++++++++++ Compare Error ++++++++++"
			echo
			(( RC = 1 ))
		fi
	fi

	ConversionString=$(printf '%d' "0x$LowEndInputVoltageRange1")
	MultFP $ConversionString "0.01" ConversionString
	echo "Offset '73'h: Low End Input Voltage Range = '$LowEndInputVoltageRange1'h ($ConversionString V)."

	if [ "$Script" = "1" ]; then
		CheckFP $ConversionString $Vin_min "1.0"
		if [[ $? -ne 0 ]]; then
			echo
			echo "Low End Input Voltage Range ($ConversionString V) != Vin_min ($Vin_min V)."
			echo "++++++++++ Compare Error ++++++++++"
			echo
			(( RC = 1 ))
		fi
	fi

	ConversionString=$(printf '%d' "0x$HighEndInputVoltageRange1")
	MultFP $ConversionString "0.01" ConversionString
	echo "Offset '75'h: High End Input Voltage Range = '$HighEndInputVoltageRange1'h ($ConversionString V)."

	if [ "$Script" = "1" ]; then
		CheckFP $ConversionString $Vin_max "1.0"
		if [[ $? -ne 0 ]]; then
			echo
			echo "High End Input Voltage Range ($ConversionString V) != Vin_max ($Vin_max V)."
			echo "++++++++++ Compare Error ++++++++++"
			echo
			(( RC = 1 ))
		fi
	fi

	if [ "$LowEndInputVoltageRange2" != "0000" ]; then
		echo
		echo " *** Unexpected value at offset '77'h - Low End Input Voltage Range 2 ***"
		echo "Expected '0000'h, read '0x$LowEndInputVoltageRange2'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '77'h: Low End Input Voltage Range 2 = '0000'h (not used)"
	fi
	if [ "$HighEndInputVoltageRange2" != "0000" ]; then
		echo
		echo " *** Unexpected value at offset '79'h - High End Input Voltage Range 2 ***"
		echo "Expected '0000'h, read '$HighEndInputVoltageRange2'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '79'h: High End Input Voltage Range 2 = '0000'h (not used)"
	fi

	ConversionString=$(printf '%d' "0x$LowEndInputFrequencyRange")
	echo "Offset '7B'h: Low End Input Frequency Range = '$LowEndInputFrequencyRange'h ($ConversionString Hz)."

	if [ "$Script" = "1" ]; then
		LessOrEqualTo $ConversionString "47"
		if [[ $? -ne 0 ]]; then
			echo
			echo "Low End Input Frequency Range  ($ConversionString Hz) > 47 Hz."
			echo "++++++++++ Compare Error ++++++++++"
			echo
			(( RC = 1 ))
		fi
	fi

	ConversionString=$(printf '%d' "0x$HighEndInputFrequencyRange")
	echo "Offset '7C'h: High End Input Frequency Range = '$HighEndInputFrequencyRange'h ($ConversionString Hz)."

	if [ "$Script" = "1" ]; then
		GreaterOrEqualTo $ConversionString "63"
		if [[ $? -ne 0 ]]; then
			echo
			echo "High End Input Frequency Range  ($ConversionString Hz) < 63 Hz."
			echo "++++++++++ Compare Error ++++++++++"
			echo
			(( RC = 1 ))
		fi
	fi
	
	ConversionString=$(printf '%d' "0x$ACDropoutTolerance")
	echo "Offset '7D'h: AC Dropout Tolerance = '$ACDropoutTolerance'h ($ConversionString msec)."
	if [ "$Script" = "1" ]; then
		GreaterOrEqualTo $ConversionString $ACDropoutTimeMS
		if [[ $? -ne 0 ]]; then
			echo
			echo "AC Dropout Tolerance ($ConversionString msec) < $ACDropoutTimeMS msec."
			echo "++++++++++ Compare Error ++++++++++"
			echo
			(( RC = 1 ))
		fi
	fi

	echo "Offset '7E'h: Binary Flags = '$BinaryFlags'h :"
	echo
	Byte=$(printf '%d\n' "0x$BinaryFlags")
	bin=$(dec2bin $Byte)

	if [ "${bin:0:1}" = "1" ]; then
		(( RC = 1 ))
		echo
		echo "   Bit 7 is reserved, yet is set to '1'."
		echo "++++++++++ Compare Error ++++++++++"
		echo
	fi
	if [ "${bin:1:1}" = "1" ]; then
		(( RC = 1 ))
		echo
		echo "   Bit 6 is reserved, yet is set to '1'."
		echo "++++++++++ Compare Error ++++++++++"
		echo
	fi
	if [ "${bin:2:1}" = "1" ]; then
		echo "   PSU is PMBUS capable."
	else
		(( RC = 1 ))
		echo
		echo "   PSU is not PMBUS capable."
		echo "++++++++++ Compare Error ++++++++++"
		echo
	fi
	if [ "${bin:3:1}" = "1" ]; then
		(( RC = 1 ))
		echo "   Predictive fail polarity = 1."
	else
		echo "   Predictive fail polarity = 0."
	fi
	if [ "${bin:4:1}" = "1" ]; then
		echo "   PSU is Hot Swap capable."
	else
		(( RC = 1 ))
		echo
		echo "   PSU is not Hot Swap capable."
		echo "++++++++++ Compare Error ++++++++++"
		echo
	fi
	if [ "${bin:5:1}" = "1" ]; then
		echo "   PSU supports Auto-Switching."
	else
		(( RC = 1 ))
		echo
		echo "   PSU does not support Auto-Switching."
		echo "++++++++++ Compare Error ++++++++++"
		echo
	fi
	if [ "${bin:6:1}" = "1" ]; then
		echo "   PSU supports Power Factor Correction."
	else
		(( RC = 1 ))
		echo
		echo "   PSU does not support Power Factor Correction."
		echo "++++++++++ Compare Error ++++++++++"
		echo
	fi
	if [ "${bin:7:1}" = "1" ]; then
		echo "   PSU supports Predictive Fail Pin."
	else
		(( RC = 1 ))
		echo
		echo "   PSU does not support Predictive Fail Pin."
		echo "++++++++++ Compare Error ++++++++++"
		echo
	fi
	echo
	if [ "$PeakWattage" != "ffff" ]; then
		echo
		echo " *** Unexpected value at offset 7Fh - Peak Wattage ***"
		echo "Expected 'FFFF'h, read '$PeakWattage'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '7F'h: Peak Wattage = 'FFFF'h (not used by Dell)."
	fi
	if [ "$CombinedWattage" != "000000" ]; then
		echo
		echo " *** Unexpected value at offset '81'h - Combined Wattage ***"
		echo "Expected '000000'h, read '$CombinedWattage'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '81'h: Combined Wattage = '000000'h (not used by Dell)."
	fi

	if [ "$PredictiveFailTachometerLowerThreshold" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '84'h - Predictive fail tachometer lower threshold ***"
		echo "Expected '00'h, read '$PredictiveFailTachometerLowerThreshold'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '84'h: Predictive fail tachometer lower threshold = '00'h (not used by Dell)."
	fi
	if [ "$ServiceTagType1" != "04" ]; then
		echo
		echo " *** Unexpected value at offset '85'h - Service Tag Type ***"
		echo "Expected '04'h, read '$ServiceTagType1'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '85'h: Service Tag Type = '04'h."
	fi
	if [ "$ServiceTagOffset1" != "0015" ]; then
		echo
		echo " *** Unexpected value at offset '86'h - Service Tag Offset ***"
		echo "Expected '0015'h, read '$ServiceTagOffset1'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '86'h: Service Tag Offset = '0015'h."
	fi
	if [ "$ServiceTagChecksum1" != "df" ]; then
		echo
		echo " *** Unexpected value at offset '88'h - Service Tag Checksum ***"
		echo "Expected 'DF'h, read '$ServiceTagChecksum1'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '88'h: Service Tag Checksum = 'DF'h."
	fi
	if [ "$ServiceTagLength1" != "07" ]; then
		echo
		echo " *** Unexpected value at offset '89'h - Service Tag Length ***"
		echo "Expected '07'h, read '$ServiceTagLength1'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '89'h: Service Tag Length = '07'h."
	fi
	if [ "$ServiceTag1" != "00000000000000" ]; then
		echo
		echo " *** Unexpected value at offset '8A'h - Service Tag ***"
		echo "Expected '00000000000000'h, read '$ServiceTag1'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '8A'h: Service Tag = '00000000000000'h (not used)."
	fi
	if [ "$RelatedServiceTagCount" != "01" ]; then
		echo
		echo " *** Unexpected value at offset '91'h - Related Service Tag Count ***"
		echo "Expected '01'h, read '$RelatedServiceTagCount'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '91'h: Related Service Tag Count = '01'h."
	fi
	if [ "$RelatedServiceTags" != "00000000000000" ]; then
		echo
		echo " *** Unexpected value at offset '92'h - Related Service Tags ***"
		echo "Expected '00000000000000'h, read '$RelatedServiceTags'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '92'h: Related Service Tags = '00000000000000'h (not used)."
	fi
	if [ "$AssetTagType2" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '99'h - Asset Tag Type ***"
		echo "Expected '00'h, read '$AssetTagType2'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '99'h: Asset Tag Type = '00'h."
	fi
	if [ "$AssetTagOffset2" != "0f07" ]; then
		echo
		echo " *** Unexpected value at offset '9A'h - Asset Tag Offset ***"
		echo "Expected '0F07'h, read '$AssetTagOffset2'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '9A'h: Asset Tag Offset = '0F07'h."
	fi
	if [ "$AssetTagChecksum2" != "00" ]; then
		echo
		echo " *** Unexpected value at offset '9C'h - Asset Tag Checksum ***"
		echo "Expected '00'h, read '$AssetTagChecksum2'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '9C'h: Asset Tag Checksum = '00'h."
	fi
	if [ "$AssetTagLength2" != "e0" ]; then
		echo
		echo " *** Unexpected value at offset '9D'h - Asset Tag Length ***"
		echo "Expected 'E0'h, read '$AssetTagLength2'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '9D'h: Asset Tag Length = 'E0'h."
	fi
	if [ "$AssetTag2" != "0a000000000000000000" ]; then
		echo
		echo " *** Unexpected value at offset '9E'h - Asset Tag ***"
		echo "Expected '0A000000000000000000'h, read '$AssetTag2'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset '9E'h: Asset Tag = '0A000000000000000000'h (not used)."
	fi
	if [ "$Reserved" != "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" ]; then
		echo
		echo " *** Unexpected value at offset 'A8'h - Reserved Area ***"
		echo "Expected '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'h, read '$Reserved'h."
		echo "++++++++++ Compare Error ++++++++++"
		echo
		(( RC = 1 ))
	else
		echo "Offset 'A8'h: Reserved Area filled with '00'h."
	fi
	
	echo
	
	Verbose="$SaveVerbose"
	Show="$SaveDebug"

	return $RC
}

function mfr_efficiency_data
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin
	local -i exponent=4

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_efficiency_data' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_efficiency_data - Reading PSU $PSU Mfr efficiency data."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0a $PSUAddress 0x20 0x01 0x1a 0xb3"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		if [ "${Response:0:4}" != "0x19" ]; then
			(( RC = 1 ))
			echo "Block count incorrect, expecting '0x19', received '${Response:0:4}'."
		fi
		
		Response="${Response:5}"
		
		Byte=$(printf '%d\n' ${Response:0:4})
		if [[ $# -eq 14 ]] ; then
			eval "$2='${Response:0:4}'"
		fi
		
		bin=$(dec2bin $Byte)

		echo
		
		if [ "${bin:0:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Byte 0, bit 7 is reserved but is asserted."
		fi
		if [ "${bin:1:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Byte 0, bit 6 is reserved but is asserted."
		fi
		if [ "${bin:2:1}" = "0" ] && [ "${bin:3:1}" = "0" ]; then
			echo "Byte 0, bits 5:4 = '00' - Not an AC input."
		elif [ "${bin:2:1}" = "0" ] && [ "${bin:3:1}" = "1" ]; then
			echo "Byte 0, bits 5:4 = '01' - Low line AC."
		elif [ "${bin:2:1}" = "1" ] && [ "${bin:3:1}" = "0" ]; then
			echo "Byte 0, bits 5:4 = '10' - High Line AC."
		elif [ "${bin:2:1}" = "1" ] && [ "${bin:3:1}" = "1" ]; then
			echo "Byte 0, bits 5:4 = '11' - Extended high line AC."
		else
			(( RC = 1 ))
			echo "Error decoding byte 0, bits 5:4."
		fi
		if [ "${bin:4:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Byte 0, bit 3 is reserved but is asserted."
		fi
		if [ "${bin:5:1}" = "1" ]; then
			(( RC = 1 ))
			echo "Byte 0, bit 2 is reserved but is asserted."
		fi
		if [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "0" ]; then
			echo "Byte 0, bits 1:0 = '00' - Not a DC input."
		elif [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "1" ]; then
			echo "Byte 0, bits 1:0 = '01' - Telecom DC."
		elif [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "0" ]; then
			echo "Byte 0, bits 1:0 = '10' - Low line DC."
		elif [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "1" ]; then
			echo "Byte 0, bits 1:0 = '11' - High line DC."
		else
			(( RC = 1 ))
			echo "Error decoding byte 0, bits 5:4."
		fi

		TransformedString=$(DecodeLinear16 "${Response:10:4}${Response:7:2}" $exponent)
		echo "Input Power During Sleep     = $TransformedString W"
		if [[ $# -eq 14 ]] ; then
			eval "$3='$TransformedString'"
		fi
		
		TransformedString=$(DecodeLinear16 "${Response:20:4}${Response:17:2}" $exponent)
		echo "Efficiency data at 5% load   = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "$4='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:30:4}${Response:27:2}" $exponent)
		echo "Efficiency data at 10% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "$5='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:40:4}${Response:37:2}" $exponent)
		echo "Efficiency data at 20% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "$6='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:50:4}${Response:47:2}" $exponent)
		echo "Efficiency data at 30% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "$7='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:60:4}${Response:57:2}" $exponent)
		echo "Efficiency data at 40% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "$8='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:70:4}${Response:67:2}" $exponent)
		echo "Efficiency data at 50% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "$9='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:80:4}${Response:77:2}" $exponent)
		echo "Efficiency data at 60% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "${10}='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:90:4}${Response:87:2}" $exponent)
		echo "Efficiency data at 70% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "${11}='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:100:4}${Response:97:2}" $exponent)
		echo "Efficiency data at 80% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "${12}='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:110:4}${Response:107:2}" $exponent)
		echo "Efficiency data at 90% load  = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "${13}='$TransformedString'"
		fi

		TransformedString=$(DecodeLinear16 "${Response:120:4}${Response:117:2}" $exponent)
		echo "Efficiency data at 100% load = $TransformedString%"
		if [[ $# -eq 14 ]] ; then
			eval "${14}='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_max_temp_1
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_max_temp_1' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_max_temp_1 - Reading PSU $PSU Mfr location 1 maximum temperature."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xc0"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo "Mfr Maximum Temperature 1 = $TransformedString C"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_max_temp_2
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_max_temp_2' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_max_temp_2 - Reading PSU $PSU Mfr location 2 maximum temperature."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xc1"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo "Mfr Maximum Temperature 2 = $TransformedString C"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function mfr_device_code
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_device_code' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_device_code - Reading PSU $PSU Mfr device code."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x20 0x01 0x05 0xd0"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		echo
		echo "MFR Device Code = ${Response:2:2}${Response:7:2}${Response:12:2}${Response:17:2}${Response:22:2}"
		echo

	fi

	return $RC
}

function isp_key
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Key

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'isp_key' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	PSUAddress=$(GetPSUAddress $PSU)
	Key=$2

	if [ "$Verbose" = "1" ]; then
		echo
		echo "isp_key - Writing PSU $PSU ISP Key '$Key'."
	fi

	if [ "$Key" = "dell" ]; then
		KeyString="0x64 0x45 0x6c 0x6c"
	elif [ "$Key" = "fmod" ]; then
		KeyString="0x46 0x6d 0x6f 0x64"
	else
		echo "Call made to function 'isp_key' with invalid key '$Key'."
		exit
	fi
		
	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0c $PSUAddress 0x20 0x05 0x00 0xd1 $KeyString"
	send_IPMICmd "$Cmd" Response
	RC=$?

	return $RC
}

function isp_status_cmd
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local ISPCmd

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'isp_status_cmd' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'isp_status_cmd' with insufficient number of parameters $#."
			exit
		fi

		ISPCmd=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "isp_status_cmd - Writing PSU $PSU ISP Command $ISPCmd."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0xd2 $ISPCmd"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "isp_status_cmd - Reading PSU $PSU ISP Status."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xd2"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			echo "ISP Status = '${Response:0:4}'"
		fi
	fi

	return $RC
}

function system_led_cntl
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Color
	local State
	local Mask

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'system_led_cntl' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		if [[ $# -lt 4 ]] ; then
			echo "Call made to function 'system_led_cntl' with insufficient number of parameters $#."
			exit
		fi

		Color=$3
		State=$4

		if [ "$Verbose" = "1" ]; then
			echo
			echo "system_led_cntl - Writing PSU $PSU LED control to $State state with the color $Color."
		fi

		if [ "$Color" = "green" ] &&  [ "$State" = "blink" ]; then
			Mask="0x02"
		elif [ "$Color" = "green" ] &&  [ "$State" = "solid" ]; then
			Mask="0x04"
		elif [ "$Color" = "amber" ] &&  [ "$State" = "blink" ]; then
			Mask="0x03"
		elif [ "$Color" = "amber" ] &&  [ "$State" = "solid" ]; then
			Mask="0x05"
		elif [ "$State" = "off" ]; then
			Mask="0x00"
		else
			(( RC = 1 ))
			echo "Unknown state requested for LED control."
		fi

		if [[ $RC -eq 0 ]]; then
			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0xd7 $Mask"
			send_IPMICmd "$Cmd" Response
			RC=$?
		fi
	else
		local Byte
		local bin

		if [ "$Verbose" = "1" ]; then
			echo
			echo "system_led_cntl - Reading PSU $PSU LED control register..."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xd7"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})

			bin=$(dec2bin $Byte)

			echo
			echo "Returned '${bin:0:4} ${bin:4:4}'b"
			echo

			if [ "${bin:0:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 7 is reserved and is asserted in response"
			fi
			if [ "${bin:1:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 6 is reserved and is asserted in response"
			fi
			if [ "${bin:2:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 5 is reserved and is asserted in response"
			fi
			if [ "${bin:3:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 4 is reserved and is asserted in response"
			fi
			if [ "${bin:4:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 3 is reserved and is asserted in response"
			fi
			if [ "${bin:5:1}" = "0" ] && [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "0" ]; then
				echo "System LED control disabled."
			elif [ "${bin:5:1}" = "0" ] && [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: LED control state is reserved - 001b."
			elif [ "${bin:5:1}" = "0" ] && [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "0" ]; then
				echo "Blink Green at 1Hz rate - 010b."
			elif [ "${bin:5:1}" = "0" ] && [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "1" ]; then
				echo "Blink Amber 2s on, 1s off - 011b."
			elif [ "${bin:5:1}" = "1" ] && [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "0" ]; then
				echo "Solid Green - 100b."
			elif [ "${bin:5:1}" = "1" ] && [ "${bin:6:1}" = "0" ] && [ "${bin:7:1}" = "1" ]; then
				echo "Solid Amber - 101b."
			elif [ "${bin:5:1}" = "1" ] && [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "0" ]; then
				(( RC = 1 ))
				echo "Error: LED control state is reserved - 110b."
			elif [ "${bin:5:1}" = "1" ] && [ "${bin:6:1}" = "1" ] && [ "${bin:7:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: LED control state is reserved - 111b."
			fi
		fi
	fi

	return $RC
}

function isp_memory_addr
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'isp_memory_addr' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local ISPMemAddr

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'isp_memory_addr' with insufficient number of parameters $#."
			exit
		fi

		ISPMemAddr=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "isp_memory_addr - Writing PSU $PSU memory address register."
		fi

		if [ -n "$ISPMemAddr" ]; then

			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0xd3 $ISPMemAddr 0x00"
			send_IPMICmd "$Cmd" Response
			RC=$?

		else
			echo "Bad ISP memory address : $ISPMemAddr"
			(( RC = 1 ))
		fi
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "isp_memory_addr - Reading PSU $PSU memory address register."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 $PSUAddress 0x00 0x01 0x02 0xd3"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			ISPMemAddr="${Response:5:4}${Response:2:2}"
			echo "ISP Memory Address Register = $ISPMemAddr"
		fi
	fi

	return $RC
}

function isp_memory
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local SaveVerbose
	local SaveDebug
	local MemAddr
	local StringBuf

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'isp_memory' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "isp_memory - Reading PSU $PSU ISP memory..."
	fi

	SaveVerbose="$Verbose"
	SaveDebug="$Show"
	Verbose="0"
	Show="0"
	(( MemAddr = 0 ))

	while [ $MemAddr -lt 256 ]; do

		local -i CharNumber
		local CharBuf
		local Char
		local -i INT

#		StringBuf=$(printf '%2.2x\n' "$MemAddr")

#		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x04 0x00 0xd4 0x02 0x$StringBuf 0x00"
#		send_IPMICmd "$Cmd" Response
#		RC=$?
#		if [[ $RC != 0 ]]; then
#			(( MemAddr = 256 ))
#		else
			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x20 0x01 0x10 0xd4"
			send_IPMICmd "$Cmd" Response
			RC=$?
			if [[ $RC -eq 0 ]]; then
				(( CharNumber = 0 ))
				CharBuf=""

				while [ $CharNumber -lt 16 ]; do
					(( CharNumber++ ))
					Char="${Response:$CharNumber*5+2:2}"
					(( INT = $(printf '%d' "0x$Char") ))
					if [ $INT -lt 32 ] || [ $INT -gt 126 ]; then
						Char="."
					else
						Char=" $Char"
						Char="${Char// /\\x}"
						Char="$Char\\n"
						Char=$(printf "$Char")
					fi

					CharBuf="$CharBuf$Char"
				done

				echo "$StringBuf : ${Response:7:2} ${Response:12:2} ${Response:17:2} ${Response:22:2} ${Response:27:2} ${Response:32:2} ${Response:37:2} ${Response:42:2} ${Response:47:2} ${Response:52:2} ${Response:57:2} ${Response:62:2} ${Response:67:2} ${Response:72:2} ${Response:77:2} ${Response:82:2} | $CharBuf"
			else
				(( MemAddr = 256 ))
			fi
#		fi

		(( MemAddr = $MemAddr + 16 ))
	done

	Verbose="$SaveVerbose"
	Show="$SaveDebug"

	return $RC
}

function fw_version
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local -i CharNumber
	local CharBuf
	local Char
	local -i INT

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'fw_version' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "fw_version - Reading PSU $PSU FW version."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0a $PSUAddress 0x20 0x01 0x09 0xd5"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		(( CharNumber = 0 ))
		CharBuf=""

		while [ $CharNumber -lt 8 ]; do
			(( CharNumber++ ))
			Char="${Response:$CharNumber*5+2:2}"
			(( INT = $(printf '%d' "0x$Char") ))
			if [ $INT -lt 32 ] || [ $INT -gt 126 ]; then
				Char="."
			else
				Char=" $Char"
				Char="${Char// /\\x}"
				Char="$Char\\n"
				Char=$(printf "$Char")
			fi

			CharBuf="$CharBuf$Char"
		done

		echo "FW version = '$CharBuf'"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$CharBuf'"
		fi
	fi

	return $RC
}

function bootloader_version
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local -i CharNumber
	local CharBuf
	local Char
	local -i INT

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'bootloader_version' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "bootloader_version - Reading PSU $PSU bootloader version."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xd6"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		echo "Bootloader version = '${Response:5:4}${Response:2:2}'"
	fi

	return $RC
}

function tot_mfr_pout_max
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local TransformedString

	if [[ $# -lt 1 ]] ; then
		echo "tot_mfr_pout_max - Call made to function 'tot_mfr_pout_max' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "tot_mfr_pout_max - Reading PSU $PSU Mfr maximum total output power."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xda"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		echo "Total Mfr Maximum Power Out = $TransformedString W"
		if [[ $# -eq 2 ]] ; then
			eval "$2='$TransformedString'"
		fi
	fi

	return $RC
}

function ocw_setting_write
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local -i exponent=2
	local OCW
	local AssnThr
	local AvgWnd
	local Mask
	local -i Byte

	if [[ $# -lt 4 ]] ; then
		echo "Call made to function 'ocw_setting_write' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	OCW=$2
	AssnThr=$3
	AvgWnd=$4

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$OCW" = "1" ]; then
		(( Byte = 0 ))
	elif [ "$OCW" = "2" ]; then
		(( Byte = 1 ))
	elif [ "$OCW" = "3" ]; then
		(( Byte = 2 ))
	else
		echo "Invalid OCW number"
		(( RC = 1 ))
	fi

	if [[ $RC -eq 0 ]]; then

		if [[ -n "$AssnThr" ]]; then
			(( Byte = $Byte | 4 ))

			TransformedString=$(EncodeLinear16 $AssnThr $exponent)
			AssnHI="${TransformedString:0:2}"
			AssnLO="${TransformedString:2:2}"

		else
			AssnHI="00"
			AssnLO="00"
		fi

		if [ -n "$AvgWnd" ]; then
			if [ "$Verbose" = "1" ]; then
				echo
				echo "ocw_setting_write - Writing PSU $PSU OCW$OCW Assertion Threshold to $AssnThr A, Averaging Window to $AvgWnd msec"
			fi

			(( Byte = $Byte | 8 ))
			(( exponent = 0 ))

			TransformedString=$(EncodeLinear16 $AvgWnd $exponent)
			WndHI="${TransformedString:0:2}"
			WndLO="${TransformedString:2:2}"
		else
			WndHI="00"
			WndLO="00"
		fi

		Mask=$(printf '%2.2x\n' "$Byte")
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x07 0x00 0xdb 0x05 0x$Mask 0x$AssnLO 0x$AssnHI 0x$WndLO 0x$WndHI"
		send_IPMICmd "$Cmd" Response
		RC=$?
	fi

	return $RC
}

function ocw_setting_read
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local -i exponent=2
	local OCW
	local AssnThr
	local AvgWnd
	local Mask

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'ocw_setting_read' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	OCW=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "ocw_setting_read - Reading PSU $PSU OCW$OCW overcurrent warning settings."
	fi

	if [ "$OCW" = "1" ]; then
		Mask="0x00"
	elif [ "$OCW" = "2" ]; then
		Mask="0x01"
	elif [ "$OCW" = "3" ]; then
		Mask="0x02"
	else
		echo "Invalid OCW number"
		(( RC = 1 ))
	fi

	if [[ $RC -eq 0 ]]; then
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e $PSUAddress 0x00 0x03 0x09 0xdc 0x01 $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	fi

	if [[ $RC -eq 0 ]]; then
		echo
		echo "Settings for OCW$OCW:"

		TransformedString=$(DecodeLinear16 "${Response:10:4}${Response:7:2}" $exponent)
		AssnThr=$TransformedString
		echo "   Assertion Threshold    = $AssnThr A"

		Response="${Response:15}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		AvgWnd=$TransformedString
		echo "   Average window length  = $AvgWnd msec"

		Response="${Response:10}"
		TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
		SamplingRate=$TransformedString
		echo "   Sampling Rate          = $SamplingRate KHz"

		Response="${Response:10}"
		TransformedString=$(DecodeLinear16 "${Response:5:4}${Response:2:2}" $exponent)
		DeassnThr=$TransformedString
		echo "   De-assertion threshold = $DeassnThr A"
		if [[ $# -eq 6 ]] ; then
			eval "$3='$AssnThr'"
			eval "$4='$AvgWnd'"
			eval "$5='$SamplingRate'"
			eval "$6='$DeassnThr'"
		fi
	fi

	return $RC
}

function ocw_setting_range
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local -i exponent
	local OCW
	local AssnThrUpperLimit
	local AssnThrLowerLimit
	local AvgWndUpperLimit
	local AvgWndLowerLimit
	local Mask

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'ocw_setting_range' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	OCW=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "ocw_setting_range - Reading PSU $PSU OCW$OCW setting ranges."
	fi

	if [ "$OCW" = "1" ]; then
		Mask="0x00"
	elif [ "$OCW" = "2" ]; then
		Mask="0x01"
	elif [ "$OCW" = "3" ]; then
		Mask="0x02"
	else
		echo "Invalid OCW number"
		(( RC = 3 ))
	fi

	if [[ $RC -eq 0 ]]; then
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8e $PSUAddress 0x00 0x03 0x09 0xdf 0x01 $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	fi

	if [[ $RC -eq 0 ]]; then
		echo "Settings for OCW$OCW:"

		TransformedString=$(DecodeLinear11 "${Response:10:4}${Response:7:2}")
		AvgWndUpperLimit=$TransformedString
		echo "   Average window length upper limit = $AvgWndUpperLimit msec"

		TransformedString=$(DecodeLinear11 "${Response:20:4}${Response:17:2}")
		AvgWndLowerLimit=$TransformedString
		echo "   Average window length lower limit = $AvgWndLowerLimit msec"

		(( exponent = 2 ))
		TransformedString=$(DecodeLinear16 "${Response:30:4}${Response:27:2}" $exponent)
		AssnThrUpperLimit=$TransformedString
		echo "   Assertion threshold upper limit   = $AssnThrUpperLimit A"

		(( exponent = 2 ))
		TransformedString=$(DecodeLinear16 "${Response:40:4}${Response:37:2}" $exponent)
		AssnThrLowerLimit=$TransformedString
		echo "   Assertion threshold lower limit   = $AssnThrLowerLimit A"

		echo
		
		if [[ $# -eq 6 ]] ; then
			eval "$3='$AvgWndUpperLimit'"
			eval "$4='$AvgWndLowerLimit'"
			eval "$5='$AssnThrUpperLimit'"
			eval "$6='$AssnThrLowerLimit'"
		fi
	fi

	return $RC
}

function ocw_status
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local -i exponent=2
	local WR
	local Mask
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'ocw_status' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2
	Mask=$3

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ -z "$Mask" ]]; then
			Mask="0xff"
		fi

		if [ "$Verbose" = "1" ]; then
			echo
			echo "ocw_status - Clearing PSU $PSU overcurrent warning status with mask of $Mask."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0xdd $Mask"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "ocw_status - Reading PSU $PSU overcurrent warning status."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xdd"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})

			bin=$(dec2bin $Byte)

			echo
			echo "Register 'ocw_status' returned '${bin:0:4} ${bin:4:4}'b"
			echo

			echo "${bin:0:1} - Bit 7 is undefined."
			echo "${bin:1:1} - Bit 6 is undefined."
			echo "${bin:2:1} - Bit 5 is undefined."
			echo "${bin:3:1} - Bit 4 is undefined."
			echo "${bin:4:1} - Bit 3 is undefined."
			echo "${bin:5:1} - OCW3 has occurred."
			echo "${bin:6:1} - OCW2 has occurred."
			echo "${bin:7:1} - OCW1 has occurred."
		fi
	fi

	echo
	return $RC
}

function ocw_counter
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'ocw_counter' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "ocw_counter - Reading PSU $PSU overcurrent warning counters."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x00 0x01 0x06 0xde"
	send_IPMICmd "$Cmd" Response
	RC=$?

	if [[ $RC -eq 0 ]]; then

		Byte=$(printf '%d\n' ${Response:5:4})
		echo "OCW1 Counter = $Byte"
		if [[ $# -eq 5 ]] ; then
			eval "$2='$Byte'"
		fi

		Byte=$(printf '%d\n' ${Response:10:4})
		echo "OCW2 Counter = $Byte"
		if [[ $# -eq 5 ]] ; then
			eval "$3='$Byte'"
		fi

		Byte=$(printf '%d\n' ${Response:15:4})
		echo "OCW3 Counter = $Byte"
		if [[ $# -eq 5 ]] ; then
			eval "$4='$Byte'"
		fi

		Byte=$(printf '%d\n' ${Response:20:4})
		echo "IOUT_OC_WARNING Counter = $Byte"
		if [[ $# -eq 5 ]] ; then
			eval "$5='$Byte'"
		fi
	fi

	return $RC
}

function mfr_rapidon_cntrl
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'mfr_rapidon_cntrl' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local RapidOn

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'mfr_rapidon_cntrl' with insufficient number of parameters $#."
			exit
		fi

		RapidOn=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_rapidon_cntrl - Writing  PSU $PSU rapid on state to '$RapidOn'."
		fi

		if [ "$RapidOn" = "normal" ]; then
			Byte="0x00"
		elif [ "$RapidOn" = "ats" ]; then
			Byte="0x01"
		elif [ "$RapidOn" = "roa" ]; then
			Byte="0x03"
		else
			(( RC = 1 ))
			echo "Invalid Rapid On State requested."
		fi

		if [[ $RC -eq 0 ]]; then

			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0xe0 $Byte"
			send_IPMICmd "$Cmd" Response
			RC=$?
		fi
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_rapidon_cntrl - Reading PSU $PSU rapid on settings."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xe0"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Returned '${bin:0:4} ${bin:4:4}'b"
			echo

			if [ "${bin:0:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 7 is undefined and is asserted in response"
			fi
			if [ "${bin:1:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 6 is undefined and is asserted in response"
			fi
			if [ "${bin:2:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 5 is undefined and is asserted in response"
			fi
			if [ "${bin:3:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 4 is undefined and is asserted in response"
			fi
			if [ "${bin:4:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 3 is undefined and is asserted in response"
			fi
			if [ "${bin:5:1}" = "1" ]; then
				echo "PSU is in SLEEP state."
			else
				echo "PSU is not in SLEEP state."
			fi
			if [ "${bin:6:1}" = "1" ];  then
				if [ "${bin:7:1}" = "1" ]; then
					echo "PSU reports it is in the ROA state."
				else
					echo "PSU reports it is in the MAIN OFF or STANDBY state."
				fi
			elif [ "${bin:7:1}" = "1" ]; then
				echo "PSU reports it is in ATS state."
			else
				echo "PSU reports it is in NORMAL state."
			fi
		fi
	fi

	return $RC
}

function mfr_sleep_trip
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Trip

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'mfr_sleep_trip' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local LO

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'mfr_sleep_trip' with insufficient number of parameters $#."
			exit
		fi

		Trip=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_sleep_trip - Writing PSU $PSU sleep trip threshold to $Trip%."
		fi

		LO=$(printf '%x\n' "$Trip")
		if [ ${#LO} -lt 2 ]; then
			LO="0$LO"
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0xe1 0x$LO 0x00"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_sleep_trip - Reading PSU $PSU sleep trip threshold."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xe1"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			Trip=$(printf '%d\n' "${Response:5:4}${Response:2:2}")
			echo "Sleep Trip = $Trip%"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$Trip'"
			fi
		fi
	fi

	return $RC
}

function mfr_wake_trip
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Trip

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'mfr_wake_trip' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local LO

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'mfr_wake_trip' with insufficient number of parameters $#."
			exit
		fi

		Trip=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_wake_trip - Writing PSU $PSU wake trip threshold to $Trip%."
		fi

		LO=$(printf '%x\n' "$Trip")
		if [ ${#LO} -lt 2 ]; then
			LO="0$LO"
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0xe2 0x$LO 0x00"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_wake_trip - Reading PSU $PSU wake trip threshold."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xe2"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			Trip=$(printf '%d\n' "${Response:5:4}${Response:2:2}")
			echo "Wake Trip = $Trip%"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$Trip'"
			fi
		fi
	fi

	return $RC
}

function mfr_trip_latency
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Latency
	local -i exponent=2

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'mfr_trip_latency' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)


	if [ "$WR" = "1" ]; then

		local LO

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'mfr_trip_latency' with insufficient number of parameters $#."
			exit
		fi

		Latency=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_trip_latency - Writing PSU $PSU trip latency to $Latency sec."
		fi

		TransformedString=$(FixedEncodeLinear11 $Latency $exponent)
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x88 $PSUAddress 0x00 0x03 0x00 0xe3 0x${TransformedString:2:2} 0x${TransformedString:0:2}"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_trip_latency - Reading PSU $PSU trip latency value."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x86 $PSUAddress 0x00 0x01 0x02 0xe3"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then
			TransformedString=$(DecodeLinear11 "${Response:5:4}${Response:2:2}")
			echo "MFR Trip Latency = $TransformedString seconds"
			if [[ $# -eq 3 ]] ; then
				eval "$3='$TransformedString'"
			fi
		fi
	fi

	return $RC
}

function mfr_page
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Page

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'mfr_page' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then
		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'mfr_page' with insufficient number of parameters $#."
			exit
		fi

		Page=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_page - Writing PSU $PSU Mfr page to $Page."
		fi

		if [ "${Page:0:2}" != "0x" ]; then
			Page=$(printf '0x%2.2x\n' $Page)
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0xe4 $Page"
		send_IPMICmd "$Cmd" Response
		RC=$?
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "mfr_page - Reading PSU $PSU Mfr page."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xe4"
		send_IPMICmd "$Cmd" Response
		RC=$?
		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			echo "MFR Page = $Response"
		fi
	fi

	return $RC
}

function mfr_pos_total
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local -i Seconds
	

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_pos_total' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_pos_total - Reading PSU $PSU Mfr total power-on time."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x20 0x01 0x04 0xe5"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		Seconds=$(printf '%d' "${Response:15:4}${Response:12:2}${Response:7:2}${Response:2:2}")

		echo
		echo "Total Power On Seconds = $Seconds"
		echo 
		if [[ $# -eq 2 ]] ; then
			eval "$2='$Seconds'"
		fi
	fi

	return $RC
}

function mfr_pos_last
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Seconds

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_pos_last' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_pos_last - Reading PSU $PSU Mfr power-on time since last power off."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a $PSUAddress 0x20 0x01 0x04 0xe6"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then
		Seconds=$(printf '%d' "${Response:15:4}${Response:12:2}${Response:7:2}${Response:2:2}")
		echo
		echo "Power On Seconds Since Last Power Off = $Seconds"
		echo
		if [[ $# -eq 2 ]] ; then
			eval "$2='$Seconds'"
		fi
	fi

	return $RC
}

function clear_history
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'clear_history' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "clear_history - Clearing PSU $PSU history..."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x80 $PSUAddress 0x00 0x01 0x00 0xe7"
	send_IPMICmd "$Cmd" Response
	RC=$?

	return $RC
}

function pfc_disable
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local PFCDis
	local InpBV
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'pfc_disable' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local -i bitfield

		if [[ $# -lt 1 ]] ; then
			echo "Call made to function 'pfc_disable' with insufficient number of parameters $#."
			exit
		fi

		InpBV=$3
		PFCDis=$4

		if [ "$Verbose" = "1" ]; then
			echo
			echo "pfc_disable - Writing PSU $PSU PFC disable control to '$PFCDis' and the Input Bulk Voltage to '$InpBV'."
		fi

		if [ "$InpBV" = "fixed" ]; then
			bitfield=8
		elif [ "$InpBV" = "dynamic" ]; then
			bitfield=0
		else
			(( RC = 2 ))
			echo "Invalid setting requested for Fixed Input Bulk Voltage"
		fi

		if [ "$PFCDis" = "activate" ]; then
			(( bitfield = $bitfield | 2 ))
		elif [ "$PFCDis" != "deactivate" ]; then
			echo "Invalid setting requested for FPC Disablement"
			(( RC = 2 ))
		fi

		Byte=$(printf '%x\n' $bitfield)

		if [[ $RC -eq 0 ]]; then

			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0xe8 0x0$Byte"
			send_IPMICmd "$Cmd" Response
			RC=$?
		fi
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "pfc_disable - Reading PSU $PSU PFC disable settings."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xe8"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Returned '${bin:0:4} ${bin:4:4}'b"
			echo

			if [ "${bin:0:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 7 is undefined and is asserted in response."
			fi
			if [ "${bin:1:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 6 is undefined and is asserted in response."
			fi
			if [ "${bin:2:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 5 is undefined and is asserted in response."
			fi
			if [ "${bin:3:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 4 is undefined and is asserted in response."
			fi
			if [ "${bin:4:1}" = "1" ]; then
				echo "Fixed input bulk voltage."
			else
				echo "Dynamic input bulk voltage."
			fi
			if [ "${bin:5:1}" = "1" ]; then
				echo "Error: Bit 2 is undefined and is asserted in response."
			fi
			if [ "${bin:6:1}" = "1" ];  then
				echo "PFC Disable function activated."
			else
				echo "PFC Disable function deactivated."
			fi
			if [ "${bin:7:1}" = "1" ]; then
				echo "PFC off."
			else
				echo "PFC on."
			fi
		fi
	fi

	return $RC
}

function psu_features
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'psu_features' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "psu_features - Reading PSU $PSU features."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xeb"
	send_IPMICmd "$Cmd" Response
	RC=$?

	if [[ $RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		Byte=$(printf '%d\n' ${Response:0:4})
		bin=$(dec2bin $Byte)

		echo
		echo "Returned '${bin:0:4} ${bin:4:4}'b"
		echo

		if [ "${bin:0:1}" = "1" ]; then
			echo "Error: Bit 7 is reserved and is asserted in response."
		fi
		if [ "${bin:1:1}" = "1" ]; then
			echo "Mixed-Mode PSU."
		else
			echo "Not a Mixed-Mode PSU."
		fi
		if [ "${bin:2:1}" = "1" ]; then
			echo "High efficiency."
		else
			echo "Not high efficiency."
		fi
		if [ "${bin:3:1}" = "1" ]; then
			echo "High Accuracy Power Monitoring supported."
		else
			echo "High Accuracy Power Monitoring not supported."
		fi
		if [ "${bin:4:1}" = "1" ]; then
			echo "Fault Protection Programming supported."
		else
			echo "Fault Protection Programming not supported."
		fi
		if [ "${bin:5:1}" = "1" ]; then
			echo "PFC Disable supported."
		else
			echo "PFC Disable not supported."
		fi
		if [ "${bin:6:1}" = "1" ];  then
			echo "Rapid On supported."
		else
			echo "Rapid On not supported."
		fi
		if [ "${bin:7:1}" = "1" ]; then
			echo "Airflow direction reverse."
		else
			echo "Airflow direction forward."
		fi
	fi

	return $RC
}

function mfr_sample_set
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin

	if [[ $# -lt 1 ]] ; then
		echo "Call made to function 'mfr_sample_set' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$Verbose" = "1" ]; then
		echo
		echo "mfr_sample_set - Reading PSU $PSU Black Box sample set."
	fi

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0a $PSUAddress 0x20 0x01 0xa0 0xec"
	send_IPMICmd "$Cmd" Response
	RC=$?
	if [[ $RC -eq 0 ]]; then

		if [[ $# -eq 2 ]] ; then
			eval "$2='$Response'"
		fi

		echo "Black Box data:"
		echo "$Response"
	fi

	return $RC
}

function latch_control
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local Byte
	local bin

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'latch_control' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local IoutWarnLatch
		local bitfield

		if [[ $# -lt 3 ]] ; then
			echo "Call made to function 'latch_control' with insufficient number of parameters $#."
			exit
		fi

		IoutWarnLatch=$3

		if [ "$Verbose" = "1" ]; then
			echo
			echo "latch_control - Writing PSU $PSU latch control setting to '$IoutWarnLatch'."
		fi

		if [ "$IoutWarnLatch" = "unlatch" ]; then
			(( bitfield = 1 ))
		elif [ "$IoutWarnLatch" = "latch" ]; then
			(( bitfield = 0 ))
		else
			(( RC = 1 ))
			echo "Invalid setting requested for IOUT OC Warning Latch setting"
		fi

		Byte=$(printf '%x\n' $bitfield)

		if [[ $RC -eq 0 ]]; then

			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x84 $PSUAddress 0x00 0x02 0x00 0xed 0x0$Byte"
			send_IPMICmd "$Cmd" Response
			RC=$?
		fi
	else
		if [ "$Verbose" = "1" ]; then
			echo
			echo "latch_control - Reading PSU $PSU latch control settings."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xed"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Returned '${bin:0:4} ${bin:4:4}'b"
			echo

			if [ "${bin:7:1}" = "1" ]; then
				echo "IOUT OC Warning Unlatched."
			else
				echo "IOUT OC Warning Latched."
			fi
		fi
	fi

	return $RC
}

function psu_factory_mode
{
	local -i RC=0
	local PSU
	local Cmd
	local PSUAddress
	local Response
	local WR
	local Byte

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'psu_factory_mode' with insufficient number of parameters $#."
		exit
	fi

	PSU=$1
	WR=$2

	PSUAddress=$(GetPSUAddress $PSU)

	if [ "$WR" = "1" ]; then

		local -i bitfield
		local BBClear
		local BBSample
		local FRUImageWr
		local FactMode

		if [[ $# -lt 6 ]] ; then
			echo "Call made to function 'psu_factory_mode' with insufficient number of parameters $#."
			exit
		fi

		BBClear=$3
		BBSample=$4
		FRUImageWr=$5
		FactMode=$6

		if [ "$Verbose" = "1" ]; then
			echo
			echo "psu_factory_mode - Writing new PSU $PSU factory mode settings."
		fi

		if [ "$BBClear" = "enable" ]; then
			(( bitfield = 16 ))
		elif [ "$BBClear" = "disable" ]; then
			(( bitfield = 0 ))
		else
			(( RC = 2 ))
			echo "Invalid setting requested for Black Box Clear Permission setting."
		fi

		if [ "$BBSample" = "enable" ]; then
			(( bitfield = $bitfield | 8 ))
		elif [ "$BBSample" != "disable" ]; then
			(( RC = 2 ))
			echo "Invalid setting requested for Black Box Sample Buffering setting."
		fi

		if [ "$FRUImageWr" = "enable" ]; then
			(( bitfield = $bitfield | 4 ))
		elif [ "$FRUImageWr" != "disable" ]; then
			(( RC = 2 ))
			echo "Invalid setting requested for FRU Image Access setting."
		fi

		if [ "$FactMode" = "enable" ]; then
			(( bitfield = $bitfield | 1 ))
		elif [ "$FactMode" != "disable" ]; then
			(( RC = 2 ))
			echo "Invalid setting requested for Factory Mode setting."
		fi

		Byte=$(printf '%x\n' $bitfield)

		if [[ $RC -eq 0 ]]; then

			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x04 $PSUAddress 0x00 0x02 0x00 0xf0 0x$Byte"
			send_IPMICmd "$Cmd" Response
			RC=$?
		fi
	else
		local bin

		if [ "$Verbose" = "1" ]; then
			echo
			echo "psu_factory_mode - Reading PSU $PSU factory mode settings."
		fi

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x82 $PSUAddress 0x00 0x01 0x01 0xf0"
		send_IPMICmd "$Cmd" Response
		RC=$?

		if [[ $RC -eq 0 ]]; then

			if [[ $# -eq 3 ]] ; then
				eval "$3='$Response'"
			fi

			Byte=$(printf '%d\n' ${Response:0:4})
			bin=$(dec2bin $Byte)

			echo
			echo "Returned '${bin:0:4} ${bin:4:4}'b"
			echo

			if [ "${bin:0:1}" = "1" ]; then
				echo "FRU content has been modified. Flag shall be saved to PSU flash."
			else
				echo "FRU content is as manufactured."
			fi
			if [ "${bin:1:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 6 is reserved and is asserted in response."
			fi
			if [ "${bin:2:1}" = "1" ]; then
				(( RC = 1 ))
				echo "Error: Bit 5 is reserved and is asserted in response."
			fi
			if [ "${bin:3:1}" = "1" ]; then
				echo "Black Box CLEAR_HISTORY permission enabled."
			else
				echo "Black Box CLEAR_HISTORY permission disabled."
			fi
			if [ "${bin:4:1}" = "1" ]; then
				echo "Black Box sample buffering enabled."
			else
				echo "Black Box sample buffering disabled."
			fi
			if [ "${bin:5:1}" = "1" ];  then
				echo "FRU image write enabled."
			else
				echo "FRU image read only."
			fi
			if [ "${bin:7:1}" = "1" ]; then
				echo "Factory mode enabled."
			else
				echo "Factory mode disabled."
			fi
		fi
	fi

	return $RC
}

function MakeInts 
{
	local _FP1=$1
	local _FP2=$2
	local -i FP1DecPtIndex
	local -i FP2DecPtIndex
	local -i FP1DecPlaces
	local -i FP2DecPlaces
	local -i _FP1INT
	local -i _FP1DEC
	local -i _FP2INT
	local -i _FP2DEC
	local -i Index
	
	(( FP1DecPtIndex = $(expr index "$_FP1" ".") ))
	(( FP2DecPtIndex = $(expr index "$_FP2" ".") ))

	if [[ $FP1DecPtIndex -eq 0 ]]; then
		(( FP1DecPtIndex = ${#_FP1} + 1 ))
		(( FP1DecPlaces = 1 ))
		_FP1="${_FP1}.0"
	elif [[ $FP1DecPtIndex -eq 1 ]]; then
		(( FP1DecPtIndex = 2 ))
		(( FP1DecPlaces = ${#_FP1} - 1 ))
		_FP1="$0.{_FP1}"
	else
		(( FP1DecPlaces = ${#_FP1} - $FP1DecPtIndex ))
	fi

	if [[ $FP2DecPtIndex -eq 0 ]]; then
		(( FP2DecPtIndex = ${#_FP2} + 1))
		(( FP2DecPlaces = 1 ))
		_FP2="${_FP2}.0"
	elif [[ $FP2DecPtIndex -eq 1 ]]; then
		(( FP2DecPtIndex = 2 ))
		(( FP2DecPlaces = ${#_FP2} - 1 ))
		_FP2="$0.{_FP2}"
	else
		(( FP2DecPlaces = ${#_FP2} - $FP2DecPtIndex ))
	fi

	(( Index = 0 ))
	if [[ $FP1DecPlaces -gt $FP2DecPlaces ]]; then
		while [[ $Index -lt $(( $FP1DecPlaces - $FP2DecPlaces )) ]]; do
			_FP2="${_FP2}0"
			(( Index++ ))
		done
		(( FP2DecPlaces = $FP1DecPlaces ))
	else
		while [[ $Index -lt $(( $FP2DecPlaces - $FP1DecPlaces )) ]]; do
			_FP1="${_FP1}0"
			(( Index++ ))
		done
		(( FP1DecPlaces = $FP2DecPlaces ))
	fi

	(( _FP1INT = 10#${_FP1:0:$FP1DecPtIndex-1} ))
	(( _FP1DEC = 10#${_FP1:$FP1DecPtIndex} ))

	(( _FP2INT = 10#${_FP2:0:$FP2DecPtIndex-1} ))
	(( _FP2DEC = 10#${_FP2:$FP2DecPtIndex} ))

	(( _FP2INT = $_FP2INT * 10 ** $FP2DecPlaces + $_FP2DEC ))
	(( _FP1INT = $_FP1INT * 10 ** $FP2DecPlaces + $_FP1DEC ))

	eval "$3='$_FP1INT'"
	eval "$4='$_FP2INT'"
	
	return $FP2DecPlaces
}


function LessOrEqualTo
{
	local Actual
	local Expected
	local -i ActualINT=0
	local -i ExpectedINT=0
	local -i DecimalPlaces

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'LessOrEqualTo' with insufficient number of parameters $#."
		exit
	fi

	Actual=$1
	Expected=$2

	MakeInts $Actual $Expected  ActualINT ExpectedINT
	(( DecimalPlaces = $? ))
	
	if [[ $ActualINT -gt $ExpectedINT ]]; then
		echo "The actual value of '$Actual' > the expected maximum limit of '$Expected'"
		echo
		return 1
	else
		if [ "$Verbose" = "1" ]; then
			echo "The actual value of '$Actual' <= the expected maximum limit of '$Expected'"
		fi
		
		return 0
	fi
}

function GreaterOrEqualTo
{
	local Actual
	local Expected
	local -i ActualINT=0
	local -i ExpectedINT=0
	local -i DecimalPlaces

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'GreaterOrEqualTo' with insufficient number of parameters $#."
		exit
	fi

	Actual=$1
	Expected=$2

	MakeInts $Actual $Expected  ActualINT ExpectedINT
	(( DecimalPlaces = $? ))

	if [[ $ActualINT -lt $ExpectedINT ]]; then
		echo "The actual value of '$Actual' < the expected minimum limit of '$Expected'."
		echo
		return 1
	else
		if [ "$Verbose" = "1" ]; then
			echo "The actual value of '$Actual' >= the expected minimum limit of '$Expected'."
		fi
		
		return 0
	fi
}

function MultFP
{
	local FP1
	local FP2
	local -i FP1INT=0
	local -i FP2INT=0
	local -i FPResult
	local -i FPResultINT
	local -i FPResultDEC
	local -i DecimalPlaces
	local FPString
	local __Result=$3

	if [[ $# -lt 3 ]] ; then
		echo "Call made to function 'MultFP' with insufficient number of parameters $#."
		exit
	fi

	FP1=$1
	FP2=$2

	MakeInts $FP1 $FP2  FP1INT FP2INT
	(( DecimalPlaces = $? ))
	
	(( FPResult = $FP1INT * $FP2INT ))
	(( FPResultINT = FPResult / (10 ** (2 * DecimalPlaces)) ))
	(( FPResultDEC = FPResult % (10 ** (2 * DecimalPlaces)) ))

	FPString="$FPResultDEC"
	
	while [ ${#FPString} -lt $(( 2 * DecimalPlaces )) ]; do
		FPString="0$FPString"
	done

	FPString="$FPResultINT.$FPString"
	eval "$3='$FPString'"

	return $RC
}

function DivideFP
{
	local FP1
	local FP2
	local -i SumINT
	local -i SumDEC
	local _Sum
	local Subtract="0"
	local -i DecimalPlaces
	local -i FP1INT=0
	local -i FP2INT=0

	if [[ $# -lt 3 ]] ; then
		echo "Call made to function 'DivideFP' with insufficient number of parameters $#."
		exit
	fi

	FP1=$1
	FP2=$2

	MakeInts $FP1 $FP2  FP1INT FP2INT

	(( SumINT = (($FP1INT * 10**3) / $FP2INT) / (10**3) ))
	(( SumDEC = (($FP1INT - ($SumINT * $FP2INT)) * 10**4) / $FP2INT + 5 ))

	FPString="$SumDEC"
	
	while [ ${#FPString} -lt 4 ]; do
		FPString="0$FPString"
	done

	_Sum="${SumINT}.${FPString:0:3}"
	eval "$3='$_Sum'"
	return 0
}

function AddFP
{
	local FP1
	local FP2
	local -i SumINT
	local -i SumDEC
	local _Sum
	local Subtract="0"
	local -i DecimalPlaces
	local -i FP1INT=0
	local -i FP2INT=0

	if [[ $# -lt 3 ]] ; then
		echo "Call made to function 'AddFP' with insufficient number of parameters $#."
		exit
	fi

	FP1=$1
	FP2=$2
	
	if [ "${FP2:0:1}" = "-" ]; then
		Subtract="1"
		FP2="${FP2:1}"
	fi

	MakeInts $FP1 $FP2  FP1INT FP2INT
	(( DecimalPlaces = $? ))
	
	if [ "$Subtract" = "1" ]; then
		(( SumINT = ($FP1INT - $FP2INT) / 10 ** $DecimalPlaces ))
		(( SumDEC = ($FP1INT - $FP2INT) % 10 ** $DecimalPlaces ))
	else
		(( SumINT = ($FP1INT + $FP2INT) / 10 ** $DecimalPlaces ))
		(( SumDEC = ($FP1INT + $FP2INT) % 10 ** $DecimalPlaces ))
	fi

	FPString="$SumDEC"
	
	while [[ ${#FPString} -lt $DecimalPlaces ]]; do
		FPString="0$FPString"
	done

	FPString="$SumINT.$FPString"
	eval "$3='$FPString'"

	return 0
}

function CheckFP
{
	local _Actual
	local _Expected
	local _Tolerance
	local Sum="Sum"
	local -i RC=0
	local SaveVerbose
	
	if [[ $# -lt 3 ]] ; then
		echo "Call made to function 'CheckFP' with insufficient number of parameters $#."
		exit
	fi

	_Actual=$1
	_Expected=$2
	_Tolerance=$3

	AddFP $_Expected $_Tolerance Sum
	
	SaveVerbose=$Verbose
	Verbose="0"
	LessOrEqualTo $_Actual $Sum
	if [[ $? -ne 0 ]]; then
		(( RC = 1 ))
		echo "The value '$_Actual' is greater than the expected bounds of '$_Expected +/- $_Tolerance'."
	else
		_Tolerance="-${_Tolerance}"
		AddFP $_Expected $_Tolerance Sum
		
		GreaterOrEqualTo $_Actual $Sum
		if [[ $? -ne 0 ]]; then
			(( RC = 2 ))
			echo "The value '$_Actual' is less than the expected bounds of '$_Expected +/- $_Tolerance'."
		elif [ "$SaveVerbose" = "1" ]; then
			echo "The value '$_Actual' is within the expected bounds of '$_Expected +/- $_Tolerance'."
		fi
	fi
	
	Verbose=$SaveVerbose

	return $RC
}

function CheckString()
{
	local Actual
	local Expected
	local -i RC=0

	if [[ $# -lt 2 ]] ; then
		echo "Call made to function 'CheckString' with insufficient number of parameters $#."
		exit
	fi

	Actual=$1
	Expected=$2

	if [ "$Actual" != "$Expected" ]; then
		(( RC = 1 ))
		echo
		echo "Actual value does not match expected value:"
		echo "Expected Value = '$Expected'."
		echo "Actual Value   = '$Actual'."
		echo
	fi

	return $RC
}

function CheckQueryCmd
{
	local Actual=$1
	local Expect=$2
	local Mandatory=$3
	
	if [ "$Actual" != "$Expect" ] && [ "$Mandatory" = "1" ]; then
	
		echo
		echo "'query' command support is mandatory for command, and data returned '$Actual' does not match expected '$Expect'."
		
		return 1
	elif [ "$Actual" != "0x00" ] && [ "$Actual" != "$Expect" ] && [ "$Mandatory" = "0" ]; then
	
		echo
		echo "'query' command support is optional for command, and data returned '$Actual' does not match expected '$Expect' nor '0x00'."
		
		return 2
	fi
	
	return 0
}

function WaitForSeconds
{
	local -i _Timer=0
	local -i _TargetTime=$1
	local _CurrentTime
	local _StartTime
	local _DateCmd="date +%s"
	local Quiet="0"
	
	
	
	if [[ $# -gt 1 ]] ; then
		Quiet=$2
	fi
	
	_StartTime=$($DateCmd | tail -n 1)

	while [[ $_Timer -lt $_TargetTime ]]; do
		_DateCmd="date +%s"
		_CurrentTime=$($_DateCmd | tail -n 1)
		if [[ $_Timer -ne $(( $_CurrentTime - $_StartTime )) ]]; then
			(( _Timer = $_CurrentTime - $_StartTime ))
			if { [[ $(( $_Timer % 5 )) -eq 0 ]] || [[ $(( $_TargetTime - $_Timer )) -lt 5 ]]; } && [ "$Quiet" != "1" ]; then
				echo "Timer = $_Timer seconds out of $_TargetTime"
			fi
		fi
	done
}

function VerifyTripLatency
{
	local _PSU=$1
	local _Latency=$2
	local _DateCmd
	local _StartTime
	local _TargetTime
	local _TimeToGo
	local _CurrentTime
	local _RC=0
	local -i _Timer=0
	local _ActualValue="_ActualValue"
	local _Pout="_Pout"
	local -i _exitLoop=0
	local _OtherPSU
	
	if [ "$_PSU" = "1" ]; then
		_OtherPSU="2"
	else
		_OtherPSU="1"
	fi
	
	mfr_trip_latency $_OtherPSU "1" $_Latency
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_trip_latency $_OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else
		CheckFP "$ActualValue" $_Latency "0"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi
	
	mfr_trip_latency $_PSU "1" $_Latency
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_trip_latency $_PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else
		CheckFP "$ActualValue" $_Latency "0"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi
	
	mfr_sleep_trip $_OtherPSU "1" "0"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_sleep_trip $_OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else	
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi

	mfr_wake_trip $_OtherPSU "1" "0"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_wake_trip $_OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else	
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi

	mfr_sleep_trip $_PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_sleep_trip $_PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else	
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi

	mfr_wake_trip $_PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_wake_trip $_PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else	
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi

	mfr_rapidon_cntrl $_PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else		
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi

	mfr_wake_trip $_OtherPSU "1" "100"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_wake_trip $_OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else	
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi

	mfr_wake_trip $_PSU "1" "100"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_wake_trip $_PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else	
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi

	mfr_sleep_trip $_OtherPSU "1" "100"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	mfr_sleep_trip $_OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	else	
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Comparison Error ++++++++++"
			return $?
		fi
	fi

	mfr_sleep_trip $_PSU "1" "100"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return $?
	fi

	_DateCmd="date +%s"
	_StartTime=$($_DateCmd | tail -n 1)

	(( _TargetTime = $_Latency + 10 ))
	
	echo
	echo "Verifying Trip Latency..."
	echo "$_Latency seconds to go."
	echo

	while [[ $_exitLoop -eq 0 ]] && [[ $_Timer -lt $_TargetTime ]] && [[ $_RC -eq 0 ]]; do
		
		_DateCmd="date +%s"
		_CurrentTime=$($_DateCmd | tail -n 1)
		
		if [[ $_Timer -ne $(( $_CurrentTime - $_StartTime )) ]]; then
		
			(( _Timer = $_CurrentTime - $_StartTime ))
			(( _TimeToGo = $_Latency - $_Timer ))
		
			if { [[ $_TimeToGo -ge 30 ]] && [[ $(( $_Timer % 30 )) -eq 0 ]]; } || { [[ $_TimeToGo -lt 30 ]] && [[ $_TimeToGo -ge 10 ]] && [[ $(( $_Timer % 10 )) -eq 0 ]]; } || { [[ $_TimeToGo -lt 10 ]] && [[ $_TimeToGo -ge 5 ]] && [[ $(( $_Timer % 5 )) -eq 0 ]]; } || [[ $_TimeToGo -lt 5 ]]; then

				mfr_rapidon_cntrl $_PSU "0" _ActualValue
				_RC=$?
				if [[ $_RC -ne 0 ]]; then
					echo "     ++++++++++ Transaction Error ++++++++++"
				else	
					echo "Timer = $_Timer seconds out of $_Latency"
					CheckString "$_ActualValue" "0x01"
					_exitLoop=$?
					if [[ $_exitLoop -eq 0 ]]; then
						if [[ $_TimeToGo -ge 5 ]]; then
							read_pout $_PSU _Pout
							_RC=$?
							if [[ $_RC -ne 0 ]]; then
								echo "     ++++++++++ Transaction Error ++++++++++"
							else	
								GreaterOrEqualTo "$_Pout" "0.01"
								_exitLoop=$?
								if [[ $_exitLoop -eq 0 ]]; then
									read_pin $_PSU _Pout
									_RC=$?
									if [[ $_RC -ne 0 ]]; then
										echo "     ++++++++++ Transaction Error ++++++++++"
									else	
										GreaterOrEqualTo "$_Pout" "5.01"
										_exitLoop=$?
									fi
								fi
							fi
						fi
					fi				
					_DateCmd="date +%s"
					_CurrentTime=$($_DateCmd | tail -n 1)
					(( _Timer = $_CurrentTime - $_StartTime ))
					(( _TimeToGo = $_Latency - ($_CurrentTime - $_StartTime) ))
					if [[ $_TimeToGo -lt 0 ]]; then
						(( _TimeToGo = 0 ))
					fi
					echo
					echo "$_TimeToGo seconds to go."
				fi
			fi
		fi
		if [[ $_RC -ne 0 ]]; then
			_exitLoop=$_RC
		fi
	done
	

	mfr_rapidon_cntrl $_PSU "0" _ActualValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		_RC=1
	fi
	if [[ $_Timer -ge $_TargetTime ]]; then
		echo
		echo "PSU $_PSU did not sleep within $_TargetTime seconds."
		echo "+++++++++ Compare Error ++++++++++"
		_RC=1
	else
		echo "Timer = $_Timer seconds out of $_Latency"
		CheckString "$_ActualValue" "0x05"
		if [[ $? -ne 0 ]]; then
			echo
			echo "PSU $_PSU did not sleep within $_TargetTime seconds."
			echo "+++++++++ Compare Error ++++++++++"
			_RC=1
		fi
	fi

	read_pout $_PSU _Power
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		_RC=1
	else
		LessOrEqualTo "$_Power" "0.0"
		if [[ $? -ne 0 ]]; then
			echo "PSU $_PSU output power = $_Power W, which is > 0 W."
			echo "+++++++++ Compare Error ++++++++++"
			_RC=1
		fi
	fi
	read_pin $_PSU _Power
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		_RC=1
	else	
		LessOrEqualTo "$_Power" "5.0"
		if [[ $? -ne 0 ]]; then
			echo
			echo "PSU $_PSU input power = $_Power W, which is > 5 W."
			echo "+++++++++ Compare Error ++++++++++"
			_RC=1
		fi
	fi

	return $_RC
}

function WaitForFan
{
	local ActualValue="ActualValue"
	local ExpectedValue="ExpectedValue"
	
	read_fan_speed_1 $PSU ExpectedValue
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
		return 1
	fi
	
	while [ "$ExpectedValue" != "$ActualValue" ]; do
		WaitForSeconds 5
	
		ExpectedValue=$ActualValue
		
		read_fan_speed_1 $PSU ActualValue
		if [[ $? -ne 0 ]]; then
			echo "     ++++++++++ Transaction Error ++++++++++"
			return 1
		fi
	done
	
	return 0
}

function RunTestScript()
{
	local PSU=$1
	local Limit="Limit"
	local AvgWnd="AvgWnd"
	local AssnThr="AssnThr"
	local OCW="OCW"
	local RapidOn="RapidOn"
	local Trip="Trip"
	local InpBV="InpBV"
	local PFCDis="PFCDis"
	local IoutWarnLatch="latch"
	local BBClear="enable"
	local BBSample="enable"
	local FRUImageWr="enable"
	local FactMode="enable"
	local MemAddr="0xff80"
	local -i Ymax=32767
	local Result1="Result1"
	local Result2="Result2"
	local Result3="Result3"
	local Result4="Result4"
	local Result5="Result5"
	local Result6="Result6"
	local Result7="Result7"
	local Result8="Result8"
	local Result9="Result9"
	local Result10="Result10"
	local Result11="Result11"
	local Result12="Result12"
	local Result13="Result13"
	local Result14="Result14"
	local -i Failed=0
	local Save=""
	local ExpectedValue="ExpectedValue"
	local ActualValue="ActualValue"
	local DeassertionDiff="DeassertionDiff"
	local AssnThrLL="AssnThrLL"
	local AssnThrUL="AssnThrUL"
	local AvgWndLL="1"
	local AvgWndUL="250"
	local EnergyCountIn="EnergyCountIn"
	local RolloverCountIn="RolloverCountIn"
	local SampleCountIn="SampleCountIn"
	local EnergyCountInLast="EnergyCountInLast"
	local RolloverCountInLast="RolloverCountInLast"
	local SampleCountInLast="SampleCountInLast"
	local TotalEnergyCountOutLast
	local TotalEnergyCountOut
	local InputVoltageType="InputVoltageType"
	local EnergyCountOut="EnergyCountOut"
	local RolloverCountOut="RolloverCountOut"
	local SampleCountOut="SampleCountOut"
	local EnergyCountOutLast="EnergyCountOutLast"
	local RolloverCountOutLast="RolloverCountOutLast"
	local SampleCountOutLast="SampleCountOutLast"
	local -i Timer
	local -i TargetTime
	local -i StartTime
	local -i CurrentTime
	local -i ScriptStartTime
	local -i ScriptTime
	local -i TimeToGo
	local ExpectedState="0x01"
	local Latency="0"
	local OtherPSU="0"
	local DellPartNumber="DellPartNumber"
	local -i Effic
	local DateCmd
	local SavedMask="SavedMask"
	local FanSpeed="FanSpeed"
	local Pout="Pout"
	local Tolerance="Tolerance"
	local _SaveVerbose
	local SaveShow
	local SaveSuppErr
	local Iout_max_calc="Iout_max_calc"

	if [ "$PSU" = "1" ]; then
		OtherPSU="2"
	else
		OtherPSU="1"
	fi
	
	DateCmd="date +%s"
	ScriptStartTime=$($DateCmd | tail -n 1)

	echo "***** Clearing all faults *****"

	_SaveVerbose=$Verbose
	Verbose="0"
	SaveShow=$Show
	Show="0"
	SaveSuppErr=$SuppErr
	SuppErr="1"
	
# Disable PSU monitoring
IPMICmd 20 2e 00 f3 57 01 00 00 b0 48
IPMICmd 20 2e 00 f3 57 01 00 01 b0 4a

	page $PSU "1" "1"	# Write page

	clear_faults $PSU

	page $PSU "1" "0"	# Write page

	clear_faults $PSU

	page $OtherPSU "1" "1"	# Write page

	clear_faults $OtherPSU

	page $OtherPSU "1" "0"	# Write page

	clear_faults $OtherPSU
	
	Verbose=$_SaveVerbose
	Show=$SaveShow
	SuppErr=$SaveSuppErr

	
#### Test page command

echo "***** Beginning validation *****"

	page $PSU "1" "1"	# Write page
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	ExpectedValue="0x01"
	page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page $PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	ExpectedValue="0x00"
	page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	clear_faults $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	coefficients $PSU "read_ein" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x05 0x01 0x00 0x00 0x00 0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	coefficients $PSU "read_eout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x05 0x01 0x00 0x00 0x00 0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	read_ein $PSU EnergyCountInLast RolloverCountInLast SampleCountInLast
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		(( TotalEnergyCountInLast = $RolloverCountInLast * $Ymax + $EnergyCountInLast ))
		echo "Energy In Count = $TotalEnergyCountInLast"
		echo
	fi

	read_eout $PSU EnergyCountOutLast RolloverCountOutLast SampleCountOutLast
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		(( TotalEnergyCountOutLast = $RolloverCountOutLast * $Ymax + $EnergyCountOutLast ))
		echo "Energy Out Count = $TotalEnergyCountOutLast"
	fi
	
	mfr_model $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_revision $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_id $PSU DellPartNumber
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	if [ "${DellPartNumber:0:1}" = "0" ]; then
		DellPartNumber="${DellPartNumber:1:5}"
	else
		DellPartNumber="${DellPartNumber:0:5}"
	fi
	
	SetPSUParameters $DellPartNumber

	mfr_location $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_date $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_serial $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	bootloader_version $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi
	
	fw_version $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	firmware_update_capability $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi
	
	firmware_update_status_flag $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	read_fru_data $PSU $DellPartNumber
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	capability $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x90"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "0" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "vout" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "vout" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "1" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "vout" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "vout" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "0" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "input" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "input" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "1" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xef"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "input" "0x10"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x10"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "input" "0xef"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xef"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "0" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "temp" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "temp" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "1" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xbf"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "temp" "0x40"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x40"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "temp" "0xbf"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xbf"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "0" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "iout" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "iout" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "1" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xdf"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "iout" "0x20"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x20"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "iout" "0xdf"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xdf"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "0" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "cml" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "cml" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "1" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "cml" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "cml" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "0" "fans_1_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "fans_1_2" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "fans_1_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "1" "fans_1_2" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "1" "fans_1_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "0" "0" "other" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "other" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "other" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	smbalert_mask $PSU "1" "0" "other" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	smbalert_mask $PSU "0" "0" "other" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	vout_ov_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Vout_OV_Limit "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	AddFP $Vout_OV_Limit "-0.74" ExpectedValue
	vout_ov_fault_limit $PSU "1" $ExpectedValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	MultFP $Vout_OV_Limit "0.02" Tolerance
	vout_ov_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	AddFP $Vout_OV_Limit "0.74" ExpectedValue
	vout_ov_fault_limit $PSU "1" $ExpectedValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	vout_ov_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	vout_ov_fault_limit $PSU "1" $Vout_OV_Limit
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	vout_ov_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Vout_OV_Limit $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	vout_uv_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Vout_UV_Limit "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Vout_UV_Limit "0.02" Tolerance
	AddFP $Vout_UV_Limit "0.24" ExpectedValue
	vout_uv_fault_limit $PSU "1" $ExpectedValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	vout_uv_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	AddFP $Vout_UV_Limit "-0.24" ExpectedValue
	vout_uv_fault_limit $PSU "1" $ExpectedValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	vout_uv_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	vout_uv_fault_limit $PSU "1" $Vout_UV_Limit
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	vout_uv_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Vout_UV_Limit $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi	

	line_status $PSU InputVoltageType
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		if [ "$InputVoltageType" = "Low line, 50Hz, AC Present." ]; then
			ExpectedValue="115"
			Tolerance="25"
			Pout_max=$Pout_max_ll
			Pin_max=$Pin_max_ll
			Iin_max=$Iin_max_ll
		elif [ "$InputVoltageType" = "No AC input." ]; then
			echo "Input Line Voltage is not present???"
			echo "Error occurred."
			(( Failed++ ))
			ExpectedValue="0"
			Tolerance="0"
		elif [ "$InputVoltageType" = "High line, 50Hz, AC Present." ]; then
			ExpectedValue="202"
			Tolerance="62"
		elif [ "$InputVoltageType" = "No DC input." ]; then
			echo "Input Line Voltage is not present???"
			echo "Error occurred."
			(( Failed++ ))
			ExpectedValue="0"
			Tolerance="0"
		elif [ "$InputVoltageType" = "Low line, 60Hz, AC Present." ]; then
			ExpectedValue="115"
			Tolerance="25"
			Pout_max=$Pout_max_ll
			Pin_max=$Pin_max_ll
			Iin_max=$Iin_max_ll
		elif [ "$InputVoltageType" = "Error: value $Response is reserved." ]; then
			echo "Undefined Input Voltage Type."
			echo "Exiting test."
			(( Failed++ ))
			exit
		elif [ "$InputVoltageType" = "High line, 60Hz, AC Present." ]; then
			ExpectedValue="202"
			Tolerance="62"
		elif [ "$InputVoltageType" = "Input is DC." ]; then
			ExpectedValue="202"
			Tolerance="62"
		else
			echo "Undefined Input Voltage Type."
			echo "Exiting test."
			(( Failed++ ))
			exit
		fi
	fi

	read_vin $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	if [ "$ExpectedValue" = "115" ]; then
	
		mfr_efficiency_ll $PSU Result1 Result2 Result3 Result4 Result5 Result6 Result7
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Transaction Error ++++++++++"
		else
			CheckFP $Result1 $Efficiency_ll_Voltage "0"
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			MultFP $Pout_max "0.20" ExpectedValue
			CheckFP $Result2 $ExpectedValue "0.5"
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result3 $Efficiency_ll_20
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			MultFP $Pout_max "0.50" ExpectedValue
			CheckFP $Result4 $ExpectedValue "0"
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result5 $Efficiency_ll_50
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			CheckFP $Result6 $Pout_max "1"
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result7 $Efficiency_ll_100
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
		fi
	else

		mfr_efficiency_hl $PSU Result1 Result2 Result3 Result4 Result5 Result6 Result7
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Transaction Error ++++++++++"
		else
			CheckFP $Result1 $Efficiency_hl_Voltage "0"
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			MultFP $Pout_max "0.20" ExpectedValue
			CheckFP $Result2 $ExpectedValue "0.5"
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result3 $Efficiency_hl_20
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			MultFP $Pout_max "0.50" ExpectedValue
			CheckFP $Result4 $ExpectedValue "1"
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result5 $Efficiency_hl_50
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			CheckFP $Result6 $Pout_max "1"
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result7 $Efficiency_hl_100
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
		fi
	fi
	
	tot_mfr_pout_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Pout_max "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	pin_op_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Pin_max "0.02" Tolerance
		CheckFP	$ActualValue $Pin_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Pin_max "0.25" ExpectedValue
	MultFP $ExpectedValue "0.02" Tolerance
	pin_op_warn_limit $PSU "1" $ExpectedValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	pin_op_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	pin_op_warn_limit $PSU "1" $Pin_max
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	MultFP $Pin_max "0.02" Tolerance
	pin_op_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Pin_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	DivideFP $Pout_max "12.2" Iout_max_calc
	MultFP $Iout_max_calc "0.02" Tolerance
	MultFP $Iout_max_calc "0.25" AssnThrLL
	MultFP $Iout_max_calc "1.2" AssnThrUL
	AvgWndLL="1"
	AvgWndUL="250"

	ocw_setting_range $PSU "1" AvgWndUL AvgWndLL AssnThrUL AssnThrLL
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Iout_max_calc "1.2" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$AssnThrUL $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		MultFP $Iout_max_calc "0.25" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$AssnThrLL $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$AvgWndLL "1" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$AvgWndUL "250" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	iout_oc_fault_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi
	
	iout_oc_fault_limit $PSU "1" $ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	iout_oc_fault_limit $PSU "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_iin_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Iin_max "0.02" Tolerance
		CheckFP	$ActualValue $Iin_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi


	iin_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Iin_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Iin_max "0.5" ExpectedValue
	MultFP $ExpectedValue "0.02" Tolerance
	iin_oc_warn_limit $PSU "1" $ExpectedValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	iin_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Iin_max "0.02" Tolerance
	iin_oc_warn_limit $PSU "1" $Iin_max
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	iin_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Iin_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_byte $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_word $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00 0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_vout $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_iout $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_input $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_temperature $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_cml $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_other $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_fans_1_2 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "byte" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "byte" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "word" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00 0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "word" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00 0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "ocw" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "ocw" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_write $PSU "0x00" "vout" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x01" "vout" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x00" "iout" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x01" "iout" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x00" "input" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x01" "input" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x00" "temp" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x01" "temp" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x00" "cml" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x01" "cml" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x00" "ocw" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page_plus_write $PSU "0x01" "ocw" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	status_vout $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	status_iout $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	status_input $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	status_temperature $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	status_cml $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	status_other $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	status_fans_1_2 $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	status_byte $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_word $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00 0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_vout $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_iout $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_input $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_temperature $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_cml $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_other $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	status_fans_1_2 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "byte" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "byte" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "word" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00 0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "word" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00 0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "temp" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x00" "ocw" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page_plus_read $PSU "0x01" "ocw" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	read_iin $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	read_vout $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	read_iout $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	read_temperature_1 $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	read_temperature_2 $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	read_temperature_3 $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	read_pout $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	read_pin $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	pmbus_revision $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		
		CheckString "$ActualValue" "0x22"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	app_profile_support $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString $ActualValue "0x04"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_vin_min $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Vin_min "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_vin_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Vin_max "0.02" Tolerance
		CheckFP	$ActualValue $Vin_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_iin_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Iin_max "0.02" Tolerance
		CheckFP	$ActualValue $Iin_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_pin_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Pin_max "0.02" Tolerance
		CheckFP	$ActualValue $Pin_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_vout_min $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Vout_min "0.02" Tolerance
		CheckFP	$ActualValue $Vout_min $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_vout_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Vout_max "0.02" Tolerance
		CheckFP	$ActualValue $Vout_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_iout_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Iout_max "0.02" Tolerance
		CheckFP	$ActualValue $Iout_max $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_pout_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Wattage "0.02" Tolerance
		CheckFP	$ActualValue $Wattage $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_tambient_max $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		GreaterOrEqualTo $ActualValue $Tambient_max
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_tambient_min $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		LessOrEqualTo "$ActualValue" $Tambient_min
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_efficiency_data $PSU Result1 Result2 Result3 Result4 Result5 Result6 Result7 Result8 Result9 Result10 Result11 Result12  Result13
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		LessOrEqualTo $Result2 "5.0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
		if [ "$Result1" = "0x10" ]; then  # low-line input
			GreaterOrEqualTo $Result4 $Efficiency_ll_10
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result5 $Efficiency_ll_20
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result8 $Efficiency_ll_50
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result13 $Efficiency_ll_100
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
		elif [ "$Result1" = "0x20" ]; then
			GreaterOrEqualTo $Result4 $Efficiency_hl_10
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result5 $Efficiency_hl_20
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result8 $Efficiency_hl_50
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
			GreaterOrEqualTo $Result13 $Efficiency_hl_100
			if [[ $? -ne 0 ]]; then
				(( Failed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			fi
		else
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
			echo "Unexpected value for Byte 1 Efficiency Data."
		fi
	fi

	mfr_max_temp_1 $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_max_temp_2 $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_device_code $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	isp_key $PSU "dell"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	isp_status_cmd $PSU "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

#	isp_memory_addr $PSU "0"
#	if [[ $? -ne 0 ]]; then
#		(( Failed++ ))
#		echo "     ++++++++++ Transaction Error ++++++++++"
#	fi

#	isp_memory $PSU
#	if [[ $? -ne 0 ]]; then
#		(( Failed++ ))
#		echo "     ++++++++++ Transaction Error ++++++++++"
#	fi

	system_led_cntl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	system_led_cntl $PSU "1" "green" "blink"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	system_led_cntl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x02"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	system_led_cntl $PSU "1" "amber" "blink"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	system_led_cntl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x03"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	system_led_cntl $PSU "1" "green" "solid"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	system_led_cntl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x04"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	system_led_cntl $PSU "1" "amber" "solid"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	system_led_cntl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x05"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	system_led_cntl $PSU "1" "green" "off"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	system_led_cntl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Iout_max_calc "1.025" ExpectedValue
#	ExpectedValue=$Iout_max_calc 
	MultFP $ExpectedValue "0.02" Tolerance
	ocw_setting_read $PSU "1" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 "200" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		MultFP $Iout_max "0.05" DeassertionDiff
		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	iout_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Result1 $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	iout_oc_warn_limit $PSU "1" $AssnThrLL
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	MultFP $AssnThrLL "0.02" Tolerance
	iout_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $AssnThrLL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_setting_read $PSU "1" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $AssnThrLL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 "200" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Iout_max_calc "1.025" ExpectedValue
	MultFP $ExpectedValue "0.02" Tolerance
	iout_oc_warn_limit $PSU "1" $ExpectedValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	iout_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_setting_read $PSU "1" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 "200" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $AssnThrLL "0.02" Tolerance
	ocw_setting_write $PSU "1" $AssnThrLL $AvgWndLL
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	ocw_setting_read $PSU "1" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $AssnThrLL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 $AvgWndLL "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $AssnThrLL "0.02" Tolerance
	iout_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $AssnThrLL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $AssnThrUL "0.02" Tolerance
	ocw_setting_write $PSU "1" $AssnThrUL "50"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	ocw_setting_read $PSU "1" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $AssnThrUL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 "50" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $AssnThrUL "0.02" Tolerance
	iout_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $AssnThrUL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Iout_max_calc "1.025" ExpectedValue
#	ExpectedValue=$Iout_max_calc 
	MultFP $ExpectedValue "0.02" Tolerance
	ocw_setting_write $PSU "1" $ExpectedValue $AvgWndUL
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	ocw_setting_read $PSU "1" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 $AvgWndUL "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Iout_max_calc "1.025" ExpectedValue
	MultFP $ExpectedValue "0.02" Tolerance
	ocw_setting_write $PSU "1" $ExpectedValue "200"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	ocw_setting_read $PSU "1" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 "200" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Result1 "0.02" Tolerance
	iout_oc_warn_limit $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$ActualValue $Result1 $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_setting_range $PSU "3" AvgWndUL AvgWndLL AssnThrUL AssnThrLL
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Iout_max_calc "1.4" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$AssnThrUL $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		MultFP $Iout_max_calc "0.25" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$AssnThrLL $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$AvgWndLL "1" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$AvgWndUL "5" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $Iout_max_calc "1.4" ExpectedValue
	MultFP $ExpectedValue "0.02" Tolerance
	ocw_setting_read $PSU "3" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 "1" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $AssnThrLL "0.02" Tolerance
	ocw_setting_write $PSU "3" $AssnThrLL $AvgWndUL
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	ocw_setting_read $PSU "3" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $AssnThrLL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 $AvgWndUL "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	MultFP $AssnThrUL "0.02" Tolerance
	ocw_setting_write $PSU "3" $AssnThrUL $AvgWndLL
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	ocw_setting_read $PSU "3" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP	$Result1 $AssnThrUL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 $AvgWndLL "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_setting_range $PSU "2" AvgWndUL AvgWndLL AssnThrUL AssnThrLL
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $Iout_max_calc "1.25" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance		
		CheckFP	$AssnThrUL $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$AssnThrLL $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$AvgWndLL "5" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$AvgWndUL "5" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_setting_read $PSU "2" Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		MultFP $AssnThrUL "0.02" Tolerance		
		CheckFP	$Result1 $AssnThrUL $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		CheckFP	$Result2 $AvgWndLL "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		GreaterOrEqualTo $Result3 "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi

		AddFP $Result1 "-$DeassertionDiff" ExpectedValue
		MultFP $ExpectedValue "0.02" Tolerance
		CheckFP	$Result4 $ExpectedValue $Tolerance
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page $PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_status $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page $PSU "1" "1"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_status $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page $PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_status $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page $PSU "1" "1"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_status $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page $PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_status $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	page $PSU "1" "1"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_status $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	ocw_counter $PSU Result1 Result2 Result3 Result4
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$Result1" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
		CheckString "$Result2" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
		CheckString "$Result3" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
		CheckString "$Result4" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_page $PSU "1" "0x00"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_page $PSU "1" "0x01"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_page $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_page $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0xff"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_pos_total $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_pos_last $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	fan_config_1_2 $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x90"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	read_fan_speed_1 $PSU FanSpeed
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	fan_command_1 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	fan_command_1 $PSU "1" "100"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	fan_command_1 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	WaitForFan

	read_fan_speed_1 $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		GreaterOrEqualTo $ActualValue $FanSpeed
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo
			echo "Fan RPM has not increased at 100%."
			echo "++++++++++ Compare Error ++++++++++"
		fi
		MaxFanSpeed=$ActualValue
	fi

	status_fans_1_2 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x08"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi	
	
	fan_command_1 $PSU "1" "75"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	fan_command_1 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "75"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi
	
	WaitForFan
	
	read_fan_speed_1 $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		LessOrEqualTo $ActualValue $MaxFanSpeed
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo
			echo "Fan RPM has not decreased from 100% to 75%."
			echo "++++++++++ Compare Error ++++++++++"
		else
			FanSpeed=$ActualValue
		fi
	fi

	fan_command_1 $PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	fan_command_1 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	WaitForFan
	
	read_fan_speed_1 $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		LessOrEqualTo $ActualValue $FanSpeed
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo
			echo "Fan RPM has not decreased from 75% to 0%."
			echo "++++++++++ Compare Error ++++++++++"
		fi
	fi

	status_fans_1_2 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x08"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi	
	
	status_fans_1_2 $PSU "1" "0xff"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi	
	
	status_fans_1_2 $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi	
	
	psu_manufacturing $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	psu_manufacturing $PSU "1" "configured"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	psu_manufacturing $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	psu_manufacturing $PSU "1" "unconfigured"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	psu_manufacturing $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_trip_latency $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "30.0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi
	
	_SaveVerbose=$Verbose
	Verbose="0"
	SaveShow=$Show
	Show="0"
	SaveSuppErr=$SuppErr
	SuppErr="1"
	
	page $OtherPSU "1" "1"

	clear_faults $OtherPSU

	page $OtherPSU "1" "0"

	clear_faults $OtherPSU
	
	Verbose=$_SaveVerbose
	Show=$SaveShow
	SuppErr=$SaveSuppErr
	
	Latency="0"
	
	mfr_trip_latency $PSU "1" $Latency
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_trip_latency $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP "$ActualValue" $Latency "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi
	
	mfr_sleep_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "20"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_sleep_trip $OtherPSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_sleep_trip $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $OtherPSU "1" "0"
	if [[ $? -ne 0 ]]; then
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_sleep_trip $PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_sleep_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $OtherPSU "1" "roa"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x03"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "1" "ats"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	WaitForSeconds 10
	
	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" $ExpectedState
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
			echo "PSU in unexpected state $ActualValue, expected $ExpectedState state."
		fi
	fi

	read_pout $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else	
		GreaterOrEqualTo "$ActualValue" "5"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo
			echo "Active PSU $PSU power out < than 5 W."
			echo "     ++++++++++ Comparison Error ++++++++++"
			echo
		fi
	fi

	read_pin $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else	
		GreaterOrEqualTo "$ActualValue" "5.01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo
			echo "Active PSU $PSU power in > than 5.01 W."
			echo "     ++++++++++ Comparison Error ++++++++++"
			echo
		fi
	fi

	mfr_rapidon_cntrl $OtherPSU "1" "normal"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "1" "normal"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "1" "roa"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x03"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "1" "normal"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_sleep_trip $OtherPSU "1" "100"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_sleep_trip $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else	
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $OtherPSU "1" "100"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else	
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_sleep_trip $PSU "1" "100"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_sleep_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else	
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $PSU "1" "100"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else	
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $OtherPSU "1" "roa"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x03"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "1" "ats"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	VerifyTripLatency $PSU $Latency 
	if [[ $? -ne 0 ]]; then
		echo
		echo "Trip Latency verification failed."
		echo "++++++++++ Compare Error ++++++++++"
		(( Failed++ ))
	fi
	
	Latency="10"
	
	VerifyTripLatency $PSU $Latency 
	if [[ $? -ne 0 ]]; then
		echo
		echo "Trip Latency verification failed."
		echo "++++++++++ Compare Error ++++++++++"
		(( Failed++ ))
	fi

	Latency="255"
	
	VerifyTripLatency $PSU $Latency 
	if [[ $? -ne 0 ]]; then
		echo
		echo "Trip Latency verification failed."
		echo "++++++++++ Compare Error ++++++++++"
		(( Failed++ ))
	fi

	Latency="30"
	
	VerifyTripLatency $PSU $Latency 
	if [[ $? -ne 0 ]]; then
		echo
		echo "Trip Latency verification failed."
		echo "++++++++++ Compare Error ++++++++++"
		(( Failed++ ))
	fi

	mfr_rapidon_cntrl $OtherPSU "1" "normal"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_sleep_trip $OtherPSU "1" "20"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_sleep_trip $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "20"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $OtherPSU "1" "50"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $OtherPSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "1" "normal"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "1" "roa"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x03"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_rapidon_cntrl $PSU "1" "normal"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_rapidon_cntrl $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else		
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_sleep_trip $PSU "1" "35"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_sleep_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "35"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_sleep_trip $PSU "1" "20"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_sleep_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "20"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $PSU "1" "25"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "25"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $PSU "1" "85"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "85"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $PSU "1" "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $PSU "1" "100"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "100"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_wake_trip $PSU "1" "50"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_wake_trip $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "50"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_trip_latency $PSU "1" "10.5"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_trip_latency $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP "$ActualValue" "10.5" "0.1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_trip_latency $PSU "1" "255"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_trip_latency $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP "$ActualValue" "255.0" "0.1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	mfr_trip_latency $PSU "1" "30"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_trip_latency $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckFP "$ActualValue" "30.0" "0.1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	psu_factory_mode $PSU "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	isp_key $PSU "fmod"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	psu_factory_mode $PSU "1" "disable" "disable" "disable" "enable"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	psu_factory_mode $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	psu_factory_mode $PSU "1" "enable" "disable" "disable" "enable"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	psu_factory_mode $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x11"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

#	clear_history $PSU
#	if [[ $? -ne 0 ]]; then
#		(( Failed++ ))
#		echo "     ++++++++++ Transaction Error ++++++++++"
#	fi
	
	psu_factory_mode $PSU "1" "disable" "disable" "disable" "disable"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	pfc_disable $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
#	else
#		CheckString "$ActualValue" "0x00"
#		if [[ $? -ne 0 ]]; then
#			(( Failed++ ))
#			echo "     ++++++++++ Comparison Error ++++++++++"
#		fi
	fi

	pfc_disable $PSU "1" "fixed" "deactivate"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	pfc_disable $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x08"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	pfc_disable $PSU "1" "fixed" "deactivate"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	pfc_disable $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x08"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	pfc_disable $PSU "1" "fixed" "activate"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	pfc_disable $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x0a"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	pfc_disable $PSU "1" "dynamic" "activate"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	pfc_disable $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x02"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	pfc_disable $PSU "1" "dynamic" "deactivate"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	pfc_disable $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	psu_features $PSU ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" $Features
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

#	mfr_sample_set $PSU
#	if [[ $? -ne 0 ]]; then
#		(( Failed++ ))
#		echo "     ++++++++++ Transaction Error ++++++++++"
#	fi

	latch_control $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	latch_control $PSU "1" "unlatch"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	latch_control $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x01"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	latch_control $PSU "1" "latch"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	latch_control $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	peak_current_record $PSU "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	peak_current_record $PSU "1"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	peak_current_record $PSU "0"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	psu_factory_mode $PSU "1" "disable" "disable" "disable" "disable"
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	psu_factory_mode $PSU "0" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckString "$ActualValue" "0x00"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "page" ActualValue 
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "query" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "clear_faults" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xdc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "page_plus_write" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xdc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "page_plus_read" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "capability" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "smbalert_mask" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "coefficients" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "fan_config_1_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "fan_command_1" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "fan_command_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0x00" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "fan_command_3" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0x00" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "fan_command_4" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0x00" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "vout_ov_fault_limit" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "vout_uv_fault_limit" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "iout_oc_fault_limit" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "iout_oc_warn_limit" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "iin_oc_warn_limit" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "pin_op_warn_limit" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_byte" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_word" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_vout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_input" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_temperature" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_cml" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_other" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_fans_1_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "status_fans_3_4" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0x00" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_ein" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xac" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_eout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xac" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_vin" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_iout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_temperature_1" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_temperature_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_temperature_3" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_fan_speed_1" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_fan_speed_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0x00" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_fan_speed_3" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0x00" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_fan_speed_4" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0x00" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_pout" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_pin" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "pmbus_revision" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_id" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_model" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_revision" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_location" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_date" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_serial" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "app_profile_support" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xbc" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_serial" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_vin_min" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_vin_max" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_iin_max" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_pin_max" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_vout_min" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_vout_max" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_iout_max" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_pout_max" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_tambient_max" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_tambient_min" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_vout_min" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_efficiency_ll" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_efficiency_hl" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "fru_data_offset" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "read_fru_data" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_efficiency_data" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_max_temp_1" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_max_temp_2" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "1"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_device_code" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "isp_key" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xd8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "isp_status_cmd" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xf8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "isp_memory_addr" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xf8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "isp_memory" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xf8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "fw_version" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "system_led_cntl" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xf8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "line_status" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "tot_mfr_pout_max" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "ocw_setting_write" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xc0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "ocw_setting_read" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "ocw_status" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "ocw_counter" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_rapidon_cntrl" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_sleep_trip" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_wake_trip" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_trip_latency" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xe0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_page" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xf8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_pos_total" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_pos_last" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "clear_history" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xdc" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "pfc_disable" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xf8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "psu_features" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xb8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "mfr_sample_set" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xa0" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "latch_control" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xf8" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	query $PSU "psu_factory_mode" ActualValue
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		CheckQueryCmd "$ActualValue" "0xfc" "0"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Comparison Error ++++++++++"
		fi
	fi

	read_ein $PSU EnergyCountIn RolloverCountIn SampleCountIn
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		(( TotalEnergyCountIn = $RolloverCountIn * $Ymax + $EnergyCountIn ))
		echo "Energy In Count = $TotalEnergyCountIn"
		echo
	fi

	read_eout $PSU EnergyCountOut RolloverCountOut SampleCountOut
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	else
		(( TotalEnergyCountOut = $RolloverCountOut * $Ymax + $EnergyCountOut ))
		echo "Energy Out Count = $TotalEnergyCountOut"
	fi

	if [[ $(( $RolloverCountIn - $RolloverCountInLast )) -lt 0 ]]; then
		(( RolloverCountIn = $RolloverCountIn + 256 ))
	fi

	echo 
	echo "*****************************************"
	echo
	
	(( TotalEnergyCountIn = $RolloverCountIn * $Ymax + $EnergyCountIn ))
	echo "Total Energy In Count = $TotalEnergyCountIn"
	echo

	if [[ $(( $RolloverCountOut - $RolloverCountOutLast )) -lt 0 ]]; then
		(( RolloverCountOut = $RolloverCountOut + 256 ))
	fi

	(( TotalEnergyCountOut = $RolloverCountOut * $Ymax + $EnergyCountOut ))

	echo
	echo "Total Energy Out Count = $TotalEnergyCountOut"
	echo

	if [[ $SampleCountIn -ne $SampleCountInLast ]]; then
	
		(( AveragePowerIn = (($TotalEnergyCountIn - $TotalEnergyCountInLast) * 1000) / ($SampleCountIn - $SampleCountInLast) ))

		ActualValue="$(( ($AveragePowerIn % 1000) + 5 ))"
		while [[ ${#ActualValue} -lt 3 ]]; do
		
			ActualValue="0$ActualValue"
		done
		
		echo
		echo "Average Power In during test script     = $(( AveragePowerIn / 1000 )).${ActualValue:0:2} W"

		(( AveragePowerOut = (($TotalEnergyCountOut - $TotalEnergyCountOutLast) * 1000) / ($SampleCountOut - $SampleCountOutLast) ))

		ActualValue="$(( ($AveragePowerOut % 1000) + 5))"
		while [[ ${#ActualValue} -lt 3 ]]; do
		
			ActualValue="0$ActualValue"
		done

		echo
		echo "Average Power Out during test script    = $(( $AveragePowerOut / 1000 )).${ActualValue:0:2} W"
		echo

		ActualValue="$(( ((($AveragePowerOut * 1000) % $AveragePowerIn) + 5) / 10 ))"
		while [[ ${#ActualValue} -lt 3 ]]; do
		
			ActualValue="0$ActualValue"
		done

		(( Effic = ($AveragePowerOut * 10000) / $AveragePowerIn ))
		ActualValue="$(( ($Effic % 100) + 5))"
		while [[ ${#ActualValue} -lt 2 ]]; do
		
			ActualValue="0$ActualValue"
		done

		echo
		echo "Efficiency during test script execution = $(( $Effic / 100 )).${ActualValue:0:1}%"
	fi
	
	echo
	echo "There were $Failed failures."
	echo

	DateCmd="date +%s"
	(( ScriptTime = $($DateCmd | tail -n 1 ) - $ScriptStartTime ))
	echo "Script took $(( $ScriptTime / 60 )) minutes and $(( $ScriptTime % 60 )) seconds to execute."

	exit $Failed
}

function CLST
{
	local PSU=$1
	local -i MaxInterval=$2
	local -i MaxDuration=$3
	local Limit="Limit"
	local AvgWnd="AvgWnd"
	local AssnThr="AssnThr"
	local OCW="OCW"
	local Result1="Result1"
	local Result2="Result2"
	local Result3="Result3"
	local Result4="Result4"
	local Result5="Result5"
	local Result6="Result6"
	local Result7="Result7"
	local Result8="Result8"
	local Result9="Result9"
	local Result10="Result10"
	local Result11="Result11"
	local Result12="Result12"
	local Result13="Result13"
	local Result14="Result14"
	local -i Failed=0
	local Save=""
	local ExpectedValue="ExpectedValue"
	local ActualValue="ActualValue"
	local DeassertionDiff="DeassertionDiff"
	local AssnThr="AssnThr"
	local AvgWnd="250"
	local -i Timer
	local -i TargetTime
	local -i StartTime
	local -i CurrentTime
	local -i ScriptStartTime
	local -i ScriptTime
	local -i TimeToGo
	local ExpectedState="0x01"
	local DellPartNumber="DellPartNumber"
	local DateCmd
	local SavedMask="SavedMask"
	local Pout="Pout"
	local Tolerance="Tolerance"
	local _SaveVerbose
	local SaveShow
	local SaveSuppErr
	local -i Loop=0
	local -i Missed=0
	local -i LastMissed=0
	local -i Timeouts=0
	local -i TotalSeconds=0
	local -i TotalSamples=0
	local -i AverageRecoveryTime=0
	local -i MinRecoveryTime=9999
	local -i MaxRecoveryTime=0
	local PSUAddress
	local AssnHI
	local AssnLO
	local TransformedString
	local WndHI
	local WndLO
	local Mask
	local -i Byte
	local -i LoopCount
	local SetCmd
	local ResetCmd
	local FailedCount
	local Sum
	local -i SlowRec=0
	local Imin=0
	
	if [ "$PSU" = "1" ]; then
		OtherPSU="2"
	else
		OtherPSU="1"
	fi
	
	DateCmd="date +%s"
	ScriptStartTime=$($DateCmd | tail -n 1)

	echo "***** Clearing all PSU faults *****"

	_SaveVerbose=$Verbose
	Verbose="0"
	SaveShow=$Show
	Show="0"
	SaveSuppErr=$SuppErr
	SuppErr="1"
	
	page $PSU "1" "1"	# Write page

	clear_faults $PSU

	page $PSU "1" "0"	# Write page

	clear_faults $PSU

	Verbose=$_SaveVerbose
	Show=$SaveShow
	SuppErr=$SaveSuppErr

#### Test page command

echo "***** Beginning validation *****"

	mfr_model $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_revision $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_id $PSU DellPartNumber
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	if [ "${DellPartNumber:0:1}" = "0" ]; then
		DellPartNumber="${DellPartNumber:1:5}"
	else
		DellPartNumber="${DellPartNumber:0:5}"
	fi
	
	SetPSUParameters $DellPartNumber

	fw_version $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	tot_mfr_pout_max $PSU Pout
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	(( Imax = $Pout / 12 ))
	(( Loop = 0 ))
	
	ocw_setting_range $PSU "1" AvgWndUL AvgWndLL AssnThrUL Imin
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi
	
	echo "Imin = $Imin"
	
	while [[ 1 -eq 1 ]]; do
		(( Loop = $Loop + 1 ))
		echo "Loop = $Loop"

		(( Duration = $RANDOM % $MaxDuration ))
		
		(( Interval = $RANDOM % $MaxInterval ))
		
		(( OCW1AvgWnd = $RANDOM % 249 + 1 ))
		(( OCW3AvgWnd = $RANDOM % 4 + 1 ))
		
		Sum="0.0"
		(( LoopCount = 0 ))
		(( FailedCount = 0 ))
		
		if [[ $(( $Loop % 5 )) -eq 1 ]]; then
			while [[ $LoopCount -lt 5 ]] && [[ $FailedCount -lt 3 ]]; do
				
				read_iout $PSU Limit	
				if [[ $? -ne 0 ]]; then
					(( Failed++ ))
					echo "     ++++++++++ Transaction Error ++++++++++"
					(( FailedCount++ ))
				else
					AddFP $Sum $Limit Sum
					(( LoopCount++ ))
				fi
			done

			if [[ $FailedCount -ge 3 ]]; then
				echo "Exceeded failure limit reading PSU current."
				exit
			fi
			
			DivideFP $Sum $LoopCount Limit
			
			echo
			echo "Average measured current = $Limit A"
		fi	
		
		if [[ $(( $Loop % 2 )) -eq 1 ]]; then
			OCW="1"
			(( Byte = 12 ))
			AvgWnd=$OCW1AvgWnd
			OCWMask="0x01"
		else
			OCW="3"
			(( Byte = 14 ))
			AvgWnd=$OCW3AvgWnd
			OCWMask="0x04"
		fi
		
		echo

		if [[ $(( $Loop % 4 )) -eq 3 ]] || [[ $(( $Loop % 4 )) -eq 0 ]]; then
			if [[ $(( $Loop % 8 )) -eq 7 ]] || [[ $(( $Loop % 8 )) -eq 0 ]]; then
				ActualValue=$Limit
				AddFP $Limit "0.3" ActualValue
				GreaterOrEqualTo $ActualValue $Imin
				if [[ $? -ne 0 ]]; then
				
					ActualValue="$Imin"
				fi

			else
				ActualValue=$Limit
				GreaterOrEqualTo $ActualValue $Imin
				if [[ $? -ne 0 ]]; then
				
					ActualValue="$Imin"
				fi
			fi
				
			echo "Setting OCW$OCW assertion threshold to $ActualValue and average window to $AvgWnd msec for a duration of $Duration seconds."
		else
			ActualValue=$Limit
			AddFP $Limit "0.3" ActualValue
			GreaterOrEqualTo $ActualValue $Imin
			if [[ $? -ne 0 ]]; then
			
				ActualValue="$Imin"
			fi
			echo "Setting OCW$OCW assertion threshold to $ActualValue and average window to $AvgWnd msec."
		fi
		echo
				
		AddFP $Limit "-0.5" ExpectedValue

		PSUAddress=$(GetPSUAddress $PSU)
		Mask=$(printf '%2.2x\n' "$Byte")

		TransformedString=$(EncodeLinear16 $ActualValue "2")
		AssnHI="${TransformedString:0:2}"
		AssnLO="${TransformedString:2:2}"

		TransformedString=$(EncodeLinear16 $AvgWnd "0")
		WndHI="${TransformedString:0:2}"
		WndLO="${TransformedString:2:2}"

		SetCmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x07 0x00 0xdb 0x05 0x$Mask 0x$AssnLO 0x$AssnHI 0x$WndLO 0x$WndHI"

		if [[ $(( $Loop % 2 )) -eq 1 ]]; then
			AvgWnd="250"
			ActualValue=$Imax
		else
			MultFP $Imax "1.2" ActualValue
			AvgWnd="1"
		fi
		
		TransformedString=$(EncodeLinear16 $ActualValue "2")
		AssnHI="${TransformedString:0:2}"
		AssnLO="${TransformedString:2:2}"

		TransformedString=$(EncodeLinear16 $AvgWnd "0")
		WndHI="${TransformedString:0:2}"
		WndLO="${TransformedString:2:2}"

		ResetCmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x07 0x00 0xdb 0x05 0x$Mask 0x$AssnLO 0x$AssnHI 0x$WndLO 0x$WndHI"

	#	echo "Sending      $SetCmd"
	#	echo "Then sending $ResetCmd"
		
		Resp=$($SetCmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

	#	ocw_setting_write $PSU $OCW $ActualValue $AvgWndUL
	#	if [[ $? -ne 0 ]]; then
	#		(( Failed++ ))
	#		echo "     ++++++++++ Transaction Error ++++++++++"
	#	fi

		if [[ $(( $Loop % 4 )) -eq 3 ]] || [[ $(( $Loop % 4 )) -eq 0 ]]; then
			WaitForSeconds $Duration
		fi
		
		Resp=$($ResetCmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')
		Resp=$($ResetCmd | tail -n 1 | tr '[A-W, Y-Z]' '[a-w, y-z]')

	#	ocw_setting_write $PSU $OCW $ActualValue $AvgWndUL
	#	if [[ $? -ne 0 ]]; then
	#		(( Failed++ ))
	#		echo "     ++++++++++ Transaction Error ++++++++++"
	#	fi

		page_plus_read $PSU "0x00" "word" ActualValue
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Transaction Error ++++++++++"
		else
			CheckString "$ActualValue" "0x00 0x40"
			if [[ $? -ne 0 ]]; then
				(( Missed++ ))
				echo "     ++++++++++ Comparison Error ++++++++++"
			else
				page_plus_read $PSU "0x00" "iout" ActualValue
				if [[ $? -ne 0 ]]; then
					(( Failed++ ))
					echo "     ++++++++++ Transaction Error ++++++++++"
				else
					CheckString "$ActualValue" "0x20"
					if [[ $? -ne 0 ]]; then
						(( Missed++ ))
						echo "     ++++++++++ Comparison Error ++++++++++"
					fi
				fi

				ocw_status $PSU "0" ActualValue
				if [[ $? -ne 0 ]]; then
					(( Failed++ ))
					echo "     ++++++++++ Transaction Error ++++++++++"
				else		
					CheckString "$ActualValue" $OCWMask
					if [[ $? -ne 0 ]]; then
						(( Missed++ ))
						echo "     ++++++++++ Comparison Error ++++++++++"
					fi
				fi
			fi
		fi

		ocw_status $PSU "1" "0xff"

		RC=0
		ScriptTime=0
		#while [[ $RC -eq 0 ]] && [[ $ScriptTime -lt 300 ]]; do

		DateCmd="date +%s"
		ScriptStartTime=$($DateCmd | tail -n 1)

		while [[ $RC -lt 1 ]]; do

			(( LoopCount = 0 ))
			(( FailedCount = 0 ))

			Sum="0.0"
			
			while [[ $LoopCount -lt 5 ]] && [[ $FailedCount -lt 3 ]]; do
				
				read_iout $PSU ActualValue	
				if [[ $? -ne 0 ]]; then
					(( Failed++ ))
					echo "     ++++++++++ Transaction Error ++++++++++"
					(( FailedCount++ ))
				else
					AddFP $Sum $ActualValue Sum
					(( LoopCount++ ))
				fi
			done
			
			if [[ $FailedCount -ge 3 ]]; then
				echo "Exceeded failure limit reading PSU current."
				exit
			fi
		
			DivideFP $Sum $LoopCount ActualValue
			
			echo
			echo "Expected recovery current = $ExpectedValue A"
			echo "Average measured current  = $ActualValue A"
			echo
			
			LessOrEqualTo $ActualValue $ExpectedValue

			if [[ $? -eq 1 ]]; then
				(( RC++ ))
			else
				(( RC = 0 ))
			fi
		done

		page_plus_write $PSU "0x00" "iout" "0x20"
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Transaction Error ++++++++++"
		fi

		if [[ $Missed -eq $LastMissed ]]; then
			DateCmd="date +%s"
			(( ScriptTime = $($DateCmd | tail -n 1 ) - $ScriptStartTime ))
			
			if [[ $ScriptTime -gt 600 ]]; then
			
				echo "It took Node Manager $(( $ScriptTime / 60 )) minutes and $(( $ScriptTime % 60 )) seconds to return to optimal performance."
				(( TotalSeconds = $TotalSeconds + $ScriptTime ))
				(( TotalSamples++ ))
				(( AverageRecoveryTime = $TotalSeconds / $TotalSamples )) 
				if [[ $ScriptTime -lt $MinRecoveryTime ]]; then
					(( MinRecoveryTime = $ScriptTime ))
				fi
				if [[ $ScriptTime -gt $MaxRecoveryTime ]]; then
					(( MaxRecoveryTime = $ScriptTime ))
				fi
				(( SlowRec++ ))
#exit

#				echo "Average Recovery Time = $(( $AverageRecoveryTime / 60 )) minutes and $(( $AverageRecoveryTime % 60 )) seconds."
#				echo "Minimum Recovery Time = $(( $MinRecoveryTime / 60 )) minutes and $(( $MinRecoveryTime % 60 )) seconds."
				echo "Maximum Recovery Time = $(( $MaxRecoveryTime / 60 )) minutes and $(( $MaxRecoveryTime % 60 )) seconds."
#				echo
			fi
			
			WaitForSeconds $Interval
		else
			(( LastMissed = $Missed ))
		fi
			
		echo
		echo "Failed = $Failed"
		echo "Missed = $Missed"
		echo "Timeouts = $Timeouts"
		echo "Slow recoveries = $SlowRec"
		echo

	done
}
	
function OverTemp
{
	local PSU=$1
	local -i MaxInterval=$2
	local -i MaxDuration=$3
	local OverTemp1="OverTemp1"
	local OverTemp2="OverTemp2"
	local Limit="Limit"
	local AvgWnd="AvgWnd"
	local AssnThr="AssnThr"
	local OCW="OCW"
	local Result1="Result1"
	local Result2="Result2"
	local Result3="Result3"
	local Result4="Result4"
	local Result5="Result5"
	local Result6="Result6"
	local Result7="Result7"
	local Result8="Result8"
	local Result9="Result9"
	local Result10="Result10"
	local Result11="Result11"
	local Result12="Result12"
	local Result13="Result13"
	local Result14="Result14"
	local -i Failed=0
	local Save=""
	local ExpectedValue="ExpectedValue"
	local ActualValue="ActualValue"
	local DeassertionDiff="DeassertionDiff"
	local AssnThr="AssnThr"
	local AvgWnd="250"
	local -i Timer
	local -i TargetTime
	local -i StartTime
	local -i CurrentTime
	local -i ScriptStartTime
	local -i ScriptTime
	local -i TimeToGo
	local ExpectedState="0x01"
	local DellPartNumber="DellPartNumber"
	local DateCmd
	local SavedMask="SavedMask"
	local OT1="0"
	local OT2="0"
	local Tolerance="Tolerance"
	local _SaveVerbose
	local SaveShow
	local SaveSuppErr
	local -i Loop=0
	local -i Missed=0
	local -i LastMissed=0
	local -i Timeouts=0
	local -i TotalSeconds=0
	local -i TotalSamples=0
	local -i AverageRecoveryTime=0
	local -i MinRecoveryTime=9999
	local -i MaxRecoveryTime=0
	local PSUAddress
	local AssnHI
	local AssnLO
	local TransformedString
	local WndHI
	local WndLO
	local Mask
	local -i Byte
	local -i LoopCount
	local SetCmd
	local ResetCmd
	local FailedCount
	local Sum
	local -i SlowRec=0
	
	if [ "$PSU" = "1" ]; then
		OtherPSU="2"
	else
		OtherPSU="1"
	fi
	
	DateCmd="date +%s"
	ScriptStartTime=$($DateCmd | tail -n 1)

	echo "***** Clearing all PSU faults *****"

	_SaveVerbose=$Verbose
	Verbose="0"
	SaveShow=$Show
	Show="0"
	SaveSuppErr=$SuppErr
	SuppErr="1"
	
	page $PSU "1" "1"	# Write page

	clear_faults $PSU

	page $PSU "1" "0"	# Write page

	clear_faults $PSU

	Verbose=$_SaveVerbose
	Show=$SaveShow
	SuppErr=$SaveSuppErr

#### Test page command

echo "***** Beginning validation *****"

	mfr_model $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_revision $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_id $PSU DellPartNumber
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	if [ "${DellPartNumber:0:1}" = "0" ]; then
		DellPartNumber="${DellPartNumber:1:5}"
	else
		DellPartNumber="${DellPartNumber:0:5}"
	fi
	
	SetPSUParameters $DellPartNumber

	fw_version $PSU
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_max_temp_1 $PSU OverTemp1
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	mfr_max_temp_2 $PSU OverTemp2
	if [[ $? -ne 0 ]]; then
		(( Failed++ ))
		echo "     ++++++++++ Transaction Error ++++++++++"
	fi

	(( Interval = 10 ))
	(( Loop = 0 ))
	
	while [[ 1 -eq 1 ]]; do
		(( Loop = $Loop + 1 ))
		echo "Loop = $Loop"
		echo
		echo "OT threshold 1 = $OverTemp1"
	
		read_temperature_1 $PSU ActualValue
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Transaction Error ++++++++++"
			(( FailedCount++ ))
		else
			GreaterOrEqualTo $OverTemp1 $ActualValue
			if [[ $? -ne 0 ]]; then
				OT1="1"
				echo "PSU $PSU Hotspot 1 has reached or exceeded its OT threshold."
			fi
		fi
		echo
		echo "OT threshold 2 = $OverTemp2"
		
		read_temperature_2 $PSU ActualValue
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Transaction Error ++++++++++"
			(( FailedCount++ ))
		else
			GreaterOrEqualTo $OverTemp2 $ActualValue
			if [[ $? -ne 0 ]]; then
				OT2="1"
				echo "PSU $PSU Hotspot 2 has reached or exceeded its OT threshold."
			fi
		fi
		
		page_plus_read "1" "0" "temp" Mask
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Transaction Error ++++++++++"
			(( FailedCount++ ))
		else
			if [ "$Mask" = "0x00" ]; then
				echo "PSU $PSU status_temp register is clear."
				if [ "$OT1" != "0" ] || [ "$OT1" != "0" ]; then
					echo "     ++++++++++ Error +++++++++++"
					echo " Overtemp condition occurred without page 0 status_temp update."
					echo "     ++++++++++ Error +++++++++++"
				fi
			fi
		fi
		
		page_plus_read "1" "1" "temp" Mask
		if [[ $? -ne 0 ]]; then
			(( Failed++ ))
			echo "     ++++++++++ Transaction Error ++++++++++"
			(( FailedCount++ ))
		else
			if [ "$Mask" = "0x00" ]; then
				echo "PSU $PSU status_temp register is clear."
				if [ "$OT1" != "0" ] || [ "$OT1" != "0" ]; then
					echo "     ++++++++++ Error +++++++++++"
					echo " Overtemp condition occurred without page 1 status_temp update."
					echo "     ++++++++++ Error +++++++++++"
				fi
			fi
		fi
		

		WaitForSeconds $Interval "1"

		echo
		echo "Failed = $Failed"
		echo

	done
}

CLIParse "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}"
