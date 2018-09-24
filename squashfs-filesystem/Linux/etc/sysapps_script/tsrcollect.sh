#!/bin/sh
# set -x
# param $1 = mount point for the collections, e.g. /mnt/mas5/tsr
# param $2 = the collection keys
# param $3 = the collection keys_rv

## clean up
unset NO_PII

## TSR execution status files
TSR_DIR=/tmp/tsr.status
TSR_CANCELING=/tmp/tsr.canceling
TSR_CTRL_LOG=${TSR_DIR}/tsrcollect.log
TSR_CTRL_OUT=${TSR_DIR}/tsrcollect.out
TSR_CTRL_HAS_ERROR=${TSR_DIR}/tsrcollect.error
TSR_CTRL_HAS_COLLECT=${TSR_DIR}/tsrcollect.exist
TSR_COLLECTORS_PATH=/usr/bin
VIEWER_SOURCE_FILE=/etc/template.html

export DEBUG=1
let ETA=24

# debug log to tsr log file
debug_log()
{
    [ $DEBUG -eq 0 ] && return

    echo "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" >> ${TSR_CTRL_LOG}
    echo "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
}
#export -f debug_log

debug_log "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"

# cleanup status files from previous runs
mkdir -p ${TSR_DIR}

# init constants
export mountPtr="$1"
export collectKeys="$2"
export collectKeys_rv="$3"
export collectKeys_save="$2"
export collectKeys_rv_save="$3"

let KEY_SYSINFO=1
let KEY_OSAPPNOPII=2
let KEY_OSAPPALL=4
let KEY_TTYLOG=8
let KEY_COMPLETION_MASK=$((KEY_SYSINFO | KEY_OSAPPNOPII | KEY_OSAPPALL | KEY_TTYLOG))

let KEY_MUT=1
let KEY_OSAPPMAN=2
let KEY_OSAPPCACHE=4
let KEY_CANCEL=8
let KEY_GENERICLOGS=256

if [ $((collectKeys_rv&KEY_GENERICLOGS)) -ne 0 ]
then
	let KEY_RV_COMPLETION_MASK=$((KEY_MUT | KEY_GENERICLOGS))
else
	let KEY_RV_COMPLETION_MASK=$((KEY_MUT))
fi

# timeouts in multiple of 5 sec
let TMO_SYSINFO=30
let TMO_OSAPPNOPII=240
let TMO_OSAPPALL=240
let TMO_TTYLOG=240
let TMO_MUT=30
let TMO_SYSINFOLCLONLY=150              #150seconds
let TMO_GENERICLOGS=80

let POLL_TIME=5
let TMO_ALL=960

# for OSAPP if ALL, NOPII is zero
let bits=$((collectKeys&KEY_OSAPPALL))
if [ $bits -ne 0 ]
then
    let collectKeys=$((collectKeys&~KEY_OSAPPNOPII))
fi

# Generic Logs Filtered set ? GENERICLOGS_FILTERED=1 : GENERICLOGS_FILTERED=0
let GENERICLOGS_FILTERED=$((collectKeys & KEY_OSAPPNOPII))
if [ $GENERICLOGS_FILTERED -ne 0 ];then
	let GENERICLOGS_FILTERED=1
fi

# special environment parameters MANUAL for OSAPP collector
if [ $((collectKeys_rv&KEY_OSAPPMAN)) -ne 0 ]
then
    debug_log $0 "MANUAL=YES"
    export MANUAL=YES
    let collectKeys_rv=$((collectKeys_rv&~KEY_OSAPPMAN))
else
    debug_log $0 "unset MANUAL"
    unset MANUAL
fi

debug_log $0 "name: $0"
debug_log $0 "param:$mountPtr"
debug_log $0 "keys: $collectKeys"
debug_log $0 "keys_rv:$collectKeys_rv"

export resultKeys="$collectKeys"
export resultKeys_rv="$collectKeys_rv"

