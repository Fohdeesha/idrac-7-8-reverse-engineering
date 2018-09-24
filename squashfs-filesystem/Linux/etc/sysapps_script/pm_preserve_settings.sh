#!/bin/sh

PM_DEFAULTS=/flash/data0/persmod/altdefaults.txt

TEMP=`cat $PM_DEFAULTS | wc -l`

for i in $(seq 3 $TEMP)
do
	GRP_NUMBER=`awk "NR==$i" $PM_DEFAULTS | cut -d: -f 1`
	GRP_INDEX=`awk "NR==$i" $PM_DEFAULTS | cut -d: -f 2`
	FLD_NUMBER=`awk "NR==$i" $PM_DEFAULTS | cut -d: -f 3`
	FLD_INDEX=`awk "NR==$i" $PM_DEFAULTS | cut -d: -f 4`
	VALUE=`awk "NR==$i" $PM_DEFAULTS | cut -d: -f 5`
	
	writecfg -g$GRP_NUMBER -e$GRP_INDEX -f$FLD_NUMBER -i$FLD_INDEX -v$VALUE
done
