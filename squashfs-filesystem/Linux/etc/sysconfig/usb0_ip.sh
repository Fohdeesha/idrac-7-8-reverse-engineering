#!/bin/sh
# This script would be called to check allowed ip address for usb0 interface
#return 0 if ip is allowed

ip=$1
usb0_new_byte1="$(echo $ip | cut -d. -f1)"
usb0_new_byte2="$(echo $ip | cut -d. -f2)"
usb0_new_byte3="$(echo $ip | cut -d. -f3)"
usb0_new_byte4="$(echo $ip | cut -d. -f4)"

#invalid ip format e.g x.y.x or a.b.c.d.x :error:101
if [ -z "$1" ] || [  -z "$usb0_new_byte1" ] || [ -z "$usb0_new_byte2" ] || [ -z "$usb0_new_byte3" ] || [ -z "$usb0_new_byte4" ]
then
	# IP parameter Error or missing:Error 101
	echo 101
	exit 
fi

#ip: 0.0.0.0 :Error:102
if [[ 0 -eq $usb0_new_byte1 && 0 -eq $usb0_new_byte2 && 0 -eq $usb0_new_byte3 && 0 -eq $usb0_new_byte4 ]]
then
	#Invalid IP: Error 102
	echo 102
	exit
fi

if [[ 169 -ne $usb0_new_byte1 || 254 -ne $usb0_new_byte2 ]]
then
	#Not a Local Link subnet IP: Error 105
	echo 105
	exit
fi

#Check if any ethernet interface is having same ip
status=`ifconfig | grep "inet addr:" | sed -e 's/inet addr://' | cut -d":" -f1 | grep -F "$ip " | wc -l`

if [ $status -ne 0 ]
then
	status=`ifconfig usb0 | grep "inet addr:" | sed -e 's/inet addr://' | cut -d":" -f1 | grep -F "$ip " | wc -l`
	#Extracted ip is of usb0: Ignore error: Send 2
	if [ $status -ne 0 ]
	then
		#New ip is same as existing usb0 ip
		echo 2
		exit
	fi
	# Already same is assigned for another ethernet interface:Error 103
	echo 103
	exit
fi

#Check: reserved IP List
ips='
	169.254.0.3
	169.254.0.4
	'
for ip in $ips
do
	local ip_byte1="$(echo $ip | cut -d. -f1)"
	local ip_byte2="$(echo $ip | cut -d. -f2)"
	local ip_byte3="$(echo $ip | cut -d. -f3)"
	local ip_byte4="$(echo $ip | cut -d. -f4)"
	if [[ $ip_byte1 -eq $usb0_new_byte1 && $ip_byte2 -eq $usb0_new_byte2 && $ip_byte3 -eq $usb0_new_byte3 && $ip_byte4 -eq $usb0_new_byte4 ]]
	then
		#Reserved IP: Setting usb0 IP Not allowed: Error 104
		echo 104
		exit
	fi
done

#default allow usb0 ip address setting: Allow usb0 ip setting
echo 0
exit
