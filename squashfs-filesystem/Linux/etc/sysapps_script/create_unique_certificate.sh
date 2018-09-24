#!/bin/sh -x 
# Start the unique certificate component

exec > /var/log/certificate.log 2>&1
set -x

RETVAL=0
SLEEP_DELAY=45
# cannot use racadm command; take to long to get during boot time
KEYSIZE=`/avct/sbin/aim_config_get_int CSR/keysize`
#HOSTNAME=`racadm getconfig -g cfgLanNetworking -o cfgDNSRacName`
############# Certficates Working Directory and files ##################################
ROOT_CERTS_DIR=/etc/certs
SYSCONFIG_DIR=/etc/sysconfig
CA_DIR=${ROOT_CERTS_DIR}/CA
CERTS_DIR=${CA_DIR}/certs
CSR_DIR=${CA_DIR}/csr
CRL_DIR=${CA_DIR}/crl
NEWCERTS_DIR=${CA_DIR}/newcerts
PRIVATE_DIR=/flash/data0/cv/private
INDEXFILE=${CA_DIR}/index.txt
INDEX_ATTR_FILE=${CA_DIR}/index.txt.attr
INITIALSERIALNUMBER=/etc/serial
SERIALNUMBER=${CA_DIR}/serial
SERIALNUMBER_PS=/flash/data0/oem_ps/cert_serial
CRLNUMBER=${CA_DIR}/crlnumber
CRLNUMBER_PS=/flash/data0/oem_ps/cert_crlnumber

CERTFLAG=${CA_DIR}/.certflag
GENNEWCERT=${CA_DIR}/.gennewcert
COMMONNAMEUSED=${CA_DIR}/.commonnameused
CERTFILE=/flash/data0/etc/certs/CA/certs/host.crt                                                                                   
CUSTOMFILE=/flash/data0/etc/certs/CA/certs/host-custom-signing.crt
CERTKEY=/flash/data0/cv/private/host.key
TMP_CERTFILE=${ROOT_CERTS_DIR}/host.crt
TMP_CERTKEY=${ROOT_CERTS_DIR}/host.key
CSRFILE=${CSR_DIR}/host.csr
OLD_CERTFILE=/etc/certs/host.cert
OLD_CERTKEY=/etc/certs/host.key

NETCONF=/etc/sysconfig/network_config/iDRACnet.conf
KEYCONF=/flash/data0/config/Security_1
OPENSSLCONF=${CA_DIR}/openssl.idrac.cnf
CERTSCONF=${CA_DIR}/idrac_certs_default.cnf

PEMFILE=/etc/certs/CA/newcerts/01.pem
AIM_PERSISTENT_OS_STR_MAIN_CERT_PATH=/flash/data0/aim/persistent/os_str_main_cert_path
AIM_PERSISTENT_OS_STR_MAIN_KEY_PATH=/flash/data0/aim/persistent/os_str_main_key_path

YESTERDAY=
DAYS_IN_10Y=

########################################################################################		
GetDate()
{
	# need to use Y, not y for case year 1999; use -u for utc time
        YESTERDAY=$(date -u -d @`echo $((\`date +%s\` -86400))` +"%Y%m%d%H%M00Z")
        DAYS_IN_10Y=`expr 10 \* 365 + 2`     # There are at least 2 leap years in every 10 years
}

#
# Gets the host name
#
GetHostName()
{
        HostName=$(cat "${NETCONF}" | grep -m 1 "HOST_NAME" | cut -d= -f2)
        echo "HostName=${HostName}"
}

GetDomainName()
{
        DomainName=$(cat "${NETCONF}" | grep -m 1 "DOMAIN_NAME" | cut -d= -f2)
        echo "DomainName=${DomainName}"
}

GetKetySize()
{

        KeySize=$(cat "${KEYCONF}" | grep -m 1 "CsrKeySize_1" | cut -d= -f2)
        echo "KeySize=${KeySize}"
}

