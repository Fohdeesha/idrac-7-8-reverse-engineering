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
#   dsm_dataeng.sh
#
# Abstract/Purpose:
#
#   Systems Management Data Engine init script
#
# Environment:
#
#   Embedded Linux
#
# Notes:
#
#   1. Environment differences are handled through the script config file.
#
###############################################################################

DENG_PROD_NAME="Systems Management Data Engine"
DENG_SCRIPT_NAME="dsm_dataeng.sh"
DENG_SCRIPT_CONFIG_FILE="/etc/dsm_dataeng.conf"

# source script config file
. ${DENG_SCRIPT_CONFIG_FILE}

DENG_DEBUG_OVERRIDE_DIR="${DENG_PERSISTENT_DIR}/debug"
DENG_PRESTART_SCRIPT_PFNAME="${DENG_DEBUG_OVERRIDE_DIR}/dsm_dataeng_prestart.sh"
DENG_INI_OVERRIDE_DIR="${DENG_PERSISTENT_DIR}/etc/ini"
DENG_SCRIPT_STAGE2_NAME="dsm_dataeng_stage2.sh"

OS_PIDFILE_DIR="/var/run"
OS_SUBSYS_LOCK_DIR="/var/lock/subsys"

# daemon binary names
DENG_DATAMGR_BIN_NAME="dsm_sa_datamgrd"
DENG_EVENTMGR_BIN_NAME="dsm_sa_eventmgrd"
DENG_SNMPMGR_BIN_NAME="dsm_sa_snmpd"
DENG_POPPROC_BIN_NAME="dsm_sa_popproc"

# daemon ini filenames
DENG_DATAMGR_DYINI_FILE="dcdmdy${DENG_BIT}.ini"
DENG_EVENTMGR_DYINI_FILE="dcemdy${DENG_BIT}.ini"
DENG_SNMPMGR_DYINI_FILE="dcsndy${DENG_BIT}.ini"

# default to no daemons enabled
DENG_DAEMON_START_LIST=""
DENG_DAEMON_STOP_LIST=""

# check if SNMP Manager enabled
if [ "${DENG_SNMPMGR_ENABLED}" = "yes" ]
then
	DENG_DAEMON_START_LIST="${DENG_DAEMON_START_LIST} ${DENG_SNMPMGR_BIN_NAME}"
	DENG_DAEMON_STOP_LIST="${DENG_SNMPMGR_BIN_NAME} ${DENG_DAEMON_STOP_LIST}"
fi

# check if Event Manager enabled
if [ "${DENG_EVENTMGR_ENABLED}" = "yes" ]
then
	DENG_DAEMON_START_LIST="${DENG_DAEMON_START_LIST} ${DENG_EVENTMGR_BIN_NAME}"
	DENG_DAEMON_STOP_LIST="${DENG_EVENTMGR_BIN_NAME} ${DENG_DAEMON_STOP_LIST}"
fi

# check if Data Manager enabled
if [ "${DENG_DATAMGR_ENABLED}" = "yes" ]
then
	DENG_DAEMON_START_LIST="${DENG_DAEMON_START_LIST} ${DENG_DATAMGR_BIN_NAME}"
	DENG_DAEMON_STOP_LIST="${DENG_DATAMGR_BIN_NAME} ${DENG_DAEMON_STOP_LIST}"
fi


# Standard status codes for commands other than "status"
STATUS_NO_ERROR=0
STATUS_GENERIC_ERROR=1
STATUS_INVALID_ARG=2
STATUS_NOT_IMPLEMENTED=3

# Data Engine status codes for commands other than "status"

# Standard status codes for "status" command
STATUS_RUNNING=0
STATUS_DEAD_PIDFILE_EXISTS=1
STATUS_DEAD_LOCKFILE_EXISTS=2
STATUS_NOT_RUNNING=3
STATUS_UNKNOWN=4

# misc
DENG_ACTIONRESULT_COLUMN=60
DENG_ACTIONSTART_LEN=0


###############################################################################
# Begin Functions
###############################################################################


