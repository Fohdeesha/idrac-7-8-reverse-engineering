#!/bin/sh

LOG_FILE=/tmp/appweb_monitor.log
LOG_BACKUP_FILE=/tmp/appweb_monitor.log.1
LOG_MAX_FILE_SIZE=1000
SCRIPT_NAME=`basename $0`
KILL_TARGET=appweb
EVENT_COUNT=0

### log message to LOG_FILE and check LOG_FILE size ###
log_to_file()
{
    if [ -e ${LOG_FILE} ]; then
        LOG_SIZE=`ls -l ${LOG_FILE} | awk '{print $5}'`
        
        if [ ${LOG_SIZE} -gt ${LOG_MAX_FILE_SIZE} ]; then
            mv -f ${LOG_FILE} ${LOG_BACKUP_FILE}
        fi
    fi

    date >> ${LOG_FILE}
    echo $1 >> ${LOG_FILE}
}

monitor() {
    (while [ 1 ]; do
    
    COUNT=`netstat -an | grep -v grep | grep -c CLOSE_WAIT`
    STATUS=$?
    
    if [ ${STATUS} == 0 ]; then
        if [ ${COUNT} -gt 8 ]; then
            log_to_file ${COUNT}
            EVENT_COUNT=$((${EVENT_COUNT}+1))
            
            if [ ${EVENT_COUNT} -gt 10 ]; then
                log_to_file "killall ${KILL_TARGET}"
                killall ${KILL_TARGET}
            fi
        else
            EVENT_COUNT=0
        fi
        
    fi
    
    sleep 30
    
    done) &
}

start() {
    COUNT=`pgrep -f ${SCRIPT_NAME} | wc -l`
    
    if [ ${COUNT} -gt 2 ]; then
        log_to_file "ALREADY START"
    else
        log_to_file "START MONITOR"
        monitor
    fi
}

stop() {
    log_to_file "STOP MONITOR"
    pkill -f "$SCRIPT_NAME start"
}

case "$1" in
    stop)
        stop
        ;;
    start)
        start
        ;;
    *)
        echo $"Usage: $0 {start|stop}"
        exit 1
esac

exit 0
