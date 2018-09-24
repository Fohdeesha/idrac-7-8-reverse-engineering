#!/bin/bash
# ============================================================================
# stageschema
#
# (C) Copyright IBM Corp. 2009
#
# THIS FILE IS PROVIDED UNDER THE TERMS OF THE ECLIPSE PUBLIC LICENSE
# ("AGREEMENT"). ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE
# CONSTITUTES RECIPIENTS ACCEPTANCE OF THE AGREEMENT.
#
# You can obtain a current copy of the Eclipse Public License from
# http://www.opensource.org/licenses/eclipse-1.0.php
#
# Description:
# Adds classes for the test suite to the installed SFCB schema. 
# Also removes those classes when called with the "unstage" argument.
# ============================================================================

usage() 
{
    echo "usage: $0 [-p prefix] [ -d testschemadir] [ -u ] " 1>&2 
}

NAMESPACE_DIRS="root/cimv2 root/interop root/interop2"
unstage=0

args=`getopt p:d:u $*`
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

while [ -n "$1" ]
do
  case $1 in
      -p) PREFIX=$2
          shift 2;;
      -d) TEST_SCHEMA_DIR=$2 
          shift 2;;
      -u) unstage=1
          shift;;
      --) shift;
          break;;
      **) break;;
  esac
done

if [ ! -d "$TEST_SCHEMA_DIR" ]; then
    usage $0
    exit 1
fi

if [ ! -d "$PREFIX" ]; then
    PREFIX=/usr/local
fi

if ! which sfcbrepos > /dev/null ; then
    echo " Cannot find sfcbrepos"
    exit 1
fi


STAGE_DIR=$PREFIX/var/lib/sfcb/stage

if [ $unstage -eq 1 ]; then
    echo "Removing test schema"
    CMD=sfcbunstage
else
    echo "Adding test schema"
    CMD=sfcbstage
fi

# Check for sfcbstage/sfcbunstage utility
if ! which $CMD > /dev/null
then
    echo " Cannot find $CMD"
    exit 1
else

    for ns in $NAMESPACE_DIRS  # loop over directories
    do
        echo $ns
        sdir=$TEST_SCHEMA_DIR/$ns/
        for file in `ls $sdir*.mof`  # loop over files
        do
            moffile=${file:${#sdir}:${#file}}  # extract mof filename
            regfile=`echo $moffile | sed 's/mof/reg/'`
            echo "  $moffile"

            dir=$sdir
            if [ $unstage -eq 1 ]; then unset dir; fi # unstage just needs the filename

            if [ -f $sdir/$regfile ]; then
                $CMD -s $STAGE_DIR -n $ns -r $dir$regfile $dir$moffile
            else
                $CMD -s $STAGE_DIR -n $ns $dir$moffile
            fi
        done
    done
fi

# Rebuild the repository
if [ $unstage -ne 1 ]
then
    sfcbrepos -f || exit 1
fi

exit 0
