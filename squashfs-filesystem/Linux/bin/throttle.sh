#!/etc/bash

THROTTLE_BUILD_DATE="2017-06-21"
THROTTLE_VER="2.6"
BUILD="BUILD37"

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Dell Confidential. DELL (c) Inc. CopyRight Reserved! 2016
# ---------------------------------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Version: 2.6
# Date:    06/21/2017
# Author:  Mark_Tsai@DELL.com / Dit_Charoen@DELL.com
# - [1] Add KabyLake-S CPU type in get_processor_cpuid()
# - [1,8] Display CPU and DRAM RAPL time windows down to usec instead of msec
# - [8] Add DRAM RAPL messaging improvement
# - [8] Add and Re-fine PL_CSR_ENABLE_ARRAY[]
# - [8] Re-fine PL_CSR_ARRAY[]
# - [11] Decoded numerical timestamp to calendar date and time
# - [2,14] Modify clear PSU faults by clear only individual bits that are set instead of using CLEAR_FAULTS command
# - [2,14] PSU status registers now cleared automatically in -loop mode
# - Add function DisplayTimeStamp()
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Version: 2.5
# Date:    07/18/2016
# Author:  Kelvin_Huang1@DELL.com / Dit_Charoen@DELL.com
#
# - [1] Added display of system ambient sensors
# - [1] Displayed PSU Redundancy Policy
# - [1] Displayed PSU Hot Spare Mode
# - [2] Indicated that "any_psu_pwr_event_asserted" latch bit at XBus 17h[3] should also indicate (POWER_CMD_6) for Modular-FC
# - [2] Displayed SmaRT&CLST PSU OC/OT/UV status and event counter on Monolithic platforms
# - [2] Displayed CLST_latch bit on Modular platforms
# - [8] Indicated NM throttled CPU when the PCS PL1 value is less than PL2, instead of less than 1.0x TDP
# - [8] Displayed the updated counter duration with time unit for PACKAGE_RAPL_PERF_STATUS, DRAM_RAPL_PERF_STATUS and Socket Power Throttled Duration
# - [8] Updated CPU PL2 safety net (Tpulse). It is forced to 4ms regardless of the PL2 TW programmed.
# - [9,10] For Safe Power Cap policy, with Policy Trigger Type 2, Aggressive Mode (T-state) is always allowed.
# - [14] Added -cp option to clear PSU all fault bits (display then clear)
# - [14] Added display of PSU STATUS_BYTE, STATUS_WORD, and STATUS_OTHER registers
# - Added PECI Proxy command timeout retry (CC=0xA2)
# - Added 13G Pounceport KNL Groveport support
# - Added GENERATION_INFO 0x22 for DCS/PEC platforms
# - Added /tmp to default throttlem.txt searching path
# - Added IPMI command completion code decoder support for "06:59", "0A:43", "30:B3", "30:CE"
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Version: 2.4+
# Date:    10/20/2015
# Author:  Kelvin_Huang1@DELL.com / Dit_Charoen@DELL.com
#
# - Changed -cl option to only clear latch bits that are set (display then clear)
# - Added -cs option to clear only NM statistics (display then clear)
# - Added -ca option to clear both latche bits and NM statistics (display then clear)
# - [11] Removed NM statistics clearing code during script initialization for loop mode
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Version: 2.4
# Date:    06/17/2015
# Author:  Kelvin_Huang1@DELL.com / Dit_Charoen@DELL.com
#
# - Trimmed trailing spaces for Git checking
# - Updated processor type boundary checking condition
# - Fixed 12.5G 1600W PSU reporting (Constant Current(CC) counter not supported)
# - Enabled Greenlow Skylake-S E3 platform support
# - Enabled Grantley Broadwell E5 processor support
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Version: 2.3
# Date:    02/17/2015
# Author:  Kelvin_Huang1@DELL.com / Dit_Charoen@DELL.com
#
# - [2]  For monolithic, add detection for chassis intrusion switch.
# - [3]  For 13G CPUs, add checking of current status bits (even bits 4, 2, 0) for the Thermal Status Sensors in addition to latch bits (odd bits 5, 3, 1).
# - [3]  Add display of effective TCC activation temperature in Celsius and current CPU temperature when TCC is activated.
# - [8]  Modify the display message to include the NM Per-Policy Throttling Statistics Section.
# - [9]  For monolithic, add detection for chassis intrusion switch which triggers CPU and System thermal power cap policies to be enabled and the former to be activated.
# - [11] Add NM per Domain throttling check.
# - [12] Modify the display message to highlight CPU performance capped.
# - [14] For modular in Stomp chassis (Modular-FC), display the SPL as part of [14]
# - [14] Modify the display message to highlight PSU OCW events
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# V2.0
#
# James_YM_Huang@Dell.com
#
# throttle.sh : Version 1.3 : 01/17/2013 Beta1
# Location:  http://intranet.dell.com/pg/epe-dsre/Power/Specifications/Forms/AllItems.aspx (Not Yet)
#
# Design collateral that documents throttle mechanisms in detail, and contains the source of the throttle mechanisms used in this script
#    - http://intranet.dell.com/pg/epe-dsre/Power/Specifications/12G%20Throttle%20Guide.docx
#
# Added getting the PSU Status Registers if the PMBusAlert is set.
# Added getting the identified NM Policy Record while NM Policy is throttling.
# Added getting the THRT_DEMAND_COUNTER and to check the value if it is throttling. (Haswell/Romley needed).
# Added getting the IA_PERF_LIMIT_REASONS(MSR:0690h) & RING_PERF_LIMIT_REASONS(MSR:06B1h) on Haswell/Romley.
# Added detection mechanism to check for CPU population at beginning, and remove the checking from every sections.
# Added detection mechanism to check for DIMM population at beginning, and remove the checking from every sections.
# Added retry mechanism to re-test the IPMI command as failure return, and output the warning if failed to retry.
# Added mechanism to output the completion-code illustrative message.
# Added detection mechanism to swap the PSU address since ICON system is not the same with others.
# Changed command option "dncl" instead of "dc", also fixed wrong message on this "Not clear the..." instead of "Clear the...".
# Re-arranged new section name ordely instead of.
# Fixed a founded bug: throttle.sh v1.2
#     Line657: y=$(($a&1)) instead of y=$(($a&0))
# Re-arrange the section in order.
#     Section 1: Initialization
#        Clear the 8 latches in the iDRAC XBus Memory Map
#        Clear the CLTT DIMM Temperature Threshold Latching Bits
#     Section 2
#        Read the 9 bits from the iDRAC XBus Memory Map that can identify if PROCHOT# or MEMHOT# is/was asserted
#     Section 3
#        Read the CPU Thermal Status Sensors
#     Section 4
#        Read the CPU MEMHOT# status register
#     Section 6
#        Check specific DIMM CLTT DIMM Temperature Threshold Latching Bits
#     Section 5
#        Check to see if DIMM_TEMP > TEMP_LO, which identifies CLTT throttling
#        Retrieve the TEMP_LO. Then, compare with for each of others.
#     Section 7
#        Check Throttling Demand Counter & CPU MSR Check
#     Section 8
#        Check CPU and DRAM RAPL Information
#     Section 9
#        Check if a Node Manager policy is limiting
#     Section 10
#        Parsing & Display all of the NM Policy information
#     Section 11
#        Get the global throttling statistics
#     Section 12
#        Get the max allowed CPU P-State and T-State
#     Section 13
#        Get the Aditional Configuration includes Node Manager K-Coefficient, CPU Power comsumption, ... etc.
#     Section 14
#        Get the Aditional Configuration includes PSU Status.
#
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# History before v2.0, please refer to the throttle.sh rev.1.2 on iDRAC7/12G.
# ---------------------------------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Help Function
# ---------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------
# Display specify message and log to the file
# $1:    echo message
# $OP:   control
#------------------------------------------------------------------------------------------------------
function echo_result_by_op
{
   if [ $OP = 1 ]; then
      echo "$1"
   fi
}

# ---------------------------------------------------------------------------------------------------------------------
# Description:
#           Print the error message depends on completion code
#
# Parameter:
#           s1(string):key             ex: "2E:D9"
#           s2(string):cp              ex: "A9" or "D2"
# ---------------------------------------------------------------------------------------------------------------------
function disp_completion_code_message
{
   #echo "The IPMI command was not successful, and the completion code was $cp."
   # ex: format="2E:44:CP:xx"
   # To find the specific competion code at first
   if [ $DEBUG -ne 1 ]; then
      fx=$(grep "^$1:CP:$2" -s -m 1 /bin/throttlem.txt)
      if [ $? -ne 0 ]; then
         fx=$(grep "^$1:CP:$2" -s -m 1 /tmp/throttlem.txt)
      fi
   else
      fx=$(grep "^$1:CP:$2" -s -m 1 /tmp/throttlem.txt)
      if [ $? -ne 0 ]; then
         fx=$(grep "^$1:CP:$2" -s -m 1 /bin/throttlem.txt)
      fi
   fi
   fx=$(echo $fx | cut -d '=' -f 2 )
   if [ $? != 0 ] || [ "$fx" = "" ]
   then                             # Not found, try again at default range
      # ex: format="CP:xx"
      if [ $DEBUG -ne 1 ]; then
         fx=$(grep "^CP:$2" -s -m 1 /bin/throttlem.txt)
         if [ $? -ne 0 ]; then
            fx=$(grep "^CP:$2" -s -m 1 /tmp/throttlem.txt)
         fi
      else
         fx=$(grep "^CP:$2" -s -m 1 /tmp/throttlem.txt)
         if [ $? -ne 0 ]; then
            fx=$(grep "^CP:$2" -s -m 1 /bin/throttlem.txt)
         fi
      fi
      fx=$(echo $fx | cut -d '=' -f 2 )
      if [ $? != 0 ] || [ "$fx" = "" ]; then
         echo "    -Unknown completion code description or decode file (throttlem.txt) is missing."
      else
         echo "    -"$fx
      fi
   else
      echo "    -"$fx
   fi
}

#------------------------------------------------------------------------------------------------------
# $1: completion code
#------------------------------------------------------------------------------------------------------
function wait_n_if_disp_dbgmessage
{
   if [ $DEBUG = 1 ]; then
      disp_completion_code_message $IPMICMD_CAT $1
   fi
}

#------------------------------------------------------------------------------------------------------
# $1:    $z: mode
# $2:    $x: echo message
# $3     $w: cpu index
#------------------------------------------------------------------------------------------------------
function print_PECI_cpu_dram_rapl_sta
{
#------------------------------------------------------------------------------------------------------
RAPL_NAME_ARRAY="RAPL PL1,RAPL PL2,DRAM RAPL"                  #RAPL TYPE String arrays
RAPLNAME_STR=$(echo $RAPL_NAME_ARRAY | cut -f $1 -d ',')       # Parse the array, and grab the y'th value in the space delimited array
#------------------------------------------------------------------------------------------------------
   # ------------------ CPU RAPL ------------ PL1 --------------
   #
   aa=$(echo $2 | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # a is now equal to bits [7:0] of the response
   a=$((0x$aa))                                         # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
   bb=$(echo $2 | cut -f 9 -d ' ' | cut -f 2 -d 'x')    # b is now equal to bits [7:0] of the response
   b=$((0x$bb))                                         # b is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
   cc=$(echo $2 | cut -f 10 -d ' ' | cut -f 2 -d 'x')   # c is now equal to bits [7:0] of the response
   c=$((0x$cc))                                         # c is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
   dd=$(echo $2 | cut -f 11 -d ' ' | cut -f 2 -d 'x')   # d is now equal to bits [7:0] of the response
   d=$((0x$dd))                                         # d is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
   # ---------------- Start PARSING RAPL DATA ------------------
   # 1).RAPL PL1, 2).RAPL PL2, 3).DRAM RAPL
   # Check bit 7 of byte 2 :
   # -----------------------------
   e=$(($b&128))
   if [ $e != 128 ]; then # if bit 7 of the 2nd byte, aka bit 15 of the 32-bit register is set, then throttling is occuring
      echo_result_by_op "        CPU$3 $RAPLNAME_STR in PCS is disabled."
   else
      # if power limit via PECI is less than via CSR, then CPU is throttled.
      LIMIT=$((0x$bb$aa)) # LIMIT = bits 15:0, need to mask off high bit
      LIMIT=$(($LIMIT&0x7FFF))   # Mask off high bit

      POWER_UNIT=$((POWER_UNIT_ARRAY[$(($3-1))]))
      LIMIT_LAST=$(echo $LIMIT $POWER_UNIT | awk '{printf("%.3f",($1/$2))}') # in Watts
      CSR_LIMIT_ENABLE=$((PL_CSR_ENABLE_ARRAY[$1-1+($3-1)*3]))

      if [ $CSR_LIMIT_ENABLE -eq 1 ]; then # Power Limit enabled by BIOS in CSR
         if [ $1 -eq 1 ]; then # RAPL_PL1 use CPU RAPL CSR PL2
            CSR_LIMIT=$((PL_CSR_ARRAY[2+($3-1)*3])) # CPU PL2
            # Since NM applies PL1 at 250ms time window, if the applied PL1 is between 1.2x TDP (PL2) and TDP,
            # this will throttle the CPU if the workload hits power level in this range with NM as cause of throttling.
         else
            CSR_LIMIT=$((PL_CSR_ARRAY[$1+($3-1)*3]))
         fi
         CSR_LIMIT=$(($CSR_LIMIT))
         CSR_LIMIT_LAST=$(echo $CSR_LIMIT $POWER_UNIT | awk '{printf("%.3f",($1/$2))}') # in Watts

         if [ $CSR_LIMIT -gt $LIMIT ]; then
            if [ $1 -eq 1 ] || [ $1 -eq 2 ]; then #RAPL_PL1 RAPL_PL2
                echo "**   NM is applying (real-time) power limit to CPU$3: $RAPLNAME_STR ${LIMIT_LAST}W in PCS < RAPL PL2 ${CSR_LIMIT_LAST}W in CSR"
            else # DRAM RAPL
                echo "**   NM is applying (real-time) power limit to CPU$3: $RAPLNAME_STR ${LIMIT_LAST}W in PCS < ${CSR_LIMIT_LAST}W in CSR"
            fi
         else
            echo "**   NM is applying (real-time) power limit to CPU$3: $RAPLNAME_STR ${LIMIT_LAST}W in PCS"
            echo "     Note: CPU$3 $RAPLNAME_STR is enabled at ${CSR_LIMIT_LAST}W in CSR"
         fi
      else # Power Limit not enabled by BIOS in CSR
         echo "**   NM is applying (real-time) power limit to CPU$3: $RAPLNAME_STR ${LIMIT_LAST}W in PCS"
         echo "     Note: CPU$3 $RAPLNAME_STR in CSR is disabled."
      fi
      echo_result_by_op "        CPU$3 $RAPLNAME_STR in PCS is enabled."
      # -----------------------------
      if [ $DEBUG -eq 1 ]; then
         echo_result_by_op "            - Register Value (MSB First)  = 0x$dd 0x$cc 0x$bb 0x$aa"
      fi
      # -----------------------------
      TIME_UNIT=$((TIME_UNIT_ARRAY[$3-1]))
      echo_result_by_op "            - Power Limit (in PCS)        = $LIMIT_LAST Watts"

      # PL2 for SandyBridge/IvyBridge -----------------------------------
      if [ $1 -eq 2 ] && ([ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x11" ]); then
         # 32-bits of data
         # [31]    Lock bit
         # [30:24] Reserved
         # [23:17] ControlTimeWindow in ms   byte 2: bits 1 - 7: Mask : 0xFE, then shift right one bit
         # [16]    LimitationClamping        Byte 2: bit 0
         # [15]    ControlEnabled            *********** INDICATES THROTTLING Byte 1, bit 7
         # [14:0]  Limit                     Byte 0 and Byte 1 : Mask: 0x7FFF
         # -----------------------------
         #PL2 formula: in 3 - 10 ms.
         VALUE=$(($c&0xFE))   # mask off bit 0
         VALUE=$(($VALUE>>1))
         VALUE=$(($VALUE))    # turn VALUE into a decimal number
         echo_result_by_op "            - Control Time Window reading = $VALUE milliseconds"
      # PL1 & DRAM & (for Haswell) PL2 -----------------------------
      else
         # 32-bits of data
         # [31:24] Reserved = 0
         # [23:22] ControlTimeWindowFraction = 0   byte2 bits 7, 6 : Mask : 0xC0, shift right 6 bits
         # [21:17] ControlTimeWindowExponent = 8   byte2 bits 1,2,3,4,5 : Mask : 0x3E, then shift right one bit
         # [16]    LimitationClamping = 1          Byte 2: bit 0
         # [15]    ControlEnabled = 1              *********** INDICATES THROTTLING Byte 1, bit 7
         # [14:0]  Limit = 0                       Byte 0 and Byte 1 : Mask: 0x7FFF
         # -----------------------------
         # [21:17] ControlTimeWindowExponent: byte2 bits 1,2,3,4,5 : Mask : 0x3E, then shift right one bit
         CTWE=$(($c&0x3E)) # mask off bits 7 and 6, and 0
         CTWE=$(($CTWE>>1))
         CTWE=$(($CTWE))   # turn CTWE into a decimal number
         #echo "            - Control Time Window Exponent value = $CTWE"
         # -----------------------------
         # [23:22] ControlTimeWindowFraction = 0     byte2 bits 7, 6 : Mask : 0xC0, shift right 6 bits
         # PL1 to be in the range 250 mS-40 seconds
         # PL2 to be in the range 3 mS-10 mS
         CTWF=$(($c&0xc0))    # mask off bits 0-5, and only leave 7 and 6
         CTWF=$(($CTWF>>6))   # Shift right 6 bits
         CTWF=$(($CTWF))      # Turn into a decimal before reporting
         #echo "            - Control Time Window Fraction value = $CTWF"
         # -----------------------------
         #PL1 formula: (1+0.25*Fraction) * 2[exp(Exponent)]: be within a range of 250 mS-40 seconds.
         #DRAM formula: same with PL1
         TIMESLOT=$(echo $CTWF $CTWE $TIME_UNIT | awk '{printf("%.3f",((1+($1/4))*(2**$2)/$3*1000))}')   # in ms
         echo_result_by_op "            - Control Time Window reading = $TIMESLOT milliseconds"

      fi
      # -----------------------------
      # [16] LimitationClamping = 1                                         Byte 2, bit 1
      # Check bit 0 of byte 2 :
      e=$(($c&1))
      if [ $e = 1 ] # if bit 0 of the 2nd byte, aka bit 16 of the 32-bit register is set
         then
         echo_result_by_op "            - Limitation Clamping         = Set"
      else
         echo_result_by_op "            - Limitation Clamping         = Not Set"
      fi # if [$e=1]
      # ---------------- END PARSING RAPL DATA ------------------
   fi # if [ $e = 128 ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Description:
#           Get catalog information by a specific data value.
#
# Parameter:
#           s1(string):key    ex: "2E:D9"
#           s2(string):cmd    ex: "7A"
# ---------------------------------------------------------------------------------------------------------------------
function get_catalog_info_by_command
{
   indexkey=$1:$2
   if [ $DEBUG -ne 1 ]; then
      mtitle=$(grep "^$indexkey" -s -m 1 /bin/throttlem.txt)
      if [ $? -ne 0 ]; then
         mtitle=$(grep "^$indexkey" -s -m 1 /tmp/throttlem.txt)
      fi
   else
      mtitle=$(grep "^$indexkey" -s -m 1 /tmp/throttlem.txt)
      if [ $? -ne 0 ]; then
         mtitle=$(grep "^$indexkey" -s -m 1 /bin/throttlem.txt)
      fi
   fi
   mtitle=$(echo $mtitle | cut -d '=' -f 2 )
   if [ $? = 1 ]; then    # decode is not found
      echo "ERROR:  Decode for $indexkey is not found in get_catalog_info_by_command()"
   fi
}

# ---------------------------------------------------------------------------------------------------------------------
# Description:
#           Print all of catalog information by a specific single a data-byte. If data value not be found, display with nothing.
#
# Parameter:
#           s1(string):key    ex: "2E:D9"
#           s2(string):cmd    ex: "7A"
#           s3(string):data   index
#           s4(string):bitmap bitmap
# ---------------------------------------------------------------------------------------------------------------------
function print_psu_reg_info_with_bit
{
   indexkeyd=$1:$2:$4
   if [ $DEBUG -ne 1 ]; then
      fx=$(grep "^$indexkeyd" -s -m 1 /bin/throttlem.txt)
      if [ $? -ne 0 ]; then
         fx=$(grep "^$indexkeyd" -s -m 1 /tmp/throttlem.txt)
      fi
   else
      fx=$(grep "^$indexkeyd" -s -m 1 /tmp/throttlem.txt)
      if [ $? -ne 0 ]; then
         fx=$(grep "^$indexkeyd" -s -m 1 /bin/throttlem.txt)
      fi
   fi
   fx=$(echo $fx | cut -d '=' -f 2 )
   if [ $? = 0 ]; then    # decode is found
      echo "            :$fx"
   else
      echo "ERROR:  Decode for $indexkeyd is not found in print_psu_reg_info_with_bit()"
   fi
}

# ---------------------------------------------------------------------------------------------------------------------
# Description:
#           Print all of catalog by a specific single bitmap-byte.
#
# Parameter:
#           s1(string):key    ex: "2E:D9"
#           s2(string):cmd    ex: "7A"
#           s3(string):data   Retrieved data by IPMI command.
# ---------------------------------------------------------------------------------------------------------------------
function print_psu_info_by_command
{
   btCount=1
   bitD3=0x00
   dataValue=0x$3
   dataValue=$(($dataValue))

   get_catalog_info_by_command $1 $2   # return at $mtitle
   if [ $OP -eq 1 ] || [ $dataValue != 0 ]; then
      echo "        PSU$4 $mtitle(0x$3):"       # display command catalog. ex: STATUS_VOUT(XX):
   fi

   while [ $btCount -le 8 ]; do     #loop for per bit field

      bitMask=$((2 ** ($btCount-1)))         # get a bitmask with ( 2^^(loopcount-1) )
      dataValue=0x$3                         # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
      dataValue=$(($bitMask & $dataValue))   # Is the bit set?
      sx=$(printf "%02X" $dataValue)         # output a string with format by data being masked
      if [ $dataValue != 0 ]; then
         print_psu_reg_info_with_bit $1 $2 $3 $sx
      fi
      btCount=$(($btCount+1))
   done
}

# ---------------------------------------------------------------------------------------------------------------------
# Parameter:
#           s1(string):key    ex: "2E:D9:ED"
#           s2(string):cmd    ex: data
#           s3(string):bitmap ex: "01" or ""40"
#           s4(string):bitval ex: 1 or 0
# ---------------------------------------------------------------------------------------------------------------------
function print_psu_reg_infoEx_with_bit
{
   indexkeyd=$1:$3=$4
   #echo "indexkeyd=$indexkeyd"
   if [ $DEBUG -ne 1 ]; then
      fx=$(grep "^$indexkeyd" -s -m 1 /bin/throttlem.txt )
      if [ $? -ne 0 ]; then
         fx=$(grep "^$indexkeyd" -s -m 1 /tmp/throttlem.txt )
      fi
   else
      fx=$(grep "^$indexkeyd" -s -m 1 /tmp/throttlem.txt )
      if [ $? -ne 0 ]; then
         fx=$(grep "^$indexkeyd" -s -m 1 /bin/throttlem.txt )
      fi
   fi
   #echo "fx=$fx"
   if [ $? = 0 ]; then    # decode is found
      dx=$(echo $fx | cut -d '=' -f 3)
      #echo "dx=$dx"
      echo_result_by_op "            :$dx"
   else
      echo "ERROR:  Decode for $indexkeyd is not found in print_psu_reg_infoEx_with_bit()"
   fi
}

# ---------------------------------------------------------------------------------------------------------------------
# Description:
#           Print all of bit fields info on given catalog by a specific single byte.
#
# Parameter:
#           s1(string):key    ex: "2E:D9"
#           s2(string):cmd    ex: "ED"
#           s3(string):data   Retrieved data by IPMI command.
# ---------------------------------------------------------------------------------------------------------------------
function print_psu_infoEx_by_command
{
   bitsmap=1
   #btCount=1
   bitD3=0x00

   get_catalog_info_by_command $1 $2   # return at $mtitle
   echo_result_by_op "        PSU$4 $mtitle(0x$3):"       # display command catalog. ex: STATUS_VOUT(XX):

   #while [ $btCount -le 8 ]; do     #loop for per bit field

      dataValue=0x$3                         # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
      dataValue=$(($dataValue & $bitsmap))     # Is the bit set?
      sx=$(printf "%02X" $bitsmap)           # output a string with format by data being masked
      #echo $btCount,$dataValue,$bitsmap

      if [ $dataValue != 0 ]; then
         print_psu_reg_infoEx_with_bit "$1:$2" $3 $sx 1  # "2E:D9:ED", data, index="01", 1
      else
         print_psu_reg_infoEx_with_bit "$1:$2" $3 $sx 0  # "2E:D9:ED", data, index="01", 0
      fi
      bitsmap=$((2*$bitsmap))
   #   btCount=$(($btCount+1))
   #done
}

#------------------------------------------------------------------------------------------------------
# ex: check_cp_then_action $cp "A2" "80 81" "Check CPU and DIMM RAPL" $IPMICMD_CAT
#     $1: $cp                          - completion code
#     $2: "AC"                         - terminated condition completion code array
#     $3: "80 A2"                      - retry again condition completion code array
#     $4: "Test CLTT Throttle"         - section name displayin
#     $5: $IPMICMD_CAT                 - section IPMI & SubCommand catalog list
#------------------------------------------------------------------------------------------------------
function check_cp_then_action #($cp, $terminate, $timeout, $display, $cmdset)
{
#------------------------------------------------------------------------------------------------------
# terminated: check specfic command code group for termination. ex: device not present
#------------------------------------------------------------------------------------------------------
local i=1
local cp=$1
local target
local target_old=''
local RETRY=0

target=$(echo $2 | cut -f $i -d ' ')
while [ -n "$target" ] && [ "$target" != "$target_old" ]; do
   #echo $cp,$cp_target
   if [ "$cp" = "$target" ]; then
      if [ $DEBUG = 1 ]; then
         echo "INFO: IPMI $5 CP=$1 at $4"
         disp_completion_code_message $5 $1
      fi
      return $RETRY
   fi
   #echo "enter check_cp_then_action11"
   i=$(($i+1))
   target_old=$target
   target=$(echo $2 | cut -f $i -d ' ')
done

#------------------------------------------------------------------------------------------------------
# retry: check timeout completion code group
#------------------------------------------------------------------------------------------------------
i=1
target_old=''
target=$(echo $3 | cut -f $i -d ' ')
while [ -n "$target" ] && [ "$target" != "$target_old" ]; do
   #echo $cp,$cp_target
   if [ "$cp" = "$target" ]; then
      if [ $DEBUG = 1 ]; then
         echo "INFO: IPMI $5 CP=$1 at $4"
      fi
      wait_n_if_disp_dbgmessage $1
      RETRY=1
      return $RETRY
   fi
   #echo "enter check_cp_then_action21"
   i=$(($i+1))
   target_old=$target
   target=$(echo $3 | cut -f $i -d ' ')
done

#------------------------------------------------------------------------------------------------------
# displaying of generic completion code message
#------------------------------------------------------------------------------------------------------
echo "ERROR: IPMI $5 failed with CP=$1 at $4"
disp_completion_code_message $5 $1
return $RETRY
}
# -------------------------------------------------------------------------------------------------------------
function get_psu_generation
{
# -------------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:D9"
PSU_GENERATION=0
# -------------------------------------------------------------------------------------------------------------
                                    # To check planer type to identify the useage.
if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
   PSU_MUX_ADR_ARRAY="18 1A"
   wMAX=2
elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
   PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
   wMAX=4                           # Up to 4 PSU supports
else
   PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
   wMAX=2                           # Generic PSU
fi
# -------------------------------------------------------------------------------------------------------------
w=1                     # Initialize the While Loop counter to 1, outside the loop
while [ $w -le $wMAX ]; do

   PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array
   PSU_POPULATED_ARRAY[$w]=0
   PSU_GEN_ARRAY[$w]=0

   RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
   while [ $RETRY != 0 ]; do  #Retry Loop

      #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
      x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0c 0xb0 0x$PSU_MUX 0x00 0x04 0x00 0xb0 0x02 0x40 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
      cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

      if [ "$cp" = "00" ]; then        #complete code=0, successful calling
         #format="2E:D9"
         # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
         # -------------------------------------------------------------------------------------------------------------
         # nothing : We just issue a Block_Write command for setting with FRU Data Offset(index) set
         # -------------------------------------------------------------------------------------------------------------
         RETRY=0                             #abort the retry loop
      else
         check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) FRU_Index in get_psu_generation()" $IPMICMD_CAT
         RETRY=$?
      fi
   done                 #Exit the For Loop ($y)

   if [ "$cp" = "00" ]; then
      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0a 0xb0 0x$PSU_MUX 0x00 0x01 0x11 0xb1 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
            #format="2E:D9"
            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            d=$(echo $x | cut -f 19 -d ' ' | cut -f 2 -d 'x')   # a is now equal to byte 6
            d=0x$d
            d=$(($d))

            if [ $d -eq 4 ]; then
               PSU_GENERATION=12
            elif [ $d -eq 5 ]; then
               PSU_GENERATION=13
            else
               PSU_GENERATION=13    #This could treat the PSU is 13G-PSU. After 13G is ready, we need to check this again.
               echo "WARNING: PSU$w generation type($d) is not supported.  Treating as 13G PSU."
            fi

            echo_result_by_op "    PSU$w is a ${PSU_GENERATION}G PSU."
            PSU_GEN_ARRAY[$w]=$PSU_GENERATION
            PSU_POPULATED_ARRAY[$w]=1
            # -------------------------------------------------------------------------------------------------------------
          RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) FRU_Data in get_psu_generation()" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y)
   fi # if [ "$cp" = "00" ]; then

   w=$(($w+1))
done                    #Exit the For Loop ($w)
}

# -------------------------------------------------------------------------------------------------------------
# Get PSU Status Registers
# -------------------------------------------------------------------------------------------------------------
# Please Refer to the Section 14.
#  - Registers: 7A 7B 7C 7D 7E 81 DD ED
# -------------------------------------------------------------------------------------------------------------
function dsp_psu_status_regs
{
IPMICMD_CAT="2E:D9"
# -------------------------------------------------------------------------------------------------------------
# To check planer type to identify the useage.
if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
   PSU_MUX_ADR_ARRAY="18 1A"
   wMAX=2
elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
   PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
   wMAX=4                           # Up to 4 PSU supports
else
   PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
   wMAX=2                           # Generic PSU
fi
PSU_STA_CMD_ARRAY="78 79 7A 7B 7C 7D 7E 81 7F DD ED"
# -------------------------------------------------------------------------------------------------------------
w=1                     # Initialize the While Loop counter to 1, outside the loop
while [ $w -le $wMAX ]; do

   if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ]; then
      PSU_GENERATION=$((PSU_GEN_ARRAY[$w]))
      if [ $PSU_GENERATION = 12 ]; then               # 12G PSU
         zMAX=9                                       # Try up to this number of IPMI command
      else                                            # 13G PSU
         zMAX=11                                      # Try up to this number of IPMI command
      fi

      PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

      z=1                  # Command Serias: Initialize the While Loop Counter to 1, outside the loop
      while [ $z -le $zMAX ]; do     # Perform the commands' loops identified in the For Loop

         PSU_STA_ARRAY[$(((($w-1))*11+$z))]=0 # initialize PSU $w Status Array and memorize later, 1 based	
         PSU_STA_CMD=$(echo $PSU_STA_CMD_ARRAY | cut -f $z -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

         RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
         while [ $RETRY != 0 ]; do  #Retry Loop

            #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
            x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x02 0xb0 0x$PSU_MUX 0x00 0x01 0x01 0x$PSU_STA_CMD | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

            if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
               #format="2E:D9:7A:XX"
               # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
               # -------------------------------------------------------------------------------------------------------------
               d=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # a is now equal to byte 6
               PSU_STA_ARRAY[$(((($w-1))*11+$z))]=$((0x$d))
               if [ $z = 1 ]; then
                  echo_result_by_op "    PSU$w (at 0x$PSU_MUX mux address) Status Registers -"
               fi
               if [ $z != 11 ]; then
                  print_psu_info_by_command $IPMICMD_CAT $PSU_STA_CMD $d $w
               else
                  print_psu_infoEx_by_command $IPMICMD_CAT $PSU_STA_CMD $d $w   # PSU: EDh Register
               fi
               # -------------------------------------------------------------------------------------------------------------
               if [ $z = 10 ]; then
                  OCW321=0x$d                     # keep info for used by coming section
               fi
               # -------------------------------------------------------------------------------------------------------------
               RETRY=0                          #abort the retry loop
            else
               check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) Status Register $PSU_STA_CMD in dsp_psu_status_regs()" $IPMICMD_CAT
               RETRY=$?                            # abort the retry loop if loop-out
               if [ "$cp" = "80" ]; then
                  z=$(($zMAX))                     # abort the psu status commands loop
               fi
            fi
         done              #Exit the For Loop ($y)

         z=$(($z+1))        #Increment the ARRAY index For Loop counter
      done                 #Exit the For Loop ($z)
   fi # if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ]; then

   w=$(($w+1))
done                    #Exit the For Loop ($w)
}

#------------------------------------------------------------------------------------------------------
# Depends on last update with update_count & sift
#------------------------------------------------------------------------------------------------------
#function update_PSU_OCW_COUNTERS
#{
#if [ $SIFT = 1 ] && [ $update_count > 0 ]; then
#   x=$(grep -n 'PSU_OCW_COUNTERS_ARRAY' "/tmp/throttled.txt")
#   y=$(echo $x | cut -f 1 -d ':')               # To find which lines?
#   y=$(($y))
#   y=$(sed -i "${y}d" "/tmp/throttled.txt")     # delete the specific history record, then update with new
#   y=$(sed -i "${y}i PSU_OCW_COUNTERS_ARRAY=$ENV_PSU_OCW_COUNTERS_STR" "/tmp/throttled.txt")
#fi
#}

#function load_PSU_OCW_COUNTERS_if_has
#{
#if [ $SIFT = 1 ]; then
#   x=$(ls /tmp/throttled.txt 2>&1 > /tmp/throttled_temp.txt)
#   x=$(grep "^/tmp/throttled.txt" /tmp/throttled_temp.txt)
#   if [ "$x" != "" ]; then                # history file throttled.txt has found.
#
#      x=$(grep 'PSU_OCW_COUNTERS_ARRAY' "/tmp/throttled.txt")
#      x=$(echo $x | cut -f 2 -d '=')      # data record => 0:0;1:0;2:0;.....
#      x2=$x                               # copy source
#
#      i=2
#      y=$(echo $x2 | cut -f $i -d ';')    # data record => 1:0 [first seperated]
#      while [ "$y" != "" ]; do
#
#         d1=$(echo $y | cut -f 1 -d ':')  # index for array
#         d2=$(echo $y | cut -f 2 -d ':')  # value of element
#         d1=$(($d1))
#         d2=$(($d2))
#         PSU_OCW_COUNTERS_ARRAY[$d1]=$d2
#         i=$(($i+1))
#         x2=$x                            # copy source
#         y=$(echo $x2 | cut -f $i -d ';')   # data record => 1:0;2:0;.....
#      done
#      load_found=1
#   else
#      load_found=0
#   fi # if [ "$x" != "" ]; then
#fi # if [ $SIFT = 1 ]
#}

function disp_psu_piout_max
{
IPMICMD_CAT="2E:D9"
# -------------------------------------------------------------------------------------------------------------
if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
   PSU_MUX_ADR_ARRAY="18 1A"
   wMAX=2
elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
   PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
   wMAX=4                           # Up to 4 PSU supports
else
   PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
   wMAX=2                           # Generic PSU
fi
PSU_REG_ARRAY="DA A6" #DA= TOT_MFR_POUT_MAX, A6= MFR_IOUT_MAX
#------------------------------------------------------------------------------------------------------
b1600W_12_5G=0 #v2.4 1600W 12.5G PSU detection
w=1                     # Initialize the While Loop counter to 1, outside the loop
while [ $w -le $wMAX ]; do

   #px=$((PSU_GEN_ARRAY[$w]))
   #if [ $px > 12 ]; then   # 13G PSU and later

      if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ]; then
         PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array

         z=1
         zMAX=2
         while [ $z -le $zMAX ]; do   #Retry Loop

            PSU_REG=$(echo $PSU_REG_ARRAY | cut -f $z -d ' ')     # Parse the array, and grab the y'th value in the space delimited array

            RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
            while [ $RETRY != 0 ]; do  #Retry Loop

               #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
               x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0xb0 0x$PSU_MUX 0x00 0x01 0x02 0x$PSU_REG | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
               cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

               if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
                  #format="2E:D9"
                  # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                  # -------------------------------------------------------------------------------------------------------------
                  a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
                  b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
                  # -------------------------------------------------------------------------------------------------------------
                  value=0x$b$a
                  value=$(($value&0x7ff))
                  value_exp=0x$b
                  value_exp=$((($value_exp)>>3))
                  if [ $((PSU_GEN_ARRAY[$w])) = 12 ]; then
                     NOMINAL_VOUT=12
                  else
                     NOMINAL_VOUT=12.2
                  fi
                  if [ $z -eq 1 ]; then #DA= TOT_MFR_POUT_MAX
                     POUT_MAX[$w]=$value        # 1 base
                     POUT_EXP_MAX[$w]=$value_exp
                     if [ $value_exp -gt 15 ]; then
                        VALUE_LAST=$(echo $value $value_exp | awk '{printf("%i",($1/(2**(32-$2))))}')
                     else
                        VALUE_LAST=$(echo $value $value_exp | awk '{printf("%i",($1*(2**$2)))}')
                     fi
                     iout=$(echo $VALUE_LAST $NOMINAL_VOUT | awk '{printf("%.3f",($1/$2))}')
                     echo_result_by_op "        PSU$w: Max output = ${iout}A (${VALUE_LAST}W at ${NOMINAL_VOUT}V, 100.0% PSU)"
                  elif [ $z -eq 2 ]; then #A6= MFR_IOUT_MAX
                     IOUT_MAX[$w]=$value        # 1 base
                     IOUT_EXP_MAX[$w]=$value_exp
                     if [ $value_exp -gt 15 ]; then
                        VALUE_LAST=$(echo $value $value_exp | awk '{printf("%.3f",($1/(2**(32-$2))))}')
                     else
                        VALUE_LAST=$(echo $value $value_exp | awk '{printf("%.3f",($1*(2**$2)))}')
                     fi
                     echo_result_by_op "                          (input line dependent, ${VALUE_LAST}A capable)"
                     if [ $VALUE_LAST == "131.000" ]; then #v2.4 1600W 12.5G PSU always report this value no matter high/low line input
                        b1600W_12_5G=1
                     fi
                  fi
                  # -------------------------------------------------------------------------------------------------------------
                  RETRY=0                          # abort the retry loop
               else
                  check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) Status Register $PSU_REG in disp_psu_piout_max()" $IPMICMD_CAT
                  RETRY=$?                            # abort the retry loop if loop-out
                if [ "$cp" = "80" ]; then
                     z=$(($zMAX))                     # abort the psu status commands loop
                fi
               fi
            done              #Exit the For Loop ($y)

            z=$(($z+1))
         done
      fi # if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ]; then

   #fi # if [ $px > 12 ]
   w=$(($w+1))
done                    #Exit the For Loop ($w)
}

#------------------------------------------------------------------------------------------------------
# Check the OCW1,OCW2,OCW3,OCW_IOUT_COUNTER,OCW_CC counter on per PSU.
#------------------------------------------------------------------------------------------------------
function chk_psu_ocw_counter
{
IPMICMD_CAT="2E:D9"
# -------------------------------------------------------------------------------------------------------------
# To check planer type to identify the useage.
if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
   PSU_MUX_ADR_ARRAY="18 1A"
   wMAX=2
elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
   PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
   wMAX=4                           # Up to 4 PSU supports
else
   PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
   wMAX=2                           # Generic PSU
fi
ENV_PSU_OCW_COUNTERS_STR=""
# -------------------------------------------------------------------------------------------------------------
w=1                     # Initialize the While Loop counter to 1, outside the loop
s=1
while [ $w -le $wMAX ]; do

   if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ] && [ $((PSU_GEN_ARRAY[$w])) -gt 12 ]; then

      PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array
      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         if [ $b1600W_12_5G -eq 1 ]; then #v2.4 1600W 12.5G PSU read 5 bytes only. OCW_COUNTER (DEh) Byte 4 Constant Current Counter is not supported.
            x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0a 0xb0 0x$PSU_MUX 0x00 0x01 0x05 0xde | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         else
            x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0a 0xb0 0x$PSU_MUX 0x00 0x01 0x06 0xde | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         fi
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
            #format="2E:D9:7A:XX"
            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 8 -d ' ')
            b=$(echo $x | cut -f 9 -d ' ')
            c=$(echo $x | cut -f 10 -d ' ')
            d=$(echo $x | cut -f 11 -d ' ')
            e=$(echo $x | cut -f 12 -d ' ')
            a=$(($a))      # OCW1
            b=$(($b))      # OCW2
            c=$(($c))      # OCW3
            d=$(($d))      # IOUT_OC_WARNING counter
            e=$(($e))      # Constant Current(CC) counter

            if [ $PSU_OCW_COUNT_CHECK = 0 ]; then              # if this is the first time to read
               PSU_OCW_COUNTERS_ARRAY[$s]=$a                   # this variable is now equal to the decimal value
               PSU_OCW_COUNTERS_ARRAY[$(($s+1))]=$b            # this variable is now equal to the decimal value
               PSU_OCW_COUNTERS_ARRAY[$(($s+2))]=$c            # this variable is now equal to the decimal value
               PSU_OCW_COUNTERS_ARRAY[$(($s+3))]=$d            # this variable is now equal to the decimal value
               PSU_OCW_COUNTERS_ARRAY[$(($s+4))]=$e            # this variable is now equal to the decimal value
            else                                               # This fragment only be executed at second time when [$THRT_COUNT_DIMM_CHECK=1]
               # OCW1 ---------------------------------------------------
               COUNTER=$((PSU_OCW_COUNTERS_ARRAY[$s]))
               if [ $a = $COUNTER ]; then
                  echo_result_by_op "    PSU$w: OCW1 counter unchanged ($a)"
               else
                  echo "**  PSU$w OCW event: OCW1 counter updated (from $COUNTER to $a)"
                  PSU_OCW_COUNTERS_ARRAY[$s]=$a
                  update_count=$(($update_count+1))
               fi
               # OCW2 ---------------------------------------------------
               COUNTER=$((PSU_OCW_COUNTERS_ARRAY[$(($s+1))]))
               if [ $b = $COUNTER ]; then
                  echo_result_by_op "    PSU$w: OCW2 counter unchanged ($b)"
               else
                  echo "**  PSU$w OCW event: OCW2 counter updated (from $COUNTER to $b)"
                  PSU_OCW_COUNTERS_ARRAY[$(($s+1))]=$b
                  update_count=$(($update_count+1))
               fi
               # OCW3 ---------------------------------------------------
               COUNTER=$((PSU_OCW_COUNTERS_ARRAY[$(($s+2))]))
               if [ $c = $COUNTER ]; then
                  echo_result_by_op "    PSU$w: OCW3 counter unchanged ($c)"
               else
                  echo "**  PSU$w OCW event: OCW3 counter updated (from $COUNTER to $c)"
                  PSU_OCW_COUNTERS_ARRAY[$(($s+2))]=$c
                  update_count=$(($update_count+1))
               fi
               # IOUT_OC_WARNING ----------------------------------------
               COUNTER=$((PSU_OCW_COUNTERS_ARRAY[$(($s+3))]))
               if [ $d = $COUNTER ]; then
                  echo_result_by_op "    PSU$w: IOUT_OC_WARNING counter unchanged ($d)"
               else
                  echo "**  PSU$w OCW event: IOUT_OC_WARNING counter updated (from $COUNTER to $d)"
                  PSU_OCW_COUNTERS_ARRAY[$(($s+3))]=$d
                  update_count=$(($update_count+1))
               fi
               # Constant Current(CC) counter ---------------------------
               if [ $b1600W_12_5G -ne 1 ]; then #v2.4 13G PSU only
                   COUNTER=$((PSU_OCW_COUNTERS_ARRAY[$(($s+4))]))
                   if [ $e = $COUNTER ]; then
                      echo_result_by_op "    PSU$w: Constant Current counter unchanged ($e)"
                   else
                      echo "**  PSU$w OCW event: Constant Current(CC) counter updated (from $COUNTER to $e)"
                      PSU_OCW_COUNTERS_ARRAY[$(($s+4))]=$e
                      update_count=$(($update_count+1))
                   fi
               fi
            fi
            if [ $SIFT = 1 ]; then
               ENV_PSU_OCW_COUNTERS_STR=$(echo "${ENV_PSU_OCW_COUNTERS_STR};$s:$a;$(($s+1)):$b;$(($s+2)):$c;$(($s+3)):$d;$(($s+4)):$e;")
            fi
            # -------------------------------------------------------------------------------------------------------------
            RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) DE:OCW_COUNTER Status Register in chk_psu_ocw_counter()" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y
   fi # if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ] && [ $((PSU_GEN_ARRAY[$w])) > 12 ]; then
   s=$(($s+5))
   w=$(($w+1))
done                    #Exit the For Loop ($w)
if [ $SIFT = 1 ]; then
   ENV_PSU_OCW_COUNTERS_STR=$(echo "0:$update_count;$ENV_PSU_OCW_COUNTERS_STR")
   #echo "ENV_PSU_OCW_COUNTERS_STR=$ENV_PSU_OCW_COUNTERS_STR"
fi
}

# -------------------------------------------------------------------------------------------------------------
# NetFn: 0x06, Cmd: 59h, Selector: FEh,
# -------------------------------------------------------------------------------------------------------------
# IPMICmd 0x20 0x06 0x00 0x59 0x00 0xFE 0x00 0x00
# The response data is:
# 0x1c 0x59 0x00 0x11 0x00 0x01 0x00 0x00 0x00
#                                    ^^^^^^^^^
# -------------------------------------------------------------------------------------------------------------
# NetFn: 0x30, Cmd: CEh, SubCmd: 04h, Data9: RapidOn State, Data10: Primary PSU
# -------------------------------------------------------------------------------------------------------------
# IPMICmd 0x20 0x30 0x00 0xCE 0x01 0x04 0x05 0x00 0x00 0x00
# The response data is:
# 0xc4 0xce 0x00 0x04 0x05 0x00 0x00 0x00 0x05 0x00 0x01 0x01 0x00
#                                                   ^^^^ ^^^^
# -------------------------------------------------------------------------------------------------------------
function disp_psu_redundancy
{

    IPMICMD_CAT="06:59"
    RETRY=1 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
    while [ $RETRY != 0 ]; do  #Retry Loop
        #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
        x=$(IPMICmd 0x20 0x06 0x00 0x59 0x00 0xFE 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
        cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
        if [ "$cp" == "00" ]; then                   #complete code=0, successful calling
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 8 -d ' ') #current policy
            if [ "$a" == "0x00" ]; then
                echo_result_by_op "        Redundancy Policy:     Not Redundant"
            elif [ "$a" == "0x01" ]; then
                echo_result_by_op "        Redundancy Policy:     Input Power Redundant"
            elif [ "$a" == "0x02" ]; then
                echo_result_by_op "        Redundancy Policy:     PSU Redundant"
            elif [ "$a" == "0xff" ]; then
                echo_result_by_op "        Redundancy Policy:     N/A"
            else
                echo_result_by_op "        Redundancy Policy:     Reserved"
            fi
            # -------------------------------------------------------------------------------------------------------------
            RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "80 6F" "C0 DF" "Get System Information with Redundancy Policy in disp_psu_redundancy()" $IPMICMD_CAT
            RETRY=$?
         fi
    done

    IPMICMD_CAT="30:CE"
    RETRY=1 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
    while [ $RETRY != 0 ]; do  #Retry Loop
        #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
        x=$(IPMICmd 0x20 0x30 0x00 0xCE 0x01 0x04 0x05 0x00 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
        cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
        if [ "$cp" == "00" ]; then                   #complete code=0, successful calling
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 11 -d ' ')
            b=$(echo $x | cut -f 12 -d ' ')
            if [ "$a" == "0x00" ]; then
                echo_result_by_op "        Hot Spare Mode:        Disabled"
            elif [ "$a" == "0x01" ]; then
                echo_result_by_op "        Hot Spare Mode:        Enabled"
                if [ "$b" == "0x01" ]; then
                    echo_result_by_op "        Primary PSU Selection: PSU 1"
                elif [ "$b" == "0x02" ];then
                    echo_result_by_op "        Primary PSU Selection: PSU 2"
                elif [ "$b" == "0x05" ];then
                    echo_result_by_op "        Primary PSU Selection: PSU 1 and 3"
                elif [ "$b" == "0x0a" ];then
                    echo_result_by_op "        Primary PSU Selection: PSU 2 and 4"
                else
                    echo_result_by_op "        Primary PSU Selection: Unknown"
                fi
            else
                echo_result_by_op "        Hot Spare Mode:        Unknown."
            fi
            # -------------------------------------------------------------------------------------------------------------
            RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "6F FF" "7E C0 DF" "Get PowerThermal Management with subcmd PSU RapidOn in disp_psu_redundancy()" $IPMICMD_CAT
            RETRY=$?
         fi
    done
}

# -------------------------------------------------------------------------------------------------------------
# NetFn: 0x0A, Cmd: 43h, SubCmd: 0100h/0101h/0102h
# -------------------------------------------------------------------------------------------------------------
# Get SMART/CLST Statistics for PSU overcurrent
#   IPMICmd 0x20 0x2E 0x00 0xE1 0x08 0x28 0x43 0x00 0x00 0x00 0x01 0x00 0xFF
#   0xbc 0xe1 0x00 0x01 0x01 0x00 0x01 0xef 0x00 0x00 0x00 0x00 0x8c 0x45 0x01 0x00 0x00 0x00 0x00 0x00 0x00
#   0xbc 0xe1 0x00 0x01 0x01 0x00 0x01 0xef 0x4b 0x3a 0x9c 0x1d 0x96 0x37 0x01 0x00 0x09 0x00 0x3d 0x00 0x3d
# Get SMART/CLST Statistics for PSU overtemperature
#   IPMICmd 0x20 0x2E 0x00 0xE1 0x08 0x28 0x43 0x00 0x00 0x01 0x01 0x00 0xFF
#   0xbc 0xe1 0x00 0x02 0x01 0x01 0x01 0xef 0x00 0x00 0x00 0x00 0x8c 0x45 0x01 0x00 0x00 0x00 0x00 0x00 0x00
#   0xbc 0xe1 0x00 0x02 0x01 0x01 0x01 0xef 0x00 0x00 0x00 0x00 0x96 0x37 0x01 0x00 0x09 0x00 0x00 0x00 0x00
# Get SMART/CLST Statistics for PSU undervoltage
#   IPMICmd 0x20 0x2E 0x00 0xE1 0x08 0x28 0x43 0x00 0x00 0x02 0x01 0x00 0xFF
#   0xbc 0xe1 0x00 0xff 0xff 0x02 0x01 0xef 0x00 0x00 0x00 0x00 0x8c 0x45 0x01 0x00 0x00 0x00 0x00 0x00 0x00
#   0xbc 0xe1 0x00 0xff 0xff 0x02 0x01 0xef 0x00 0x00 0x00 0x00 0x96 0x37 0x01 0x00 0x09 0x00 0x00 0x00 0x00
# -------------------------------------------------------------------------------------------------------------
function display_SmaRT_CLST_status
{
    INDEX_CMD_ARRAY="00 01 02"    #0x00=Get PSU Over Current statistics, 0x01=Get PSU Over Temperature statistics, 0x02=Get PSU Under Voltage statistics
    SMARTCLST_NAME_ARRAY="OverCurrent OverTemperature UnderVoltage"   #SMARTCLST TYPE String arrays
    IPMICMD_CAT="0A:43"
    w=1
    wMAX=3
    echo_result_by_op ""
    echo_result_by_op "    NM SEL Entry - PSU SmaRT & CLST Event Counter:"
    while [ $w -le $wMAX ]; do

        INDEX_CMD=$(echo $INDEX_CMD_ARRAY | cut -f $w -d ' ') # Parse the array, and grab the y'th value in the space delimited array
        SMARTCLST_TYPE=$(echo $SMARTCLST_NAME_ARRAY | cut -f $w -d ' ') # Parse the array, and grab the x'th value in the space delimited array
        RETRY=1
        while [ $RETRY != 0 ]; do  #Retry Loop
            x=$(IPMICmd 0x20 0x2E 0x00 0xE1 0x08 0x28 0x43 0x00 0x00 0x$INDEX_CMD 0x01 0x00 0xFF | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
            if [ "$cp" == "00" ]; then        #complete code=0, successful calling
                a=$(echo $x | cut -f 17 -d ' ' | cut -f 2 -d 'x')
                b=$(echo $x | cut -f 18 -d ' ' | cut -f 2 -d 'x')
                c=$(echo $x | cut -f 19 -d ' ' | cut -f 2 -d 'x')
                d=$(echo $x | cut -f 20 -d ' ' | cut -f 2 -d 'x')
                e=$(echo $x | cut -f 21 -d ' ' | cut -f 2 -d 'x')
                SMARTCLST_Status=$((0x$a))
                SMARTCLST_P_Counter=$((0x$c$b))
                SMARTCLST_Counter=$((0x$e$d))
                if [ "$INDEX_CMD" == "00" ];then #OverCurrent
                    if [ $SMARTCLST_OVERCURRENT_CHECKED -eq 0 ];then # if this is the first time to read
                        SMARTCLST_OverCurrent_ARRAY[0]=$(($SMARTCLST_Status))
                        SMARTCLST_OverCurrent_ARRAY[1]=$(($SMARTCLST_P_Counter))
                        SMARTCLST_OverCurrent_ARRAY[2]=$(($SMARTCLST_Counter))
                        SMARTCLST_OVERCURRENT_CHECKED=1
                    fi
                    if [ $(($SMARTCLST_Status&0x09)) -eq 0 ]; then #bit0 and bit3
                        echo_result_by_op "        - SmaRT&CLST PSU $SMARTCLST_TYPE event has not reported"
                    else
                        echo "        - SmaRT&CLST PSU $SMARTCLST_TYPE event reported"
                    fi
                    if [ $((SMARTCLST_OverCurrent_ARRAY[1])) -eq $SMARTCLST_P_Counter ]; then
                        echo_result_by_op "        - SmaRT&CLST PSU $SMARTCLST_TYPE event counter unchanged ($SMARTCLST_P_Counter)"
                    else
                        echo "        - SmaRT&CLST PSU $SMARTCLST_TYPE event counter updated (from $((SMARTCLST_OverCurrent_ARRAY[1])) to $SMARTCLST_P_Counter)"
                    fi
                    SMARTCLST_OverCurrent_ARRAY[0]=$(($SMARTCLST_Status))
                    SMARTCLST_OverCurrent_ARRAY[1]=$(($SMARTCLST_P_Counter))
                    SMARTCLST_OverCurrent_ARRAY[2]=$(($SMARTCLST_Counter))
                elif [ "$INDEX_CMD" == "01" ]; then #OverTemperature
                    if [ $SMARTCLST_OVERTEMP_CHECKED -eq 0 ]; then # if this is the first time to read
                        SMARTCLST_OverTemp_ARRAY[0]=$(($SMARTCLST_Status))
                        SMARTCLST_OverTemp_ARRAY[1]=$(($SMARTCLST_P_Counter))
                        SMARTCLST_OverTemp_ARRAY[2]=$(($SMARTCLST_Counter))
                        SMARTCLST_OVERTEMP_CHECKED=1
                    fi
                    if [ $(($SMARTCLST_Status&0x12)) -eq 0 ]; then #bit1 and bit4
                        echo_result_by_op "        - SmaRT&CLST PSU $SMARTCLST_TYPE event has not reported"
                    else
                        echo "        - SmaRT&CLST PSU $SMARTCLST_TYPE event reported"
                    fi
                    if [ $((SMARTCLST_OverTemp_ARRAY[1])) -eq $SMARTCLST_P_Counter ]; then
                        echo_result_by_op "        - SmaRT&CLST PSU $SMARTCLST_TYPE event counter unchanged ($SMARTCLST_P_Counter)"
                    else
                        echo "        - SmaRT&CLST PSU $SMARTCLST_TYPE event counter updated (from $((SMARTCLST_OverTemp_ARRAY[1])) to $SMARTCLST_P_Counter)"
                    fi
                    SMARTCLST_OverTemp_ARRAY[0]=$(($SMARTCLST_Status))
                    SMARTCLST_OverTemp_ARRAY[1]=$(($SMARTCLST_P_Counter))
                    SMARTCLST_OverTemp_ARRAY[2]=$(($SMARTCLST_Counter))
                elif [ "$INDEX_CMD" == "02" ]; then #UnderVoltage
                    if [ $SMARTCLST_UNDERVOLT_CHECKED -eq 0 ]; then # if this is the first time to read
                        SMARTCLST_UnderVoltage_ARRAY[0]=$(($SMARTCLST_Status))
                        SMARTCLST_UnderVoltage_ARRAY[1]=$(($SMARTCLST_P_Counter))
                        SMARTCLST_UnderVoltage_ARRAY[2]=$(($SMARTCLST_Counter))
                        SMARTCLST_UNDERVOLT_CHECKED=1
                    fi
                    if [ $(($SMARTCLST_Status&0x24)) -eq 0 ]; then #bit2 and bit5
                        echo_result_by_op "        - SmaRT&CLST PSU $SMARTCLST_TYPE event has not reported"
                    else
                        echo "        - SmaRT&CLST PSU $SMARTCLST_TYPE event reported"
                    fi
                    if [ $((SMARTCLST_UnderVoltage_ARRAY[1])) -eq $SMARTCLST_P_Counter ]; then
                        echo_result_by_op "        - SmaRT&CLST PSU $SMARTCLST_TYPE event counter unchanged ($SMARTCLST_P_Counter)"
                    else
                        echo "        - SmaRT&CLST PSU $SMARTCLST_TYPE event counter updated (from $((SMARTCLST_UnderVoltage_ARRAY[1])) to $SMARTCLST_P_Counter)"
                    fi
                    SMARTCLST_UnderVoltage_ARRAY[0]=$(($SMARTCLST_Status))
                    SMARTCLST_UnderVoltage_ARRAY[1]=$(($SMARTCLST_P_Counter))
                    SMARTCLST_UnderVoltage_ARRAY[2]=$(($SMARTCLST_Counter))
                fi
                RETRY=0                          #abort the retry loop
            else
                check_cp_then_action $cp "C9" "C0 DF" "$SMARTCLST_TYPE in display_SmaRT_CLST_status()" $IPMICMD_CAT
                RETRY=$?
            fi
        done
        w=$(($w+1))
    done
}

# -------------------------------------------------------------------------------------------------------------
#  PSU Register: DCh Address - OCW_SETTING_READ (13G IPMM x00-02) (13G & Equonix ONLY)
# -------------------------------------------------------------------------------------------------------------
# IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0e 0xb0 0x08 0x00 0x03 0x09 0xDC 0x01 0x00 => OCW select option 1
# IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0e 0xb0 0x08 0x00 0x03 0x09 0xDC 0x01 0x01 => OCW select option 2
# IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0e 0xb0 0x08 0x00 0x03 0x09 0xDC 0x01 0x02 => OCW select option 3
# -------------------------------------------------------------------------------------------------------------
function disp_psu_status_dc_reg
{
IPMICMD_CAT="2E:D9"
# -------------------------------------------------------------------------------------------------------------
# To check planer type to identify the useage.
if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
   PSU_MUX_ADR_ARRAY="18 1A"
   wMAX=2
elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
   PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
   wMAX=4                           # Up to 4 PSU supports
else
   PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
   wMAX=2                           # Generic PSU
fi
#------------------------------------------------------------------------------------------------------
w=1                     # Initialize the While Loop counter to 1, outside the loop
while [ $w -le $wMAX ]; do

   if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ] && [ $((PSU_GEN_ARRAY[$w])) -gt 12 ]; then

      PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

      z=0                  # Command Serias: Initialize the While Loop Counter to 0, outside the loop
      zMAX=2               # Try up to this number of IPMI command
      while [ $z -le $zMAX ]; do     # Perform the commands' loops identified in the For Loop

         RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
         while [ $RETRY != 0 ]; do  #Retry Loop

            #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
            x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x0e 0xb0 0x$PSU_MUX 0x00 0x03 0x09 0xDC 0x01 0x0$z | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

            if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
               #format="2E:D9"
               # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
               # -------------------------------------------------------------------------------------------------------------
               aa1=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')   # a is now equal to byte 6
               bb1=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')   # a is now equal to byte 6
               aa2=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
               bb2=$(echo $x | cut -f 11 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
               aa3=$(echo $x | cut -f 12 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
               bb3=$(echo $x | cut -f 13 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
               aa4=$(echo $x | cut -f 14 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
               bb4=$(echo $x | cut -f 15 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
               # -------------------------------------------------------------------------------------------------------------
               value=0x$bb1$aa1        # Linear-16 with Exponent(-2) in Amp
               #value=$(($value))      # To convert it or not, the AMP_LAST is not the different than this.
               AMP_LAST=$(echo $value | awk '{printf("%.3f",($1/4))}')
               # -------------------------------------------------------------------------------------------------------------
               if [ $((PSU_GEN_ARRAY[$w])) = 12 ]; then
                  NOMINAL_VOUT=12
               else
                  NOMINAL_VOUT=12.2
               fi
               pout_max=$((POUT_MAX[$w]))             # 1 base
               pout_exp_max=$((POUT_EXP_MAX[$w]))     # 1 base
               #echo $value,$pout_max, $pout_exp_max
               if [ $pout_exp_max -gt 15 ]; then
                   RATING_VALUE=$(echo $value $pout_max $pout_exp_max $NOMINAL_VOUT | awk '{printf("%.1f",(100*((($1/4)*$4)/($2/(2**(32-$3))))))}')
               else
                   RATING_VALUE=$(echo $value $pout_max $pout_exp_max $NOMINAL_VOUT | awk '{printf("%.1f",(100*((($1/4)*$4)/($2*(2**$3)))))}')
               fi
               # -------------------------------------------------------------------------------------------------------------
               POWER_VALUE=$(echo $value $NOMINAL_VOUT | awk '{printf("%i",($1/4*$2))}')
               # -------------------------------------------------------------------------------------------------------------
               zz=$(($z+1))
               echo_result_by_op "    PSU$w: OCW$zz OCW_SETTING_READ"
               echo_result_by_op "        - Assertion threshold    = ${AMP_LAST}A (${POWER_VALUE}W at ${NOMINAL_VOUT}V, $RATING_VALUE% PSU)"
               # -------------------------------------------------------------------------------------------------------------
               value=0x$bb4$aa4        # Linear-16 with Exponent(-2) in msec
               #value=$(($value))
               AMP_LAST=$(echo $value | awk '{printf("%.3f",($1/4))}')
               POWER_VALUE=$(echo $value $NOMINAL_VOUT | awk '{printf("%i",($1/4*$2))}')
               if [ $pout_exp_max -gt 15 ]; then
                  RATING_VALUE=$(echo $value $pout_max $pout_exp_max $NOMINAL_VOUT | awk '{printf("%.1f",(100*((($1/4)*$4)/($2/(2**(32-$3))))))}')
               else
                   RATING_VALUE=$(echo $value $pout_max $pout_exp_max $NOMINAL_VOUT | awk '{printf("%.1f",(100*((($1/4)*$4)/($2*(2**$3)))))}')
               fi
               echo_result_by_op "        - De-assertion threshold = ${AMP_LAST}A (${POWER_VALUE}W at ${NOMINAL_VOUT}V, $RATING_VALUE% PSU)"
               # -------------------------------------------------------------------------------------------------------------
               value=0x$bb2$aa2           # Linear-11 with Exponent(0) in msec
               #value=$(($value))
               value=$(($value&0x7ff))
               VALUE_LAST=$(echo $value | awk '{printf("%i",$1)}')
               echo_result_by_op "        - Average window length  = $VALUE_LAST msec"
               # -------------------------------------------------------------------------------------------------------------
               value=0x$bb3$aa3        # Linear-11 with Exponent(-2) in msec
               #value=$(($value))
               value=$(($value&0x7ff))
               VALUE_LAST=$(echo $value | awk '{printf("%.0f",($1/4))}')
               echo_result_by_op "        - Sampling Rate at $VALUE_LAST kHz"
               # -------------------------------------------------------------------------------------------------------------
               RETRY=0                          #abort the retry loop
            else
               check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) Status Register DCh in disp_psu_status_dc_reg()" $IPMICMD_CAT
               RETRY=$?
               if [ "$cp" = "80" ]; then
                  z=$(($zMAX))                     # abort the psu status commands loop
               fi
            fi
         done              #Exit the For Loop ($y)

         z=$(($z+1))       #Increment the ARRAY index For Loop counter
      done                 #Exit the For Loop ($z)
   fi # if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ] && [ $((PSU_GEN_ARRAY[$w])) > 12 ]; then
   w=$(($w+1))
done                    #Exit the For Loop ($w)
}

# -------------------------------------------------------------------------------------------------------------
#  PSU Register: E9h Address - PEAK_CURRENT_RECORD (13G IPMM x02-01)
# -------------------------------------------------------------------------------------------------------------
# IPMICmd IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8c $PSUAddress 0x00 0x01 0x05 0xe9
# -------------------------------------------------------------------------------------------------------------
function disp_psu_peak_current_e9_reg
{
IPMICMD_CAT="2E:D9"
# -------------------------------------------------------------------------------------------------------------
# To check planer type to identify the useage.
if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
   PSU_MUX_ADR_ARRAY="18 1A"
   wMAX=2
elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
   PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
   wMAX=4                           # Up to 4 PSU supports
else
   PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
   wMAX=2                           # Generic PSU
fi
#------------------------------------------------------------------------------------------------------
w=1                     # Initialize the While Loop counter to 1, outside the loop
while [ $w -le $wMAX ]; do

   if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ] && [ $((PSU_GEN_ARRAY[$w])) -gt 12 ]; then

      PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

         RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
         while [ $RETRY != 0 ]; do  #Retry Loop

            #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
            x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x8a 0xb0 0x$PSU_MUX 0x00 0x01 0x05 0xe9 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

            if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
               #format="2E:D9"
               # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
               # -------------------------------------------------------------------------------------------------------------
               aa1=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')      # a is now equal to byte 6
               bb1=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')      # a is now equal to byte 6
               aa2=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
               bb2=$(echo $x | cut -f 11 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
               # -------------------------------------------------------------------------------------------------------------
               value=0x$bb1$aa1        # Linear-16 with Exponent(-2) in Amp
               #value=$(($value))      # To convert it or not, the AMP_LAST is not the different than this.
               PEAK_CURRENT=$(echo $value | awk '{printf("%.3f",($1/4))}')
               # -------------------------------------------------------------------------------------------------------------
               value=0x$bb2$aa2        # Linear-16 with Exponent(-2) in msec
               #value=$(($value))
               HISTORICAL_PEAK=$(echo $value | awk '{printf("%.3f",($1/4))}')
               # -------------------------------------------------------------------------------------------------------------
               echo_result_by_op "    PSU$w: Peak Current = ${PEAK_CURRENT}A; Historical Peak Current = ${HISTORICAL_PEAK}A"
               # -------------------------------------------------------------------------------------------------------------
               RETRY=0                          #abort the retry loop
            else
               check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) Status Register E9h in disp_psu_peak_current_e9_reg()" $IPMICMD_CAT
               RETRY=$?
            fi
         done              #Exit the For Loop ($y)

   fi # if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ] && [ $((PSU_GEN_ARRAY[$w])) > 12 ]; then
   w=$(($w+1))
done                    #Exit the For Loop ($w)
}

#------------------------------------------------------------------------------------------------------
# Check ambient sensors
#------------------------------------------------------------------------------------------------------
# IPMICmd 0x20 0x30 0x00 0xCE 0x01 0x0E 0x03 0x00 0x00 0x00 0x00 0x00 0x00 0x00
#                                                           ^^^^
#   - 0x00 (Ambient)
#   - 0x08 (NDC/Ambient)
#   - 0x0F (PSU/Ambient)
#   - 0x12 (Mezz Ambient)
#------------------------------------------------------------------------------------------------------
# ex:
# IPMICmd 0x20 0x30 0x00 0xCE 0x01 0x0E 0x03 0x00 0x00 0x00 0x00 0x00 0x00 0x00
# The response data is:
# 0xc4 0xce 0x00 0x0e 0x03 0x00 0x00 0x00 0x03 0x00 0x17
#                                                   ^^^^ 17h = 23 degC
#------------------------------------------------------------------------------------------------------
function disp_temp_sensors
{
    # Temperature sensors are platform specific. Varying platform-by-platform.
    # Enable system ambient sensor for v2.5. Defer others for future release
    #SENSOR_ARRAY="00 08 0F 12"
    #SENSOR_NAME_ARRAY="System Ambient,NDC Ambient,PSU Ambient,Mezz Ambient"
    #SENSOR_FF_MOD="1 0 0 1"
    #SENSOR_FF_MONO="1 1 1 0"
    #w=1
    #wMAX=4

    SENSOR_ARRAY="00 "
    SENSOR_NAME_ARRAY="System Ambient,"
    SENSOR_FF_MOD="1 "
    SENSOR_FF_MONO="1 "
    w=1
    wMAX=1

    IPMICMD_CAT="30:CE"
    #bMonolithic=0

    #if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x22" ]; then     #13G: 0x20:Monolithic (Note: in case of 12G issue)
    #    bMonolithic=1
    #fi

    while [ $w -le $wMAX ]; do
        SN=$(echo $SENSOR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the w'th value in the space delimited array
        SNN=$(echo $SENSOR_NAME_ARRAY | cut -f $w -d ',')  # Parse the array, and grab the w'th value in the space delimited array
        RETRY=1
        while [ $RETRY != 0 ]; do  #Retry Loop
            x=$(IPMICmd 0x20 0x30 0x00 0xCE 0x01 0x0E 0x03 0x00 0x00 0x00 $SN 0x00 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
            if [ "$cp" = "00" ]; then        #complete code=0, successful calling
                d=$(echo $x | cut -f 11 -d ' ' | cut -f 2 -d 'x')   # a is now equal to byte 6
                d=0x$d
                d=$(($d))
                echo_result_by_op "        $SNN = $d degree C"
                RETRY=0
            else
                check_cp_then_action $cp "6F FF" "7E C0 DF" "Get Power/Thermal mgmt with subcmd GetTemp in disp_temp_sensors()" $IPMICMD_CAT
                RETRY=$?
            fi
        done
        w=$(($w+1))
    done
}

# -------------------------------------------------------------------------------------------------------------
# Section 5&6: Get DIMM TSOD Temp via PCS. Called in [5&6]
# -------------------------------------------------------------------------------------------------------------
# Input:
#   CPU_POPULATED_ARRAY[]
#   DIMM_POPULATED_ARRAY[]
# Output:
#   DIMM_TEMP_ARRAY[]= an integer of the DIMM_TEMP in celcius
# -------------------------------------------------------------------------------------------------------------
function get_dimm_temp_PCS14 #???
{
    CPU_ID_ARRAY="30 31 32 33" #0x30=CPU1, 0x31=CPU2, 0x32=CPU3, 0x33=CPU4
    #INDEX_CMD_ARRAY="0E"       #0x0E=DDR DIMM Digital Thermal Reading
    #INDEX_NAME_ARRAY="DDR_DIMM_Digital_Thermal_Reading"   #RAPL TYPE String arrays
    IPMICMD_CAT="2E:40"

    if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
        INDEX_ARG_ARRAY="00 01 02 03 04 05"
        wMAX=1  # max CPU qty, Initialize the While Loop counter to 1, outside the loop
        argMAX=6  # Try up to this number of argument
    else
        return
    fi

    s=1
    w=1 # CPU index: Initialize the While Loop counter to 1, outside the loop
    while [ $w -le $wMAX ]; do
        if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]; then        # ONLY Populated cpu available, others bypass
            CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')       # Parse the array, and grab the y'th value in the space delimited array
            arg=1 # Arg Series: Initialize the While Loop Counter to 1, outside the loop
            while [ $arg -le $argMAX ]; do # Perform the arg loops identified in the For Loop
                dx=$((DIMM_POPULATED_ARRAY[$(($s-1))]))
                if [ $dx != 0 ]; then   # If dimm is populated
                    INDEX_ARG=$(echo $INDEX_ARG_ARRAY | cut -f $arg -d ' ') # Parse the array, and grab the y'th value in the space delimited array
                    RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                    while [ $RETRY != 0 ]; do  #Retry Loop
                        x=$(IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x0E 0x$INDEX_ARG 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                        cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
                        if [ "$cp" == "00" ]; then        #complete code=0 && FCS=0x40, successful calling
                            cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # c=FCS code, 0x40 means the IPMI command succeeded
                            if [ "$cp2" == "40" ]; then             #complete code=0 && FCS=0x40, successful calling
                                #format="2E:40"
                                # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                                #check RAPL status. Refer to print_PECI_cpu_dram_rapl_sta $z "$x" $w""

                                a=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')  # a is now equal to TSOD Temp
                                a=0x$a
                                DIMM_TEMP_ARRAY[$(($s-1))]=$(($a))

                                RETRY=0        #abort the retry loop
                            elif [ "$cp2" == "80" ] || [ "$cp2" == "81" ]; then
                                check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in get_dimm_temp_PCS14()" "FC"
                                RETRY=$?
                            fi
                        else
                            check_cp_then_action $cp "AC" "A2 C0 DF" "$CPU$w DDR_DIMM_Digital_Thermal_Reading in get_dimm_temp_PCS14()" $IPMICMD_CAT
                            RETRY=$?
                        fi
                    done # end of while [ $RETRY != 0 ]
                fi # end of if [ $dx != 0 ]; then   # If dimm is populated
                s=$(($s+1))
                arg=$(($arg+1))
            done # end of while [ $arg -le $argMAX ]; do
        fi # end of if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]
        w=$(($w+1))
    done # end of while [ $w -le $wMAX ]
}


# -------------------------------------------------------------------------------------------------------------
# Section 8: Get the CPUs' Power_Unit
# -------------------------------------------------------------------------------------------------------------
# The PACKAGE_POWER_SKU_UNIT located at PCI-Config address: 1/10/0/0x8c by IPMICmd 0x20 0x2e 0x00 0x44 .......
# We could use the RdPkgConfig() through by PECI command to get the same information instead of, and
#  the most importance is that we DONOT care the PCI addressing between Sandy/Ivy/Haswell.
#------------------------------------------------------------------------------------------------------
function get_power_time_unit
{
CPU_ID_ARRAY="30 31 32 33"    #0x30=CPU1, 0x31=CPU2, 0x32=CPU3, 0x33=CPU4
IPMICMD_CAT="2E:40"
# -------------------------------------------------------------------------------------------------------------
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) != 0 ]; then  # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')         # Parse the array, and grab the y'th value in the space delimited array

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         x=$(IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x1E 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then           #complete code=0 && FCS=0x40, successful calling
            cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # c=FCS code, 0x40 means the IPMI command succeeded
            if [ "$cp2" = "40" ]; then       #complete code=0 && FCS=0x40, successful calling
               #format="2E:40"
               # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
               # -----------------------------
               a=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x') # a is now equal to Power_Unit which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
               a=0x$a                                       # value equal a string
               POWER_UNIT=$(($a))                           # POWER_UNIT is equal to the lower nibble of the byte returned by the IPMI command
               POWER_UNIT=$(($POWER_UNIT&15))               # mask off the upper nibble
               POWER_UNIT=$((2**$POWER_UNIT))               # set POWER_UNIT to 2^POWER_UNIT
               POWER_UNIT_ARRAY[$(($w-1))]=$(($POWER_UNIT)) # section 13.x to be used
               # -------------------------------------------------------------------------------------------------------------
               a=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')    # a is now equal to Time_Unit which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
               a=0x$a                                       # value equal a string
               TIME_UNIT=$(($a))                            # TIME_UNIT is equal to the lower nibble of the byte returned by the IPMI command
               TIME_UNIT=$(($TIME_UNIT&15))                 # mask off the upper nibble
               TIME_UNIT=$((2**$TIME_UNIT))                 # set TIME_UNIT to 2^TIME_UNIT
               TIME_UNIT_ARRAY[$(($w-1))]=$(($TIME_UNIT))   # section 13.x to be used
               echo_result_by_op "    CPU$w: Power_Unit = 1/$POWER_UNIT Watt, Time_Unit = 1/$TIME_UNIT second" # per CPU
               # -------------------------------------------------------------------------------------------------------------
               RETRY=0                          #abort the retry loop
            elif [ "$cp2" = "80" ] || [ "$cp2" = "81" ]; then
               check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in get_power_time_unit()" "FC"
               RETRY=$?
            fi
         else
            check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in get_power_time_unit()" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y
   fi #if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) != 0 ]; then

   w=$(($w+1))
done                    #Exit the For Loop ($w)
}

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Detect the cpu population by checking of RAPL Power Limit Exceeded Counter. Refer to Section 11.1
#  - Based on PACKAGE_RAPL_PERF_STATUS command
#  - Please refer to section 8.1
# ---------------------------------------------------------------------------------------------------------------------------------------------------
function detect_cpu_populated
{
#echo_result_by_op "    Detect Populated CPU."	
if [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake - CSR cannot be access by 2Eh/44h
    # Greenlow Exception
    # - CSR is not supported on Greenlow. So detect_cpu_populated function won't work.
    # - For single socket CPU platform, CPU is populated as default.
    # - If hard coded is not prefered, Get Host CPU Data(2E/EA) could be used to replace CSR
    #     IPMICmd 20 2e 00 e1 06 b8 ea 57 01 00 00
    IPMICMD_CAT="2E:EA"
    RETRY=1
    CPU_POPULATED_ARRAY[0]=0
    CPU_POPULATED_ARRAY[1]=0
    CPU_POPULATED_ARRAY[2]=0
    CPU_POPULATED_ARRAY[3]=0
    while [ $RETRY -ne 0 ]; do  #Retry Loop
        x=$(IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xb8 0xea 0x57 0x01 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
        cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
        if [ "$cp" == "00" ]; then              # complete code=0, successful calling
            if [ $(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x') != "00" ]; then
                CPU_POPULATED_ARRAY[0]=1
                echo_result_by_op "    CPU1 is populated."
            fi
            return
        else
            check_cp_then_action $cp "81" "C0 DF" "CPU1 in detect_cpu_populated()" $IPMICMD_CAT
            RETRY=$?
        fi
    done
    return
fi
# -------------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"             # This is a space delimited string array that can be parsed, and the characters can be turned into numbers
IPMICMD_CAT="2E:44"
# -------------------------------------------------------------------------------------------------------------
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array
   CPU_POPULATED_ARRAY[$(($w-1))]=0

   RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
   while [ $RETRY != 0 ]; do  #Retry Loop

      #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
      if [ $PROCESSOR_TYPE -lt 7 ]; then # SNB/IVB
        x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x88 0x20 0x15 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
      elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
        x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x88 0x20 0x1F 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
      else #unknown platform
        return
      fi
      cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

      if [ "$cp" = "00" ]; then              # complete code=0, successful calling
         # ----- CPU present -----------------------------------------------------------------------------
         CPU_POPULATED_ARRAY[$(($w-1))]=1    # has populated
         echo_result_by_op "    CPU$w is populated."
         RETRY=0                          #abort the retry loop
      else
          check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in detect_cpu_populated()" $IPMICMD_CAT
         RETRY=$?
      fi
   done              #Exit the For Loop ($y)

   w=$(($w+1))
done
}

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------- Check for DIMM Populated ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------
# Get DIMM Population Information
# ------------------------------------------------------------------------------------------------------
#
# Example commands for CPU1 are listed below:
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x80 0xA0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0xA0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x88 0xA0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x80 0xB0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0xB0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x88 0xB0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x80 0xC0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0xC0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x88 0xC0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x80 0xD0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0xD0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x88 0xD0 0x17 0x00 0x03
#
# The value 0x40 from the commands above can be changed to 0x41 for CPU2, 0x42 for CPU3, or 0x43 for CPU4.
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x80 0xA0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x41 0x80 0xA0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x42 0x80 0xA0 0x17 0x00 0x03
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x43 0x80 0xA0 0x17 0x00 0x03
#
#
# Command: IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x80 0xA0 0x17 0x00 0x03
# Response: (DIMM Not Populated)  0xbc 0x44 0x00 0x57 0x01 0x00 0x00 0x00 0x00 0x00
# Response: (DIMM Populated)      0xbc 0x44 0x00 0x57 0x01 0x00 0x0d 0x50 0x00 0x00
#                                                                    **** 0x50, bit 14, 1=pop, 0=nopop
#
# Byte 7 of the response contains bits 8-15 of the 32-bit register.  Check bit 14, if 1=popped, if 0=nopopped.
#
# --------------------------------------------------------------------------------
function detect_dimm_populated
{
#echo_result_by_op "    Detect Populated DIMM."
# --------------------------------------------------------------------------------
case $PROCESSOR_TYPE in
   1) # SNB-EP
       mMAX=1
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:15=FUN:2:3:4:5=OFS:80:84:88"
       ;;
   3) # IVB-EP w/ 1HA
       mMAX=1
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:15=FUN:2:3:4:5=OFS:80:84:88"
       ;;
   4) # IVB-EP & IVB-EP 4S w/ 2HA
       mMAX=2
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:15=FUN:2:3=OFS:80:84:88=BUS:1=DEV:29=FUN:2:3=OFS:80:84:88"
       ;;
   5) # IVB-EX w/ 2HA
       mMAX=2
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:15=FUN:2:3:4:5=OFS:80:84:88=BUS:1=DEV:29=FUN:2:3:4:5=OFS:80:84:88"
       ;;
   7) # HSX-EP w/ 1HA
       mMAX=1
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:19=FUN:2:3:4:5=OFS:80:84:88"
       ;;
   8) # HSX-EP & HSX-EP 4S w/ 2HA
       mMAX=2
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:19=FUN:2:3=OFS:80:84:88=BUS:1=DEV:22=FUN:2:3=OFS:80:84:88"
       ;;
   9) # HSX-EX w/ 2HA
       mMAX=2
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:19=FUN:2:3:4:5=OFS:80:84:88=BUS:1=DEV:22=FUN:2:3:4:5=OFS:80:84:88"
       ;;
   10) # BDX-EP w/ 1HA #v2.4
       mMAX=1
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:19=FUN:2:3:4:5=OFS:80:84:88"
       ;;
   11) # BDX-EP & BDX-EP 4S w/ 2HA #v2.4
       mMAX=2
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:19=FUN:2:3=OFS:80:84:88=BUS:1=DEV:22=FUN:2:3=OFS:80:84:88"
       ;;
   12) # BDX-EX w/ 2HA #v2.4
       mMAX=2
       CMD_CONFIG="DIMMMTR=BUS:1=DEV:19=FUN:2:3:4:5=OFS:80:84:88=BUS:1=DEV:22=FUN:2:3:4:5=OFS:80:84:88"
       ;;
   13) #KNL Xeon Phi
       mMAX=2
       CMD_CONFIG="DIMMMTR=BUS:2=DEV:9=FUN:2:3:4=OFS:B60=BUS:2=DEV:8=FUN:2:3:4=OFS:B60" #DIMMMTR, Bit[14]. BUS:2=DEV:9 maps to MC0, BUS:2=DEV:8 maps to MC1
       ;;
   20) # Greenlow Skylake-S w/ 1HA #v2.4
       mMAX=1
       CMD_CONFIG=
       echo_result_by_op "    DIMM population detection not supported by Greenlow Skylake/Kabylake CPUs"
       return # Greenlow doesn't support CSR
       ;;
   * )
       echo "ERROR: Internal Error in detect_dimm_populated(). Terminating the script."
       exit 1
esac

# --------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"             #CPU IDs
# --------------------------------------------------------------------------------
s=1
w=1                     # CPU index: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) != 0 ]; then    # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')       # Parse the array, and grab the y'th value in the space delimited array
      s2=1

      m=0
      while [ $m -lt $mMAX ]; do

         offset=$((2+4*$m))
         bus_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         bus_no=$(echo $bus_no_config | cut -f 2 -d ':')
         bus_no=$(($bus_no))                             # string 2 decimal

         offset=$((3+4*$m))
         dev_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         dev_no=$(echo $dev_no_config | cut -f 2 -d ':')
         dev_no=$(($dev_no))                             # string 2 decimal

         PCI_ADR3=$(((($dev_no&0x1f)>>1)|(($bus_no&0x0f)<<4)))
         PCI_ADR4=$(((($bus_no&0xf0)>>4)))

         PCI_ADR3=$(echo $PCI_ADR3 | awk '{printf("%02x",$1)}')
         PCI_ADR4=$(echo $PCI_ADR4 | awk '{printf("%02x",$1)}')

         offset=$((4+4*$m))
         fun_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         offset=$((5+4*$m))
         reg_adr_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')

         v=2
         reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')
         while [ -n "$reg_adr" ]; do

            reg_adr2=0x$reg_adr
            PCI_ADR1=$(($reg_adr2&0x00ff))
            PCI_ADR1=$(echo $PCI_ADR1 | awk '{printf("%02x",$1)}')

            z=2
            fun_no=$(echo $fun_no_config | cut -f $z -d ':')
            while [ -n "$fun_no" ]; do

               fun_no=$(($fun_no))                          # string 2 decimal
               PCI_ADR2=$(((($reg_adr2&0x0f00)>>8)|(($fun_no&7)<<4)|(($dev_no&1)<<7)))
               PCI_ADR2=$(echo $PCI_ADR2 | awk '{printf("%02x",$1)}')

               RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
               while [ $RETRY != 0 ]; do  #Retry Loop

                  #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                  x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x$PCI_ADR1 0x$PCI_ADR2 0x$PCI_ADR3 0x$PCI_ADR4 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                  cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                  if [ "$cp" = "00" ]; then                  #complete code=0, successful calling
                     #format="2E:44:XX" if has
                     # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                     # -------------------------------------------------------------------------------------------------------------
                     a=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')   # a is now equal to byte 6
                     a=0x$a             # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                     b=$(($a&64))      # check bit 6, if set, b=64, and DIMM is populated
                     if [ $b = 64 ]; then
                        DIMM_POPULATED_ARRAY[$(($s-1))]=1   #set populated
                        echo_result_by_op "    DIMM$s2 of CPU$w is populated."
                     else
                        DIMM_POPULATED_ARRAY[$(($s-1))]=0
                        #echo "DIMM$s2 is not Populated!"   #Display: Device no be found. (If needed)
                     fi
                     if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
                        TEMP_LATCH_ARRAY[$(($s-1))]=0x3c       # for TEMPHI/TEMPMIDHI/TEMPMID/TEMPLO Latchbits in temporary used
                     else
                        TEMP_LATCH_ARRAY[$(($s-1))]=0x1c       # for TEMPHI/TEMPMID/TEMPLO Latchbits in temporary used
                     fi
                     # -------------------------------------------------------------------------------------------------------------
                      RETRY=0                          #abort the retry loop
                  else
                       check_cp_then_action $cp "AC" "A2 C0 DF" "DIMM$s2 of CPU$w in detect_dimm_populated()" $IPMICMD_CAT
                     RETRY=$?
                  fi
               done              #Exit the For Loop ($y)
               s2=$(($s2+1))
               s=$(($s+1))
               z=$(($z+1))
               fun_no=$(echo $fun_no_config | cut -f $z -d ':')

            done # while [ -n "$fun_no" ]; do
            v=$(($v+1))
            reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')

         done # while [ -n "$reg_adr" ]; do

         m=$(($m+1))
      done # while [ $h > 1 ]; do

   fi #if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) != 0 ]; then
   w=$(($w+1))

done # while [ $w -le $wMAX ]; do
}

#------------------------------------------------------------------------------------------------------
# CAPID6 Bit29: The second home agent enabled bit.
#------------------------------------------------------------------------------------------------------
function get_haswell_ha2_sku
{
#------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:44"
#------------------------------------------------------------------------------------------------------
RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
while [ $RETRY != 0 ]; do  #Retry Loop

   #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
   x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9C 0x30 0x1F 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
   cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
   if [ "$cp" = "00" ]; then              #complete code=0, successful calling
      #format="2E:44:XX" if has
      #------------------------------------------------------------------------------------------------------
      a=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x') # a is now equal to byte 6
      a=0x$a
      a=$(($a&0x20))

      if [ $a != 0 ]; then
         HA2_SUPPORT=1
         #echo_result_by_op "    CPU supports two Home Agents."
         # PROCESSOR_TYPE will be either 8 (HSX-EP w/ 2 HAs) or 9 (HSX-EX)
      else
         HA2_SUPPORT=0
         #echo_result_by_op "    CPU supports one Home Agent."
      fi
      #------------------------------------------------------------------------------------------------------
      RETRY=0                          #abort the retry loop
   else
      check_cp_then_action $cp "AC" "A2 C0 DF" "Get Home-Agent Information in get_haswell_ha2_sku()" $IPMICMD_CAT
      RETRY=$?
   fi
done                 #Exit the For Loop ($y)
}

function get_ivy_ha2_sku
{
#------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:44"
#------------------------------------------------------------------------------------------------------
RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
while [ $RETRY != 0 ]; do  #Retry Loop

   #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
   x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x94 0x30 0x15 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
   cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
   if [ "$cp" = "00" ]; then              #complete code=0, successful calling
      #format="2E:44:XX" if has
      #------------------------------------------------------------------------------------------------------
      a=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
      a=0x$a
      a=$(($a&0x08))

      if [ $a != 0 ]; then
         HA2_SUPPORT=1
         #echo_result_by_op "    CPU supports two home agents."
         # PROCESSOR_TYPE will be either 4 (IVB-EP w/ 2 HAs) or 5 (IVB-EX)
      else
         HA2_SUPPORT=0
         #echo_result_by_op "    CPU supports one Home Agent."
      fi
      #------------------------------------------------------------------------------------------------------
      RETRY=0                          #abort the retry loop
   else
      check_cp_then_action $cp "AC" "A2 C0 DF" "Get Home-Agent Information in get_ivy_ha2_sku()" $IPMICMD_CAT
      RETRY=$?
   fi
done                 #Exit the For Loop ($y)
}


#------------------------------------------------------------------------------------------------------
# $1: mode: 1:IVY & Sandybridge
#           2:Haswell
#------------------------------------------------------------------------------------------------------
function get_processor_capid0
{
#------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:44"
#------------------------------------------------------------------------------------------------------
PROCESSOR_EX=0
RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
while [ $RETRY != 0 ]; do  #Retry Loop

   #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
   if [ $1 = 1 ]; then  # IVY
      x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0x30 0x15 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
   else                 # Haswell
      x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0x30 0x1F 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
   fi
   cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

   if [ "$cp" = "00" ]; then                  #complete code=0, successful calling
      #format="2E:44:XX" if has
      # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
      # -------------------------------------------------------------------------------------------------------------
      a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
      a=0x$a                # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
      b=$(($a&16))      # bits=[5:0]
      if [ $b != 0 ]; then
         PROCESSOR_EX=1
      fi
      PROCESSOR_CAPID=$(($a))
      # -------------------------------------------------------------------------------------------------------------
      RETRY=0                          #abort the retry loop
   else
      check_cp_then_action $cp "AC" "A2 C0 DF" "Error in get_processor_capid0()" $IPMICMD_CAT
      RETRY=$?
   fi
done              #Exit the For Loop ($y)
}

#------------------------------------------------------------------------------------------------------
# IPMICmd 0x20 0x06 0x00 0x59 0x00 0xd4 0x01 0x00
#                                       ^^^^ cpu index
#------------------------------------------------------------------------------------------------------
#ex:Sandy Bridge: 0x000206d7 = 0xd7 0x06 0x02 0x00 => 00 02 06 d7
#     Ivy Bridge: 0x000306E7                       => 00 03 06 e7
#------------------------------------------------------------------------------------------------------
function get_processor_cpuid
{
#------------------------------------------------------------------------------------------------------
IPMICMD_CAT="06:59"
CAPID_STR=""
PROCESSOR_TYPE_STR=""
#------------------------------------------------------------------------------------------------------
RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
while [ $RETRY != 0 ]; do  #Retry Loop

   #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
   x=$(IPMICmd 0x20 0x06 0x00 0x59 0x00 0xd4 0x01 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
   cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
   if [ "$cp" = "00" ]; then              #complete code=0, successful calling
      #format="06:59:XX" if has
      #------------------------------------------------------------------------------------------------------
      RETRY=0                          #abort the retry loop
   else
      check_cp_then_action $cp "" "C0 DF" "Get processor Information in get_processor_cpuid()" $IPMICMD_CAT
      RETRY=$?
   fi
done                 #Exit the For Loop ($y)
#------------------------------------------------------------------------------------------------------
if [ "$cp" = "00" ]; then              #complete code=0, successful calling

   a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # a is now equal to byte 6
   b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x') # a is now equal to byte 6
   c=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x') # a is now equal to byte 6
   d=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')    # a is now equal to byte 6
   CPUID=$d$c$b$a
   #echo "CPUID=0x$CPUID"
   # ----- $PROCESSOR_TYPE list -----
   # CMD_CONFIG check condifion
   # 0x000206d7(0x000206Dx): 1:SNB-EP, (Not be used: EN/E)
   # ----------------------: 2:N/A
   # 0x000306d7(0x000306Dx): 3:IVY-EP w/ 1HA
   # ----------------------: 4:N/A
   # ----------------------: 5:N/A
   # ----------------------: 6:N/A
   # 0x000406d7(0x000306Fx): 7:HASWELL EP w/ 1HA
   # ----------------------: 8:HASWELL EP w/ 2HAs(4 memory channels)
   # ----------------------: 9:HASWELL EX w/ 2HAs(8 memory channels)
   # 0x000?????(0x0000506E0):10:Skylake DT w/ 1HA (2 memory channels)

   a2=0x$a
   a2=$(($a2&0xf0))
   a2=$(echo $a2 | awk '{printf("%02x",$1)}' | tr '[a-w, y-z]' '[A-W, Y-Z]')

   HA2_SUPPORT=0
   # Sandy Bridge -------------------------------------------------------------
   if [ "$d" = "00" ] && [ "$c" = "02" ] && [ "$b" = "06" ] && [ "$a2" = "D0" ]; then
      PROCESSOR_TYPE=1        # SNB-EP
      PROCESSOR_TYPE_STR="Sandybridge"
      get_processor_capid0 1     # retrieve ivy support status, then return PROCESSOR_EX
      if [ $PROCESSOR_EX = 1 ]; then
         CAPID_STR="EX"
      #else
         #get_ivy_ha2_sku             # Is HomeAgent x 2 supported?
         #if [ $HA2_SUPPORT =1 ]; then
        #   PROCESSOR_TYPE=4     # IVB-EP & IVB-EP 4S w/ 2HA
         #else
         #   PROCESSOR_TYPE=3     # IVB-EP w/ 1HA
         #fi
      fi

   # Ivy Bridge ---------------------------------------------------------------
   elif [ "$d" = "00" ] && [ "$c" = "03" ] && [ "$b" = "06" ] && [ "$a2" = "E0" ]; then
      PROCESSOR_TYPE_STR="Ivybridge"
      get_processor_capid0 1     # retrieve ivy support status, then return PROCESSOR_EX
      if [ $PROCESSOR_EX = 1 ]; then
         PROCESSOR_TYPE=5        # IVB-EX w/ 2HA
         CAPID_STR="EX"
         HA2_SUPPORT=1
      else
         get_ivy_ha2_sku    # Is HomeAgent x 2 supported?
         if [ $HA2_SUPPORT =1 ]; then
           PROCESSOR_TYPE=4     # IVB-EP & IVB-EP 4S w/ 2HA
         else
            PROCESSOR_TYPE=3     # IVB-EP w/ 1HA
         fi
      fi

   # Haswell ------------------------------------------------------------------
   elif [ "$d" = "00" ] && [ "$c" = "03" ] && [ "$b" = "06" ] && [ "$a2" = "F0" ]; then
      PROCESSOR_TYPE_STR="Haswell"
      get_processor_capid0 2     # retrieve hsx support status, then return PROCESSOR_EX
      if [ $PROCESSOR_EX = 1 ]; then
         PROCESSOR_TYPE=9        # HSX-EX w/ 2HA
         CAPID_STR="EX"
      else
         get_haswell_ha2_sku     # Is HomeAgent x 2 supported?
         if [ $HA2_SUPPORT = 1 ]; then
           PROCESSOR_TYPE=8     # HSX-EP & HSX-EP 4S w/ 2HA
         else
            PROCESSOR_TYPE=7     # HSX-EP w/ 1HA
         fi
      fi

   # Broadwell ------------------------------------------------------------------
   # PROCESSOR_TYPE 10, 11, 12, ... and 19 are reserved for Broadwell-EP 1HA, -EP 2HA, -EP 4S (if needed to be different from -EP 2HA) and -EX.
   # Reason: Broadwell should be very similar to Haswell for the registers that throttle.sh cares about.
   elif [ "$d" = "00" ] && [ "$c" = "04" ] && [ "$b" = "06" ] && [ "$a2" = "F0" ]; then #v2.4
      PROCESSOR_TYPE_STR="Broadwell"
      get_processor_capid0 2     # retrieve cpu support status, then return PROCESSOR_EX
      if [ $PROCESSOR_EX = 1 ]; then
         PROCESSOR_TYPE=12        # BDX-EX w/ 2HA
         CAPID_STR="EX"
      else
         get_haswell_ha2_sku     # Is HomeAgent x 2 supported?
         if [ $HA2_SUPPORT = 1 ]; then
           PROCESSOR_TYPE=11     # BDX-EP & BDX-EP 4S w/ 2HA
         else
            PROCESSOR_TYPE=10     # BDX-EP w/ 1HA
         fi
      fi

   # KnightsLanding Xeon-Phi ------------------------------------------------------------------
   elif [ "$d" = "00" ] && [ "$c" = "05" ] && [ "$b" = "06" ] && [ "$a2" = "70" ]; then
        PROCESSOR_TYPE_STR="KnightsLanding"
        PROCESSOR_TYPE=13 #KNL
        CAPID_STR="Phi"
   # Skylake-S ------------------------------------------------------------------ 
   elif [ "$d" = "00" ] && [ "$c" = "05" ] && [ "$b" = "06" ] && [ "$a2" = "E0" ]; then
      PROCESSOR_TYPE_STR="Skylake"
      PROCESSOR_TYPE=20 #v2.4
      CAPID_STR="S"
   # Kabylake-S ------------------------------------------------------------------ 
   elif [ "$d" = "00" ] && [ "$c" = "09" ] && [ "$b" = "06" ] && [ "$a2" = "E0" ]; then
      PROCESSOR_TYPE_STR="Kabylake"
      PROCESSOR_TYPE=20 #v2.6
      CAPID_STR="S"

   # ------------------------------------------------------------------
   else
      PROCESSOR_TYPE=7  # HSX-EP with 1 HA
      PROCESSOR_TYPE_STR="Haswell"
      CAPID_STR="EP"
      HA2_SUPPORT=0
      echo "WARNNING: Unknown processor type.  Treating as Haswell-EP(Processor Type=$PROCESSOR_TYPE) with 1 Home Agent (CPUID=0x$CPUID)"
   fi

   if [ "$CAPID_STR" = "" ]; then
      #capid=$((PROCESSOR_CAPID&31))         # EP 4S
      if [ $(($PROCESSOR_CAPID&8)) != 0 ]; then
         CAPID_STR="EP 4S"
      elif [ $(($PROCESSOR_CAPID&4)) != 0 ]; then
         CAPID_STR="EP"
      elif [ $(($PROCESSOR_CAPID&2)) != 0 ]; then
         CAPID_STR="EN"
      fi
   fi

   if [ $PROCESSOR_TYPE -eq 1 ] || [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
      echo_result_by_op "    Processor Type $PROCESSOR_TYPE:  $PROCESSOR_TYPE_STR-${CAPID_STR} (CPUID=0x$CPUID)"
   elif [ $HA2_SUPPORT = 1 ]; then
      echo_result_by_op "    Processor Type $PROCESSOR_TYPE:  $PROCESSOR_TYPE_STR-${CAPID_STR} with 2 Home Agents (CPUID=0x$CPUID)"
   elif [ $HA2_SUPPORT = 0 ]; then
      echo_result_by_op "    Processor Type $PROCESSOR_TYPE:  $PROCESSOR_TYPE_STR-${CAPID_STR} with 1 Home Agent (CPUID=0x$CPUID)"
   # Unsupported --------------------------------------------------------------
   else
      echo "ERROR: Unsupported processor type (CPUID=$CPUID). Exiting script."
      exit 1
   fi
fi
#------------------------------------------------------------------------------------------------------
}

function get_platform_information
{
x=$(/etc/default/ipmi/getsysid)
y=$(more /tmp/platform_id)
echo_result_by_op "    iDRAC: $x system, Planar Type ID=0x$y "
#------------------------------------------------------------------------------------------------------
# Get Planer Type id
#------------------------------------------------------------------------------------------------------
PLANTYPE1=0x`MemAccess -rb 0x14000003 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
PLANTYPE2=0x`MemAccess -rb 0x14000004 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
x1=$(((($PLANTYPE1))<<4))
x1=$(($x1&0xf0))
x2=$(($PLANTYPE2&0x0f))
x=$(($x1|$x2))
PLANTYPE=$x
#echo_result_by_op "    Planar Type = $PLANTYPE"

if [ $PLANTYPE -ge 80 ] && [ $PLANTYPE -lt 176 ]; then   # Spec 13G range: <= 0x50(80) > 0xb0(178)
   GENERATION=13                             # 13G detected
   # -------------------------------------------------------------------------------------------------------------
   IPMICMD_CAT="30:BD"
   # -------------------------------------------------------------------------------------------------------------
   RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
   while [ $RETRY != 0 ]; do  #Retry Loop

      #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
      x=$(IPMICmd 0x20 0x30 0x00 0xbd | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
      cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

      if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
         #format="30:BD"
         # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
         # -------------------------------------------------------------------------------------------------------------
         d=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')   # a is now equal to byte 6
         GENERATION_INFO=0x$d                # 13G: (IPMI OEM Command Spec. v1.93)
                                             # 0x20: Monolithic, 0x21: Modular
                                             # 0x13: CMC-Stomp PSB, 0x14: CMC Stomp FOB, 0x22: 13G iDRAC DCS/PEC
                                             # 0x15-0x1F: Reserved
         # TBD: 0x18, 0x19 is older definition. This need to be removed.
         if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x10" ]; then     #13G: 0x20:Monolithic (Note: in case of 12G issue)
            echo_result_by_op "    13G Monolithic Detected"
         elif [ $GENERATION_INFO == "0x21" ]  || [ $GENERATION_INFO == "0x11" ]; then  #13G: 0x21:Modular
            echo_result_by_op "    13G Modular Detected"
         elif [ $GENERATION_INFO == "0x22" ]; then  #13G: 0x22:DCS/PEC
            echo_result_by_op "    13G DCS/PEC Detected"
         else
            if [ $GENERATION_INFO == "0x19" ]; then
              echo "WARNNING: Unknown platform type detected (Generation Info = $GENERATION_INFO)."
              GENERATION_INFO=0x21
              echo "          Treating Generation Info as 13G Modular ($GENERATION_INFO)."
            else
              echo "WARNNING: Unknown platform type detected (Generation Info = $GENERATION_INFO)."
              GENERATION_INFO=0x20
              echo "          Treating Generation Info as 13G Monolithic ($GENERATION_INFO)."
            fi
         fi
         RETRY=0                          #abort the retry loop
      else
       check_cp_then_action $cp "" "C0 DF" "Get platform information in get_platform_information()" $IPMICMD_CAT
         RETRY=$?
      fi
   done              #Exit the For Loop ($y)
else
   GENERATION=12                    # We treat 12G Generation as here.
   # -------------------------------------------------------------------------------------------------------------
   IPMICMD_CAT="30:BD"
   # -------------------------------------------------------------------------------------------------------------
   RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
   while [ $RETRY != 0 ]; do  #Retry Loop

      #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
      x=$(IPMICmd 0x20 0x30 0x00 0xbd | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
      cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

      if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
         #format="30:BD"
         # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
         # -------------------------------------------------------------------------------------------------------------
         d=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')   # a is now equal to byte 6
         GENERATION_INFO=0x$d                # 0x10: 12G iDRAC Monolithic, 0x11: 12G iDRAC Modular
         if [ $GENERATION_INFO == "0x10" ]; then         #12G: 0x10:Monolithic, 0x11:Modular
            echo_result_by_op "    12G Monolithic Detected"
         elif [ $GENERATION_INFO == "0x11" ]; then       #12G: 0x10:Monolithic, 0x11:Modular
            echo_result_by_op "    12G Modular Detected"
         else
            GENERATION=13                    # We treat 13G Generation as here.
              echo "WARNNING: Unknown platform type detected (Generation Info = $GENERATION_INFO). Set to default generation on 13G."
              GENERATION_INFO=0x20
              echo "          Treating Generation Info as 13G Monolithic ($GENERATION_INFO)."
         # TBD: 0x22: 13G iDRAC DCS/PEC
         fi
         RETRY=0                          #abort the retry loop
      else
       check_cp_then_action $cp "" "C0 DF" "Get platform information in get_platform_information()" $IPMICMD_CAT
         RETRY=$?
      fi
   done              #Exit the For Loop ($y)
fi
}

function reset_nm_statistics
{
#------------------------------------------------------------------------------------------------------
DOMAIN_ARRAY="00 01 02 03"
IPMICMD_CAT="2E:C7"
# --------------------------------------------------------------------------------
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   DM_ID=$(echo $DOMAIN_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the w'th value in the space delimited array

   RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
   while [ $RETRY != 0 ]; do  #Retry Loop

      #Set z = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
      x=$(IPMICmd 0x20 0x2e 0x00 0xc7 0x57 0x01 0x00 0x00 0x$DM_ID 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')   # Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = DIMM_TEMP if successful
      cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

      if [ "$cp" = "00" ]; then              #complete code=0, successful calling
         RETRY=0     #abort the domain loop
      else
         check_cp_then_action $cp "" "C0 DF" "Reset NM Statistics at Domain $DM_ID in reset_nm_statistics()" $IPMICMD_CAT
         RETRY=$?
      fi
   done              #Exit the For Loop ($y)

   w=$(($w+1))
done
}

function reset_psu_status
{
    IPMICMD_CAT="2E:D9"
    # -------------------------------------------------------------------------------------------------------------
    # To check planer type to identify the useage.
    if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
       PSU_MUX_ADR_ARRAY="18 1A"
       wMAX=2
    elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
       PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
       wMAX=4                           # Up to 4 PSU supports
    else
       PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
       wMAX=2                           # Generic PSU
    fi
    PSU_STA_CMD_ARRAY="78 79 7A 7B 7C 7D 7E 81 7F DD ED"
    # -------------------------------------------------------------------------------------------------------------
    w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
    while [ $w -le $wMAX ]; do
        if [ $((PSU_POPULATED_ARRAY[$w])) -eq 1 ]; then
            PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

            if [ $PSU_GENERATION = 12 ]; then                # 12G PSU
                RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                while [ $RETRY != 0 ]; do  #Retry Loop

                    #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                    x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x00 0xb0 0x$PSU_MUX 0x00 0x01 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                    cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
                    if [ "$cp" == "00" ]; then      #complete code=0, successful calling
                        RETRY=0                          #abort the retry loop
                    else
                        check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) in reset_psu_status()" $IPMICMD_CAT
                        RETRY=$?
                    fi
                done
            else                                             # 13G PSU - change from v3.2 to clear invidual bit from each register            
                for (( z=3; z<11; z++ )) #PSU_STA_CMD_ARRAY="78 79 7A 7B 7C 7D 7E 81 7F DD ED"
                do
                   if [ $((PSU_STA_ARRAY[$(((($w-1))*11+$z))])) -ne 0 ]
                    then
                        RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                        while [ $RETRY != 0 ]; do  #Retry Loop

                            PSU_STA_CMD=$(echo $PSU_STA_CMD_ARRAY | cut -f $z -d ' ')  # Parse the array, and grab the y'th value in the space delimited array
                            clearbit=$(echo $((PSU_STA_ARRAY[$(((($w-1))*11+$z))])) | awk '{printf("%02x",$1)}')
                            x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x04 0xb0 0x$PSU_MUX 0x00 0x02 0x00 0x$PSU_STA_CMD 0x$clearbit | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
                            if [ "$cp" == "00" ]; then      #complete code=0, successful calling
                                RETRY=0                     #abort the retry loop
                            else
                                check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) in reset_psu_status()" $IPMICMD_CAT
                                RETRY=$?
                            fi
                        
                        done              
                    fi
                done                
            fi #end of if [ $PSU_GENERATION = 12 ]; then                # 12G PSU
        fi #end of if [ $((PSU_POPULATED_ARRAY[$w])) -eq 1 ]; then
        w=$(($w+1))
    done
}


########################################################################################################
#
# Display the time of throttling source selected in the request. This is the start timestamp of the 
# first throttling activation as host RTC time.
#
########################################################################################################
function DisplayTimeStamp
{
    time=`date -d @$1 -u`
    echo "$time ($1)"
    #echo "**      Time:      $time (Timestamp: $1)"
}


function get_user_define
{
if [ "$USER_GENERATION" != "" ]; then
   GENERATION=$(($USER_GENERATION))
   echo "Info: User Define with GENERATION=$GENERATION"
fi
if [ "$USER_PROCESSOR_TYPE" != "" ]; then
   PROCESSOR_TYPE=$(($USER_PROCESSOR_TYPE))
   echo "Info: User Define with PROCESSOR_TYPE=$PROCESSOR_TYPE"
fi
if [ "$USER_PSU_GENERATION" != "" ]; then
   PSU_GENERATION=$(($USER_PSU_GENERATION))
   PSU_GEN_ARRAY[1]=$PSU_GENERATION
   PSU_GEN_ARRAY[2]=$PSU_GENERATION
   PSU_GEN_ARRAY[3]=$PSU_GENERATION
   PSU_GEN_ARRAY[4]=$PSU_GENERATION
   echo "Info: User Define with PSU_GENERATION=$PSU_GENERATION"
fi
#if [ "$USER_PSU_MUX_ADR_ARRAY" != "" ]; then          # ex: -USER_PSU_MUX_ADR_ARRAY 0x0c,0x0d,0x0e,0x0f
#   # ....
#fi
}
#------------------------------------------------------------------------------------------------------
# Section 7: pre-Check the DIMM throttling demand counter ( Retrieve the data ONLY )
#------------------------------------------------------------------------------------------------------
function chk_throttle_demand_count
{
#------------------------------------------------------------------------------------------------------
case $PROCESSOR_TYPE in
1) # SNB-EP
   echo_result_by_op "    DIMM Throttling Demand Counters not supported by SandyBridge CPUs"
   return 0
   ;;
3) # IVB-EP w/ 1HA
   mMAX=1
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:16=FUN:4:5:0:1=OFS:198:19a:19c"
   ;;
4) # IVB-EP & IVB-EP 4S w/ 2HA
   mMAX=2
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:16=FUN:4:5=OFS:198:19a:19c=BUS:1=DEV:30=FUN:4:5=OFS:198:19a:19c"
   ;;
5) # IVB-EX w/ 2HA
   mMAX=2
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:16=FUN:4:5:0:1=OFS:198:19a:19c=BUS:1=DEV:30=FUN:4:5:0:1=OFS:198:19a:19c"
   ;;
7) # HSX-EP w/ 1HA
   mMAX=2
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:20=FUN:0:1=OFS:198:19a:19c=BUS:1=DEV:21=FUN:0:1=OFS:198:19a:19c"
   ;;
8) # HSX-EP & HSX-EP 4S w/ 2HA
   mMAX=2
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:20=FUN:0:1=OFS:198:19a:19c=BUS:1=DEV:23=FUN:0:1=OFS:198:19a:19c"
   ;;
9) # HSX-EX w/ 2HA
   mMAX=4
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:20=FUN:0:1=OFS:198:19a:19c=BUS:1=DEV:21=FUN:0:1=OFS:198:19a:19c"
                        "=BUS:1=DEV:23=FUN:0:1=OFS:198:19a:19c=BUS:1=DEV:24=FUN:0:1=OFS:198:19a:19c"
   ;;
10) # BDX-EP w/ 1HA #v2.4
   mMAX=2
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:20=FUN:0:1=OFS:198:19a:19c=BUS:1=DEV:21=FUN:0:1=OFS:198:19a:19c" #thrt_count_dimm Bit[15:0]
   ;;
11) # BDX-EP & BDX-EP 4S w/ 2HA #v2.4
   mMAX=2
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:20=FUN:0:1=OFS:198:19a:19c=BUS:1=DEV:23=FUN:0:1=OFS:198:19a:19c"
   ;;
12) # BDX-EX w/ 2HA #v2.4
   mMAX=4
   CMD_CONFIG="THRT_COUNT=BUS:1=DEV:20=FUN:0:1=OFS:198:19a:19c=BUS:1=DEV:21=FUN:0:1=OFS:198:19a:19c"
                        "=BUS:1=DEV:23=FUN:0:1=OFS:198:19a:19c=BUS:1=DEV:24=FUN:0:1=OFS:198:19a:19c"
   ;;
13) #KNL Xeon Phi
   mMAX=2
   CMD_CONFIG="THRT_COUNT=BUS:2=DEV:9=FUN:2:3:4=OFS:D3C=BUS:2=DEV:8=FUN:2:3:4=OFS:D3C" #THRT_COUNT_CHNL_CFG, Bit[15:0]. BUS:2=DEV:9 maps to MC0, BUS:2=DEV:8 maps to MC1
   ;;
20) # Greenlow Skylake-S w/ 1HA #v2.4
   mMAX=1
   CMD_CONFIG=
   echo_result_by_op "        DIMM Throttling Demand Counters in CSR not supported by Greenlow Skylake/Kabylake CPUs"
   return 0 # Greenlow doesn't support CSR
   ;;
*)
   echo "ERROR: Internal Error in chk_throttle_demand_count(). Terminate the script."
   exit 1
esac

#------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"    # 0x40=CPU1, 0x41=CPU2, 0x42=CPU3, 0x43=CPU4
DEM_CTR_NAME_ARRAY="THRT_COUNT_DIMM_0 THRT_COUNT_DIMM_1 THRT_COUNT_DIMM_2"   #DIMM throttling counters
IPMICMD_CAT="2E:44"
ENV_THRT_COUNT_DIMM_STR=""
# -------------------------------------------------------------------------------------------------------------
update_count=0
s=1
w=1                     # CPU index: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')          # Parse the array, and grab the y'th value in the space delimited array

   if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]; then     # ONLY Populated cpu available, others bypass
      s2=1
      m=0
      while [ $m -lt $mMAX ]; do

         offset=$((2+4*$m))
         bus_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         bus_no=$(echo $bus_no_config | cut -f 2 -d ':')
         bus_no=$(($bus_no))                             # string 2 decimal

         offset=$((3+4*$m))
         dev_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         dev_no=$(echo $dev_no_config | cut -f 2 -d ':')
         dev_no=$(($dev_no))                             # string 2 decimal

         PCI_ADR3=$(((($dev_no&0x1f)>>1)|(($bus_no&0x0f)<<4)))
         PCI_ADR4=$(((($bus_no&0xf0)>>4)))

         PCI_ADR3=$(echo $PCI_ADR3 | awk '{printf("%02x",$1)}')
         PCI_ADR4=$(echo $PCI_ADR4 | awk '{printf("%02x",$1)}')

         offset=$((4+4*$m))
         fun_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         offset=$((5+4*$m))
         reg_adr_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')

         v=2
         reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')
         while [ -n "$reg_adr" ]; do

            reg_adr2=0x$reg_adr
            PCI_ADR1=$(($reg_adr2&0x00ff))
            PCI_ADR1=$(echo $PCI_ADR1 | awk '{printf("%02x",$1)}')

            z=2
            fun_no=$(echo $fun_no_config | cut -f $z -d ':')
            while [ -n "$fun_no" ]; do

               fun_no=$(($fun_no))                          # string 2 decimal
               PCI_ADR2=$(((($reg_adr2&0x0f00)>>8)|(($fun_no&7)<<4)|(($dev_no&1)<<7)))
               PCI_ADR2=$(echo $PCI_ADR2 | awk '{printf("%02x",$1)}')

               if [ $((DIMM_POPULATED_ARRAY[$(($s-1))])) = 1 ]; then    #ONLY Populated available, others bypass

                  RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                  while [ $RETRY != 0 ]; do  #Retry Loop

                     #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                     x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x$PCI_ADR1 0x$PCI_ADR2 0x$PCI_ADR3 0x$PCI_ADR4 0x02 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                     cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                     if [ "$cp" = "00" ]; then                  #complete code=0, successful calling
                        #format="2E:44:XX"
                        # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                        # -----------------------------
                        a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')    # a is now equal to byte 7
                        b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # b is now equal to byte 8

                        COUNTER=0x$b$a                # get the value by return string
                        COUNTER=$(($COUNTER))         # set this variable to the hex value

                        if [ $THRT_COUNT_DIMM_CHECK = 0 ]; then            # if this is the first time to read
                           THRT_COUNT_DIMM_ARRAY[$s]=$COUNTER              # this variable is now equal to the decimal value
                        else                                               # This fragment only be executed at second time when [$THRT_COUNT_DIMM_CHECK=1]
                           COUNTER2=$((THRT_COUNT_DIMM_ARRAY[$s]))
                           if [ $COUNTER = $COUNTER2 ]; then
                              echo_result_by_op "    DIMM$s2 of CPU$w: THRT_COUNT_DIMM CSR counter unchanged ($COUNTER)"
                           else
                              echo "**  DIMM$s2 of CPU$w throttled: THRT_COUNT_DIMM CSR counter updated (from $COUNTER2 to $COUNTER)"
                              #CounterDuration=$(echo $COUNTER $COUNTER2 $((TIME_UNIT_ARRAY[$(($w-1))])) | awk '{printf("%.0f",(($1-$2)/$3*1000))}')
                              #echo "**  DIMM$s2 of CPU$w throttled: THRT_COUNT_DIMM CSR counter updated (from $COUNTER2 to $COUNTER)($CounterDuration msec)"
                              THRT_COUNT_DIMM_ARRAY[$s]=$(($COUNTER))
                              update_count=$(($update_count+1))
                           fi
                        fi
                        if [ $SIFT = 1 ]; then
                           ENV_THRT_COUNT_DIMM_STR=$(echo "${ENV_THRT_COUNT_DIMM_STR}$s:$COUNTER;")
                        fi
                      RETRY=0                          #abort the retry loop
                     else
                        check_cp_then_action $cp "AC" "A2 C0 DF" "DIMM$s2 of CPU$w in chk_throttle_demand_count()" $IPMICMD_CAT
                        RETRY=$?
                     fi
                   done              #Exit the For Loop ($k)

               fi                   # if [ $((DIMM_POPULATED_ARRAY[$(($s2-1))])) = 1 ]; then
               i=$(($i+1))          #Increment the ARRAY index For Loop counter

               s2=$(($s2+1))
               s=$(($s+1))
               z=$(($z+1))
               fun_no=$(echo $fun_no_config | cut -f $z -d ':')

            done # while [ -n "$fun_no" ]; do
            v=$(($v+1))
            reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')

         done # while [ -n "$reg_adr" ]; do

         m=$(($m+1))
      done # while [ $h > 1 ]; do
   fi                      # [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]; then
   w=$(($w+1))
done                       #Exit the For Loop ($w)
if [ $SIFT = 1 ]; then
   ENV_THRT_COUNT_DIMM_STR=$(echo "0:$update_count;$ENV_THRT_COUNT_DIMM_STR;")
   #echo "ENV_THRT_COUNT_DIMM_STR=$ENV_THRT_COUNT_DIMM_STR"
fi
}

#------------------------------------------------------------------------------------------------------
# Depends on last update with update_count & sift
#------------------------------------------------------------------------------------------------------
function update_THRT_COUNT_DIMM
{
if [ $SIFT = 1 ] && [ $update_count > 0 ]; then
   x=$(grep -n 'THRT_COUNT_DIMM_ARRAY' "/tmp/throttled.txt")
   y=$(echo $x | cut -f 1 -d ':')               # To find which lines?
   y=$(($y))
   y=$(sed -i "${y}d" "/tmp/throttled.txt")     # delete the specific history record, then update with new
   y=$(sed -i "${y}i THRT_COUNT_DIMM_ARRAY=$ENV_THRT_COUNT_DIMM_STR" "/tmp/throttled.txt")
fi
}

function load_THRT_COUNT_DIMM_if_has
{
load_found=0
if [ $SIFT = 1 ]; then
   x=$(ls /tmp/throttled.txt 2>&1 > /tmp/throttled_temp.txt)
   x=$(grep "^/tmp/throttled.txt" /tmp/throttled_temp.txt)
   if [ "$x" != "" ]; then               # history file throttled.txt has found.

      x=$(grep 'THRT_COUNT_DIMM_ARRAY' "/tmp/throttled.txt")
      if [ "$x" != "" ]; then               # history file throttled.txt has found.

         x=$(echo $x | cut -f 2 -d '=')      # data record => 0:0;1:0;2:0;.....
         x2=$x                               # copy source

         i=2
         y=$(echo $x2 | cut -f $i -d ';')    # data record => 1:0 [first seperated]
         while [ "$y" != "" ]; do

            d1=$(echo $y | cut -f 1 -d ':')  # index for array
            d2=$(echo $y | cut -f 2 -d ':')  # value of element
            d1=$(($d1))
            d2=$(($d2))
            THRT_COUNT_DIMM_ARRAY[$d1]=$d2
            i=$(($i+1))
            x2=$x                            # copy source
            y=$(echo $x2 | cut -f $i -d ';')   # data record => 1:0;2:0;.....
         done
         load_found=1
      fi # if [ "$x" != "" ]; then
   fi # if [ "$x" != "" ]; then
fi # if [ $SIFT = 1 ]
}

#------------------------------------------------------------------------------------------------------
# Section 8.1: pre-Check the RAPL Power Limit Exceeded Counters ( Retrieve the data ONLY )
#------------------------------------------------------------------------------------------------------
function chk_cpu_rapl_perf_PCS #v2.4 check CPU and DRAM RAPL Performance by PCS indexes. Called in [8.1]
{
    CPU_ID_ARRAY="30 31 32 33" #0x30=CPU1, 0x31=CPU2, 0x32=CPU3, 0x33=CPU4
    INDEX_CMD_ARRAY="08 26"    #0x08=Package_RAPL_Performance_Status_Read, 0x26=DDR_RAPL_Performance_Status
    RAPL_NAME_ARRAY="PACKAGE_RAPL_PERF_STATUS DRAM_RAPL_PERF_STATUS"   #RAPL TYPE String arrays
    IPMICMD_CAT="2E:40"
    ENV_RAPL_PERF_STATUS_STR=""
    # -------------------------------------------------------------------------------------------------------------
    update_count=0
    w=1                     # Initialize the While Loop counter to 1, outside the loop
    wMAX=4
    while [ $w -le $wMAX ]; do
        if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]; then        # ONLY Populated cpu available, others bypass
            CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')       # Parse the array, and grab the y'th value in the space delimited array
            z=1                        # Command Serias: Initialize the While Loop Counter to 1, outside the loop
            zMAX=2                     # Try up to this number of IPMI command
            while [ $z -le $zMAX ]; do # Perform the commands' loops identified in the For Loop
                INDEX_CMD=$(echo $INDEX_CMD_ARRAY | cut -f $z -d ' ') # Parse the array, and grab the y'th value in the space delimited array
                RAPL_TYPE=$(echo $RAPL_NAME_ARRAY | cut -f $z -d ' ') # Parse the array, and grab the x'th value in the space delimited array

                s=$(((($w-1))*3+$z))
                RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                while [ $RETRY != 0 ]; do  #Retry Loop
                    #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                    if [ $INDEX_CMD == "08" ]; then
                        if [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then # Grantley Haswell/Broadwell - Socket Power Limit Indicator Status Read
                            x=$(IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x$INDEX_CMD 0xFF 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                        elif [ $PROCESSOR_TYPE -eq 20 ]; then # Greenlow Skylake-S/Kabylake-S - PACKAGE RAPL Performance Status Read
                            x=$(IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x$INDEX_CMD 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                        else #unknown platform
                            return
                        fi
                    else
                        if [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -le 20 ]; then #v2.4 Grantley Haswell/Broadwell and Greenlow Skylake-S/Kabylake-S
                            x=$(IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x$INDEX_CMD 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                        else #unknown platform
                            return
                        fi
                    fi
                    cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded
                    if [ "$cp" == "00" ]; then        #complete code=0 && FCS=0x40, successful calling
                        cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # c=FCS code, 0x40 means the IPMI command succeeded
                        if [ "$cp2" == "40" ]; then             #complete code=0 && FCS=0x40, successful calling
                            #format="2E:40"
                            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                            #check RAPL status. Refer to print_PECI_cpu_dram_rapl_sta $z "$x" $w""

                            a=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')  # a is now equal to RAPL perf status [ 7 -  0]
                            b=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')  # b is now equal to RAPL perf status [15 -  8]
                            c=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x') # c is now equal to RAPL perf status [23 - 16]
                            d=$(echo $x | cut -f 11 -d ' ' | cut -f 2 -d 'x') # d is now equal to RAPL perf status [31 - 24]
                            COUNTER=0x$d$c$b$a            # get the value by return string: bash support 32bit signed integer
                            COUNTER=$(($COUNTER))         # get the value by return string

                            if [ $RAPL_PERF_STATUS_CHECK = 0 ]; then              # if this is the first time to read
                                RAPL_PERF_STATUS_ARRAY[$s]=$(($COUNTER))     # this variable is now equal to the decimal value))
                            else
                                COUNTER2=$((RAPL_PERF_STATUS_ARRAY[$s]))
                                #CounterDuration=$(echo $CounterDuration | cut -f 1 -d '.')
                                if [ $COUNTER -eq $COUNTER2 ]; then
                                    echo_result_by_op "        CPU$w: $RAPL_TYPE PCS counter unchanged ($COUNTER)"
                                else
                                    if [ $COUNTER2 -gt $COUNTER ]; then # 32b counter overflow
                                        CounterDuration=$(echo $COUNTER $COUNTER2 $((TIME_UNIT_ARRAY[$(($w-1))])) | awk '{printf("%.0f",(($1+(0xFFFFFFFF-$2)+1)/$3*1000))}')
                                    else
                                        CounterDuration=$(echo $COUNTER $COUNTER2 $((TIME_UNIT_ARRAY[$(($w-1))])) | awk '{printf("%.0f",(($1-$2)/$3*1000))}')
                                    fi
                                    #CounterDuration2=$(echo $CounterDuration2 | cut -f 1 -d '.')
                                    echo "**      CPU$w RAPL: $RAPL_TYPE PCS counter updated (from $COUNTER2 to $COUNTER)($CounterDuration msec)" 
                                    RAPL_PERF_STATUS_ARRAY[$s]=$(($COUNTER))
                                    update_count=$(($update_count+1))
                                fi
                            fi
                            if [ $SIFT = 1 ]; then
                                #echo "1:$ENV_RAPL_PERF_STATUS_STR"
                                ENV_RAPL_PERF_STATUS_STR=$(echo "${ENV_RAPL_PERF_STATUS_STR}$s:$COUNTER;")
                                #echo "2:$ENV_RAPL_PERF_STATUS_STR"
                            fi
                            RETRY=0        #abort the retry loop
                        elif [ "$cp2" == "80" ] || [ "$cp2" == "81" ]; then
                            check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in chk_cpu_rapl_perf_PCS()" "FC" #ToDo 0603 double check stop condition
                            RETRY=$?
                        #else #ToDo Need to handle other sub-CC of RdPkgConfig here?
                        #
                        fi
                    else
                        check_cp_then_action $cp "AC" "A2 C0 DF" "$CPU$w $RAPL_TYPE in chk_cpu_rapl_perf_PCS()" $IPMICMD_CAT #ToDo 0603 double check stop condition
                        RETRY=$?
                    fi
                done # end of while [ $RETRY != 0 ]
                z=$(($z+1)) #Increment the ARRAY index For Loop counter
            done # end of while [ $z -le $zMAX ]
        fi # end of if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]
        w=$(($w+1))
    done # end of while [ $w -le $wMAX ]
    if [ $SIFT = 1 ]; then
        ENV_RAPL_PERF_STATUS_STR=$(echo "0:$update_count;$ENV_RAPL_PERF_STATUS_STR")
        #echo "ENV_RAPL_PERF_STATUS_STR=$ENV_RAPL_PERF_STATUS_STR"
    fi
}

function chk_cpu_rapl_perf
{
# -------------------------------------------------------------------------------------------------------------
if [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake - CSR cannot be access by 2Eh/44h
    #PRIMARY_PLANE_RAPL_PERF_STATUS no replacement
    #PACKAGE_RAPL_PERF_STATUS uses PCS Index  8 to replace CSR B=1: D=30: F=2: O=88h (PACKAGE_RAPL_PERF_STATUS)
    #   Use PCS Index 8 (Package RAPL Performance Status Read) to replace CSR B=1: D=30: F=2: O=88h (PACKAGE_RAPL_PERF_STATUS)
    #     IPMICmd 0x20 0x2E 0x00 0x40 0x57 0x01 0x00 0x30 0x05 0x05 0xA1 0x00 0x08 0x00 0x00
    #DRAM_RAPL_PERF_STATUS    uses PCS Index 38 to replace CSR B=1: D=30: F=2: O=D8h (DRAM_RAPL_PERF_STATUS)
    #   Use PCS Index 38 (DDR RAPL Performance Status Read) to replace CSR B=1: D=30: F=2: O=D8h (DRAM_RAPL_PERF_STATUS)
    #     IPMICmd 0x20 0x2E 0x00 0x40 0x57 0x01 0x00 0x30 0x05 0x05 0xA1 0x00 0x26 0x00 0x00
    chk_cpu_rapl_perf_PCS
    return # Greenlow doesn't support CSR
fi
# -------------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"          # This is a space delimited string array that can be parsed, and the characters can be turned into numbers
INDEX_CMD_ARRAY="80 88 D8"          # Read at twice
RAPL_NAME_ARRAY="PRIMARY_PLANE_RAPL_PERF_STATUS PACKAGE_RAPL_PERF_STATUS DRAM_RAPL_PERF_STATUS"    # RAPL name string
                 #Grantley
                   #PACKAGE_RAPL_PERF_STATUS B=1:D=30:F=2:O=88h
                   #DRAM_RAPL_PERF_STATUS    B=1:D=30:F=2:O=D8h
IPMICMD_CAT="2E:44"
ENV_RAPL_PERF_STATUS_STR=""
# -------------------------------------------------------------------------------------------------------------
update_count=0
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array
      if [ $PROCESSOR_TYPE -lt 7 ]; then # SNB/IVB
        v=1
      elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
        v=2                  # Haswell not supports for this command. Skip the first parameter.
      else #unknown platform
        v=0
        w=$wMAX
        continue
      fi
      while [ $v -le 3 ]; do     # Reading with 3 type

         INDEX_CMD=$(echo $INDEX_CMD_ARRAY | cut -f $v -d ' ')   # Parse the array, and grab the y'th value in the space delimited array
         RAPL_TYPE=$(echo $RAPL_NAME_ARRAY | cut -f $v -d ' ')  # Parse the array, and grab the x'th value in the space delimited array
         s=$(((($w-1))*3+$v))

         RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
         while [ $RETRY != 0 ]; do  #Retry Loop

            #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
            if [ $PROCESSOR_TYPE -lt 7 ]; then # SNB/IVB
               x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x$INDEX_CMD 0x20 0x15 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
               # CSR B=1: D=30: F=2: O=88h - PACKAGE_RAPL_PERF_STATUS
               # CSR B=1: D=30: F=2: O=D8h - DRAM_RAPL_PERF_STATUS
               x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x$INDEX_CMD 0x20 0x1F 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            #else #should be filtered out by previous condition checking
            #   x=
            fi
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

            if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
               #format="2E:44"
               # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
               # -------------------------------------------------------------------------------------------------------------
               a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # a is now equal to byte 6
               b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x') # b is now equal to byte 7
               #if [ $v = 1 ]; then
               #   c="00"
               #   d="00"
               #else
                  c=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
                  d=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x') # b is now equal to byte 7
               #fi

               COUNTER=0x$d$c$b$a            # get the value by return string: bash support 32bit signed integer
               COUNTER=$(($COUNTER))         # get the value by return string

               if [ $RAPL_PERF_STATUS_CHECK = 0 ]; then              # if this is the first time to read
                  RAPL_PERF_STATUS_ARRAY[$s]=$(($COUNTER))     # this variable is now equal to the decimal value))
               else                                                  # This fragment only be executed at second time when [$RAPL_PERF_STATUS_CHECK=1]
                  COUNTER2=$((RAPL_PERF_STATUS_ARRAY[$s]))
                  #CounterDuration=$(echo $CounterDuration | cut -f 1 -d '.')
                  if [ $COUNTER -eq $COUNTER2 ] ; then
                     echo_result_by_op "        CPU$w: $RAPL_TYPE CSR counter unchanged ($COUNTER)"
                  else
                     if [ $COUNTER2 -gt $COUNTER ]; then # 32b counter overflow
                        CounterDuration=$(echo $COUNTER $COUNTER2 $((TIME_UNIT_ARRAY[$(($w-1))])) | awk '{printf("%.0f",(($1+(0xFFFFFFFF-$2)+1)/$3*1000))}')
                     else
                        CounterDuration=$(echo $COUNTER $COUNTER2 $((TIME_UNIT_ARRAY[$(($w-1))])) | awk '{printf("%.0f",(($1-$2)/$3*1000))}')
                     fi
                     #CounterDuration2=$(echo $CounterDuration2 | cut -f 1 -d '.')
                     echo "**      CPU$w RAPL: $RAPL_TYPE CSR counter updated (from $COUNTER2 to $COUNTER)($CounterDuration msec)"
                     RAPL_PERF_STATUS_ARRAY[$s]=$(($COUNTER))
                     update_count=$(($update_count+1))
                  fi
               fi
               if [ $SIFT = 1 ]; then
                  #echo "1:$ENV_RAPL_PERF_STATUS_STR"
                  ENV_RAPL_PERF_STATUS_STR=$(echo "${ENV_RAPL_PERF_STATUS_STR}$s:$COUNTER;")
                  #echo "2:$ENV_RAPL_PERF_STATUS_STR"
               fi
              RETRY=0                          #abort the retry loop
            else
                 check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w $RAPL_TYPE in chk_cpu_rapl_perf()" $IPMICMD_CAT
               RETRY=$?
            fi
         done              #Exit the For Loop ($y)
         v=$(($v+1))

      done

   fi # if [ $dx != 0 ]; then      # If cpu is populated
   w=$(($w+1))
done
if [ $SIFT = 1 ]; then
   ENV_RAPL_PERF_STATUS_STR=$(echo "0:$update_count;$ENV_RAPL_PERF_STATUS_STR")
   #echo "ENV_RAPL_PERF_STATUS_STR=$ENV_RAPL_PERF_STATUS_STR"
fi
}

#------------------------------------------------------------------------------------------------------
# Depends on last update with update_count.
#------------------------------------------------------------------------------------------------------
function update_RAPL_PERF_STATUS
{
if [ $SIFT = 1 ] && [ $update_count > 0 ]; then
   x=$(grep -n 'RAPL_PERF_STATUS_ARRAY' "/tmp/throttled.txt")
   y=$(echo $x | cut -f 1 -d ':')               # To find which lines?
   y=$(($y))
   y=$(sed -i "${y}d" "/tmp/throttled.txt")     # delete the specific history record, then update with new
   y=$(sed -i "${y}i RAPL_PERF_STATUS_ARRAY=$ENV_RAPL_PERF_STATUS_STR" "/tmp/throttled.txt")
fi
}

function load_RAPL_PERF_STATUS_if_has
{
load_found=0
if [ $SIFT = 1 ]; then
   x=$(ls /tmp/throttled.txt 2>&1 > /tmp/throttled_temp.txt)
   x=$(grep "^/tmp/throttled.txt" "/tmp/throttled_temp.txt")
   if [ "$x" != "" ]; then               # history file throttled.txt has found.

      x=$(grep 'RAPL_PERF_STATUS_ARRAY' "/tmp/throttled.txt")
      x=$(echo $x | cut -f 2 -d '=')      # data record => 0:0;1:0;2:0;.....
      x2=$x                               # copy source

      i=2
      y=$(echo $x2 | cut -f $i -d ';')    # data record => 1:0 [first seperated]
      while [ "$y" != "" ]; do

         d1=$(echo $y | cut -f 1 -d ':')  # index for array
         d2=$(echo $y | cut -f 2 -d ':')  # value of element
         d1=$(($d1))
         d2=$(($d2))
         RAPL_PERF_STATUS_ARRAY[$d1]=$d2
         echo "RAPL_PERF_STATUS_ARRAY[$d1]=$d2"
         i=$(($i+1))
         x2=$x                            # copy source
         y=$(echo $x2 | cut -f $i -d ';')   # data record => 1:0;2:0;.....
      done
      load_found=1
   fi # if [ "$x" != "" ]; then
fi # if [ $SIFT = 1 ]
}

#------------------------------------------------------------------------------------------------------
# Section 8.2: pre-Check the Check CPU RAPL Limiting Counter ( Retreive the data ONLY )
#------------------------------------------------------------------------------------------------------
function chk_cpu_rapl_limit_counter
{
# -------------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="30 31 32 33"             # This is a space delimited string array that can be parsed, and the characters can be turned into numbers
IPMICMD_CAT="2E:40"
ENV_RAPL_LIMIT_COUNT_STR=""
# -------------------------------------------------------------------------------------------------------------
if [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake doesn't support PCS Index 11 (Socket Power Throttled Duration)
    RAPL_LIMIT_COUNT_ARRAY[1]=$((0x00))
    RAPL_LIMIT_COUNT_ARRAY[2]=$((0x00))
    RAPL_LIMIT_COUNT_ARRAY[3]=$((0x00))
    RAPL_LIMIT_COUNT_ARRAY[4]=$((0x00))
    echo_result_by_op "        CPU1: RAPL PCS Index 11 (Socket Power Throttled Duration) counter is not supported."
    return
fi

update_count=0
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated
      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         x=$(IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x0B 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
            #format="2E:40"
            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # c=FCS code, 0x40 means the IPMI command succeeded
            if [ "$cp2" = "40" ]; then             #complete code=0 && FCS=0x40, successful calling
               a=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x') # a is now equal to byte 7
               b=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x') # b is now equal to byte 8
               c=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')    # a is now equal to byte 9
               d=$(echo $x | cut -f 11 -d ' ' | cut -f 2 -d 'x')    # b is now equal to byte 10

               COUNTER=0x$d$c$b$a         # get the value by return string
               COUNTER=$(($COUNTER))      # set this variable to the hex value

               if [ $RAPL_LIMIT_COUNT_CHECK = 0 ]; then           # if this is the first time to read
                  RAPL_LIMIT_COUNT_ARRAY[$w]=$(($COUNTER)) # this variable is now equal to the decimal value
               else                                               # This fragment only be executed at second time when [$RAPL_LIMIT_COUNT_CHECK=1]
                  COUNTER2=$((RAPL_LIMIT_COUNT_ARRAY[$w]))
                  #CounterDuration=$(echo $CounterDuration | cut -f 1 -d '.')
                  if [ $COUNTER -eq $COUNTER2 ]; then
                     echo_result_by_op "        CPU$w: PCS Index 11 (Socket Power Throttled Duration) counter unchanged ($COUNTER)"
                  else
                     if [ $COUNTER2 -gt $COUNTER ]; then # 32b counter overflow
                        CounterDuration=$(echo $COUNTER $COUNTER2 $((TIME_UNIT_ARRAY[$(($w-1))])) | awk '{printf("%.0f",(($1+(0xFFFFFFFF-$2)+1)/$3*1000))}')
                     else
                        CounterDuration=$(echo $COUNTER $COUNTER2 $((TIME_UNIT_ARRAY[$(($w-1))])) | awk '{printf("%.0f",(($1-$2)/$3*1000))}')
                     fi
                     #CounterDuration2=$(echo $CounterDuration2 | cut -f 1 -d '.')
                     echo "**      CPU$w RAPL: PCS Index 11 (Socket Power Throttled Duration) counter updated (from $COUNTER2 to $COUNTER)($CounterDuration msec)"
                     RAPL_LIMIT_COUNT_ARRAY[$w]=$(($COUNTER))
                     update_count=$(($update_count+1))
                  fi
               fi
               if [ $SIFT = 1 ]; then
                  #echo "1:$ENV_RAPL_LIMIT_COUNT_STR"
                  ENV_RAPL_LIMIT_COUNT_STR=$(echo "${ENV_RAPL_LIMIT_COUNT_STR}$w:$COUNTER;")
                  #echo "2:$ENV_RAPL_LIMIT_COUNT_STR"
               fi
               # -------------------------------------------------------------------------------------------------------------
              RETRY=0                          #abort the retry loop
            elif [ "$cp2" = "80" ] || [ "$cp2" = "81" ]; then
               check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in chk_cpu_rapl_limit_counter()" "FC"
               RETRY=$?
            fi
         else
              check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in chk_cpu_rapl_limit_counter()" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y)

   fi # if [ $dx != 0 ]; then      # If cpu is populated
   w=$(($w+1))

done
if [ $SIFT = 1 ]; then
   ENV_RAPL_LIMIT_COUNT_STR=$(echo "0:$update_count;$ENV_RAPL_LIMIT_COUNT_STR")
fi
}

#------------------------------------------------------------------------------------------------------
# Depends on last update with update_count.
#------------------------------------------------------------------------------------------------------
function update_RAPL_LIMIT_COUNT
{
if [ $SIFT = 1 ] && [ $update_count > 0 ]; then
   x=$(grep -n 'RAPL_LIMIT_COUNT_ARRAY' "/tmp/throttled.txt")
   y=$(echo $x | cut -f 1 -d ':')               # To find which lines?
   y=$(($y))
   y=$(sed -i "${y}d" "/tmp/throttled.txt")     # delete the specific history record, then update with new
   y=$(sed -i "${y}i RAPL_LIMIT_COUNT_ARRAY=$ENV_RAPL_LIMIT_COUNT_STR" "/tmp/throttled.txt")
fi
}

function load_RAPL_LIMIT_COUNT_if_has
{
load_found=0
if [ $SIFT = 1 ]; then
   x=$(ls /tmp/throttled.txt 2>&1 > /tmp/throttled_temp.txt)
   x=$(grep "^/tmp/throttled.txt" "/tmp/throttled_temp.txt")
   if [ "$x" != "" ]; then               # history file throttled.txt has found.

      x=$(grep 'RAPL_LIMIT_COUNT_ARRAY' "/tmp/throttled.txt")
      if [ "$x" != "" ]; then               # history file throttled.txt has found.

         x=$(echo $x | cut -f 2 -d '=')      # data record => 0:0;1:0;2:0;.....
         x2=$x                               # copy source

         i=2
         y=$(echo $x2 | cut -f $i -d ';')    # data record => 1:0 [first seperated]
         while [ "$y" != "" ]; do

            d1=$(echo $y | cut -f 1 -d ':')  # index for array
            d2=$(echo $y | cut -f 2 -d ':')  # value of element
            d1=$(($d1))
            d2=$(($d2))
            RAPL_LIMIT_COUNT_ARRAY[$d1]=$d2
            echo "RAPL_LIMIT_COUNT_ARRAY[$d1]=$d2"
            i=$(($i+1))
            x2=$x                            # copy source
            y=$(echo $x2 | cut -f $i -d ';')   # data record => 1:0;2:0;.....
         done
         load_found=1
      fi
   fi # if [ "$x" != "" ]; then
fi # if [ $SIFT = 1 ]
}

#------------------------------------------------------------------------------------------------------
# Section 8.3:
#------------------------------------------------------------------------------------------------------
# $1:    $z: mode
# $2:    $x: echo message
# $3     $w: cpu index
#------------------------------------------------------------------------------------------------------
function print_CSR_cpu_dram_rapl_sta
{
#------------------------------------------------------------------------------------------------------
RAPL_NAME_ARRAY="RAPL PL1 CSR,RAPL PL2 CSR,DRAM RAPL CSR"   #RAPL TYPE String arrays
RAPLNAME_STR=$(echo $RAPL_NAME_ARRAY | cut -f $1 -d ',')       # Parse the array, and grab the y'th value in the space delimited array
#------------------------------------------------------------------------------------------------------

   #echo "    CPU$3 -"
   # ------------------ CPU RAPL ------------ PL1 --------------
   #
   a=$(echo $2 | cut -f 7 -d ' ' | cut -f 2 -d 'x') # a is now equal to bits [7:0] of the response
   b=$(echo $2 | cut -f 8 -d ' ' | cut -f 2 -d 'x') # b is now equal to bits [7:0] of the response
   c=$(echo $2 | cut -f 9 -d ' ' | cut -f 2 -d 'x') # c is now equal to bits [7:0] of the response
   d=$(echo $2 | cut -f 10 -d ' ' | cut -f 2 -d 'x')    # d is now equal to bits [7:0] of the response
   bb=0x$b
   # ---------------- Start PARSING RAPL DATA ------------------
   # 1).RAPL PL1, 2).RAPL PL2, 3).DRAM RAPL
   # Check bit 7 of byte 2 :
   # -----------------------------------------------------------
   e=$(($bb&128))
   if [ $e != 128 ]; then        # if bit 7 of the 2nd byte, aka bit 15 of the 32-bit register is set, then throttling is occuring
      echo_result_by_op "        CPU$3: $RAPLNAME_STR is disabled."
      PL_CSR_ENABLE_ARRAY[$1-1+($3-1)*3]=0
   else
      echo_result_by_op "        CPU$3: $RAPLNAME_STR is enabled."
      PL_CSR_ENABLE_ARRAY[$1-1+($3-1)*3]=1
   fi # if [ $e = 128 ]
      # -----------------------------------------------------------------------------------
      aa=0x$a
      bb=0x$b
      cc=0x$c
      dd=0x$d
      if [ $DEBUG -eq 1 ]; then
         echo_result_by_op "            - Register Value (MSB First)  = $dd $cc $bb $aa"
      fi
      # -----------------------------------------------------------------------------------
      TIME_UNIT=$((TIME_UNIT_ARRAY[$3-1]))
      LIMIT=$((0x$b$a))             # LIMIT = bits 15:0, need to mask off high bit
      LIMIT=$(($LIMIT&0x7FFF))      # Mask off high bit
      POWER_UNIT=$((POWER_UNIT_ARRAY[$(($3-1))]))
      LIMIT_LAST=$(echo $LIMIT $POWER_UNIT | awk '{printf("%.3f",($1/$2))}')   # in Watts
      echo_result_by_op "            - Power Limit (in CSR)        = $LIMIT_LAST Watts"
      # PL2 for SandyBridge/IvyBridge -----------------------------------
      if [ $1 -eq 2 ] && ([ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x11" ]); then
         # 32-bits of data
         # [31]    Lock bit
         # [30:24] Reserved
         # [23:17] ControlTimeWindow in ms   byte 2: bits 1 - 7: Mask : 0xFE, then shift right one bit
         # [16]    LimitationClamping        Byte 2: bit 0
         # [15]    ControlEnabled            *********** INDICATES THROTTLING Byte 1, bit 7
         # [14:0]  Limit                     Byte 0 and Byte 1 : Mask: 0x7FFF
         # -----------------------------
         #PL2 formula: in 3 - 10 ms.
         VALUE=$(($cc&0xFE))  # mask off bit 0
         VALUE=$(($VALUE>>1))
         VALUE=$(($VALUE))    # turn VALUE into a decimal number
         echo_result_by_op "            - Control Time Window reading = $VALUE milliseconds"
         echo_result_by_op "              (Note: There is a 4ms built-in safety net in CPU)" # IPS6000098137 - PL2 safety net: it enforces 4ms regardless of the PL2 TW. ???
      # PL1 & DRAM & (for Haswell) PL2 -----------------------------
      else
         # 32-bits of data
         # [31:24] Reserved = 0
         # [23:22] ControlTimeWindowFraction = 0   byte2 bits 7, 6 : Mask : 0xC0, shift right 6 bits
         # [21:17] ControlTimeWindowExponent = 8   byte2 bits 1,2,3,4,5 : Mask : 0x3E, then shift right one bit
         # [16]    LimitationClamping = 1          Byte 2: bit 0
         # [15]    ControlEnabled = 1              *********** INDICATES THROTTLING Byte 1, bit 7
         # [14:0]  Limit = 0                       Byte 0 and Byte 1 : Mask: 0x7FFF
         # -----------------------------
         # [21:17] ControlTimeWindowExponent: byte2 bits 1,2,3,4,5 : Mask : 0x3E, then shift right one bit
         CTWE=$(($cc&0x3E))      # mask off bits 7 and 6, and 0
         CTWE=$(($CTWE>>1))
         CTWE=$(($CTWE))         # turn CTWE into a decimal number
         # -----------------------------
         # [23:22] ControlTimeWindowFraction = 0     byte2 bits 7, 6 : Mask : 0xC0, shift right 6 bits
         # PL1 to be in the range 250 mS-40 seconds
         # PL2 to be in the range 3 mS-10 mS
         CTWF=$(($cc&0xc0))      # mask off bits 0-5, and only leave 7 and 6
         CTWF=$(($CTWF>>6))      # Shift right 6 bits
         CTWF=$(($CTWF))         # Turn into a decimal before reporting
         # -----------------------------
         #PL1 formula: (1+0.25*Fraction) * 2[exp(Exponent)]: be within a range of 250 mS-40 seconds.
         #DRAM formula: same with PL1
         TIMESLOT=$(echo $CTWF $CTWE $TIME_UNIT | awk '{printf("%.3f",((1+($1/4))*(2**$2)/$3*1000))}')   # in ms
         echo_result_by_op "            - Control Time Window reading = $TIMESLOT milliseconds"
         if [ $1 -eq 2 ]; then
         echo_result_by_op "              (Note: There is a 4ms built-in safety net in CPU)" # IPS6000098137 - PL2 safety net: it enforces 4ms regardless of the PL2 TW. ???
         fi
      fi
      # -----------------------------
      # [16] LimitationClamping = 1                                         Byte 2, bit 1
      # Check bit 0 of byte 2 :
      e=$(($cc&1))
      echo_result_by_op "            - Limitation Clamping         = $e (1=Set)"
      LOCK=$((($dd&0x80)>>7))
      if [ $1 -eq 2 ]; then
         echo_result_by_op "            - Lock Bit (for PL1 & PL2)    = $LOCK (1=Locked)"
      fi
      if [ $1 -eq 3 ]; then
         echo_result_by_op "            - Lock Bit                    = $LOCK (1=Locked)"
      fi
      # ---------------- END PARSING RAPL DATA ------------------
   #fi # if [ $e = 128 ]
}

function chk_cpu_dram_rapl_by_CSR # called by Pre-Checking for [8.3]
{
# -------------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"          #CPU IDs
if [ $PROCESSOR_TYPE -lt 7 ]; then # SNB/IVB
   PCI_ADR1_ARRAY="E8 EC C8"        #PCI ADDR
   PCI_ADR2_ARRAY="00 00 20"        #PCI ADDR
   PCI_ADR3_ARRAY="15 15 15"        #PCI ADDR
elif [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
   PCI_ADR1_ARRAY="E0 E4 C8"        #PCI ADDR # PACKAGE_RAPL_LIMIT_CFG (PL1) B=1:D=30:F=0:O=E0h
   PCI_ADR2_ARRAY="00 00 00"        #PCI ADDR # PACKAGE_RAPL_LIMIT_CFG (PL2) B=1:D=30:F=0:O=E4h
   PCI_ADR3_ARRAY="1F 1F 1F"        #PCI ADDR # DRAM_PLANE_POWER_LIMIT_CFG   B=1:D=30:F=0:O=C8h
elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
   PCI_ADR1_ARRAY="E8 EC C8"        #PCI ADDR #1: PACKAGE_RAPL_LIMIT (PL1) B=1:D=30:F=0:O=E8h
   PCI_ADR2_ARRAY="00 00 20"        #PCI ADDR #2: PACKAGE_RAPL_LIMIT (PL2) B=1:D=30:F=0:O=ECh
   PCI_ADR3_ARRAY="1F 1F 1F"        #PCI ADDR #3: DRAM_PLANE_POWER_LIMIT   B=1:D=30:F=2:O=C8h
elif [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake - CSR cannot be access by 2Eh/44h
   return
else #unknown platform
   return
fi
IPMICMD_CAT="2E:44"
# -------------------------------------------------------------------------------------------------------------
w=1                     # CPU index: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) != 0 ]; then    # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')          # Parse the array, and grab the y'th value in the space delimited array

      v=1
      vMAX=3
      while [ $v -le $vMAX ]; do     # Perform the commands' loops identified in the For Loop

         PCI_ADR1_ADDR=$(echo $PCI_ADR1_ARRAY | cut -f $v -d ' ')  # Parse the array, and grab the y'th value in the space delimited array
         PCI_ADR2_ADDR=$(echo $PCI_ADR2_ARRAY | cut -f $v -d ' ')  # Parse the array, and grab the y'th value in the space delimited array
         PCI_ADR3_ADDR=$(echo $PCI_ADR3_ARRAY | cut -f $v -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

         RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
         while [ $RETRY != 0 ]; do  #Retry Loop

            #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x$PCI_ADR1_ADDR 0x$PCI_ADR2_ADDR 0x$PCI_ADR3_ADDR 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

            if [ "$cp" = "00" ]; then                  #complete code=0, successful calling
               #format="2E:44:XX" if has
               # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
               # -------------------------------------------------------------------------------------------------------------
               a1=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')    # a is now equal to byte 6
               a2=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # a is now equal to byte 6
               a=0x$a2$a1
               a=$(($a))
               a=$(($a&0x7fff))
               PL_CSR_ARRAY[$v+($w-1)*3]=$a
               print_CSR_cpu_dram_rapl_sta $v "$x" $w
               # -------------------------------------------------------------------------------------------------------------
              RETRY=0                          #abort the retry loop
            else
               check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in chk_cpu_dram_rapl_by_CSR()" $IPMICMD_CAT
               RETRY=$?
            fi
         done              #Exit the For Loop ($y)

         v=$(($v+1))
      done

   fi #if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) != 0 ]; then
   w=$(($w+1))

done                       #Exit the For Loop ($w)
}

#v2.4 Read CPU TDP from PCS and assign to TDP_PCS_ARRAY[], PMAX_PCS_ARRAY[], PMIN_PCS_ARRAY[]. This is called by Pre-Checking [8.3].
function chk_cpu_tdp_pmin_pmax_by_PCS
{
    IPMICMD_CAT="2E:40"
    CPU_ID_ARRAY="30 31 32 33"    #0x30=CPU1, 0x31=CPU2, 0x32=CPU3, 0x33=CPU4
    PCS_INDEX_ARRAY="1C 1D"
    PCS_NAME_ARRAY="PACKAGE_POWER_SKU_LOW PACKAGE_POWER_SKU_HIGH"
    w=1  # CPU0/1/2/3/4: Initialize the While Loop counter to 1, outside the loop
    wMAX=4

    if [ $PROCESSOR_TYPE -gt 20 ]; then #unknown platform
        return
    fi

    while [ $w -le $wMAX ]; do
        if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) == 1 ]; then # ONLY Populated cpu available, others bypass
            CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array
            z=1
            zMAX=2
            while [ $z -le $zMAX ]; do # Perform the commands' loops identified in the For Loop
                PCS_INDEX=$(echo $PCS_INDEX_ARRAY | cut -f $z -d ' ') # Parse the array, and grab the y'th value in the space delimited array
                PCS_TYPE=$(echo $PCS_NAME_ARRAY | cut -f $z -d ' ') # Parse the array, and grab the x'th value in the space delimited array
                RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                while [ $RETRY != 0 ]; do  #Retry Loop
                    #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                    x=$(IPMICmd 0x20 0x2E 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x$PCS_INDEX 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                    cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x')       # c=completion code, 0x00 means the IPMI command succeeded
                    if [ "$cp" == "00" ]; then            # complete code=0, successful calling
                        cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')   # c=FCS code, 0x40 means the IPMI command succeeded
                        if [ "$cp2" == "40" ]; then       # complete code=0 && FCS=0x40, successful calling
                            if [ $z -eq 1 ];then #PACKAGE_POWER_SKU_LOW
                                a=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')  # a is now equal to TDP  which is the  8th byte stored in the value of x.  This value is in string form, not an integer value
                                b=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')  # b is now equal to TDP  which is the  9th byte stored in the value of x.  This value is in string form, not an integer value
                                c=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x') # c is now equal to Pmin which is the 10th byte stored in the value of x.  This value is in string form, not an integer value
                                d=$(echo $x | cut -f 11 -d ' ' | cut -f 2 -d 'x') # d is now equal to Pmin which is the 11th byte stored in the value of x.  This value is in string form, not an integer value
                                TDP=$((0x$b$a))
                                TDP=$(($TDP&0x7fff))
                                PMIN=$((0x$d$c))        # Need to follow up. It always shows 0x0000
                                PMIN=$(($PMIN&0x7fff))
                                TDP_PCS_ARRAY[$(($w-1))]=$TDP
                                PMIN_PCS_ARRAY[$(($w-1))]=$PMIN
                                #POWER_UNIT=$((POWER_UNIT_ARRAY[$(($w-1))]))
                                #TDP=$(($TDP/$POWER_UNIT))
                                #PMIN=$(($PMIN/$POWER_UNIT))
                            elif [ $z -eq 2 ];then #PACKAGE_POWER_SKU_HIGH
                                e=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')  # e is now equal to Pmax which is the  8th byte stored in the value of x.  This value is in string form, not an integer value
                                f=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')  # f is now equal to Pmax which is the  9th byte stored in the value of x.  This value is in string form, not an integer value
                                PMAX2=$((0x$f$e))       # Need to follow up. It always shows 0x0000
                                PMAX2=$(($PMAX2&0x7fff))
                                PMAX_PCS_ARRAY[$(($w-1))]=$PMAX2
                                #POWER_UNIT=$((POWER_UNIT_ARRAY[$(($w-1))]))
                                #PMAX2=$(($PMAX2/$POWER_UNIT))
                            #else
                            fi
                            #echo "    CPU$w: Pmax = $PMAX2, TDP = $TDP, Pmin = $PMIN (Watts). (Pn not available.)"
                            RETRY=0 #abort the retry loop
                        elif [ "$cp2" == "80" ] || [ "$cp2" == "81" ]; then
                            check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in chk_cpu_tdp_pmin_pmax_by_PCS()" "FC"
                            RETRY=$?
                        fi
                    else
                        check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w $PCS_TYPE in chk_cpu_tdp_pmin_pmax_by_PCS()" $IPMICMD_CAT #ToDo 0603 double check stop condition.
                        RETRY=$?
                    fi # end of if [ "$cp" == "00" ]
                done # end of while [ $RETRY != 0 ]; do  #Retry Loop
                z=$(($z+1)) #Increment the ARRAY index For Loop counter
            done
        fi # end of if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) == 1 ]; then
        w=$(($w+1))
    done #end of while [ $w -le $wMAX ]; do
}

#------------------------------------------------------------------------------------------------------
# Section 8.4: pre-Check the CPU ICCMAX Counters by CSR ( Retreive the data ONLY )
#------------------------------------------------------------------------------------------------------
function read_cpu_iccmax_by_CSR
{
# -------------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"             # This is a space delimited string array that can be parsed, and the characters can be turned into numbers
IPMICMD_CAT="2E:44"
ENV_ICCMAX_COUNT_STR=""
# -------------------------------------------------------------------------------------------------------------
if [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake - CSR cannot be accessed by 2Eh/44h
    ICCMAX_LIMIT_ARRAY[1]=$((0x00))
    ICCMAX_LIMIT_ARRAY[2]=$((0x00))
    ICCMAX_LIMIT_ARRAY[3]=$((0x00))
    ICCMAX_LIMIT_ARRAY[4]=$((0x00))
   return
fi
# -------------------------------------------------------------------------------------------------------------

update_count=2          # always TBD
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated
      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop
         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         if [ $PROCESSOR_TYPE -lt 7 ]; then # SNB/IVB
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0xF8 0x00 0x15 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         elif [ $PROCESSOR_TYPE -eq 13 ]; then # KNL VCCP_VR_CURRENT_CONFIG_CFG (B=1:D=30:F=2:O=F0h)
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0xF0 0x20 0x1F 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell VR_CURRENT_CONFIG (CSR B=1:D=30:F=0:O=F8)
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0xF8 0x00 0x1F 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         else #unknown platform
            return
         fi
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
            #format="2E:40"
            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')    # a is now equal to byte 7
            b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # b is now equal to byte 8
            #c=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')   # b is now equal to byte 8
            d=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')   # b is now equal to byte 8

            COUNTER=0x$b$a                      # get the value by return string
            COUNTER=$(($COUNTER&0x1fff))        # set this variable to the hex value, then divide 8 (in 0.125 Amps Unit)
            ICCMAX_LIMIT_ARRAY[$w]=$COUNTER        # this variable is now equal to the decimal value
            ICCMAX_VALUE=$(echo $COUNTER | awk '{printf("%.3f",($1/8))}')
            LOCK=0x$d
            LOCK=$((($LOCK&0x80)>>7))
            echo_result_by_op "        CPU$w: ICCMAX = $ICCMAX_VALUE Amp(s); Lock Bit is $LOCK"
            if [ $SIFT = 1 ]; then
               ENV_ICCMAX_COUNT_STR=$(echo "${ENV_ICCMAX_COUNT_STR}$w:$COUNTER;")
            fi
            # -------------------------------------------------------------------------------------------------------------
            RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in read_cpu_iccmax_by_CSR()" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y)

   fi # if [ $dx != 0 ]; then      # If cpu is populated
   w=$(($w+1))

done
if [ $SIFT = 1 ]; then
   ENV_ICCMAX_COUNT_STR=$(echo "0:$update_count;$ICCMAX_COUNT_STR")
fi
}

#------------------------------------------------------------------------------------------------------
# Depends on last update with update_count.
#------------------------------------------------------------------------------------------------------
function update_CPU_ICCMAX_COUNTER
{
if [ $SIFT = 1 ] && [ $update_count > 0 ]; then
   x=$(grep -n 'ICCMAX_LIMIT_ARRAY' "/tmp/throttled.txt")
   y=$(echo $x | cut -f 1 -d ':')               # To find which lines?
   y=$(($y))
   y=$(sed -i "${y}d" "/tmp/throttled.txt")     # delete the specific history record, then update with new
   y=$(sed -i "${y}i ICCMAX_LIMIT_ARRAY=$ENV_ICCMAX_LIMIT_STR" "/tmp/throttled.txt")
fi
}

function load_CPU_ICCMAX_COUNTER_if_has
{
load_found=0
if [ $SIFT = 1 ]; then
   x=$(ls /tmp/throttled.txt 2>&1 > /tmp/throttled_temp.txt)
   x=$(grep "^/tmp/throttled.txt" /tmp/throttled_temp.txt)
   if [ "$x" != "" ]; then               # history file throttled.txt has found.

      x=$(grep 'ICCMAX_LIMIT_ARRAY' "/tmp/throttled.txt")
      if [ "$x" != "" ]; then               # history file throttled.txt has found.
         x=$(echo $x | cut -f 2 -d '=')      # data record => 0:0;1:0;2:0;.....
         x2=$x                               # copy source

         i=2
         y=$(echo $x2 | cut -f $i -d ';')    # data record => 1:0 [first seperated]
         while [ "$y" != "" ]; do

            d1=$(echo $y | cut -f 1 -d ':')  # index for array
            d2=$(echo $y | cut -f 2 -d ':')  # value of element
            d1=$(($d1))
            d2=$(($d2))
            ICCMAX_LIMIT_ARRAY[$d1]=$d2
            i=$(($i+1))
            x2=$x                            # copy source
            y=$(echo $x2 | cut -f $i -d ';')   # data record => 1:0;2:0;.....
         done
         load_found=1
      fi # if [ "$x" != "" ]; then
   fi # if [ "$x" != "" ]; then
fi # if [ $SIFT = 1 ]
}

#------------------------------------------------------------------------------------------------------
# Section 9.1: Report if NM Activated Policy Found by aboved section
# $1: return by IPMI command
# $2: domain id (in string)
# $3: policy id
# ------------------------------------------------------------------------------------------------------
function disp_NM_policy
{
   # ##################################################################################################################################
   # ##### PERFORM POLICY DATA PARSING HERE, AND THEN INCREMENT THE POLICY ID
   # ##################################################################################################################################
   # -------------------------------------------------------------------------------------------------------------
   # doc#: byte  2,3,4 (count order from cp): Intel Manufacturer ID
   # -------------------------------------------------------------------------------------------------------------
   # response:    0xbc 0xc2 0x00 0x57 0x01 0x00 0x60 0x10 0x01 0x06 0x03 0xe8 0x03 0x00 0x00 0x06 0x03 0x01 0x00
   # resp order:                 4    5    6    7    8    9    10   11   12   13   14   15   16   17   18   19
   # doc# byte order:       1    2    3    4    5    6    7    8    9    10   11   12   13   14   15   16   17 (base on IBL# 434090,pg.54)
   # decod                                      e    f    g    h    i    j    k    l    m    n    o    q    r
   # -------------------------------------------------------------------------------------------------------------
   e=$(echo $1 | cut -f 7 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 6 of z, the first byte of policy ID data
   e=0x$e      # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   f=$(echo $1 | cut -f 8 -d ' ' | cut -f 2 -d 'x') # f is now equal to byte 7 of z, the first byte of policy ID data
   f=0x$f      # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   g=$(echo $1 | cut -f 9 -d ' ' | cut -f 2 -d 'x') # g is now equal to byte 8 of z, the first byte of policy ID data
   g=0x$g      # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   h=$(echo $1 | cut -f 10 -d ' ' | cut -f 2 -d 'x')    # h is now equal to byte 9 of z, the first byte of policy ID data
   #h=0x$h     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   i=$(echo $1 | cut -f 11 -d ' ' | cut -f 2 -d 'x')    # i is now equal to byte 10 of z, the first byte of policy ID data
   #i=0x$i     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   j=$(echo $1 | cut -f 12 -d ' ' | cut -f 2 -d 'x')    # j is now equal to byte 11 of z, the first byte of policy ID data
   #j=0x$j     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   k=$(echo $1 | cut -f 13 -d ' ' | cut -f 2 -d 'x')    # k is now equal to byte 12 of z, the first byte of policy ID data
   #k=0x$k     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   l=$(echo $1 | cut -f 14 -d ' ' | cut -f 2 -d 'x')    # l is now equal to byte 13 of z, the first byte of policy ID data
   #l=0x$l     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   m=$(echo $1 | cut -f 15 -d ' ' | cut -f 2 -d 'x')    # m is now equal to byte 14 of z, the first byte of policy ID data
   #m=0x$m     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   n=$(echo $1 | cut -f 16 -d ' ' | cut -f 2 -d 'x')    # n is now equal to byte 15 of z, the first byte of policy ID data
   #n=0x$n     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   o=$(echo $1 | cut -f 17 -d ' ' | cut -f 2 -d 'x')    # o is now equal to byte 16 of z, the first byte of policy ID data
   #o=0x$o     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   q=$(echo $1 | cut -f 18 -d ' ' | cut -f 2 -d 'x')    # q is now equal to byte 17 of z, the first byte of policy ID data
   #q=0x$q     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   r=$(echo $1 | cut -f 19 -d ' ' | cut -f 2 -d 'x')    # r is now equal to byte 18 of z, the first byte of policy ID data
   #r=0x$r     # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
   dstr=$2 # domain ID string from caller, e.g. 0x01
   pstr=$3 # policy ID string from caller, e.g. 0x04
   ########################## Decode byte e
   b=$(($e&0x0F))          # Mask off the high nibble byte e, and only work with bits [3:0]
   if [ $b = 0 ]           #if the lower nibble of e is 0, then - Domain ID: 0x00 = Entire Platform
   then echo "        - Domain ID: 00 = System"
   elif [ $b = 1 ]      #if the lower nibble of e is 1, then - Domain ID: 0x01 = CPU
   then echo "        - Domain ID: 01 = CPU"
   elif [ $b = 2 ]      #if the lower nibble of e is 2, then - Domain ID: 0x02 = Memory
   then echo "        - Domain ID: 02 = Memory"
   elif [ $b = 3 ]      #if the lower nibble of e is 3, then - Domain ID: 0x03 = Hardware Protection
   then echo "        - Domain ID: 03 = Hardware (PSU output, CMC allocation) Protection"
   elif [ $b = 4 ]
   then echo "        - Domain ID: 04 = High Power I/O Subsystem"
   fi
   #
   y=$(($e&16))
   if [ $y != 0 ]       #if e bit 4 is set, then the Policy is Enabled
   then echo "        - Policy is Enabled"
   else echo "        - Policy is Disabled"
   fi
   #
   y=$(($e&32))
   if [ $y != 0 ]       #if e bit 5 is set, then the per Domain Node Manager policy control is enabled
   then echo "        - Per Domain Node Manager Policy control is Enabled"
   else echo "        - Per Domain Node Manager Policy control is Disabled"
   fi
   #
   y=$(($e&64))
   if [ $y != 0 ]       #if e bit 6 is set, then the Global Node Manager Policy Control is Enabled
   then echo "        - Global Node Manager Policy Control is Enabled"
   else echo "        - Global Node Manager Policy Control is Disabled"
   fi
   #
   y=$(($e&128))
   if [ $y != 0 ]       #if e bit 7 is set, then Policy is Created and Managed by Other Management Client
   then echo "        - This Policy is Created and Managed by Other Management Client"
   else echo "        - This Policy is Not Created and Managed by Other Management Client"
   fi
   ########################## Decode byte f
   y=$(($f&0x0F))          # Mask off the high nibble byte f, and only work with bits [3:0]
   if [ $y = 0 ]           #if the lower nibble of f is 0, then - Policy Trigger Type:  0 - No Policy Trigger, Policy will maintain Power Limit
   then echo "        - Policy Trigger Type:  0 - No Policy Trigger, Policy will maintain Power Limit"
   ptt=0                # set policy trigger type = 0 for use in decoding policy trigger limit for bytes o and n
   elif [ $y = 1 ]      #if the lower nibble of f is 1, then - Policy Trigger Type:  1 - Inlet Temp Limit Policy Trigger in Celsius
   then echo "        - Policy Trigger Type:  1 - Inlet Temp Limit Policy Trigger in Celsius"
   ptt=1                # set policy trigger type = 1 for use in decoding policy trigger limit for bytes o and n
   elif [ $y = 2 ]      #if the lower nibble of f is 2, then - Policy Trigger Type:  2 - Missing Power Reading Timeout in 1/11th of second
   then echo "        - Policy Trigger Type:  2 - Missing Power Reading Timeout in 1/10th of second" #v2.4
   ptt=2                # set policy trigger type = 2 for use in decoding policy trigger limit for bytes o and n
   elif [ $y = 3 ]      #if the lower nibble of f is 3, then - Policy Trigger Type:   3 - Time after host reset Trigger in 1/11th of second
   then echo "        - Policy Trigger Type:  3 - Time after host reset Trigger in 1/10th of second" #v2.4
   ptt=3 # set policy trigger type = 3 for use in decoding policy trigger limit for bytes o and n
   elif [ $y = 4 ]      #if the lower nibble of f is 3, then - Policy Trigger Type:   4 - B oot time policy
   then echo "        - Policy Trigger Type:  4 - Boot time policy"
   ptt=4                # set policy trigger type = 0 for use in decoding policy trigger limit for bytes o and n
   fi
   y=$(($f&0x10))
   if [ $y = 16 ]       #if the bit3 of byte 6 is 1, then - Policy Type:  0 - Power Control Policy. Policy will maintain Power limit.
   then echo "        - Policy Type:  1 - This is a Power Control Policy and it will maintain Power Limit"
   fi
   #
   y=$(($f&0x60))          # Mask off all the bits except [6:5]
   #
   yy=$(($g&2))         # Policy Exception Actions
   if [ $b = 0 ] || [ $b = 1 ]; then      # domain 0 or domain 1
      if [ $y = 0 ] && [ $yy = 0 ]; then
         echo "        - Node Manager is not allowed to use T-States and memory throttling"
      elif [ $y = 32 ]; then
         echo "        - Node Manager is not allowed to use T-States and memory throttling"
      elif [ $y = 0 ] && [ $yy = 2 ]; then
         echo "        - Node Manager is allowed to use T-States and memory throttling"
      elif [ $y = 64 ]; then
         echo "        - Node Manager is allowed to use T-States and memory throttling"
      fi
   elif [ $b = 2 ]; then                  # domain 2
      echo "        - This Policy is in the Memory Domain, and should be set to 0, actual value is = $y"
   fi
   if [ $dstr == "00" ] && [ $pstr == "04" ]; then #Domain ID 0 [System], Policy ID 4 (Safe Power Cap)
    echo "          (For Policy Trigger Type 2, NM ignores this setting and is always allowed to use T-States and memory throttling.)"
   fi
   ########################## Decode byte g
   y=$(($g&1))            # Check bit 0 to see if it is set or not
   if [ $y = 0 ]           #If bit 0 is set, then Policy Exception Actions when Policy Power Limit is exceeded over Correction Time Limit - Send Alert
   then echo "        - Policy Exception Actions when Power Limit is Exceeded : Do Not Send Alert"
   elif [ $y = 1 ]      #If bit 0 is set, then Policy Exception Actions when Policy Power Limit is exceeded over Correction Time Limit - Send Alert
   then echo "        - Policy Exception Actions when Power Limit is Exceeded : Send Alert"
   fi
   #
   y=$(($g&2))            # Check bit 1 to see if it is set or not
   if [ $y = 0 ]           #If bit 1 is set, then Policy Exception Actions when Policy Power Limit is exceeded over Correction Time Limit - Shutdown System
   then echo "        - Policy Exception Actions when Power Limit is Exceeded : Do Not Shutdown System"
   elif [ $y = 1 ]      #If bit 0 is set, then Policy Exception Actions when Policy Power Limit is exceeded over Correction Time Limit - Shutdown System
   then echo "        - Policy Exception Actions when Power Limit is Exceeded : Shutdown System"
   fi
   #
   if [ $b = 0 ]; then  #if the lower nibble of e is 0, then - Domain ID: 0x00 = Entire Platform
      y=$(($g&128))     # Check bit 7 to see if it is set or not
      if [ $y = 0 ]         #If bit 1 is set, then Policy Exception Actions when Policy Power Limit is exceeded over Correction Time Limit - Shutdown System
      then echo "        - Power limiting policy and reporting is based on primary (input) side power domain"
      elif [ $y = 128 ]   #If bit 0 is set, then Policy Exception Actions when Policy Power Limit is exceeded over Correction Time Limit - Shutdown System
      then echo "        - Power limiting policy and reporting is based on secondary (output or DC) side power domain"
      fi
   fi
   yy=$(($f&128))       # Policy Storage Option
   if [ $yy = 0 ]       #If bit 0 is clear, then Persistent storage option set at persistent storage
   then echo "        - Policy Storage Option is persistent storage"
   else                 #If bit 1 is set, the Policy storage option set at volatile memory
        echo "        - Policy Storage Option is volatile memory"
   fi
   ########################## Decode bytes h and i
   y=0x$i$h             # y = hex value of two bytes where i is the MSB byte, and h is the LSB, (IPMI command responses always return in LSB, therefore for human readable it's i h , not h i.
   y=$(($y))            # y = decimal value of y
   if [ $ptt = 0 ] || [ $ptt = 1 ] || [ $ptt = 3 ]; then
      echo "        - Power Limit is = ${y} Watts"
   elif [ $ptt = 2 ]; then
      echo "        - Throttling Level = ${y} %  (100% = max system throttling)"
   elif [ $ptt = 4 ]; then
      boot_mode=$(($y&0x0001))
      if [ $boot_mode != 0 ]; then
         echo "        - Boot system in power-optimized mode during POST"
      else
         echo "        - Boot system in performance-optimized mode during POST"
      fi
      core_disabled=$((($y&0x00fe)>>1))
      echo "        - Number of physical CPU cores to be disabled per CPU socket by BIOS = $core_disabled"
   fi

   ########################## Decode bytes n and o
   y=0x$o$n             # y = hex value of two bytes where o is the MSB byte, and n is the LSB, (IPMI command responses always return in LSB, therefore for human readable it's o n , not n o.
   y=$(($y))            # y = decimal value of y
   #
   if [ $ptt = 0 ]      # if the policy Trigger Limit is 0 - No policy trigger, Policy will maintain Power Limit
   then echo "        - Policy Trigger Limit is = Power Limit = $y Watts"
   elif [ $ptt = 1 ]        # if the policy trigger limit is 1 - Inlet Temp Limit Policy Trigger in Celsius
   then echo "        - Policy Trigger Limit Temperature in Celcius is = $y"
   elif [ $ptt = 2 ]        # if the policy trigger limit is 2 - Missing power reading timeout in 1/11th of second
   then echo "        - Policy Trigger Limit - Time After Host Reset Trigger in 1/11th of second is = $y"
   elif [ $ptt = 3 ]        # if the policy trigger limit is 3 - Time after host reset Trigger in 1/11th of second
   then echo "        - Policy Trigger Limit - Time for BMC to send NM Set Event Receiver after Host Reset in 1/11th of second is = $y"
   elif [ $ptt = 4 ]        # if the policy trigger limit is 4 - Boot time policy
   then echo "        - Policy Trigger Limit is set to 0 for Boot Time Policy, the actual value is = $y"
   fi                   # [ptt=4]
   ########################## Decode bytes j, k, l, m
   y=0x$m$l$k$j         # y = 4 bytes in MSB order, which is reverse from the LSB IPMI command response
   y=$(($y))            # y = decimal value of y
   echo "        - Correction Time Limit : Max time before NM Implements corrective Actions is = $y ms"
   ########################## Decode bytes q and r
   y=0x$r$q             # y = hex value of two bytes where r is the MSB byte, and q is the LSB, (IPMI command responses always return in LSB, therefore for human readable it's r q , not q r.
   y=$(($y))            # y = decimal value of y
   echo "        - Statistics Reporting Period is = $y seconds"
   # ########################### Completed parsing the policy data
}

#------------------------------------------------------------------------------------------------------
# Section 9.1: Report if NM Activated Policy Found by aboved section
# $1: domain id
# $2: policy id
# ------------------------------------------------------------------------------------------------------
function report_activated_NM_policy
{
IPMICMD_CAT="2E:C2"
# --------------------------------------------------------------------------------
RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
while [ $RETRY != 0 ]; do  #Retry Loop

   zz=$(IPMICmd 0x20 0x2e 0x00 0xc2 0x57 0x01 0x00 0x$1 0x$2 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
   cpz=$(echo $zz | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

   #d3=$(($1))
   #p3=$(($2))
   if [ "$cpz" = "00" ]
      then              #complete code=0, successful calling
      #format="2E:C2:XX"
      # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
      # -------------------------------------------------------------------------------------------------------------
      #echo " "
      #echo "    Throttling NM Policy:  Domain ID = $d3, Policy ID = $p3"
      # ##################################################################################################################################
      # ##### PERFORM POLICY DATA PARSING HERE, AND THEN INCREMENT THE POLICY ID
      # ##################################################################################################################################
      disp_NM_policy "$zz" "$1" "$2"
      RETRY=0           # abort the loop
      # -------------------------------------------------------------------------------------------------------------
   else
       check_cp_then_action $cpz "" "C0 DF" "Check NM policy in report_activated_NM_policy()" $IPMICMD_CAT
      RETRY=$?
   fi
done #while [ $r -le $RETRY ]; do   #Retry Loop
}

function disp_help_message
{
echo " "
echo "throttle.sh v$THROTTLE_VER ($THROTTLE_BUILD_DATE) help:"
echo " "
echo "Note:  Full functionality requires iDRAC Enterprise License and"
echo "       system main power."
echo " "
echo "This script displays status of various indicators with power limiting"
echo "implications. Lines with leading \"**\" indicates current or past events"
echo "depending on the indicators. The script is divided into these sections:"
echo "     1  : Initialization (once only) and ambient inlet temperature sensor"
echo "     2  : iDRAC XBus memory-mapped throttle latch bits and GPIO"
echo "     3  : CPU thermal status sensors"
echo "     4  : CPU MEMHOT# assertion latch bits"
echo "     5  : CLTT DIMM temperature threshold crossing latch bits"
echo "     6  : Current DIMM temperature"
echo "     7  : DIMM throttling demand counters"
echo "     8  : CPU and DRAM RAPL"
echo "     9  : Active Node Manager power limiting policy"
echo "     10 : Node Manager policy map"
echo "     11 : Node Manager statistics"
echo "     12 : Max allowed CPU P-State and T-State"
echo "     13 : CPU configuration"
echo "     14 : PSU configuration and status"
echo " "
echo "Command line parameters: "
echo " "
echo "     throttle.sh [option1] [option2] [option3] [option4] [option5]"
echo " "
echo "     option1: [(none)|-dnop]"
echo "     option2: [(none)|-loop]"
echo "     option3: [(none)|-cl|-cs|-cp|-ca]"
#echo "     option4: [(none)|-dnrmmb|-dnrcts|-dnrmh|-dnrclc|-dnrmd|-dnrrapl|-dnrnm|"
#echo "              -dnrnmp|-dnrnms|-dnrpts|-dnrcpu|-dnrpsu][-run section#[,section#]]"
echo "     option4: [(none)|-run section#,[section#]]"
echo "     option5: [(none)|-debug]"
echo " "
echo "     -dnop    : Do not output non-event messages"
echo "     -loop    : Continuous polling mode"
echo "     -cl      : Clear any latch bits that are set (display then clear)"
echo "     -cs      : Clear NM statistics (display then clear)"
echo "     -cp      : Clear PSU status bits that are set (display then clear)"
echo "     -ca      : Clear all (latch bits, NM statistics and PSU status bits) (display then clear)"
echo "     -run x,y : Run only the specified comma-separated sections x and y"
#echo "     -dnrmmb  : (2)   Do not run iDRAC XBus memory-mapped latch bits check"
#echo "     -dnrcts  : (3)   Do not run CPU thermal status sensors check"
#echo "     -dnrmh   : (4)   Do not run CPU MEMHOT# assertion latch bits check"
#echo "     -dnrclc  : (5&6) Do not run CLTT DIMM temperature threshold crossing"
#echo "                      latch bits check and current DIMM temperature check"
#echo "     -dnrmd   : (7)   Do not run DIMM throttling demand counters check"
#echo "     -dnrrapl : (8)   Do not run CPU and DRAM RAPL check"
#echo "     -dnrnm   : (9)   Do not run active Node Manager power limiting policy check"
#echo "     -dnrnmp  : (10)  Do not run Node Manager policy map check"
#echo "     -dnrnms  : (11)  Do not run Node Manager statistics check"
#echo "     -dnrpts  : (12)  Do not run max allowed CPU P-State and T-State check"
#echo "     -dnrcpu  : (13)  Do not run Additional CPU configuration check"
#echo "     -dnrpsu  : (14)  Do not run Additional PSU configuration and status check"
echo "     -debug   : Enable debug information"
echo " "
echo "To log to a file, here's one way:"
echo "     throttle.sh -loop 2>&1 | tee file.log"
echo " "
}

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------- Main Script From Here ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# VARIABLE DEFINITION
CLEAR_LATCHES=0  # variable to check if the -cl parameter is used : throttle detection latches should not be cleared.  Default is CLEAR_LATCHES = 0 = Don't clear the latches
CLEAR_STATS=0  # variable to check if the -cs parameter is used : NM stats should not be cleared.  Default is CLEAR_STATS = 0 = Don't clear NM stats
CLEAR_PSU=0 # variable to check if the -cp parameter is used: PSU status bits should not be cleared. Default is CLEAR_PSU = 0 = Don't clear PSU status bits
RUN_TEMP_SENSE=1
RMMB=1 # variable to check if the -dnrmmb parameter is used : skip checking iDRAC XBus Memory Mapped Bits
RCTS=1 # variable to check if the -dnrcts paramater is used : skip checking the CPU Thermal Status Sensor
RMH=1 # variable to check if the -dnrmh parameter is used : skip checking CPU MEMHOT# assertion
RCLC=1 # variable to check if the -dnrclc parameter is used : Skip checking the CLTT DIMM_TEMP and CLTT latching bits.  Default is DNRCLC = 1 = Do not skip checking the CLTT latching bits
RMD=1 # variable to check if the -dnrmd parameter is used : skip checking DIMM Throttling Demand Counter
RRAPL=1 # variable to check if the -dnrrapl parameter is used : skip checking RAPL
RNM=1 # variable to check if the -dnrnm parameter is used : Skip checking the Node Manager policy throttling, and NM policy map
RNMP=1 # variable to check if the -rnmp parameter is used : Skip displaying the Node Manager policy information
RNMS=1 # variable to check if the -rnms parameter is used : Skip checking the node manager statistics
RPTS=1 # variable to check if the -dnrpts parameter is used : skip checking the max p-state and t-state
RPSU=1 # variable to check if the -rpsu parameter is used : display the psu status information
RCPU=1  # variable to check if the -rcpu parameter is used : display the processor relevent information
DEBUG=0 # variable to check if the -debug parameter is used : turn on to output debug information about response by IPMI commands
OP=1 # variable to check if the -op parameter is used : turn on to output CPU/DIMM population information
LOOP_MODE=0 # variable to check if the -poll parameter is used : To detect throttle events near real-time, run the script in continuous polling mode
SIFT=0
DIMM_POPULATED_CHECK=0 # variable to check if the DIMM populated has been checked
THRT_COUNT_DIMM_CHECK=0
RAPL_PERF_STATUS_CHECK=0
RAPL_LIMIT_COUNT_CHECK=0
#RNMS_RAN_ONCE_ALREADY=0
ICCMAX_COUNT_CHECK=0
PSU_OCW_COUNT_CHECK=0
SMARTCLST_OVERCURRENT_CHECKED=0
SMARTCLST_OVERTEMP_CHECKED=0 #SMARTCLST_OverTemp_ARRAY[]
SMARTCLST_UNDERVOLT_CHECKED=0 #SMARTCLST_UnderVoltage_ARRAY[]

PROCESSOR_TYPE=0
PLANTYPE=0
GENERATION=0
GENERATION_INFO=0x00
update_count=0
load_found=0
SPEED=0
SPEED_OPTION=""
XSIFT=0

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Decode the command line parameters.  Max of 15 parameters can be used.
# --------------------------------------------------------------------------------
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# --------------------------------------------------------------------------------
# Parses all command line paramters.  the ' parameter is not valid, because it defines the end of the parameter array in the code below
# --------------------------------------------------------------------------------
# ------------------------- Check for command line parameters --------------------
# --------------------------------------------------------------------------------
PARAMETER_ARRAY=$*  # Builds parameter string of all the parameters passed from the command line delimited by spaces
PA=1   # Parameter Array Loop Initialization
PARAMETER_TEXT=$1 # Enter loop only if there is at least one parameter, otherwise PARAMETER_ARRAY = '' = null
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# This section displays a description of the script, and parameter usage text if requested by the user
# ./throttle.sh help
# ./throttle.sh -help
# ./throttle.sh --help
# if the first parameter is "help", then display the help text
if [ "$1" = "help" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ]
then
   disp_help_message
   exit 0 # Don't run script, and everything ended fine.
fi
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo "Throttle Detection Script: throttle.sh v$THROTTLE_VER $THROTTLE_BUILD_DATE"
echo "Copyright (c) 2017 - Dell Inc."

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if [ "$PARAMETER_TEXT" != '' ]  # add a ' to the end of the PARAMETER_ARRAY to enable the last paramter to be found correctly in the loop below, expecially if there is only one parameter
then
PARAMETER_ARRAY="${PARAMETER_ARRAY} '"
fi
# --------------------------------------------------------------------------------
while [ "$PARAMETER_TEXT" != '' ]      # Keep on parsing the parameters until a null paramter is found
do                                     # Start While Loop
#PARAMETER_TEXT=$(echo $PARAMETER_ARRAY | cut -f $PA -d ' ')  # Parse the array, and grab the PA'th value in the space delimited array
#echo "PA=${PA}; Parameter Text = $PARAMETER_TEXT"
# --------------------------------------------------------------------------------
if [ "$PARAMETER_TEXT" = "-cl" ]; then
   CLEAR_LATCHES=1   # Set CLEAR_LATCHES = 1, in order to clear the latches per the request of the user,
# --------------------------------------------------------------------------------
elif [ "$PARAMETER_TEXT" = "-cs" ]; then
   CLEAR_STATS=1     # Set CLEAR_STATS = 1, in order to clear NM stats per the request of the user,
# --------------------------------------------------------------------------------
elif [ "$PARAMETER_TEXT" = "-ca" ]; then  # Clear All - both latches and NM stats
   CLEAR_LATCHES=1   # Set CLEAR_LATCHES = 1, in order to clear the latches per the request of the user,
   CLEAR_STATS=1     # Set CLEAR_STATS = 1, in order to clear NM stats per the request of the user,
   CLEAR_PSU=1 # Set CLEAR_PSU = 1, in order to clear PSU status bits (CLEAR_FAULTS)
elif [ "$PARAMETER_TEXT" = "-cp" ]; then  # Clear PSU status bits
   CLEAR_PSU=1 # Set CLEAR_PSU = 1, in order to clear PSU status bits (CLEAR_FAULTS)
# --------------------------------------------------------------------------------
#Check for Defined Parameter #2 (section 2)
elif [ "$PARAMETER_TEXT" = "-dnrmmb" ]; then
   RMMB=0 # Set RMMB = 0, in order to skip checking the iDRAC XBus Memory Mapped Bits
# --------------------------------------------------------------------------------
#Check for Defined Parameter #3 (section 3)
elif [ "$PARAMETER_TEXT" = "-dnrcts" ]; then
   RCTS=0 # Set RCTS = 0, in order to skip checking the CPU Thermal Status Sensors
# --------------------------------------------------------------------------------
#Check for Defined Parameter #4 (section 4)
elif [ "$PARAMETER_TEXT" = "-dnrmh" ]; then
   RMH=0 # Set RMH = 0, in order to skip checking the CPU MEMHOT# test
# --------------------------------------------------------------------------------
#Check for Defined Parameter #5 (section 5/6)
elif [ "$PARAMETER_TEXT" = "-dnrclc" ]; then
   RCLC=0 # Set RCLC = 0, in order to skip checking the CLTT latching bits
# --------------------------------------------------------------------------------
#Check for Defined Parameter #6 (section 7)
elif [ "$PARAMETER_TEXT" = "-dnrmd" ]; then
   RMD=0 # Set RMD = 0, in order to skip checking the Demand Counter & MSR checks
# --------------------------------------------------------------------------------
#Check for Defined Parameter #7 (section 8)
elif [ "$PARAMETER_TEXT" = "-dnrrapl" ]; then
   RRAPL=0 # Set RRAPL = 0, in order to skip checking the CPU and DRAM RAPL
# --------------------------------------------------------------------------------
#Check for Defined Parameter #8 (section 9)
elif [ "$PARAMETER_TEXT" = "-dnrnm" ]; then
   RNM=0 # Set RNM = 0, in order to skip checking the NM policies for throttling
# --------------------------------------------------------------------------------
#Check for Defined Parameter #9 (section 10)
elif [ "$PARAMETER_TEXT" = "-dnrnmp" ]; then
   RNMP=0 # Set RNMP = 0, in order to skip displaying the Map of NM Policy Table
# --------------------------------------------------------------------------------
#Check for Defined Parameter #10 (section 11)
elif [ "$PARAMETER_TEXT" = "-dnrnms" ]; then
   RNMS=0 # Set RNMS = 0, in order to skip checking the NM statistics
# --------------------------------------------------------------------------------
#Check for Defined Parameter #11 (section 12)
elif [ "$PARAMETER_TEXT" = "-dnrpts" ]; then
   RPTS=0 # Set RPTS = 0, in order to skip cchecking the max p-state and t-state
# --------------------------------------------------------------------------------
#Check for Defined Parameter #13 (section 13)
elif [ "$PARAMETER_TEXT" = "-dnrcpu" ]; then
   RCPU=0 # Set RCPU = 1, in order to skip checking additional CPU configuration info
# --------------------------------------------------------------------------------
#Check for Defined Parameter #12 (section 14)
elif [ "$PARAMETER_TEXT" = "-dnrpsu" ]; then
   RPSU=0 # Set RPSU = 0, in order to skip checking additional PSU configuration info
# --------------------------------------------------------------------------------
#Check for Defined Parameter (debug)
elif [ "$PARAMETER_TEXT" = "-debug" ]; then
   DEBUG=1 # Set DEBUG = 1, in order to turn on debug outputs
# --------------------------------------------------------------------------------
#Check for Defined Parameter (CPU/DIMM population information)
elif [ "$PARAMETER_TEXT" = "-dnop" ]; then
   OP=0 # Set OP = 0, in order to turn off non-throttling messages
   RNMP=0
   RCPU=0
# --------------------------------------------------------------------------------
#Check for Defined Parameter
#Run everything once then exit - similar to how v1.2 behaved.
elif [ "$PARAMETER_TEXT" = "-loop" ]; then
   LOOP_MODE=1
   CLEAR_LATCHES=1
   CLEAR_PSU=1
   echo "Continuous polling mode enabled.  User <Ctrl+C> to exit script."
# --------------------------------------------------------------------------------
#Check for remote GUI option: -sift
elif [ "$PARAMETER_TEXT" = "-sift" ]; then
   SIFT=1
# --------------------------------------------------------------------------------
#Check for remote GUI option: -sift
elif [ "$PARAMETER_TEXT" = "-xsift" ]; then
   XSIFT=1
# --------------------------------------------------------------------------------
#Check for speed option on command line option
elif [ "$PARAMETER_TEXT" = "-run" ]; then
   PA=$(($PA+1))
   SPEED=1
   SPEED_OPTION=$(echo $PARAMETER_ARRAY | cut -f $PA -d ' ')  # Parse the array, and grab the PA'th value in the space delimited array
# --------------------------------------------------------------------------------
#Check for pre-defined option by user and or remote GUI: -GENERATION
elif [ "$PARAMETER_TEXT" = "-GENERATION" ]; then
   PA=$(($PA+1))
   USER_GENERATION=$(echo $PARAMETER_ARRAY | cut -f $PA -d ' ')  # Parse the array, and grab the PA'th value in the space delimited array
# --------------------------------------------------------------------------------
#Check for pre-defined option by user and or remote GUI: -PROCESSOR_TYPE
elif [ "$PARAMETER_TEXT" = "-PROCESSOR_TYPE" ]; then
   PA=$(($PA+1))
   USER_PROCESSOR_TYPE=$(echo $PARAMETER_ARRAY | cut -f $PA -d ' ')  # Parse the array, and grab the PA'th value in the space delimited array
# --------------------------------------------------------------------------------
#Check for pre-defined option by user and or remote GUI: -PSU_GENERATION
elif [ "$PARAMETER_TEXT" = "-PSU_GENERATION" ]; then
   PA=$(($PA+1))
   USER_PSU_GENERATION=$(echo $PARAMETER_ARRAY | cut -f $PA -d ' ')  # Parse the array, and grab the PA'th value in the space delimited array
# --------------------------------------------------------------------------------
##Check for pre-defined option by user and or remote GUI: -PSU_MUX_ARRAY
#elif [ "$PARAMETER_TEXT" = "-PSU_MUX_ADR_ARRAY" ]; then
#   PA=$(($PA+1))
#   USER_PSU_MUX_ARRAY=$(echo $PARAMETER_ARRAY | cut -f $PA -d ' ')  # Parse the array, and grab the PA'th value in the space delimited array
# --------------------------------------------------------------------------------
# Add additional parameter checks here if you has the new
# --------------------------------------------------------------------------------
elif [ "$PARAMETER_TEXT" = "'" ]; then
# Do nothing - dummy option appended at end of command line for proper parsing
   echo
else
   echo "ERROR:  Invalid command line options: $PARAMETER_TEXT.  Displaying help and exiting."
   disp_help_message
   exit 0 # Don't run script, and everything ended fine.
fi
PA=$(($PA+1))              # Increment a While Loop counter
PARAMETER_TEXT=$(echo $PARAMETER_ARRAY | cut -f $PA -d ' ')  # Parse the array, and grab the PA'th value in the space delimited array
done # while [ "$PARAMETER_TEXT" != '' ]

if [ $DEBUG = 1 ]; then
    echo "DEBUG Mode enabled."
fi
# --------------------------------------------------------------------------------
if [ $XSIFT = 1 ]; then
   x=$(rm -f /tmp/throttled.txt)
   y=$(rm -f /tmp/throttled_temp.txt)
    echo "Removed the restored sift-log."
   exit 0
fi
# --------------------------------------------------------------------------------
if [ $OP = 0 ]; then
   echo "Initialization started.  This may take a while depending on number of devices"
   echo "installed in system."
fi
# --------------------------------------------------------------------------------
#echo " "
# --------------------------------------------------------------------------------
# Speed option
if [ $SPEED = 1 ]; then
   # Start with executing none of the sections and then process command line further to run only specified sections
   RUN_TEMP_SENSE=0
   RMMB=0
   RCTS=0
   RMH=0
   RCLC=0
   RMD=0
   RRAPL=0
   RNM=0
   RNMP=0
   RNMS=0
   RPTS=0
   RCPU=0
   RPSU=0

   i=1
   x="${SPEED_OPTION},"   # Added comma so that a single section will parse properly
   y=$(echo $x | cut -f $i -d ',')    # Parse the array, and grab the y'th value in the space delimited array
   while [ "$y" != '' ]; do
      if [ "$y" = "1" ]; then
         RUN_TEMP_SENSE=1
      elif [ "$y" = "2" ]; then
         RMMB=1
      elif [ "$y" = "3" ]; then
         RCTS=1
      elif [ "$y" = "4" ]; then
         RMH=1
      elif [ "$y" = "5" ]; then
         RCLC=1
      elif [ "$y" = "6" ]; then
         RCLC=1
      elif [ "$y" = "7" ]; then
         RMD=1
      elif [ "$y" = "8" ]; then
         RRAPL=1
      elif [ "$y" = "9" ]; then
         RNM=1
      elif [ "$y" = "10" ]; then
         RNMP=1
      elif [ "$y" = "11" ]; then
         RNMS=1
      elif [ "$y" = "12" ]; then
         RPTS=1
      elif [ "$y" = "13" ]; then
         RCPU=1
      elif [ "$y" = "14" ]; then
         RPSU=1
      else
         echo "ERROR:  Invalid command line options:  -run $y.  Displaying help and exiting."
         disp_help_message
         exit 0 # Don't run script, and everything ended fine.
      fi
      i=$(($i+1))
      y=$(echo $x | cut -f $i -d ',')  # data record => 1:0;2:0;.....
   done
fi # if [ $SPEED = 1 ]; then

# --------------------------------------------------------------------------------
# ------------------------- Check for PowerEdge Generation ID _-------------------
# --------------------------------------------------------------------------------
if [ $RMMB = 1 ] || [ $RPSU = 1 ] || [ $RNM = 1 ]; then                     # if section 2, 9 and 14 have been activated, enable the process
   get_platform_information      # To get the platform information: generation and monolithic/modular
fi

if [ $RMMB = 1 ] || [ $RPSU = 1 ]; then                     # if this section been activated, enable the process
if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x10" ]; then     #13G: 0x20:Monolithic (Note: in case of 12G issue)
   get_psu_generation         # 13G need to be check
fi
fi

# Must include all sections for detect_dimm_populated() and get_power_time_unit()
if [ $RRAPL = 1 ] || [ $RCPU = 1 ] || [ $RCLC = 1 ] || [ $RMD = 1 ] || [ $RCTS = 1 ] || [ $RMH = 1 ]; then
   get_processor_cpuid           # Sandy/Ivy(12G), Haswell(13G), and SKUs (EP/EN/...)
fi

# --------------------------------------------------------------------------------
# ------------------------- Check User Definition if has -------------------------
# --------------------------------------------------------------------------------
get_user_define               # To get the user pre-define information if has.

# --------------------------------------------------------------------------------
# ------------------------- Check for DIMM Populated -----------------------------
# --------------------------------------------------------------------------------
# Must include all sections for detect_dimm_populated() and get_power_time_unit()
if [ $RRAPL = 1 ] || [ $RCPU = 1 ] || [ $RCLC = 1 ] || [ $RMD = 1 ] || [ $RCTS = 1 ] || [ $RMH = 1 ]; then
   detect_cpu_populated          # To run the detection at CPU Population
fi

# --------------------------------------------------------------------------------
# ------------------------- Check for DIMM Populated -----------------------------
# --------------------------------------------------------------------------------
if [ $RCLC = 1 ] || [ $RMD = 1 ]; then
    detect_dimm_populated
fi

# ------------------------------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------------------------------
if [ $RRAPL = 1 ] || [ $RCPU = 1 ]; then #v2.4 if [8] or [13] are selected
   get_power_time_unit
   chk_cpu_tdp_pmin_pmax_by_PCS
fi

# ------------------------------------------------------------------------------------------------------
# Section 1: Initialization: one shut ONLY
# ------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[1/14] Initialization"

#------------------------------------------------------------------------------------------------------
# Pre-Checking Section (would be called in any cases)
#------------------------------------------------------------------------------------------------------
# Section 7: pre-Check the DIMM throttling demand counter ( Retreive the data ONLY )
#------------------------------------------------------------------------------------------------------
#if [ $RMD = 1 ]; then                     # if this section been activated, enable the process
#   chk_throttle_demand_count
#   THRT_COUNT_DIMM_CHECK=1
#fi # if [ $RMD = 1 ]; then

if [ $RMD = 1 ]; then                     # if this section been activated, enable the process
   if [ $PROCESSOR_TYPE != 1 ]; then
      echo_result_by_op "    Read DIMM Throttling Demand Counters"
      load_THRT_COUNT_DIMM_if_has
      if [ $load_found = 0 ]; then
         chk_throttle_demand_count
         if [ $SIFT = 1 ]; then
            x=$(echo "THRT_COUNT_DIMM_ARRAY=$ENV_THRT_COUNT_DIMM_STR" >> /tmp/throttled.txt )
         fi
      fi
      THRT_COUNT_DIMM_CHECK=1
   fi # if [ $PROCESSOR_TYPE = 1 ]; then
fi # if [ $RMD = 1 ]; then
#------------------------------------------------------------------------------------------------------
# Section 8.1: pre-Check the RAPL Power Limit Exceeded Counters ( Retreive the data ONLY )
# Section 8.2: pre-Check the CPU RAPL Limiting Counter ( Retreive the data ONLY )
# Section 8.3: pre-Check the chk_cpu_dram_rapl_by_CSR
# Section 8.4: pre-Check the CPU ICCMAX Counter ( Retreive the data ONLY )
#------------------------------------------------------------------------------------------------------
#if [ $RRAPL = 1 ]; then                # if this section been activated, enable the process
#
#   chk_cpu_rapl_perf
#   RAPL_PERF_STATUS_CHECK=1
#
#   chk_cpu_rapl_limit_counter
#   RAPL_LIMIT_COUNT_CHECK=1
#
#   echo_result_by_op "    Read CPU & DRAM RAPL CSR information ..."
#   chk_cpu_dram_rapl_by_CSR                                               # ONLY one-shoot
#
#fi # if [ $RRAPL = 1 ]; then

if [ $RRAPL = 1 ]; then                # if this section been activated, enable the process

   echo_result_by_op "    Read CPU & DRAM RAPL Power Limit Exceeded Counters"    # by Bus/Dev/Fun/Ofs
   load_RAPL_PERF_STATUS_if_has
   if [ $load_found = 0 ]; then
      chk_cpu_rapl_perf
      if [ $SIFT = 1 ]; then
         x=$(echo "RAPL_PERF_STATUS_ARRAY=$ENV_RAPL_PERF_STATUS_STR" >> /tmp/throttled.txt )
      fi
   fi
   RAPL_PERF_STATUS_CHECK=1

   echo_result_by_op "    Read CPU RAPL Activated Counters"
   load_RAPL_LIMIT_COUNT_if_has
   if [ $load_found = 0 ]; then
      chk_cpu_rapl_limit_counter
      if [ $SIFT = 1 ]; then
         x=$(echo "RAPL_LIMIT_COUNT_ARRAY=$ENV_RAPL_LIMIT_COUNT_STR" >> /tmp/throttled.txt )
      fi
   fi
   RAPL_LIMIT_COUNT_CHECK=1

   echo_result_by_op "    Read CPU & DRAM RAPL in CSR"
   if [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4
        chk_cpu_dram_rapl_by_CSR # check CPU PL1/PL2 and DRAM PL1 power limits
   elif [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 check CPU PL1/PL2 PL1/P2 power limits based on TDP_PCS_ARRAY prepared in chk_cpu_tdp_pmin_pmax_by_PCS() in Pre-Checking [8.3]
        POWER_UNIT=$((POWER_UNIT_ARRAY[0]))
        CSR_LIMIT=$((TDP_PCS_ARRAY[0]))

        PL_CSR_ARRAY[1]=$CSR_LIMIT #fake CSR's CPU RAPL PL1
        CSR_LIMIT_LAST=$(echo $CSR_LIMIT $POWER_UNIT | awk '{printf("%7.3f",($1/$2))}')   # in Watts
        echo_result_by_op "        CPU1: RAPL PL1 CSR is not supported."
        echo_result_by_op "            - Power Limit (TDP in PCS)       = $CSR_LIMIT_LAST Watts"

        CSR_LIMIT_LAST=$(echo $CSR_LIMIT | awk '{printf("%.0f",($1*1.25))}')   # in Watts
        PL_CSR_ARRAY[2]=$CSR_LIMIT_LAST #fake CSR's CPU RAPL PL2
        CSR_LIMIT_LAST=$(echo $CSR_LIMIT $POWER_UNIT | awk '{printf("%7.3f",($1/$2*1.25))}')   # in Watts
        echo_result_by_op "        CPU1: RAPL PL2 CSR is not supported."
        echo_result_by_op "            - Power Limit (1.25x TDP in PCS) = $CSR_LIMIT_LAST Watts"

        PL_CSR_ARRAY[3]=0 #CSR's DRAM RAPL is not supported
        echo_result_by_op "        CPU1: DRAM RAPL CSR is not supported."
   else #unknown platform
        exit 1;
   fi

   echo_result_by_op "    Read CPU ICCMAX in CSR"
   if [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4
       #load_CPU_ICCMAX_COUNTER_if_has
       #if [ $load_found = 0 ]; then
          read_cpu_iccmax_by_CSR
          #if [ $SIFT = 1 ]; then
          #   x=$(echo "ICCMAX_LIMIT_ARRAY=$ENV_ICCMAX_LIMIT_STR" >> /tmp/throttled.txt )
          #fi
       #fi
       ICCMAX_COUNT_CHECK=1
   elif [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4
        echo_result_by_op "        CPU1: ICCMAX in CSR is not supported."
   else #unknown platform
        exit 1;
   fi

fi # if [ $RRAPL = 1 ]; then

#------------------------------------------------------------------------------------------------------
# Section 14.1: pre-Check the OCW1,OCW2,OCW3,OCW_IOUT_COUNTER on per PSU ( Retreive the data ONLY )
#------------------------------------------------------------------------------------------------------
#if [ $RPSU = 1 ]; then                    # if this section been activated, enable the process
#   chk_psu_ocw_counter
#   PSU_OCW_COUNT_CHECK=1
#fi #if [ $RPSU = 1 ]; then

if [ $RPSU = 1 ] || [ $RMMB = 1 ]; then                     # if this section been activated, enable the process
if [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x20" ]; then     # 12G/13G: monolithic only

   #v2.4 pull in disp_psu_piout_max prior to chk_psu_ocw_counter for early detect 1600W PSU b1600W_12_5G
   echo_result_by_op "    Read PSU Max Output"
   disp_psu_piout_max

   echo_result_by_op "    Read PSU OCW Counters"
   #load_PSU_OCW_COUNTERS_if_has
   #if [ $load_found = 0 ]; then
      chk_psu_ocw_counter
      #if [ $SIFT = 1 ]; then
      #   x=$(echo "PSU_OCW_COUNTERS_ARRAY=$ENV_PSU_OCW_COUNTERS_STR" >> /tmp/throttled.txt )
      #fi
   #fi
   PSU_OCW_COUNT_CHECK=1

   echo_result_by_op "    Read PSU Redundancy Mode"
   disp_psu_redundancy

fi # if [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x20" ]; then
fi # if [ $RPSU = 1 ]; then

#------------------------------------------------------------------------------------------------------
# Section 11: Reset NM Statistics before process the section 11
#------------------------------------------------------------------------------------------------------
#if [ $RNMS = 1 ] && [ $LOOP_MODE = 1 ]; then
#echo_result_by_op "    Clearing NM Global Statistics"
#reset_nm_statistics
#fi

#------------------------------------------------------------------------------------------------------
# Display temperature sensors for [2], [3], [4], [5], [6], [9], [12], [14]
#------------------------------------------------------------------------------------------------------
if [ $LOOP_MODE -ne 1 ]; then
   if [ $RMMB = 1 ] || [ $RCTS = 1 ] || [ $RMH = 1 ] || [ $RCLC = 1 ] || [ $RNM = 1 ] || [ $RPTS = 1 ] || [ $RPSU = 1 ]; then
      echo_result_by_op "    Read Temperature sensors"
      disp_temp_sensors
   fi
fi

#------------------------------------------------------------------------------------------------------
if [ $OP = 0 ]; then
    echo "Initialization completed."
    echo "Throttle Detection started.  Detecting ..."
fi

#------------------------------------------------------------------------------------------------------
# Unless -dncl, Throttle Detect Initialization (Section 1 and first reads for Sections 7, 8.1, 8.2)
# Infinite loop until user's Ctrl-C to quit:
#------------------------------------------------------------------------------------------------------
while [ true ]; do   # LOOP_MODE

if [ $LOOP_MODE = 1 ]; then
   tm=$(date)
   echo " "
   echo "Time log: $tm"
   #echo " "

   if [ $RUN_TEMP_SENSE = 1 ]; then
      echo_result_by_op "[1/14] Initialization"
      echo_result_by_op "    Read Temperature sensors"
      disp_temp_sensors
   fi
fi

#------------------------------------------------------------------------------------------------------
# Section 2: iDRAC XBus Memory Map Throttle Tests
#------------------------------------------------------------------------------------------------------
if [ $RMMB = 1 ]
then # If there are not any command line parameters to skip this test

#------------------------------------------------------------------------------------------------------
# Section 2 ##############################################################################################
echo_result_by_op " "
echo_result_by_op "[2/14] iDRAC XBus memory-mapped throttle latch bits and GPIO check"
#------------------------------------------------------------------------------------------------------
# Check the 9 bits in the iDRAC XBus Memory Map for throttling
#  1:  0x0D.3 idrac_prochot_assert (Not Latching)
#  2:  0x0D.2 idrac_memhot_assert (Not Latching)
#  3:  0x16.0 any_psu_alert_asserted
#  4:  0x17.3 any_psu_power_event_n (v2.01)
#  5:  0x17.2 me_prochot_assert
#  6:  0x17.1 me_memhot_assert
#  7:  0x17.0 dimm_temp_event_n_asserted_memhot
#  8:  0x18.3 any_cpu_vrhot_n_prochot_assert
#  9:  0x18.2 any_mem_vrhot_n_assert
# 10:  0x4A.3 Throttle_Latch (Did throttle occur?)
# 11:  0x4A.2 Throttle_Source_CMC_or_Autothrottle_Latch (If Throttle_Latch, then source=CMC or autothrottle)
# 12:  0x5c.1 power_cmd_6: live bit (v2.01) (Not Latching)
#------------------------------------------------------------------------------------------------------
# This fragment used for reference ONLY
#/bin/MemAccess -wb 14000016 01 > /dev/null 2>&1 # Clear Offset 0x16, bit 0
#/bin/MemAccess -wb 14000017 07 > /dev/null 2>&1 # Clear Offset 0x17 bits 0, 1, 2
#/bin/MemAccess -wb 14000018 0C > /dev/null 2>&1 # Clear Offset 0x18 bits 2, 3
#/bin/MemAccess -wb 1400004A 0C > /dev/null 2>&1 # Clear Offset 0x4A bits 2, 3
#-----------------------------------------------------------------------------------------------------
DISP_PSU_STA=0

#echo "    Test 1/9: Check XBus 0x0D.3 : idrac_prochot_assert"
# Command to check iDRAC XBus Memory Map Offset 0x0D bit 3; idrac_prochot_assert
# If set, then PROCHOT# is being asserted by the iDRAC
# This bit is not latching, does not need to be cleared
# iDRAC is not expected to assert this bit, but it can be used for debug purposes
let x=0x`MemAccess -rb 0x1400000D | tail -n +4 | head -n 1 | cut -f 3 -d ' '` #Remove the all but the bottom 4 rows of the response, then remove the bottom 3 rows, and grab the 1st byte of data
let "x2 = ($x & 8)" # the & is a bit wise AND, and checking vs 8 (1000b) checks bit 3 of the response
if [ $x2 -eq 0 ]        # if the bit is set, then it is throttling, otherwise it is equal to 0, and it is not throttling.
then echo_result_by_op "    iDRAC is not asserting PROCHOT_N (real-time) (iDRAC XBus 0x0D[3] not set)"
else
   echo "**  Throttled: iDRAC is asserting PROCHOT_N (real-time) (iDRAC XBus 0x0D[3] set) and GPUHOT (if supported)"
fi

#echo "    Test 2/9: Check XBus 0x0D.2 : idrac_memhot_assert"
# Command to check iDRAC XBus Memory Map Offset 0x0D bit 2: idrac_memhot_assert
# If set, then MEMHOT# is being asserted by the iDRAC
# This bit is not latching, does not need to be cleared
# iDRAC is not expected to assert this bit, but it can be used for debug purposes
#let x=0x`MemAccess -rb 0x1400000D | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
let "x2 = ($x & 4)"
if [ $x2 -eq 0 ]
then echo_result_by_op "    iDRAC is not asserting MEMHOT_N (real-time) (iDRAC XBus 0x0D[2] not set)"
else
   echo "    Note: iDRAC is asserting MEMHOT_N (real-time) (iDRAC XBus 0x0D[2] set)"
fi

CPLD_LATCH_16_DEF=0
#echo "    Test 3/9: Check XBus 0x16.0 : any_psu_alert_asserted"
# Command to check iDRAC XBus Memory Map Offset 0x16 bit 0: any_psu_alert_asserted
# If set, then SMBAlert# is being asserted by the PSU
# This bit is latching, and is write 1 to clear
# PSU will assert this bit due to PSU Over Current Warning (OCW), PSU over temp, or if PSU Vin is low
let x=0x`MemAccess -rb 0x14000016 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
let "x = ($x & 1)"
if [ $x -eq 0 ]; then
    echo_result_by_op "    PSU has not asserted SMB_ALERT_N (latched) (iDRAC XBus 0x16[0] not set)"
else
   CPLD_LATCH_16_DEF=0x01
   echo "**  Throttled: PSU asserted SMB_ALERT_N (latched) (iDRAC XBus 0x16[0] set)"
   DISP_PSU_STA=1 # enable psu status register displaying for later be used
fi

if [ $CLEAR_LATCHES = 1 ] && [ $CPLD_LATCH_16_DEF != 0 ]; then
latchbt=$(echo $CPLD_LATCH_16_DEF | awk '{printf("%02x",$1)}')
/bin/MemAccess -wb 14000016 $latchbt > /dev/null 2>&1    # Clear Offset 0x4A bits 2, 3, if has
fi

CPLD_LATCH_17_DEF=0
let x=0x`MemAccess -rb 0x14000017 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
# Command to check iDRAC XBus Memory Map Offset 0x17 bit 3: any_psu_pwr_event_n
if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x22" ]; then     #13G: 0x20:Monolithic (Note: in case of 12G issue)
    #let x=0x`MemAccess -rb 0x14000017 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
    let "x2 = ($x & 8)"
    if [ $x2 -eq 0 ]; then
        echo_result_by_op "    PSU has not asserted PWR_EVENT_N (latched) (iDRAC XBus 0x17[3] not set)"
    else
        CPLD_LATCH_17_DEF=$(($CPLD_LATCH_17_DEF|0x08))
        echo "**  Throttled: PSU asserted PWR_EVENT_N (latched) (iDRAC XBus 0x17[3] set)"
        DISP_PSU_STA=1 # enable psu status register displaying for later be used
    fi
elif [ $GENERATION_INFO == "0x21" ]  || [ $GENERATION_INFO == "0x11" ]; then  #13G: 0x21:Modular
    #let x=0x`MemAccess -rb 0x14000017 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
    let "x2 = ($x & 8)"
    if [ $x2 -eq 0 ]; then
        echo_result_by_op "    Modular-FC POWER_CMD_6 (PWR_EVENT_N) has not asserted (latched) (iDRAC XBus 0x17[3] not set)"
    else
        CPLD_LATCH_17_DEF=$(($CPLD_LATCH_17_DEF|0x08))
        echo "**  Throttled: Modular-FC POWER_CMD_6 (PWR_EVENT_N) asserted (latched) (iDRAC XBus 0x17[3] set)"
        DISP_PSU_STA=1 # enable psu status register displaying for later be used
    fi
fi

#echo "    Test 4/9: Check XBus 0x17.2 : me_prochot_assert"
# Command to check iDRAC XBus Memory Map Offset 0x17 bit 2: me_prochot_assert
# If set, then the ME is driving the signal based on receiving SMBAlert# from the PSU
# This bit is latching, and is write 1 to clear
let "x2 = ($x & 4)"
if [ $x2 -eq 0 ]
then echo_result_by_op "    NM has not asserted NM_PROCHOT_N (latched) (iDRAC XBus 0x17[2] not set)"
else
   CPLD_LATCH_17_DEF=$(($CPLD_LATCH_17_DEF|0x04))
   echo "**  Throttled: NM asserted NM_PROCHOT_N (latched) (iDRAC XBus 0x17[2] set)"
fi

#echo "    Test 5/9: Check XBus 0x17.1 : me_memhot_assert"
# Command to check iDRAC XBus Memory Map Offset 0x17 bit 1: me_memhot_assert
# If set, then the ME is driving the signal based on receiving SMBAlert# from the PSU
# This bit is latching, and is write 1 to clear
#let x=0x`MemAccess -rb 0x14000017 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
let "x2 = ($x & 2)"
if [ $x2 -eq 0 ]
then echo_result_by_op "    NM has not asserted NM_MEMHOT_N (latched) (iDRAC XBus 0x17[1] not set)"
else
   CPLD_LATCH_17_DEF=$(($CPLD_LATCH_17_DEF|0x02))
   echo "    Note: NM asserted NM_MEMHOT_N (latched) (iDRAC XBus 0x17[1] set)"
fi

#echo "    Test 6/9: Check XBus 0x17.0 : dimm_temp_event_n_asserted_memhot"
# Command to check iDRAC XBus Memory Map Offset 0x17 bit 0: dimm_temp_event_n_asserted_memhot
# If set, then the DIMM temperature event was asserted by the DIMMs, which should not be enabled in 12G
# This bit is latching, and is write 1 to clear
#let x=0x`MemAccess -rb 0x14000017 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
let "x2 = ($x & 1)"
if [ $x2 -eq 0 ]
then echo_result_by_op "    DIMMs have not asserted DIMM_EVENT_N (latched) (iDRAC XBus 0x17[0] not set)"
else
   CPLD_LATCH_17_DEF=$(($CPLD_LATCH_17_DEF|0x01))
   echo "    Note: One or more DIMMs asserted DIMM_EVENT_N (latched) (iDRAC XBus 0x17[0] set)"
fi

if [ $CLEAR_LATCHES = 1 ] && [ $CPLD_LATCH_17_DEF != 0 ]; then
latchbt=$(echo $CPLD_LATCH_17_DEF | awk '{printf("%02x",$1)}')
/bin/MemAccess -wb 14000017 $latchbt > /dev/null 2>&1    # Clear Offset 0x17 bits 0, 1, 2 if has
fi

CPLD_LATCH_18_DEF=0
#echo "    Test 7/9: Check XBus 0x18.3 : any_cpu_vrhot_n_prochot_assert"
# Command to check iDRAC XBus Memory Map Offset 0x18 bit 3: any_cpu_vrhot_n_prochot_assert
# If set, then one of the CPU Voltage Regulators are hot
# This bit is latching, and is write 1 to clear
let x=0x`MemAccess -rb 0x14000018 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
let "x2 = ($x & 8)"
if [ $x2 -eq 0 ]
then echo_result_by_op "    CPU VRs have not asserted CPU_VRHOT (latched) (iDRAC XBus 0x18[3] not set)"
else
   CPLD_LATCH_18_DEF=$(($CPLD_LATCH_18_DEF|0x08))
   echo "**  Throttled: One or more CPU VRs asserted CPU_VRHOT (latched) (iDRAC XBus 0x18[3] set)"
fi

#echo "    Test 8/9: Check XBus 0x18.2 : any_mem_vrhot_n_assert"
# Command to check iDRAC XBus Memory Map Offset 0x18 bit 2: any_mem_vrhot_n_assert
# If set, then one of the Memory Voltage Regulators are hot
# This bit is latching, and is write 1 to clear
#let x=0x`MemAccess -rb 0x14000018 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
let "x2 = ($x & 4)"
if [ $x2 -eq 0 ]
then echo_result_by_op "    Mem VRs have not asserted MEM_VRHOT (latched) (iDRAC XBus 0x18[2] not set)"
else
   CPLD_LATCH_18_DEF=$(($CPLD_LATCH_18_DEF|0x04))
   echo "    Note: One or more Mem VRs asserted MEM_VRHOT (latched) (iDRAC XBus 0x18[2] set)"
fi

if [ $CLEAR_LATCHES = 1 ] && [ $CPLD_LATCH_18_DEF != 0 ]; then
latchbt=$(echo $CPLD_LATCH_18_DEF | awk '{printf("%02x",$1)}')
/bin/MemAccess -wb 14000018 $latchbt > /dev/null 2>&1    # Clear Offset 0x18 bits 2, 3, if has
fi

if [ $GENERATION_INFO == "0x11" ] || [ $GENERATION_INFO == "0x21" ]; then     # 0x10 = 12G Monolithic, 0x11 = 12G Modular, 0x20 = 13G Monolithic, 0x21 = 13G Modular
    CPLD_LATCH_4A_DEF=0
    #echo "    Test 9/9: Check XBus 0x4A.3 : Throttle_Latch"
    # Command to check iDRAC XBus Memory Map Offset 0x4A bit 3: Throttle_Latch
    # If set, then there are any number of Modular throttle initiators, including CPLD OCW, CMC Shifty bus, etc.
    # Check 0x4A.2 to add insight into the throttle initiator
    # This bit is latching, and is write 1 to clear
    let x=0x`MemAccess -rb 0x1400004a | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
    let "x2 = ($x & 8)"
    if [ $x2 -eq 0 ]; then
        echo_result_by_op "    Modular-M Throttle_Latch has not asserted (latched) (iDRAC XBus 0x4A[3] not set)"
    else
        CPLD_LATCH_4A_DEF=$(($CPLD_LATCH_4A_DEF|0x08))
        echo "**  Throttled: Modular-M Throttle_Latch asserted (latched) (iDRAC XBus 0x4A[3] set)"

        #echo "Check Throttle Initiator for [0x4A.3]"
        # Command to check iDRAC XBus Memory Map Offset 0x4A bit 3: Throttle_Source_CMC_or_Auto_throttle_latch
        # If set, then there are any number of Modular throttle initiators, including CPLD OCW, CMC Shifty bus, etc.
        # Check 0x4A.2 to add insight into the throttle initiator
        # This bit is latching, and is write 1 to clear
        #let x=0x`MemAccess -rb 0x1400004a | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
        let "x2 = ($x & 4)"
        if [ $x2 -eq 0 ]; then
            echo "**  Throttled: Modular-M Throttle_Source is from CMC or autothrottle (latched) (iDRAC XBus 0x4A[2] set)"
        else
            echo "**  Throttled: Modular-M Throttle_Source is not from CMC or autothrottle (latched) (iDRAC XBus 0x4A[2] not set)"
        fi
        CPLD_LATCH_4A_DEF=$(($CPLD_LATCH_4A_DEF|0x04))
    fi # iDRAC XBus Memory Map Offset 0x4A bit 3: Throttle_Latch

    if [ $CLEAR_LATCHES = 1 ] && [ $CPLD_LATCH_4A_DEF != 0 ]; then
        latchbt=$(echo $CPLD_LATCH_4A_DEF | awk '{printf("%02x",$1)}')
        /bin/MemAccess -wb 1400004A $latchbt > /dev/null 2>&1   # Clear Offset 0x4A bits 2, 3, if has
    fi

    #x=$(MemAccess -rb 0x1400004A | grep "0x" | head -n 1 | cut -d ' ' -f 3)
    #x=$(($x))
    x2=$(($x&1))
    if [ $x2 -eq 0 ]; then
        echo_result_by_op "    Modular-M CLST_latch bit has not asserted (latched) (iDRAC XBus 0x4A[0] not set)"
    else
        echo "**    Modular-M CLST_latch bit has asserted (latched) (iDRAC XBus 0x4A[0] set)"
    fi

    if [ $PLANTYPE = 24 ] || [ $PLANTYPE = 32 ] || [ $PLANTYPE = 33 ]; then    # Planer type id: Aqua,Sifi,Sojo platform system
        let x=0x`MemAccess -rb 0x1400005c | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
        let "x2 = ($x & 2)"
        if [ $x2 -eq 0 ]; then
            echo_result_by_op "    Modular-FC PSB has not asserted POWER_CMD_6 ELR bit (real-time) (iDRAC XBus 0x5C[1] not set)"
        else
            echo "**  Throttled: Modular-FC PSB asserted POWER_CMD_6 ELR bit (real-time) (iDRAC XBus 0x5C[1] set)"
        fi
    fi
fi

#if [ $CPLD_LATCH_16_DEF -ne 0 ] || [ $CPLD_LATCH_17_DEF -ne 0 ] || [ $CPLD_LATCH_18_DEF -ne 0 ] || [ $CPLD_LATCH_4A_DEF -ne 0 ]; then
if [ $CPLD_LATCH_16_DEF -ne 0 ] || [ $CPLD_LATCH_17_DEF -ne 0 ]; then
    if [ $CPLD_LATCH_18_DEF -ne 0 ] || [ $CPLD_LATCH_4A_DEF -ne 0 ]; then
        if [ $CLEAR_LATCHES = 1 ]; then
            echo_result_by_op "    Cleared any Latch Bits that were set."
        fi
    fi
fi

if [ $DISP_PSU_STA = 1 ]; then
   if [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x20" ]; then # 0x10 = 12G Monolithic, 0x11 = 12G Modular, 0x20 = 13G Monolithic, 0x21 = 13G Modular
      echo_result_by_op "    Displaying PSU status since PSU SMB_ALERT_N or PWR_EVENT_N assertion was latched."
      dsp_psu_status_regs
      disp_psu_status_dc_reg                    # Will bypass the none-13G psu
      chk_psu_ocw_counter                       # Will bypass the none-13G psu: counters of OCW1, OCW2, OCW3, IOUT_OC_WARNING
      disp_psu_peak_current_e9_reg              # Will bypass the none-13G psu
      if [ $CLEAR_PSU -eq 1 ]; then
        reset_psu_status
      fi
   fi # if [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x20" ]; then
   if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x22" ]; then     # 0x10 = 12G Monolithic, 0x11 = 12G Modular, 0x20 = 13G Monolithic, 0x21 = 13G Modular
      display_SmaRT_CLST_status #Monolithic only. Display after PSU asserted SMB_ALERT_N (latched) or PWR_EVENT_N (latched)
   fi
fi

# chassis intrusion
if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x22" ]; then     # 0x10 = 12G Monolithic, 0x11 = 12G Modular, 0x20 = 13G Monolithic, 0x21 = 13G Modular
    if [ $(testgpio 0 39 0 | grep GPIO | cut -d ' ' -f 5) == "0" ]; then
        echo_result_by_op "    Chassis intrusion is not asserting (real-time) (iDRAC GPIO39, Pin AG10 not set)"
    else
        echo "**  Chassis intrusion is asserting (real-time) (iDRAC GPIO39, Pin AG10 set)"
    fi
fi #end of if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x10" ]


# End Section 2  ##############################################################################################
fi # END if [ $RMMB = 1 ]


#------------------------------------------------------------------------------------------------------
# Section 3: CPU Thermal Status Sensor
#------------------------------------------------------------------------------------------------------
if [ $RCTS = 1 ]
then # If there are not any command line parameters to skip this test

#------------------------------------------------------------------------------------------------------
# CPU Thermal Status Sensor
#
# PECI WrPkgConfig() to Index 20d with value of 0x2A (0x0010_1010) to clear Bits 5, 3, 1:
#
#
# Response:  0xbc 0xe1 0x00 0x01 0xc0 0x00 0x00
#                                     **** This byte contains bits 0, 1, 2 that need to be checked
# Bit0: CPU Critical Temperature
# Bit1: PROCHOT# Assertions
# Bit2: TCC Activation
#------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[3/14] CPU thermal status sensors check"
#------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY_2E40="30 31 32 33"        #0x30=CPU1, 0x31=CPU2, 0x32=CPU3, 0x33=CPU4
CPU_ID_ARRAY_2E44="40 41 42 43"        #0x40=CPU1, 0x41=CPU2, 0x42=CPU3, 0x43=CPU4
IPMICMD_CAT="2E:40"
#------------------------------------------------------------------------------------------------------
w=1                           # CPU index: Initialize the While Loop counter to 1, outside the loop
wMAX=4
bCriticalCPUTemp=0 # Dump CPU temp for Critical CPU temp event. Starting after Haswell.
while [ $w -le $wMAX ]; do

    dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
    if [ $dx != 0 ]; then      # If cpu is populated

        CPU_ID=$(echo $CPU_ID_ARRAY_2E40 | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array
        clear_latch=0
        clear_latch_mask=0xff
        clear_latch_mask=$(($clear_latch_mask))
        bCriticalCPUTemp=0 # clear flag for each CPU loop

        RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
        while [ $RETRY != 0 ]; do  #Retry Loop

            #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
            x=$(IPMICmd 0x20 0x2E 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x14 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') # PCS 20
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

            if [ "$cp" = "00" ]; then             #complete code=0, successful calling
                cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # c=FCS code, 0x40 means the IPMI command succeeded
                if [ "$cp2" = "40" ]; then             #complete code=0 && FCS=0x40, successful calling
                    a=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')
                    a=0x$a                                       # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                    a=$(($a))                                  # a is now equal to the decimal value, an integer, of the DIMM_TEMP in celcius, and math can now be performed on this number
                    # -------------------------------------------------------------------------------------------------------------
                    if [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -le 20 ]; then #v2.4 Grantley Haswell/Broadwell and Greenlow Skylake-S
                        y=$(($a&32))          # Check to see if bit 5 is set by performing a bitwise AND with 32, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled: CPU Critical Temperature exceeded (latched) (PCS Index 20 Bit 5 set)"
                            clear_latch=1
                            clear_latch_mask=$(($clear_latch_mask&0xdf))  # Need a write of 0 to Bit 5 to clear
                            bCriticalCPUTemp=1
                        else
                            echo_result_by_op "    CPU$w: CPU Critical Temperature not exceeded (latched) (PCS Index 20 Bit 5 clear)"
                        fi
                        y=$(($a&16))          # Check to see if bit 4 is set by performing a bitwise AND with 10h, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled: CPU Critical Temperature is exceeded (real-time) (PCS Index 20 Bit 4 set)"
                            bCriticalCPUTemp=1
                        else
                            echo_result_by_op "    CPU$w: CPU Critical Temperature is not exceeded (real-time) (PCS Index 20 Bit 4 clear)"
                        fi
                        y=$(($a&8))           # Check to see if bit 3 is set by performing a bitwise AND with 8, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled: CPU PROCHOT_N asserted (latched) (PCS Index 20 Bit 3 set)"
                            clear_latch=1
                            clear_latch_mask=$(($clear_latch_mask&0xf7))  # Need a write of 0 to Bit 3 to clear
                            #bCriticalCPUTemp=1 #Remove display of CPU temp for PROCHOT.  PROCHOT is input to CPU and does not indicate CPU is hot.
                        else
                            echo_result_by_op "    CPU$w: CPU PROCHOT_N not asserted (latched) (PCS Index 20 Bit 3 clear)"
                        fi
                        y=$(($a&4))           # Check to see if bit 2 is set by performing a bitwise AND with 04h, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled: CPU PROCHOT_N is asserted (real-time) (PCS Index 20 Bit 2 set)"
                            #bCriticalCPUTemp=1 #Remove display of CPU temp for PROCHOT.  PROCHOT is input to CPU and does not indicate CPU is hot.
                        else
                            echo_result_by_op "    CPU$w: CPU PROCHOT_N is not asserted (real-time) (PCS Index 20 Bit 2 clear)"
                        fi
                        y=$(($a&2))           # Check to see if bit 1 is set by performing a bitwise AND with 2, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled:  Thermal Control Circuitry (TCC) activated (latched) (PCS Index 20 Bit 1 set)"
                            clear_latch=1
                            clear_latch_mask=$(($clear_latch_mask&0xfd))
                            bCriticalCPUTemp=1
                        else
                            echo_result_by_op "    CPU$w: Thermal Control Circuitry (TCC) not activated (latched) (PCS Index 20 Bit 1 clear)"
                        fi
                        y=$(($a&1))           #KH Check to see if bit 0 is set by performing a bitwise AND with 01h, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled:  Thermal Control Circuitry (TCC) is activated (real-time) (PCS Index 20 Bit 0 set)"
                            bCriticalCPUTemp=1
                        else
                            echo_result_by_op "    CPU$w: Thermal Control Circuitry (TCC) is not activated (real-time) (PCS Index 20 Bit 0 clear)"
                        fi
                    else  # SandyBridge or IvyBridge
                        y=$(($a&16))          # Check to see if bit 4 is set by performing a bitwise AND with 16, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled: CPU Critical Temperature is exceeded (real-time) (PCS Index 20 Bit 4 set)"
                        else echo_result_by_op "    CPU$w: CPU Critical Temperature is not exceeded (real-time) (PCS Index 20 Bit 4 clear)"
                        fi
                        y=$(($a&4))           # Check to see if bit 2 is set by performing a bitwise AND with 4, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled: CPU PROCHOT_N is asserted (real-time) (PCS Index 20 Bit 2 set)"
                        else echo_result_by_op "    CPU$w: CPU PROCHOT_N is not asserted (real-time) (PCS Index 20 Bit 2 clear)"
                        fi
                        y=$(($a&1))           # Check to see if bit 0 is set by performing a bitwise AND with 1, if the bit is set, then y != 0
                        if [ $y != 0 ]; then
                            echo "**  CPU$w throttled:  Thermal Control Circuitry (TCC) is activated (real-time) (PCS Index 20 Bit 0 set)"
                        else echo_result_by_op "    CPU$w: Thermal Control Circuitry (TCC) is not activated (real-time) (PCS Index 20 Bit 0 clear)"
                        fi
                    fi
                    # -------------------------------------------------------------------------------------------------------------
                    RETRY=0           #abort the retry loop
                elif [ "$cp2" = "80" ] || [ "$cp2" = "81" ]; then
                    check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in [CPU thermal status sensors check]" "FC"
                    RETRY=$?
                fi  #  if [ "$cp2" = "40" ]
            else
                check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in [CPU thermal status sensors check]" $IPMICMD_CAT
                RETRY=$?
            fi
        done  # end of "while [ $RETRY != 0 ]; do  #Retry Loop"

        # Clear latched bits if latched
        if [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -le 20 ] && [ $CLEAR_LATCHES = 1 ] && [ $clear_latch != 0 ]; then #v2.4 Grantley Haswell/Broadwell and Greenlow Skylake-S

            clear_latch_mask=$(echo $clear_latch_mask | awk '{printf("%02X",$1)}')

            RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
            while [ $RETRY != 0 ]; do  #Retry Loop

                #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                x=$(IPMICmd 0x20 0x2E 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x0A 0x01 0xA5 0x00 0x14 0x00 0x00 0x$clear_latch_mask 0xff 0xff 0xff | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                if [ "$cp" = "00" ]; then              #complete code=0, successful calling
                    cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # c=FCS code, 0x40 means the IPMI command succeeded
                    if [ "$cp2" = "40" ]; then             #complete code=0 && FCS=0x40, successful calling
                        # -------------------------------------------------------------------------------------------------------------
                        # nothing
                        # -------------------------------------------------------------------------------------------------------------
                        RETRY=0           #abort the retry loop
                    elif [ "$cp2" = "80" ] || [ "$cp2" = "81" ]; then
                        check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in [CPU thermal status sensors check - clear latch]" "FC"
                        RETRY=$?
                    fi  #  if [ "$cp2" = "40" ]
                else
                    check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in [CPU thermal status sensors check - clear latch]" $IPMICMD_CAT
                    RETRY=$?
                fi
            done # end of "while [ $RETRY != 0 ]; do  #Retry Loop"

            echo_result_by_op "    Cleared any Thermal Status Sensors latch bits that were set."
        fi # if [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -le 20 ] && [ $CLEAR_LATCHES = 1 ] && [ $clear_latch != 0 ]; then #v2.4

        if [ $bCriticalCPUTemp != 0 ] || [ $DEBUG -ne 0 ]; then # CPU Temp event(s) asserted
            CPU_ID_2E44=$(echo $CPU_ID_ARRAY_2E44 | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array

            #KH IPMI 2E:44 TEMPERATURE_TARGET (1:30:0:E4h) #ToDo Replace by PCS 16 Temperature Target
            #CSR 1:30:0:E4h
            #    IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0xe4 0x00 0x1f 0x00 0x03
            #        E5: 0xbc 0x44 0x00 0x57 0x01 0x00 0x00 0x0a 0x56 0x00
            #            0xbc 0x44 0x00 0x57 0x01 0x00 0x00 0x0a 0x60 0x00
            #PCS 16 (23:16 - Prochot temperature where the Thermal Monitor is activated.)
            #       (27:24 - Temperature offset in degrees C from the Prochot.)
            #    IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x30 0x05 0x05 0xA1 0x00 0x10 0x00 0x00
            #        E5: 0xbc 0x40 0x00 0x57 0x01 0x00 0x40 0x00 0x0a 0x56 0x00
            #            0xbc 0x40 0x00 0x57 0x01 0x00 0x40 0x00 0x0a 0x60 0x00
            #        E3: 0xbc 0x40 0x00 0x57 0x01 0x00 0x40 0x00 0x14 0x64 0x00
            RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
            while [ $RETRY != 0 ]; do  #Retry Loop

                #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                if [ $PROCESSOR_TYPE -eq 13 ]; then # KNL
                    x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID_2E44 0xe4 0x20 0x1f 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') # TEMPERATURE_TARGET_CFG (1:30:2:E4h)
                elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
                    x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID_2E44 0xe4 0x00 0x1f 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') # TEMPERATURE_TARGET (1:30:0:E4h)
                elif [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake-S
                    break
                else
                    break
                fi
                cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                if [ "$cp" == "00" ]; then                                #complete code=0, successful calling
                    #format="2E:44:XX"
                    # result example: 0xbc 0x44 0x00 0x57 0x01 0x00 0xXX 0x0a 0x60 0x00
                    # Bit[ 7: 0] Reserved
                    # Bit[15: 8] FAN_TEMP_TARGET_OFST = TEMP_CONTROL_OFFSET #KNL reserved
                    # Bit[23:16] REF_TEMP = TCC_ACTIVATION_TEMP
                    # Bit[27:24] TJ_MAX_TCC_OFFSET = TCC_ACTIVATION_OFFSET  #KNL reserved
                    # Bit[31:28] Reserved
                    # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                    # -------------------------------------------------------------------------------------------------------------
                    #iTEMP_CONTROL_OFFSET=$((0x$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')))
                    iTCC_ACTIVATION_TEMP=$((0x$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')))
                    iTJ_MAX_TCC_OFFSET=$((0x$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')))
                    iTJ_MAX_TCC_OFFSET=$(($iTJ_MAX_TCC_OFFSET&0x0f))
                    if [ $PROCESSOR_TYPE -eq 13 ]; then # KNL no TJ_MAX_TCC_OFFSET Bit[27:24]
                        iTJ_MAX_TCC_OFFSET=$((0));
                    fi
                    iEFF_TCC_ACTIVATION_TEMP=$(($iTCC_ACTIVATION_TEMP-$iTJ_MAX_TCC_OFFSET))

                    strTCC_ACTIVATION_TEMP=$(printf '%i' $iTCC_ACTIVATION_TEMP)
                    strTJ_MAX_TCC_OFFSET=$(printf '%i' $iTJ_MAX_TCC_OFFSET)
                    strEFF_TCC_ACTIVATION_TEMP=$(printf '%3i' $iEFF_TCC_ACTIVATION_TEMP)
                    echo_result_by_op "    CPU$w: Effective TCC activation temperature = $strEFF_TCC_ACTIVATION_TEMP degC (Default = $strTCC_ACTIVATION_TEMP; Offset = $strTJ_MAX_TCC_OFFSET)"
                    #strTEMP_CONTROL_OFFSET=$(printf '%3i' $iTEMP_CONTROL_OFFSET)
                    #echo "    CPU$w: Tcontrol Offset Temperature = $strTEMP_CONTROL_OFFSET degC"

                    # -------------------------------------------------------------------------------------------------------------
                    RETRY=0                          #abort the retry loop
                else
                    check_cp_then_action $cp "AC" "A2 C0 DF" "Get CPU$w's TEMPERATURE_TARGET" "2E:44"
                    RETRY=$?
                fi
            done  # end of "while [ $RETRY != 0 ]; do  #Retry Loop"

            #KH IPMI 2E:44 PACKAGE_TEMPERATURE (1:30:0:C8h) #ToDo Replace by PCS 02 Package Temperature Read
            #CSR 1:30:0:C8h
            #    IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0xc8 0x00 0x1f 0x00 0x01
            #        E5: 0xbc 0x44 0x00 0x57 0x01 0x00 0x27
            #            0xbc 0x44 0x00 0x57 0x01 0x00 0x30
            #PCS 02 (22:16 - Temperature in degrees C, relative Tprochot.)
            #    IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x30 0x05 0x05 0xA1 0x00 0x02 0x00 0x00
            #        E5: 0xbc 0x40 0x00 0x57 0x01 0x00 0x40 0xf5 0xf2 0x00 0x00
            #            0xbc 0x40 0x00 0x57 0x01 0x00 0x40 0x8e 0xf2 0x00 0x00
            #        E3: 0xbc 0x40 0x00 0x57 0x01 0x00 0x40 0x3c 0xef 0x00 0x00
            RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
            while [ $RETRY != 0 ]; do  #Retry Loop

                #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
                    x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID_2E44 0xc8 0x20 0x1f 0x00 0x01 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') # PACKAGE_TEMPERATURE_CFG (1:30:2:C8h)
                elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
                    x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID_2E44 0xc8 0x00 0x1f 0x00 0x01 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') # PACKAGE_TEMPERATURE (1:30:0:C8h)
                elif [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake-S
                    break
                else
                    break
                fi
                cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                if [ "$cp" == "00" ]; then                                #complete code=0, successful calling
                    #format="2E:44:XX"
                    # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                    # -------------------------------------------------------------------------------------------------------------
                    iPKG_TEMP=$((0x$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')))    # a is now equal to CPU package temperature in hex
                    strPKG_TEMP=$(printf '%3i' $iPKG_TEMP)                                      # transfer to decimal
                    if [ $iPKG_TEMP -gt $iEFF_TCC_ACTIVATION_TEMP ]; then # compare to TCC or Tcontrol???
                        echo "**  CPU$w: Package real-time temperature        = $strPKG_TEMP degC (> TCC activation temp)"
                    else
                        echo_result_by_op "    CPU$w: Package real-time temperature        = $strPKG_TEMP degC"
                    fi
                    echo_result_by_op " "            #add an empty line for readability
                    # -------------------------------------------------------------------------------------------------------------
                    RETRY=0                          #abort the retry loop
                else
                    check_cp_then_action $cp "AC" "A2 C0 DF" "Get CPU$w's PACKAGE_TEMPERATURE" "2E:44"
                    RETRY=$?
                fi
            done  # end of "while [ $RETRY != 0 ]; do  #Retry Loop"

        fi # end of if [ bCriticalCPUTemp != 0 ]; then
    fi # if [ $dx != 0 ]; then

    w=$(($w+1))
done # end of while [ $w -le $wMAX ]; do
fi # END [ $RCTS = 1 ]


#------------------------------------------------------------------------------------------------------
# Section 4: Check the CPU MEMHOT# register status
#------------------------------------------------------------------------------------------------------
if [ $RMH = 1 ]
then # If there are not any command line parameters to skip this test
#------------------------------------------------------------------------------------------------------

# Section 4 ##############################################################################################
#
#  Check the CPU MEMHOT# register status
#
# 443553 sandy bridge-enepex processor external design Volume 2 v1.5.pdf, Section 4.3.8.7, pg. 525
#
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x24 0x81 0x17 0x00 0x03
#                                            ****                           CPU1, CPU 2 = 0x41, CPU 3 = 0x42 etc.
#
# For CPU1, check bits 0, and 1 for MEMHOT
#
# The response data is:
# 0xbc 0x44 0x00 0x57 0x01 0x00 0x03 0x00 0x00 0x00
#                               ****                This is the lowest byte, with the lower bits 0 and 1
#
# 03h bits 0, and 1 are set, because 3 = 0011
#
# Set prochot and memhot
#
# Use the following commands from the iDRAC to assert/de-assert PROCHOT# and MEMHOT# which are valid on Modular and Monolithic platforms
# - Assert PROCHOT# and MEMHOT#:  /bin/MemAccess -wb 1400000d 0C
# - De-Assert PROCHOT# and MEMHOT#:  /bin/MemAccess -wb 1400000d 00
#
# Clear bits 0 and 1 :  IPMICmd 0x20 0x2e 0x00 0x45 0x57 0x01 0x00 0x40 0x24 0x81 0x17 0x00 0x03 0x03 0x00 0x00 0x00
#------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[4/14] CPU MEMHOT# assertion latch bits check"
#------------------------------------------------------------------------------------------------------
#  Check the CPU MEMHOT# register status
#------------------------------------------------------------------------------------------------------
case $PROCESSOR_TYPE in
1) # SNB-EP
   mMAX=1
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:15=FUN:0=OFS:124"
   ;;
3) # IVB-EP w/ 1HA
   mMAX=1
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:15=FUN:0=OFS:124"
   ;;
4) # IVB-EP & IVB-EP 4S w/ 2HA
   mMAX=2
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:15=FUN:0=OFS:124=BUS:1=DEV:29=FUN:0=OFS:124"
   ;;
5) # IVB-EX w/ 2HA
   mMAX=2
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:15=FUN:0=OFS:124=BUS:1=DEV:29=FUN:0=OFS:124"
   ;;
7) # HSX-EP w/ 1HA
   mMAX=1
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:19=FUN:0=OFS:124"
   ;;
8) # HSX-EP & HSX-EP 4S w/ 2HA
   mMAX=2
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:19=FUN:0=OFS:124=BUS:1=DEV:22=FUN:0=OFS:124"
   ;;
9) # HSX-EX w/ 2HA
   mMAX=2
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:19=FUN:0=OFS:124=BUS:1=DEV:22=FUN:0=OFS:124"
   ;;
10) # BDX-EP w/ 1HA #v2.4
   mMAX=1
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:19=FUN:0=OFS:124"
   ;;
11) # BDX-EP & BDX-EP 4S w/ 2HA #v2.4
   mMAX=2
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:19=FUN:0=OFS:124=BUS:1=DEV:22=FUN:0=OFS:124"
   ;;
12) # BDX-EX w/ 2HA #v2.4
   mMAX=2
   CMD_CONFIG="MH_EXT_STAT=BUS:1=DEV:19=FUN:0=OFS:124=BUS:1=DEV:22=FUN:0=OFS:124"
   ;;
13) #KNL Xeon Phi
   mMAX=2
   CMD_CONFIG="MH_EXT_STAT=BUS:2=DEV:9=FUN:2:3:4=OFS:D74=BUS:2=DEV:8=FUN:2:3:4=OFS:D74" #MH_EXT_STAT B=2:D=8:F=2:O=D74h Bit[0] only, not Bit[1]. BUS:2=DEV:9 maps to MC0, BUS:2=DEV:8 maps to MC1
   ;;
20) # Greenlow Skylake-S w/ 1HA #v2.4
   mMAX=0 # Greenlow doesn't support CSR
   CMD_CONFIG=
   echo_result_by_op "    CPU MEMHOT# assertion latch bits in CSR not supported by Greenlow Skylake/Kabylake CPUs"
   ;;
*)
   echo "ERROR: Internal Error in [Section 4]. Terminate the script."
   exit 1
esac


#------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"    # This is a space delimited string array that can be parsed, and the characters can be turned into numbers
IPMICMD_CAT="2E:44"
#------------------------------------------------------------------------------------------------------
s=1
w=1                           # CPU index: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated
      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array

      m=0
      while [ $m -lt $mMAX ]; do

         if [ $HA2_SUPPORT = 1 ]; then
            HA_STR=$(($m+1))
            HA_STR="HA$HA_STR"
         else
            HA_STR=""
         fi
         offset=$((2+4*$m))
         bus_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         bus_no=$(echo $bus_no_config | cut -f 2 -d ':')
         bus_no=$(($bus_no))                             # string 2 decimal

         offset=$((3+4*$m))
         dev_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         dev_no=$(echo $dev_no_config | cut -f 2 -d ':')
         dev_no=$(($dev_no))                             # string 2 decimal

         PCI_ADR3=$(((($dev_no&0x1f)>>1)|(($bus_no&0x0f)<<4)))
         PCI_ADR4=$(((($bus_no&0xf0)>>4)))

         PCI_ADR3=$(echo $PCI_ADR3 | awk '{printf("%02x",$1)}')
         PCI_ADR4=$(echo $PCI_ADR4 | awk '{printf("%02x",$1)}')

         offset=$((4+4*$m))
         fun_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         offset=$((5+4*$m))
         reg_adr_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')

         v=2
         reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')
         while [ -n "$reg_adr" ]; do

            reg_adr2=0x$reg_adr
            PCI_ADR1=$(($reg_adr2&0x00ff))
            PCI_ADR1=$(echo $PCI_ADR1 | awk '{printf("%02x",$1)}')

            z=2
            fun_no=$(echo $fun_no_config | cut -f $z -d ':')
            while [ -n "$fun_no" ]; do

               fun_no=$(($fun_no))                          # string 2 decimal
               PCI_ADR2=$(((($reg_adr2&0x0f00)>>8)|(($fun_no&7)<<4)|(($dev_no&1)<<7)))
               PCI_ADR2=$(echo $PCI_ADR2 | awk '{printf("%02x",$1)}')

               IPMICMD_CAT="2E:44"
               RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
               while [ $RETRY != 0 ]; do  #Retry Loop

                  #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                  x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x$PCI_ADR1 0x$PCI_ADR2 0x$PCI_ADR3 0x$PCI_ADR4 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                  cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                  if [ "$cp" = "00" ]; then                 #complete code=0, successful calling
                     #format="2E:44"
                     # -------------------------------------------------------------------------------------------------------------
                     a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')   # a is now equal to the low byte of the PCI address space which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
                     a=0x$a                                         # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                     if [ $PROCESSOR_TYPE -eq 13 ]; then # KNL
                         MC_no=$(($m))
                         Ch_no=$(($fun_no-2))
                         if [ $(($a&1)) != 0 ]; then                 #If bit 0 is set,
                            echo "    Note: CPU$w MC$MC_no Ch$Ch_no MEM_HOT[0]# asserted (latched) (MH_EXT_STAT CSR Bit 0 set)"
                         else
                            echo_result_by_op "    CPU$w: MC$MC_no Ch$Ch_no MEM_HOT[0]# not asserted (latched) (MH_EXT_STAT CSR Bit 0 clear)"
                         fi
                         a=$(($a&1)) # KNL has only one MEM_HOT# bit @ MH_EXT_STAT Bit[0], demote Bit[7:1] for MEMHOT_CLEAR_ARRAY
                     else
                         if [ $(($a&1)) != 0 ]; then                 #If bit 0 is set,
                            echo "    Note: CPU$w $HA_STR MEM_HOT[0]# asserted (latched) (MH_EXT_STAT CSR Bit 0 set)"
                         else
                            echo_result_by_op "    CPU$w: $HA_STR MEM_HOT[0]# not asserted (latched) (MH_EXT_STAT CSR Bit 0 clear)"
                         fi
                         if [ $(($a&2)) != 0 ]; then                 #If bit 1 is set,
                            echo "    Note: CPU$w $HA_STR MEM_HOT[1]# asserted (latched) (MH_EXT_STAT CSR Bit 1 set)"
                         else
                            echo_result_by_op "    CPU$w: $HA_STR MEM_HOT[1]# not asserted (latched) (MH_EXT_STAT CSR Bit 1 clear)"
                         fi
                         a=$(($a&3)) # MEM_HOT#[1:0] bit @ MH_EXT_STAT Bit[1:0], demote Bit[7:2] for MEMHOT_CLEAR_ARRAY
                     fi
                     MEMHOT_CLEAR_ARRAY[$(($s-1))]=$a
                     # -------------------------------------------------------------------------------------------------------------
                     RETRY=0           #abort the retry loop
                  else
                     check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in [CPU MEMHOT# assertion latch bits check]" $IPMICMD_CAT
                     RETRY=$?
                  fi
               done                 #Exit the For Loop ($y)

       # Clear latch bits if set and if clearing is enabled --------------------------------------------------------------------
               clrbt=$((MEMHOT_CLEAR_ARRAY[$(($s-1))]))      # 0 base: while latch-bit be set before
               if [ $CLEAR_LATCHES = 1 ] && [ $clrbt != 0 ]; then                     # If cpu is populated && clear when latch-bit be set before
                  clrbt=$(echo $clrbt | awk '{printf("%02x",$1)}')    # convert to string

                  # -------------------------------------------------------------------------------------------------------------
                  IPMICMD_CAT="2E:45"
                  # -------------------------------------------------------------------------------------------------------------
                  RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                  while [ $RETRY != 0 ]; do  #Retry Loop

                     #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                     x=$(IPMICmd 0x20 0x2e 0x00 0x45 0x57 0x01 0x00 0x$CPU_ID 0x$PCI_ADR1 0x$PCI_ADR2 0x$PCI_ADR3 0x$PCI_ADR4 0x03 0x$clrbt 0x00 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                     cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                     if [ "$cp" = "00" ]; then              #complete code=0, successful calling
                        #format="2E:45:XX" if has
                        # -------------------------------------------------------------------------------------------------------------
                        # nothing
                        # -------------------------------------------------------------------------------------------------------------
                        RETRY=0           #abort the retry loop
                     else
                       check_cp_then_action $cp "AC" "A2 C0 DF" "CPU$w in [CPU MEMHOT# assertion latch bits check]" $IPMICMD_CAT
                        RETRY=$?
                     fi
                  done                 #Exit the For Loop ($y)
               fi # if [ $clrbt != 0 ]; then


               s=$(($s+1))
               z=$(($z+1))
               fun_no=$(echo $fun_no_config | cut -f $z -d ':')

            done # while [ -n "$fun_no" ]; do
            v=$(($v+1))
            reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')

         done # while [ -n "$reg_adr" ]; do

         m=$(($m+1))
      done # while [ $h > 1 ]; do

   fi # if [ $dx != 0 ]; then      # If cpu is populated
   w=$(($w+1))
done
#------------------------------------------------------------------------------------------------------
if [ $CLEAR_LATCHES = 1 ] ; then
echo_result_by_op "    Cleared any CPU MEMHOT Latching Bits that were set."
fi
fi # [ $RMH = 1 ]

#------------------------------------------------------------------------------------------------------
# Section 6: Check specific DIMM CLTT DIMM Temperature Threshold & Latching Bits Status
#------------------------------------------------------------------------------------------------------
if [ $RCLC = 1 ]
then # If there are not any command line parameters, then check CLTT DIMM_TEMP and CLTT latching bits, but if the -dnrclc parameter is used, then skip these tests

#------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[5&6/14] CLTT DIMM temperature threshold crossing latch bits check and"
echo_result_by_op "         current DIMM temperature check against thresholds"
echo_result_by_op "    Note: During boot, TEMPMID and TEMPLO exceeded indications may display along"
echo_result_by_op "          with normal DIMM temperatures.  This is benign."
echo_result_by_op "          Include -cl option to clear.  Running script in loop mode will also"
echo_result_by_op "          clear after the initial iteration."
# --------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------
# 1). Get Latching Bits Status & current DIMM Temperature (NEW)
#------------------------------------------------------------------------------------------------------
# To check specific DIMM CLTT DIMM Temperature Threshold Latching Bits
#
# Command:  IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x50 0x01 0x18 0x00 0x03
# Example Response: 0xbc 0x44 0x00 0x57 0x01 0x00 0x1f 0x00 0x00 0x03
#                                                                **** highest byte contains bits 28, 27, 26 that should be checked for TEMPHI/TEMPMID/TEMPLO Events Asserted
#
# This script gathers and comapares the DIMM temperature vs. the lowest programmed threshold for CLTT throttling
# If DIMM_TEMP > TEMP_LO, then CLTT is throttling
# This script implements 3 retry's for each IPMI command to minimize IPMI command failures
# There are 1 second delays built into retrys number 2 and 3
#
# DIMM Temperature
#
# Example Command:  IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x50 0x01 0x18 0x00 0x03
# Example Response:  0xbc 0x44 0x00 0x57 0x01 0x00 0x1e 0x00 0x00 0x03
#                                                  ****                  0x1e = DIMM Temp in Celcius
#------------------------------------------------------------------------------------------------------
# 1). Get Latching Bits Status & DIMM Temperature (NEW)
#------------------------------------------------------------------------------------------------------
case $PROCESSOR_TYPE in
1) # SNB-EP w/ 1HA
   mMAX=1
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:16=FUN:4:5:0:1=OFS:150:154:158"
   ;;
3) # IVB-EP w/ 1HA
   mMAX=1
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:16=FUN:4:5:0:1=OFS:150:154:158"
   ;;
4) # IVB-EP & IVB-EP 4S w/ 2HA
   mMAX=2
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:16=FUN:4:5=OFS:150:154:158=BUS:1=DEV:30=FUN:4:5=OFS:150:154:158"
   ;;
5) # IVB-EX w/ 2HA
   mMAX=2
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:16=FUN:4:5:0:1=OFS:150:154:158=BUS:1=DEV:30=FUN:4:5:0:1=OFS:150:154:158"
   ;;
7) # HSX-EP w/ 1HA
   mMAX=2
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:20=FUN:0:1=OFS:150:154:158=BUS:1=DEV:21=FUN:0:1=OFS:150:154:158"
   ;;
8) # HSX-EP & HSX-EP 4S w/ 2HA
   mMAX=2
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:20=FUN:0:1=OFS:150:154:158=BUS:1=DEV:23=FUN:0:1=OFS:150:154:158"
   ;;
9) # HSX-EX w/ 2HA
   mMAX=4
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:20=FUN:0:1=OFS:150:154:158=BUS:1=DEV:21=FUN:0:1=OFS:150:154:158"
                          "=BUS:1=DEV:23=FUN:0:1=OFS:150:154:158=BUS:1=DEV:24=FUN:0:1=OFS:150:154:158"
   ;;
10) # BDX-EP w/ 1HA #v2.4
   mMAX=2
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:20=FUN:0:1=OFS:150:154:158=BUS:1=DEV:21=FUN:0:1=OFS:150:154:158"
   ;;
11) # BDX-EP & BDX-EP 4S w/ 2HA #v2.4
   mMAX=2
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:20=FUN:0:1=OFS:150:154:158=BUS:1=DEV:23=FUN:0:1=OFS:150:154:158" #dimmtempstat_0, dimmtempstat_1, dimmtempstat_2 Bit[28,27,26,7:0]
   ;;
12) # BDX-EX w/ 2HA #v2.4
   mMAX=4
   CMD_CONFIG="DIMMTEMPSTAT=BUS:1=DEV:20=FUN:0:1=OFS:150:154:158=BUS:1=DEV:21=FUN:0:1=OFS:150:154:158"
                          "=BUS:1=DEV:23=FUN:0:1=OFS:150:154:158=BUS:1=DEV:24=FUN:0:1=OFS:150:154:158"
   ;;
13) #KNL Xeon Phi
   mMAX=2
   CMD_CONFIG="DIMMTEMPSTAT=BUS:2=DEV:9=FUN:2:3:4=OFS:D60=BUS:2=DEV:8=FUN:2:3:4=OFS:D60"  #chntempstat_cfg B=2:D=8:9F=2:3:4O=D60h Bit[29,28,26]. BUS:2=DEV:9 maps to MC0, BUS:2=DEV:8 maps to MC1
   ;;
20) # Greenlow Skylake-S w/ 1HA #v2.4
   mMAX=0 # Greenlow doesn't support CSR
   CMD_CONFIG=
   echo_result_by_op "    CLTT threshold and DIMM temperature not supported by Greenlow Skylake/Kabylake CPUs"
   ;;
*)
   echo "ERROR: Internal Error in [Section 6]. Terminate the script."
   exit 1
esac

# -------------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"            #CPU IDs
#IPMICMD_CAT="2E:44"
# -------------------------------------------------------------------------------------------------------------
s=1
w=1                           # CPU index: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array
      s2=1
      m=0
      while [ $m -lt $mMAX ]; do

         offset=$((2+4*$m))
         bus_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         bus_no=$(echo $bus_no_config | cut -f 2 -d ':')
         bus_no=$(($bus_no))                             # string 2 decimal

         offset=$((3+4*$m))
         dev_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         dev_no=$(echo $dev_no_config | cut -f 2 -d ':')
         dev_no=$(($dev_no))                             # string 2 decimal

         PCI_ADR3=$(((($dev_no&0x1f)>>1)|(($bus_no&0x0f)<<4)))
         PCI_ADR4=$(((($bus_no&0xf0)>>4)))

         PCI_ADR3=$(echo $PCI_ADR3 | awk '{printf("%02x",$1)}')
         PCI_ADR4=$(echo $PCI_ADR4 | awk '{printf("%02x",$1)}')

         offset=$((4+4*$m))
         fun_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         offset=$((5+4*$m))
         reg_adr_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')

         v=2
         reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')
         while [ -n "$reg_adr" ]; do

            reg_adr2=0x$reg_adr
            PCI_ADR1=$(($reg_adr2&0x00ff))
            PCI_ADR1=$(echo $PCI_ADR1 | awk '{printf("%02x",$1)}')

            z=2
            fun_no=$(echo $fun_no_config | cut -f $z -d ':')
            while [ -n "$fun_no" ]; do

               fun_no=$(($fun_no))                          # string 2 decimal
               PCI_ADR2=$(((($reg_adr2&0x0f00)>>8)|(($fun_no&7)<<4)|(($dev_no&1)<<7)))
               PCI_ADR2=$(echo $PCI_ADR2 | awk '{printf("%02x",$1)}')

                  dx=$((DIMM_POPULATED_ARRAY[$(($s-1))]))
                  if [ $dx != 0 ]; then   # If dimm is populated

                     IPMICMD_CAT="2E:44"
                     RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                     while [ $RETRY != 0 ]; do  #Retry Loop

                        #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                        x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x$PCI_ADR1 0x$PCI_ADR2 0x$PCI_ADR3 0x$PCI_ADR4 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                        cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                        if [ "$cp" = "00" ]; then                   #complete code=0, successful calling
                           #format="2E:44:XX"
                           # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                           # -------------------------------------------------------------------------------------------------------------
                           if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
                             a2=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')   # a is now equal to the high byte which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
                             a2=0x$a2
                             a2=$(($a2&0x3c)) #Bit[2/26]=ev_asrt_templo, Bit[3/27]=ev_asrt_tempmid, Bit[4/28]=ev_asrt_tempmidhi, Bit[5/29]=ev_asrt_temphi
                           else
                             a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # a is now equal to DIMM_TEMP which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
                             a=0x$a                                       # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                             a=$(($a))                                    # a is now equal to the decimal value, an integer, of the DIMM_TEMP in celcius, and math can now be performed on this number
                             DIMM_TEMP_ARRAY[$(($s-1))]=$a
                             a2=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')   # a is now equal to the high byte which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
                             a2=0x$a2
                             a2=$(($a2&0x1c)) #Bit[2/26]=ev_asrt_templo, Bit[3/27]=ev_asrt_tempmid, Bit[4/28]=ev_asrt_temphi
                           fi
                           TEMP_LATCH_ARRAY[$(($s-1))]=$a2   # To keep the [Latch-bit status] for coming section 6
                           # -------------------------------------------------------------------------------------------------------------
                           RETRY=0           #abort the retry loop
                        else
                           check_cp_then_action $cp "AC" "A2 C0 DF" "DIMM$s2 of CPU$w in [Test DIMM Temp Threshold Latching Bits]" $IPMICMD_CAT
                           RETRY=$?
                        fi
                     done              #Exit the For Loop ($y)


                   # Clear latch bits if set and if clearing is enabled
                     latchbt=$((TEMP_LATCH_ARRAY[$(($s-1))]))     # 0 base: while latch-bit be set before

                     if [ $CLEAR_LATCHES = 1 ] && [ $latchbt != 0  ]; then  # If dimm is populated
                        latchbt=$(echo $latchbt | awk '{printf("%02x",$1)}')    # convert to string
                        IPMICMD_CAT="2E:45"
                        RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                        while [ $RETRY != 0 ]; do  #Retry Loop

                           #Note: latchbt was a value, don't need to convert again.
                           #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                           x=$(IPMICmd 0x20 0x2e 0x00 0x45 0x57 0x01 0x00 0x$CPU_ID 0x$PCI_ADR1 0x$PCI_ADR2 0x$PCI_ADR3 0x$PCI_ADR4 0x03 0x00 0x00 0x00 0x$latchbt | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                           cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                           if [ "$cp" = "00" ]; then              #complete code=0, successful calling
                              #format="2E:45:XX" if has
                              RETRY=0           #abort the retry loop
                           else
                              check_cp_then_action $cp "AC" "A2 C0 DF" "DIMM$s2 of CPU$w in [Test DIMM Temp Threshold Latching Bits]" $IPMICMD_CAT
                              RETRY=$?
                           fi
                        done              #Exit the For Loop ($y)
                     fi # if [ $CLEAR_LATCHES = 1 ] && [ $latchbt != 0  ]; then
                  fi # if [ $dx != 0 ]; then

               s=$(($s+1))
               s2=$(($s2+1))
               z=$(($z+1))
               fun_no=$(echo $fun_no_config | cut -f $z -d ':')

            done # while [ -n "$fun_no" ]; do
            v=$(($v+1))
            reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')

         done # while [ -n "$reg_adr" ]; do

         m=$(($m+1))
      done # while [ $h > 1 ]; do
   fi # if [ $px != 0 ]; then

   w=$(($w+1))
done                    #Exit the For Loop ($w)

if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL Hottest DIMM Sensor Reading within a channel. Supposed it should work the same as the real-time DIM temp reading PCS 14???
    get_dimm_temp_PCS14
fi
# -------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------
# Section 5: Check Is DIMM Temperature > TEMP_LO Threshold ? Latching Bits Status
#------------------------------------------------------------------------------------------------------
# This script gathers and comapares the DIMM temperature vs. the lowest programmed threshold for CLTT throttling
# If DIMM_TEMP > TEMP_LO, then CLTT is throttling
# This script implements 3 retry's for each IPMI command to minimize IPMI command failures
# There are 1 second delays built into retrys number 2 and 3
#
# DIMM Temperature
#
# Example Command:  IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x50 0x01 0x18 0x00 0x03
# Example Response:  0xbc 0x44 0x00 0x57 0x01 0x00 0x1e 0x00 0x00 0x03
#                                                  ****                  0x1e = DIMM Temp in Celcius
# ---------------------------------------------------------------------------------------------------------------------------
# 1). Get TEMP_LO
# ---------------------------------------------------------------------------------------------------------------------------
#echo_result_by_op "[5/13]  CLTT Throttle Tests: Is DIMM Temperature > TEMP_LO Threshold ?"

# ---------------------------------------------------------------------------------------------------------------------------
# Section 5: Check Is DIMM Temperature > TEMP_LO Threshold once latch-bit has been latched.
# ---------------------------------------------------------------------------------------------------------------------------
# 2). Get TEMP_LO, Then compare with DIMM Temperature which be retrievd on Section 6.
# ---------------------------------------------------------------------------------------------------------------------------
# 1. Retrieve the TEMP_LO threshold.
# 2. Then, Check Is DIMM Temperature > TEMP_LO Threshold.
#
# Command:  IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x20 0x01 0x18 0x00 0x03
# Example Response: 0xbc 0x44 0x00 0x57 0x01 0x00 0x50 0x58 0x5b 0x00
#                                                                **** highest byte contains bits 28, 27, 26 that should be checked for TEMPHI/TEMPMID/TEMPLO Events Asserted
# ---------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------------
# 2). Get TEMP_LO, Then compare with DIMM Temperature which be retrievd on Section 6.
# ---------------------------------------------------------------------------------------------------------------------------
case $PROCESSOR_TYPE in
1) # SNB-EP
   mMAX=1
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:16=FUN:4:5:0:1=OFS:120:124:128"
   ;;
3) # IVB-EP w/ 1HA
   mMAX=1
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:16=FUN:4:5:0:1=OFS:120:124:128"
   ;;
4) # IVB-EP & IVB-EP 4S w/ 2HA
   mMAX=2
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:16=FUN:4:5=OFS:120:124:128=BUS:1=DEV:30=FUN:4:5=OFS:120:124:128"
   ;;
5) # IVB-EX w/ 2HA
   mMAX=2
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:16=FUN:4:5:0:1=OFS:120:124:128=BUS:1=DEV:30=FUN:4:5:0:1=OFS:120:124:128"
   ;;
7) # HSX-EP w/ 1HA
   mMAX=2
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:20=FUN:0:1=OFS:120:124:128=BUS:1=DEV:21=FUN:0:1=OFS:120:124:128"
   ;;
8) # HSX-EP & HSX-EP 4S w/ 2HA
   mMAX=2
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:20=FUN:0:1=OFS:120:124:128=BUS:1=DEV:23=FUN:0:1=OFS:120:124:128"
   ;;
9) # HSX-EX w/ 2HA
   mMAX=4
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:20=FUN:0:1=OFS:120:124:128=BUS:1=DEV:21=FUN:0:1=OFS:120:124:128"
                          "=BUS:1=DEV:23=FUN:0:1=OFS:120:124:128=BUS:1=DEV:24=FUN:0:1=OFS:120:124:128"
   ;;
10) # BDX-EP w/ 1HA #v2.4
   mMAX=2
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:20=FUN:0:1=OFS:120:124:128=BUS:1=DEV:21=FUN:0:1=OFS:120:124:128" #DIMM_TEMP_TH Bit[7:0]=Lo, Bit[15:8]=Mid, Bit[23:16]=Hi
   ;;
11) # BDX-EP & BDX-EP 4S w/ 2HA #v2.4
   mMAX=2
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:20=FUN:0:1=OFS:120:124:128=BUS:1=DEV:23=FUN:0:1=OFS:120:124:128"
   ;;
12) # BDX-EX w/ 2HA #v2.4
   mMAX=4
   CMD_CONFIG="DIMM_TEMP_TH=BUS:1=DEV:20=FUN:0:1=OFS:120:124:128=BUS:1=DEV:21=FUN:0:1=OFS:120:124:128"
                          "=BUS:1=DEV:23=FUN:0:1=OFS:120:124:128=BUS:1=DEV:24=FUN:0:1=OFS:120:124:128"
   ;;
13) #KNL Xeon Phi
   mMAX=2
   CMD_CONFIG="DIMM_TEMP_TH=BUS:2=DEV:9=FUN:2:3:4=OFS:D54=BUS:2=DEV:8=FUN:2:3:4=OFS:D54" #CHN_TEMP_TH_CFG B=2:D=8:9F=2:3:4O=D54h Bit[7:0]=Lo, Bit[15:8]=Mid, Bit[31:24]=Hi. BUS:2=DEV:9 maps to MC0, BUS:2=DEV:8 maps to MC1
   ;;
20) # Greenlow Skylake-S w/ 1HA #v2.4
   mMAX=0 # Greenlow doesn't support CSR
   CMD_CONFIG=
   echo_result_by_op "    CLTT threshold and DIMM temperature not supported by Greenlow Skylake/Kabylake CPUs"
   ;;
*)
   echo "ERROR: Internal Error in [Section 5]. Terminate the script."
   exit 1
esac

# ---------------------------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"            #CPU IDs
IPMICMD_CAT="2E:44"
# ---------------------------------------------------------------------------------------------------------------------------
s=1
w=1                           # CPU index: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array
      s2=1
      m=0
      while [ $m -lt $mMAX ]; do

         offset=$((2+4*$m))
         bus_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         bus_no=$(echo $bus_no_config | cut -f 2 -d ':')
         bus_no=$(($bus_no))                             # string 2 decimal

         offset=$((3+4*$m))
         dev_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         dev_no=$(echo $dev_no_config | cut -f 2 -d ':')
         dev_no=$(($dev_no))                             # string 2 decimal

         PCI_ADR3=$(((($dev_no&0x1f)>>1)|(($bus_no&0x0f)<<4)))
         PCI_ADR4=$(((($bus_no&0xf0)>>4)))

         PCI_ADR3=$(echo $PCI_ADR3 | awk '{printf("%02x",$1)}')
         PCI_ADR4=$(echo $PCI_ADR4 | awk '{printf("%02x",$1)}')

         offset=$((4+4*$m))
         fun_no_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')
         offset=$((5+4*$m))
         reg_adr_config=$(echo $CMD_CONFIG | cut -f $offset -d '=')

         v=2
         reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')
         while [ -n "$reg_adr" ]; do

            reg_adr2=0x$reg_adr
            PCI_ADR1=$(($reg_adr2&0x00ff))
            PCI_ADR1=$(echo $PCI_ADR1 | awk '{printf("%02x",$1)}')

            z=2
            fun_no=$(echo $fun_no_config | cut -f $z -d ':')
            while [ -n "$fun_no" ]; do

               fun_no=$(($fun_no))                          # string 2 decimal
               reg_adr2=0x$reg_adr
               PCI_ADR2=$(((($reg_adr2&0x0f00)>>8)|(($fun_no&7)<<4)|(($dev_no&1)<<7)))
               PCI_ADR2=$(echo $PCI_ADR2 | awk '{printf("%02x",$1)}')

               latch=$((TEMP_LATCH_ARRAY[$(($s-1))]))    # get the [Latch-bit status] which be kept by section 5
               dx=$((DIMM_POPULATED_ARRAY[$(($s-1))]))
               if [ $dx != 0 ]; then                     # If dimm is populated

                  if [ $latch = 0 ]; then                # If unlatching
                     echo_result_by_op "    DIMM$s2 of CPU$w: CLTT DIMM temperature threshold latching bits not set"
                  else                                   # If latching
                  # ---------------------------------------------------------------------------------------------------------------
                     if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
                        p=$(($latch&32))                    #"    CPU1 DIMM1:  CLTT Throttling:  TEMPHI    Event Asserted"
                        pq=$(($latch&16))                    #"    CPU1 DIMM1:  CLTT Throttling:  TEMPMIDHI Event Asserted"
                        q=$(($latch&8))                     #"    CPU1 DIMM1:  CLTT Throttling:  TEMPMID   Event Asserted"
                        r=$(($latch&4))                     #"    CPU1 DIMM1:  CLTT Throttling:  TEMPLO    Event Asserted"
                        if [ $p != 0 ]; then
                          echo "**  DIMM$s2 of CPU$w: TEMPHI exceeded (latched) (chntempstat_cfg CSR Bit 29 set)"
                          #TEMP_LIMIT_STR="TEMPHI"
                        fi
                        if [ $pq != 0 ]; then
                            echo "**  DIMM$s2 of CPU$w: TEMPMIDHI exceeded (latched) (chntempstat_cfg CSR Bit 28 set)"
                            #TEMP_LIMIT_STR="TEMPMIDHI"
                        fi
                        if [ $q != 0 ]; then
                            echo "**  DIMM$s2 of CPU$w: TEMPMID exceeded (latched) (chntempstat_cfg CSR Bit 27 set)"
                            #TEMP_LIMIT_STR="TEMPMID"
                        fi
                        if [ $r != 0 ]; then
                            echo "**  DIMM$s2 of CPU$w: TEMPLO exceeded (latched) (chntempstat_cfg CSR Bit 26 set)"
                            #TEMP_LIMIT_STR="TEMPLO"
                        fi
                     else
                        p=$(($latch&16))                    #"    CPU1 DIMM1:  CLTT Throttling:  TEMPHI  Event Asserted"
                        q=$(($latch&8))                     #"    CPU1 DIMM1:  CLTT Throttling:  TEMPMID Event Asserted"
                        r=$(($latch&4))                     #"    CPU1 DIMM1:  CLTT Throttling:  TEMPLO  Event Asserted"
                        if [ $p != 0 ]; then
                          echo "**  DIMM$s2 of CPU$w: TEMPHI exceeded (latched) (DIMMTEMPSTAT CSR Bit 28 set)"
                          #TEMP_LIMIT_STR="TEMPHI"
                        fi
                        if [ $q != 0 ]; then
                            echo "**  DIMM$s2 of CPU$w: TEMPMID exceeded (latched) (DIMMTEMPSTAT CSR Bit 27 set)"
                            #TEMP_LIMIT_STR="TEMPMID"
                        fi
                        if [ $r != 0 ]; then
                            echo "**  DIMM$s2 of CPU$w: TEMPLO exceeded (latched) (DIMMTEMPSTAT CSR Bit 26 set)"
                            #TEMP_LIMIT_STR="TEMPLO"
                        fi
                     fi
                     #
                     #else
                     #   latch2=$(echo $latch | awk '{printf("%02x",$1)}')
                     #   echo "    DIMM$s2 of CPU$w throttled: non-generic latched (value=0x$latch2)"
                     #fi # endif $r, $q, $p
                  #fi
                  # ---------------------------------------------------------------------------------------------------------------
                  #latch2=$(($latch&0x1c))                # bypass/ignor others latched state
                  #if [ $latch2 != 0 ]; then
                     RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
                     while [ $RETRY != 0 ]; do  #Retry Loop

                        #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
                        x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x$PCI_ADR1 0x$PCI_ADR2 0x$PCI_ADR3 0x$PCI_ADR4 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
                        cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

                        if [ "$cp" = "00" ]; then                 #complete code=0, successful calling
                           #format="2E:44:XX"
                           # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                           # -------------------------------------------------------------------------------------------------------------
                           a=$((DIMM_TEMP_ARRAY[$(($s-1))]))
                           # -------------------------------------------------------------------------------------------------------------
                           if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
                               b=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')  # b is now equal to TEMP_HI which is the 6th byte stored in the value of y.  This value is in string form, not an integer value
                               b=0x$b                                                    # b is now equal to the hex value.  This adds a 0x to the string, which converts 'b' from a string to a number
                               b=$(($b))                                                # b is now equal to the decimal value, an integer, of the TEMP_HI in celcius, and math can now be performed on this number
                               bc=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')  # b is now equal to TEMP_MIDHI which is the 6th byte stored in the value of y.  This value is in string form, not an integer value
                               bc=0x$bc                                                 # b is now equal to the hex value.  This adds a 0x to the string, which converts 'b' from a string to a number
                               bc=$(($bc))                                              # b is now equal to the decimal value, an integer, of the TEMP_MIDHI in celcius, and math can now be performed on this number
                           else
                               b=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x') # b is now equal to TEMP_HI which is the 6th byte stored in the value of y.  This value is in string form, not an integer value
                               b=0x$b                                     # b is now equal to the hex value.  This adds a 0x to the string, which converts 'b' from a string to a number
                               b=$(($b))                                   # b is now equal to the decimal value, an integer, of the TEMP_HI in celcius, and math can now be performed on this number
                           fi
                           # -------------------------------------------------------------------------------------------------------------
                           c=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x') # c is now equal to TEMP_MID which is the 6th byte stored in the value of y.  This value is in string form, not an integer value
                           c=0x$c                                     # c is now equal to the hex value.  This adds a 0x to the string, which converts 'c' from a string to a number
                           c=$(($c))                                   # c is now equal to the decimal value, an integer, of the TEMP_MID in celcius, and math can now be performed on this number
                           # -------------------------------------------------------------------------------------------------------------
                           d=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # d is now equal to TEMP_LO which is the 6th byte stored in the value of y.  This value is in string form, not an integer value
                           d=0x$d                                     # d is now equal to the hex value.  This adds a 0x to the string, which converts 'd' from a string to a number
                           d=$(($d))                                   # d is now equal to the decimal value, an integer, of the TEMP_LO in celcius, and math can now be performed on this number
                           if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
                                echo_result_by_op "    DIMM Temp Thresholds: TEMP_HI=$b, TEMP_MIDHI=$bc, TEMP_MID=$c, TEMP_LO=$d Celsius"
                           else
                                echo_result_by_op "    DIMM Temp Thresholds: TEMP_HI=$b, TEMP_MID=$c, TEMP_LO=$d Celsius"
                           fi
                           # -------------------------------------------------------------------------------------------------------------
                           if [ "$a" -ge "$b" ]; then                     # if a=DIMM_TEMP <= b=TEMP_HI, then CLTT is not throttling
                              echo "**  DIMM$s2 of CPU$w crossed TEMP_HI: real-time DIMM_TEMP >= TEMP_HI ($a >= $b Celsius)"
                           elif [ $p != 0 ]; then
                              echo "    DIMM$s2 of CPU$w: real-time DIMM_TEMP < TEMP_HI ($a < $b Celsius)"
                           fi
                           # -------------------------------------------------------------------------------------------------------------
                           if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
                               if [ "$a" -ge "$bc" ]; then                     # if a=DIMM_TEMP <= bc=TEMP_MIDHI, then CLTT is not throttling
                                  echo "**  DIMM$s2 of CPU$w crossed TEMP_MIDHI: real-time DIMM_TEMP >= TEMP_MIDHI ($a >= $bc Celsius)"
                               elif [ $pq != 0 ]; then
                                  echo "    DIMM$s2 of CPU$w: real-time DIMM_TEMP < TEMP_MIDHI ($a < $bc Celsius)"
                               fi
                           fi
                           # -------------------------------------------------------------------------------------------------------------
                           if [ "$a" -ge "$c" ]; then                     # if a=DIMM_TEMP <= c=TEMP_MID, then CLTT is not throttling
                              echo "**  DIMM$s2 of CPU$w crossed TEMP_MID: real-time DIMM_TEMP >= TEMP_MID ($a >= $c Celsius)"
                           elif [ $q != 0 ]; then
                              echo "    DIMM$s2 of CPU$w: real-time DIMM_TEMP < TEMP_MID ($a < $c Celsius)"
                           fi
                           # -------------------------------------------------------------------------------------------------------------
                           if [ "$a" -ge "$d" ]; then                     # if a=DIMM_TEMP <= d=TEMP_LO, then CLTT is not throttling
                              echo "**  DIMM$s2 of CPU$w crossed TEMP_LO: real-time DIMM_TEMP >= TEMP_LO ($a >= $d Celsius)"
                           elif [ $r != 0 ]; then
                              echo "    DIMM$s2 of CPU$w: real-time DIMM_TEMP < TEMP_LO ($a < $d Celsius)"
                           fi # TEMP_LO
                           # -------------------------------------------------------------------------------------------------------------
                           RETRY=0           #abort the retry loop
                        else
                           check_cp_then_action $cp "AC" "A2 C0 DF" "DIMM$s2 of CPU$w in [Get Temp_LO]" $IPMICMD_CAT
                           RETRY=$?
                        fi
                     done              #Exit the For Loop ($y)
                  fi # if [ $latch = 0 ]; then
               fi # if [ $dx != 1 ]; then

               s=$(($s+1))
               s2=$(($s2+1))
               z=$(($z+1))
               fun_no=$(echo $fun_no_config | cut -f $z -d ':')

            done # while [ -n "$fun_no" ]; do
            v=$(($v+1))
            reg_adr=$(echo $reg_adr_config | cut -f $v -d ':')

         done # while [ -n "$reg_adr" ]; do

         m=$(($m+1))
      done # while [ $h > 1 ]; do

   fi # if [ $px != 0 ]; then
   w=$(($w+1))
done                    #Exit the For Loop ($w)

# section 6: reset/clear CLTT Latch Bits ---------------------------------------------------
if [ $CLEAR_LATCHES = 1 ] ; then
   echo_result_by_op "    Cleared any CLTT DIMM Tempeture Latching Bits that were set."
fi

#------------------------------------------------------------------------------------------------------
# Section End
#------------------------------------------------------------------------------------------------------
fi # [ $RCLC = 1 ]
#------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------
# Section 7: Get Throttling Demand Counter
#------------------------------------------------------------------------------------------------------
if [ $RMD = 1 ]
then # If there are not any command line parameters to skip this test

# ------------------------------------------------------------------------------------------------------
# Get Throttling Demand Counter
#
# Example Commands:
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x98 0x01 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9A 0x01 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9C 0x01 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x98 0x11 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9A 0x11 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9C 0x11 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x98 0x41 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9A 0x41 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9C 0x41 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x98 0x51 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9A 0x51 0x18 0x00 0x02
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x9C 0x51 0x18 0x00 0x02
#                                            **** 0x40=CPU1, 0x41=CPU2, 0x42=CPU3, 0x43=CPU4
# Example Response:
#
#                      0xbc 0x44 0x00 0x57 0x01 0x00 0x00 0x00
#                                                    **** **** Data in LSB first
#------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[7/14] DIMM throttling demand counters check"
#------------------------------------------------------------------------------------------------------
if [ $PROCESSOR_TYPE = 1 ]; then
   echo_result_by_op "    DIMM Throttling Demand Counters not supported by SandyBridge CPUs"
else
   chk_throttle_demand_count
   update_THRT_COUNT_DIMM
fi

#------------------------------------------------------------------------------------------------------
# Section 7.1: Get xxx (IA_PERF_LIMIT_REASONS RING_PERF_LIMIT_REASONS) for 13G
#------------------------------------------------------------------------------------------------------
# After we checked, the MSR retrieving it cannot be done by IPMI 0x46 command.
# Removing of this section. You may refer to beta revision on 0514 drop.
#------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------
fi # if [ $RMD = 1 ]
#------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------
# Section 8: Check CPU and DRAM RAPL Information
#------------------------------------------------------------------------------------------------------
if [ $RRAPL = 1 ]
then # If there are not any command line parameters to skip this test

#------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[8/14] CPU RAPL, DRAM RAPL, and CPU IccMax check"
echo_result_by_op "    Note: CPU and DRAM RAPL can be initiated by CPU itself or by a NM"
echo_result_by_op "          power limiting policy. Thus, incrementing RAPL counters may or may"
echo_result_by_op "          not be due to NM. Check messages in Sections [8], [9] and [11]."
echo_result_by_op "          RAPL enabled means limits are put in place. Incrementing counters"
echo_result_by_op "          means actual throttling to stay within specified limits."

#------------------------------------------------------------------------------------------------------
# Section 8.1: Check RAPL Power Limit Exceeded Counters
# ------------------------------------------------------------------------------------------------------
#
# Check RAPL Power Limit Exceeded Counters
#
# Source:  443553 sandy bridge-enepex processor external design Volume 2 v1.1
# - 4.5.4.8 Primary Plane RAPL Perf Status : pg.  689-690
# - 4.5.4.9 Package RAPL Perf Status : pg. 690
# - 4.5.4.14 DRAM RAPL Perf Status : pg. 692-693
#
# Plane RAPL Status
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x80 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x41 0x80 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x42 0x80 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x43 0x80 0x20 0x15 0x00 0x03
# Package RAPL Status
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x88 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x41 0x88 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x42 0x88 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x43 0x88 0x20 0x15 0x00 0x03
# DRAM RAPL Status
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0xD8 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x41 0xD8 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x42 0xD8 0x20 0x15 0x00 0x03
# IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x43 0xD8 0x20 0x15 0x00 0x03
#
# Response:
# 0xbc 0x44 0x00 0x57 0x01 0x00 0x99 0xc8 0x08 0x00
#           *CC*                LSB  MSB             - The bottom bits [15:0] contain the RAPL Counters
# -------------------------------------------------------------------------------------------------------------
echo_result_by_op "    Check CPU & DRAM RAPL Power Limit Exceeded Counters"
chk_cpu_rapl_perf
update_RAPL_PERF_STATUS       # up to date if has

#------------------------------------------------------------------------------------------------------
# Section 8.2: Check RAPL Limiting Counters
# ------------------------------------------------------------------------------------------------------
echo_result_by_op "    Check CPU RAPL Activated Counters"
chk_cpu_rapl_limit_counter
update_RAPL_LIMIT_COUNT       # up to date if has

#------------------------------------------------------------------------------------------------------
# Section: 8.3: Get CPU and DRAM RAPL Information (from PECI RdPkbConfig)
# ------------------------------------------------------------------------------------------------------
# Get CPU and DRAM RAPL Information
#
# Example Commands:
# IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x30 0x05 0x05 0xA1 0x00 0x1A 0xFF 0x00
# IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x30 0x05 0x05 0xA1 0x00 0x1B 0xFF 0x00
# IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x30 0x05 0x05 0xA1 0x00 0x22 0xFF 0x00
# IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x31 0x05 0x05 0xA1 0x00 0x1A 0xFF 0x00
# IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x31 0x05 0x05 0xA1 0x00 0x1B 0xFF 0x00
# IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x31 0x05 0x05 0xA1 0x00 0x22 0xFF 0x00
#                                            CPU                      RAPL type: 0x30=CPU1, 0x31=CPU2, 0x1A=PL1 data, 0x1B=PL2 CPU data, 0x22=DRAM RAPL PL Data
#
# Example Response:
#
#                      0xbc 0x40 0x00 0x57 0x01 0x00 0x40 0x00 0x00 0x00 0x00
#                                                         **** **** **** ****   Data in LSB first
# 32-bits of data
# [31:24] Reserved = 0
# [23:22] ControlTimeWindowFraction = 0     byte2 bits 7, 6 : Mask : 0xC0, shift right 6 bits
# [21:17] ControlTimeWindowExponent = 8     byte2 bits 1,2,3,4,5 : Mask : 0x3E, then shift right one bit
# [16] LimitationClamping = 1                                         Byte 2, bit 1
# [15] ControlEnabled = 1            *********** INDICATES THROTTLING Byte 1, bit 7
# [14:0] Limit = 0                Byte 0 and Byte 1 : Mask: 0x7FFF
# ---------------------------------------------
# Commands to set NM K-Coefficient
#  99%
#    IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x63
#  95%
#    IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x5f
#  40%
#    IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x28
#  20%
#    IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x14
#
# GET K-Coefficient
# IPMICmd 0x20 0x2e 0x00 0xf1 0x57 0x01 0x00
#
# Get Node Manager Statistics C8 Command for HW :  IPMICmd 0x20 0x2e 0x00 0xc8 0x57 0x01 0x00 0x1d 0x03 0x00
#
#
# Doug,
# I can look at your platform if necessary, but if you want to try some diagnostics yourself, here the info is how to do it:
# 1. When you modify the K-Coefficient, the proper behavior should be that Power Limit for HW Protection Policy is changed. To check that you can send the C2h command (‘Get NM Policy?:
#
# IPMICmd 20 2e 00 0xc2 0x57 0x01 0x00 0x03 0x00
# The response data is:
# 0xbc 0xc2 0x00 0x57 0x01 0x00 0x73 0x50 0x01 0xd6 0x01 0xe8 0x03 0x00 0x00 0xd6 0x01 0x01 0x00
# 0xbc 0xc2 0x00 0x57 0x01 0x00 0x73 0x50 0x01 0xe6 0x03 0xe8 0x03 0x00 0x00 0xe6 0x03 0x01 0x00  3:53PM 10-27-11 DM
#
#
# On ORCA the Power Limit for the policy equals (MFR_POUT_MAX * K-Coefficient)
# When you change the K-Coefficient, the Limit for HW Protection Policy should change:
# IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x14
# The response data is:
# 0xbc 0xf0 0x00 0x57 0x01 0x00
# [SH7757 ~]$ IPMICmd 20 2e 00 0xc2 0x57 0x01 0x00 0x03 0x00
# The response data is:
# 0xbc 0xc2 0x00 0x57 0x01 0x00 0x73 0x50 0x01 0x63 0x00 0xe8 0x03 0x00 0x00 0x63 0x00 0x01 0x00
# 0xbc 0xc2 0x00 0x57 0x01 0x00 0x73 0x50 0x01 0xe6 0x03 0xe8 0x03 0x00 0x00 0xe6 0x03 0x01 0x00   3:54PM 10-27-11 DM
#
# 2. The next thing to check are statistics for the HW Protection Policy using C8h command
# IPMICmd 20 2e 00 0xc8 0x57 0x01 0x00 0x11 0x03 0x00
# The response data is:
# 0xbc 0xc8 0x00 0x57 0x01 0x00 0x36 0x00 0x35 0x00 0x36 0x00 0x35 0x00 0x70 0xe2 0x53 0x4e 0x01 0x00 0x00 0x00 0x73
# 0xbc 0xc8 0x00 0x57 0x01 0x00 0xef 0x00 0xee 0x00 0xef 0x00 0xee 0x00 0xad 0xf7 0xa5 0x4e 0x01 0x00 0x00 0x00 0x73   3:54PM 10-27-11 DM
#
# The red value is current power consumption. The HW Protection Policy should start limit power only when power consumption exceeds limit shown in the previous step for the c2h command.
# The yellow value are flags bits. 0xfX denotes that the HW Protection Policy is actually limiting, Other values indicate that this policy is not limiting.
#
# 3. Another useful command for detecting the source of power limiting is the f2h command (‘Get Limiting Policy?. It has to be sent separately for each domain:
# IPMICmd 20 2e 00 0xf2 0x57 0x01 0x00 0x00
# IPMICmd 20 2e 00 0xf2 0x57 0x01 0x00 0x01
# IPMICmd 20 2e 00 0xf2 0x57 0x01 0x00 0x02
# IPMICmd 20 2e 00 0xf2 0x57 0x01 0x00 0x03
#           0xbc 0xf2 0xa1 0x57 0x01 0x00 3:54PM 10-27-11 DM
#
# Sebastian
#
#------------------------------------------------------------------------------------------------------
# Note: The CSR value be retrieved in the earily stage by chk_cpu_dram_rapl_by_CSR().

#------------------------------------------------------------------------------------------------------
# Section: 8.3: Get CPU and DRAM RAPL Information from PECI RdPkbConfig Table: index 0x1a, 0x1b, 0x22
# -----------------------------------------------------------------------------------------------------
echo_result_by_op "    Check CPU & DRAM RAPL in PCS"
#------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="30 31 32 33"             #0x30=CPU1, 0x31=CPU2, 0x32=CPU3, 0x33=CPU4
INDEX_CMD_ARRAY="1A 1B 22"             #0x1A=PL1 data, 0x1B=PL2 CPU data, 0x22=DRAM RAPL PL Data
RAPL_NAME_ARRAY="RAPL_PL1 RAPL_PL2 DRAM_RAPL"   #RAPL TYPE String arrays
IPMICMD_CAT="2E:40"
# -------------------------------------------------------------------------------------------------------------

w=1                     # Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')         # Parse the array, and grab the y'th value in the space delimited array

   if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]; then        # ONLY Populated cpu available, others bypass

      z=1                        # Command Serias: Initialize the While Loop Counter to 1, outside the loop
      zMAX=3                     # Try up to this number of IPMI command
      while [ $z -le $zMAX ]; do # Perform the commands' loops identified in the For Loop

         INDEX_CMD=$(echo $INDEX_CMD_ARRAY | cut -f $z -d ' ')   # Parse the array, and grab the y'th value in the space delimited array
         RAPLNAME_STR=$(echo $RAPL_NAME_ARRAY | cut -f $z -d ' ')       # Parse the array, and grab the y'th value in the space delimited array

         RETRY=1                   # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
         while [ $RETRY != 0 ]; do  #Retry Loop

            #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
            x=$(IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x$INDEX_CMD 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
            cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

            if [ "$cp" = "00" ]; then        #complete code=0 && FCS=0x40, successful calling
               cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # c=FCS code, 0x40 means the IPMI command succeeded
               if [ "$cp2" = "40" ]; then             #complete code=0 && FCS=0x40, successful calling
                  #format="2E:40"
                  # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
                  print_PECI_cpu_dram_rapl_sta $z "$x" $w
                  # ----------------------------------------------------------
                  RETRY=0        #abort the retry loop
               elif [ "$cp2" = "80" ] || [ "$cp2" = "81" ]; then
                  check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in Display CPU and DRAM RAPL(PCS) at $RAPLNAME_STR" "FC"
                  RETRY=$?
               fi
            else
                 check_cp_then_action $cp "AC" "A2 C0 DF" "Check $CPU$w: CPU&DIMM RAPL(PCS) at $RAPLNAME_STR" $IPMICMD_CAT
               RETRY=$?
            fi
         done              #Exit the For Loop ($y)

         z=$(($z+1))       #Increment the ARRAY index For Loop counter
      done                 #Exit the For Loop ($z)
   fi # [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]; then
   w=$(($w+1))
done                    #Exit the For Loop ($w)

if [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
#------------------------------------------------------------------------------------------------------
# Section: 8.4: Get CPU ICCMAX from PCS index 15
#                than compare against with CSR value (read_cpu_iccmax_by_CSR)
# -----------------------------------------------------------------------------------------------------
echo_result_by_op "    Check CPU ICCMAX in PCS"
#------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="30 31 32 33" #0x30=CPU1, 0x31=CPU2, 0x32=CPU3, 0x33=CPU4
IPMICMD_CAT="2E:40"
# -------------------------------------------------------------------------------------------------------------
w=1                        # Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do

   CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')         # Parse the array, and grab the y'th value in the space delimited array

   if [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]; then        # ONLY Populated cpu available, others bypass

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         x=$(IPMICmd 0x20 0x2e 0x00 0x40 0x57 0x01 0x00 0x$CPU_ID 0x05 0x05 0xA1 0x00 0x0f 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then        #complete code=0 && FCS=0x40, successful calling
            cp2=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x') # c=FCS code, 0x40 means the IPMI command succeeded
            if [ "$cp2" = "40" ]; then             #complete code=0 && FCS=0x40, successful calling
               #format="2E:40"
               # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
               # -----------------------------
               a=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x') # a is now equal to byte 8
               b=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x') # b is now equal to byte 9
               COUNTER=0x$b$a                      # get the value by return string
               ENABLE=$((($COUNTER&0x8000)>>15))
               if [ $ENABLE = 1 ]; then
                  echo_result_by_op "        CPU$w ICCMAX in PCS is enabled (PCS Index15[15] set)."
                  COUNTER=$(($COUNTER&0x1fff))        # set this variable to the hex value
                  COUNTER2=$((ICCMAX_LIMIT_ARRAY[$w]))
                  #echo "COUNTER=$COUNTER, COUNTER2=$COUNTER2"
                  ICCMAX_VALUE=$(echo $COUNTER | awk '{printf("%.3f",($1/8))}')
                  ICCMAX_VALUE2=$(echo $COUNTER2 | awk '{printf("%.3f",($1/8))}')
                  if [ $COUNTER -lt $COUNTER2 ]; then
                     echo "**      iDRAC is applying (real-time) current limit to CPU$w: ICCMAX = ${ICCMAX_VALUE}A in PCS < ${ICCMAX_VALUE2}A in CSR"
                  else
                     echo_result_by_op "        CPU$w: ICCMAX = ${ICCMAX_VALUE}A in PCS and ${ICCMAX_VALUE2}A in CSR"
                  fi
               else
                  echo_result_by_op "        CPU$w ICCMAX in PCS is disabled (PCS Index15[15] not set)."
               fi # if [ $ENABLE = 1 ]; then
               # -----------------------------
               RETRY=0        #abort the retry loop
            elif [ "$cp2" = "80" ] || [ "$cp2" = "81" ]; then
               check_cp_then_action $cp2 "" "80 81" "CPU$w $IPMICMD_CAT w/ PECI CP=$cp2 in Display ICCMAX(PCS)" "FC"
               RETRY=$?
            fi
         else
            check_cp_then_action $cp "AC" "A2 C0 DF" "Check CPU$w: ICCMAX(PCS)" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y)

   fi # [ $((CPU_POPULATED_ARRAY[$(($w-1))])) = 1 ]; then
   w=$(($w+1))
done                    #Exit the For Loop ($w)
fi # if [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then
#------------------------------------------------------------------------------------------------------
fi # if [ $RRAPL = 1 ]

#------------------------------------------------------------------------------------------------------
# Section 9: Check if a Node Manager policy is limiting
#------------------------------------------------------------------------------------------------------

if [ $RNM = 1 ]
then # If there are not any command line parameters, then run the Node Manager tests for policies that are throttling, and create a map of NM policies

# Section 9 ##############################################################################################
#
# Example Commands to check if a Node Manager policy is limiting
#
# Example Command:     IPMICmd 0x20 0x2e 0x00 0xF2 0x57 0x01 0x00 0x00
#
# Example Rsponse:     0xbc 0xf2 0xa1 0x57 0x01 0x00
#                                ****                     0xa1 = No policy is currently limiting for the specified Domain
#
# Example Response:    0xbc 0xf2 0x00 0x57 0x01 0x00 0x00
#                                ****                ^^^^       0x00 = Command was a success, and 0x00 = Policy ID 0x00 is limiting
# Check NM Throttling for Domain:  Entire Platform
#     IPMICmd 0x20 0x2e 0x00 0xF2 0x57 0x01 0x00 0x00
# Check NM Throttling for Domain:  CPU Subsystem
#     IPMICmd 0x20 0x2e 0x00 0xF2 0x57 0x01 0x00 0x01
# Check NM Throttling for Domain:  Memory Subsystem
#     IPMICmd 0x20 0x2e 0x00 0xF2 0x57 0x01 0x00 0x02
# Check NM Throttling for Domain:  Hardware Protection / K-Coefficient
#     IPMICmd 0x20 0x2e 0x00 0xF2 0x57 0x01 0x00 0x03
#
# Commands to set NM K-Coefficient
#  99%
#    IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x63
#  95%
#    IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x5f
#  40%
#    IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x28
#  20%
#    IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x14
#------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[9/14] Active Node Manager power limiting policy (real-time) check"
#------------- -----------------------------------------------------------------------------------------
DOMAIN_ARRAY="00 01 02 03 04"    # This is a space delimited string array that can be parsed, and the characters can be turned into numbers
IPMICMD_CAT="2E:F2"
# -------------------------------------------------------------------------------------------------------------

w=1                     # Initialize the For Loop Counter x = 1, also same as domain id
bCheckIntrusion=0 # check chassis intrusion status
while [ $w -le 4 ]      # Skipping Domain ID 5 which is not used
   do                   #Retry Loop

   DM_ID=$(echo $DOMAIN_ARRAY | cut -f $w -d ' ')    # Parse the array, and grab the y'th value in the space delimited array

   RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
   while [ $RETRY != 0 ]; do  #Retry Loop

      #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
      x=$(IPMICmd 0x20 0x2e 0x00 0xF2 0x57 0x01 0x00 0x$DM_ID | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
      cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x')  # c=completion code, 0x00 means the IPMI command succeeded

      if [ "$cp" = "00" ]; then              #complete code=0, successful calling
         #format="2E:F2:XX"
         # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
         # -------------------------------------------------------------------------------------------------------------
         p=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x' | tr '[a-w, y-z]' '[A-W, Y-Z]') # p=policy ID of the actively throttling policy within the domain
         if [ $w = 1 ]; then              # domain 00
            echo -n "**  NM Power Limiting Activated: Domain ID 0 [System], Policy ID $p "
            if [ "$p" = "01" ]; then
               echo "(User Defined Power Cap A)"
            elif [ "$p" = "02" ]; then
               echo "(OMPC Statistics)"
            elif [ "$p" = "03" ]; then
               echo "(Boot Time Power Cap)"
            elif [ "$p" = "04" ]; then
               echo "(Safe Power Cap)"
            elif [ "$p" = "05" ]; then
               echo "(User Defined Power Cap B 'Backup')"
            elif [ "$p" = "08" ]; then
               echo "(ISC-Defined Power Cap - NLB)"
            elif [ "$p" = "09" ]; then
               echo "(ISC/AMP System Statistics - Input power)"
            elif [ "$p" = "0C" ]; then
               echo "(ISC/AMP System Statistics - Output power)"
            elif [ "$p" = "0D" ]; then
               echo "(Thermal Power Cap - System)"
               bCheckIntrusion=1
            else
               echo "(Not Defined)"
            fi
         elif [ $w = 2 ] && [ "$p" == "0E" ]; then            # domain 01
            echo "**  NM Power Limiting Activated: Domain ID 1 [CPU], Policy ID $p (Thermal Power Cap - CPU)"
            bCheckIntrusion=1
         elif [ $w = 3 ] && [ "$p" == "0F" ]; then            # domain 02
            echo "**  NM Power Limiting Activated: Domain ID 2 [Memory], Policy ID $p (Thermal Power Cap - Memory)"
         elif [ $w = 4 ] && [ "$p" == "00" ]; then            # domain 03
            echo "**  NM Power Limiting Activated: Domain ID 3 [Hardware Protection (PSU output,CMC allocation,K-Coefficient)], Policy ID $p"
         elif [ $w = 5 ]; then            # domain 04
            echo "**  NM Power Limiting Activated: Domain ID 4 [High Power IO], Policy ID $p"
         else                             # domain others
            echo "**  NM Power Limiting Activated: Domain ID $w [Not defined], Policy ID $p"
         fi
         #------------------------------------------------------------------------------------------------------
         # Report if NM Activated Policy Found by aboved section
         # ------------------------------------------------------------------------------------------------------
         report_activated_NM_policy "$DM_ID" "$p"
         # -------------------------------------------------------------------------------------------------------------
         y=$(($RETRY))                       #abort the retry loop
      elif [ "$cp" = "A1" ]; then           #cp=a1: no policy is currently for specified domain: nm policy not be found
         if [ $w = 1 ]; then
            echo_result_by_op "    NM Power Limiting not activated: Domain ID 0 [System]"
         elif [ $w = 2 ]; then
            echo_result_by_op "    NM Power Limiting not activated: Domain ID 1 [CPU]"
         elif [ $w = 3 ]; then
            echo_result_by_op "    NM Power Limiting not activated: Domain ID 2 [Memory]"
         elif [ $w = 4 ]; then
            echo_result_by_op "    NM Power Limiting not activated: Domain ID 3 [Hardware Protection(PSU output,CMC allocation,K-Coefficient)]"
         elif [ $w = 5 ]; then
            echo_result_by_op "    NM Power Limiting not activated: Domain ID 4 [High Power IO]"
         fi
         RETRY=0        #abort the retry loop
      else
         check_cp_then_action $cp "" "C0 DF" "Check Domain ID($DM_ID) in [Active Node Manager power limiting policy check]" $IPMICMD_CAT
         RETRY=$?
      fi
   done              #Exit the For Loop ($y)
   w=$(($w+1))
done                 #Exit the For Loop ($w)

# chassis intrusion
if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x22" ]; then     # 0x10 = 12G Monolithic, 0x11 = 12G Modular, 0x20 = 13G Monolithic, 0x21 = 13G Modular
    if [ $bCheckIntrusion != 0 ]; then
        if [ $(testgpio 0 39 0 | grep GPIO | cut -d ' ' -f 5) == "0" ]; then
            echo_result_by_op "    Chassis intrusion is not asserting (real-time) (iDRAC GPIO39, Pin AG10 not set)"
        else
            echo "**  Chassis intrusion is asserting (real-time) (iDRAC GPIO39, Pin AG10 set)"
        fi
    fi #end of if [ $bCheckIntrusion != 0 ]
fi #end of if [ $GENERATION_INFO == "0x20" ] || [ $GENERATION_INFO == "0x10" ]

# End Section 9 ##############################################################################################
fi # [ $RNM = 1 ] This is the endif for the parameter -dnrnm (do not run node manager)


# -------------------------------------------------------------------------------------------------------------
# Section 10: Parsing and Display all of the NM Policy information.
# -------------------------------------------------------------------------------------------------------------
if [ $RNMP = 1 ]
then # If there is any command line parameters, then displaying the map of Node Manager information.
# -------------------------------------------------------------------------------------------------------------
# Section 10: Parsing & Display all of the NM Policy information.
# -------------------------------------------------------------------------------------------------------------
# Parsing & Display all of the NM Policy information.
#
#
# How to create a map of NM Policies using the C2h Get Node Manager Policy IPMI Command
#
# Start with Domain ID = 0, and Policy ID = 0
#
# Command:  IPMICmd 0x20 0x2e 0x00 0xc2 0x57 0x01 0x00 0x00 0x00
#
# Expected Response if this is     a valid Domain and Policy:  0xbc 0xc2 0x00 0x57 0x01 0x00 0x60 0x10 0x01 0x06 0x03 0xe8 0x03 0x00 0x00 0x06 0x03 0x01 0x00
#                                                                        ||||                6< Bytes 6:18 = DATA                                         >18
# Expected Response if this is not a valid            Policy:  0xbc 0xc2 0x80 0x57 0x01 0x00 0x01 0x05
#          Policy ID = Byte 6                                            ||||                6*** 7^^^ = X # of Active Policies
#          if   Byte 6 != 0
#               Re-send the C2h Command with the same Domain, and new Policy ID = Byte 6
#          else Increment the Domain ID, set Policy ID = 0
#               Re-Send C2h Command with new Domain ID and new Policy ID
#
# Expected Response if this is not a valid Domain           :  0xbc 0xc2 0x81 0x57 0x01 0x00 0x00 0x04
#         Domain ID = Byte 6                                             ||||                6*** 7^^^ = Y # of Active Domains
#         if   Byte 6 != 0
#              Re-send the C2h Command with the new Domain ID = Byte 6, and Policy ID = 0
#         else Finished, because Domain ID flipped back to 0, which means all Policy IDs in all Domains were checked
# -------------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:C2"
# -------------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[10/14] Node Manager policy map (real-time) check"

d=0                     # Initialize the Domain ID variable to 0x00
p=0                     # Initialize the Policy ID variable to 0x00
x=1                     # Initialize the For Loop Counter x = 1, outside the loop
while [ $x -lt 255 ]
   do                   #Retry Loop

   #Set z = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
   dstr=$(echo $d | awk '{printf("%02X",$1)}')
   pstr=$(echo $p | awk '{printf("%02X",$1)}')

   RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
   while [ $RETRY != 0 ]; do  #Retry Loop

      z=$(IPMICmd 0x20 0x2e 0x00 0xc2 0x57 0x01 0x00 $dstr $pstr | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
      cp=$(echo $z | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

      if [ "$cp" = "00" ]
         then              #complete code=0, successful calling
         #format="2E:C2:XX"
         # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
         # -------------------------------------------------------------------------------------------------------------
         p2=$(echo $z | cut -f 7 -d ' ' | cut -f 2 -d 'x') # p=policy ID of the actively throttling policy within the domain
         if [ $d = 0 ]; then              # domain 00
            echo -n "    NM Policy: Domain ID 0 [System], Policy ID $p "
            if [ "$pstr" == "01" ]; then
               echo "(User Defined Power Cap A)"
            elif [ "$pstr" == "02" ]; then
               echo "(OMPC Statistics)"
            elif [ "$pstr" == "03" ]; then
               echo "(Boot Time Power Cap)"
            elif [ "$pstr" == "04" ]; then
               echo "(Safe Power Cap)"
            elif [ "$pstr" == "05" ]; then
               echo "(User Defined Power Cap B 'Backup')"
            elif [ "$pstr" == "08" ]; then
               echo "(ISC-Defined Power Cap - NLB)"
            elif [ "$pstr" == "09" ]; then
               echo "(ISC/AMP System Statistics - Input power)"
            elif [ "$pstr" == "0C" ]; then
               echo "(ISC/AMP System Statistics - Output power)"
            elif [ "$pstr" == "0D" ]; then
               echo "(Thermal Power Cap - System)"
            else
               echo "(Not Defined)"
            fi
         #elif [ $d = 1 ] && [ "$pstr" == "0E" ]; then            # domain 01
         #   echo "    NM Policy: Domain ID 1 [CPU], Policy ID $p (Thermal Power Cap - CPU)"
         elif [ $d = 1 ]; then            # domain 01
            echo -n "    NM Policy: Domain ID 1 [CPU], Policy ID $p "
            if [ "$pstr" == "0A" ]; then
               echo "(ISC/AMP CPU Statistics)"
            elif [ "$pstr" == "0E" ]; then
               echo "(Thermal Power Cap - CPU)"
            fi
         #elif [ $d = 2 ] && [ "$pstr" == "0F" ]; then            # domain 02
         #   echo "    NM Policy: Domain ID 2 [Memory], Policy ID $p (Thermal Power Cap - Memory)"
         elif [ $d = 2 ]; then            # domain 01
            echo -n "    NM Policy: Domain ID 2 [Memory], Policy ID $p "
            if [ "$pstr" == "0B" ]; then
               echo "(ISC/AMP Memory Statistics)"
            elif [ "$pstr" == "0F" ]; then
               echo "(Thermal Power Cap - Memory)"
            fi
         elif [ $d = 3 ] && [ "$pstr" == "00" ]; then            # domain 03
            echo "    NM Policy: Domain ID 3 [Hardware Protection(PSU output,CMC allocation,K-Coefficient)], Policy ID $p"
         elif [ $d = 4 ]; then            # domain 04
            echo "    NM Policy: Domain ID 4 [High Power IO], Policy ID $p"
         else                             # domain others
            echo "    NM Policy: Domain ID $d [Not defined], Policy ID $p"
         fi
         # ##################################################################################################################################
         # ##### PERFORM POLICY DATA PARSING HERE, AND THEN INCREMENT THE POLICY ID
         # ##################################################################################################################################
         disp_NM_policy "$z" "$dstr" "$pstr"
         #
         p=$(($p+1))          # Increment the Policy ID, because a valid Domain and Policy was found, now check for the next one
         RETRY=0
         # -------------------------------------------------------------------------------------------------------------
      elif [ "$cp" = "80" ]   #completion code!=0, the completion code is not good (AKA, not 0x00), then usleep 500000 second, and retry #3, else skip retry
         then              #cp=80: if target device no present, to end the retry, and abort this DEVICE serias.
         # -------------------------------------------------------------------------------------------------------------
         a=$(echo $z | cut -f 7 -d ' ' | cut -f 2 -d 'x')   # a is now equal to the the next valid policy ID which is the 6th byte stored in the value of z.
         a=0x$a            # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
         a=$(($a))
         if [ $a = 0 ]     # if the next valid Policy ID is 00, then increment the Domain, and set the Policy ID = 00, because all of the valid Policies in this Domain have been found
             then
            # --------------------------------------------------
            # DITDIT hack - Intel bug
            if [ $d = 0 ] && [ $p -eq 10 ]; then
               p=12
            elif [ $d = 0 ] && [ $p -eq 12 ]; then
               p=13
            else
               p=0            # Set Policy ID = 0x00
               d=$(($d+1))    # Increment the Domain ID, because all the valid policies have been found in this domain, now check the next one
            fi
            # DITDIT end hack - Intel bug
            # --------------------------------------------------
            # --------------------------------------------------
            # DITDIT need to uncomment below after removing hack
            #p=0            # Set Policy ID = 0x00
            #d=$(($d+1))    # Increment the Domain ID, because all the valid policies have been found in this domain, now check the next one
            # DITDIT need to uncomment above after removing hack
            # --------------------------------------------------
         else              # Set the Policy ID to the next valid Policy ID, which is stored in the value of a
            p=$a           # The Policy ID is now equal to the next valid Policy ID, and the C2h command can be re-run
         fi # [$a=00]
         RETRY=0
         # -------------------------------------------------------------------------------------------------------------
      elif [ "$cp" = "81" ]    #if others error: cp!=80
         then
         # -------------------------------------------------------------------------------------------------------------
         a=$(echo $z | cut -f 7 -d ' ' | cut -f 2 -d 'x')   # a is now equal to the the next valid Domain ID which is the 6th byte stored in the value of z.
         a=0x$a                                                     # a is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
         a=$(($a))
         if [ $a = 0 ]     # if the next valid Domain ID is 00, then this script is finished, because all of the Policy IDs in all of the valid Domain IDs have been found.  Domain ID started with 0x00, and the next one is where the script started
         then
            x=255          # Set x=loop number, because this script if finished
         else              # Set the Policy ID to the next valid Policy ID, which is stored in the value of a
            d=$a           # The Domain ID is now equal to the next valid Domain ID, and the C2h command can be re-run
         fi # [$a=00]
         RETRY=0
      else
         check_cp_then_action $cp "" "C0 DF" "Check Policy ID($p) of Domain ID $d in [Node Manager policy map check]" $IPMICMD_CAT
         RETRY=$?
         if [ "$cp" != "C0" ]; then
            x=255             #terminate the process once got some problem since non-endless loop
         fi
      fi
   done # while [ $RETRY != 0 ]; do
   x=$(($x+1))                          # Increment the For Loop counter                        #abort the retry loop
done              #Exit the For Loop ($x)

# End Section 10 ##############################################################################################
fi # [ $RNMP = 1 ] This is the endif for the parameter -dnrnmp (do not run node manager)


#------------------------------------------------------------------------------------------------------
# Section 11: Get the global throttling statistics
#------------------------------------------------------------------------------------------------------
if [ $RNMS = 1 ]
then # If there are not any command line parameters, then run the Node Manager tests for policies that are throttling, and create a map of NM policies

#------------------------------------------------------------------------------------------------------
# Section 11 ##############################################################################################
#------------------------------------------------------------------------------------------------------
#
#  Create a map of all NM policies, and get the global throttling statistics
#
# How to create a map of NM Policies using the C2h Get Node Manager Policy IPMI Command
#
# Start with Domain ID = 0, and Policy ID = 0
#
# Command:  IPMICmd 0x20 0x2e 0x00 0xc2 0x57 0x01 0x00 0x00 0x00
#
# Expected Response if this is     a valid Domain and Policy:  0xbc 0xc2 0x00 0x57 0x01 0x00 0x60 0x10 0x01 0x06 0x03 0xe8 0x03 0x00 0x00 0x06 0x03 0x01 0x00
#                                                                        ||||                6< Bytes 6:18 = DATA                                         >18
# Expected Response if this is not a valid            Policy:  0xbc 0xc2 0x80 0x57 0x01 0x00 0x01 0x05
#          Policy ID = Byte 6                                            ||||                6*** 7^^^ = X # of Active Policies
#          if   Byte 6 != 0
#               Re-send the C2h Command with the same Domain, and new Policy ID = Byte 6
#          else Increment the Domain ID, set Policy ID = 0
#               Re-Send C2h Command with new Domain ID and new Policy ID
#
# Expected Response if this is not a valid Domain           :  0xbc 0xc2 0x81 0x57 0x01 0x00 0x00 0x04
#         Domain ID = Byte 6                                             ||||                6*** 7^^^ = Y # of Active Domains
#         if   Byte 6 != 0
#              Re-send the C2h Command with the new Domain ID = Byte 6, and Policy ID = 0
#         else Finished, because Domain ID flipped back to 0, which means all Policy IDs in all Domains were checked
# s=0x00, IPMI Command did not complete successfully
# s=0x01, IPMI command completion code was 0x80
# s=0x02, IPMI command completion code was 0x81
#
# trigger domain 0x03 policy 0, HW protection domain by setting k-coefficient really low
# IPMICmd 0x20 0x2e 0x00 0xf0 0x57 0x01 0x00 0x63
#                                            **** K-Coefficient in % of PSU output wattage, 5F = 95% = Default
#
# Get k-coefficient:  IPMICmd 0x20 0x2e 0x00 0xf1 0x57 0x01 0x00
#
#------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[11/14] Node Manager statistics check"

#------------------------------------------------------------------------------------------------------
MODE_ARRAY="03 03 03 03 01 01 01 01 01"
DOMAIN_ARRAY="00 01 02 03 00 01 02 03 04"
IPMICMD_CAT="2E:C8"
# --------------------------------------------------------------------------------
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
if [ $OP = 0 ]; then # OP=0 means turn off non-throttling messages
   wMAX=4  # Display the Global Throttling Statistics (including Domain 0/1/2/3); skip Global Power Stats
#elif [ $GENERATION -gt 12 ]; then
#   wMAX=6
else
   wMAX=8 # Skip Domain ID 4 (High Power IO) - not supported
fi
while [ $w -le $wMAX ]; do

   MODE_ID=$(echo $MODE_ARRAY | cut -f $w -d ' ')
   DM_ID=$(echo $DOMAIN_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the w'th value in the space delimited array

   RETRY=1                 # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
   while [ $RETRY != 0 ]; do  #Retry Loop

      #Set z = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
      x=$(IPMICmd 0x20 0x2e 0x00 0xc8 0x57 0x01 0x00 0x$MODE_ID 0x$DM_ID 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')   # Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = DIMM_TEMP if successful
      cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

      if [ "$cp" = "00" ]; then              #complete code=0, successful calling
         #format="2E:C8:XX"
         # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
         # -------------------------------------------------------------------------------------------------------------
         if [ "$MODE_ID" == "03" ]; then # Global throttling statistics [%]
            UNIT="%"
            if [ "$DM_ID" == "00" ]; then
                echo "    Global Throttling Statistics Domain ID 0 System:"
                echo "    (100% = max CPU/Mem throttling NM can enforce; 0% = no CPU/Mem throttling by NM)"
            elif [ "$DM_ID" == "01" ]; then
                echo "    Global Throttling Statistics Domain ID 1 CPU subsystem:"
                echo "    (100% = max CPU throttling NM can enforce; 0% = no CPU throttling by NM)"
            elif [ "$DM_ID" == "02" ]; then
                echo "    Global Throttling Statistics Domain ID 2 Memory subsystem:"
                echo "    (100% = max Mem throttling NM can enforce; 0% = no Mem throttling by NM)"
            elif [ "$DM_ID" == "03" ]; then
                echo "    Global Throttling Statistics Domain ID 3 HW Protection:"
                echo "    (100% = max CPU/Mem throttling NM can enforce; 0% = no CPU/Mem throttling by NM)"
            elif [ "$DM_ID" == "04" ]; then
                echo "    Global Throttling Statistics Domain ID 4 High Power IO subsystem:"
                echo "    (100% = max MIC throttling NM can enforce; 0% = no MIC throttling by NM)"
            else
                break # exception, domain is not supported.
            fi
         elif [ "$MODE_ID" == "01" ]; then  # $MODE_ID = "01", Global power statistics in [Watts]
            UNIT="Watts"
            if [ "$DM_ID" == "00" ]; then
               echo "    Global Power Statistics Domain ID 0 System - Input Power (Watts):"
            elif [ "$DM_ID" == "01" ]; then
               echo "    Global Power Statistics Domain ID 1 CPU subsystem - Output Power (Watts):"
            elif [ "$DM_ID" == "02" ]; then
               echo "    Global Power Statistics Domain ID 2 Memory subsystem - Output Power (Watts):"
            elif [ "$DM_ID" == "03" ]; then
               echo "    Global Power Statistics Domain ID 3 HW Protection - Output Power (Watts):"
            elif [ "$DM_ID" == "04" ]; then
               echo "    Global Power Statistics Domain ID 4 High Power IO subsystem (Watts):"
            else
               break # exception, domain is not supported.
            fi
         else
            break # exception, mode is not supported.
         fi

         aa=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')  # e is now equal to byte 6 of z, the first byte of policy ID data
         ab=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')  # e is now equal to byte 7 of z, the first byte of policy ID data
         ac=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')  # e is now equal to byte 8 of z, the first byte of policy ID data
         ad=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 9 of z, the first byte of policy ID data
         ae=$(echo $x | cut -f 11 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 10 of z, the first byte of policy ID data
         af=$(echo $x | cut -f 12 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 11 of z, the first byte of policy ID data
         ag=$(echo $x | cut -f 13 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 12 of z, the first byte of policy ID data
         ah=$(echo $x | cut -f 14 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 13 of z, the first byte of policy ID data
         ai=$(echo $x | cut -f 15 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 14 of z, the first byte of policy ID data
         aj=$(echo $x | cut -f 16 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 15 of z, the first byte of policy ID data
         ak=$(echo $x | cut -f 17 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 16 of z, the first byte of policy ID data
         al=$(echo $x | cut -f 18 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 17 of z, the first byte of policy ID data
         am=$(echo $x | cut -f 19 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 18 of z, the first byte of policy ID data
         an=$(echo $x | cut -f 20 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 19 of z, the first byte of policy ID data
         ao=$(echo $x | cut -f 21 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 20 of z, the first byte of policy ID data
         ap=$(echo $x | cut -f 22 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 21 of z, the first byte of policy ID data
         aq=$(echo $x | cut -f 23 -d ' ' | cut -f 2 -d 'x') # e is now equal to byte 21 of z, the first byte of policy ID data
         # ---------------------------------------------------------------------------------------------------------------------------
         aq=0x$aq       # is now equal to the hex value, which is needed to perform bitwise functions to identify what bits are or are not set
         # ----------- Decode aa and ab
         y=0x$ab$aa  # y = hex value of two bytes
         y=$(($y))   # y = decimal value of y
         echo "        - Current Value = $y $UNIT"
         # ----------- Decode ac and ad
         y=0x$ad$ac  # y = hex value of two bytes
         y=$(($y))   # y = decimal value of y
         echo "        - Minimum Value = $y $UNIT"
         # ----------- Decode ae and af
         y=0x$af$ae  # y = hex value of two bytes
         y=$(($y))   # y = decimal value of y
         echo "        - Maximum Value = $y $UNIT"
         # ----------- Decode ag and ah
         y=0x$ah$ag  # y = hex value of two bytes
         y=$(($y))   # y = decimal value of y
         echo "        - Average Value = $y $UNIT"
         # ----------- Decode ai and aj ak al
         y=0x$al$ak$aj$ai  # y = hex value of two bytes
         y=$(($y))   # y = decimal value of y
         echo -n "        - Time Stamp    = "
         DisplayTimeStamp "$y"
         # ----------- Decode am and an ao ap
         y=0x$ap$ao$an$am  # y = hex value of two bytes
         y=$(($y))   # y = decimal value of y
         echo "        - Statistics Reporting Period = $y seconds"
         # ----------- Decode aq
         dp=$(($aq&64))     # Check bit 5 to see if it is set or not
         if [ $dp = 0 ]         #If bit 1 is set, then Policy Exception Actions when Policy Power Limit is exceeded over Correction Time Limit - Shutdown System
         then
            echo "        - Measurements are not in progress"
         fi
         if [ $dp = 64 ]        #If bit 0 is set, then Policy Exception Actions when Policy Power Limit is exceeded over Correction Time Limit - Shutdown System
         then
            echo "        - Measurements are in progress"
         fi
         # -------------------------------------------------------------------------------------------------------------
         RETRY=0     #abort the domain loop
      else
         check_cp_then_action $cp "" "C0 DF" "Check Domain ID $DM_ID in [Node Manager statistics check]" $IPMICMD_CAT
         RETRY=$?
      fi
   done              #Exit the For Loop ($y)

   w=$(($w+1))
done
if [ $CLEAR_STATS = 1 ] ; then
   reset_nm_statistics
   echo_result_by_op "    Cleared NM Global Statistics"
fi
#RNMS_RAN_ONCE_ALREADY=1
# End Section 11 ###################################################################################
fi # [ $RNMS = 1 ]

# -------------------------------------------------------------------------------------------------------------
# Section 12: Get the max allowed CPU P-State and T-State
# -------------------------------------------------------------------------------------------------------------

if [ $RPTS = 1 ]
then # If there are not any command line parameters, then run the Node Manager tests for policies that are throttling, and create a map of NM policies

# ------------------------------------------------------------------------------------------------------
# Section 12 ##############################################################################################
# ------------------------------------------------------------------------------------------------------
#
# D3h Get Max Allowed CPU P-State/T-State
#   - If the max P-State is not 0, then the system is throttling
#
# Source:  434090_NodeMgr2.0_IPMI-Interface-Spec_1.0.pdf, pg. 66
#
# Example Command:  IPMICmd 0x20 0x2e 0x00 0xD3 0x57 0x01 0x00 0x00
#                                                              ****  Entire Platform Domain requesting CPU P/T States
#
# Example Response:  0xbc 0xd3 0x00 0x57 0x01 0x00 0x00 0x00
# Example Response:  0xbc 0xd3 0x00 0x57 0x01 0x00 0x01 0x00
#                                                  **** ^^^^   **** = Max Allowed P-State, ^^^^ = Max Allowed T-State
#
#
# --------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[12/14] Max allowed CPU P-State and T-State (real-time) check"

# --------------------------------------------------------------------------------
IPMICMD_CAT="2E:D3"
# --------------------------------------------------------------------------------
RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
while [ $RETRY != 0 ]; do  #Retry Loop

   #Set z = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
   x=$(IPMICmd 0x20 0x2e 0x00 0xD3 0x57 0x01 0x00 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') # Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = DIMM_TEMP if successful
   cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

   if [ "$cp" = "00" ]
      then                                #complete code=0, successful calling
      #format="2E:D3:XX"
      # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
      # -------------------------------------------------------------------------------------------------------------
      a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')  # a is now equal to byte 6
      b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')  # b is now equal to byte 7
      #
      a=0x$a
      a=$(($a))
      a=$(echo $a | awk '{printf("%i",$1)}')
      if [ $a = 0 ]
      then
         echo_result_by_op "    CPU: Max allowed CPU P-state is P$a (P0 = Turbo, not limited)"
      else
         echo "**  CPU performance capped: Max allowed CPU P-state is P$a (P0 = Turbo, not limited)"
      fi # END if [$a=00]
      #
      b=0x$b
      b=$(($b))
      if [ $b = 0 ]
      then
         echo_result_by_op "    CPU: Max allowed CPU T-state is T$b (T0 = not limited)"
      else
         echo "**  CPU performance capped: Max allowed CPU T-state is T$b (T0 = not limited)"
      fi # END if [$b=00]
      # -------------------------------------------------------------------------------------------------------------
      RETRY=0     #abort the domain loop
   else
      check_cp_then_action $cp "" "C0 DF" "Get CPU's P&T state in [Max allowed CPU P-State and T-State check]" $IPMICMD_CAT
      RETRY=$?
   fi
done              #Exit the For Loop ($y)
fi # if [ $RPTS = 1 ]
# End Section 12 ##############################################################################################

# Start Section 13 ##############################################################################################
if [ $RCPU = 1 ]
then # If there are not any command line parameters, then run the following tests, else the -raci parameter was used, and skip this section
RCPU=0 # Display CPU info once only
# -------------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[13/14] Additional CPU configuration (real-time) check"
# -------------------------------------------------------------------------------------------------------------
# Section: 13.1 Get the CPUs'Pmax, Pn, Power-Unit, TDP
# -------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------
# Get the CPUs'Pmax, Pn, Power-Unit, TDP
# -------------------------------------------------------------------------------------------------------------
#
# Example to get Pmax and Pn
#
# Commands for CPU0:
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x88 0x00 0x15 0x00 0x02
#                                              CPU0
#   Response: 0xbc 0x44 0x00 0x57 0x01 0x00 0xb0 0x04
#                                           **** ^^^^   Pmax = 0x04b0 * Power Unit
#
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0xF8 0x30 0x15 0x00 0x02
#                                              CPU0
#   Response: 0xbc 0x44 0x00 0x57 0x01 0x00 0x30 0x02
#                                           **** ^^^^   Pn = 0x0230 * Power Unit
#
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x8C 0x00 0x15 0x00 0x01
#                                              CPU0
#   Response: 0xbc 0x44 0x00 0x57 0x01 0x00 0x03
#                                           ****   Power_Unit = 1(2^0x03)
#
#   IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0x00 0x15 0x00 0x02
#   Response:  0xbc 0x44 0x00 0x57 0x01 0x00 0xf8 0x02
#                                          **** ^^^^   TDP = 0x02f8 * Power Unit
#
# -------------------------------------------------------------------------------------------------------------
# (1).Get the CPUs' Pmax
# -------------------------------------------------------------------------------------------------------------
# sandy         pci address: 1/10/0/84,88
#                 IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x88 0x00 0x15 0x00 0x02
# haswell       pci address: 1/30/0/84,88
#                 IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x88 0x00 0x1F 0x00 0x02
# -------------------------------------------------------------------------------------------------------------
CPU_ID_ARRAY="40 41 42 43"          #CPU IDs
IPMICMD_CAT="2E:44"
# -------------------------------------------------------------------------------------------------------------
w=1                     # CPU0/1/2/3/4: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]
   do

   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array
      PMAX[$(($w-1))]=0    # clear at first in case of failure IPMI Command

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         if [ $PROCESSOR_TYPE -lt 7 ]; then # SNB/IVB
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x88 0x00 0x15 0x00 0x02 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         elif [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x84 0x20 0x1F 0x00 0x02 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') #PACKAGE_POWER_SKU_CFG B=1:D=30:F=2:O=80h
         elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x88 0x00 0x1F 0x00 0x02 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') #PACKAGE_POWER_SKU B=1:D=30:F=0:O=84h
         elif [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake - CSR cannot be access by 2Eh/44h
            x=
            RETRY=0
            w=$wMAX
            continue
         else
            x=
         fi
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then              #complete code=0, successful calling
            #format="2E:44:XX"
            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')    # a is now equal to DIMM_TEMP which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
            b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # a is now equal to DIMM_TEMP which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
            PMAX2=0x$b$a                        # IPMI response is in LSB, so need to arrange in MSB b then a.  Still need to get and multiply by the POWER_UNIT
            PMAX2=$(($PMAX2))                   # IPMI response is in LSB, so need to arrange in MSB b then a.  Still need to get and multiply by the POWER_UNIT
            PMAX[$(($w-1))]=$PMAX2              # 13-8 to be used
            #echo "    CPU$w: PMAX = $PMAX2"      # per CPU
            # -------------------------------------------------------------------------------------------------------------
            RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "AC" "A2 C0 DF" "Get CPU$w's PMAX in [Get CPU PMAX]" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y)

   fi #if [ $dx != 0 ]; then
   w=$(($w+1))
done                    #Exit the For Loop ($p)

# -------------------------------------------------------------------------------------------------------------
# Section: 13.2 Get the CPUs' PN
# -------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------
# (2).Get the CPUs' PN
# -------------------------------------------------------------------------------------------------------------
# sandy          pci address: 1/10/3/f8
#                    IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0xF8 0x30 0x15 0x00 0x02
# haswell        pci address: 1/30/3/f8
#                    IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0xF8 0x30 0x1F 0x00 0x02
# -------------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:44"
w=1                     # CPU0/1/2/3/4: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]
   do

   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array
      PN[$(($w-1))]=0      # clear at first in case of failure IPMI Command

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         if [ $PROCESSOR_TYPE -lt 7 ]; then # SNB/IVB
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0xF8 0x30 0x15 0x00 0x02 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0xF8 0x30 0x1F 0x00 0x02 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') #PWR_LIMIT_MISC_INFO B1:D30:F3:RF8h
         elif [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake - CSR cannot be access by 2Eh/44h
            x=
            RETRY=0
            w=$wMAX
            continue
         else
            x=
         fi
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]
            then                                #complete code=0, successful calling
            #format="2E:44:XX"
            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')    # a is now equal to Pn which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
            b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # b is now equal to Pn which is the 7th byte stored in the value of x.  This value is in string form, not an integer value
            PN2=0x$b$a                          # IPMI response is in LSB, so need to arrange in MSB b then a. Still need to get and multiply by the POWER_UNIT
            PN2=$(($PN2))                       # IPMI response is in LSB, so need to arrange in MSB b then a. Still need to get and multiply by the POWER_UNIT
            PN2=$(($PN2&0x7fff))                # v1.3 fix: [bit15-0]
            PN[$(($w-1))]=$(($PN2))             # section 13.8 to be used
            #echo "    CPU$w: PN = $PN2"         # per CPU
            # -------------------------------------------------------------------------------------------------------------
            RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "AC" "A2 C0 DF" "Get CPU$w's PN in [Get CPU PN]" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y)

   fi # if [ $dx != 0 ]; then
   w=$(($w+1))
done                    #Exit the For Loop ($p)

# -------------------------------------------------------------------------------------------------------------
# Section: 13.3 Additional (Option need to be specified)
# -------------------------------------------------------------------------------------------------------------
# (3).Get CPU TDP
# -------------------------------------------------------------------------------------------------------------
# sandy       pci address: 1/10/0/0x84
#                 IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0x00 0x15 0x00 0x02
# haswell     pci address: 1/30/0/0x84: Table 71. Summary of Bus: 1, Device: 30, Function: 0 ->
#                 IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x40 0x84 0x00 0x1F 0x00 0x02
# -------------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:44"
w=1                     # CPU0/1/2/3/4: Initialize the While Loop counter to 1, outside the loop
wMAX=4
while [ $w -le $wMAX ]; do
   dx=$((CPU_POPULATED_ARRAY[$(($w-1))]))
   if [ $dx != 0 ]; then      # If cpu is populated

      CPU_ID=$(echo $CPU_ID_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         if [ $PROCESSOR_TYPE -lt 7 ]; then # SNB/IVB
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x84 0x00 0x15 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         elif [ $PROCESSOR_TYPE -eq 13 ]; then #KNL
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x80 0x20 0x1F 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') #PACKAGE_POWER_SKU_CFG B=1:D=30:F=2:O=80h
         elif [ $PROCESSOR_TYPE -ge 7 ] && [ $PROCESSOR_TYPE -lt 20 ]; then #v2.4 Grantley Haswell/Broadwell
            x=$(IPMICmd 0x20 0x2e 0x00 0x44 0x57 0x01 0x00 0x$CPU_ID 0x84 0x00 0x1F 0x00 0x03 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]') #PACKAGE_POWER_SKU B=1:D=30:F=0:O=84h
         elif [ $PROCESSOR_TYPE -eq 20 ]; then #v2.4 Greenlow Skylake - CSR cannot be access by 2Eh/44h
            #Leverage TDP_PCS_ARRAY[], PMAX_PCS_ARRAY[] and PMIN_PCS_ARRAY[] from chk_cpu_tdp_pmin_pmax_by_PCS() in Pre-Checking [8.3]
            #wMAX=$w
            TDP=$((TDP_PCS_ARRAY[$(($w-1))]))
            PMIN=$((PMIN_PCS_ARRAY[$(($w-1))]))
            PMAX2=$((PMAX_PCS_ARRAY[$(($w-1))]))
            POWER_UNIT=$((POWER_UNIT_ARRAY[$(($w-1))]))
            TDP=$(($TDP/$POWER_UNIT))
            PMIN=$(($PMIN/$POWER_UNIT))
            PMAX2=$(($PMAX2/$POWER_UNIT))
            echo "    CPU$w: Pmax = $PMAX2, TDP = $TDP, Pmin = $PMIN (Watts). (Pn not available.)"
            RETRY=0
            w=$wMAX
            continue
         else #unknown platform
            RETRY=0
            w=$wMAX
            continue
         fi
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then      #complete code=0, successful calling
            #format="2E:44:XX"
            #d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')    # a is now equal to Pn which is the 7th byte stored in the value of x.  This value is in string form, not an integer value
            b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # b is now equal to Pn which is the 8th byte stored in the value of x.  This value is in string form, not an integer value
            c=$(echo $x | cut -f 9 -d ' ' | cut -f 2 -d 'x')    # c is now equal to Pn which is the 9th byte stored in the value of x.  This value is in string form, not an integer value
            d=$(echo $x | cut -f 10 -d ' ' | cut -f 2 -d 'x')   # d is now equal to Pn which is the 10th byte stored in the value of x.  This value is in string form, not an integer value
            TDP=0x$b$a                          # IPMI response is in LSB, so need to arrange in MSB b then a.  Still need to get and multiply by the POWER_UNIT
            TDP=$(($TDP))
            TDP=$(($TDP&0x7fff))                # v1.3 fix: [bit15-0]
            if [ $PROCESSOR_TYPE -eq 13 ]; then #KNL PACKAGE_POWER_SKU_CFG doesn't provide TDP power in Bit[14:0].
                TDP=$((TDP_PCS_ARRAY[$(($w-1))]))
            fi
            PMIN=0x$d$c
            PMIN=$(($PMIN))
            PMIN=$(($PMIN&0x7fff))
            # -------------------------------------------------------------------------------------------------------------
            POWER_UNIT=$((POWER_UNIT_ARRAY[$(($w-1))]))
            TDP=$(($TDP/$POWER_UNIT))
            PMIN=$(($PMIN/$POWER_UNIT))
            PMAX2=$((PMAX[$(($w-1))]))
            PMAX2=$(($PMAX2/$POWER_UNIT))
            PN2=$((PN[$(($w-1))]))
            PN2=$(($PN2/$POWER_UNIT))
            echo "    CPU$w: Pmax = $PMAX2, TDP = $TDP, Pn = $PN2, Pmin = $PMIN (Watts)"
            # -------------------------------------------------------------------------------------------------------------
            RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "AC" "A2 C0 DF" "Get CPU$w's TDP in [Get CPU TDP]" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y)
   fi # if [ $dx != 0 ]; then
   w=$(($w+1))
done                    #Exit the For Loop ($p)
# End Section 13 ##############################################################################################
fi # [ $RCPU = 1 ]

#------------------------------------------------------------------------------------------------------
# Section 14: Get the Aditional Configuration with PSU information
#------------------------------------------------------------------------------------------------------

if [ $RPSU = 1 ]; then  # If there are not any command line parameters, then run the following tests, else the -raci parameter was used, and skip this section
#RPSU=0 # Display PSU info once only
#------------------------------------------------------------------------------------------------------
# Section 14 ##############################################################################################
#------------------------------------------------------------------------------------------------------
# Section 14: Get the Node Manager K-Coefficient
#
# Example to get the Node Manager K-Coefficient
#
# F1h command:  IPMICmd 0x20 0x2e 0x00 0xf1 0x57 0x01 0x00
#
# Example Response: 0xbc 0xf1 0x00 0x57 0x01 0x00 0x5f
#                                                 ****  Byte 6 is the K-Coefficient in %
#
#------------------------------------------------------------------------------------------------------
echo_result_by_op " "
echo_result_by_op "[14/14] Additional PSU configuration and status check for Monolithic systems"
echo_result_by_op "        Additional Blade power info for Modular systems"

#------------------------------------------------------------------------------------------------------
IPMICMD_CAT="CP"  # default completion code message, "2E:F1" None of specific completion code in here.
#------------------------------------------------------------------------------------------------------
d=0
RETRY=1                # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
while [ $RETRY != 0 ]; do  #Retry Loop

   #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
   x=$(IPMICmd 0x20 0x2e 0x00 0xf1 0x57 0x01 0x00 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')   # Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = K-Coefficient if successful
   cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x')               # c=completion code, 0x00 means the IPMI command succeeded, cut out all the bytes other than the completion code, then cut out the leading "0x"

   if [ "$cp" = "00" ]
      then                                #complete code=0, successful calling
      #format="CP"
      # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
      # -------------------------------------------------------------------------------------------------------------
      d=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')  # d is now equal to K-coefficient which is the 7th byte stored in the value of x.  This value is in string form, not an integer value
      d=0x$d                                                       # d is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
      d=$(($d))                                                      # d is now equal to the decimal value, an integer, of the K-Coefficient in percent, and math can now be performed on this number
      echo_result_by_op "    NM HW Protection K-Coefficient is = $d %"
      # -------------------------------------------------------------------------------------------------------------
      RETRY=0                          #abort the retry loop
   else
      check_cp_then_action $cp "" "C0 DF" "[Get HW K-Coefficient]" $IPMICMD_CAT
      RETRY=$?
   fi
done              #Exit the For Loop ($y)

# -------------------------------------------------------------------------------------------------------------
# Section: 14.1 Get PSU Status Registers
# -------------------------------------------------------------------------------------------------------------
# Get PSU Status Registers
#
# Example Read Byte Command
# IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x02 0xb0 0x08 0x00 0x01 0x01 0x7A (Command is 7A)
#
# Response:  0xbc 0xd9 0x00 0x57 0x01 0x00 0x00
#                                          ****  This is the status byte for the command 7A
#  7Ah STATUS_VOUT
#  7Bh STATUS_IOUT
#  7Ch STATUS_INPUT
#  7Dh STATUS_TEMPERATURE
#  7Eh STATUS_CML
#  7Fh STATUS_OTHER                      # Removed since not supported any more
#  80h STATUS_MFR_SPECIFIC               # Removed since not supported any more
#  81h STATUS_FANS_1_2
#
#  DCh OCW_SETTING_READ
#  DDh OCW_STATUS
#  DEh OCW_COUNTER
#  EDh LATCH_CONTROL
#
#  Get STATUS bytes from PSU1/2
#
#------------------------------------------------------------------------------------------------------
if [ $GENERATION_INFO == "0x10" ] || [ $GENERATION_INFO == "0x20" ]; then # 12G/13G: monolithic only
dsp_psu_status_regs                       # This will set $PSU_MUX_ADR_ARRAY which based on ICON or others system.
disp_psu_status_dc_reg                    # Will bypass the none-13G psu
chk_psu_ocw_counter                       # Will bypass the none-13G psu: counters of OCW1, OCW2, OCW3, IOUT_OC_WARNING
disp_psu_peak_current_e9_reg              # Will bypass the none-13G psu
#update_PSU_OCW_COUNTERS                  # TBD ??? (last rev. was exist)

# -------------------------------------------------------------------------------------------------------------
# Section: 14.2 Get PSU IOUT Over Current Warning
# -------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------
# Get PSU IOUT Over Current Warning
# -------------------------------------------------------------------------------------------------------------
# Example command to get the PSU IOUT Over Current Warning
#
# Command for PSU1:  IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0xb0 0x08 0x00 0x01 0x02 0x4A
# Command for PSU2:  IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0xb0 0x0a 0x00 0x01 0x02 0x4A
#                                                                         **** Platform specific MUX Setting (will be different for 4-Socket Systems)
# Response:  0xbc 0xd9 0x00 0x57 0x01 0x00 0xb8 0xea
#                                          **** ^^^^   Data encoded in Linear-11 Format with LSB First.  MSB data is 0xeab8, need to decode
#
# -------------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:D9"
# -------------------------------------------------------------------------------------------------------------
# To check planer type to identify the useage.
if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
   PSU_MUX_ADR_ARRAY="18 1A"
   wMAX=2
elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
   PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
   wMAX=4                           # Up to 4 PSU supports
else
   PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
   wMAX=2                           # Generic PSU
fi
#------------------------------------------------------------------------------------------------------
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
#wMAX=2
while [ $w -le $wMAX ]; do

   if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ]; then
      PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0xb0 0x$PSU_MUX 0x00 0x01 0x02 0x4A | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]
            then                 #complete code=0, successful calling
            #format="2E:D9"
            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')    # a is now equal to LSB which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
            b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # a is now equal to LSB which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
            # Start Linear-11 decoding with a=LSB and b=MSB
            iout=0x$b$a             # w = to the two byte response of the IPMI command in MSB format win Linear-11 encoded format
            c=$(($iout&0xF800))     # Mask off all the bits except [15:11]  bitwise and with 1111100000000000 = 0xF800
            d=$(($iout&0x07FF))     # Mask off all the bits except [10:0]  bitwise and with 0000011111111111 = 0x07FF
            c=$(($c>>11))           # Bit Shift right 11 times
            #                       # Start Linear-11 Decode
            #----------------------------------------------------------------------------------------------------------
            #if [ $c -gt 15 ]     # if n > 15
            #   then              # then n=32-c
            #   n=$((32-$c))
            #   n=$((2**$n))        # n=2^n
            #   DECODE_VALUE=$(($d/$n)) # decoded value = d*2^-n
            #else
            #   # in here, it should not be happened.
            #   n=$c
            #   n=$((2**$n))        # n=2^n
            #   DECODE_VALUE=$(($d*$n)) # decoded value = d*2^-n
            #fi
            #----------------------------------------------------------------------------------------------------------
            pout_max=$((POUT_MAX[$w]))             # 1 base
            pout_exp_max=$((POUT_EXP_MAX[$w]))     # 1 base
            if [ $((PSU_GEN_ARRAY[$w])) = 12 ]; then
               NOMINAL_VOUT=12
            else
               NOMINAL_VOUT=12.2
            fi
            if [ $c -gt 15 ]; then
               OCW_AMPS=$(echo $d $c | awk '{printf("%.3f",($1/(2**(32-$2))))}')
               if [ $pout_exp_max -gt 15 ]; then
                   RATING_VALUE=$(echo $d $c $pout_max $pout_exp_max $NOMINAL_VOUT | awk '{printf("%.1f",(100*(((($1/(2**(32-$2)))*$5)/($3/(2**(32-$4)))))))}' )
               else
                   RATING_VALUE=$(echo $d $c $pout_max $pout_exp_max $NOMINAL_VOUT | awk '{printf("%.1f",(100*(((($1/(2**(32-$2)))*$5)/($3*(2**$4))))))}' )
               fi
            else
               OCW_AMPS=$(echo $d $c | awk '{printf("%.3f",($1*(2**$2)))}')
               if [ $pout_exp_max -gt 15 ]; then
                   RATING_VALUE=$(echo $d $c $pout_max $pout_exp_max $NOMINAL_VOUT | awk '{printf("%.1f",(100*(((($1*(2**$2))*$5)/($3/(2**(32-$4)))))))}' )
               else
                   RATING_VALUE=$(echo $d $c $pout_max $pout_exp_max $NOMINAL_VOUT | awk '{printf("%.1f",(100*(((($1*(2**$2))*$5)/($3*(2**$4))))))}' )
               fi
            fi
            #----------------------------------------------------------------------------------------------------------
            #n=$((2**$n))        # n=2^n
            #DECODE_VALUE=$(($d/$n)) # decoded value = d*2^-n
            #OCW_AMPS=$(($VALUE_LAST))
            #OCW_WATTS=$(($OCW_AMPS*12))        # 13G: 12.2V, 12G: 12V
            if [ $c -gt 15 ]; then
               OCW_WATTS=$(echo $d $c $NOMINAL_VOUT | awk '{printf("%i",($1/(2**(32-$2))*$3+0.5))}')
            else
               OCW_WATTS=$(echo $d $c $NOMINAL_VOUT | awk '{printf("%i",($1*(2**$2)*$3+0.5))}')
            fi
            #
            # END Linear-11 decoding with a=LSB and b=MSB.  The decoded data is stored in OCW_AMPS
            #
            echo_result_by_op "    PSU$w: Over Current Warning Limit = ${OCW_AMPS}A (${OCW_WATTS}W at ${NOMINAL_VOUT}V, ${RATING_VALUE}% PSU)"
            # -------------------------------------------------------------------------------------------------------------
           RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) in [Get PSU OC]" $IPMICMD_CAT
            RETRY=$?
         fi
      done              #Exit the For Loop ($y)
   fi # if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ]; then

   w=$(($w+1))
done                    #Exit the For Loop ($w)

# -------------------------------------------------------------------------------------------------------------
# Section: 14.3 Get PSU1/PSU2 Pout
# -------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------
# Get PSU1/PSU2 Pout
# -------------------------------------------------------------------------------------------------------------
#
# Example to get the PSU Pout
#
# Command for PSU1:  IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0xb0 0x08 0x00 0x01 0x02 0x96
# Command for PSU2:  IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0xb0 0x0a 0x00 0x01 0x02 0x96
#                                                                         ****                         Platform specific MUX setting (will be different for 4-socket systems)
#
# Response:  0xbc 0xd9 0x00 0x57 0x01 0x00 0x02 0xfa
#                                          **** ^^^^   Data encoded in Linear-11 Format with LSB First.  MSB data is 0xfa02, need to decode
#
# -------------------------------------------------------------------------------------------------------------
IPMICMD_CAT="2E:D9"
# -------------------------------------------------------------------------------------------------------------
# To check planer type to identify the useage.
if [ $PLANTYPE = 11 ]; then         # Planer type id: ICON platform system
   PSU_MUX_ADR_ARRAY="18 1A"
   wMAX=2
elif [ $PLANTYPE = 13 ]; then       # Planer type id: EQUINOX platform system
   PSU_MUX_ADR_ARRAY="0C 0D 0E 0F"
   wMAX=4                           # Up to 4 PSU supports
else
   PSU_MUX_ADR_ARRAY="08 0A"        # PSU Bus IDs: 08:PSU2, 0A:PSU1
   wMAX=2                           # Generic PSU
fi
# -------------------------------------------------------------------------------------------------------------
w=1                     # PSU1/2: Initialize the While Loop counter to 1, outside the loop
#wMAX=2
while [ $w -le $wMAX ]; do

   if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ]; then

      PSU_MUX=$(echo $PSU_MUX_ADR_ARRAY | cut -f $w -d ' ')  # Parse the array, and grab the y'th value in the space delimited array

      RETRY=1                  # Try up to this number of IPMI command retrys, includes first shoot. Totally 4 shoots in the loop.
      while [ $RETRY != 0 ]; do  #Retry Loop

         #Set x = to the response of the IPMI command without the "The response data is:" header, and x.byte6 = The Target of this section if successful
         x=$(IPMICmd 0x20 0x2e 0x00 0xd9 0x57 0x01 0x00 0x06 0xb0 0x$PSU_MUX 0x00 0x01 0x02 0x96 | tail -n 1 | tr '[a-w, y-z]' '[A-W, Y-Z]')
         cp=$(echo $x | cut -f 3 -d ' ' | cut -f 2 -d 'x') # c=completion code, 0x00 means the IPMI command succeeded

         if [ "$cp" = "00" ]; then      #complete code=0, successful calling
            #format="2E:D9"
            # d(data) is now equal to the hex value.  This adds a 0x to the string, which converts 'a' from a string to a number
            # -------------------------------------------------------------------------------------------------------------
            a=$(echo $x | cut -f 7 -d ' ' | cut -f 2 -d 'x')    # a is now equal to LSB which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
            b=$(echo $x | cut -f 8 -d ' ' | cut -f 2 -d 'x')    # a is now equal to LSB which is the 6th byte stored in the value of x.  This value is in string form, not an integer value
            #
            # Start Linear-11 decoding with a=LSB and b=MSB
            #
            # Example Decode:
            #       0xbc 0xd9 0x00 0x57 0x01 0x00 0x20 0xe3
            #       (Data is LSB first) Data = 0xe3 0x20
            #       Data = 0xE320 = 1110001100100000
            #       Data = (5bits)(11bits) = (B)(Y) = (11100)(01100100000), = (28d) (800d)
            #       "IF B>15
            #       Then N = 0 - (32 - B)
            #       Else N = B
            #       (Example B is > 15, so N = 0 - (32 - 28) = -4)"
            #       Data = Y*2^N = 800 * 2^-4 = 50W
            #       Data = 50W
            pout=0x$b$a             # w = to the two byte response of the IPMI command in MSB format win Linear-11 encoded format
            c=$(($pout&0xF800))     # Mask off all the bits except [15:11]  bitwise and with 1111100000000000 = 0xF800
            d=$(($pout&0x07FF))     # Mask off all the bits except [10:0]  bitwise and with 0000011111111111 = 0x07FF
            c=$(($c>>11))        # Bit Shift right 11 times
            #                    # Start Linear-11 Decode
            #n=25                 # Initialize n
            #if [ $c -gt 15 ]; then  # if n > 15: Data = Y/(2^N)
            #   n=$((32-$c))
            #   n=$((2**$n))        # n=2^n
            #   DECODE_VALUE=$(($d/$n)) # decoded value = d*2^-n
            #else                    # if n < 15: Data = Y*(2^N)
            #   n=$c
            #   n=$((2**$n))        # n=2^n
            #   DECODE_VALUE=$(($d*$n)) # decoded value = d*2^-n
            #fi
            if [ $c -gt 15 ]; then
               VALUE_LAST=$(echo $d $c | awk '{printf("%i",($1/(2**(32-$2))))}')
            else
               VALUE_LAST=$(echo $d $c | awk '{printf("%i",($1*(2**$2)))}')
            fi
            # ----------------------------------------------------------------
            # JamesH: Potential bugy since this is only apply if n<0
            #n=$((2**$n))        # n=2^n
            #DECODE_VALUE=$(($d/$n)) # decoded value = d*2^-n
            # ----------------------------------------------------------------
            #
            # END Linear-11 decoding with a=LSB and b=MSB.  The decoded data is stored in DECODE_VALUE
            #
            echo_result_by_op "    PSU$w: Real-time Pout = $VALUE_LAST Watts"
            # -------------------------------------------------------------------------------------------------------------
            RETRY=0                          #abort the retry loop
         else
            check_cp_then_action $cp "80" "81 C0 DF" "PSU$w (at 0x$PSU_MUX mux address) in [Get PSU Pout]" $IPMICMD_CAT
            RETRY=$?
         fi
      done                 #Exit the For Loop ($y)
   fi # if [ $((PSU_POPULATED_ARRAY[$w])) = 1 ]; then

   w=$(($w+1))
done                    #Exit the For Loop ($w)
elif [ $GENERATION_INFO == "0x11" ] || [ $GENERATION_INFO == "0x21" ]; then   # 0x11 = 12G Modular, 0x21 = 13G Modular

# -------------------------------------------------------------------------------------------------------------
# Section: 14.4 Get Blade power and power limit information (Modular) If it is a modular system.
# -------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------
# Get Blade power and power limit information (Modular) If it is a modular system.
# -------------------------------------------------------------------------------------------------------------
#
# Get Blade power and power limit information
#     Offset 60:62 = Blade Power Consumption
#     Offset 63:65 = Blade power warning threshold
#     Offset 66:68 = Blade power overlimit thresshold
# -------------------------------------------------------------------------------------------------------------
xx=$(MemAccess -rb 0x14000060 | tail -n +4 | head -n 1)    # only grab the 4'th line (0x14000060), and next useful bytes order is starting on N+3 (1 base)

# Example resulting string assigned to $xx
# "0x14000060 = 00 0e 00 0f 08 01 0f 0d : 01 00 00 00 00 00 00 00"

x=$(echo $xx | cut -f 3 -d ' ' | cut -c 2)                  # only grab the lower nibble of each byte, and this value is a string
y=$(echo $xx | cut -f 4 -d ' ' | cut -c 2)                  # only grab the lower nibble of each byte, and this value is a string
z=$(echo $xx | cut -f 5 -d ' ' | cut -c 2)                  # only grab the lower nibble of each byte, and this value is a string
#echo "$z $y $x"
bpc=0x$z$y$x         # This will concatenate the strings to make 12-bits in MSB order
bpc=$(($bpc))        # This will concatenate the strings to make 12-bits in MSB order

x=$(echo $xx | cut -f 6 -d ' ' | cut -c 2)                  # only grab the lower nibble of each byte, and this value is a string
y=$(echo $xx | cut -f 7 -d ' ' | cut -c 2)                  # only grab the lower nibble of each byte, and this value is a string
z=$(echo $xx | cut -f 8 -d ' ' | cut -c 2)                  # only grab the lower nibble of each byte, and this value is a string
#echo "$z $y $x"
bpw=0x$z$y$x         # This will concatenate the strings to make 12-bits in MSB order
bpw=$(($bpw))        # This will concatenate the strings to make 12-bits in MSB order

x=$(echo $xx | cut -f 9 -d ' ' | cut -c 2)                  # only grab the lower nibble of each byte, and this value is a string
y=$(echo $xx | cut -f 10 -d ' ' | cut -c 2)                 # only grab the lower nibble of each byte, and this value is a string
z=$(echo $xx | cut -f 12 -d ' ' | cut -c 2)                 # only grab the lower nibble of each byte, and this value is a string
#echo "$z $y $x"
bpov=0x$z$y$x        # This will concatenate the strings to make 8-bits in MSB order
bpov=$(($bpov))      # This will concatenate the strings to make 8-bits in MSB order

# -------------------------------------------------------------------------------------------------------------
# Get SPL/GoTo value if it is a 13G modular system.
#     Offset 5B = Pwr_Threshold[7:4]
#     Offset 5A = Pwr_Threshold[3:0]
# -------------------------------------------------------------------------------------------------------------
#     SPL/GoTo value = Pwr_Threshold[7:0] * scalar + offset
#           Scalar  Offset
#       QH   4.8W    57.6W
#       HH   9.6W   115.2W
#       FH  19.2W   230.4W
# -------------------------------------------------------------------------------------------------------------
xx=$(MemAccess -rb 0x14000050 | tail -n +4 | head -n 1)    # only grab the 4'th line (0x14000050)

x=$(echo $xx | cut -f 14 -d ' ' | cut -c 2)                # only grab the lower nibble of 0x5A, and this value is a string
y=$(echo $xx | cut -f 15 -d ' ' | cut -c 2)                # only grab the lower nibble of 0x5B, and this value is a string

SPL=0x$y$x         # This will concatenate the strings to make 12-bits in MSB order
SPL=$(($SPL))      # This will concatenate the strings to make 12-bits in MSB order

# -------------------------------------------------------------------------------------------------------------
if [ $GENERATION == 13 ]; then    # 13G Modular
   BLADE_PQ=$(echo $bpc | awk '{printf("%8.3f",($1*0.6))}')
   BLADE_PH=$(echo $bpc | awk '{printf("%8.3f",($1*0.6))}')
   BLADE_PF=$(echo $bpc | awk '{printf("%8.3f",($1*1.2))}')
   echo "    Blade Power Consumption         : Quarter-Height Blade = $BLADE_PQ Watts"
   echo "                                    : Half-Height Blade    = $BLADE_PH Watts"
   echo "                                    : Full-Height Blade    = $BLADE_PF Watts"
   BLADE_PQ=$(echo $bpw | awk '{printf("%8.3f",($1*0.6))}')
   BLADE_PH=$(echo $bpw | awk '{printf("%8.3f",($1*0.6))}')
   BLADE_PF=$(echo $bpw | awk '{printf("%8.3f",($1*1.2))}')
   echo "    Blade Power Warning Threshold   : Quarter-Height Blade = $BLADE_PQ Watts"
   echo "                                    : Half-Height Blade    = $BLADE_PH Watts"
   echo "                                    : Full-Height Blade    = $BLADE_PF Watts"
   BLADE_PQ=$(echo $bpov | awk '{printf("%8.3f",($1*0.6))}')
   BLADE_PH=$(echo $bpov | awk '{printf("%8.3f",($1*0.6))}')
   BLADE_PF=$(echo $bpov | awk '{printf("%8.3f",($1*1.2))}')
   echo "    Blade Power Overlimit Threshold : Quarter-Height Blade = $BLADE_PQ Watts"
   echo "                                    : Half-Height Blade    = $BLADE_PH Watts"
   echo "                                    : Full-Height Blade    = $BLADE_PF Watts"
   BLADE_PQ=$(echo $SPL | awk '{printf("%8.3f",($1*4.8+57.6))}')
   BLADE_PH=$(echo $SPL | awk '{printf("%8.3f",($1*9.6+115.2))}')
   BLADE_PF=$(echo $SPL | awk '{printf("%8.3f",($1*19.2+230.4))}')
   echo "    Blade SPL/GoTo Value            : Quarter-Height Blade = $BLADE_PQ Watts"
   echo "                                    : Half-Height Blade    = $BLADE_PH Watts"
   echo "                                    : Full-Height Blade    = $BLADE_PF Watts"
elif [ $GENERATION == 12 ]; then  # 12G Modular
   BLADE_PQ=$(echo $bpc | awk '{printf("%8.3f",($1*0.5952))}')
   BLADE_PH=$(echo $bpc | awk '{printf("%8.3f",($1*0.5952))}')
   BLADE_PF=$(echo $bpc | awk '{printf("%8.3f",($1*1.19))}')
   echo "    Blade Power Consumption         : Quarter-Height Blade = $BLADE_PQ Watts"
   echo "                                    : Half-Height Blade    = $BLADE_PH Watts"
   echo "                                    : Full-Height Blade    = $BLADE_PF Watts"
   BLADE_PQ=$(echo $bpw | awk '{printf("%8.3f",($1*0.5952))}')
   BLADE_PH=$(echo $bpw | awk '{printf("%8.3f",($1*0.5952))}')
   BLADE_PF=$(echo $bpw | awk '{printf("%8.3f",($1*1.19))}')
   echo "    Blade Power Warning Threshold   : Quarter-Height Blade = $BLADE_PQ Watts"
   echo "                                    : Half-Height Blade    = $BLADE_PH Watts"
   echo "                                    : Full-Height Blade    = $BLADE_PF Watts"
   BLADE_PQ=$(echo $bpov | awk '{printf("%8.3f",($1*0.5952))}')
   BLADE_PH=$(echo $bpov | awk '{printf("%8.3f",($1*0.5952))}')
   BLADE_PF=$(echo $bpov | awk '{printf("%8.3f",($1*1.19))}')
   echo "    Blade Power Overlimit Threshold : Quarter-Height Blade = $BLADE_PQ Watts"
   echo "                                    : Half-Height Blade    = $BLADE_PH Watts"
   echo "                                    : Full-Height Blade    = $BLADE_PF Watts"
fi
# -------------------------------------------------------------------------------------------------------------
# END Get Blade power and power limit information
# -------------------------------------------------------------------------------------------------------------
#else          # TBD: 0x22: 13G iDRAC DCS/PEC
fi # if [ $GENERATION_INFO == "0x10" ]; then

if [ $CLEAR_PSU -eq 1 ] ; then
   reset_psu_status
   echo_result_by_op "    Cleared PSU Fault bits"
fi

# End Section 14 ##############################################################################################
fi # [ $RPSU = 1 ]

if [ $LOOP_MODE = 0 ]; then
   tm=$(date)
   echo " "
   echo "End Throttle Detection Script: throttle.sh v$THROTTLE_VER"
   echo "Time log: $tm"
   echo " "
   exit 0
fi
# -------------------------------------------------------------------------------------------------------------

# End Section Loop ##############################################################################################
done # while [ true ]; do

# -------------------------------------------------------------------------------------------------------------
# Infinite Loop
# -------------------------------------------------------------------------------------------------------------

