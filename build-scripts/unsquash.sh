#!/bin/bash
echo "packages required: squashfs-tools unzip binwalk"
sleep 2
wget https://downloads.dell.com/FOLDER05025751M/1/iDRAC8_2.60.60.60_A00.exe
unzip iDRAC8_2.60.60.60_A00.exe
binwalk -e firmimg.d7
sleep 1
unsquashfs -dest livefs _firmimg.d7.extracted/2F0800.squashfs
sleep 1
rm -rf _firmimg.d7.extracted/ iDRAC_2_60_60_60_Release_Notes.txt iDRAC8_2.60.60.60_A00.exe firmimg.d7
echo -e '\n'
echo "de-squashed to livefs/"
echo "please squash responsibly"
echo -e '\n'
