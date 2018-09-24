# This script is run on every iDRAC at manufacturing time.
# to create a certificate with a derived CN using the
# node id so it can be authenticated by a provisioning server
# for zero touch deployment.
#
# Files used:
#   1) d_h_ssl_manuf.cnf
#   2) ROOTCAPK.PEM (loaded by mdiags via dynamic partition)
#   3) RootCA.pem
#   4) CUSCLTPV.PEM (optional customer CA private key)
#   5) CUSCLTPW.PEM (optional customer CA private key password)
#   6) CUSTRTCA.PEM (optional customer Root CA cert)
#
# Files created:
#   1) STAG_iDRAC_d_h_req.pem (temporary)
#   2) STAG_iDRAC_d_h_key.pem (private key for SSL handshake - client)
#   3) STAG_iDRAC_d_h_cert.pem (client certificate for ssl handshake)
#   4) STAG_client.pem or STAG_client_factory.pem (cat of cert and key)
#

# add PATH to enable racadm use
export PATH=$PATH:/usr/local/bin

ENCRYPTED_CA_PRIV_KEY="/tmp/MFGDRV/ROOTCAPK.PEM"
CA_PRIV_KEY="/tmp/ROOTCAPK2.PEM"
CUSTOMER_CA_PRIV_KEY="/tmp/MFGDRV/CUSCLTPV.PEM"
CUSTOMER_CA_PRIV_KEY_PASSWD="/tmp/MFGDRV/CUSCLTPW.PEM"
CUSTOMER_ROOT_CA_CERT="/tmp/MFGDRV/CUSTRTCA.PEM"
REQUEST_TYPE=$1
ERROR_FILE="/tmp/STAG_client_error"
IN_PROGRESS_FILE="/tmp/cert_script_pending_flag"
TMP_DIR="/tmp"

# fault codes
NO_DIRTOWRITE=1
FILE_MISSING=2
NO_STAG=3
CA_PRIV_KEY_INVALID=4
GEN_KEY_ER=5
INVALID_PASSPHASE=6
MISMATCH_PRVKEY=7
FAILTOSAVECERT=8
CA_CERT_FILE_ER=9
BAD_DESCERYPT=10
INVALID_REQTYPE=11

subf_findWd()
{
  echo $1 $2
  err=`grep -i $1 $2`
  if [ -n $err ]; then
    xret=1
  else
    xret=0
  fi
  return $xret >&2
}

subf_error_exit()
{
  # unmount the MFGDRV partition
  umount -d $TMP_DIR/MFGDRV
  rmdir $TMP_DIR/MFGDRV

  rm *.pem

  # remove 'in progress' file
  rm -f $1
  exit 0
}

cd $TMP_DIR
mkdir $TMP_DIR/MFGDRV

# create 'in progress' file
touch $IN_PROGRESS_FILE
rm -f $ERROR_FILE

if [ -d "/flash/data0/cv" ] ; then
  IDRAC_CERT_AND_KEY="/flash/data0/cv/STAG_client.pem"
  IDRAC_CERT_AND_KEY_FACTORY="/flash/data0/cv/STAG_client_factory.pem"
  OPEN_SSL_CONFIG="/usr/share/discovery/d_h_ssl_manuf.cnf"
  CA_CERT_FILE="/usr/share/discovery/RootCA.pem"
  PERSISTENT_DIR="/flash/data0/cv"
  DISCOVERY_GEN_CSR_SCRIPT="/usr/bin/discovery_gen_csr.sh"

  # mount MFGDRV maser drive to read root CA privkey
  mount -t vfat -o loop $TMP_DIR/images/MFGDRV.img $TMP_DIR/MFGDRV -oshortname=mixed

else
   #error
  echo $NO_DIRTOWRITE no directory to write STAG_client.pem to >> $ERROR_FILE
  rm -f $IN_PROGRESS_FILE
  exit 1;
fi

# prepare temporary files for ca
rm index.txt
touch index.txt
rm serial
echo 12 > serial

