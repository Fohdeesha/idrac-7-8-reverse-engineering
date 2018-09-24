#!/bin/sh
if [ "$1" != start ]; then exit; fi
PATH=/avct/sbin:$PATH
rmpath=`aim_config_get_str pm_str_rfs_rmpath`
if [ "$rmpath" = "" ];
then
#echo "No Active RFS session.  Enable VM."
#/avct/sbin/aim_config_set_bool vm_bool_enabled 1 1
exit;
fi

# Restore RFS connection

i=0
(while [ 1 ]; do
if [ $i -eq 5 ] ; 
then
#echo "RFS failed to reconnect.  Re-enable VM."
#/avct/sbin/aim_config_set_bool vm_bool_enabled 1 1 
exit;
fi

if [ -e /tmp/EVENT_NETCHANGE_ACTIVE ] ;
then 
# EVENT_NETCHANGE_ACTIVE is there!
rmshrcfg

if [ $? -eq 0 ] ;
then
echo "RFS connection successful!"
exit
fi

i=$(($i+1))
sleep 15

else
# EVENT_NETCHANGE_ACTIVE is not there!
sleep 10
fi

done)&
