#!/etc/bash
#ME Triage v0.1 by Kyle Cross
##Initial release, with decode for Get Device ID and Get Self-test Results.
##Future upgrades - decode GPIO 162 state

#ME Triage v0.2 by Jordan Chin
##Added NMLC function

#ME Triage v0.3 by Jordan Chin + Kelvin Huang
##Added MEFS1 and MEFS2 capture
##Added Get Exception Data capture (14G use only)
##Prints out human readable ME FW version by default
##Prints out human readable MEFS1 and MEFS2 by default
##Added progress bar for SUSRAM read

#ME Triage v0.4 by Jordan Chin
##Added IPMI reset command
##Added GetDeviceID command

#ME Triage v0.5 by Jordan Chin
##Added system config dump for Intel BKC

#ME Triage v0.6 by Kelvin
##Fixed indentation, trimmed tailing spaces, changed tab to space
##Fixed condition checking in status subroutine
##Enhanced Get SelfTest Result response parsing in status subroutine
##Added option to restore ME to factory default
##Added option to set ME into recovery image
##Added option to rescue ME by toggling recovery jumper

date
echo "ME Triage v0.6"
echo "Optional Parameter: "
echo "-status       Display ME status (ME FW version, MEFS registers, recovery reason)"
echo "-nmlc         Runs NodeManager Log Capture function (output: /tmp/metriage/nmlclog.txt)"
echo "-reset        Send ME firmware IPMI reset command"
echo "-getdeviceid  Send ME firmware IPMI GetDeviceID command"
echo "-bkc          Display system configuration for Intel BKC"
echo "-factory      Restore ME to factory default"
echo "-recovery     Set ME into Recovery image by ME FW Recovery Jumper"
echo "-rescue       Toggle ME FW Recovery Jumper and restart ME"
echo

mkdir /tmp/metriage > /dev/null 2>&1

function Run_BKC
{

    /bin/MemAccess -rb 14000000 | grep '0x14000000' > /tmp/xbus.txt
    MAJOR_REV=$(cut -c 15 /tmp/xbus.txt)
    MINOR_REV=$(cut -c 18 /tmp/xbus.txt)
    MAINT_REV=$(cut -c 21 /tmp/xbus.txt)
    PLANAR_REV=$(cut -c 41 /tmp/xbus.txt)

    IPMICmd 20 2e 0 e1 2 18 1 | grep '0x' > /tmp/getdeviceid.txt

    racadm get BIOS.SysInformation > /tmp/bios.txt
    BIOS_VERSION=$(cat /tmp/bios.txt | grep 'BiosVersion' | sed "s/^#SystemBiosVersion=//")
    ME_VERSION=$(cat /tmp/bios.txt | grep 'SystemMeVersion' | sed "s/^#SystemMeVersion=//")
    MODEL_NAME=$(cat /tmp/bios.txt | grep 'SystemModelName' | sed "s/^#SystemModelName=//")

    racadm get BIOS.ProcSettings > /tmp/bios.txt
    CPU_TYPE=$(cat /tmp/bios.txt | grep 'Proc1Brand' | sed "s/^#Proc1Brand=//")
    CPU_ID=$(cat /tmp/bios.txt | grep 'Proc1Id' | sed "s/^#Proc1Id=//")

    echo
    echo "$MODEL_NAME"
    echo "BIOS Version = $BIOS_VERSION"
    echo "ME Version = $ME_VERSION"
    echo "CPLD Rev = $MAJOR_REV.$MINOR_REV.$MAINT_REV"
    echo "Planar Rev = $PLANAR_REV"
    echo "CPU Type = $CPU_TYPE"
    echo "CPU ID = $CPU_ID"
    echo
    echo "Get Device ID Results:"
    cat /tmp/getdeviceid.txt
    echo
    echo "IDRAC Build Info:"
    cat /etc/fw_ver

}

