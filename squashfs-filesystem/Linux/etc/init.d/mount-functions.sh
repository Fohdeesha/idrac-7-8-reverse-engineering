#!/bin/sh

recover_ext_fs() {
    partition=${1}
    mountpoint=${2}
    fstype=${3:-ext3}
    minsize=${4:-0}

    # run fsck if filesystem looks remotely salvageable
    size=0
    type=$(blkid ${partition} | sed 's/SEC_TYPE=\"[^"]*\"//' | sed -n 's/^.*TYPE=//p')
    if [ -n "${type}" -a "\"$fstype\"" != "${type}" ] ; then
        echo -n " Checking FS "
        fsck.${fstype} -p ${partition} ||:
        fsck.${fstype} -y ${partition} ||:
        size=$(tune2fs -l ${partition} | grep "Block count" | cut -d: -f2 )
    fi

    if [ $size -lt $minsize ] || ! mount $mountpoint; then
        echo "mounting $partition on $mountpoint failed, formatting partition"
        # BITS235032: Flash getting full cause of enormous software entries reaching the inode limit
        if [ ${mountpoint} == "/flash/data0" ]; then
            echo "formatting /flash/data0 with 2048 inodes"
            mkfs.${fstype} -N 2048 $partition
        else
            mkfs.${fstype} $partition
        fi
        tune2fs -m 1 $partition
    fi

    mount $mountpoint
    rm -rf $mountpoint/lost+found/*
    return 0
}

ensure_file() {
    local IMAGE_FILE=$1
    local IMAGE_MIN_SIZE=$2
    local IMAGE_SIZE=$3
    local IMAGE_CREATED_FLAG=$4
    # Check for the image file, if present don't format, it is already prepared
    local File_Size=$(stat -c %s ${IMAGE_FILE} ||:)
    if [ ! -e ${IMAGE_FILE} -o ${File_Size:-0} -lt $IMAGE_MIN_SIZE ]
    then
        #Create an image file (sparsely!) == write one byte to 1M-1 offset
        # SAVES 0.25 seconds (per megabyte), don't mess with this unless you know what you are doing!
        dd if=/dev/zero of=${IMAGE_FILE} bs=1 count=1 seek=$(( IMAGE_SIZE * 1024 * 1024 - 1 ))
        [ -z "$IMAGE_CREATED_FLAG" ] || touch $IMAGE_CREATED_FLAG
    fi
}

recover_scratchpad() {
    format_flag=$1
    image=/mnt/rawscratch/scrtch.img
    SCRTCH_IMG_SIZE_IN_MB=308
    MIN_SCRTCH_IMG_SIZE_IN_BYTES=$(( (${SCRTCH_IMG_SIZE_IN_MB} - 1) * 1024 * 1024 ))

    echo " Checking Scratchpad Image... "
    ensure_file ${image} ${MIN_SCRTCH_IMG_SIZE_IN_BYTES} ${SCRTCH_IMG_SIZE_IN_MB}

    type=$(blkid ${image} | sed 's/SEC_TYPE=\"[^"]*\"//' | sed -n 's/^.*TYPE=//p' ||:)
    if [ -n "${type}" -a  "\"vfat\"" = "${type}" ]; then
        echo -n " Checking FS "
        fsck.vfat -p ${image}
        fsck.vfat -y ${image}
    fi

    # note shell short-circuit... if format_flag is 'format', the mount will not be done in the line below
    if [ "$format_flag" = "format" ] || ! mount /mnt/scratchpad
    then
        echo -n " Re-Formatting "
        mkdosfs -n scrtch ${image}
        mount /mnt/scratchpad
    fi

    touch /mnt/scratchpad/scratchpad.txt
    return 0
}

# the following is called from pm/pm/pm/pm.c to initiate reformat of the
# scratchpad area (it's sort of overkill, we could simply remove all the files,
# but this follows the old design for now. There isn't really any compelling
# need to completely reformat it since it's already mounted and
# known-to-be-valid)
if [ "$1" = "reformat-scratchpad" ]; then
    umount /mnt/scratchpad
    rm /mnt/rawscratch/scrtch.img
    recover_scratchpad format
		ln -sf ${image} /mmc1/scrtch.img
fi
