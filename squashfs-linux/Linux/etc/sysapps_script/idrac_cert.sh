#!/bin/sh
#
# usage: ./idrac_cert.sh [csr | upload | download | delete]
#

# set "off" to turn off debug
_DEBUG="on"
DEBUG()
{
 [ "$_DEBUG" == "on" ] &&  $@
}

# Macros

CA=/etc/certs/CA
CERTS=/etc/certs/CA/certs
CSR=/etc/certs/CA/csr

CERTFLAG=/etc/certs/CA/.certflag
GENNEWCERT=/etc/certs/CA/.gennewcert
CERTFILE=/etc/certs/CA/certs/host.crt
CERTKEY=/flash/data0/cv/private/host.key

# Default certificate / key:
DEFCERTFILE=/etc/default/certs/host.cert
DEFCERTKEY=/etc/default/certs/host.key

CVPATH=/flash/data0/cv
CSRPATH=/etc/certs/CA/csr
TMPFILE=/tmp/.tmp

# CSRFILE=/tmp/CSR.csr
CSRFILE=/etc/certs/CA/csr/host.csr
PRIVKEYFILE=$CVPATH/host.key

DSCFILE=$CERTS/host-default-signing.crt
DSCTMPFILE=/tmp/host-default-signing.crt
CSCFILE=$CERTS/host-custom-signing.crt
CSCTMPFILE=/tmp/host-custom-signing.crt
CSCKEY=$CVPATH/private/host-custom-signing.key
PFXFILE=$CERTS/host-custom.pfx
PFXTMPFILE=/tmp/host-custom.pfx
OPENSSLCONF=/etc/certs/CA/openssl.idrac.cnf
CSCPASSFILE=/tmp/cscpass

# Shared Memory
IDRAC_CERT_SEC=19
CSR_REQ_OFFSET=0
CSC_UPLOAD_OFFSET=1
CSC_DOWNLOAD_OFFSET=2
CSC_DELETE_OFFSET=3

# Completion Codes - will be written to the shared memory locations
CSC_SUCCESS=0
CSC_SSL_GEN_ERR=2
CSC_PKCS_FILE_MISSING=3
PKCS_FILE_WRONG=4
PKCS_PASS_WRONG=5
PKCS_EXTRACT_ERR=6
OPENSSL_UKNOWN_ERR=7
CSC_RESET=FF

##############################################################################
#
# Utility functions
#
##############################################################################

