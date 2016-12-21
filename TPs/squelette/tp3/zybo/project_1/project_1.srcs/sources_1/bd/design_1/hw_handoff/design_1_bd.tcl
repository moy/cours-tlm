
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set b [ create_bd_port -dir O -from 4 -to 0 -type clk b ]
  set btn3 [ create_bd_port -dir I btn3 ]
  set clk [ create_bd_port -dir I -type clk clk ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {125000000} \
 ] $clk
  set g [ create_bd_port -dir O -from 5 -to 0 g ]
  set hsync [ create_bd_port -dir O hsync ]
  set led0 [ create_bd_port -dir O led0 ]
  set r [ create_bd_port -dir O -from 4 -to 0 r ]
  set reset_rtl [ create_bd_port -dir I -type rst reset_rtl ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset_rtl
  set vsync [ create_bd_port -dir O vsync ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0 ]
  set_property -dict [ list \
CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {0} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_0

  # Create instance: axi_intc_0, and set properties
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0 ]
  set_property -dict [ list \
CONFIG.C_HAS_CIE {0} \
CONFIG.C_HAS_FAST {0} \
CONFIG.C_HAS_IPR {1} \
CONFIG.C_HAS_IVR {0} \
CONFIG.C_HAS_SIE {0} \
 ] $axi_intc_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
CONFIG.NUM_MI {6} \
CONFIG.NUM_SI {3} \
 ] $axi_interconnect_0

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]
  set_property -dict [ list \
CONFIG.enable_timer2 {0} \
 ] $axi_timer_0

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 blk_mem_gen_0 ]
  set_property -dict [ list \
CONFIG.use_bram_block {BRAM_Controller} \
 ] $blk_mem_gen_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.use_bram_block.VALUE_SRC {DEFAULT} \
 ] $blk_mem_gen_0

  # Create instance: mdm_0, and set properties
  set mdm_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_0 ]
  set_property -dict [ list \
CONFIG.C_USE_UART {1} \
 ] $mdm_0

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.6 microblaze_0 ]
  set_property -dict [ list \
CONFIG.C_D_AXI {1} \
CONFIG.C_D_LMB {0} \
CONFIG.C_I_AXI {1} \
CONFIG.C_I_LMB {0} \
CONFIG.C_USE_DCACHE {0} \
CONFIG.C_USE_ICACHE {0} \
CONFIG.C_USE_REORDER_INSTR {0} \
 ] $microblaze_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: vga_axi_ip_0, and set properties
  set vga_axi_ip_0 [ create_bd_cell -type ip -vlnv user.org:user:vga_axi_ip:1.0 vga_axi_ip_0 ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {3} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_intc_0_interrupt [get_bd_intf_pins axi_intc_0/interrupt] [get_bd_intf_pins microblaze_0/INTERRUPT]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins vga_axi_ip_0/s00_axi]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins axi_intc_0/s_axi] [get_bd_intf_pins axi_interconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M04_AXI [get_bd_intf_pins axi_interconnect_0/M04_AXI] [get_bd_intf_pins axi_timer_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M05_AXI [get_bd_intf_pins axi_interconnect_0/M05_AXI] [get_bd_intf_pins mdm_0/S_AXI]
  connect_bd_intf_net -intf_net mdm_0_MBDEBUG_0 [get_bd_intf_pins mdm_0/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins microblaze_0/M_AXI_DP]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_IP [get_bd_intf_pins axi_interconnect_0/S01_AXI] [get_bd_intf_pins microblaze_0/M_AXI_IP]
  connect_bd_intf_net -intf_net vga_axi_ip_0_m00_axi [get_bd_intf_pins axi_interconnect_0/S02_AXI] [get_bd_intf_pins vga_axi_ip_0/m00_axi]

  # Create port connections
  connect_bd_net -net axi_intc_0_irq [get_bd_pins axi_intc_0/irq] [get_bd_pins microblaze_0/Interrupt]
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins axi_timer_0/interrupt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net btn3_1 [get_bd_ports btn3] [get_bd_ports led0] [get_bd_pins axi_gpio_0/gpio_io_i]
  connect_bd_net -net clk_1 [get_bd_ports clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_0/M04_ACLK] [get_bd_pins axi_interconnect_0/M05_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_0/S02_ACLK] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins mdm_0/S_AXI_ACLK] [get_bd_pins microblaze_0/Clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins vga_axi_ip_0/m00_axi_aclk] [get_bd_pins vga_axi_ip_0/s00_axi_aclk]
  connect_bd_net -net mdm_0_Debug_SYS_Rst [get_bd_pins mdm_0/Debug_SYS_Rst] [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst]
  connect_bd_net -net mdm_0_Interrupt [get_bd_pins mdm_0/Interrupt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins proc_sys_reset_0/mb_reset]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_intc_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/M04_ARESETN] [get_bd_pins axi_interconnect_0/M05_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_0/S02_ARESETN] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins mdm_0/S_AXI_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins vga_axi_ip_0/m00_axi_aresetn] [get_bd_pins vga_axi_ip_0/s00_axi_aresetn]
  connect_bd_net -net reset_rtl_1 [get_bd_ports reset_rtl] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net vga_axi_ip_0_b [get_bd_ports b] [get_bd_pins vga_axi_ip_0/b]
  connect_bd_net -net vga_axi_ip_0_g [get_bd_ports g] [get_bd_pins vga_axi_ip_0/g]
  connect_bd_net -net vga_axi_ip_0_hsync [get_bd_ports hsync] [get_bd_pins vga_axi_ip_0/hsync]
  connect_bd_net -net vga_axi_ip_0_irq [get_bd_pins vga_axi_ip_0/irq] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net vga_axi_ip_0_r [get_bd_ports r] [get_bd_pins vga_axi_ip_0/r]
  connect_bd_net -net vga_axi_ip_0_vsync [get_bd_ports vsync] [get_bd_pins vga_axi_ip_0/vsync]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axi_intc_0/intr] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_intc_0/S_AXI/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_intc_0/S_AXI/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mdm_0/S_AXI/Reg] SEG_mdm_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs mdm_0/S_AXI/Reg] SEG_mdm_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x73A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs vga_axi_ip_0/s00_axi/reg0] SEG_vga_axi_ip_0_reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x73A00000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs vga_axi_ip_0/s00_axi/reg0] SEG_vga_axi_ip_0_reg0
  create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_intc_0/S_AXI/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C00000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs mdm_0/S_AXI/Reg] SEG_mdm_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x73A00000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs vga_axi_ip_0/s00_axi/reg0] SEG_vga_axi_ip_0_reg0

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.12  2016-01-29 bk=1.3547 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port vsync -pg 1 -y 240 -defaultsOSRD
preplace port btn3 -pg 1 -y 100 -defaultsOSRD
preplace port reset_rtl -pg 1 -y 300 -defaultsOSRD
preplace port hsync -pg 1 -y 220 -defaultsOSRD
preplace port led0 -pg 1 -y 380 -defaultsOSRD
preplace port clk -pg 1 -y 150 -defaultsOSRD
preplace portBus b -pg 1 -y 300 -defaultsOSRD
preplace portBus r -pg 1 -y 260 -defaultsOSRD
preplace portBus g -pg 1 -y 280 -defaultsOSRD
preplace inst axi_intc_0 -pg 1 -lvl 1 -y 440 -defaultsOSRD
preplace inst proc_sys_reset_0 -pg 1 -lvl 2 -y 70 -defaultsOSRD
preplace inst axi_timer_0 -pg 1 -lvl 4 -y 850 -defaultsOSRD
preplace inst axi_gpio_0 -pg 1 -lvl 4 -y 670 -defaultsOSRD
preplace inst xlconcat_0 -pg 1 -lvl 6 -y 460 -defaultsOSRD
preplace inst mdm_0 -pg 1 -lvl 1 -y 280 -defaultsOSRD
preplace inst blk_mem_gen_0 -pg 1 -lvl 5 -y 730 -defaultsOSRD
preplace inst vga_axi_ip_0 -pg 1 -lvl 4 -y 310 -defaultsOSRD
preplace inst microblaze_0 -pg 1 -lvl 2 -y 260 -defaultsOSRD
preplace inst axi_interconnect_0 -pg 1 -lvl 3 -y 490 -defaultsOSRD
preplace inst axi_bram_ctrl_0 -pg 1 -lvl 4 -y 1110 -defaultsOSRD
preplace netloc axi_intc_0_interrupt 1 1 1 390
preplace netloc vga_axi_ip_0_r 1 4 3 1710 260 NJ 260 NJ
preplace netloc mdm_0_Debug_SYS_Rst 1 1 1 360
preplace netloc axi_bram_ctrl_0_BRAM_PORTA 1 4 1 NJ
preplace netloc axi_interconnect_0_M02_AXI 1 3 1 1310
preplace netloc vga_axi_ip_0_g 1 4 3 1720 280 NJ 280 NJ
preplace netloc proc_sys_reset_0_mb_reset 1 1 2 410 360 880
preplace netloc mdm_0_Interrupt 1 1 5 NJ 350 NJ 130 NJ 130 N 130 2060
preplace netloc microblaze_0_M_AXI_DP 1 2 1 940
preplace netloc vga_axi_ip_0_irq 1 4 2 N 370 2050
preplace netloc proc_sys_reset_0_interconnect_aresetn 1 2 1 NJ
preplace netloc vga_axi_ip_0_m00_axi 1 2 3 960 140 NJ 140 1670
preplace netloc axi_interconnect_0_M04_AXI 1 3 1 1270
preplace netloc vga_axi_ip_0_vsync 1 4 3 1690 240 NJ 240 NJ
preplace netloc clk_1 1 0 4 NJ 150 380 390 NJ 210 NJ
preplace netloc xlconcat_0_dout 1 0 7 60 360 NJ 370 NJ 180 NJ 180 NJ 180 N 180 2250
preplace netloc microblaze_0_M_AXI_IP 1 2 1 930
preplace netloc axi_interconnect_0_M05_AXI 1 0 4 50 170 NJ 170 NJ 170 1260
preplace netloc axi_interconnect_0_M00_AXI 1 3 1 1280
preplace netloc btn3_1 1 0 7 NJ -20 NJ -20 NJ -20 NJ -20 NJ 380 NJ 380 NJ
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 4 50 350 NJ 380 910 200 NJ
preplace netloc axi_interconnect_0_M01_AXI 1 3 1 1320
preplace netloc mdm_0_MBDEBUG_0 1 1 1 N
preplace netloc vga_axi_ip_0_hsync 1 4 3 1680 220 NJ 220 NJ
preplace netloc axi_intc_0_irq 1 1 1 400
preplace netloc axi_interconnect_0_M03_AXI 1 0 4 40 160 NJ 160 NJ 160 1270
preplace netloc reset_rtl_1 1 0 2 NJ 50 NJ
preplace netloc vga_axi_ip_0_b 1 4 3 1730 300 NJ 300 NJ
preplace netloc axi_timer_0_interrupt 1 4 2 1720 440 N
levelinfo -pg 1 0 220 650 1110 1540 1940 2160 2320 -top -30 -bot 1190
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


