#!/bin/sh

# return codes
RET_EXIT_SUCCESS=0
RET_EXIT_FAIL_JOB_CREATE=1

RET_EXIT=$RET_EXIT_SUCCESS
jobId=""
index=""
jobIdFile=""
logFile=""
jobType=""
jstoreLocation=""

# for jobType init/startup
jobType=$1

erRetryDIR="/mmc2/Easy?Restore"
erRetryFILE="/mmc2/Easy?Restore/init"
jstoreLocation="/bin/jcstore"

logFile="/tmp/sd_jobid.log"
touch $logFile

# Create a job and get the Job Id

if [ X$jobType == "Xinit" ] ; then
  echo "*********Creating shutdown job first time***************" >> $logFile
  rm -f /tmp/idrac_sd_job_id
  mkdir -p $erRetryDIR
  if [ ! -e $erRetryFILE ] ; then
      echo 3 > $erRetryFILE
  fi
# key for idrac reboot needed
  echo 1 > /tmp/ER_idrac_reboot_needed
# check DM ready for jcpop job creation
  end=180;
  COUNT=0;
  while [ $COUNT -lt $end ]; do

      getDMstatus > /var/run/Dm.log;

      COUNT=$(( $COUNT + 5 ))
      echo $COUNT >> $logFile


      if grep -q -i 'not ready' /var/run/Dm.log; then
          echo "DM not ready" >> $logFile;
      else
          echo "Looks like DM ready" >> $logFile;
          if grep -q -i 'ready' /var/run/Dm.log; then
              echo "DM ready confirmed"  >> $logFile;
              break;
          else
              echo "other failure in getDMstatus"  >> $logFile;
          fi
      fi
      sleep 5;
    # Do what you want.
    :
  done

# create storage area for tracking
  $jstoreLocation -a 8 -z 43 -n Shutdown -o /tmp/idrac_sd_job_id -t TIME_NOW -s "Shutdown Pending" >> $logFile
  if [ -e "/tmp/idrac_sd_job_id" ] ; then
     jobId=`sed 's/.*=//' /tmp/idrac_sd_job_id `
  else
     jobId=""
  fi

  if [ X$jobId != X ] ; then
    # Update job status
    echo jobId $jobId created >> $logFile
    echo $jobId > /tmp/eraseShutDownJID
  else
    echo Error creating job >> $logFile
    RET_EXIT=$RET_EXIT_FAIL_JOB_CREATE;
  fi

elif [ X$jobType == "Xstartup" ] ; then
  echo "*********Creating shutdown job after restart***************" >> $logFile
# Update storage area and check for retry limit
  if [ -e $erRetryFILE ] ; then
     echo Updating $erRetryFile >> $logFile
     while IFS='' read -r retry || [[ -n "$retry" ]]; do
     if [ X$retry == "X0" ]; then
       rm -f $erRetryFILE
       echo DONE - retries exhausted >> $logFile
     else
       retry=$(expr $retry - 1)
       echo $retry > $erRetryFILE
# Start sysConfigRestore process again Entity 4
       echo starting configure restore >> $logFile
	   IPMICmd 20 30 0 d0 00 15 10 0 0 0 10 0 08 0 0 0 0 0 0 0 0 0 0 0 0 0 >> $logFile
	   echo returned $? >> $logFile
     fi
     done < $erRetryFILE
  else
     echo "ERROR! restart without an init" >> $logFile
  fi
else
  echo "Error, invalid input parameter" >> $logFile
fi

echo "return value $RET_EXIT" >> $logFile
exit $RET_EXIT
