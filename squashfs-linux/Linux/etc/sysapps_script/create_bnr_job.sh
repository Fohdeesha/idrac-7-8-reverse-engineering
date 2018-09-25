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

# for jobType b=backup, r=restore
jobType=$1

#if [ -d "/conf" ] ; then
#  jstoreLocation="/usr/local/bin/jstore"
#else
  jstoreLocation="/bin/jcstore"
#fi

logFile="/tmp/bnr.log"

# Create a job and get the Job Id

if [ X$jobType == "Xb" ] ; then
  echo "*********Creating backup job***************" > $logFile
  rm -f /tmp/idrac_br_job_id
  $jstoreLocation -a 8 -z 164 -n Backup:Image -o /tmp/idrac_br_job_id -t TIME_NOW -s "Ready For Backup" >> $logFile
elif [ X$jobType == "Xr" ] ; then
  echo "*********Creating restore job***************" > $logFile
  rm -f /tmp/idrac_br_job_id
  $jstoreLocation -a 8 -z 165 -n Restore:Image -o /tmp/idrac_br_job_id -t TIME_NOW -s "Ready For Restore" >> $logFile
else
  echo error, invalid input parameter >> $logFile
fi

#if [ -d "/conf" ] ; then
  #modular

#  jobId=`cut -d = -f 2,2 /tmp/idrac_br_job_id`
  
  # rm whitespace using echo
#  jobId=`echo $jobId`
#  jobIdFile="/conf/idrac_br_job_id"

if [ -d "/flash/data0/oem_ps" ] ; then

   # get the service tag
   jobId=`sed 's/.*=//' /tmp/idrac_br_job_id `
   jobIdFile="/flash/data0/oem_ps/idrac_br_job_id"

else
   #error
   echo no directory to read d_h_ssl_manuf.cnf
fi


if [ X$jobId != X ] ; then
  # Update job status
  echo $jobId > $jobIdFile

  echo jobId $jobId created >> $logFile
  # Tell job store to check for new jobs
  # $jstoreLocation -a 12
else
  echo Error creating job >> $logFile
  RET_EXIT=$RET_EXIT_FAIL_JOB_CREATE;
fi

echo $RET_EXIT > /tmp/create_bnr_job_exit
exit $RET_EXIT


