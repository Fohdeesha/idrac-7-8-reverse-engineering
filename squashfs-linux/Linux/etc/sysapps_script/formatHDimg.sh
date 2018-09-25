#!/bin/sh
IMAGE=$1
LABEL=$2


if [ -z "$IMAGE" ]
then
    echo "Arg#1: Image file name is needed" > /tmp/formatresult
    exit 1
fi

if [ -z "$LABEL" ]
then
    echo "Arg#2: Label is needed" >> /tmp/formatresult
    exit 1
fi

DEV_NAME=$(losetup -f)
losetup $DEV_NAME $IMAGE

P1_SIZE=$(stat -c %s $IMAGE)

echo Creating partitions on ${DEV_NAME} of size $P1_SIZE... >> /tmp/formatresult

P1_SECTORS=$((${P1_SIZE} / 512 - 1))
echo Sectors =$P1_SECTORS

# Clear out the first sector so that it doesn't have any stale data
# that looks like a filesystem on it.  fdisk doesn't do this.
/bin/dd if=/dev/zero of=${DEV_NAME} conv=notrunc bs=512 count=1

# Generate commands for fdisk (securely)
FDISK_CMD=$(mktemp /tmp/fdisk-XXXXXX)
#trap 'rm -f $FDISK_CMD' EXIT

echo u > ${FDISK_CMD}
echo o >> ${FDISK_CMD}

echo n >> ${FDISK_CMD}
echo p >> ${FDISK_CMD}
echo 1 >> ${FDISK_CMD}

# take the default start sector
echo >> ${FDISK_CMD}

# take the default end sector
echo >> ${FDISK_CMD}

# Active the 1st partition
echo a >> ${FDISK_CMD}
echo 1 >> ${FDISK_CMD}
echo t >> ${FDISK_CMD}
echo 6 >> ${FDISK_CMD}

echo p >> ${FDISK_CMD}
echo w >> ${FDISK_CMD}

# Create partitions
/sbin/fdisk -H128 -S1 ${DEV_NAME} 0<${FDISK_CMD}

rm -f $FDISK_CMD

/sbin/fdisk -lu ${DEV_NAME}

sector_size=`/sbin/fdisk -lu ${DEV_NAME} | /bin/awk '/^Units/ {print $9}'`
sector_start_p1=1
offset_p1=$sector_size

losetup -d $DEV_NAME
while [ $? -ne 0 ] ; do
  sleep 1
  losetup -d $DEV_NAME
done

losetup -o $offset_p1 $DEV_NAME $IMAGE

# -F 12 no longer works for scratch pad at over 300MB
# mkdosfs -F 12 -n $LABEL $DEV_NAME
mkdosfs -F 16 -n $LABEL $DEV_NAME

if [ $? -ne 0 ]
then
        echo mkdosfs failed >> /tmp/formatresult
else
        echo mkdosfs success >> /tmp/formatresult
fi

losetup -d $DEV_NAME
while [ $? -ne 0 ] ; do
  sleep 1
  losetup -d $DEV_NAME
done
exit 0