function Run_NMLC
{
    echo "Running NodeManager Log Capture. Please wait several minutes."

    date > /tmp/metriage/nmlclog.txt

    printf "\n# Get Device ID\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting Device ID... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x02 0x18 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"
    # pass criteria: the last byte of response = 0x01

    printf "\n# Get Self Test Results\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting Self Test Results... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x02 0x18 0x04 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"
    # pass criteria: byte1 of response = 0x0 or 0x80 or 0x82

    printf "\n# Get FW Status Registers - MEFS1 and MEFS2\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting FW Status Registers... "
    if [ "$aa" == "04" ]; then
        IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x00 0x00 0x01 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    else
        IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x00 0x00 0x01 0x02 | grep '0x' >> /tmp/metriage/nmlclog.txt
    fi
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x00 0x00 0x01 0x02 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n# Get Exception Log (13G)\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting Exception Log (13G)... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x08 0x28 0x43 0x00 0x00 0x00 0x00 0x00 0xff | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x08 0x28 0x43 0x00 0x00 0x01 0x00 0x00 0xff | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x08 0x28 0x43 0x00 0x00 0x02 0x00 0x00 0xff | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x08 0x28 0x43 0x00 0x00 0x03 0x00 0x00 0xff | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x08 0x28 0x43 0x00 0x00 0x04 0x00 0x00 0xff | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"
    #pass criteria: rsp=0xc9 for all of the commands

    printf "\n# Get Exception Data (14G)\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting Exception Data (14G)... "
    IPMICmd 0x20 0x2e 0x00 0xe6 0x0b 0xc0 0x26 0x57 0x01 0x00 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n# Get HECI-1 Statistics\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting HECI-1 Statistics... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0a 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x02 0x87 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n# Get HECI-2 Statistics\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting HECI-2 Statistics... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0a 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x02 0x8d 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n# Get IPMB Statistics\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting IPMB Statistics... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0a 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x02 0x7d 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n# Get PECI Statistics (CPU 0 and 1)\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting PECI Statistics (CPU 0 and 1)... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0b 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x03 0xc0 0x01 0x00 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0b 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x03 0xc0 0x01 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n# Get PECI Extended Statistics (CPU 0 and 1)\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting PECI Extended Statistics (CPU 0 and 1)... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0b 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x03 0xc1 0x01 0x00 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0b 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x03 0xc1 0x01 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n# Read Memory (SUSRAM) from 0x8000b000 to 0x800b7fc step=4\n" >> /tmp/metriage/nmlclog.txt
    printf "Reading Memory (SUSRAM) from 0x8000b000 to 0x800b7fc... This may take a while.\n"
    MEMCOUNTER=45056
    COUNTER=0
    MYPROGRESS=0
    while [ $MEMCOUNTER -le 47100 ]; do
        printf '%x' $MEMCOUNTER > /tmp/tmptxt
        msb=$(cat /tmp/tmptxt | cut -c1-2)
        lsb=$(cat /tmp/tmptxt | cut -c3-4)
        IPMICmd 0x20 0x2e 0x00 0xe1 0x0e 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x06 0x27 0x01 0x$lsb 0x$msb 0x00 0x80 | grep '0x' >> /tmp/metriage/nmlclog.txt
        MEMCOUNTER=$(($MEMCOUNTER+4))
        COUNTER=$(($COUNTER+1))
        echo -ne "Progress: $COUNTER/512\r"
    done
    printf "Progress: $COUNTER/512 DONE!\n"

    printf "\n# Read Power Data registers\n" >> /tmp/metriage/nmlclog.txt
    printf "Reading Power Data registers... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x9f 0x01 0x03 0x03 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x9f 0x01 0x04 0x03 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x9f 0x01 0x05 0x03 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x9f 0x01 0x00 0x03 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n# Get SMT Statistics per interface\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting SMT Statistics per interface... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0xc8 0x01 0x01 0x00 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0xc8 0x01 0x01 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0xc8 0x01 0x02 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n#Read Reset Supression Sensor state\n" >> /tmp/metriage/nmlclog.txt
    printf "Reading Reset Supression Sensor state... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x03 0x10 0x2d 0xc5 | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"

    printf "\n#Get Exception Data\n" >> /tmp/metriage/nmlclog.txt
    printf "Getting Exception Data... "
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x00 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x01 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x02 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x03 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x04 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x05 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x06 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x07 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x08 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x09 | grep '0x' >> /tmp/metriage/nmlclog.txt
    IPMICmd 0x20 0x2e 0x00 0xe1 0x06 0xB8 0xE6 0x57 0x01 0x00 0x0a | grep '0x' >> /tmp/metriage/nmlclog.txt
    printf "DONE!\n"
    #pass criteria: rsp=0xd6 for all of the commands

}

