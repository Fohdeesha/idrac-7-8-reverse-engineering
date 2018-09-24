# This script generates a CSR with a derived CN using the node id
# so it can be authenticated by a provisioning server for zero touch
# deployment.
#
# Files used:
#   1) d_h_ssl_manuf.cnf
#
# Files created:
#   1) STAG_iDRAC_d_h_req.pem (CSR request)
#   2) STAG_iDRAC_d_h_key.pem (private key for SSL handshake - client)
#

# add PATH to enable racadm use
export PATH=$PATH:/usr/local/bin

# default values
CountryCode=""
StateName=""
Locality=""
OrganizationName=""
OrganizationUnit=""
CLIENT_ID="" # Node Id
Email="." # email is optional

RET_EXIT=0
TMP_DIR="/tmp"

# fault codes
NO_DIRTOWRITE=1
FILE_MISSING=2
NO_CLIENT_ID=3
CA_PRIV_KEY_INVALID=4
GEN_KEY_ER=5
INVALID_PASSPHASE=6
MISMATCH_PRVKEY=7
FAILTOSAVECERT=8
CA_CERT_FILE_ER=9
BAD_DESCERYPT=10
INVALID_REQTYPE=11

cd $TMP_DIR

# cleanup
rm /tmp/STAG_iDRAC_d_h_req.pem

OPEN_SSL_CONFIG="/usr/share/discovery/d_h_ssl_manuf.cnf"

# get the client id
#CLIENT_ID=`racadm getsysinfo -s | grep "Service Tag" | sed 's/.*= //'`
#DF538859 fix
CLIENT_ID=$(cat /tmp/sysinfo_nodeid)

if [ X$RET_EXIT = X0 ] ; then
  if [ ${#CLIENT_ID} -ge "7" ]; then
    echo CLIENT_ID is set to $CLIENT_ID
  else
   	echo CLIENT_ID not in file
		# Try to get the client id using IPMI
		ret=`IPMICmd 20 6 0 59 0 c5 0 0`
		stagHex=`echo ${ret} | sed 's/^.*0x07 //' | sed 's/0x/\\\\x/g' | sed 's/ //g'`
		CLIENT_ID=`echo -e ${stagHex} | cat`
		if [ ${#CLIENT_ID} -ge "7" ]; then
    	echo CLIENT_ID is set to $CLIENT_ID
		else
    	echo CLIENT_ID is BLANK
    	RET_EXIT=$NO_CLIENT_ID
		fi
  fi
fi

if [ X$RET_EXIT = X0 ] ; then
  # load parameters
  if [ -f /tmp/d_h_ssl_csr_param ] ; then
    . /tmp/d_h_ssl_csr_param
  else
    # default values
    CountryCode="US"
    StateName="TX"
    Locality="Austin"
    OrganizationName="Dell"
    OrganizationUnit="Product Group"
    Email="support@dell.com"
  fi

  export CountryCode
  export StateName
  export Locality
  export OrganizationName
  export OrganizationUnit
  export CLIENT_ID
  export Email

  # generate keys and CSR req
  if ! openssl req -new -newkey rsa:2048 -sha384 -out /tmp/STAG_iDRAC_d_h_req.pem \
    -keyout /tmp/STAG_iDRAC_d_h_key.pem -nodes -config $OPEN_SSL_CONFIG
  then
    RET_EXIT=$GEN_KEY_ER
  fi
fi

if [ X$jobId != X ] ; then
  if [ X$RET_EXIT = X0 ] ; then
    echo jobId $jobId complete
    jstore -a 11 -j $jobId -s "COMPLETED" -m "LC001" -x "The command was successful"
  else
    echo jobId $jobId failed
    jstore -a 11 -j $jobId -s "FAILED" -m "LC002" -x "General failure"
  fi
fi

exit $RET_EXIT