###############################################################################
# Function:    dataeng_check_daemon_name
# Description: Check daemon name and map aliases
# Returns:     LSB status codes
###############################################################################
dataeng_check_daemon_name()
{
	local daemon=$1
	local status=${STATUS_NO_ERROR}

	case ${daemon} in
		${DENG_DATAMGR_BIN_NAME}|datamgr|dm)
			DAEMON_NAME_MAPPED=${DENG_DATAMGR_BIN_NAME}
			DAEMON_DYINI_FILE=${DENG_DATAMGR_DYINI_FILE}
			;;
	
		${DENG_EVENTMGR_BIN_NAME}|eventmgr|em)
			DAEMON_NAME_MAPPED=${DENG_EVENTMGR_BIN_NAME}
			DAEMON_DYINI_FILE=${DENG_EVENTMGR_DYINI_FILE}
			;;
	
		${DENG_SNMPMGR_BIN_NAME}|snmpmgr|sm)
			DAEMON_NAME_MAPPED=${DENG_SNMPMGR_BIN_NAME}
			DAEMON_DYINI_FILE=${DENG_SNMPMGR_DYINI_FILE}
			;;
	
		*)
			status=${STATUS_INVALID_ARG}
			;;
	esac

	return ${status}
} # dataeng_check_daemon_name


###############################################################################
# Function:    dataeng_prestart
# Description: Run Data Engine prestart script
# Returns:     LSB status codes
###############################################################################
dataeng_prestart()
{
	local daemon

	# make sure no daemons are running
	dataeng_status >/dev/null
	if [ $? = ${STATUS_NOT_RUNNING} ];
	then
		# check for prestart script
		if [ -f ${DENG_PRESTART_SCRIPT_PFNAME} ];
		then
			echo "Running ${DENG_PRESTART_SCRIPT_PFNAME}"
			chmod 755 ${DENG_PRESTART_SCRIPT_PFNAME}
			${DENG_PRESTART_SCRIPT_PFNAME}
		fi
	fi

	return ${STATUS_NO_ERROR}
} # dataeng_prestart


###############################################################################
# Function:    dataeng_start
# Description: Start Data Engine daemons
# Returns:     LSB status codes
###############################################################################
dataeng_start()
{
	local daemon

	echo "Starting ${DENG_PROD_NAME}:"
	
	# check if any Data Engine daemons enabled
	if [ -z "${DENG_DAEMON_START_LIST}" ];
	then
		echo "No daemons enabled"
	else
		# make sure IPC directory exists
		if [ ! -d /var/run/.ipc ];
		then
			mkdir -p /var/run/.ipc
			touch /var/run/.ipc/.lxsuptIPCini
			touch /var/run/.ipc/.lxsuptIPCiniSem
		fi

		# start Data Engine daemons that are enabled
		for daemon in ${DENG_DAEMON_START_LIST};
		do
			dataeng_startdaemon ${daemon}
		done
	fi

	return ${STATUS_NO_ERROR}
} # dataeng_start


###############################################################################
# Function:    dataeng_start_stage2
# Description: Start Data Engine stage 2
# Returns:     None
###############################################################################
dataeng_start_stage2()
{
	# check if Data Manager stage 2 populator load enabled
	if [ "${DENG_DATAMGR_STAGE2_ENABLED}" = "yes" ]
	then
		${DENG_SCRIPT_STAGE2_NAME}
	fi
} # dataeng_start_stage2


###############################################################################
# Function:    dataeng_startdaemon <daemon>
# Description: Start specified daemon
# Returns:     LSB status codes
###############################################################################
dataeng_startdaemon()
{
	local daemon=$1

	# check daemon name
	dataeng_check_daemon_name ${daemon}
	if [ $? != ${STATUS_NO_ERROR} ];
	then
		echo "${DENG_SCRIPT_NAME}: Invalid daemon name: '${daemon}'"
		return ${STATUS_INVALID_ARG}
	fi

	daemon=${DAEMON_NAME_MAPPED}

	dataeng_supt_actionstart "Starting ${daemon}: "

	# check if daemon is running
	dataeng_supt_daemonstatus ${daemon} >/dev/null
	if [ $? != ${STATUS_RUNNING} ];
	then
		# if starting Data Manager
		if [ ${daemon} = ${DENG_DATAMGR_BIN_NAME} ];
		then
			# make sure no populator processes are still running
			dataeng_supt_popprocstopall
		fi

		# start the daemon
		dataeng_supt_daemonstart "${DENG_DAEMON_DIR}/${daemon}" "${DENG_DAEMON_OPTIONS}"
	else
		dataeng_supt_actionend_success "Already started"
	fi

	return ${STATUS_NO_ERROR}
} # dataeng_startdaemon


