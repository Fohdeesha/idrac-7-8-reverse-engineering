#!/bin/sh

#Driver code:
#Work
#	Send/receive
#Clear fifo 
#Set SSD in CR1
#Wait 100 udelay
#Clear SSD, SSA, and SSDB in CR1
#Clear fifo

set -e

CR1=0xfe002008
CR2=0xfe002010
CR3=0xfe002018
CPLD=0x14000039
FIFO=0xfe002000
OPCODE_RDSR=0x05
OPCODE_RD_LOCKRG=0xE8
OPCODE_RD_FLSR=0x70
OPCODE_RD_NVCR=0xB5
OPCODE_WT_NVCR=0xB1
OPCODE_RD_VCR=0x85
OPCODE_WT_VCR=0x81
OPCODE_RD_EVCR=0x65
OPCODE_WT_EVCR=0x61
OPCODE_RSTEN=0x66
OPCODE_RSTMEM=0x99
OPCODE_RSTIO=0xFF
OPCODE_WREN=0x06

spi_send_rec()
{
   local CMD_LEN=$1
   local CMD
   local REC_LEN
   local i=0
   # Receive len is the last arg
   for REC_LEN in $@; do :; done

   #clear SSA in CR1
   cr1=0x`MemAccess2 -rl -a $CR1 -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
   cr1=`printf '0x%x' $(($cr1&~1))`
   MemAccess2 -wl -a $CR1 -d $cr1 -c 1 1>/dev/null


   for CMD in ${@:2} ; do
      MemAccess2 -wl -a $FIFO -d $CMD -c 1 1>/dev/null
      i=$(($i+1))
      if [ $i -eq $CMD_LEN ]; then
         break
      fi
   done


   #set receive length
   MemAccess2 -wl -a $CR3 -d $REC_LEN -c 1 1>/dev/null

   #clear SSD and set SSDB in CR1
   cr1=0x`MemAccess2 -rl -a $CR1 -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
   cr1=`printf '0x%x' $(($cr1|4&~((2))))`
   MemAccess2 -wl -a $CR1 -d $cr1 -c 1 1>/dev/null

   cr1=0x`MemAccess2 -rl -a $CR1 -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
   cr1=`printf '0x%x' $(($cr1|1))` 
   #set SSA in CR1
   MemAccess2 -wl -a $CR1 -d $cr1 -c 1 1>/dev/null
   sleep 1

   if [ $REC_LEN -gt 0 ]; then
      echo -n "0x"
   fi
   while [ $REC_LEN -gt 0 ] ; do
      data=0x`MemAccess2 -rl -a $FIFO -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
      #echo -n "$data "
      printf "%02x" $data
      REC_LEN=$(($REC_LEN-1))
   done
   echo ""

}
spi_clear_fifo()
{
   cr2=0x`MemAccess2 -rl -a $CR2 -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
   #   echo "clear fifo - toggle $cr2 to "$(($cr2|128))
#   printf "clear fif0 - toggle 0x%02x to 0x%02x \n" $cr2 $(($cr2|128))  
   cr2=`printf '0x%x' $(($cr2|128))`
   MemAccess2 -wl -a $CR2 -d $cr2 -c 1 1>/dev/null
   sleep 1
   cr2=0x`MemAccess2 -rl -a $CR2 -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
   #      echo "clear fifo - toggle $cr2 to "$(($cr2&~128))
 #  printf "clear fif0 - toggle 0x%02x to 0x%02x \n" $cr2 $(($cr2&~128))
   cr2=`printf '0x%x' $(($cr2&~128))`
   MemAccess2 -wl -a $CR2 -d $cr2 -c 1 1>/dev/null
}


spi_reset()
{
   echo "SPI reset"
   spi_clear_fifo
   cr1=0x`MemAccess2 -rl -a $CR1 -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
   cr1=`printf '0x%x' $(($cr1|2))`
   #set SSD
   MemAccess2 -wl -a $CR1 -d $cr1 -c 1 1>/dev/null
   sleep 1
   #clear SSA, SSD, and SSDB in CR1
   cr1=0x`MemAccess2 -rl -a $CR1 -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
   cr1=`printf '0x%x' $(($cr1&~((4|2|1))))`
   MemAccess2 -wl -a $CR1 -d $cr1 -c 1 1>/dev/null
   spi_clear_fifo
}