function Reset_ME
{
    echo "Attempting to reset ME FW"
    IPMICmd 0x20 0x2e 0x00 0xe1 0x02 0x18 0x02

}

function Set_ME_Recovery
{
    echo "Attempting to put ME FW into recovery mode"
    testgpio 1 162 3 1 > /dev/null 2>&1 # set GPIO162 to output
    testgpio 1 162 0 0 > /dev/null 2>&1  # set GPIO162 low
    IPMICmd 0x20 0x2e 0x00 0xe1 0x02 0x18 0x02 > /dev/null 2>&1 # reset ME
    sleep 5
    testgpio 1 162 0 1 > /dev/null 2>&1  # set GPIO162 high
    testgpio 1 162 3 0 > /dev/null 2>&1  # set GPIO162 to input
    Get_ME_Status
}

function Rescue_ME
{
    echo "Attempting to toggle ME FW Recovery Jumper and restart ME"
    testgpio 1 162 3 1 > /dev/null 2>&1 # set GPIO162 to output
    testgpio 1 162 0 0 > /dev/null 2>&1  # set GPIO162 low
    testgpio 1 162 0 1 > /dev/null 2>&1  # set GPIO162 high
    testgpio 1 162 3 0 > /dev/null 2>&1  # set GPIO162 to input
    IPMICmd 0x20 0x2e 0x00 0xe1 0x02 0x18 0x02 > /dev/null 2>&1 # reset ME
    sleep 5
    Get_ME_Status
}

function Get_ME_DeviceID
{
    echo "Sending GetDeviceID command"
    IPMICmd 20 2e 0 e1 2 18 1
}

function Load_ME_Factory_Deafult
{
    echo "Attempting to restore Factory Default variable values and restart ME"
    IPMICmd 0x20 0x2e 0x00 0xdf 0x57 0x01 0x00 0x02

}

