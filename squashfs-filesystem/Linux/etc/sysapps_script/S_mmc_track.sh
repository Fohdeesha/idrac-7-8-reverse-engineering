#!/bin/sh

#
# MMC_TRACKING script - this script determines the freq in which
#	the mmc_stats executable logs reads/writes to the MMC
#

MMC_STATS_EXEC="/sbin/mmc_stats"         # mmc_stats executable

while true
  do
    $MMC_STATS_EXEC
    sleep 86400				# Execute once a day
  done
