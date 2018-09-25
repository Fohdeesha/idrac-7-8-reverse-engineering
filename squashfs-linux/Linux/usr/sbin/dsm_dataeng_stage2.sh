#!/bin/sh
###############################################################################
#
#          Dell Inc. PROPRIETARY INFORMATION
# This software is supplied under the terms of a license agreement or
# nondisclosure agreement with Dell Inc. and may not
# be copied or disclosed except in accordance with the terms of that
# agreement.
#
# Copyright (c) 2010-2012 Dell Inc. All Rights Reserved.
#
# Module Name:
#
#   dsm_dataeng_stage2.sh
#
# Abstract/Purpose:
#
#   Systems Management Data Engine init script
#
# Environment:
#
#   iDRAC Linux
#
###############################################################################

dcecfg command=loadpopgroup groupname=dmstagetwo

