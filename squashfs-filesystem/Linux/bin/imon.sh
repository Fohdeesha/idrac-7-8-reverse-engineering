#!/bin/sh
# filename is imon.sh
# copy into /tmp folder
# cd /tmp
# tftp -g -r imon.sh 192.168.0.100
# chmod 777 imon.sh
# ./imon.sh
#
# craig_klein@Dell.com
# Version v1 : Initial Release under this file name
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#-------------------------------------------------------------------------------------------------

Version="1.0"
CLICmd=""
Verbose="0"
Debug="0"

ListCommands()
{
echo "
Supported commands are:
	
	config
	reset
	current
	voltage
	version
	
"
	echo
	echo "Syntax: imon <COMMAND> [OPTIONS...]"
	echo
	echo "Supported commands are listed above..."
	echo
}

Syntax()
{
	echo
	
	if [ "$CLICmd" = "config" ]; then
		if [ "$Switch" = "" ]; then
			echo "Syntax:  ./imon.sh $CLICmd -r"
			echo "              or"
			echo "         ./imon.sh $CLICmd -[e|d|m|v|b|s] <PARAMETER>"
			echo
			echo "Where:    -r : Read current IMON settings."
			echo "          -e : Enable channel, followed by channel number (1-3)."
			echo "          -d : Disable channel, followed by channel number (1-3)."
			echo "          -m : Set operating mode."
			echo "          -v : Write new sample averaging setting (0-7)."
			echo "          -b : Write new bus voltage conversion time (0-7)."
			echo "          -s : Write new shunt voltage conversion time (0-7)."
			echo
			echo "Switches can be combined, but only one channel can be enabled or disabled per instantiation."
			echo
			echo "For help with parameters, enter a switch with no parameters."
			echo
			exit
		elif [ "$Switch" = "-m" ]; then
			echo "Valid operating modes:"
			echo
			echo "      0 - Power-down."
			echo "      1 - Shunt voltage, triggered."
			echo "      2 - Bus voltage, triggered."
			echo "      3 - Shunt and bus, triggered."
			echo "      4 - Power-down."
			echo "      5 - Shunt voltage, continuous."
			echo "      6 - Bus voltage, continuous."
			echo "      7 - Shunt and bus, continuous."
			echo
			exit
		elif [ "$Switch" = "-v" ]; then
			echo "Valid channel sample averaging settings:"
			echo
			echo "      0 - Use 1 sample/average."
			echo "      1 - Use 4 samples/average."
			echo "      2 - Use 16 samples/average."
			echo "      3 - Use 64 samples/average."
			echo "      4 - Use 128 samples/average."
			echo "      5 - Use 256 samples/average."
			echo "      6 - Use 512 samples/average."
			echo "      7 - Use 1024 samples/average."
			echo
			exit
		elif [ "$Switch" = "-b" ] || [ "$Switch" = "-s" ]; then
			echo "Valid voltage conversion time settings:"
			echo
			echo "      0 - 140us"
			echo "      1 - 204us"
			echo "      2 - 332us"
			echo "      3 - 588us"
			echo "      4 - 1.1ms"
			echo "      5 - 2.116ms"
			echo "      6 - 4.156ms"
			echo "      7 - 8.244ms"
			echo
			exit
		fi
	elif [ "$CLICmd" = "current" ] || [ "$CLICmd" = "voltage" ]; then
			echo "Syntax:  ./imon.sh $CLICmd <1-3>"
			echo
			echo "Where:    The command is followed by the channel number (1-3)."
			echo
			exit
	fi

	echo
	echo "Unknown command..."
	ListCommands
	echo
	exit
}