function Get_ME_Status
{

    ## Check if ME is in recovery
    IPMICmd 20 2e 0 e1 2 18 1 | grep '0x' > /tmp/metriage/getdeviceid.txt

    ## Check if CC is 0x00
    compcode=$(cut -f 3 -d ' ' /tmp/metriage/getdeviceid.txt)
    if [ $compcode != "0x00" ]; then
        echo "ME Get Device ID failed. (CC=$compcode) !!!!!"
        return
    fi

    GetDeviceIDPayload=$(tail -c 6 /tmp/metriage/getdeviceid.txt)

    aa=$(cut -c 28-29 /tmp/metriage/getdeviceid.txt)
    b=$(cut -c 33 /tmp/metriage/getdeviceid.txt)
    c=$(cut -c 34 /tmp/metriage/getdeviceid.txt)
    dd=$(cut -c 78-79 /tmp/metriage/getdeviceid.txt)
    d=$(cut -c 83 /tmp/metriage/getdeviceid.txt)

    echo "ME Firmware Version: $aa.0$b.0$c.$dd$d"

    if [ $aa == "04" ]; then # SPS 4.0
        IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x00 0x00 0x01 0x01 | grep '0x' > /tmp/metriage/getfwstatus.txt
    else                       # SPS 3.0 or earlier
        IPMICmd 0x20 0x2e 0x00 0xe1 0x0c 0xc0 0x26 0x57 0x01 0x00 0x04 0x06 0x04 0x00 0x00 0x01 0x02 | grep '0x' > /tmp/metriage/getfwstatus.txt
    fi

    compcode=$(cut -f 3 -d ' ' /tmp/metriage/getfwstatus.txt)
    if [ $compcode == "0x00" ]; then
            mefs1a=$(cut -c 73-74 /tmp/metriage/getfwstatus.txt)
            mefs1b=$(cut -c 78-79 /tmp/metriage/getfwstatus.txt)
            mefs1c=$(cut -c 83-84 /tmp/metriage/getfwstatus.txt)
            mefs1d=$(cut -c 88-89 /tmp/metriage/getfwstatus.txt)
            mefs2a=$(cut -c 93-94 /tmp/metriage/getfwstatus.txt)
            mefs2b=$(cut -c 98-99 /tmp/metriage/getfwstatus.txt)
            mefs2c=$(cut -c 103-104 /tmp/metriage/getfwstatus.txt)
            mefs2d=$(cut -c 108-109 /tmp/metriage/getfwstatus.txt)
            echo "MEFS1: 0x$mefs1d$mefs1c$mefs1b$mefs1a , MEFS2: 0x$mefs2d$mefs2c$mefs2b$mefs2a"
    else
        echo "ME Get FW Status failed. (CC=$compcode) !!!!!"
    fi

    if [ $GetDeviceIDPayload == "0x01" ]; then
        echo "ME is using the Operational Image.  No issue detected"
    elif [ $GetDeviceIDPayload == "0x00" ]; then
        ##Use IPMICmd 0x20 0x2e 0x00 0xdf 0x57 0x01 0x00 0x01  to force ME to recovery for test purposes
        echo "ME is in RECOVERY !!!!!!"
        echo "Checking Self-test results to determine why ME is in RECOVERY"
        ## If ME is in recovery, check why
        IPMICmd 20 2e 0 e1 2 18 4 | grep '0x'> /tmp/metriage/getselftest.txt
        cat /tmp/metriage/getselftest.txt | sed 's/0x/\n0x/g' | sed 1,3d > /tmp/metriage/selftestpayloadtemp.txt
        #cat /tmp/metriage/selftestpayloadtemp.txt
        GetSelfTestPayloadByte1=$(cat /tmp/metriage/selftestpayloadtemp.txt | sed 2,3d)
        cat /tmp/metriage/selftestpayloadtemp.txt | sed 1,1d > /tmp/metriage/selftestpayloadtemp2.txt
        #cat /tmp/metriage/selftestpayloadtemp2.txt
        GetSelfTestPayloadByte2=$(cat /tmp/metriage/selftestpayloadtemp2.txt | sed 2,3d)
        cat /tmp/metriage/selftestpayloadtemp2.txt | sed 1,1d > /tmp/metriage/selftestpayloadtemp3.txt
        GetSelfTestPayloadByte3=$(cat /tmp/metriage/selftestpayloadtemp3.txt)
        #echo $GetSelfTestPayload
        #echo $GetSelfTestPayloadByte1
        #echo $GetSelfTestPayloadByte2
        #echo $GetSelfTestPayloadByte3

        if [ $GetSelfTestPayloadByte1 == "0x00" ]; then
            echo "Self-test complete, decoding other bytes..."
            ##Begin Case 2 - Byte 2
            if [ $GetSelfTestPayloadByte2 == "0x55" ]; then
                echo "No self-test error, all tests passed."
            elif [ $GetSelfTestPayloadByte2 == "0x56" ]; then
                echo "Self test not implemented in this controller."
            elif [ $GetSelfTestPayloadByte2 == "0x57" ]; then
                echo "Corrupted or inaccessible data or devices."
                GetSelfTestPayloadByte3=$((GetSelfTestPayloadByte3))
                if [ $(($GetSelfTestPayloadByte3&0x01)) -ne 0 ]; then
                    echo " - Operational Image or Factory Presets"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x02)) -ne 0 ]; then
                    echo " - Firmware boot error"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x04)) -ne 0 ]; then
                    echo " - SDR repository empty"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x08)) -ne 0 ]; then
                    echo " - PIA access error"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x10)) -ne 0 ]; then
                    echo " - Reserved"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x20)) -ne 0 ]; then
                    echo " - FRU access error"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x40)) -ne 0 ]; then
                    echo " - SDR access error"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x80)) -ne 0 ]; then
                    echo " - SEL access error"
                fi
            elif [ $GetSelfTestPayloadByte2 == "0x58" ]; then
                echo "Fatal hardware error - exception type = $GetSelfTestPayloadByte3"
            elif [ $GetSelfTestPayloadByte2 == "0x80" ]; then
                echo "PSU Monitoring service error."
                GetSelfTestPayloadByte3=$((GetSelfTestPayloadByte3))
                if [ $(($GetSelfTestPayloadByte3&0x01)) -ne 0 ]; then
                    echo " - PSU1 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x02)) -ne 0 ]; then
                    echo " - PSU2 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x04)) -ne 0 ]; then
                    echo " - PSU3 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x08)) -ne 0 ]; then
                    echo " - PSU4 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x10)) -ne 0 ]; then
                    echo " - PSU5 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x20)) -ne 0 ]; then
                    echo " - PSU6 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x40)) -ne 0 ]; then
                    echo " - PSU7 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x80)) -ne 0 ]; then
                    echo " - PSU8 is not responding"
                fi
            elif [ $GetSelfTestPayloadByte2 == "0x81" ]; then
                echo "Self-test reports ME entered RECOVERY image !!! Decoding reason...."
                if [ $GetSelfTestPayloadByte3 == "0x00" ]; then
                    echo "RECOVERY entered due to asserting ME recovery jumper.  Check state of GPIO 162 with testgpio."
                elif [ $GetSelfTestPayloadByte3 == "0x01" ]; then
                    echo "RECOVERY entered due to Security strap override jumper being asserted"
                elif [ $GetSelfTestPayloadByte3 == "0x02" ]; then
                    echo "RECOVERY entered due to DFh 'Forced Recovery' IPMI command"
                elif [ $GetSelfTestPayloadByte3 == "0x03" ]; then
                    echo "RECOVERY entered due to invalid flash configuration."
                elif [ $GetSelfTestPayloadByte3 == "0x04" ]; then
                    echo "RECOVERY entered due to ME internal error"
                else
                    echo "Unknown Self-test response in Byte 3 = $GetSelfTestPayloadByte3"
                fi
            elif [ $GetSelfTestPayloadByte2 == "0x82" ]; then
                echo "HSC monitoring service error."
                GetSelfTestPayloadByte3=$((GetSelfTestPayloadByte3))
                if [ $(($GetSelfTestPayloadByte3&0x01)) -ne 0 ]; then
                    echo " - HSC1 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x02)) -ne 0 ]; then
                    echo " - HSC2 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x04)) -ne 0 ]; then
                    echo " - HSC3 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x08)) -ne 0 ]; then
                    echo " - HSC4 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x10)) -ne 0 ]; then
                    echo " - HSC5 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x20)) -ne 0 ]; then
                    echo " - HSC6 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x40)) -ne 0 ]; then
                    echo " - HSC7 is not responding"
                fi
                if [ $(($GetSelfTestPayloadByte3&0x80)) -ne 0 ]; then
                    echo " - HSC8 is not responding"
                fi
            else
                echo "Unknown ME Get Self-Test Result response in Byte 2 = $GetSelfTestPayloadByte2"
            fi
        elif [ $GetSelfTestPayloadByte1 == "0xd5" ]; then
                echo "ME Get Self-Test Result not complete..."
        else
                echo "ME Get Self-Test Results failed. (CC=$GetSelfTestPayloadByte1) !!!!!"
        fi
    else
        echo "ME is in an undefined state (ImageFlag=$GetDeviceIDPayload) !!!!!"
    fi

    ## If Recovery jumper, check GPIO state

    ## If jumper was asserted, cold boot and check if ME is in recovery

}

if [ "$1" == "-nmlc" ]; then
    echo
    Run_NMLC
elif [ "$1" == "-status" ]; then
    Get_ME_Status
elif [ "$1" == "-reset" ]; then
    Reset_ME
elif [ "$1" == "-getdeviceid" ]; then
    Get_ME_DeviceID
elif [ "$1" == "-bkc" ]; then
    Run_BKC
elif [ "$1" == "-recovery" ]; then
    Set_ME_Recovery
elif [ "$1" == "-factory" ]; then
    Load_ME_Factory_Deafult
elif [ "$1" == "-rescue" ]; then
    Rescue_ME
else
    Get_ME_Status
fi