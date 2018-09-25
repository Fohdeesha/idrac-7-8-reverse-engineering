#!/bin/sh
#
# usage: ./validateSSLcert.sh
#

# set "off" to turn off debug
_DEBUG="off"
DEBUG()
{
 [ "$_DEBUG" == "on" ] &&  $@
}

############## Working directories and files ###############
DEFAULT=/etc/default
SYSCONFIG=/etc/sysconfig
CA=/etc/certs/CA
CERTS=/etc/certs/CA/certs
CSR=/etc/certs/CA/csr
CRL=/etc/certs/CA/crl
NEWCERTS=/etc/certs/CA/newcerts
PRIVATE=/flash/data0/cv/private
INDEXFILE=/etc/certs/CA/index.txt
SERIALNUMBER=/etc/certs/CA/serial
SERIALNUMBER_PS=/flash/data0/oem_ps/cert_serial
CRLNUMBER=/etc/certs/CA/crlnumber
CRLNUMBER_PS=/flash/data0/oem_ps/cert_crlnumber

CERTFLAG=/etc/certs/CA/.certflag
GENNEWCERT=/etc/certs/CA/.gennewcert
COMMONNAMEUSED=/etc/certs/CA/.commonnameused
CERTFILE=/etc/certs/CA/certs/host.crt
OLD_CERTFILE=/etc/certs/host.cert
CERTKEY=/flash/data0/cv/private/host.key
OLD_CERTKEY=/etc/certs/host.key
CSRFILE=/etc/certs/CA/csr/host.csr
CUSTOMSIGNINGCERT=/etc/certs/CA/certs/host-custom-signing.crt
CUSTOMSIGNINGCERTKEY=/flash/data0/cv/private/host-custom-signing.key

APPENDEDCERTS=/etc/certs/CA/certs/appended-certs.crt

NETCONF=/tmp/network_config/iDRACnet.conf
OPENSSLCONF=/etc/certs/CA/openssl.idrac.cnf
CERTSCONF=/etc/certs/CA/idrac_certs_default.cnf

CV_CA=/flash/data0/cv/CA
CV_CERTS=/flash/data0/cv/CA/certs
CV_CSR=/flash/data0/cv/CA/csr
CV_CRL=/flash/data0/cv/CA/crl
CV_NEWCERTS=/flash/data0/cv/CA/newcerts
CV_PRIVATE=/flash/data0/cv/CA/private
CV_INDEXFILE=/flash/data0/cv/CA/index.txt
CV_SERIALNUMBER=/flash/data0/cv/CA/serial
CV_SERIALNUMBER_PS=/flash/data0/oem_ps/cv_cert_serial
CV_CRLNUMBER=/flash/data0/cv/CA/serial
CV_CRLNUMBER_PS=/flash/data0/oem_ps/cv_cert_serial
CV_OPENSSLCONF=/flash/data0/cv/CA/openssl.idrac.cert.cnf
CV_COMMONNAMEUSED=/flash/data0/cv/CA/.commonnameused
CV_CERTFILE=/flash/data0/cv/CA/certs/host.crt
CV_CERTKEY=/flash/data0/cv/CA/private/host.key
CV_CSRFILE=/flash/data0/cv/CA/csr/host.csr
CV_CERT_MODULUS=/flash/data0/cv/CA/private/mod.txt



##############################################################################
#
# Utility functions
#
##############################################################################

#
# Set Cert Flag
#
SetCertFlag()
{
	   echo "0" > "${CERTFLAG}" 
	   # Compare def idrac cert with the one in use previously	
	   IssuerName_Custom=$(openssl x509 -noout -in "${OLD_CERTFILE}" -issuer | cut -d/ -f7 | cut -d= -f2)
	   IssuerName_Default=$(openssl x509 -noout -in "${CERTFILE}" -issuer | cut -d/ -f7 | cut -d= -f2)
	   if [ "${IssuerName_Custom}" != "${IssuerName_Default}" ]; then
	   	   echo "2" > "${CERTFLAG}"
	   fi
}

#
# Gets the host name
#
GetLocalHostName()
{
   LocalHostName=$(cat "${NETCONF}" | grep -m 1 "HOST_NAME" | cut -d= -f2)
   DEBUG echo "LocalHostName=${LocalHostName}"
}

