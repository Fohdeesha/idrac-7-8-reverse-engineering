#!/bin/sh

features="gui fullui ssh vmkvm wsman snmp pwrbudget pwrmonitor telnet clp ipv6 ddns dnic dirsvc tfa sso pkauth screen video boot vflash collabor devmonitor rfs vfolder"

for f in $features
do
	echo "granting $f ...."
	/avct/sbin/fmchk -g $f
done