#
# Exit Upload Signing Cert in case of an error
#
UploadSCertError()
{
    if [ -e "${CSCPASSFILE}" ]; then
        # Remove password file
        rm -f $CSCPASSFILE
    fi
    # if a cert / key file was generated, remove them, they are not valid (BITS048103)
    if [ -e "${CSCFILE}" ]; then
        # Remove CS cert file
        rm -f $CSCFILE
    fi
    if [ -e "${CSCKEY}" ]; then
        # Remove CS key file
        rm -f $CSCKEY
    fi
    DEBUG echo "Upload CSC completed with errors"
    exit 1
}
#
# Upload Signing Cert
#
UploadSCert()
{
   # Upload Signing Certificate
   DEBUG echo "Upload Signing Certificate"
   # Write "FF" (reset) to the shared memory
   echo $CSC_RESET > "${TMPFILE}"
   /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
   # Custom SSL Cert. exist?
   flag=$(cat "${CERTFLAG}")
   if [ "${flag}" == "9" ]; then
      # BITS050039: After uploading Custom Certificate, uploading Custom Signing Certificate is failing 
      # 9 is not define. Writting 9 instead of 2 to the flag to make sure it will never get here. Easy fix with minimum code change and impact
      # Write "2" (SSL certificate cannot be generated) to the shared memory
      echo $CSC_SSL_GEN_ERR > "${TMPFILE}"
      /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
      DEBUG echo "SSL certificate cannot be generated"
      UploadSCertError
   else
      # Custom SSL Cert. exist in /tmp?
      if [ -e "${PFXTMPFILE}" ]; then
        # Move signing cert. from DM (/tmp) to the persistent storage. Cert will be in PKCS12 format, so file extension will change
        mv $PFXTMPFILE $PFXFILE
        if [ -e "${CSCPASSFILE}" ]; then
            # Password exists
            # Extract the certificate and private key from the input file
            # First the cert
            openssl pkcs12 -in $PFXFILE -clcerts -nokeys -passin file:$CSCPASSFILE -out $CSCFILE > $TMPFILE 2>&1
            opensslout=`cat $TMPFILE`
            DEBUG echo "Status: ${opensslout}"
            if [ "${opensslout}" != "MAC verified OK" ]; then
                if [[ "${opensslout}" == "Mac verify error"* ]]; then
                    # Write PKCS_PASS_WRONG to the shared memory
                    echo $PKCS_PASS_WRONG > "${TMPFILE}"
                    /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
                    DEBUG echo "Wrong PKCS password"
                    UploadSCertError
                else
                    # Write PKCS_FILE_WRONG to the shared memory
                    echo $PKCS_FILE_WRONG > "${TMPFILE}"
                    /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
                    DEBUG echo "Wrong PKCS file"
                    UploadSCertError
                fi
            fi
            # Then the private key
            openssl pkcs12 -in $PFXFILE -nocerts -passin file:$CSCPASSFILE -out $CSCKEY -passout pass:1234
            # Remove password file
            rm -f $CSCPASSFILE
        else
            # Password does not exist
            # Extract the certificate and private key from the input file
            # First the cert
            openssl pkcs12 -in $PFXFILE -clcerts -nokeys -passin pass: -out $CSCFILE > $TMPFILE 2>&1
            opensslout=`cat $TMPFILE`
            DEBUG echo "Status: ${opensslout}"
            if [ "${opensslout}" != "MAC verified OK" ]; then
                if [[ "${opensslout}" == "Mac verify error"* ]]; then
                    # Write PKCS_PASS_WRONG to the shared memory
                    echo $PKCS_PASS_WRONG > "${TMPFILE}"
                    /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
                    DEBUG echo "Wrong PKCS password"
                    UploadSCertError
                else
                    # Write PKCS_FILE_WRONG to the shared memory
                    echo $PKCS_FILE_WRONG > "${TMPFILE}"
                    /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
                    DEBUG echo "Wrong PKCS file"
                    UploadSCertError
                fi
            fi
            # Then the private key
            openssl pkcs12 -in $PFXFILE -nocerts -passin pass: -out $CSCKEY -passout pass:1234
        fi
        # Check if both CSC cert and key exist
        if [ -e "${CSCFILE}" ] && [ -e "${CSCKEY}" ]; then
            let "csc_size = $( ls -l ${CSCFILE} | awk '{print $5}' )"
            let "key_size = $( ls -l ${CSCKEY} | awk '{print $5}' )"
            if [ $csc_size -gt 0 ]  && [ $key_size -gt 0 ]; then
                DEBUG echo csc_size = $csc_size
                DEBUG echo key_size = $key_size
                
                # Re-encode the private key to Base64
                openssl rsa -in $CSCKEY -out $CSCKEY -passin pass:1234
                # Generate SSL cert.
                # openssl ca -batch -config "${OPENSSLCONF}" -policy policy_anything -cert "${CSCFILE}" -out "${CERTFILE}" -infiles "${CSRFILE}"    
                # Write "0" (success) to the shared memory
                echo $CSC_SUCCESS > "${TMPFILE}"
                /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
                # Delete the certificate
                #rm -f $CERTFILE
                touch $GENNEWCERT
                # Set Cert. Flag to "Custom Signing"
                echo "1" > "${CERTFLAG}"
                # Call validateSSLcert.sh to generate the SSL certificate
                /etc/sysapps_script/validateSSLcert.sh
                # Wait 5 sec before restarting AppWeb
                #sleep 30
                # Reboot iDRAC. Just in case, if not handled in validate SSL script
                #reboot
            else
                # Write PKCS_EXTRACT_ERR to the shared memory
                echo $PKCS_EXTRACT_ERR > "${TMPFILE}"
                /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
                DEBUG echo "PKCS extract error"
                UploadSCertError
            fi
        else
            # Write OPENSSL_UKNOWN_ERR to the shared memory
            echo $OPENSSL_UKNOWN_ERR > "${TMPFILE}"
            /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
            DEBUG echo "OpenSSL error - unknown"
            UploadSCertError
        fi
      else
        # Write "3" (File missing) to the shared memory
        echo $CSC_PKCS_FILE_MISSING > "${TMPFILE}"
        /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_UPLOAD_OFFSET -l 1 < "${TMPFILE}"
        DEBUG echo "PKCS file missing"
        UploadSCertError
      fi
   fi
   # Double-check
   if [ -e "${CSCPASSFILE}" ]; then
      # Remove password file
      rm -f $CSCPASSFILE
   fi
}