#
# Gets the domian name 
#
GetDNSHostName()
{
   DnsHostName=$(cat "${NETCONF}" | grep -m 1 "DOMAIN_NAME" | cut -d= -f2)
   DEBUG echo "DnsHostName=${DnsHostName}"
}

#
# Gets the domian name 
#
GetIpAddress()
{
      
   V4_ENABLED=$(cat "${NETCONF}" | grep -m 1 "V4_ENABLED" | cut -d= -f2)
   V6_ENABLED=$(cat "${NETCONF}" | grep -m 1 "V6_ENABLED" | cut -d= -f2)

   if [[ "${V4_ENABLED}" == "yes" ]]; then
	   DEBUG echo "Using IPv4 address"   
	   IpAddress=$(cat "${NETCONF}" | grep -m 1 "V4_ADDR" | cut -d= -f2)
	   if [[ ! "${IpAddress}" ]]; then
	   	DEBUG echo "IPv4 address is empty"   	   
	   	IpAddress="0.0.0.0"
   	   fi  	

   elif [[ "${V6_ENABLED}" == "yes" ]]; then
	   DEBUG echo "Using IPv6 address"   
	   IpAddress=$(cat "${NETCONF}" | grep -m 1 "V6_ADDR1" | cut -d= -f2)
	   if [[ ! "${IpAddress}" ]]; then
	   	DEBUG echo "Use Link Local when V6_ADDR1 is empty"   	   
	   	IpAddress=$(cat "${NETCONF}" | grep -m 1 "V6_ADDR_LINK" | cut -d= -f2)
   	   fi  	
   fi

   DEBUG echo "IpAddress=${IpAddress}"
}

#
# Get current host name of iDrac
#
GetHostName()
{
   if [ -n "$1" ]; then
	CommonNameFlag=$(cat "${CV_COMMONNAMEUSED}")	
	LOCAL_COMMONNAMEUSED=${CV_COMMONNAMEUSED}
   else
	CommonNameFlag=$(cat "${COMMONNAMEUSED}")
	LOCAL_COMMONNAMEUSED=${COMMONNAMEUSED}	
   fi
   
   if [[ ! "${CommonNameFlag}" ]]; then
	GetLocalHostName
	if [ -z ${LocalHostName} ]; then
      		GetIpAddress
		HostName="${IpAddress}"
		echo "02" > "${LOCAL_COMMONNAMEUSED}"
        else
      		GetDNSHostName
      		if [ -z ${DnsHostName} ]; then
	   		HostName="${LocalHostName}"
	   		echo "01" > "${LOCAL_COMMONNAMEUSED}"
      	   	else
		        HostName="${LocalHostName}.${DnsHostName}"
		       	echo "00" > "${LOCAL_COMMONNAMEUSED}"
      		fi
   	fi   	
   else	
	DEBUG echo "Common name options"   
        DEBUG echo "Type 00 - Hostname.DNS-Hostname"
        DEBUG echo "Type 01 - Local-Hostname"
        DEBUG echo "Type 02 - IP Address"   
        DEBUG echo "CommonNameFlag is ${CommonNameFlag}."
        GetLocalHostName
   	if [ "${CommonNameFlag}" == "00" ]; then
      		GetDNSHostName
		HostName="${LocalHostName}.${DnsHostName}"
   	
   	elif [ "${CommonNameFlag}" == "01" ]; then
   		HostName="${LocalHostName}"
   	else
   	      	GetIpAddress
		HostName="${IpAddress}"
   	fi
      
   fi
   DEBUG echo "HostName=${HostName}"
   	
}

#
# Get SSL cert common name (CN)
#
GetCommonName()
{
   if [ -n "$1" ]; then
	   CommonName=$(openssl x509 -noout -in "${CV_CERTFILE}" -subject | cut -d/ -f7 | cut -d= -f2)
	   DEBUG echo "CommonName=${CommonName}"
   else
	   CommonName=$(openssl x509 -noout -in "${CERTFILE}" -subject | cut -d/ -f7 | cut -d= -f2)
	   DEBUG echo "CommonName=${CommonName}"
   fi
}

