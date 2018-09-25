#/bin/sh
#
#Summary-   This script sets up the credential vault file system.
# 

GREPOPTION="-E"
DIR="/etc/fsdf/"
TEMPDIR="/tmp/"
#TEMP=`/bin/bash --version`
#BASH_VER="${TEMP#*.}"
#TEMP="${BASH_VER#*.}"
#BASH_VER="${TEMP%%(*}"
LINE=0
LINEMOD=

#if [[ $BASH_VER -ne 0 ]]; then
#    echo "Resetting vars for local bash"
#    DIR=""
#    TEMPDIR=""
#fi

cat ${DIR}DebugCaps.ini | grep ${GREPOPTION} "Description|Racadm" >${TEMPDIR}tempDebugCaps
echo ""
echo ""
echo "FSDAF-DebugCaps: "
while read line
do
    let "LINE=$LINE+1"
    let LINEMOD="$LINE % 2"

    echo "$line "
    if [[ $LINEMOD -eq 0 ]];then
      echo ""
    fi

done<${TEMPDIR}tempDebugCaps

rm -f ${TEMPDIR}tempDebugCaps
exit $?

