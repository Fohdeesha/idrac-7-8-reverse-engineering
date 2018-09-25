#!/bin/sh
# generates a general file w/sorted timezone names.

strlen()
{
	echo ${#1}
}

zp=${1%/}	# (optional) zoneinfo path
[ -n "$zp" ] || zp="/usr/share/zoneinfo"	# default path

[ -d $zp -a -e $zp/Universal ] || { echo "usage: $0 zoneinfo-path" ; exit 1 ; }

sp="s!^$zp/!!g"	# sed program  "s!^$zp/!!"

gx=".svn\|Factory\|posixrules\|.*.tab\|posix/.*\|right/.*\|localtime"	# grep exclusions

of=$2 #output filename "zonelist.dat"

rm -f $of
nz=0
while read
do
	rz=${REPLY%/*}
	if [ ".$rz" = ".$REPLY" ]; then
		mz="$mz $rz"
	elif	[ "$mz" = "${mz%$rz\**}" ]; then
		mz="$mz $rz*"
	fi

	echo -e "$REPLY" >> $of
	nz=$((nz+1))
done << HERE
`find $zp -type f -print | sed $sp | grep -v $gx | LC_ALL=C sort`
HERE

#echo -e "\nTotal = $nz" >> $of
