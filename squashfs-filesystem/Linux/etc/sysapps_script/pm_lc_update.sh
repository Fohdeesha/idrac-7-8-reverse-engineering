#!/bin/sh

# This Parses the lcoem.conf file at the location specified by PM_LC_CONF
# The structure of PM_LC_CONF is as follows
#
# LCOEMEnable=0
# CSIOROEMEnable=0
#
# If the above format changes, please change the file parsing suitably

# LCOEMControl - Controls LC. Accepts the following
# 0 - LC is DISABLED
# 1 - LC is ENABLED

# CSIOROEMEnable - Controls CSIOR. Accepts the following
# 0 - CSIOR Disabled
# 1 - CSIOR Enabled

# This script returns the following values.
# 0 - SUCCESS
# 1 - FAILURE - Config file pointed by PM_LC_CONF Not Found
# 2 - Unable to change the LC behavior alone as per LCOEMEnable
# 3 - Unable to change the CSIOR behavior alone as per CSIOROEMEnable
# 5 - Unable to change the LC and CISOR behavior as per LCOEMEnable and CSIOROEMEnable

PM_LC_CONF=/flash/data0/persmod/lcoem.conf
source /etc/sysapps_script/pm_logger.sh
# EXIT_CODE : Allocated Exit codes 131 to 160 for this File.
EXIT_CODE=0
LC_ENABLED=0
LC_DISABLED=1
CSIOR_ENABLED=1
CSIOR_DISABLED=0
RETALL=0

if [ -f $PM_LC_CONF ]; then

        LC_ENABLE=`awk -F "=" '/LCOEMEnable/{print $2}' $PM_LC_CONF`
        CSIOR_ENABLE=`awk -F "=" '/CSIOROEMEnable/{print $2}' $PM_LC_CONF`

        if [ -n "$LC_ENABLE" ]; then
                LC_ENABLE=`expr $LC_ENABLE`
                if [  $LC_ENABLE -eq 0 ]; then
                        LC_ENABLE=$LC_DISABLED
                        echo DISABLING LC
                else
                        LC_ENABLE=$LC_ENABLED
                        echo ENABLING LC

                fi
        		exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xaf $LC_ENABLE 0x00 0x00" 131
				ret_val=$?
				if [ $ret_val -ne 0 ] ; then
					EXIT_CODE=$ret_val
				fi
				
        fi
        if [ -n "$CSIOR_ENABLE" ]; then
           CSIOR_ENABLE=`expr $CSIOR_ENABLE`
                if [ $(($CSIOR_ENABLE)) -eq 0 ]; then
                        CSIOR_ENABLE=$CSIOR_DISABLED
                        echo DISABLING CSIOR
                else
                        CSIOR_ENABLE=$CSIOR_ENABLED
                        echo ENABLING CSIOR
                fi
                exec_ipmi_cmd "IPMICmd 0x20 0x30 0x00 0xa3 0x11 $CSIOR_ENABLE 0x00 0x00" 132
				ret_val=$?
				if [ $ret_val -ne 0 ] ; then
					EXIT_CODE=$ret_val
				fi
                
        fi
        
else
        EXIT_CODE=133
fi
echo $EXIT_CODE
return $EXIT_CODE
