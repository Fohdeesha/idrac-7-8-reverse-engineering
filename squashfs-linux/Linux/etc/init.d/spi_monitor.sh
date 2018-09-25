#!/bin/sh

# Start the shadow RAM here
if /bin/grep -q "NOT ENABLED" /sys/devices/platform/sh_spi.0/spi_master/spi0/spi0.1/shadow; then
   echo -n "1" > /sys/devices/platform/sh_spi.0/spi_master/spi0/spi0.1/shadow ||:
fi

exit 0                                                                       
