#!/bin/sh
#Script to fetch CIM schema for sfcb.

# Evaluate the CIMSCHEMA_ env vars, if not set
# use the configure values, if available
# defaults otherwise

CIMSCHEMA_SOURCE=${CIMSCHEMA_SOURCE:-}
CIMSCHEMA_MOF=${CIMSCHEMA_MOF:-}
CIMSCHEMA_SUBDIRS=${CIMSCHEMA_SUBDIRS:-}

MOFZIPURL=${CIMSCHEMA_SOURCE:-"http://dmtf.org/sites/default/files/cim/cim_schema_v2350/cim_schema_2.35.0Final-MOFs.zip"}
SCHEMAMOF=${CIMSCHEMA_MOF:-cim_schema_2.35.0.mof}

# zip file for schema v2.17 (and others) contain subdirectories.  v2.9 does not
HASSUBDIRS=yes
if [ "$CIMSCHEMA_SUBDIRS" = "no" ]
then
    HASSUBDIRS=no
fi

TMPZIP=/tmp/cimmof.zip
trap "rm -f $TMPZIP" exit 

usage()
{
    echo usage: $1 [-f] [schemadir] >&2
}

fixschema()
{
  cd $sfcbdir/CIM
  if [ $SCHEMAMOF != CIM_Schema.mof ]
  then
      cp $SCHEMAMOF CIM_Schema.mof
  fi
}

args=`getopt f $*`
rc=$?

if [ $rc = 127 ]
then
    echo "warning: getopt not found ...continue without syntax check"
    args=$*
elif [ $rc != 0 ]
then
    usage $0
    exit 1
fi

set -- $args

force=0
while [ -n "$1" ]
do
  case $1 in
      -f) force=1
	  shift;;
      --) shift;
	  break;;
  esac
done

if [ $# = 1 ]; then
    sfcbdir=$1
elif [ $# = 0 ]; then
    sfcbdir=/usr/share/sfcb
else
    usage $0
    exit 1
fi


fetch_mof()
{
    if echo $MOFZIPURL | grep http: > /dev/null
    then
        if [ -x /usr/bin/curl ]
        then 
  	    /usr/bin/curl -o $TMPZIP $MOFZIPURL
        else
            echo "Need curl to get CIM schema files." 1>&2
            return 1
        fi
    else
	cp $MOFZIPURL $TMPZIP
    fi
}

if [ ! -f $sfcbdir/CIM/CIM_Schema.mof ] || [ $force = 1 ]
then
    echo "Fetching CIM Schema from $MOFZIPURL ..."
    if [ -d $sfcbdir/CIM ]
    then
	rm -rf $sfcbdir/CIM
	if [ $? != 0 ]
	then
	    echo "Failed to delete schema directory $sfcbdir/CIM" >&2
	    exit 1
	fi
    fi
    mkdir -p $sfcbdir/CIM
    if [ $HASSUBDIRS = yes ]
    then
	ZIPFLAGS=
    else
	ZIPFLAGS=-j
    fi
    if [ $? = 0 ]; then
	fetch_mof &&
	echo "Unpacking CIM Schema to $sfcbdir/CIM/ ..." &&
	unzip -q $ZIPFLAGS -d $sfcbdir/CIM $TMPZIP &&
	fixschema &&
	exit 0
    fi
    echo "Failed to fetch and install CIM schema" 1>&2 
else
    echo "CIM Schema already present - nothing to do."
    exit 0
fi   
