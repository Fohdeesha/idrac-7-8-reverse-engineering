#!/bin/sh

genScript()
{
if [ "$File" == "" ]; then
    exit 1
fi

cat <<-HERE > $File
# ignore all by default
restrict default ignore
restrict -6 default ignore


# Permit all access over the loopback interface.  This could
# be tightened as well, but to do so would effect some of
restrict 127.0.0.1
restrict -6 ::1

# Drift file.  Put this in a directory which the daemon can write to.
# No symbolic links allowed, either, since the daemon updates the file
# by creating a temporary in the same directory and then renaming
# it to the file.
driftfile /flash/data0/ntp/drift


# Permit time synchronization with our time source, but do not
# permit the source to query or modify the service on this system.
$Server1
$Server2
$Server3

$Restrict1
$Restrict2
$Restrict3

#tos setting
$Maxdist
$Mindist

HERE
}

EnableServer()
{
    if echo $3 | grep -q :
    then
      export $1="server -6 $3"
      export $2="restrict -6 $3 kod nomodify notrap nopeer noquery"
    else
      export $1="server $3"
      export $2="restrict $3 kod nomodify notrap nopeer noquery"
    fi
}

while getopts :M:f:s:m: opt
do
    case $opt in
    M)
        Maxdist="tos maxdist $OPTARG"
    ;;
    m)
        Mindist="tos mindist $OPTARG"
    ;;
    f)
        File=$OPTARG
    ;;
    s)
        shift $(($OPTIND - 2))
        if [ "$1" != "" ];then EnableServer Server1 Restrict1 $1; fi
        if [ "$2" != "" ];then EnableServer Server2 Restrict2 $2; fi
        if [ "$3" != "" ];then EnableServer Server3 Restrict3 $3; fi
    ;;
    '?')
        exit 0
    ;;
    esac
done
genScript
