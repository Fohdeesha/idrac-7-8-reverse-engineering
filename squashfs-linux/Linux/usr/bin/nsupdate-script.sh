#! /bin/sh

PROG_NAME=$0
PRE_LOCK=$1
THIS_LOCK=$2
NSUPDATE_FILE=$3
PRIMARY_DNS_SERVER=$4
SECONDARY_DNS_SERVER=$5

if [ $# -lt 3 ]; then
    echo "Usage: $0 pre_lock this_lock nsupdate_file primary_dns_server secondary_dns_server"
    exit 1
fi

if [ $# -eq 3 ]; then
    PRIMARY_DNS_SERVER="::"
    SECONDARY_DNS_SERVER="::"
fi

if [ $# -eq 4 ]; then
    SECONDARY_DNS_SERVER="::"
fi

# Query a host unknown.com to make sure DNS server reachable
dns_server_query() {
    DNS_SERVER=$1
    DNS_TYPE=$2

    if [ "${DNS_SERVER}" = "::" ]; then
         echo "[$PROG_NAME,pid=$$,$DNS_TYPE] DNS server is empty."
         DNS_SERVER_PASS=0
    else
        #Transaction ID: 2bytes(0x12,0x34)
        #Flags: 2bytes(0x01,0x00)
        #Questions: 2bytes(0x00,0x01)
        #Answer PRs: 2bytes(0x00,0x00)
        #Authority PRs: 2bytes(0x00,0x00)
        #Additional PRS: 2bytes,(0x00,0x00)
        #Quries:
        #      Name: unknown.com(0x07,unknown,0x03,com.0x00)
        #      Type: A(0x00,0x01)
        #      Class: IN(0x00,0x01)
        #QUERY_STRING="\x12\x34\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x07unknown\x03com\x00\x00\x01\x00\x01"
        #echo -ne $QUERY_STRING | nc -w 2 -u $DNS_SERVER 53 > /tmp/dns_query.log

        #Verify responder's Transaction ID should be same as sender
        #FIND_DNS=`hexdump /tmp/dns_query.log | grep 3412 | wc -l`
        #if [ "${FIND_DNS}" != "1" ]; then
        #    echo "[$PROG_NAME,pid=$$,$DNS_TYPE] Could not find DNS server: $DNS_SERVER"
        #    DNS_SERVER_PASS=0
        #else
        #    echo "[$PROG_NAME,pid=$$,$DNS_TYPE] find DNS server: $DNS_SERVER"
        #    DNS_SERVER_PASS=1
        #fi

	nc -w 2 -z $DNS_SERVER 53

	if [ "$?" != "0" ]; then
            echo "[$PROG_NAME,pid=$$,$DNS_TYPE] Could not find DNS server: $DNS_SERVER"
            DNS_SERVER_PASS=0
        else
            echo "[$PROG_NAME,pid=$$,$DNS_TYPE] find DNS server: $DNS_SERVER"
            DNS_SERVER_PASS=1
        fi
    fi
}

run_nsupdate() {
    DNS_SERVER=$1
    DNS_TYPE=$2

    dns_server_query $DNS_SERVER $DNS_TYPE

    if [ "${DNS_SERVER_PASS}" = "1" ]; then
        #Prepare nsupdate file
        NSUPDATE_FILE_READY=$NSUPDATE_FILE.ready
        echo "server $DNS_SERVER" > $NSUPDATE_FILE_READY
        cat $NSUPDATE_FILE >> $NSUPDATE_FILE_READY

        #Doing nsupdate
        echo "[$PROG_NAME,pid=$$,$DNS_TYPE] nsupdate DNS server: $DNS_SERVER"
        nsupdate -t 10 -v $NSUPDATE_FILE_READY

        rm -f $NSUPDATE_FILE_READY
    fi
}

# Lock this script, next script need wait this script unlock. 
touch $THIS_LOCK

TIMEOUT=0
# Wait pre script unlock
while [ -e $PRE_LOCK ]; do
        sleep 1
        #avoid unknown issue cause looping, so set timeout  
        TIMEOUT=`expr $TIMEOUT + 1`
        if [ $TIMEOUT -gt 60 ]; then
            rm -f $PRE_LOCK
        fi
done

echo "[$PROG_NAME,pid=$$] $@"

run_nsupdate $PRIMARY_DNS_SERVER "Primary"
run_nsupdate $SECONDARY_DNS_SERVER "Secondary"

# Unlock this script, next script can be continue.
rm -f $NSUPDATE_FILE
rm -f $THIS_LOCK

