##############################################################################
## Filename:          /home/ensiens.imag.fr/moy/sle-tlm/TPs/squelette/tp3/fpga/drivers/opb_vga_v1_00_a/data/opb_vga_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Fri Sep 18 14:42:55 2009 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "opb_vga" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