GetCertificateDefaults() 
{
   if [ -n "$1" ]; then
    	GetHostName $1
   else
   	GetHostName
   fi
   SubjectArg="/C=$(cat "${CERTSCONF}" | grep -m 1 "COUNTRY" | cut -d= -f2)"      
   SubjectArg="${SubjectArg}/ST=$(cat "${CERTSCONF}" | grep -m 1 "STATE" | cut -d= -f2)"
   SubjectArg="${SubjectArg}/L=$(cat "${CERTSCONF}" | grep -m 1 "LOCALITY" | cut -d= -f2)"
   SubjectArg="${SubjectArg}/O=$(cat "${CERTSCONF}" | grep -m 1 "ORGANIZATION" | cut -d= -f2)"
   SubjectArg="${SubjectArg}/OU=$(cat "${CERTSCONF}" | grep -m 1 "ORGANIZATION_UNIT" | cut -d= -f2)"
   SubjectArg="${SubjectArg}/CN=${HostName}"
   DEBUG echo "SubjectArg=${SubjectArg}"
}

GenerateNewRequest() 
{      
   DEBUG echo "Generate new CSR"	
   openssl req -config "${OPENSSLCONF}" -newkey rsa:2048 -nodes -keyout "${CERTKEY}" -out "${CSRFILE}" -subj "${SubjectArg}" -days 2556         
}

SignRequest() 
{	
   DEBUG echo "Sign the new request using the uploaded custom signing certificate"		   
   openssl ca -batch -md sha256 -config "${OPENSSLCONF}" -policy policy_anything -cert "${CUSTOMSIGNINGCERT}" -out "${CERTFILE}" -infiles "${CSRFILE}"
}

RevokeExpiredCertificate() 
{ 
   DEBUG ECHO "REVOKE EXPIRED CERTIFICATE"	
   openssl ca -config "${OPENSSLCONF}" -revoke "${CERTFILE}"
   # openssl ca -config "${OPENSSLCONF}" -gencrl -out "${CRL}/ca.crl"
   DEBUG echo "Generate CRL"
   cp ${CRLNUMBER} ${CRLNUMBER_PS}    
}

RemoveCSRFile()
{  
   DEBUG echo "Remove CSR file"	
   rm -f "${CSRFILE}"   
}


GenerateNewCertificate()
{
   echo "" > "${COMMONNAMEUSED}"
   Yesterday=$(date -d @`echo $((\`date +%s\` -86400))` +"%Y%m%d000000Z")	
   DEBUG echo "Generate new certificate signed by custom signing cert"	
   GetCertificateDefaults   
   GenerateNewRequest      
   DEBUG echo "Sign the new request using the uploaded custom signing certificate"		   
   openssl ca -batch -md sha256 -in "${CSRFILE}" -config "${OPENSSLCONF}" -policy policy_anything -cert "${CUSTOMSIGNINGCERT}" -keyfile "${CUSTOMSIGNINGCERTKEY}" -out "${CERTFILE}" -startdate "${Yesterday}"	 	 
   #openssl ca -batch -config "${OPENSSLCONF}" -policy policy_anything -cert "${CUSTOMSIGNINGCERT}" -out "${CERTFILE}" -infiles "${CSRFILE}"
   DEBUG echo "Append the server certificate and CA certificate into one file"
   cat "${CERTFILE}" "${CUSTOMSIGNINGCERT}" > "${APPENDEDCERTS}"
   mv "${APPENDEDCERTS}" "${CERTFILE}"
   cp ${SERIALNUMBER} ${SERIALNUMBER_PS}
#   shmwrite -i 2 0
#   /etc/sysapps_script/S_7600_appweb.sh restart
#   /etc/sysapps_script/S_avct_server_maser.sh restart       
#    sleep 45
#    reboot
}

