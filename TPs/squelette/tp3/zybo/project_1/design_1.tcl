
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
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

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
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

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_1 ]
  set_property -dict [ list \
CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_1

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_0

  # Create instance: axi_intc_0, and set properties
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0 ]

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
CONFIG.NUM_MI {7} \
CONFIG.NUM_SI {3} \
 ] $axi_interconnect_0

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]
  set_property -dict [ list \
CONFIG.enable_timer2 {0} \
 ] $axi_timer_0

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 blk_mem_gen_0 ]

  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 blk_mem_gen_1 ]

  # Create instance: mdm_0, and set properties
  set mdm_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_0 ]
  set_property -dict [ list \
CONFIG.C_USE_UART {1} \
 ] $mdm_0

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.5 microblaze_0 ]
  set_property -dict [ list \
CONFIG.C_D_AXI {1} \
CONFIG.C_D_LMB {0} \
CONFIG.C_I_AXI {1} \
CONFIG.C_I_LMB {0} \
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
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_intc_0_interrupt [get_bd_intf_pins axi_intc_0/interrupt] [get_bd_intf_pins microblaze_0/INTERRUPT]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins vga_axi_ip_0/s00_axi]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins axi_intc_0/s_axi] [get_bd_intf_pins axi_interconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M04_AXI [get_bd_intf_pins axi_interconnect_0/M04_AXI] [get_bd_intf_pins axi_timer_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M05_AXI [get_bd_intf_pins axi_interconnect_0/M05_AXI] [get_bd_intf_pins mdm_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M06_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M06_AXI]
  connect_bd_intf_net -intf_net mdm_0_MBDEBUG_0 [get_bd_intf_pins mdm_0/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins microblaze_0/M_AXI_DP]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_IP [get_bd_intf_pins axi_interconnect_0/S01_AXI] [get_bd_intf_pins microblaze_0/M_AXI_IP]
  connect_bd_intf_net -intf_net vga_axi_ip_0_m00_axi [get_bd_intf_pins axi_interconnect_0/S02_AXI] [get_bd_intf_pins vga_axi_ip_0/m00_axi]

  # Create port connections
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins axi_timer_0/interrupt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net btn3_1 [get_bd_ports btn3] [get_bd_pins axi_gpio_0/gpio_io_i]
  connect_bd_net -net clk_1 [get_bd_ports clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_0/M04_ACLK] [get_bd_pins axi_interconnect_0/M05_ACLK] [get_bd_pins axi_interconnect_0/M06_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_0/S02_ACLK] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins mdm_0/S_AXI_ACLK] [get_bd_pins microblaze_0/Clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins vga_axi_ip_0/m00_axi_aclk] [get_bd_pins vga_axi_ip_0/s00_axi_aclk]
  connect_bd_net -net mdm_0_Debug_SYS_Rst [get_bd_pins mdm_0/Debug_SYS_Rst] [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst]
  connect_bd_net -net mdm_0_Interrupt [get_bd_pins mdm_0/Interrupt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins proc_sys_reset_0/mb_reset]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_intc_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/M04_ARESETN] [get_bd_pins axi_interconnect_0/M05_ARESETN] [get_bd_pins axi_interconnect_0/M06_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_0/S02_ARESETN] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins mdm_0/S_AXI_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins vga_axi_ip_0/m00_axi_aresetn] [get_bd_pins vga_axi_ip_0/s00_axi_aresetn]
  connect_bd_net -net reset_rtl_1 [get_bd_ports reset_rtl] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net vga_axi_ip_0_b [get_bd_ports b] [get_bd_pins vga_axi_ip_0/b]
  connect_bd_net -net vga_axi_ip_0_g [get_bd_ports g] [get_bd_pins vga_axi_ip_0/g]
  connect_bd_net -net vga_axi_ip_0_hsync [get_bd_ports hsync] [get_bd_pins vga_axi_ip_0/hsync]
  connect_bd_net -net vga_axi_ip_0_irq [get_bd_pins vga_axi_ip_0/irq] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net vga_axi_ip_0_r [get_bd_ports r] [get_bd_pins vga_axi_ip_0/r]
  connect_bd_net -net vga_axi_ip_0_vsync [get_bd_ports vsync] [get_bd_pins vga_axi_ip_0/vsync]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axi_intc_0/intr] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x8000 -offset 0x0 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x0 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x20100000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x20100000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x10000 -offset 0x40000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_intc_0/s_axi/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_intc_0/s_axi/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x41400000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mdm_0/S_AXI/Reg] SEG_mdm_0_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x41400000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs mdm_0/S_AXI/Reg] SEG_mdm_0_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x73A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs vga_axi_ip_0/s00_axi/reg0] SEG_vga_axi_ip_0_reg0
  create_bd_addr_seg -range 0x1000 -offset 0x73A00000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs vga_axi_ip_0/s00_axi/reg0] SEG_vga_axi_ip_0_reg0
  create_bd_addr_seg -range 0x8000 -offset 0x0 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x20000 -offset 0x20100000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x10000 -offset 0x40000000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_intc_0/s_axi/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41C00000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x41400000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs mdm_0/S_AXI/Reg] SEG_mdm_0_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x73A00000 [get_bd_addr_spaces vga_axi_ip_0/m00_axi] [get_bd_addr_segs vga_axi_ip_0/s00_axi/reg0] SEG_vga_axi_ip_0_reg0

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.8
#  -string -flagsOSRD
preplace port vsync -pg 1 -y 870 -defaultsOSRD
preplace port btn3 -pg 1 -y 1060 -defaultsOSRD -right
preplace port reset_rtl -pg 1 -y 710 -defaultsOSRD
preplace port hsync -pg 1 -y 850 -defaultsOSRD
preplace port clk -pg 1 -y 560 -defaultsOSRD
preplace portBus b -pg 1 -y 930 -defaultsOSRD
preplace portBus r -pg 1 -y 890 -defaultsOSRD
preplace portBus g -pg 1 -y 910 -defaultsOSRD
preplace inst axi_intc_0 -pg 1 -lvl 4 -y 820 -defaultsOSRD
preplace inst axi_gpio_0 -pg 1 -lvl 7 -y 1050 -defaultsOSRD
preplace inst proc_sys_reset_0 -pg 1 -lvl 1 -y 900 -defaultsOSRD
preplace inst xlconcat_0 -pg 1 -lvl 3 -y 850 -defaultsOSRD
preplace inst axi_timer_0 -pg 1 -lvl 1 -y 490 -defaultsOSRD
preplace inst mdm_0 -pg 1 -lvl 1 -y 50 -defaultsOSRD
preplace inst blk_mem_gen_0 -pg 1 -lvl 8 -y 350 -defaultsOSRD
preplace inst vga_axi_ip_0 -pg 1 -lvl 7 -y 870 -defaultsOSRD
preplace inst blk_mem_gen_1 -pg 1 -lvl 8 -y 440 -defaultsOSRD
preplace inst microblaze_0 -pg 1 -lvl 1 -y 190 -defaultsOSRD
preplace inst axi_interconnect_0 -pg 1 -lvl 5 -y 860 -defaultsOSRD
preplace inst axi_bram_ctrl_0 -pg 1 -lvl 6 -y 310 -defaultsOSRD
preplace inst axi_bram_ctrl_1 -pg 1 -lvl 6 -y 500 -defaultsOSRD
preplace netloc axi_intc_0_interrupt 1 0 5 NJ -50 NJ -50 NJ -50 NJ -50 1720
preplace netloc vga_axi_ip_0_r 1 7 2 N 870 NJ
preplace netloc mdm_0_Debug_SYS_Rst 1 0 2 130 -60 1050
preplace netloc axi_bram_ctrl_0_BRAM_PORTA 1 6 2 NJ 310 NJ
preplace netloc axi_interconnect_0_M02_AXI 1 5 2 NJ 830 NJ
preplace netloc vga_axi_ip_0_g 1 7 2 N 890 NJ
preplace netloc proc_sys_reset_0_mb_reset 1 0 2 170 270 1030
preplace netloc mdm_0_Interrupt 1 1 2 N 50 1210
preplace netloc microblaze_0_M_AXI_DP 1 1 4 NJ 180 NJ 180 NJ 180 1750
preplace netloc vga_axi_ip_0_irq 1 2 6 NJ 1190 NJ 1190 NJ 1190 NJ 1190 NJ 1190 2680
preplace netloc proc_sys_reset_0_interconnect_aresetn 1 1 4 NJ 700 NJ 700 NJ 700 N
preplace netloc vga_axi_ip_0_m00_axi 1 4 4 1750 1160 NJ 1160 NJ 1160 2690
preplace netloc axi_interconnect_0_M04_AXI 1 0 6 NJ 390 NJ 390 NJ 390 NJ 390 NJ 390 2070
preplace netloc clk_1 1 0 7 120 720 NJ 720 N 720 1490 720 1740 1180 2110 850 2420
preplace netloc vga_axi_ip_0_vsync 1 7 2 N 850 NJ
preplace netloc xlconcat_0_dout 1 3 1 N
preplace netloc microblaze_0_M_AXI_IP 1 1 4 NJ 200 NJ 200 NJ 200 1730
preplace netloc axi_interconnect_0_M05_AXI 1 0 6 NJ -30 NJ -30 NJ -30 NJ -30 NJ -30 2080
preplace netloc axi_interconnect_0_M00_AXI 1 5 1 2090
preplace netloc btn3_1 1 7 2 NJ 1060 N
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 7 140 370 1040 740 N 740 1480 740 1730 1170 2120 870 2400
preplace netloc mdm_0_MBDEBUG_0 1 0 2 160 -20 1030
preplace netloc axi_interconnect_0_M01_AXI 1 5 1 2100
preplace netloc vga_axi_ip_0_hsync 1 7 2 N 830 NJ
preplace netloc axi_interconnect_0_M06_AXI 1 5 2 NJ 920 2410
preplace netloc axi_bram_ctrl_1_BRAM_PORTA 1 6 2 2420 440 NJ
preplace netloc axi_interconnect_0_M03_AXI 1 3 3 1500 560 NJ 560 2060
preplace netloc reset_rtl_1 1 0 1 NJ
preplace netloc vga_axi_ip_0_b 1 7 2 N 910 NJ
preplace netloc axi_timer_0_interrupt 1 1 2 N 520 1200
levelinfo -pg 1 90 800 1180 1390 1610 1910 2270 2550 2800 2970 -top -70 -bot 1200
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


