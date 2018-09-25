#!/bin/sh

#
# This script brands iDrac platform.
#
# 1. It goes through configuration file list and mounts files from input directory over files
#    from the list one by one.
#    This step is to enable branding capability.
#
# 2. Mounts input directory over ${AVCT_MAP_PROP_DIR}/personality or
#    /usr/local/etc/appweb/personality, if env variable AVCT_MAP_PROP_DIR is not set.
#    This step is for AppWeb to enable resource overwrite capability.
#
# 3. Unmounts all files from configuration file list, if second input parameter is specified.
#
SELF_DIR=$0
echo SELF_DIR=$SELF_DIR

# Remove remove program name from leaving path.
SELF_DIR=${SELF_DIR%\/?*}
echo SELF_DIR=$SELF_DIR

# Assign BRAND_CONFIG_DIR since brandedFilesList.txt will be in the same dir as this script.
BRAND_CONFIG_DIR=${BRAND_CONFIG_DIR:-${SELF_DIR}}
echo BRAND_CONFIG_DIR=$BRAND_CONFIG_DIR

BRND_DIR=$1
if [ -z "$BRND_DIR" ]
then
	echo "Please specify directory name."
	echo "Usage: setPersonality.sh <directory>"
	exit 1;
fi

BRND_DIR=${BRND_DIR%%/}
echo BRND_DIR=$BRND_DIR

REVERSE=$2
if [ -z "$REVERSE" ]
then
	REVERSE="0"
else
	REVERSE="1"
fi

BRND_CFG_DIR=${BRAND_CONFIG_DIR:-"."}
BRND_CFG_NAME=${BRAND_CONFIG_NAME:-"brandedFilesList.txt"}
BRND_CFG_FILE=${BRND_CFG_DIR}/${BRND_CFG_NAME}
echo ${BRND_CFG_FILE}

if [ -z "$BRND_CFG_FILE" ]
then
	echo "Branding configuration list file does not exist."
	exit 1;
fi

# setting default to this script home directory.
SRC_DIR="/etc/sysapps_script/"

while read inputline
do
	# Remove preceeding and trailing spaces.
	inputline=${inputline## }
	inputline=${inputline%% }
	# Check opening # for comments.
	y=${inputline##\#}
	if [ "$y" = "$inputline" ]
	then
		# Check opening [
		x=${inputline##\[}
		#echo x=$x
		if [ "$x" = "$inputline" ]
		then
			# This is file name line. Mount brand file over source file.
			srcFileName=${inputline}
			echo srcFileName=$srcFileName
			fullSrcFileName=${SRC_DIR}/${srcFileName}
			echo fullSrcFileName=$fullSrcFileName
			fullBrandFileName=${BRND_DIR}/${srcFileName}
			echo fullBrandFileName=$fullBrandFileName
			# Check both files for existence before mounting.
			if [ -f "$fullBrandFileName" ]
			then
				if [ -f "$fullSrcFileName" ]
				then
					if [ "$REVERSE" = "0" ]
					then
						mount --bind $fullBrandFileName $fullSrcFileName
						echo mount --bind $fullBrandFileName $fullSrcFileName
					else
						umount $fullSrcFileName
						echo umount $fullSrcFileName
					fi
				else
					echo Error - fullSrcFileName=$fullSrcFileName is missing...
				fi
			else
				echo Error - fullBrandFileName=$fullBrandFileName is missing...
			fi
		else
			# This is directory line. Strip closing ]
			SRC_DIR=${x%%]}
			# Remove preceeding and trailing spaces.
			SRC_DIR=${SRC_DIR## }
			SRC_DIR=${SRC_DIR%% }
			# Remove trailing / if present.
			SRC_DIR=${SRC_DIR%%/}
			echo ${SRC_DIR}
		fi
	else
		echo "Skip comment line."
	fi
done < ${BRND_CFG_FILE}

#
# Mount resource direcory.
#
RESOURCE_DIR=${AVCT_MAP_PROP_DIR}
if [ -z "$RESOURCE_DIR" ]
then
	RESOURCE_DIR="/usr/local/etc/appweb/"
fi
RESOURCE_DIR=${RESOURCE_DIR%%/}
PERSONALITY_DIR=${RESOURCE_DIR}/"personality"
echo $PERSONALITY_DIR
if [ "$REVERSE" = "0" ]
then
	if [ -d "$BRND_DIR" ]
	then
		if [ -d "$PERSONALITY_DIR" ]
		then
			mount $BRND_DIR $PERSONALITY_DIR
			echo mount $BRND_DIR $PERSONALITY_DIR
		else
			echo Error - PERSONALITY_DIR=$PERSONALITY_DIR is missing...
		fi
	else
		echo Error - BRND_DIR=$BRND_DIR is missing...
	fi
else
	if [ -d "$PERSONALITY_DIR" ]
	then
		umount $PERSONALITY_DIR
		echo umount $PERSONALITY_DIR
	else
		echo Error - PERSONALITY_DIR=$PERSONALITY_DIR is missing...
	fi
fi

