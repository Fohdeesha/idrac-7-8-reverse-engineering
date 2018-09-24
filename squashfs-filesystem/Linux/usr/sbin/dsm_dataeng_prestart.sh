#!/bin/sh
###############################################################################
#
#          Dell Inc. PROPRIETARY INFORMATION
# This software is supplied under the terms of a license agreement or
# nondisclosure agreement with Dell Inc. and may not
# be copied or disclosed except in accordance with the terms of that
# agreement.
#
# Copyright (c) 2010-2012 Dell Inc. All Rights Reserved.
#
# Module Name:
#
#   dsm_dataeng_prestart.sh
#
# Abstract/Purpose:
#
#   Systems Management Data Engine pre-start script
#
# Environment:
#
#   Embedded Linux
#
###############################################################################

DENG_SCRIPT_CONFIG_FILE="/etc/dsm_dataeng.conf"

# source script config file
. ${DENG_SCRIPT_CONFIG_FILE}

DENG_DEBUG_OVERRIDE_DIR="${DENG_PERSISTENT_DIR}/debug"

TYPE_BINARY=1
TYPE_TEXT=2


###############################################################################
# Function:    check_binary_file_override
# Description: Check if override exists for binary file
# Returns:     None
###############################################################################
check_binary_file_override()
{
	local filename=$1
	local origdir=$2
	local override="${DENG_DEBUG_OVERRIDE_DIR}/${filename}"
	local mntpt="${origdir}/${filename}"

	# check if override exists
	if [ -f ${override} ];
	then
		echo "Mounting ${override}"

		# clear any mounts for override mount point
		while `mount | grep -q ${mntpt}` ;
		do
			umount ${mntpt}
		done

		# make sure binary has execute permission
		chmod 755 ${override}

		# mount specified override to specified mount point
		mount --bind ${override} ${mntpt}
	fi
} # check_binary_file_override


###############################################################################
# Function:    check_text_file_override
# Description: Check if override exists for text file
# Returns:     None
###############################################################################
check_text_file_override()
{
	local filename=$1
	local origdir=$2
	local override="${DENG_DEBUG_OVERRIDE_DIR}/${filename}"

	# check if override exists
	if [ -f ${override} ];
	then
		echo "Copying ${override}"
		cp -f ${override} ${origdir}
	fi
} # check_text_file_override


###############################################################################
# Function:    check_pattern_override
# Description: Check if override exists for filename pattern and directory
# Returns:     None
###############################################################################
check_pattern_override()
{
	local pattern=$1
	local origdir=$2
	local filetype=$3

	# check if original file directory exists
	if [ -d ${origdir} ];
	then
		# change to original file directory
		cd ${origdir}

		# get list of filenames for specified pattern
		FILELIST=`ls ${pattern} 2>/dev/null`
		if [ $? = 0 ];
		then
			# check each file in list for override
			for FILENAME in ${FILELIST};
			do
				case ${filetype} in
					${TYPE_BINARY})
						check_binary_file_override ${FILENAME} ${origdir}
						;;
					${TYPE_TEXT})
						check_text_file_override ${FILENAME} ${origdir}
						;;
				esac
			done
		fi
	fi
} # check_pattern_override


###############################################################################
# check for overrides
###############################################################################

# binary files
check_pattern_override "dsm_sa_*" ${DENG_DAEMON_DIR} ${TYPE_BINARY}
check_pattern_override "dc*" ${DENG_TOOL_DIR} ${TYPE_BINARY}
check_pattern_override "libdc*" ${DENG_LIB_DIR} ${TYPE_BINARY}

# text files
check_pattern_override "*.ini" ${DENG_INI_DIR} ${TYPE_TEXT}
check_pattern_override "*.log" ${DENG_DEBUG_LOG_DIR} ${TYPE_TEXT}


###############################################################################
# End Script
###############################################################################