GetCertificateValues()
{
        GetHostName
	GetDomainName

        COUNTRY=$(cat "${CERTSCONF}" | grep -m 1 "COUNTRY" | cut -d= -f2)
        STATE=$(cat "${CERTSCONF}" | grep -m 1 "STATE" | cut -d= -f2)
        LOCALITY=$(cat "${CERTSCONF}" | grep -m 1 "LOCALITY" | cut -d= -f2)
        ORGANIZATION=$(cat "${CERTSCONF}" | grep -m 1 "ORGANIZATION" | cut -d= -f2)
        ORGANIZATION_UNIT=$(cat "${CERTSCONF}" | grep -m 1 "ORGANIZATION_UNIT" | cut -d= -f2)
        EMAIL_ADDRESS=$(cat "${CERTSCONF}" | grep -m 1 "EMAIL_ADDRESS" | cut -d= -f2)

        SubjectArg="/C=${COUNTRY}"
	SubjectArg="${SubjectArg}/ST=${STATE}"
        SubjectArg="${SubjectArg}/L=${LOCALITY}"
        SubjectArg="${SubjectArg}/O=${ORGANIZATION}"
        SubjectArg="${SubjectArg}/OU=${ORGANIZATION_UNIT}"
        SubjectArg="${SubjectArg}/emailAddress=${EMAIL_ADDRESS}"
	HostName=$(echo $HostName)
	if [ -z "$HostName" ]; then
		SvcTag=`racadm getsvctag`
		HostName="idrac-${SvcTag}"
	fi
	DomainName=$(echo $DomainName)
	if [ -z "$DomainName" ]; then
		SubjectArg="${SubjectArg}/CN=${HostName}"
	else
		SubjectArg="${SubjectArg}/CN=${HostName}.${DomainName}"
	fi
        echo "SubjectArg=${SubjectArg}"
}

GenerateNewSelfSignedCertificate()
{
        # setdate and enddate use utc time
	echo "" > "${COMMONNAMEUSED}"
	GetDate
	GetSerialNumber                 
        echo "${TempSerialNumber}" > ${SERIALNUMBER}
        GetCertificateValues
	#GetKetySize
        openssl req -newkey rsa:${KEYSIZE} -nodes -sha256 -days $DAYS_IN_10Y -subj "${SubjectArg}" -keyout "${CERTKEY}" -out "${CSRFILE}"
        openssl ca -batch -selfsign -config "${OPENSSLCONF}" -in "${CSRFILE}" -keyfile "${CERTKEY}" -policy policy_anything -out "${CERTFILE}" -extensions v3_ca -startdate "${YESTERDAY}" -days $DAYS_IN_10Y

        cp ${SERIALNUMBER} ${SERIALNUMBER_PS}
        chmod 600 ${CERTKEY}

	echo "0" > "${CERTFLAG}"
        #sleep ${SLEEP_DELAY}
    echo "A new self signed certificate was generated" >> /tmp/idrac_boot_notes
}

GetSerialNumber()
{
        GetCertificateValues
        openssl req -x509 -newkey rsa:512 -nodes -sha256 -days $DAYS_IN_10Y -subj "${SubjectArg}" -keyout "${TMP_CERTKEY}" -out "${TMP_CERTFILE}"
        TempSerialNumber=$(openssl x509 -noout -in "${TMP_CERTFILE}" -serial | cut -d/ -f7 | cut -d= -f2)
        echo "TempSerialNumber=${TempSerialNumber}"

        rm -f ${TMP_CERTFILE}
        rm -f ${TMP_CERTKEY}
}

CheckValidExpiredCert()
{
        #issuer= /C=US/ST=Texas/L=Round Rock/O=Dell Inc./OU=Remote Access Group/CN=idrac/emailAddress=support@dell.com
        
	COUNTRY1=$(openssl x509 -noout -in ${CERTFILE} -issuer | cut -d/ -f2)
        COUNTRY2=$(openssl x509 -noout -in ${CERTFILE} -subject | cut -d/ -f2)
        STATE1=$(openssl x509 -noout -in ${CERTFILE} -issuer | cut -d/ -f3)
        STATE2=$(openssl x509 -noout -in ${CERTFILE} -subject | cut -d/ -f3)
        LOCALITY1=$(openssl x509 -noout -in ${CERTFILE} -issuer | cut -d/ -f4)
        LOCALITY2=$(openssl x509 -noout -in ${CERTFILE} -subject | cut -d/ -f4)
        ORGANIZATION1=$(openssl x509 -noout -in ${CERTFILE} -issuer | cut -d/ -f5)
        ORGANIZATION2=$(openssl x509 -noout -in ${CERTFILE} -subject | cut -d/ -f5)
        ORGANIZATION_UNIT1=$(openssl x509 -noout -in ${CERTFILE} -issuer | cut -d/ -f6)
        ORGANIZATION_UNIT2=$(openssl x509 -noout -in ${CERTFILE} -subject | cut -d/ -f6)
        EMAIL1=$(openssl x509 -noout -in ${CERTFILE} -issuer | cut -d/ -f8)
        EMAIL2=$(openssl x509 -noout -in ${CERTFILE} -subject | cut -d/ -f8)

        if [ "${EMAIL1}" = "emailAddress=support@dell.com" ] && [ "${EMAIL2}" = "emailAddress=support@dell.com" ] && [ "${ORGANIZATION_UNIT1}" = "OU=Remote Access Group" ] && [ "${ORGANIZATION_UNIT2}" = "OU=Remote Access Group" ] && [ "${ORGANIZATION1}" = "O=Dell Inc." ] && [ "${ORGANIZATION2}" = "O=Dell Inc." ] && [ "${LOCALITY1}" = "L=Round Rock" ] && [ "${LOCALITY2}" = "L=Round Rock" ] && [ "${STATE1}" = "ST=Texas" ] && [ "${STATE2}" = "ST=Texas" ] && [ "${COUNTRY1}" = "C=US" ] && [ "${COUNTRY2}" = "C=US" ]; then
                VALID_EXPIRED_CERT="true"
        else
                VALID_EXPIRED_CERT="false"
        fi

}