# collector base TAGs
# SYSINFO
# OSSAPPNOP
# OSAPPALL
# TTYLOG
# MUT
# GENERICLOGS

# operate in ${TSR_DIR} dir
cd ${TSR_DIR}

# collection directories
DIR_TEMP_SYSINFO="/tmp/sysinfo"
DIR_SYSINFO="$mountPtr/tsr/sysinfo"
DIR_TTYLOG="$mountPtr/tsr/ttylog"
DIR_OSAPPNOPII="$mountPtr/tsr/osapp"
DIR_OSAPPALL="$mountPtr/tsr/osapp"
DIR_MUT="$mountPtr/tsr/mut"
DIR_VIEWER="$mountPtr/tsr"
DIR_INVENTORY="$mountPtr/tsr/sysinfo/inventory"
DIR_GENERICLOGS="$mountPtr/tsr/ism"
LC_FILE="$mountPtr/tsr/sysinfo/lcfiles/curr_lclog.xml"
VIEWER_TARGET_FILE="$mountPtr/tsr/viewer.html"
SRC_SYSINFO_BIOS_ATTRIBUTE="$DIR_TEMP_SYSINFO/inventory/sysinfo_CIM_BIOSAttribute.xml"
SRC_SYSINFO_DCIM_VIEW="$DIR_TEMP_SYSINFO/inventory/sysinfo_DCIM_View.xml"
IDRAC_FIRST_POWER_ON_TIME_FILE=/flash/data3/iDRACFirstPowerOnTime.txt
DIR_PRODLOGS="$mountPtr/tsr/ProdLogs/"
PRODLOG_FILES="/tmp/REArev"

CopyFilesLike()
{
	FilesLike=$1
    debug_log "Copying $FilesLike* started..........."
    FilesToCopy=`ls $FilesLike*`
    for file in $FilesToCopy;do
        debug_log "Copying $file..........."
        cp -p $file $2
    done
    debug_log "Copying $FilesLike* finished"
}

# common utilities
remove_tags()
{
    debug_log remove_tags
    rm -f "$1".start "$1".end "$1".error
}

collect_init()
{
# $1=TAG
# $2=BITMAP
# $3=MASK
# $4=TIMEOUT

    debug_log collect_init enter $1 $2 $3 $4

    [ $(($2&$3)) -eq 0 ] && return 1

    debug_log collect_init return
    return 0
}

collect_wait_pid_timeout()
{
# $1=TAG
# $2=pid

    debug_log collect_wait_pid_timeout enter $1 $2

    echo $2 > "${TSR_DIR}/$1.start"

    (sleep $TMO_SYSINFOLCLONLY; debug_log collect_wait_pid_timeout occured; echo "$1 collection timedout" >> ${TSR_DIR}/$1.error; kill -6 $2 ) &
    let timeoutPid=$!

    wait $2
    let rc=$?

    # if pid is not in this shell
    [ $rc -eq 127 ] && echo "wait: invalid pid" >> "${TSR_DIR}/$1.error"

    kill -0 $timeoutPid && kill -9 $timeoutPid

    debug_log collect_wait_pid_timeout "$1($2)" return $rc
    return $rc
}

collect_wait_pid()
{
# $1=TAG
# $2=pid

    debug_log collect_wait_pid enter $1 $2

    echo $2 > "${TSR_DIR}/$1.start"
    wait $2
    let rc=$?

    # if pid is not in this shell
    [ $rc -eq 127 ] && echo "wait: invalid pid" >> "${TSR_DIR}/$1.error"

    debug_log collect_wait_pid "$1($2)" return $rc
    return $rc
}

