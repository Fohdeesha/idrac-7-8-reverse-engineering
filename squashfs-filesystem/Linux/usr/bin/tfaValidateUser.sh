#!/bin/sh

#usage tfaValidateUser.sh cert_file user_cert_path ca_cert_path crl_check_enabled

#This script expects 4 aruments:
#The user certificate extracted from the Smart Card
#The stored user certificate name & path
#The CA certificate name & path for that user
#A flag that indicates if this is an Active Directory user


cert=$1
userCert=$2
caCert=$3
crlCheck=$4
numArgs=4
validUser=1


# make sure file exists and we're passed the proper number of arguments
if [ ! -f $cert  ] 
then
	echo "Error: File $cert does not exist"
elif [ ! -f $userCert ]
then
	echo "Error: File $userCert does not exist"
elif [ ! -f $caCert ]
then
	echo "Error: File $caCert does not exist"
elif [ $# -ne $numArgs ]
then
	echo "Error: $# argmunets passed- $numArgs are required"

else
	
	storedCrl="`dirname $caCert`/crl.cer"
	tmpCrl="`dirname $caCert`/crlTemp.cer"
	caAndCrl="`dirname $caCert`/caWithCrl.cer"
	echo $caPath
	#validate input user certificate with stored copy
	if [ "`diff -q $cert $userCert`" ]
	then
		echo "Error: The Smartcard certificate $cert and stored certificate $userCert differ"
	else
		echo "the smartcard certificate $cert and stored certificate $userCert match"
		
		#validate user cert against the stored CA cert
		if [ $crlCheck = 1 ]
		then
			
			echo "Converting DER encoded CRl to PEM format" 
			openssl crl -inform DER -outform PEM -in $storedCrl -out $tmpCrl 	
			
			#verify CRL against stored CA cert
			crlVerifyResult=`openssl crl -noout -CAfile $caCert -in $tmpCrl 2>&1`
			if [ "$crlVerifyResult" =  "verify OK" ]
			then	
				#combine the CA cert with the PEM copy of the CRL for verification	
				cat $caCert $tmpCrl > $caAndCrl 
				verifyResult=`openssl verify -CAfile $caAndCrl -crl_check $cert 2>&1`
			else
				echo "Error: CRL failed check against $caCert with result $crlVerifyResult"  	
			fi

		else
			verifyResult=`openssl verify -CAfile $caCert $cert 2>&1`
		fi

		if [  "$verifyResult" = $cert:\ OK ]
		then
			echo "user certificate $cert is valid"
			#return a "pass" value
			validUser=0
		else
			echo "Error: User certificate $cert verification failed"
			echo $verifyResult
		fi 
		
	fi
	#clean up
	rm -f $tmpCrl
	rm -f $caAndCrl	
fi

exit "$validUser"


