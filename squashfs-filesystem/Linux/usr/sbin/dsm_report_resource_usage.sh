#!/bin/sh
###############################################################################
#
# Script to report resource usage
#
###############################################################################

POPPROCLIST=`ps | grep dsm_sa_popproc | grep -v grep | awk '{print $6}'`
PROCLIST="dsm_sa_snmpd dsm_sa_eventmgrd dsm_sa_datamgrd ${POPPROCLIST}"

FIELD_WIDTH_PROCNAME=16
FIELD_WIDTH_NUM=8

DOUBLE_LINE="================================================================================"
SINGLE_LINE="--------------------------------------------------------------------------------"


###############################################################################
# report_process_info
###############################################################################
report_process_info()
{
	local procname procpid procvsz
	local procname_padded procpid_padded procvsz_padded
	local fdcnt socketcnt threadcnt
	
	procname=$1
	get_padded_val ${procname} ${FIELD_WIDTH_PROCNAME} append
	procname_padded=${PADDED_VAL}
	
	procpid=`ps | grep ${procname} | grep -v grep | awk '{print $1}'`
	if [ -z "${procpid}" ];
	then
		return 1
	fi
	get_padded_val ${procpid} ${FIELD_WIDTH_NUM} prepend
	procpid_padded=${PADDED_VAL}
	
	procvsz=`ps | grep ${procname} | grep -v grep | awk '{print $3}'`
	get_padded_val ${procvsz} ${FIELD_WIDTH_NUM} prepend
	procvsz_padded=${PADDED_VAL}
	
	get_padded_val "`grep Threads: /proc/${procpid}/status | awk '{print $2}'`" ${FIELD_WIDTH_NUM} prepend
	threadcnt=${PADDED_VAL}
	
	get_padded_val "`ls -l /proc/${procpid}/fd | wc -l`" ${FIELD_WIDTH_NUM} prepend
	fdcnt=${PADDED_VAL}
	
	get_padded_val "`ls -l /proc/${procpid}/fd | grep socket | wc -l`" ${FIELD_WIDTH_NUM} prepend
	socketcnt=${PADDED_VAL}
	
	echo "${procname_padded} ${procpid_padded} ${procvsz_padded} ${threadcnt} ${fdcnt} ${socketcnt}"
} # report_process_info


###############################################################################
# report_resource_usage_summary
###############################################################################
report_resource_usage_summary()
{
	local procname semcnt

	print_report_header "Resource Usage Summary"
	
	# report process summary
	echo "PROCESS               PID      VSZ  THREADS      FDS  SOCKETS"
	for procname in ${PROCLIST};
	do
		report_process_info ${procname}
	done
	echo ""

	# report active semaphore count
	semcnt=$(cat /proc/sysvipc/sem | wc -l)
	semcnt=$((semcnt - 1)) # account for header line
	echo "Number of semaphores: ${semcnt}"
	echo ""
} # report_resource_usage_summary


###############################################################################
# report_resource_usage_detailed_info
###############################################################################
report_resource_usage_detailed_info()
{
	local procname procpid

	print_report_header "Resource Usage Detailed Info"

	# report system detailed info
	print_subsection_header "System"

	# report active semaphores
	echo "Semaphores:"
	cat /proc/sysvipc/sem
	echo ""

	# report process detailed info
	for procname in ${PROCLIST};
	do
		print_subsection_header "${procname}"

		procpid=`ps | grep ${procname} | grep -v grep | awk '{print $1}'`
		if [ -z "${procpid}" ];
		then
			continue
		fi

		echo "Threads:"
		ps -T | grep ${procname} | grep -v grep
		echo ""

		echo "Open fds:"
		ls -l /proc/${procpid}/fd | grep -iv "total 0"
		echo ""

		echo "Memory map:"
		cat /proc/${procpid}/maps
		echo ""
	done
} # report_resource_usage_detailed_info


###############################################################################
# get_padded_val
###############################################################################
get_padded_val()
{
	local len fieldwidth numspaces padtype
	
	PADDED_VAL="$1"
	fieldwidth=$2
	padtype=$3
	
	len=${#1}
	numspaces=$((${fieldwidth} - ${len}))
	while [ ${numspaces} -gt 0 ];
	do
		if [ ${padtype} = "prepend" ]
		then
			PADDED_VAL=" ${PADDED_VAL}"
		else
			PADDED_VAL="${PADDED_VAL} "
		fi
		numspaces=$((numspaces -1))
	done
} # get_padded_val


###############################################################################
# print_report_header
###############################################################################
print_report_header()
{
	echo "${DOUBLE_LINE}"
	echo "$1"
	echo "${DOUBLE_LINE}"
	echo ""
} # print_report_header


###############################################################################
# print_subsection_header
###############################################################################
print_subsection_header()
{
	echo "${SINGLE_LINE}"
	echo "$1"
	echo "${SINGLE_LINE}"
	echo ""
} # print_subsection_header


###############################################################################
# Script Main
###############################################################################

REPORT_TYPE="all"

# process command line parameters
while [ ! -z "$1" ];
do
	if echo $1 | grep -q "type="; then
		REPORT_TYPE=`echo $1 | sed "s/type=//"`
	else
		echo "Invalid parameter: $1"
		exit 1
	fi
	shift
done

# report resource usage
case "${REPORT_TYPE}" in
	all)
		report_resource_usage_summary
		report_resource_usage_detailed_info
		;;

	summary)
		report_resource_usage_summary
		;;

	detailedinfo)
		report_resource_usage_detailed_info
		;;

	*)
		echo "Invalid type value: ${REPORT_TYPE}"
		exit 1
		;;
esac

echo "${DOUBLE_LINE}"
echo "End of report"
echo "${DOUBLE_LINE}"
echo ""


###############################################################################
# Script End
###############################################################################