#
# Download Signing Cert
#
DownloadSCert()
{
  # Download Signing Certificate
  DEBUG echo "$1 $2 certificate"
  # Write "FF" (reset) to the shared memory
  echo $CSC_RESET > "${TMPFILE}"
  /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_DOWNLOAD_OFFSET -l 1 < "${TMPFILE}"   
      
  if [ $2 = "custom" ]; then
    # Download the custom signing cert
    # Custom Signing Cert. exist?
    if [ -e "${CSCFILE}" ]; then
      # Copy signing certificate to /tmp
      cp $CSCFILE $CSCTMPFILE
      # Write "0" (success) to the shared memory
      echo $CSC_SUCCESS > "${TMPFILE}"
      /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_DOWNLOAD_OFFSET -l 1 < "${TMPFILE}"
    else
      # Write "3" (Custom Signing Cert. does not exist) to the shared memory
      echo $CSC_PKCS_FILE_MISSING > "${TMPFILE}"
      /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_DOWNLOAD_OFFSET -l 1 < "${TMPFILE}"
    fi
  else
    # Download the default signing cert
    # Default Signing Cert. exist?
    if [ -e "${DSCFILE}" ]; then
      # Copy signing certificate to /tmp
      cp $DSCFILE $DSCTMPFILE
      # Write "0" (success) to the shared memory
      echo $CSC_SUCCESS > "${TMPFILE}"
      /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_DOWNLOAD_OFFSET -l 1 < "${TMPFILE}"
    else
      # Write "3" (Signing Cert. does not exist) to the shared memory
      echo $CSC_PKCS_FILE_MISSING > "${TMPFILE}"
      /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_DOWNLOAD_OFFSET -l 1 < "${TMPFILE}"
    fi
  fi 
}

#
# Delete Signing Cert
#
DeleteSCert()
{
   # Delete Signing Certificate
   DEBUG echo "Delete Signing Certificate"
   # Write "FF" (reset) to the shared memory
   echo $CSC_RESET > "${TMPFILE}"
   /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_DELETE_OFFSET -l 1 < "${TMPFILE}"
   # Custom Signing Cert. exist?
   if [ -e "${CSCFILE}" ]; then
      # Delete Signing Certificate
      rm -f $CSCFILE
      # Delete the certificate
      #rm -f $CERTFILE
      touch $GENNEWCERT
      # Set Cert. Flag to "Default"
      echo "0" > "${CERTFLAG}"
      # Copy the default certificate / key
      rm -f $CERTFILE
      rm -f $CERTKEY
      /etc/sysapps_script/create_unique_certificate.sh > /dev/null 2>&1
      # Wait 5 sec before restarting
      #sleep 30
      # Write "0" (success) to the shared memory
      echo $CSC_SUCCESS > "${TMPFILE}"
      /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_DELETE_OFFSET -l 1 < "${TMPFILE}"
      # Wait 5 sec before restarting
      # Reboot iDRAC
      #reboot -f
      echo "Reset iDRAC to apply new certificate. Until iDRAC is reset old certificate will be active."
   else
      # Write "3" (Custom Signing Cert. does not exist) to the shared memory
      echo $CSC_PKCS_FILE_MISSING > "${TMPFILE}"
      /bin/shmwrite -s $IDRAC_CERT_SEC -o $CSC_DELETE_OFFSET -l 1 < "${TMPFILE}"
   fi
}


##############################################################################
#
# Main Script
#
##############################################################################

DEBUG echo "iDRAC Certificate script"
if [ -n "$1" ]; then
    flag=$1
else
    DEBUG echo -e "Please provide an option: [csr | upload | download | delete]\n" 
    exit 1
fi


    if [ "${flag}" == "upload" ]; then
    UploadSCert
    else
    if [ "${flag}" == "download" ]; then
        DownloadSCert $1 $2
        else
            if [ "${flag}" == "delete" ]; then
            DeleteSCert
            else
            echo -e "$1 is not a valid option.\nPlease provide an option: [upload | download | delete]\n" 
                exit 1
            fi
        fi
    fi

DEBUG echo ""
DEBUG echo "finished..."

exit 0