collect_fin()
{
# $1=TAG
# $2=$? (return code of previous execution)

    debug_log collect_fin enter $1 $2

    let rc=$2
    case "$rc" in
        0) # success
            touch "${TSR_CTRL_HAS_COLLECT}"
            rm -f "${TSR_DIR}/$1.error"
        ;;

        1) # partial
            touch "${TSR_CTRL_HAS_COLLECT}"
            if [[ $1 != "MUT" ]] && [[ $1 != "GENERICLOGS" ]]
            then
            	touch "${TSR_CTRL_HAS_ERROR}"
            fi
            echo $rc >> "${TSR_DIR}/$1.error"
        ;;

        2) # failed (no collection available)
            if [[ $1 != "MUT" ]] && [[ $1 != "GENERICLOGS" ]]
            then
            	touch "${TSR_CTRL_HAS_ERROR}"
            fi
            echo $rc >> "${TSR_DIR}/$1.error"
        ;;

        *) # this shouldn't happen
            debug_log $0 "$1:error return code: $rc"
            if [[ $1 != "MUT" ]] && [[ $1 != "GENERICLOGS" ]]
            then
            	touch "${TSR_CTRL_HAS_ERROR}"
            fi
            echo "Unrecognized error returned by $1:$rc" >> "${TSR_DIR}/$1.error"
    esac

    touch "${TSR_DIR}/$1.end"

    debug_log collect_fin return
}


