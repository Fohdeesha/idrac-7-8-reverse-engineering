mount -t jffs2 /dev/mtdblock5 /mnt/tmp
/bin/avct_control --file=/mnt/tmp/mas101.img --store=1 --id=MAS101 --size=0 --rw imgcreate
/bin/avct_control --file=/mnt/tmp/mas102.img --store=1 --id=MAS102 --size=0 --rw imgcreate
