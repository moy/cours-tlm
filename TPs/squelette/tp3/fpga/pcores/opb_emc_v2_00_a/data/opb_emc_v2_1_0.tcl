##############################################################################
##
## Copyright (c) 2005 Xilinx, Inc. All Rights Reserved.
## DO NOT COPY OR MODIFY THIS FILE. 
## THE CONTENTS AND METHODOLOGY MAY CHANGE IN FUTURE RELEASES.
##
## opb_emc_v2_1_0.tcl
##
##############################################################################

## @BEGIN_CHANGELOG EDK_I
##
## - clean up old datastructure APIs
##
## @END_CHANGELOG


## @BEGIN_CHANGELOG EDK_Gmm_SP2
##
## Added tcl for 2.00.a version
##
## @END_CHANGELOG

#***--------------------------------***------------------------------------***
#
#			     IPLEVEL_DRC_PROC
#
#***--------------------------------***------------------------------------***


#
# check C_MAX_MEM_WIDTH
# C_MAX_MEM_WIDTH = max(C_MEMx_WIDTH)
#
proc check_iplevel_settings {mhsinst} {

    set mhs_handle   [xget_hw_parent_handle $mhsinst]
    xload_hw_library emc_common_v2_00_a
    
    hw_emc_common_v2_00_a::check_max_mem_width $mhsinst

}
