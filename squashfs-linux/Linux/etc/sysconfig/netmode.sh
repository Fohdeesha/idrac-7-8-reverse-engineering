#!/bin/sh
# translate netmode value into available nic string
#0,,None,None
#1,eth0,Dedicated,LOM1
#2,ncsi0,LOM1,LOM2
#3,ncsi1,LOM2,LOM3
#4,ncsi2,LOM3,LOM4
#5,ncsi3,LOM4,ALL
#6,ncsi4,LOM5,LOM5
#7,ncsi5,LOM6,LOM6
#8,ncsi6,LOM7,LOM7
#9,ncsi7,LOM8,LOM8
#10,,,ALL

if [ -z $1 ]; then
   echo "usage: $0 <NETMODE>"
   exit 0
fi

selection=""
failover=""
Allfail=""
# Get max no of LOMs
limit=`aim_config_get_int NumOfEmbdLOMs`
if [ $? != 0 ];then
    limit=4
fi

getnicname ()
{
i=0
niclst=`grep ncsi /proc/net/dev | cut -d":" -f1 | sort | xargs`
for nic in ${niclst}
do
   if [ $i -eq $1 ]; then
        selection=$nic
   elif [ $i -eq $2 ] && [ $2 -ne 4 ] && [ $2 -ne 10 ]; then
        failover=$nic
   else
        Allfail="$Allfail $nic"
   fi
   i=`expr $i + 1`
# limit to 4 LOMs only
   if [[ $i -ge $limit ]]; then
	break
   fi
done

if [ $2 -gt 0 ] && [ "$failover" == "" ]; then
        failover=$Allfail
fi

}
SEL=`expr $1 / 6`

if [ $SEL != 0 ]; then
    FAIL=`expr $1 % 6`
    if [[ ${FAIL} -ge `expr ${SEL} + 1` ]]; then
	getnicname `expr ${SEL} - 1` `expr ${FAIL} - 1`
    else
	getnicname `expr ${SEL} - 1` `expr ${FAIL} - 2`
    fi
else
   selection="eth0"
fi
#echo selection=$selection
#echo failover=$failover
echo $selection $failover

