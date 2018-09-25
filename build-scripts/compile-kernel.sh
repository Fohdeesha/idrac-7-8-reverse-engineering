#!/bin/bash
echo -e '\n'
echo "packages required: too many - gcc-sh4-linux-gnu g++-sh4-linux-gnu etc etc"
echo "download the source code package (IDRAC7 & IDRAC8 are the same package):"
echo "https://opensource.dell.com/releases/idrac8/iDRAC_opensource_2.60.60.60.tar.gz"
echo "extract it, it is several gigabytes"
echo "make your changes, such as removing forced cmdline from .config"
echo "run this script from iDRAC_opensource_2.60.60.60/externalsrc/linux-yocto"
sleep 2
ARCH=sh make clean
ARCH=sh CROSS_COMPILE=sh4-linux-gnu- make uImage -j2
echo -e '\n'
echo "Kernel Built"
echo "Your file to flash is arch/sh/boot/uImage.gz"
echo -e '\n'