InitCertDirs() {

        if [ ! -e "/flash/data0${ROOT_CERTS_DIR}" ]; then
                mkdir -p /flash/data0${ROOT_CERTS_DIR}
        fi

        if [ ! -e "${ROOT_CERTS_DIR}" ]; then
                echo "[WARNING]: /etc/certs link does not exist"
                ln -s /flash/data0${ROOT_CERTS_DIR} ${ROOT_CERTS_DIR}
        fi

        if [ ! -e "/flash/data0${ROOT_CERTS_DIR}/cacerts" ]; then
                mkdir -p /flash/data0${ROOT_CERTS_DIR}/cacerts
        fi

        if [ ! -e "/flash/data0${ROOT_CERTS_DIR}/csr" ]; then
                mkdir -p /flash/data0${ROOT_CERTS_DIR}/csr
        fi

        # Create the CA directory hierarchy
        if [ ! -e "${CA_DIR}" ]; then
                mkdir -p ${CA_DIR}
        fi

        if [ ! -e "${CERTS_DIR}" ]; then
                mkdir -p ${CERTS_DIR}
        fi

        if [ ! -e "${CSR_DIR}" ]; then
                mkdir -p ${CSR_DIR}
        fi

        if [ ! -e "${CRL_DIR}" ]; then
                mkdir -p ${CRL_DIR}
        fi

        if [ ! -e "${NEWCERTS_DIR}" ]; then
                mkdir -p ${NEWCERTS_DIR}
        fi

        if [ ! -e "${INDEXFILE}" ]; then
                touch ${INDEXFILE}
        fi

        if [ ! -e "${INDEX_ATTR_FILE}" ]; then
                touch ${INDEX_ATTR_FILE}
        fi

        if [ ! -e "${PRIVATE_DIR}" ]; then
                mkdir -p ${PRIVATE_DIR}
        fi

}