version()
{
	echo "Version = $Version"
	exit
}
CLIParse()
{
	if [ $# -lt 1 ]; then
		Syntax
	fi

	CLICmd="$1"
	shift
	
	if [ "$CLICmd" = "version" ]; then
		version
	elif [ "$CLICmd" = "reset" ]; then
		reset
	elif [ "$CLICmd" = "config" ]; then

		Channel=""
		AvgSamples=""
		BusConvTime=""
		ShuntConvTime=""
		Mode=""
		Enable=""
		Switch=""
		
		if [ -n "$1" ]; then
			until [ -z "$1" ]
			do
				if [ "$1" = "-r" ] && [ "$Switch" = "" ]; then
					Switch="-r"
				elif [ "$1" = "-v" ] && [ "$Switch" != "-r" ]; then
					Switch="-v"
					shift
					if [ -n "$1" ]; then
						if [[ "$1" -ge "0" ]] && [[ "$1" -le "7" ]]; then
							AvgSamples="$1"
						fi
					else
						Syntax
					fi
				elif [ "$1" = "-b" ] && [ "$Switch" != "-r" ]; then
					Switch="-b"
					shift
					if [ -n "$1" ]; then
						if [[ "$1" -ge "0" ]] && [[ "$1" -le "7" ]]; then
							BusConvTime="$1"
						fi
					else
						Syntax
					fi
				elif [ "$1" = "-s" ] && [ "$Switch" != "-r" ]; then
					Switch="-s"
					shift
					if [ -n "$1" ]; then
						if [[ "$1" -ge "0" ]] && [[ "$1" -le "7" ]]; then
							ShuntConvTime="$1"
						fi
					else
						Syntax
					fi
				elif [ "$1" = "-m" ] && [ "$Switch" != "-r" ]; then
					Switch="-m"
					shift
					if [ -n "$1" ]; then
						if [[ "$1" -ge "0" ]] && [[ "$1" -le "7" ]]; then
							Mode="$1"
						fi
					else
						Syntax
					fi
				elif [ "$1" = "-d" ] && [ "$Switch" != "-r" ]; then
					Enable="0"
					Switch="-d"
					shift
					if [ -n "$1" ]; then
						if [[ "$1" -ge "1" ]] && [[ "$1" -le "3" ]]; then
							Channel="$1"
						fi
					else
						Syntax
					fi
				elif [ "$1" = "-e" ] && [ "$Switch" != "-r" ]; then
					Enable="1"
					Switch="-e"
					shift
					if [ -n "$1" ]; then
						if [[ "$1" -ge "1" ]] && [[ "$1" -le "3" ]]; then
							Channel="$1"
						fi
					else
						Syntax
					fi
				fi
				shift
			done

			if [ "$Switch" = "" ] || { [ "$Switch" != "-r" ] && [ "$Channel" = "" ] && [ "$AvgSamples" = "" ] && [ "$BusConvTime" = "" ] && [ "$ShuntConvTime" = "" ] && [ "$Mode" = "" ];} then
				Syntax
			fi
			
			config
		else
			Syntax
			exit
		fi
	elif [ "$CLICmd" = "current" ] || [ "$CLICmd" = "voltage" ]; then

		Channel=""
		
		if [ -n "$1" ]; then
			Channel="$1"
			
			if [ "$Channel" != "1" ] && [ "$Channel" != "2" ] && [ "$Channel" != "3" ]; then
				echo
				echo "Invalid channel number."
				echo
				Syntax
				exit
			fi
			
			if [ "$CLICmd" = "current" ]; then
				current
			else
				voltage
			fi
		else
			Syntax
			exit
		fi
	else
		echo
		echo "unknown command"
		echo
		Syntax
	fi
}

dec2bin()
{
    bin=""
    padding=""
    base2=(0 1)
    while [ "$Byte" -gt 0 ];	do
		bin=${base2[$(($Byte % 2))]}$bin
		Byte=$(($Byte / 2))
    done
	
	if [ ${#bin} -eq 0 ]; then
		bin="0"
	fi
		
    if [ $((8 - (${#bin} % 8))) -ne 8 ]; then
		printf -v padding '%*s' $((8 - (${#bin} % 8))) ''
		padding=${padding// /0}
    fi
	bin=$padding$bin
}

CompletionCodes()
{
	if [ "$CC" = "0x80" ]; then
		echo "Command response timeout. SMBUS device was not present."
	elif [ "$CC" = "0x81" ]; then
		echo "Command not serviced. Not able to allocate the resources for serving this command at this time. Retry needed."
	elif [ "$CC" = "0x82" ]; then
		echo "Illegal SMBUS PSU Address Command."
	elif [ "$CC" = "0xa1" ]; then
		echo "Illegal SMBUS PSU Address Target Address."
	elif [ "$CC" = "0xa2" ]; then
		echo "PEC error."
	elif [ "$CC" = "0xa3" ]; then
		echo "Illegal First Register Offset."
	elif [ "$CC" = "0xa5" ]; then
		echo "Unsupported Write Length."
	elif [ "$CC" = "0xa6" ]; then
		echo "Unexpected Data Offset field value."
	elif [ "$CC" = "0xaa" ]; then
		echo "SMBUS timeout."
	elif [ "$CC" = "0xc0" ]; then
		echo "Node Busy. Command could not be processed because command processing resources are temporarily unavailable."
	elif [ "$CC" = "0xc1" ]; then
		echo "Invalid Command."
	elif [ "$CC" = "0xc2" ]; then
		echo "Command invalid for given LUN."
	elif [ "$CC" = "0xc3" ]; then
		echo "Timeout while processing command. Response unavailable."
	elif [ "$CC" = "0xc4" ]; then
		echo "Out of space. Command could not be completed because of a lack of storage space required to execute the given command operation."
	elif [ "$CC" = "0xc5" ]; then
		echo "Reservation Canceled or Invalid Reservation ID."
	elif [ "$CC" = "0xc6" ]; then
		echo "Request data truncated."
	elif [ "$CC" = "0xc7" ]; then
		echo "Request data length invalid."
	elif [ "$CC" = "0xc8" ]; then
		echo "Request data field length limit exceeded."
	elif [ "$CC" = "0xc9" ]; then
		echo "Parameter out of range. One or more parameters in the data field of the Request are out of range."
	elif [ "$CC" = "0xca" ]; then
		echo "Cannot return number of requested data bytes."
	elif [ "$CC" = "0xcb" ]; then
		echo "Requested Sensor, data, or record not present."
	elif [ "$CC" = "0xcc" ]; then
		echo "Invalid data field in Request."
	elif [ "$CC" = "0xcd" ]; then
		echo "Command illegal for specified sensor or record type."
	elif [ "$CC" = "0xce" ]; then
		echo "Command response could not be provided."
	elif [ "$CC" = "0xcf" ]; then
		echo "Cannot execute duplicated request."
	elif [ "$CC" = "0xd0" ]; then
		echo "Command response could not be provided. SDR Repository in update mode."
	elif [ "$CC" = "0xd1" ]; then
		echo "Command response could not be provided. Device in firmware update mode."
	elif [ "$CC" = "0xd2" ]; then
		echo "Command response could not be provided. BMC initialization or initialization agent in progress."
	elif [ "$CC" = "0xd3" ]; then
		echo "Destination unavailable. Cannot deliver request to selected destination."
	elif [ "$CC" = "0xd4" ]; then
		echo "Cannot execute command due to insufficient privilege level or other security-based restriction."
	elif [ "$CC" = "0xd5" ]; then
		echo "Cannot execute command. Command, or request parameter(s), not supported in present state."
	elif [ "$CC" = "0xd6" ]; then
		echo "Cannot execute command. Parameter is illegal because command sub-function has been disabled or is unavailable."
	elif [ "$CC" = "0xff" ]; then
		echo "Unspecified error."
	else
		echo "Unknown Completion Code."
	fi
}

send_IPMICmd()
{	
	RESP=$($Cmd | tail -n 1)
	
	if [ "$Debug" = "1" ]; then
		echo "IPMI Cmd  = $Cmd"
		echo "IPMI Resp = $RESP"
	fi
	CC=${RESP:10:4}
	if [ "$CC" != "0x00" ]; then
		echo "IPMI Cmd  = $Cmd"
		echo "IPMI Resp = $RESP"
		echo
		echo "Error: Completion Code = $CC"
		ERR="1"
		CompletionCodes
	fi

	RESP=${RESP#'0xbc 0xd9 0x00 0x57 0x01 0x00 '}

	if [ "$RESP" != "" ] && [ "$Debug" = "1" ]; then
		echo
		echo "$RESP"
	fi
}

config()
{
	ERR="0"
	
	declare -i CfgInt
	declare -i HiInt
	declare -i LoInt
	declare -i Dummy

	if [ "$Switch" = "-r" ]; then
		if [ "$Verbose" = "1" ]; then
			echo ""
			echo "Reading IMON config register."
		fi
		
		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0x80 0x07 0x00 0x01 0x02 0x00"
		send_IPMICmd
		
		if [ "$ERR" = "0" ]; then
			echo "Current configuration register setting = ${RESP:0:4}${RESP:7:2}"
			Byte=$(printf '%d\n' ${RESP:0:4})
			dec2bin
			Byte1=$bin
			Byte=$(printf '%d\n' ${RESP:5:4})
			dec2bin
			Byte2=$bin
			
			if [ "$Debug" = "1" ]; then
				echo
				echo "Returned '${Byte1:0:4} ${Byte1:3:4} ${Byte2:0:4} ${Byte2:3:4}'b"
			fi
			
			echo
			if [ ${Byte1:0:1} = "1" ]; then
				ERR="1"
				echo "Reset is asserted."
			fi
			if [ ${Byte1:1:1} = "1" ]; then
				echo "Channel 1 is enabled."
			else
				echo "Channel 1 is disabled."
			fi
			if [ ${Byte1:2:1} = "1" ]; then
				echo "Channel 2 is enabled."
			else
				echo "Channel 2 is disabled."
			fi
			if [ ${Byte1:3:1} = "1" ]; then
				echo "Channel 3 is enabled."
			else
				echo "Channel 3 is disabled."
			fi
			if [ ${Byte1:4:1} = "0" ] && [ ${Byte1:5:1} = "0" ] && [ ${Byte1:6:1} = "0" ]; then
				echo "1 sample is used for each averaging."
			elif [ ${Byte1:4:1} = "0" ] && [ ${Byte1:5:1} = "0" ] && [ ${Byte1:6:1} = "1" ]; then
				echo "4 samples are used for each averaging."
			elif [ ${Byte1:4:1} = "0" ] && [ ${Byte1:5:1} = "1" ] && [ ${Byte1:6:1} = "0" ]; then
				echo "16 samples are used for each averaging."
			elif [ ${Byte1:4:1} = "0" ] && [ ${Byte1:5:1} = "1" ] && [ ${Byte1:6:1} = "1" ]; then
				echo "64 samples are used for each averaging."
			elif [ ${Byte1:4:1} = "1" ] && [ ${Byte1:5:1} = "0" ] && [ ${Byte1:6:1} = "0" ]; then
				echo "128 samples are used for each averaging."
			elif [ ${Byte1:4:1} = "1" ] && [ ${Byte1:5:1} = "0" ] && [ ${Byte1:6:1} = "1" ]; then
				echo "256 samples are used for each averaging."
			elif [ ${Byte1:4:1} = "1" ] && [ ${Byte1:5:1} = "1" ] && [ ${Byte1:6:1} = "0" ]; then
				echo "512 samples are used for each averaging."
			else
				echo "1024 samples are used for each averaging."
			fi
			if [ ${Byte1:7:1} = "0" ] && [ ${Byte2:0:1} = "0" ] && [ ${Byte2:1:1} = "0" ]; then
				echo "Bus voltage conversion time is 140us"
			elif [ ${Byte1:7:1} = "0" ] && [ ${Byte2:0:1} = "0" ] && [ ${Byte2:1:1} = "1" ]; then
				echo "Bus voltage conversion time is 204us"
			elif [ ${Byte1:7:1} = "0" ] && [ ${Byte2:0:1} = "1" ] && [ ${Byte2:1:1} = "0" ]; then
				echo "Bus voltage conversion time is 332us"
			elif [ ${Byte1:7:1} = "0" ] && [ ${Byte2:0:1} = "1" ] && [ ${Byte2:1:1} = "1" ]; then
				echo "Bus voltage conversion time is 588us"
			elif [ ${Byte1:7:1} = "1" ] && [ ${Byte2:0:1} = "0" ] && [ ${Byte2:1:1} = "0" ]; then
				echo "Bus voltage conversion time is 1.1ms"
			elif [ ${Byte1:7:1} = "1" ] && [ ${Byte2:0:1} = "0" ] && [ ${Byte2:1:1} = "1" ]; then
				echo "Bus voltage conversion time is 2.116ms"
			elif [ ${Byte1:7:1} = "1" ] && [ ${Byte2:0:1} = "1" ] && [ ${Byte2:1:1} = "0" ]; then
				echo "Bus voltage conversion time is 4.156ms"
			else
				echo "Bus voltage conversion time is 8.244ms"
			fi
			if [ ${Byte2:2:1} = "0" ] && [ ${Byte2:3:1} = "0" ] && [ ${Byte2:4:1} = "0" ]; then
				echo "Shunt voltage conversion time is 140us"
			elif [ ${Byte2:2:1} = "0" ] && [ ${Byte2:3:1} = "0" ] && [ ${Byte2:4:1} = "1" ]; then
				echo "Shunt voltage conversion time is 204us"
			elif [ ${Byte2:2:1} = "0" ] && [ ${Byte2:3:1} = "1" ] && [ ${Byte2:4:1} = "0" ]; then
				echo "Shunt voltage conversion time is 332us"
			elif [ ${Byte2:2:1} = "0" ] && [ ${Byte2:3:1} = "1" ] && [ ${Byte2:4:1} = "1" ]; then
				echo "Shunt voltage conversion time is 588us"
			elif [ ${Byte2:2:1} = "1" ] && [ ${Byte2:3:1} = "0" ] && [ ${Byte2:4:1} = "0" ]; then
				echo "Shunt voltage conversion time is 1.1ms"
			elif [ ${Byte2:2:1} = "1" ] && [ ${Byte2:3:1} = "0" ] && [ ${Byte2:4:1} = "1" ]; then
				echo "Shunt voltage conversion time is 2.116ms"
			elif [ ${Byte2:2:1} = "1" ] && [ ${Byte2:3:1} = "1" ] && [ ${Byte2:4:1} = "0" ]; then
				echo "Shunt voltage conversion time is 4.156ms"
			else
				echo "Shunt voltage conversion time is 8.244ms"
			fi
			if [ ${Byte2:5:1} = "0" ] && [ ${Byte2:6:1} = "0" ] && [ ${Byte2:7:1} = "0" ]; then
				echo "IMON mode - Power-down."
			elif [ ${Byte2:5:1} = "0" ] && [ ${Byte2:6:1} = "0" ] && [ ${Byte2:7:1} = "0" ]; then
				echo "IMON mode - Shunt voltage, triggered."
			elif [ ${Byte2:5:1} = "0" ] && [ ${Byte2:6:1} = "0" ] && [ ${Byte2:7:1} = "0" ]; then
				echo "IMON mode - Bus voltage, triggered."
			elif [ ${Byte2:5:1} = "0" ] && [ ${Byte2:6:1} = "0" ] && [ ${Byte2:7:1} = "0" ]; then
				echo "IMON mode - Shunt and bus, triggered."
			elif [ ${Byte2:5:1} = "0" ] && [ ${Byte2:6:1} = "0" ] && [ ${Byte2:7:1} = "0" ]; then
				echo "IMON mode - Power-down."
			elif [ ${Byte2:5:1} = "0" ] && [ ${Byte2:6:1} = "0" ] && [ ${Byte2:7:1} = "0" ]; then
				echo "IMON mode - Shunt voltage, continuous."
			elif [ ${Byte2:5:1} = "0" ] && [ ${Byte2:6:1} = "0" ] && [ ${Byte2:7:1} = "0" ]; then
				echo "IMON mode - Bus voltage, continuous."
			else
				echo "IMON mode - Shunt and bus, continuous."
			fi
		else
			echo "Error occurred."
			echo
		fi
	else

		Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0x80 0x07 0x00 0x01 0x02 0x00"
		send_IPMICmd
		
		if [ "$ERR" = "0" ]; then
			CfgInt=`(printf '%d' "${RESP:0:4}${RESP:7:2}")`
			
			if [ "$Mode" != "" ]; then
				if [ "$Verbose" = "1" ]; then
					echo ""
					echo "Setting IMON mode to $Mode."
				fi
				
				CfgInt=`(printf '%d' "${RESP:0:4}${RESP:7:2}")`
				
				(( CfgInt = CfgInt & 65528 ))
				(( CfgInt = CfgInt | Mode ))
			fi	
			if [ "$AvgSamples" != "" ]; then
				if [ "$Verbose" = "1" ]; then
					if [ "$AvgSamples" = "0" ]; then
						Samples=1
					elif [ "$AvgSamples" = "1" ]; then
						Samples=4
					elif [ "$AvgSamples" = "2" ]; then
						Samples=16
					elif [ "$AvgSamples" = "3" ]; then
						Samples=64
					elif [ "$AvgSamples" = "4" ]; then
						Samples=128
					elif [ "$AvgSamples" = "5" ]; then
						Samples=256
					elif [ "$AvgSamples" = "6" ]; then
						Samples=512
					elif [ "$AvgSamples" = "7" ]; then
						Samples=1024
					else
						ERR="1"
						echo "Invalid setting requested for Averaging samples."
						echo "Error occurred."
						return
					fi
					echo
					echo "Setting the number of samples used for averaging to $Samples."
				fi
				
				(( CfgInt = CfgInt & 61951 ))
				(( AvgSamples = AvgSamples << 9 ))
				(( CfgInt = CfgInt | AvgSamples ))
			fi
			if [ "$BusConvTime" != "" ]; then
				if [ "$Verbose" = "1" ]; then
					if [ "$BusConvTime" = "0" ]; then
						BCT="140us"
					elif [ "$BusConvTime" = "1" ]; then
						BCT="204us"
					elif [ "$BusConvTime" = "2" ]; then
						BCT="332us"
					elif [ "$BusConvTime" = "3" ]; then
						BCT="588us"
					elif [ "$BusConvTime" = "4" ]; then
						BCT="1.1ms"
					elif [ "$BusConvTime" = "5" ]; then
						BCT="2.116ms"
					elif [ "$BusConvTime" = "6" ]; then
						BCT="4.156ms"
					elif [ "$BusConvTime" = "7" ]; then
						BCT="8.244ms"
					else
						ERR="1"
						echo "Invalid setting requested for bus voltage conversion time."
						echo "Error occurred."
						return
					fi
					echo
					echo "Setting the bus conversion time to $BCT."
				fi
				
				(( CfgInt = CfgInt & 65087 ))
				(( BusConvTime = BusConvTime << 6 ))
				(( CfgInt = CfgInt | BusConvTime ))
			fi
			if [ "$ShuntConvTime" != "" ]; then
				if [ "$Verbose" = "1" ]; then
					if [ "$ShuntConvTime" = "0" ]; then
						SCT="140us"
					elif [ "$ShuntConvTime" = "1" ]; then
						SCT="204us"
					elif [ "$ShuntConvTime" = "2" ]; then
						SCT="332us"
					elif [ "$ShuntConvTime" = "3" ]; then
						SCT="588us"
					elif [ "$ShuntConvTime" = "4" ]; then
						SCT="1.1ms"
					elif [ "$ShuntConvTime" = "5" ]; then
						SCT="2.116ms"
					elif [ "$ShuntConvTime" = "6" ]; then
						SCT="4.156ms"
					elif [ "$ShuntConvTime" = "7" ]; then
						SCT="8.244ms"
					else
						ERR="1"
						echo "Invalid setting requested for shunt voltage conversion time."
						echo "Error occurred."
						return
					fi
					echo
					echo "Setting the shunt conversion time to $SCT."
				fi
				
				(( CfgInt = CfgInt & 65479 ))
				(( ShuntConvTime = ShuntConvTime << 3 ))
				(( CfgInt = CfgInt | ShuntConvTime ))
			fi
			if [ "$Enable" = "0" ]; then
				if [ "$Verbose" = "1" ]; then
					echo "Disabling channel $Channel."
				fi
				
				(( Channel = (1 << ( 15 - Channel )) ^ 65535 ))
				(( CfgInt = CfgInt & Channel ))
			fi
			if [ "$Enable" = "1" ]; then
				if [ "$Verbose" = "1" ]; then
					echo "Enabling channel $Channel."
				fi
				
				(( Channel = 1 << ( 15 - Channel ) ))
				(( CfgInt = CfgInt | Channel ))
			fi
			
			(( LoInt = CfgInt & 255 ))
			LO=`(printf '%2.2x' $LoInt)`

			(( HiInt = ( CfgInt>>8 ) & 255 ))
			HI=`(printf '%2.2x' $HiInt)`

			
			echo "Previous configuration register setting = ${RESP:0:4}${RESP:7:2}"

			Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x08 0x80 0x07 0x00 0x03 0x00 0x00 0x$HI 0x$LO"
			send_IPMICmd
			
			Switch="-r"
			config
		else
			echo
			echo "Error occurred."
			echo
		fi
	fi
	
	echo ""
}

reset()
{   
	ERR="0"

	if [ "$Verbose" = "1" ]; then
		echo ""
		echo "Resetting IMON."
	fi
	
	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0x80 0x07 0x00 0x01 0x02 0x00"
	send_IPMICmd
	
	
	CfgInt=`(printf '%d' "${RESP:0:4}${RESP:7:2}")`
	
	(( CfgInt = CfgInt | 32768 ))
		
	(( LoInt = CfgInt & 255 ))
	LO=`(printf '%2.2x' $LoInt)`

	(( HiInt = ( CfgInt>>8 ) & 255 ))
	HI=`(printf '%2.2x' $HiInt)`

	
	echo "Previous configuration register (before reset) = ${RESP:0:4}${RESP:7:2}"

	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x08 0x80 0x07 0x00 0x03 0x00 0x00 0x$HI 0x$LO"
	send_IPMICmd

	Switch="-r"
	config

	echo ""
}

current()
{	
	ERR="0"

	declare -i Resistor
	declare -i Voltage
	declare -i Current
		
	if [ "$Verbose" = "1" ]; then
		echo ""
		echo "Reading channel $Channel shunt voltage."
	fi
	
	if [ $Channel = "1" ]; then
		Divisor=1000
		Addr="1"
	elif [ $Channel = "2" ]; then
		Divisor=500
		Addr="3"
	elif [ $Channel = "3" ]; then
		Divisor=333
		Addr="5"
	else
		echo
		echo "Invalid channel number."
		echo
		ERR="1"
		return
	fi
	
	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0x80 0x07 0x00 0x01 0x02 0x0$Addr"
	send_IPMICmd

	if [ "$ERR" = "0" ]; then
		Voltage=`(printf '%d' "${RESP:0:4}${RESP:7:2}")`
		(( current = Voltage * 5 )) 
		
		if [ "$Verbose" = "1" ]; then
			echo "Shunt voltage = $current uV"
		fi
		
		(( CurrentInt = Voltage * 10 / Divisor ))
		(( CurrentDec = (( Voltage * 10  + 5 ) % Divisor )))
		StringBuf="$CurrentDec"
		while [ ${#StringBuf} -lt "2" ]
		do
			StringBuf="0$StringBuf"
		done
		StringBuf=${StringBuf:0:2}

		echo
		echo "Shunt current = $CurrentInt.$StringBuf A"
		echo
	else
		echo "Error occurred."
	fi

	echo ""
}

voltage()
{	
	ERR="0"

	declare -i Resistor
	declare -i Voltage
	Divisor=10000
		
	if [ "$Verbose" = "1" ]; then
		echo ""
		echo "Reading channel $Channel bus voltage."
	fi
	
	if [ $Channel = "1" ]; then
		Addr="2"
	elif [ $Channel = "2" ]; then
		Addr="4"
	elif [ $Channel = "3" ]; then
		Addr="6"
	else
		echo
		echo "Invalid channel number."
		echo
		ERR="1"
		return
	fi
	
	Cmd="IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0x80 0x07 0x00 0x01 0x02 0x0$Addr"
	send_IPMICmd

	if [ "$ERR" = "0" ]; then
		Voltage=`(printf '%d' "${RESP:0:4}${RESP:7:2}")`
		(( VoltageInt = Voltage * 10 / Divisor ))
		(( VoltageDec = ((( Voltage * 10) + 5 ) % Divisor ) / 10 ))
		StringBuf="$VoltageDec"
		while [ ${#StringBuf} -lt "3" ]
		do
			StringBuf="0$StringBuf"
		done

		echo
		echo "Bus voltage = $VoltageInt.$StringBuf V"
		echo
	else
		echo "Error occurred."
	fi

	echo ""
}

CLIParse $1 $2 $3 $4 $5 $6 $7 $8 $9
if [ "$Script" = "0" ]; then
	exit
fi

