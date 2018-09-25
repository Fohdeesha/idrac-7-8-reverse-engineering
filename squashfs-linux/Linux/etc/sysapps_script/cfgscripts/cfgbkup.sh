#!/bin/sh
#script for backing up of config data
SLEEP_TIME=5

# reduce writes to flash by backing up no more than once per hour
MIN_SECS_BETWEEN_BACKUPS=$(( 60 * 60 ))

BACKUP_PATH=/mmc1/cfgbkp
BACKUP_FILENAME=cfgbkp.tar.bz2
BACKUP_MD5SUM=${BACKUP_FILENAME}.md5
BACKUP_CONTENTS_MD5SUM=cfgbkp-contents.md5
BACKUP_FILE_LIST=$BACKUP_PATH/cfgfiles.lst

TMP_LOC=/tmp/cfgbkp
CFG_LOC=/flash/data0/config
CFG_CHANGED=cfgupdate
WAIT_FOR_CHANGES=cfgchanges
CFGLOG=/tmp/cfgwrites.txt
CHKSUM_CHANGED=0

# create the list of config files that need to be backed up by parsing cfggrp.txt
create_backup_file_list() {
    cfg_lst=$1
    awk -F':' '{print "/flash/data0/config/"$3"_*";}' $CFG_LOC/*cfggrp.txt |cut -f1 |
        while read a
        do
             for file in $(echo $a)
             do
                if [ -f $file ]
                then
                   echo $file >> $cfg_lst
                fi
             done
        done 
}

# save the backup and md5sums to TMPFS. This is saved to persistent storage elsewhere.
do_backup() {
    # save tarball of config files
    tar -cjf $TMP_LOC/$BACKUP_FILENAME -T $BACKUP_FILE_LIST 2> /dev/null

    # save md5sum of tarball
    md5sum $TMP_LOC/$BACKUP_FILENAME > $TMP_LOC/$BACKUP_MD5SUM

    # save md5sum of file contents (which is different from tarball since tarball has file timestamps.)
    # files can be re-written with same data and not change md5sum, but tarball will change
    cat $(cat $BACKUP_FILE_LIST)|md5sum |awk '{print $1}' > $TMP_LOC/$BACKUP_CONTENTS_MD5SUM

    # when comparing checksums, we need to compare the contents. ignore the
    # tarball md5sum except for checking for integrity.
    local OLD_SUM=$(awk '{print $1}' $BACKUP_PATH/$BACKUP_CONTENTS_MD5SUM 2>/dev/null)
    local NEW_SUM=$(awk '{print $1}' $TMP_LOC/$BACKUP_CONTENTS_MD5SUM 2>/dev/null)
    if [ "$OLD_SUM" != "$NEW_SUM" ]; then
        CHKSUM_CHANGED=1
        mv $TMP_LOC/$BACKUP_CONTENTS_MD5SUM $BACKUP_PATH/
    fi
}

mkdir -p $TMP_LOC
mkdir -p $BACKUP_PATH
cd $TMP_LOC

# if we don't have a current backup, initiate a fake change to create one
[ ! -e $BACKUP_PATH/$BACKUP_FILENAME ] || touch  $TMP_LOC/$CFG_CHANGED

while true
do
    sleep $SLEEP_TIME ||:
    now=$(date +%s)
    [ -e $BACKUP_FILE_LIST ] || create_backup_file_list $BACKUP_FILE_LIST
    # rotate log file when over 1000 lines
    if [ $(wc -l $CFGLOG | cut -f1 -d ' ') -ge 1000 ]
    then
        echo "rotating cfgwrites.txt"
        mv $CFGLOG $CFGLOG.1
    fi

    # see if cfglib says it wrote something
    if [ -f $TMP_LOC/$CFG_CHANGED ]
    then
        echo "Some data changed. Waiting for more changes"
        rm -rf $TMP_LOC/$CFG_CHANGED
        touch $TMP_LOC/$WAIT_FOR_CHANGES
        continue # start over and wait for more changes
    fi

    # create tar and see if there is any change.
    if [ ! -f $TMP_LOC/$CFG_CHANGED -a -f $TMP_LOC/$WAIT_FOR_CHANGES ]
    then
        echo "No more changes. Calculate checksum and mark backup required"
        do_backup
        rm -rf $TMP_LOC/$WAIT_FOR_CHANGES
        [ "$CHKSUM_CHANGED" -ne 0 ] ||  echo "Contents did not change, no backup necessary"
        continue # make a backup, but wait a bit before saving
    fi

    if [ "$CHKSUM_CHANGED" -eq 0 ]; then
        # if no config files changed, we can skip the rest of the loop, we
        # don't need to save config
        continue
    fi

    # only print this message every few minutes
    if [ $(( now - ${last_print_time:=0} )) -gt $(( 60 * 5 )) ]; then
        echo "Need to save backup to persistent store. last backup age: $(( now - ${last_backup_time:=0} ))"
        last_print_time=$(date +%s)
    fi

    # if enough time has passed since last backup, save it
    if [ $(( now - ${last_backup_time:=0} )) -gt $MIN_SECS_BETWEEN_BACKUPS ]
    then
        echo "Saving backup to persistent store."
        mv $TMP_LOC/$BACKUP_FILENAME        $BACKUP_PATH
        mv $TMP_LOC/$BACKUP_MD5SUM          $BACKUP_PATH
        mv $TMP_LOC/$BACKUP_CONTENTS_MD5SUM $BACKUP_PATH
        last_print_time=0  # print message again next time around, dont wait 5 mins
        last_backup_time=$(date +%s)
        CHKSUM_CHANGED=0
    fi
done