###############################################################################
# Function:    dataeng_stop
# Description: Stop Data Engine daemons
# Returns:     LSB status codes
###############################################################################
dataeng_stop()
{
	local daemon

	echo "Stopping ${DENG_PROD_NAME}:"
	
	# check if any Data Engine daemons enabled
	if [ -z "${DENG_DAEMON_STOP_LIST}" ];
	then
		echo "No daemons enabled"
	else
		# stop Data Engine daemons that are running
		for daemon in ${DENG_DAEMON_STOP_LIST};
		do
			dataeng_stopdaemon ${daemon}
		done
	fi

	return ${STATUS_NO_ERROR}
} # dataeng_stop


###############################################################################
# Function:    dataeng_stopdaemon <daemon>
# Description: Stop specified daemon
# Returns:     LSB status codes
###############################################################################
dataeng_stopdaemon()
{
	local daemon=$1

	# check daemon name
	dataeng_check_daemon_name ${daemon}
	if [ $? != ${STATUS_NO_ERROR} ];
	then
		echo "${DENG_SCRIPT_NAME}: Invalid daemon name: '${daemon}'"
		return ${STATUS_INVALID_ARG}
	fi

	daemon=${DAEMON_NAME_MAPPED}

	dataeng_supt_actionstart "Stopping ${daemon}: "

	# check if daemon is running
	dataeng_supt_daemonstatus ${daemon} >/dev/null
	if [ $? = ${STATUS_RUNNING} ];
	then
		# stop the daemon
		dataeng_supt_daemonstop ${daemon}
	else
		dataeng_supt_actionend_failure "Not started"
	fi

	return ${STATUS_NO_ERROR}
} # dataeng_stopdaemon


###############################################################################
# Function:    dataeng_status
# Description: Get status of Data Engine daemons
# Returns:     LSB status codes
###############################################################################
dataeng_status()
{
	local daemon
	local status=${STATUS_NOT_RUNNING}

	# check if any Data Engine daemons enabled
	if [ ! -z "${DENG_DAEMON_START_LIST}" ];
	then
		# get status of Data Engine daemons
		for daemon in ${DENG_DAEMON_START_LIST};
		do
			dataeng_supt_daemonstatus ${daemon}
			if [ $? = ${STATUS_RUNNING} ];
			then
				status=${STATUS_RUNNING}
			fi
		done

		# report any populator processes that are running
		dataeng_supt_popprocstatus
	fi

	return ${status}
} # dataeng_status


###############################################################################
# Function:    dataeng_supt_daemonrunning <daemon> <pid list>
# Description: Check if daemon is running
# Returns:     0 = daemon running, 1 = daemon not running
###############################################################################
dataeng_supt_daemonrunning()
{
	local daemon=$1
	local pidlist="$2"

	if [ -n "${pidlist}" ];
	then
		for pid in ${pidlist};
		do
			if [ -d /proc/${pid} ];
			then
				return 0
			fi
		done
	fi

	return 1
} # dataeng_supt_daemonrunning


###############################################################################
# Function:    dataeng_supt_daemon_ini_override <daemon>
# Description: Check if daemon ini file should be overridden
# Returns:     LSB status codes
###############################################################################
dataeng_supt_daemon_ini_override()
{
	local daemon="$1"

	# get daemon ini filename
	dataeng_check_daemon_name ${daemon}
	if [ $? != ${STATUS_NO_ERROR} ];
	then
		return ${STATUS_INVALID_ARG}
	fi

	# check if daemon dynamic ini file should be overridden
	if [ -f ${DENG_INI_OVERRIDE_DIR}/${DAEMON_DYINI_FILE} ];
	then
		cp -f ${DENG_INI_OVERRIDE_DIR}/${DAEMON_DYINI_FILE} ${DENG_INI_DIR}
	fi

	return ${STATUS_NO_ERROR}
} # dataeng_supt_daemon_ini_override


