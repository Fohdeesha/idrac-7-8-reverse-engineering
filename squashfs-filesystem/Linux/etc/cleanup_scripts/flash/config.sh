#!/bin/sh

#   This script checks and deletes any files that do not belong to config_lib
#   Note that this script runs under BASH prompt. Please invoke accordingly
#   

SKIP_FILES="eventfilter32_1 iDRACnet.conf NICSwitch.conf iDRACnet.default TestFile_1"
CONFIG_DIR="/flash/data0/config"
CONFIG_FILES=`find $CONFIG_DIR -type f`

#Valid Filenames = Find the value in 'Filename column in the *txt files > filter out blank lines > filter out 'Filename' string - because filename string is used as a comment in the txt files
VALID_FILENAMES=`cut -d":" -f3 $CONFIG_DIR/*grp.txt | grep -v "^$" | grep -v "Filename" `

for file in $CONFIG_FILES
do
    basename=`basename $file | cut -d"_" -f1`

    # Check if the file is present in the valid list. If Valid, skip processing this file 
    echo "$SKIP_FILES" | grep "$basename" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "Found a file in valid list. Skipping - $file"
        continue
    fi

    echo "$VALID_FILENAMES" | grep "$basename" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        continue
    else
        echo -e "Invalid File found. Deleting $file"
        rm -rf $file
    fi
        
done

