#!/bin/sh

PERMANENT_CAPBIOS_FILE="/flash/data0/oem_ps/CAPBIOS"
TEMP_CAPBIOS_FILE="/tmp/CAPBIOS"

# If no tmp file then delete permanent file
if [ ! -e $TEMP_CAPBIOS_FILE ]
then
    rm -f $PERMANENT_CAPBIOS_FILE
fi

# if tmp and permanent file are same then dont write tmp to permanent location
if ! diff /flash/data0/oem_ps/CAPBIOS /tmp/CAPBIOS
then
    if [ -e $TEMP_CAPBIOS_FILE ]
    then
        cp -f $TEMP_CAPBIOS_FILE $PERMANENT_CAPBIOS_FILE
    fi
fi

#BITS083253: SK: Commenting out removal of CAPBIOS from /tmp
# remove tmp file
#rm -f $TEMP_CAPBIOS_FILE