###############################################################################
# Function:    dataeng_supt_daemonstart <daemon pathfilename> <daemon options>
# Description: Start a daemon
# Returns:     LSB status codes
###############################################################################
dataeng_supt_daemonstart()
{
	local daemon_pfname="$1"
	local daemon=`echo ${daemon_pfname} | sed s!^.*/!!`
	local status

	shift

	# check if daemon ini file should be overridden
	dataeng_supt_daemon_ini_override ${daemon}

	# start daemon
	"${daemon_pfname}" $*

	# check return status
	if [ $? = 0 ];
	then
		# check for crash
		dataeng_supt_daemonstatus ${daemon} >/dev/null 2>&1
		if [ $? = ${STATUS_RUNNING} ];
		then
			status=${STATUS_NO_ERROR}
			dataeng_supt_actionend_success ""
			dataeng_supt_logmessage "${daemon} startup succeeded"
		else
			status=${STATUS_GENERIC_ERROR}
			dataeng_supt_actionend_crashed ""
			dataeng_supt_logmessage "${daemon} crashed on startup"
		fi
	else
		status=${STATUS_GENERIC_ERROR}
		dataeng_supt_actionend_failure ""
		dataeng_supt_logmessage "${daemon} startup failed"
	fi

	return ${status}
} # dataeng_supt_daemonstart


###############################################################################
# Function:    dataeng_supt_daemonstop <daemon>
# Description: Stop a daemon
# Returns:     LSB status codes
###############################################################################
dataeng_supt_daemonstop()
{
	local daemon=$1
	local killed=0
	local status=${STATUS_GENERIC_ERROR}
	local line pid pidfile pidlist pidmain secs

	# get list of pids for daemon
	pidlist=""

	# check for pid file in standard location
	pidfile="${OS_PIDFILE_DIR}/${daemon}.pid"
	if [ -f ${pidfile} ];
	then
		# get list of pids from pid file
		read line < ${pidfile}
		for pid in ${line};
		do
			if [ -d /proc/${pid} ];
			then
				pidlist="${pidlist} ${pid}"
			fi
		done
	fi

	# check if list of pids found in pid file
	if [ -z ${pidlist} ];
	then
		# get list of pids for daemon
		pidlist=`pidof ${daemon}`
	fi

	# check if list of pids found for daemon
	if [ -n "${pidlist}" ];
	then
		# find pid for main thread; it should be lowest numbered pid
		pidmain=0
		for pid in ${pidlist};
		do
			if [ ${pidmain} -eq 0 ] || [ ${pid} -lt ${pidmain} ];
			then
				pidmain=${pid}
			fi
		done

		# check if pid for main thread found
		if [ ${pidmain} != 0 ];
		then
			# signal main thread to shutdown
			kill -TERM ${pidmain}
			usleep 100000

			# wait up to N seconds for all daemon threads to go away
			secs=0
			while [ ${secs} -lt ${DENG_DAEMON_STOP_TIMEOUT_SECS} ];
			do
				if dataeng_supt_daemonrunning "${daemon}" "${pidlist}";
				then
					# at least one daemon thread is still running
					sleep 1
					secs=$((secs + 1))
				else
					# no daemon threads are running
					break
				fi
			done

			# check again in case timeout occurred
			if dataeng_supt_daemonrunning "${daemon}" "${pidlist}";
			then
				# refresh list of pids and issue KILL for all remaining threads
				pidlist=`pidof ${daemon}`
				kill -KILL ${pidlist}
				sleep 1
				killed=1
			fi

			# check again for return code
			dataeng_supt_daemonrunning "${daemon}" "${pidlist}"
			if [ $? != 0 ];
			then
				# no daemon threads are running
				status=${STATUS_NO_ERROR}
			fi
		fi
	fi

	# display and log status
	if [ ${status} = ${STATUS_NO_ERROR} ];
	then
		if [ ${killed} = 1 ];
		then
			# stopped with hard kill
			dataeng_supt_actionend_killed ""
			dataeng_supt_logmessage "${daemon} terminated with SIGKILL"
		else
			# check for crash
			dataeng_supt_daemonstatus ${daemon} >/dev/null 2>&1
			if [ $? = ${STATUS_DEAD_PIDFILE_EXISTS} ];
			then
				# crashed when stopping
				dataeng_supt_actionend_crashed ""
				dataeng_supt_logmessage "${daemon} crashed on shutdown"
			else
				# stopped normally
				dataeng_supt_actionend_success ""
				dataeng_supt_logmessage "${daemon} shutdown succeeded"
			fi
		fi
	else
		# failed to stop
		dataeng_supt_actionend_failure ""
		dataeng_supt_logmessage "${daemon} shutdown failed"
	fi

	return ${status}
} # dataeng_supt_daemonstop


