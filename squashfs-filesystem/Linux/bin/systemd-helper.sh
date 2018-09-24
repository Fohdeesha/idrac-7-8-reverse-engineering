#!/bin/sh
if [ -z "$1" ] ; then
        echo ""
        echo "Usage: $0 <legacy-script-name>"
        echo "       $0 S_7010_snmpd.sh"
        echo ""
        exit 0
fi
fname=`basename $1`
sname=`grep $fname /lib/systemd/system/*.service | cut -d":" -f1 | xargs`
for i in $sname
do
srt=`grep $fname $i | cut -d":" -f2 | cut -d"=" -f2`
echo $srt
echo "  `basename $i`"
done

echo "use following convention:"
for i in $sname
do
echo "           systemctl status `basename $i`"
done
        echo ""