# specific collector controlling wrapper
collect_SYSINFO()
{
    debug_log collect_SYSINFO enter

    ! collect_init SYSINFO $collectKeys $KEY_SYSINFO $TMO_SYSINFO && return

    mkdir -p "$DIR_SYSINFO" || echo "Cannot create $DIR_SYSINFO" >> ${TSR_DIR}/SYSINFO.error
    # Clean the old files so that report dosent contain stale data
    rm -rf "$DIR_SYSINFO"/*
    # Check whether sysinfoapp is only triggered

    mkdir -p "$DIR_TEMP_SYSINFO" || echo "Cannot create $DIR_TEMP_SYSINFO" >> ${TSR_DIR}/SYSINFO.error
    # Clean the old files so that report dosent contain stale data
    rm -rf "$DIR_TEMP_SYSINFO"/*
    sysinfoapp -d "$DIR_TEMP_SYSINFO" &
    collect_wait_pid SYSINFO $!
    let rc=$?

    collect_fin SYSINFO $rc

    if [ ! -f $IDRAC_FIRST_POWER_ON_TIME_FILE ]; then
			/usr/bin/iDRACFirstPowerOnTime
	fi
	[ -f $IDRAC_FIRST_POWER_ON_TIME_FILE ] && { cp -p $IDRAC_FIRST_POWER_ON_TIME_FILE $DIR_SYSINFO; echo "iDRACFirstPowerOnTime File exists and is being added"; } || echo "iDRACFirstPowerOnTime file NOT FOUND" >> ${DIR_SYSINFO}/IDRACFIRSTPOWERUPTIME.error

    debug_log collect_SYSINFO return
}

collect_SYSINFOLCLONLY()
{
    debug_log collect_SYSINFOLCLONLY enter

    ! collect_init SYSINFOLCLONLY $collectKeys_save $KEY_SYSINFO $TMO_SYSINFO && return

    #run the sysinfoapp and collect only the lcl logs
    sysinfoapp -d "$DIR_TEMP_SYSINFO" -reusepath TRUE -c "CurrLCLog" &
    collect_wait_pid_timeout SYSINFOLCLONLY $!
    let rc=$?

    collect_fin SYSINFOLCLONLY $rc

    #if error set the sysinfo bit, so error can be returned
    if [ -f ${TSR_DIR}/SYSINFOLCLONLY.error ]
    then
        # set the bit if successful
        let resultKeys=$((resultKeys|KEY_SYSINFO))
    fi

    debug_log collect_SYSINFOLCLONLY return
}

collect_TTYLOG()
{
    debug_log collect_TTYLOG enter

    ! collect_init TTYLOG $collectKeys $KEY_TTYLOG $TMO_TTYLOG && return

    mkdir -p "$DIR_TTYLOG" || echo "Cannot create $DIR_TTYLOG" >> ${TSR_DIR}/TTYLOG.error
    # Clean the old files otherwise RTCEM will append log to same file
    rm -rf "$DIR_TTYLOG"/*
    OUT_DIR="$DIR_TTYLOG" collectTTYLog &
    collect_wait_pid TTYLOG $!
    let rc=$?

    collect_fin TTYLOG $rc
    debug_log collect_TTYLOG exit
}

collect_OSAPPNOPII()
{
    debug_log collect_OSAPPNOPII enter

    ! collect_init OSAPPNOPII $collectKeys $KEY_OSAPPNOPII $TMO_OSAPPNOPII && return

    mkdir -p "$DIR_OSAPPNOPII" || echo "Cannot create $DIR_OSAPPNOPII" >> ${TSR_DIR}/OSAPPNOPII.error
    mkdir -p "$DIR_OSAPPNOPII"/results || echo "Cannot create $DIR_OSAPPNOPII/results" >> ${TSR_DIR}/OSAPPNOPII.error

    if [ -d $DIR_OSAPPNOPII ] && [ $(($collectKeys_rv&$KEY_OSAPPCACHE)) -ne 0 ]
    then
        # use the cached copy
        let rc=0
    else
        # update the get_date stamp
        touch "$OUT_DIR"

        OUT_DIR="$DIR_OSAPPNOPII" NO_PII="TRUE" collectOSApp &
        collect_wait_pid OSAPPNOPII $!
        let rc=$?

        # if collection failed completely
        if [ $rc -eq 2 ]
        then
            rm -rf "$OUT_DIR"
        fi
    fi

    collect_fin OSAPPNOPII $rc

    debug_log collect_OSAPPNOPII return
}

collect_OSAPPALL()
{
    debug_log collect_OSAPPALL enter

    ! collect_init OSAPPALL $collectKeys $KEY_OSAPPALL $TMO_OSAPPALL && return

    mkdir -p "$DIR_OSAPPALL" ||  echo "Cannot create $DIR_OSAPPALL" >> ${TSR_DIR}/OSAPPALL.error
    mkdir -p "$DIR_OSAPPALL"/results ||  echo "Cannot create $DIR_OSAPPALL/results" >> ${TSR_DIR}/OSAPPALL.error

    if [ -d $DIR_OSAPPALL ] && [ $(($collectKeys_rv&$KEY_OSAPPCACHE)) -ne 0 ]
    then
        # use the cached copy
        let rc=0
    else
        # update the get_date stamp
        touch "$OUT_DIR"

        OUT_DIR="$DIR_OSAPPALL" collectOSApp &
        collect_wait_pid OSAPPALL $!
        let rc=$?

        # if collection failed completely
        if [ $rc -eq 2 ]
        then
            rm -rf "$OUT_DIR"
        fi
    fi

    collect_fin OSAPPALL $rc

    debug_log collect_OSAPPALL return
}

collect_MUT()
{
    debug_log collect_MUT enter

    ! collect_init MUT $collectKeys_rv $KEY_MUT $TMO_MUT && return

    mkdir -p "${DIR_MUT}" ||  echo "Cannot create $DIR_MUT" >> ${TSR_DIR}/MUT.error
    mkdir -p /tmp/mut

    # run explicit collect
    aggregateMUT collect
    # remove old mut data
    rm -rf ${DIR_MUT}/mut_*.xml
    # invoke the MUT collector
    OUT_DIR="$DIR_MUT" aggregateMUT xml all "$DIR_MUT" &
    collect_wait_pid MUT $!
    let rc=$?

    collect_fin MUT $rc

    debug_log collect_MUT return
}

collect_GENERICLOGS()
{
    debug_log collect_GENERICLOGS enter

    ! collect_init GENERICLOGS $collectKeys_rv $KEY_GENERICLOGS $TMO_GENERICLOGS && return

    mkdir -p "$DIR_GENERICLOGS" || echo "Cannot create $DIR_GENERICLOGS" >> ${TSR_DIR}/GENERICLOGS.error
    # Clean the old data
    rm -rf "$DIR_GENERICLOGS"/*
    OUT_DIR="$DIR_GENERICLOGS" collectGenericLogs $GENERICLOGS_FILTERED &
    collect_wait_pid GENERICLOGS $!
    let rc=$?

    collect_fin GENERICLOGS $rc
    debug_log collect_GENERICLOGS return
}

create_HTMLViewer()
{

	if [ ! -f "$VIEWER_TARGET_FILE" ]
	then
		rm -f "$VIEWER_TARGET_FILE"
	fi

	debug_log create_HTMLViewer enter
	touch "$VIEWER_TARGET_FILE"

	debug_log "Inventory Directory:" $DIR_INVENTORY "  LC File:" $LC_FILE

	if [ -d $DIR_INVENTORY ] && [ -e $LC_FILE ]
	then
		OUT_DIR="$DIR_VIEWER" $TSR_COLLECTORS_PATH/createHTMLViewer $VIEWER_SOURCE_FILE "$VIEWER_TARGET_FILE" "$DIR_INVENTORY" "$LC_FILE"
	elif [ ! -d $DIR_INVENTORY ] && [ -e $LC_FILE ]
	then
		OUT_DIR="$DIR_VIEWER" $TSR_COLLECTORS_PATH/createHTMLViewer $VIEWER_SOURCE_FILE "$VIEWER_TARGET_FILE" "" "$LC_FILE"
	elif [ -d $DIR_INVENTORY ] && [ ! -e $LC_FILE ]
	then
		OUT_DIR="$DIR_VIEWER" $TSR_COLLECTORS_PATH/createHTMLViewer $VIEWER_SOURCE_FILE "$VIEWER_TARGET_FILE" "$DIR_INVENTORY" ""
	else
		OUT_DIR="$DIR_VIEWER" $TSR_COLLECTORS_PATH/createHTMLViewer $VIEWER_SOURCE_FILE "$VIEWER_TARGET_FILE" "" ""
	fi
	debug_log create_HTMLViewer return
}


# start all the controlling wrappers in parallel
start_collect()
{
    debug_log start_collect enter

    collect_SYSINFO &
    collect_TTYLOG &
    collect_OSAPPNOPII &
    collect_OSAPPALL &
    collect_MUT &
    collect_GENERICLOGS &

    debug_log start_collect exit
}

poll_collector()
{
debug_log poll_collector $1 $2 $3 $4 $5 $6

# $1=TAG
pTAG=$1
# $2=mask
pMask=$2
# $3=keys_name
pKeyn=$3
# $4=keys_value
pKeyv=$4
# $5=resultkeys_name
pResultn=$5
# $6=resultkeys_value
pResultv=$6

    [ $(($pKeyv&$pMask)) -eq 0 ] && return

    if [ -f ${TSR_DIR}/${pTAG}.end ]
    then
        debug_log $0 "$pTAG done."
        let $pKeyn=$(($pKeyv&~$pMask))
        if [[ "$1" == "MUT" ]] || [[ "$1" == "GENERICLOGS" ]]
        then
            # clear the bit regardless of result for MUT and GenericLogs
            let $pResultn=$(($pResultv&~$pMask))
        elif [ ! -f ${TSR_DIR}/${pTAG}.error ]
        then
        	# clear the bit if successful
            let $pResultn=$(($pResultv&~$pMask))
        else
        	debug_log $0 "$pTAG has error."
        fi
    else
        debug_log $0 "$pTAG still working"
    fi

    debug_log poll_collector return
}

# poll for the completion
poll()
{
    let dur=0

    #use the current job completion percent and increment from that
    let start_job_progress=`jpop GetJob "$JID" | grep Percent | cut -f2 -d:`

    # overall timeout == POLL_TIME * TMO_ALL seconds
    while [ $dur -lt $TMO_ALL ]
    do
        # if it is cancelled by the master
        if [ -f "$TSR_CANCELING" ]
        then
            cancel

            # void all partion collections if operation aborted
            rm -f "${TSR_CTRL_HAS_COLLECT}"

            # cleanup the collecting flag
            #rm -f "$TSR_CANCELING"
            # cleanup is done in jtask exe
            return
        fi

        # update the percentage of JID if we can
        if [ ! -z "$JID" ] && ( which jpop > /dev/null )
        then
            # 240*5 == 20 min estimated completion time
            let pcent=$(( $start_job_progress + ((dur*100 ) / ETA )))

            # stop at 90%
            if [ $pcent -gt 90 ]
            then
                let pcent=90
            fi
            jpop UpdateJob "$JID" 3 $pcent
        fi

        # polling
        echo -n "."
        poll_collector SYSINFO $KEY_SYSINFO collectKeys $collectKeys resultKeys $resultKeys
        poll_collector OSAPPNOPII $KEY_OSAPPNOPII collectKeys $collectKeys resultKeys $resultKeys
        poll_collector OSAPPALL $KEY_OSAPPALL collectKeys $collectKeys resultKeys $resultKeys
        poll_collector TTYLOG $KEY_TTYLOG collectKeys $collectKeys resultKeys $resultKeys
        poll_collector MUT $KEY_MUT collectKeys_rv $collectKeys_rv resultKeys_rv $resultKeys_rv
        poll_collector GENERICLOGS $KEY_GENERICLOGS collectKeys_rv $collectKeys_rv resultKeys_rv $resultKeys_rv

        # check completion status
        if [ $((collectKeys & KEY_COMPLETION_MASK)) -eq 0 ] && [ $((collectKeys_rv & KEY_RV_COMPLETION_MASK)) -eq 0 ]
        then
            debug_log "All completed!"
			#get lcllog at end
            debug_log "Running sysinfoapp to collect lcllog"
            collect_SYSINFOLCLONLY

	    debug_log "Sanitizing sysinfo xmls"
	    sanitizeXML $SRC_SYSINFO_BIOS_ATTRIBUTE
	    sanitizeXML $SRC_SYSINFO_DCIM_VIEW

	    #Should have inventory and LC log by now
        debug_log "Copying sysinfoapp results to destination path"
	    mv $DIR_TEMP_SYSINFO/* $DIR_SYSINFO

	    sync
            sync
            if [ $((collectKeys_save&KEY_OSAPPALL)) -ne 0 ] || [ $((collectKeys_save&KEY_OSAPPNOPII)) -ne 0 ]
            then
                debug_log "KEY_OSAPPALL or KEY_OSAPPNOPII is present"
                mkdir -p "$mountPtr"/tsr/osc/fr
                mkdir -p "$mountPtr"/tsr/osc/pr
                if [ $((collectKeys_rv_save&KEY_OSAPPCACHE)) -ne 0 ]
                then
                    debug_log "Use cache is selected"
                    if [ $((collectKeys_save&KEY_OSAPPALL)) -ne 0 ]
                    then
                        debug_log "OSAPP ALL is selected"
                        if [ -e "$mountPtr"/tsr/osapp/results/OSC-PR-Report* ]
                        then
                            debug_log "Moving PR report to osc/pr"
                            rm -rf "$mountPtr"/tsr/osc/pr/*
                            mv "$mountPtr"/tsr/osapp/results/OSC-PR-Report* "$mountPtr"/tsr/osc/pr
                        fi
                        if [ -e "$mountPtr"/tsr/osc/fr/OSC-FR-Report* ]
                        then
                            debug_log "Moving FR report from osc/fr"
                            rm -rf "$mountPtr"/tsr/osapp/results/*
                            mv "$mountPtr"/tsr/osc/fr/OSC-FR-Report* "$mountPtr"/tsr/osapp/results
                        fi
                    elif [ $((collectKeys_save&KEY_OSAPPNOPII)) -ne 0 ]
                    then
                        debug_log "OSAPP PII is selected"
                        if [ -e "$mountPtr"/tsr/osapp/results/OSC-FR-Report* ]
                        then
                            debug_log "Moving FR report to osc/fr"
                            rm -rf "$mountPtr"/tsr/osc/fr/*
                            mv "$mountPtr"/tsr/osapp/results/OSC-FR-Report* "$mountPtr"/tsr/osc/fr
                        fi
                        if [ -e "$mountPtr"/tsr/osc/pr/OSC-PR-Report* ]
                        then
                            debug_log "Moving PR report from osc/pr"
                            rm -rf "$mountPtr"/tsr/osapp/results/*
                            mv "$mountPtr"/tsr/osc/pr/OSC-PR-Report* "$mountPtr"/tsr/osapp/results
                        fi
                    fi
                    #Check if we have copied the report
                    if [ ! -e "$mountPtr"/tsr/osapp/results/OSC-* ]
                    then
                        debug_log "Looks like cached copy is not present. So logging SYS189"
                        OSAPP_LOGMSG=SYS189 collectOSApp
                        touch "${TSR_CTRL_HAS_ERROR}"
                    fi
                else
                    debug_log "Use cache is not selected"
                    if [ $((collectKeys_save&KEY_OSAPPALL)) -ne 0 ]
                    then
                        debug_log "OSAPP ALL is selected"
                        #check if both reports are generated
                        if [ -e "$mountPtr"/tsr/osapp/results/OSC-FR-Report* ] && [ -e "$mountPtr"/tsr/osapp/results/OSC-PR-Report* ]
                        then
                            #move PR report
                            debug_log "Moving PR report to osc/pr"
                            rm -rf "$mountPtr"/tsr/osc/pr/*
                            rm -rf "$mountPtr"/tsr/osc/fr/*
                            mv "$mountPtr"/tsr/osapp/results/OSC-PR-Report* "$mountPtr"/tsr/osc/pr
                        fi
                    elif [ $((collectKeys_save&KEY_OSAPPNOPII)) -ne 0 ]
                    then
                        debug_log "OSAPP PII is selected"
                        #check if both reports are generated
                        if [ -e "$mountPtr"/tsr/osapp/results/OSC-FR-Report* ] && [ -e "$mountPtr"/tsr/osapp/results/OSC-PR-Report* ]
                        then
                            #move FR report
                            debug_log "Moving FR report to osc/fr"
                            rm -rf "$mountPtr"/tsr/osc/fr/*
                            rm -rf "$mountPtr"/tsr/osc/pr/*
                            mv "$mountPtr"/tsr/osapp/results/OSC-FR-Report* "$mountPtr"/tsr/osc/fr
                        fi
                    fi
                fi


                sync
                sync
            else
                debug_log "KEY_OSAPPALL or KEY_OSAPPNOPII is not present"
            fi
            # Collect Thermal data
            /usr/bin/AppThermalSHM -ro
            if [ -e /tmp/Thermal.zip ]
            then
                debug_log "Thermal data successfully created"
                mv /tmp/Thermal.zip ${DIR_MUT}
            else
                debug_log "Thermal data not created"
            fi
	    if [  -d "$DIR_PRODLOGS" ]
	    then
		    rm -rf "$DIR_PRODLOGS"
	    fi

	    if ls $PRODLOG_FILES* 1> /dev/null 2>&1; then
		    debug_log "REArev files exist"
		    mkdir -p "$DIR_PRODLOGS"
		    let rc=$?
		    if [[ $rc == 0 ]]; then
			    CopyFilesLike $PRODLOG_FILES $DIR_PRODLOGS
		    else
			    debug_log "$DIR_PRODLOGS cannot be created"
		    fi
	    else
		    debug_log "REArev files do not exist"
	    fi

		# Create HTML Viewer
	    debug_log "Creating HTML Collection Viewer"
	    create_HTMLViewer

            return
        fi

        sleep $POLL_TIME
        let dur=dur+1
    done

    # attempt to cancel operations, we may still have partial results
    cancel

    touch "${TSR_CTRL_HAS_ERROR}"
    echo Timed out
}

### collection main routine
collect()
{
    # remove the status files left over
    remove_tags SYSINFO
    remove_tags OSAPPNOPII
    remove_tags OSAPPALL
    remove_tags TTYLOG
    remove_tags MUT
	remove_tags SYSINFOLCLONLY
	remove_tags GENERICLOGS

    # remove previous package
    rm -rf "$mountPtr"/TSR*.zip

    start_collect
    poll

    printf "%x %x" $resultKeys $resultKeys_rv > "$TSR_CTRL_OUT"
}

## Cancellation routines ##
cancel_init()
{
# $1=TAG
# $2=BITMAP
# $3=MASK

    [ $(($2&$3)) -eq 0 ] && return 1

    # kill the on-going collector, if still alive
    if [ -f "${TSR_DIR}/$1.end" ]
    then
        return 1
    fi

    # send abort signal to the process which is still running
    export kpid=$(cat "${TSR_DIR}/$1.start")
    if [ -d "/proc/$kpid" ]
    then
        kill -6 $kpid
    else
        echo "$kpid not exist" >> "${TSR_DIR}/$1.error"
    fi

    # mark it complete with error
    echo "$1 Cancelled" >> "${TSR_DIR}/$1.error"
    touch "${TSR_DIR}/$1.end"

    return 0
}

cancel_SYSINFO()
{
    ! cancel_init SYSINFO $collectKeys $KEY_SYSINFO && return
}

cancel_OSAPPNOPII()
{
    ! cancel_init OSAPPNOPII $collectKeys $KEY_OSAPPNOPII && return
}

cancel_OSAPPALL()
{
    ! cancel_init OSAPPALL $collectKeys $KEY_OSAPPALL && return
}

cancel_TTYLOG()
{
    ! cancel_init TTYLOG $collectKeys $KEY_TTYLOG && return
}

cancel_MUT()
{
    ! cancel_init MUT $collectKeys_rv $KEY_MUT && return
}

cancel_GENERICLOGS()
{
    ! cancel_init GENERICLOGS $collectKeys_rv $KEY_GENERICLOGS && return
}

### cancellation main routine
cancel()
{
    cancel_SYSINFO
    cancel_OSAPPNOPII
    cancel_OSAPPALL
    cancel_TTYLOG
    cancel_MUT
    cancel_GENERICLOGS

}

main()
{
    # estimate the completion time
    if [ $(( collectKeys & KEY_SYSINFO )) -ne 0 ]
    then
        let ETA=24
    fi

    if [ $(( collectKeys & (KEY_OSAPPNOPII | KEY_OSAPPALL | KEY_TTYLOG) )) -ne 0 ]
    then
        let ETA=240
    fi

    if [ ! -f "$TSR_CANCELING" ]
    then
        rm -f "${TSR_CTRL_HAS_ERROR}"
        rm -f "${TSR_CTRL_HAS_COLLECT}"
        rm -f "${TSR_CTRL_LOG}"
        rm -f "${TSR_CTRL_OUT}"
		rm -f "$VIEWER_TARGET_FILE"
        collect
    fi
}

main

# return the error code
[ -f $TSR_CTRL_HAS_COLLECT ] &&   [ ! -f $TSR_CTRL_HAS_ERROR ]  && exit 0
[ -f $TSR_CTRL_HAS_COLLECT ] &&   [ -f $TSR_CTRL_HAS_ERROR ]    && exit 1
[ ! -f $TSR_CTRL_HAS_COLLECT ] && [ -f $TSR_CTRL_HAS_ERROR ]    && exit 2
[ ! -f $TSR_CTRL_HAS_COLLECT ] && [ ! -f $TSR_CTRL_HAS_ERROR ]  && exit 2