###############################################################################
# Function:    dataeng_supt_daemonstatus <daemon>
# Description: Get current status of a daemon
# Returns:     LSB status code
###############################################################################
dataeng_supt_daemonstatus()
{
	local daemon=$1
	local pidlist pidfile lockfile

	# get list of pids for daemon
	pidlist=`pidof ${daemon}`
	if [ -n "${pidlist}" ];
	then
		echo "${daemon} (pid ${pidlist}) is running"
		return ${STATUS_RUNNING}
	fi

	# check for pid file in standard location
	pidfile="${OS_PIDFILE_DIR}/${daemon}.pid"
	if [ -f ${pidfile} ];
	then
		echo "${daemon} is dead and ${OS_PIDFILE_DIR} pid file exists"
		return ${STATUS_DEAD_PIDFILE_EXISTS}
	fi

	# check for lock file in standard location
	lockfile="${OS_SUBSYS_LOCK_DIR}/${daemon}"
	if [ -f ${lockfile} ];
	then
		echo "${daemon} is dead and ${OS_SUBSYS_LOCK_DIR} lock file exists"
		return ${STATUS_DEAD_LOCKFILE_EXISTS}
	fi

	echo "${daemon} is stopped"
	return ${STATUS_NOT_RUNNING}
} # dataeng_supt_daemonstatus


###############################################################################
# Function:    dataeng_supt_popprocstatus
# Description: Report if any populator processes are running
# Returns:     LSB status code
###############################################################################
dataeng_supt_popprocstatus()
{
	local pid pidlist popprocname

	# get sorted list of populator process pids
	pidlist=`pidof ${DENG_POPPROC_BIN_NAME} | tr " " "\n" | sort`
	if [ -z "${pidlist}" ];
	then
		return ${STATUS_NOT_RUNNING}
	fi

	# report populator processes
	for pid in ${pidlist};
	do
		popprocname=`sed s!^.*${DENG_POPPROC_BIN_NAME}!! /proc/${pid}/cmdline | tr -d "\n\0"`
		echo "${DENG_POPPROC_BIN_NAME} ${popprocname} (pid ${pid}) is running"
	done

	return ${STATUS_RUNNING}
} # dataeng_supt_popprocstatus


###############################################################################
# Function:    dataeng_supt_popprocstopall
# Description: Stop any populator processes that are running
# Returns:     none
###############################################################################
dataeng_supt_popprocstopall()
{
	local pidlist secs

	# get list of populator process pids
	pidlist=`pidof ${DENG_POPPROC_BIN_NAME}`
	if [ -z "${pidlist}" ];
	then
		# none running
		return
	fi

	dataeng_supt_logmessage "Found these populator processes running: ${pidlist}"

	# give populator processes one last chance for normal termination
	kill -TERM ${pidlist}

	# wait up to N seconds for all processes to go away
	secs=0
	while [ ${secs} -lt ${DENG_POPPROC_STOP_TIMEOUT_SECS} ];
	do
		sleep 1
		secs=$((secs + 1))

		# check again
		pidlist=`pidof ${DENG_POPPROC_BIN_NAME}`
		if [ -z "${pidlist}" ];
		then
			# none running
			return
		fi
	done

	# kill any populator processes still running
	kill -KILL ${pidlist}

	dataeng_supt_logmessage "Terminated these populator processes with SIGKILL: ${pidlist}"

	# give OS time to clean up
	sleep 1
} # dataeng_supt_popprocstopall