if [ X$REQUEST_TYPE = X0 ] ; then
   IDRAC_CERT_AND_KEY=$IDRAC_CERT_AND_KEY_FACTORY
   if ! [ -e $ENCRYPTED_CA_PRIV_KEY ]; then
       echo $FILE_MISSING $ENCRYPTED_CA_PRIV_KEY is missing >> $ERROR_FILE
       subf_error_exit $IN_PROGRESS_FILE
   fi

   #decrypt the signing key
   if ! openssl base64 -d -in $ENCRYPTED_CA_PRIV_KEY -out $CA_PRIV_KEY \
       -pass pass:zrPhlYx
   then
       echo $CA_PRIV_KEY_INVALID failed to decrypt $ENCRYPTED_CA_PRIV_KEY to $CA_PRIV_KEY >> $ERROR_FILE
	subf_error_exit $IN_PROGRESS_FILE
   fi
elif [ X$REQUEST_TYPE = X3 ] ; then
   if ! [ -e $CUSTOMER_CA_PRIV_KEY -a -e $CUSTOMER_CA_PRIV_KEY_PASSWD -a -e $CUSTOMER_ROOT_CA_CERT ]; then
       echo $FILE_MISSING at least one file is missing >> $ERROR_FILE
       subf_error_exit $IN_PROGRESS_FILE
   fi

   CA_OPTION="-passin file:$CUSTOMER_CA_PRIV_KEY_PASSWD"
   CA_PRIV_KEY=$CUSTOMER_CA_PRIV_KEY
   CA_CERT_FILE=$CUSTOMER_ROOT_CA_CERT
   cp -f $CUSTOMER_ROOT_CA_CERT $PERSISTENT_DIR
else
    echo $INVALID_REQTYPE Invalid request type $REQUEST_TYPE >> $ERROR_FILE
    subf_error_exit $IN_PROGRESS_FILE
fi

rm -f $IDRAC_CERT_AND_KEY

# generate default CSR
sh $DISCOVERY_GEN_CSR_SCRIPT
GEN_CSR_RET=$?

# generate idrac pub and private key
if [ X$GEN_CSR_RET == X$NO_STAG ] ; then
   echo $NO_STAG Service TAG not set >> $ERROR_FILE
   subf_error_exit $IN_PROGRESS_FILE
elif [ X$GEN_CSR_RET != X0 ] ; then
  echo $GEN_KEY_ER failed to generate idrac keys >> $ERROR_FILE
  subf_error_exit $IN_PROGRESS_FILE
else
  #create certificate from CSR
  rm -f $TMP_DIR/cert_err

  openssl ca -md sha384 -batch -config $OPEN_SSL_CONFIG -startdate 690101120000Z \
    -keyfile $CA_PRIV_KEY -policy policy_anything -outdir . \
    -out $TMP_DIR/STAG_iDRAC_d_h_cert.pem -cert $CA_CERT_FILE \
    $CA_OPTION -infiles $TMP_DIR/STAG_iDRAC_d_h_req.pem \
    > $TMP_DIR/cert_err 2>&1

  if [ -f $TMP_DIR/cert_err ]
  then
    if subf_findWd error $TMP_DIR/cert_err
    then
      if subf_findWd x509 $TMP_DIR/cert_err
      then
	echo $MISMATCH_PRVKEY x509 >> $ERROR_FILE
      elif subf_findWd password $TMP_DIR/cert_err
      then
	echo $INVALID_PASSPHASE password >> $ERROR_FILE
      elif subf_findWd "bad decrypt" $TMP_DIR/cert_err
      then
	echo $BAD_DESCERYPT bad decrypt >> $ERROR_FILE
      else
	echo $CA_CERT_FILE_ER internal error >> $ERROR_FILE
      fi
    fi

    #to display the message in console
    cat $TMP_DIR/cert_err
    rm -f $TMP_DIR/cert_err
  fi
fi

if ! [ -f $ERROR_FILE ]
then
    cat $TMP_DIR/STAG_iDRAC_d_h_key.pem $TMP_DIR/STAG_iDRAC_d_h_cert.pem > $IDRAC_CERT_AND_KEY
    if [ -f $IDRAC_CERT_AND_KEY ]; then
	echo certificate created
    else
	echo $FAILTOSAVECERT fail to save cert >> $ERROR_FILE
    fi
fi

# unmount the MFGDRV partition
umount -d $TMP_DIR/MFGDRV
rmdir $TMP_DIR/MFGDRV

rm *.pem

# remove 'in progress' file
rm -f $IN_PROGRESS_FILE
