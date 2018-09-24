#!/bin/sh
imcreadylogfile=/tmp/imcreadylog
imcprereadyfile=/tmp/imcpreready_init
imcprecompfile=/tmp/imcpreready_compl
imcreadyinitfile=/tmp/imcready_init
imcreadyreadfile=/tmp/imcready_read
imccompfile=/tmp/imcready_compl
increadyoverride=/tmp/imcready_override
cmcipaddr=169.254.31.40
initsleeptime=60
cmcinitpingtime=5
cmcpingtime=2
readyfilechktime=10
readycompltime=15
filechkretrycnt=15
imccompretry=5
rebootcntfile1=/flash/data0/imcnotreadyreboot1
rebootcntfile2=/flash/data0/imcnotreadyreboot2
rebootcntfile3=/flash/data0/imcnotreadyreboot3
imcreadychkskip=/flash/data0/skipimcchk

echo $$ > /var/run/cmc-idrac.pid

chk_imcpreready()
{
       echo "chk_imcpreready(): Wait 10s" >>$imcreadylogfile
       sleep $readyfilechktime

       if [ -e $imcprecompfile ]; then
         echo "IMC PreReady completed!" >>$imcreadylogfile
       else 
         echo "IMC PreReady initiated but not finished completely so sending IMC PreReady once more" >>$imcreadylogfile
         touch $increadyoverride
         /bin/IPMICmd 0x20 0x30 0x00 0x97 0x00 0x00 0x00 0x00 0x04 0x00 0x00 0x00 0 >> /dev/null
         rm -rf $increadyoverride  >>/dev/null
         sleep $readycompltime
         ping $cmcipaddr -W 5 -c 1 >>/dev/null
         while [ $? -ne 0 ] ; do
           echo "Pingingchk CMC" >>$imcreadylogfile
           sleep $cmcpingtime;
           imccompfile=0;
           ping $cmcipaddr -W 1 -c 1 >>/dev/null
         done
       fi
       return 0
}
chk_imcready()
{
       echo "chk_imcready(): Wait 10s" >>$imcreadylogfile
       sleep $readyfilechktime

       if [ -e $imcreadyreadfile ]; then
         echo "IMC Ready read by CMC!" >>$imcreadylogfile
       else 
         echo "IMC ready initiated but not finished completely so sending IMC Ready again" >>$imcreadylogfile
         touch $increadyoverride
         /bin/IPMICmd 0x20 0x30 0x00 0x97 0x00 0x01 0x00 0x00 0x0 0x00 0x00 0x00 0 >> /dev/null
         rm -rf $increadyoverride  >>/dev/null
         sleep $readycompltime
         ping $cmcipaddr -W 5 -c 1 >>/dev/null
         while [ $? -ne 0 ] ; do
           echo "Pingingchk CMC" >>$imcreadylogfile
           sleep $cmcpingtime;
           imccompfile=0;
           ping $cmcipaddr -W 1 -c 1 >>/dev/null
         done
       fi
       return 0
}
chk_imccomplete()
{
  imcseq=0;
  while [ ${imcseq} -le $imccompretry ] ; do
    if [ -e $imccompfile ]; then
      echo "IMC Ready completed exit" >>$imcreadylogfile
       rm -rf $rebootcntfile1  >>/dev/null
       rm -rf $rebootcntfile2  >>/dev/null
       rm -rf $rebootcntfile3  >>/dev/null
       return 0
     else
#       echo "IMC ready initiated but not finished completely so sending IMC Ready once more" >>$imcreadylogfile
#       touch $increadyoverride
#       /bin/IPMICmd 0x20 0x30 0x00 0x97 0x00 0x01 0x00 0x00 0x0 0x00 0x00 0x00 0 >> /dev/null
#       rm -rf $increadyoverride  >>/dev/null
       echo "IMC Ready read by CMC but not completed! Waiting 15s.." >>$imcreadylogfile	
       sleep $readycompltime
       ping $cmcipaddr -W 5 -c 1 >>/dev/null
       while [ $? -ne 0 ] ; do
         echo "Pingingchk CMC" >>$imcreadylogfile
         sleep $cmcpingtime;
         imccompfile=0;
         ping $cmcipaddr -W 1 -c 1 >>/dev/null
       done                                 
       imcseq=`expr ${imcseq} + 1`
    fi
  done
  rm -rf $increadyoverride >>/dev/null
  return 0                  
}
d1_start()
{
if [ -e $imcreadychkskip ]; then
    echo "Skipping IMC Ready checks"
    return 0
fi

  sleep $initsleeptime;
  MemAccess POWER_OVERRIDE > /dev/null
  PWRON_Override=$?
  #echo $PWRON_Override

  if [ "$PWRON_Override" == "1" ] ; then
    return 0
  fi
  ping $cmcipaddr -W 1 -c 1 >>/dev/null
  while [ $? -ne 0 ] ; do
    echo "Pinging CMC" >> $imcreadylogfile
    sleep $cmcinitpingtime;
    ping $cmcipaddr -W 1 -c 1 >>/dev/null
  done
  cnt=0
  while [ ${cnt} -le $filechkretrycnt ] ; do
    echo "Waiting for Ready. Count: ${cnt}" >>$imcreadylogfile
    if [ -e $imcprereadyfile ]; then
      if [ -e $imcprecompfile ]; then
        if [ -e $imcreadyinitfile ]; then
          if [ -e $imcreadyreadfile ]; then
            echo "All necessary init file found chking completion" >>$imcreadylogfile
            chk_imccomplete
            return 0
          else 
            echo "Not found $imcreadyreadfile" >>$imcreadylogfile
            chk_imcready
          fi
        else
          echo "Not found $imcreadyinitfile" >>$imcreadylogfile
#          chk_imcready
      	  echo "Waiting for fullfw to signal IMC_READY" >>$imcreadylogfile
      	  sleep $readyfilechktime;
        fi
      else 
        echo "Not found $imcprecompfile" >>$imcreadylogfile
        chk_imcpreready
      fi
    else
      echo "Not found $imcprereadyfile" >>$imcreadylogfile
#        chk_imcpreready
      echo "Waiting for fullfw to signal IMC_PREREADY" >>$imcreadylogfile
      sleep $readyfilechktime;
    fi
    cnt=`expr ${cnt} + 1`
#    echo "No files found"
#    sleep $readyfilechktime;
    ping $cmcipaddr -W 5 -c 1 >>/dev/null
    while [ $? -ne 0 ] ; do
      echo "Pingingchk CMC" >> $imcreadylogfile 
      sleep $cmcpingtime;
      cnt=0;
      ping $cmcipaddr -W 1 -c 1 >>/dev/null
    done
  done
  echo "No IMC Ready sequence has been successful reboot idrac"
  touch /flash/data0/imcnotreadyreboot
  return 0
#  reboot;
}

case "$1" in
  start)
    d1_start
    ;;
    
  *)
    d1_start
    ;;

esac