###############################################################################
# Function:    dataeng_supt_actionstart <message>
# Description: Display action start message
# Returns:     none
###############################################################################
dataeng_supt_actionstart()
{
	local msg="$1"

	# display action start message
	echo -n "$msg"

	# save action start message length
	DENG_ACTIONSTART_LEN=${#msg}
} # dataeng_supt_actionstart


###############################################################################
# Function:    dataeng_supt_actionend <message> <result>
# Description: Display action end message
# Returns:     none
###############################################################################
dataeng_supt_actionend()
{
	local msg="$1"
	local result="$2"
	local msglen=${#msg}
	local pad=""
	local padlen=$((DENG_ACTIONRESULT_COLUMN - 1))

	# determine number of pad spaces between message and result
	padlen=$((padlen - DENG_ACTIONSTART_LEN))
	padlen=$((padlen - msglen))

	# generate pad string
	while [ ${padlen} -gt 0 ]; do
		pad="${pad} "
		padlen=$((padlen - 1))
	done

	# display action end message
	echo "${msg}${pad}${result}"

	# reset action start message length
	DENG_ACTIONSTART_LEN=0
} # dataeng_supt_actionend


###############################################################################
# Function:    dataeng_supt_actionend_success <message>
# Description: Display action end success message
# Returns:     none
###############################################################################
dataeng_supt_actionend_success()
{
	dataeng_supt_actionend "$1" "[  OK  ]"
} # dataeng_supt_actionend_success


###############################################################################
# Function:    dataeng_supt_actionend_failure <message>
# Description: Display action end failure message
# Returns:     none
###############################################################################
dataeng_supt_actionend_failure()
{
	dataeng_supt_actionend "$1" "[FAILED]"
} # dataeng_supt_actionend_success


###############################################################################
# Function:    dataeng_supt_actionend_warning <message>
# Description: Display action end warning message
# Returns:     none
###############################################################################
dataeng_supt_actionend_warning()
{
	dataeng_supt_actionend "$1" "[WARNING]"
} # dataeng_supt_actionend_warning


###############################################################################
# Function:    dataeng_supt_actionend_killed <message>
# Description: Display action end killed message
# Returns:     none
###############################################################################
dataeng_supt_actionend_killed()
{
	dataeng_supt_actionend "$1" "[KILLED]"
} # dataeng_supt_actionend_killed


###############################################################################
# Function:    dataeng_supt_actionend_crashed <message>
# Description: Display action end crashed message
# Returns:     none
###############################################################################
dataeng_supt_actionend_crashed()
{
	dataeng_supt_actionend "$1" "[CRASHED]"
} # dataeng_supt_actionend_crashed


###############################################################################
# Function:    dataeng_supt_logmessage <message>
# Description: Log message to OS log
# Returns:     none
###############################################################################
dataeng_supt_logmessage()
{
	# log message to OS log
	logger -t "${DENG_SCRIPT_NAME}" "$1"
} # dataeng_supt_logmessage


###############################################################################
# End Functions
###############################################################################


###############################################################################
# Check command line parameter for action to perform
###############################################################################

case "$1" in
	boot)
		# boot with stage 1
		dataeng_prestart
		dataeng_start
		EXIT_STATUS=$?
		;;

	stage2)
		# load stage 2
		dataeng_start_stage2
		EXIT_STATUS=$?
		;;

	start)
		# start service
		dataeng_prestart
		dataeng_start
		dataeng_start_stage2
		EXIT_STATUS=$?
		;;

	stop)
		# stop service
		dataeng_stop
		EXIT_STATUS=$?
		;;

	restart|force-reload)
		# restart service
		dataeng_stop
		dataeng_prestart
		dataeng_start
		dataeng_start_stage2
		EXIT_STATUS=$?
		;;

	status)
		# print and return current status of service
		dataeng_status
		EXIT_STATUS=$?
		;;

	status-quiet)
		# return current status of service
		dataeng_status >/dev/null
		EXIT_STATUS=$?
		;;

	reload)
		# reload configuration
		echo "${DENG_SCRIPT_NAME}: reload not supported"
		EXIT_STATUS=${STATUS_NOT_IMPLEMENTED}
		;;

	startdaemon|startd)
		# start Data Engine daemon
		dataeng_startdaemon "$2"
		EXIT_STATUS=$?
		;;

	stopdaemon|stopd)
		# stop Data Engine daemon
		dataeng_stopdaemon "$2"
		EXIT_STATUS=$?
		;;

	restartdaemon|restartd)
		# restart Data Engine daemon
		dataeng_stopdaemon "$2"
		dataeng_startdaemon "$2"
		EXIT_STATUS=$?
		;;

	*)
		echo "${DENG_SCRIPT_NAME}: Invalid argument"
		echo "Usage: ${DENG_SCRIPT_NAME} {start|stop|restart|force-reload|status}"
		EXIT_STATUS=${STATUS_INVALID_ARG}
esac

exit ${EXIT_STATUS}


###############################################################################
# End Script
###############################################################################

