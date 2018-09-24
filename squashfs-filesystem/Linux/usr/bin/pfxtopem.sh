#! /bin/sh

# command line parameters
# $1 incertfile - This is the .pfx (pkcs12) file that we are reading
# $2 outcertfile - This is the .pem file that we will be creating 
# $3 password - This is the export password of the pkcs12 file

RETCODE=1 #initialize to failure

#validate the number of command line parameters 
if [ $# -eq 3 ]
then

 incertfile=$1
 outcertfile=$2
 password=$3

#make sure the .pem file specified is not present 
rm -f $outcertfile

#run the openssl command 
openssl pkcs12 -in $1 -out $2 -nodes -passin pass:$3

else
 echo incorrect number of input parameters
 exit "$RETCODE"
fi

#if we got here we are assuming everything went ok
RETCODE=0 

exit "$RETCODE"
