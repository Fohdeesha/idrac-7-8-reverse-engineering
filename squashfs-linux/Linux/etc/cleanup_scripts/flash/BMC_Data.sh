#!/bin/sh
destfiles=`find /flash/data0/BMC_Data -type f`
skipfiles="AssetTag.dat mctpdisc.txt"
for i in $destfiles
do
  fname=`basename $i`
  for s in $skipfiles
  do
    if [ "$fname" == "$s" ]; then
        continue 2
    fi
  done

  match=`find /etc/default/ipmi/default/ -name $fname`
  if [ -z $match ]; then
      echo "deleting unknown file $i"
      rm -rf $i
  fi
done