do_cv_certs() {
	mkdir -p ${CV_CA}
	mkdir -p ${CV_CERTS}
	mkdir -p ${CV_CSR}
	mkdir -p ${CV_CRL}
	mkdir -p ${CV_NEWCERTS}
	mkdir -p ${CV_PRIVATE}
	touch ${CV_INDEXFILE}
	
	if [ -e "${CV_SERIALNUMBER_PS}" ] && [ ! -e "${CV_SERIALNUMBER_PS}" ]; then 
		cp ${CV_SERIALNUMBER} ${CV_SERIALNUMBER_PS}
		cp ${CV_CRLNUMBER} ${CV_CRLNUMBER_PS}
	elif [ ! -e "${CV_SERIALNUMBER}" ] && [ -e "${CV_SERIALNUMBER_PS}" ]; then
		cp ${CV_SERIALNUMBER_PS} ${CV_SERIALNUMBER}
		cp ${CV_CRLNUMBER_PS} ${CV_CRLNUMBER}
	elif [ ! -e "${CV_SERIALNUMBER}" ] && [ ! -e "${CV_SERIALNUMBER_PS}" ]; then	
		echo "01" > ${CV_SERIALNUMBER}
		echo "01" > ${CV_CRLNUMBER}
		cp ${CV_SERIALNUMBER} ${CV_SERIALNUMBER_PS}
		cp ${CV_CRLNUMBER} ${CV_CRLNUMBER_PS}
	fi
	
	touch ${CV_COMMONNAMEUSED}
	cp /etc/sysconfig/openssl.idrac.cert.cnf ${CV_CA}

	if [ ! -e "${CV_CERTFILE}" ] || [ ! -s "${CV_CERTFILE}" ] || [ ! -e "${CV_CERTKEY}" ] || [ ! -s "${CV_CERTKEY}" ]; then
		GenerateNewSelfSignedCertificate
	else
		# Validate and generate if necessary
		GetHostName cv
		GetCommonName cv
		if [ "${HostName}" != "${CommonName}" ]; then
		     DEBUG echo "idrac host name doesn't match common name"
		     #RevokeExpiredCertificate
		     #RemoveCSRFile
		     GenerateNewSelfSignedCertificate
	     	     exit 0
	  	fi

		# The Common Name (CN in certificate is valid so now
	        # check the expiration date in cerificate
	        DAYS=30
	        openssl x509 -checkend $(( 86400 * $DAYS )) -in "${CERTFILE}" > /dev/null
	        if [ $? != 0 ]; then
			DEBUG echo "==> Certificate ${CERTFILE} is about to expire soon:"		 
			GenerateNewSelfSignedCertificate		 
			exit 0
	  	fi	  	
	fi
}


GenerateNewSelfSignedCertificate() 
{
   echo "" > "${CV_COMMONNAMEUSED}"
   Yesterday=$(date -d @`echo $((\`date +%s\` -86400))` +"%Y%m%d000000Z")
   GetCertificateDefaults cv		
   openssl req -config "${CV_OPENSSLCONF}" -newkey rsa:2048 -nodes -keyout "${CV_CERTKEY}" -out "${CV_CSRFILE}" -subj "${SubjectArg}" -days 2556         
   openssl ca -batch -selfsign -in "${CV_CSRFILE}" -config "${CV_OPENSSLCONF}" -keyfile "${CV_CERTKEY}" -policy policy_anything -out "${CV_CERTFILE}" -extensions v3_ca -startdate "${Yesterday}"
   openssl x509 -modulus -noout -in "${CV_CERTFILE}" > "${CV_CERT_MODULUS}"   
   cp ${CV_SERIALNUMBER} ${CV_SERIALNUMBER_PS}
}

RenewCertificate() 
{
   RevokeExpiredCertificate
   SignRequest
}

##############################################################################
#
# Main Script
#
##############################################################################

# now we can validate certificate by first checking the local
# idrac host name vs Common Name (CN) in certificate.

flag=$(cat "${CERTFLAG}")
sernum=$(cat "${SERIALNUMBER}")

DEBUG echo "Supported certificate types in iDRAC"   
DEBUG echo "Type 1 - Certificate signed by custom signing certificate"
DEBUG echo "Type 2 - Custom SSL certificate"   
DEBUG echo "CERTFLAG is ${flag}."

if [ -n "$1" ]; then
    	cv_arg=$1
   	if [ "${cv_arg}" == "0" ]; then
		do_cv_certs
   	elif [ "${cv_arg}" == "1" ]; then
   		rm -rf "${CV_CERTFILE}"
   		rm -rf "${CV_CERTKEY}"
   		rm -rf "${CV_CERT_MODULUS}"
   	else
		DEBUG echo -e "Invalid argument" 
		exit 1
   	fi
    	
else
	if [ -e "${GENNEWCERT}" ]; then
	   	# certificate doesn't exist
   		DEBUG echo "certificate doesn't exist, creating it..."
   		rm -rf $GENNEWCERT   
   		if [ "${flag}" == "1" ]; then
	   		GenerateNewCertificate
   		fi
	fi
fi


DEBUG echo ""
DEBUG echo "finished..."

exit 0
