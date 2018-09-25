#!/bin/sh

features="gui fullui snmp telnet clp ipv6 ddns screen ssh"

for f in $features
do
	echo "granting $f ...."
	/avct/sbin/fmchk -g $f
done