DoCerts() {
	
	InitCertDirs
        
	echo -n "${CERTFILE}" > ${AIM_PERSISTENT_OS_STR_MAIN_CERT_PATH}
        echo -n "${CERTKEY}" > ${AIM_PERSISTENT_OS_STR_MAIN_KEY_PATH}

        cp ${SYSCONFIG_DIR}/idrac_certs_default.cnf ${CA_DIR}
        cp ${SYSCONFIG_DIR}/openssl.idrac.cnf ${CA_DIR}

        # init the serial
	# check for zero byte size file first; if true, re-seed files
        if [ ! -s "${SERIALNUMBER}" ] || [ ! -s "${SERIALNUMBER_PS}" ]; then
                cp ${INITIALSERIALNUMBER} ${SERIALNUMBER}
                cp ${INITIALSERIALNUMBER} ${CRLNUMBER}
                cp ${SERIALNUMBER} ${SERIALNUMBER_PS}
                cp ${CRLNUMBER} ${CRLNUMBER_PS}
        elif [ -e "${SERIALNUMBER}" ] && [ ! -e "${SERIALNUMBER_PS}" ]; then
                cp ${SERIALNUMBER} ${SERIALNUMBER_PS}
                cp ${CRLNUMBER} ${CRLNUMBER_PS}
        elif [ ! -e "${SERIALNUMBER}" ] && [ -e "${SERIALNUMBER_PS}" ]; then
                cp ${SERIALNUMBER_PS} ${SERIALNUMBER}
                cp ${CRLNUMBER_PS} ${CRLNUMBER}
        elif [ ! -e "${SERIALNUMBER}" ] && [ ! -e "${SERIALNUMBER_PS}" ]; then
                cp ${INITIALSERIALNUMBER} ${SERIALNUMBER}
                cp ${INITIALSERIALNUMBER} ${CRLNUMBER}
                cp ${SERIALNUMBER} ${SERIALNUMBER_PS}
                cp ${CRLNUMBER} ${CRLNUMBER_PS}
        fi

        touch ${COMMONNAMEUSED}

        # for the case of upgrade firmware from old certs
        # avctboot.sh moves the old certs to /etc/certs/host.cert and /etc/certs/host.key
        if [ -e "${OLD_CERTFILE}" ] && [ -e "${OLD_CERTKEY}" ]; then
                echo "[INFO]: Old Certificate ${OLD_CERTFILE} and ${OLD_CERTKEY} files exist; it will copy and use these files"
                cp ${OLD_CERTFILE} ${CERTFILE}
                cp ${OLD_CERTKEY} ${CERTKEY}
                echo "2" > "${CERTFLAG}"
                rm -rf ${OLD_CERTFILE}
                rm -rf ${OLD_CERTKEY}
        # check if certificate does not exists: using -e
	# check if certificate is not size zero: using -s
        elif [ ! -e "${CERTFILE}" ] || [ ! -s "${CERTFILE}" ]; then                             
                echo "[INFO]: Certificate ${CERTFILE} does not exist"                    
                GenerateNewSelfSignedCertificate                                                                               
                exit 0                                                   
        elif [ ! -e "${CERTKEY}" ] && [ ! -e "${CUSTOMFILE}" ]; then      
                echo "[INFO]: Certificate key ${CERTKEY} does not exist"
                GenerateNewSelfSignedCertificate
		exit 0 
	# for the case of upgrade firmware from old certs
        # avctboot.sh moves the old certs to /etc/certs/host.cert and /etc/certs/host.key
        elif [ -e "${OLD_CERTFILE}" ] && [ -e "${OLD_CERTKEY}" ]; then
                echo "[INFO]: Old Certificate ${OLD_CERTFILE} and ${OLD_CERTKEY} files exist; it will copy and use these files"
                cp ${OLD_CERTFILE} ${CERTFILE}
                cp ${OLD_CERTKEY} ${CERTKEY}
                echo "2" > "${CERTFLAG}"
                rm -rf ${OLD_CERTFILE}
                rm -rf ${OLD_CERTKEY}
        else
		echo "1" > "${CERTFLAG}"
                RESULT_VALID_CERT=`openssl x509 -in "${CERTFILE}" -text -noout 2>&1 | head -1`
                echo "[INFO]: Certificate ${CERTFILE} exists"
        fi


        # check if certificate is corrupted
        if [ "${RESULT_VALID_CERT}" = "unable to load certificate" ]; then
                echo "[ERROR]: Certificate ${CERTFILE} is corrupted"
                GenerateNewSelfSignedCertificate
                exit 0
        else
                echo "[INFO]: Certificate ${CERTFILE} is not corrupted"
        fi

	# check if certificate will expire soon
        RESULT_EXPIRED_CERT="$(openssl verify "${CERTFILE}" 2>&1 | grep 'depth lookup' | head -2 |  tail -1 | cut -d: -f2)"
        if [ "${RESULT_EXPIRED_CERT}" = "certificate has expired" ]; then
                echo "[ERROR:]: Certificate ${CERTFILE} is about to expire soon"
                # only generated if signed sign certificate
                CheckValidExpiredCert
		if [ "${VALID_EXPIRED_CERT}" = "true" ]; then
                	GenerateNewSelfSignedCertificate
                	exit 0
		fi
        else
                echo "[INFO]: Certificate ${CERTFILE} is not expired yet"
        fi

        # Check for invalid date (leap year)
	EXPIRE_DATE=$(openssl x509 -enddate -in /flash/data0/etc/certs/CA/certs/host.crt -noout | cut -f 2 -d =)
	month=$(echo $EXPIRE_DATE | awk '{print $1}')
	day=$(echo $EXPIRE_DATE | awk '{print $2}')
	year=$(echo $EXPIRE_DATE | awk '{print $4}')
	if [ "$month" = "Feb" -a "$day" = "29"  -a "$year" = "2026" ] ; then
                GenerateNewSelfSignedCertificate
                exit 0
        fi

        exit 0
}

start() {
	DoCerts

}

start
