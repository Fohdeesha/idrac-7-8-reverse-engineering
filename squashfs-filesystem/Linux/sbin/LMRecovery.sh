#!/bin/sh

LM_DEST_FILE="/tmp/LMbackup.tgz"
LM_BACKUP=0
LM_RESTORE=0

show_usage() {
   echo "Usage: `basename $0` -b [ -f filename ]"
   echo "       `basename $0` -r [ -f filename ]"

}
if [ $# -eq 0 ]
then
    show_usage
    exit 1
fi
 
while getopts "h?brf:" opt; do
    case "$opt" in
	h|\?)
	    show_usage
	    exit 0
	    ;;
	b)
	    LM_BACKUP=1
	    ;;
	r)
	    LM_RESTORE=1
	    ;;
	f)
	    LM_DEST_FILE=$OPTARG
	    ;;
    esac
done

if [ $LM_BACKUP -eq 1 ] && [ $LM_RESTORE -eq 1 ] 
then
    echo "Error: Only one of -b or -r may be specified"
    exit 3
elif [ $LM_BACKUP -eq 1 ]
then
    tar czf $LM_DEST_FILE /flash/data0/rsdsafe/lm /flash/data1/rsdsafe/lm
elif [ $LM_RESTORE -eq 1 ]
then
    tar xzf $LM_DEST_FILE -C /
else
    echo "Error: One of -b or -r must be specified"
    exit 4
fi

