#!/bin/sh
# SMASH applications startup script
SFCB_Script="/etc/sysapps_script/sfcbd.sh"
WSMAN_Script="/etc/sysapps_script/openwsmand.sh"
CLP_Script="/etc/sysapps_script/clpd.sh"

export SFCC_CLIENT=SfcbLocal

case "$1" in
   start)
      ifconfig lo 127.0.0.1 up
      sleep 3
      sh $SFCB_Script start
      sh $WSMAN_Script start
      nohup sh $CLP_Script start > /dev/null 2>&1 &
      ;;
   stop)
      sh $SFCB_Script stop
      sh $WSMAN_Script stop
      sh $CLP_Script stop
      ;;
   reset)
      sh $SFCB_Script reset
      sh $WSMAN_Script reset
      nohup sh $CLP_Script reset > /dev/null 2>&1 &
      ;;
   reload|restart)
      sh $SFCB_Script restart
      sh $WSMAN_Script restart
      nohup sh $CLP_Script restart > /dev/null 2>&1 &
      ;;
   status)
      sh $SFCB_Script status
      sh $WSMAN_Script status
      sh $CLP_Script status
      ;;
   *)
      sh $SFCB_Script start
      sh $WSMAN_Script start
      sh $CLP_Script start
      ;;
esac

exit $?