spi_controller_reset()
{
   MemAccess2 -wl -a $CR1 -d fe -c 1 1>/dev/null
   MemAccess2 -wl -a $CR1 -d 0 -c 1 1>/dev/null
   MemAccess2 -wl -a $CR3 -d 0 -c 1 1>/dev/null
   spi_clear_fifo
   cr2=0x`MemAccess2 -rl -a $CR2 -c 1 | tail -n +4 | head -n 1 | cut -f 3 -d ' '`
   cr2=`printf '0x%x' $(($cr2|7))`
   MemAccess2 -wl -a $CR2 -d $cr2 -c 1 1>/dev/null
   sleep 1

}

print_usage()
{
      echo 
      echo "Usage: $0 <argument> [options]"
      echo "Where <argument> can be one of:"
      echo "   init "
      echo "      Shut down other services that may be accessing SPI part"
      echo "   dump_reg "
      echo "      Dump registers for Micron n25q part"
      echo "   reset_sp0 "
      echo "      Reset SPI0 controller on BMC"
      echo "   micron_recover"
      echo "      Initiate I/O recovery for Micron n25q part"
      echo "   raw <cmd len> <cmd> [<cmd data>] <receive len>"
      echo "      Send raw command to spi part"
      echo "      <cmd len> is the length of the command part including the command (hex)"
      echo "      <receive len> length of the response of the command, may be zero "
      echo 
}
case "$1" in 
   start_sync)
      if [ ! -e /mmc1/SPI_shadow.bin ]
      then
         # copy the memory buffer
         /bin/dd if=/sys/kernel/debug/spishadow of=/mmc1/SPI_shadow.bin bs=4096

         # run the recovery if it hasn't been run
         # this will create the mmc1 files and stop the monitor timer
         # this will happen if the driver discovers the SPI unresponsive
         # before the spi_monitor service.
         /bin/systemctl start spi_recovery.service
         # disable the CPLD reset bit to keep external services from
         # causing the CPLD to reset the iDRAC
         cpld=0x`MemAccess2 -rb -a $CPLD -c 1 | tail  -n +4 | head -n 1 | cut -f 3 -d ' '`
         #control is bit 0
         cpld=`printf '0x%x' $(($cpld&~1))`
         MemAccess2 -wb -a $CPLD -d $cpld -c 1 1>/dev/null
      fi
      /bin/systemctl start spi_sync.timer
      ;;
   copy)
      echo "Dump SPI shadow"
      # clear the fault
      echo -n "2" > /sys/devices/platform/sh_spi.0/spi_master/spi0/spi0.1/shadow
      # copy the memory
      /bin/dd if=/sys/kernel/debug/spishadow of=/mmc1/SPI_shadow.bin bs=4096
      ;;
   erase_stress)
      while true; do
         for i in `seq 0 0x10000 0xb0000`; do
            flash_erase /dev/mtd8 $i 1
            sleep $2
         done
      done
      ;;
   init)
#      systemctl stop spi_monitor.timer
      systemctl stop idracMonitor.timer
      systemctl stop idracMonitor.service
      systemctl stop fullfw_app.service
      umount /flash/data1
      ;;
   micron_recover)
      spi_send_rec 1 $OPCODE_RSTIO 0

      ;;
   dump_reg)
      echo -n "SR   = "
      spi_send_rec 1 $OPCODE_RDSR 1
      echo -n "LKRG = "
      spi_send_rec 1 $OPCODE_RD_LOCKRG 1
      echo -n "FLSR = "
      spi_send_rec 1 $OPCODE_RD_FLSR 1

      echo -n "VCR  = "
      spi_send_rec 1 $OPCODE_RD_VCR 1
      echo -n "NVCR = "
      spi_send_rec 1 $OPCODE_RD_NVCR 2
      echo -n "EVCR = "
      spi_send_rec 1 $OPCODE_RD_EVCR 1

      spi_reset
      ;;
   raw)
      if [ $# -gt 3 ]; then
        spi_send_rec ${*:3}
      else
        print_usage
      fi
      ;;
   reset_sp0)
      spi_controller_reset
      ;;
   *)
      print_usage

esac

exit 0


