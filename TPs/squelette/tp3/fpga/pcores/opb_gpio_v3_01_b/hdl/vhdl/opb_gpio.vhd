-------------------------------------------------------------------------------
-- $Id: opb_gpio.vhd,v 1.1 2004/11/10 23:04:00 ushap Exp $
-------------------------------------------------------------------------------
-- OPB_GPIO - entity/architecture pair 
-------------------------------------------------------------------------------
--
--  ***************************************************************************
--  **  Copyright(C) 2003 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  **  This text contains proprietary, confidential                         **
--  **  information of Xilinx, Inc. , is distributed by                      **
--  **  under license from Xilinx, Inc., and may be used,                    **
--  **  copied and/or disclosed only pursuant to the terms                   **
--  **  of a valid license agreement with Xilinx, Inc.                       **
--  **                                                                       **
--  **  Unmodified source code is guaranteed to place and route,             **
--  **  function and run at speed according to the datasheet                 **
--  **  specification. Source code is provided "as-is", with no              **
--  **  obligation on the part of Xilinx to provide support.                 **
--  **                                                                       **
--  **  Xilinx Hotline support of source code IP shall only include          **
--  **  standard level Xilinx Hotline support, and will only address         **
--  **  issues and questions related to the standard released Netlist        **
--  **  version of the core (and thus indirectly, the original core source). **
--  **                                                                       **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Support Hotline will only be able          **
--  **  to confirm the problem in the Netlist version of the core.           **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        opb_gpio.vhd
-- Version:         v3.01b
-- Description:     General Purpose I/O for OPB bus
--
-------------------------------------------------------------------------------
-- Structure: 
--
--              opb_gpio.vhd
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_Gmm_SP2 
--      * IPIF changed from v3_00_a v3_01_a  
--      * MIN_SIZE Attribute is changed from "0x1ff" to "0x100"  
--      * USER_ADDR_RANGE_ARRAY mapping changed to GPIO_HIGHADDR
--      * Fix of interrupt functionality 
-- @END_CHANGELOG 
-------------------------------------------------------------------------------
-- Author:      BLT
-- History:
-- 
--  BLT             07-05-2001      -- First version
-- ^^^^^^
--      First version of GPIO.
-- ~~~~~~
--  BLT             08-08-2001      -- Added generics
-- ^^^^^^
--      Added C_GPIO_WIDTH generic to specify number of I/O bits.
--      Added C_ALL_INPUTS generic for case when all I/O are input only.
--      Added byte enable capability to read/write regs.
-- ~~~~~~
--  JAC             07-17-2003     -- Added Dual and default reset values
--  LSS             01-09-2004     -- Corrected Interrupt functionality
-- 	                                  Changed default values of generics
--  
--  Vaibhav         08-09-2004     -- MIN_SIZE Attribute is changed 
--                                    from "0x1ff" to "0x100" to fix 
--                                    CR 189837 and CR 190262 
--                                 -- CONSTANT USER_ADDR_RANGE_ARRAY Mapping 
--                                    changed from "ZERO_ADDR_PAD & C_HIGHADDR"
--                                    to "ZERO_ADDR_PAD & GPIO_HIGHADDR"
--                                 -- CONSTANT "ARD_DEPENDENT_PROPS_ARRAY" is 
--                                    changed to Exclude the Device ISC 
--                                    IPIF service interrupts
-- 
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_cmb" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library proc_common_v2_00_a;
use proc_common_v2_00_a.proc_common_pkg.all;
use proc_common_v2_00_a.family.all;
use proc_common_v2_00_a.ipif_pkg.all;

library opb_ipif_v3_01_a; 
use opb_ipif_v3_01_a.opb_ipif;

library opb_gpio_v3_01_b; 
use opb_gpio_v3_01_b.all;

-------------------------------------------------------------------------------
--                     Defination of Generics :				     --
-------------------------------------------------------------------------------
-- C_BASEADDR          -  OPB GPIO Base Address
-- C_HIGHADDR          -  OPB GPIO High Address
-- C_USER_ID_CODE      -  User ID 
-- C_OPB_AWIDTH        -  Address width of OPB BUS.
-- C_OPB_DWIDTH        -  Data width of OPB BUS.
-- C_FAMILY	           -  Target Fpga Family
-- C_GPIO_WIDTH        -  GPIO Data Bus width.
-- C_ALL_INPUTS        -  Inputs Only. 
-- C_INTERRUPT_PRESENT -  GPIO Interrupt.
-- C_IS_BIDIR          -  Selects GPIO_IO_I as input.
-- C_DOUT_DEFAULT      -  GPIO_DATA Register reset value.
-- C_TRI_DEFAULT       -  GPIO_TRI Register reset value.
-- C_IS_DUAL           -  Dual Channel GPIO.
-- C_ALL_INPUTS_2      -  Channel2 Inputs only.
-- C_IS_BIDIR_2        -  Selects GPIO2_IO_I as input.
-- C_DOUT_DEFAULT_2    -  GPIO2_DATA Register reset value.
-- C_TRI_DEFAULT_2     -  GPIO2_TRI Register reset value.
-------------------------------------------------------------------------------  

-------------------------------------------------------------------------------
--                  Defination of Ports                                      --
-------------------------------------------------------------------------------
-- OPB_ABus    	       - OPB Address Bus
-- OPB_BE      	       - OPB Byte Enables
-- OPB_Clk     	       - OPB Clock
-- OPB_DBus    	       - OPB Data Bus
-- OPB_RNW     	       - OPB Read, Not Write
-- OPB_Rst     	       - OPB Reset
-- OPB_select  	       - OPB Select
-- OPB_seqAddr 	       - OPB Sequential Address
-- Sln_DBus    	       - OPB GPIO Data Bus
-- Sln_errAck  	       - OPB GPIO Error Acknowledge
-- Sln_retry   	       - OPB GPIO Retry
-- Sln_toutSup 	       - OPB GPIO TimeoutSuppress
-- Sln_xferAck 	       - OPB GPIO Transfer Acknowledge

-- IP2INTC_Irpt	       - OPB GPIO Interrupt

		       
-- GPIO_IO_I   	       - Channel 1 General purpose I/O in port
-- GPIO_IO_O   	       - Channel 1 General purpose I/O out port
-- GPIO_IO_T   	       - Channel 1 General purpose I/O TRI-STATE control port
-- GPIO_in     	       - Channel 1 General purpose input
-- GPIO_d_out  	       - Channel 1 GPIO_Data register out
-- GPIO_t_out  	       - Channel 1 GPIO_Tri register out
-- GPIO2_IO_I  	       - Channel 2 General purpose I/O in port
-- GPIO2_IO_O  	       - Channel 2 General purpose I/O out port
-- GPIO2_IO_T  	       - Channel 2 General purpose I/O TRI-STATE control port
-- GPIO2_in    	       - Channel 2 General purpose input
-- GPIO2_d_out 	       - Channel 2 GPIO2_Data register out
-- GPIO2_t_out 	       - Channel 2 GPIO2_Tri register out
-------------------------------------------------------------------------------

entity opb_gpio is  
  generic
  (
    C_BASEADDR          : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_HIGHADDR          : std_logic_vector(0 to 31) := X"00000000";
    C_USER_ID_CODE      : integer                   := 3;
    C_OPB_AWIDTH        : integer                   := 32;
    C_OPB_DWIDTH        : integer                   := 32;
    C_FAMILY            : string                    := "virtex2"; -- not used
    C_GPIO_WIDTH        : integer                   := 32;
    C_ALL_INPUTS        : INTEGER                   := 0;
    C_INTERRUPT_PRESENT : INTEGER                   := 0;
    C_IS_BIDIR          : INTEGER                   := 1;
    C_DOUT_DEFAULT      : STD_LOGIC_VECTOR          := X"0000_0000";
    C_TRI_DEFAULT       : STD_LOGIC_VECTOR          := X"FFFF_FFFF";
    C_IS_DUAL           : INTEGER                   := 0;
    C_ALL_INPUTS_2      : INTEGER                   := 0;
    C_IS_BIDIR_2        : INTEGER                   := 1;
    C_DOUT_DEFAULT_2    : STD_LOGIC_VECTOR          := X"0000_0000";
    C_TRI_DEFAULT_2     : STD_LOGIC_VECTOR          := X"FFFF_FFFF"
  );
  port
  (
    OPB_ABus     : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
    OPB_BE       : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
    OPB_Clk      : in  std_logic;
    OPB_DBus     : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
    OPB_RNW      : in  std_logic;
    OPB_Rst      : in  std_logic;
    OPB_select   : in  std_logic;
    OPB_seqAddr  : in  std_logic;
    Sln_DBus     : out std_logic_vector(0 to C_OPB_DWIDTH-1);
    Sln_errAck   : out std_logic;
    Sln_retry    : out std_logic;
    Sln_toutSup  : out std_logic;
    Sln_xferAck  : out std_logic;
    
    IP2INTC_Irpt : out std_logic; -- Interrupt
    
    GPIO_IO_I    : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_IO_O    : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_IO_T    : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_in      : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_d_out   : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_t_out   : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_IO_I   : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_IO_O   : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_IO_T   : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_in     : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_d_out  : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_t_out  : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1)

  );

-------------------------------------------------------------------------------
-- fan-out attributes for XST
-------------------------------------------------------------------------------
      
      attribute MAX_FANOUT                  : string;
      attribute MAX_FANOUT   of OPB_Clk     : signal is "10000";
      attribute MAX_FANOUT   of OPB_Rst     : signal is "10000";
-------------------------------------------------------------------------------
-- Attributes for MPD file
-------------------------------------------------------------------------------
      attribute IP_GROUP : string ;
      attribute IP_GROUP of opb_gpio: entity is "LOGICORE";
      attribute MIN_SIZE : string ;
  
    
      attribute MIN_SIZE of C_BASEADDR: constant is "0x100"; 
      attribute SIGIS : string ;
      attribute SIGIS of OPB_Clk: signal is "Clk";
      attribute SIGIS of OPB_Rst: signal is "Rst";
      attribute SIGIS of IP2INTC_Irpt : signal is "INTR_LEVEL_HIGH";


end entity opb_gpio; 
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------

architecture imp of opb_gpio is 

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

constant ZERO_ADDR_PAD : std_logic_vector(0 to 64-C_OPB_AWIDTH-1) := (others => '0');

constant PIPELINE_MODEL : integer   := 7;  
constant INCLUDE_BURST_SUPPORT : integer   := 0;  


constant USER_NUM_CE      : integer     := 1;

constant INTR_TYPE      : integer   := INTR_POS_EDGE_DETECT;

constant INTR_BASEADDR  : std_logic_vector(0 to 31)  := C_BASEADDR or X"00000100";
constant INTR_HIGHADDR  : std_logic_vector(0 to 31)  := C_BASEADDR or X"000001FF";
constant GPIO_HIGHADDR  : std_logic_vector(0 to 31)  := C_BASEADDR or X"0000000F";

	function set_no_intr (x:integer) return integer is
	begin
	  if (x = 0) then
	    return 1;
	    else
	    return 2;
	end if;
	end set_no_intr;

	constant NUM_USER_INTR : integer := set_no_intr(C_IS_DUAL);

constant USER_ARD_ID_ARRAY : INTEGER_ARRAY_TYPE :=
        (
         0 => USER_00 
           );

constant ARD_ID_ARRAY : INTEGER_ARRAY_TYPE := 
	add_intr_ard_id_array(C_INTERRUPT_PRESENT /= 0,USER_ARD_ID_ARRAY);

constant POSTED_ZEROS : std_logic_vector(0 to ARD_ID_ARRAY'length-1)  := (others => '0');

constant USER_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE :=
        (
         ZERO_ADDR_PAD & C_BASEADDR, 
         ZERO_ADDR_PAD & GPIO_HIGHADDR 
        );

constant ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
	add_intr_ard_addr_range_array
		(C_INTERRUPT_PRESENT /= 0,
         ZERO_ADDR_PAD,
         INTR_BASEADDR,
         INTR_HIGHADDR,
         ARD_ID_ARRAY,
         USER_ADDR_RANGE_ARRAY);


constant USER_ARD_DWIDTH_ARRAY     : INTEGER_ARRAY_TYPE :=
        (
         0 => C_OPB_DWIDTH   
        );

constant ARD_DWIDTH_ARRAY : INTEGER_ARRAY_TYPE :=
	add_intr_ard_dwidth_array
	 (C_INTERRUPT_PRESENT /= 0,
      C_OPB_DWIDTH,
	  ARD_ID_ARRAY,
      USER_ARD_DWIDTH_ARRAY);
	
constant USER_NUM_CE_ARRAY   : INTEGER_ARRAY_TYPE :=
        (
         0 =>  pad_power2(USER_NUM_CE)   
        );

constant ARD_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE :=
	add_intr_ard_num_ce_array
	  (C_INTERRUPT_PRESENT /= 0,
	   ARD_ID_ARRAY,
	   USER_NUM_CE_ARRAY);

--	populate_intr_mode_array(NUM_USER_INTR,INTR_TYPE);
constant IP_INTR_MODE_ARRAY   : INTEGER_ARRAY_TYPE :=  (5,5);

-- No dependent properties
constant ARD_DEPENDENT_PROPS_ARRAY : DEPENDENT_PROPS_ARRAY_TYPE := 
        ( 1 => (EXCLUDE_DEV_ISC =>1,
                INCLUDE_DEV_PENCODER => 0,
                others => 0),
	  0 => (others => 0));
                
-- Do not include MIR
constant DEV_MIR_ENABLE         : integer := 0;
constant DEV_BLK_ID             : integer := 0;

-- Burst support generics
-- need both the address counter and the write burst buffer
constant INCLUDE_ADDR_CNTR      : integer := 0;
constant INCLUDE_WR_BUF         : integer := 0;

constant ZERO_DATA             : std_logic_vector(0 to C_OPB_DWIDTH-1)
                                    :=  (others => '0');
constant ZERO_INTR             : std_logic_vector(0 to IP_INTR_MODE_ARRAY'length-1)
                                    := (others => '0');

--constant IP_NUM_INTR         :  INTEGER := IP_INTR_MODE_ARRAY'length;

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------

signal GPIO_xferAck_i     : std_logic;
signal GPIO_intr     : std_logic;
signal GPIO2_intr     : std_logic;
signal GPIO_DBus     : std_logic_vector(0 to C_OPB_DWIDTH-1);

signal Bus2IP_Data_i        : std_logic_vector(0 to C_OPB_DWIDTH-1);
-- IPIC Used Signals

signal ip2bus_rdack             : std_logic;
signal ip2bus_wrack             : std_logic;
signal ip2bus_ack               : std_logic;
signal ip2bus_addrack           : std_logic;
signal ip2bus_toutsup           : std_logic;
signal ip2bus_retry             : std_logic;
signal ip2bus_errack            : std_logic;
signal ip2bus_postedwrinh       : std_logic_vector(0 to ARD_ID_ARRAY'LENGTH-1);
signal ip2bus_data              : std_logic_vector(0 to C_OPB_DWIDTH - 1);
signal ip2bus_intrevent         : std_logic_vector(0 to IP_INTR_MODE_ARRAY'length-1);

signal bus2ip_addr              : std_logic_vector(0 to C_OPB_AWIDTH - 1);
signal bus2ip_addrvalid         : std_logic;
signal bus2ip_data              : std_logic_vector(0 to C_OPB_DWIDTH - 1);
signal bus2ip_rnw               : std_logic;
signal bus2ip_rdreq             : std_logic;
signal bus2ip_wrreq             : std_logic;
signal bus2ip_cs                : std_logic_vector(0 to ARD_ID_ARRAY'LENGTH-1);
signal bus2ip_ce                : std_logic_vector(0 to calc_num_ce(ARD_NUM_CE_ARRAY)-1);
signal bus2ip_rdce              : std_logic_vector(0 to calc_num_ce(ARD_NUM_CE_ARRAY)-1);
signal bus2ip_wrce              : std_logic_vector(0 to calc_num_ce(ARD_NUM_CE_ARRAY)-1);
signal bus2ip_be                : std_logic_vector(0 to (C_OPB_DWIDTH / 8) - 1);
signal bus2ip_burst             : std_logic;
signal bus2ip_clk               : std_logic;
signal bus2ip_reset             : std_logic;


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

begin -- architecture IMP

  OPB_IPIF_I : entity opb_ipif_v3_01_a.opb_ipif
    generic map
    (
      C_ARD_ID_ARRAY              => ARD_ID_ARRAY,
      C_ARD_ADDR_RANGE_ARRAY      => ARD_ADDR_RANGE_ARRAY,
      C_ARD_DWIDTH_ARRAY          => ARD_DWIDTH_ARRAY,
      C_ARD_NUM_CE_ARRAY          => ARD_NUM_CE_ARRAY,
      
      C_ARD_DEPENDENT_PROPS_ARRAY => ARD_DEPENDENT_PROPS_ARRAY,
      C_PIPELINE_MODEL            => PIPELINE_MODEL,
      
      C_DEV_BLK_ID                => DEV_BLK_ID,
      C_DEV_MIR_ENABLE            => DEV_MIR_ENABLE,
      
      C_OPB_AWIDTH                => C_OPB_AWIDTH,
      C_OPB_DWIDTH                => C_OPB_DWIDTH,
      C_FAMILY                    => C_FAMILY,
      C_IP_INTR_MODE_ARRAY        => IP_INTR_MODE_ARRAY,
      
      C_DEV_BURST_ENABLE          => INCLUDE_BURST_SUPPORT,
      C_INCLUDE_ADDR_CNTR         => INCLUDE_ADDR_CNTR,
      C_INCLUDE_WR_BUF            => INCLUDE_WR_BUF   
    )
    port map
    (
      OPB_select           => OPB_select,
      OPB_DBus             => OPB_DBus,
      OPB_ABus             => OPB_ABus,
      OPB_BE               => OPB_BE,
      OPB_RNW              => OPB_RNW,
      OPB_seqAddr          => OPB_seqAddr,
      Sln_DBus             => Sln_DBus,
      Sln_xferAck          => Sln_xferAck,
      Sln_errAck           => Sln_errAck,
      Sln_retry            => Sln_retry,
      Sln_toutSup          => Sln_toutSup,
      
      Bus2IP_CS            => bus2ip_cs,
      --Bus2IP_CE            => bus2ip_ce,
      Bus2IP_CE            => open,
      Bus2IP_RdCE          => bus2ip_rdce,
      Bus2IP_WrCE          => bus2ip_wrce,
      Bus2IP_Data          => bus2ip_data,
      Bus2IP_Addr          => bus2ip_addr,
      Bus2IP_AddrValid     => bus2ip_addrvalid,
      Bus2IP_BE            => bus2ip_be,
      Bus2IP_RNW           => bus2ip_rnw,
      Bus2IP_Burst         => bus2ip_burst,
      
      IP2Bus_Data          => ip2bus_data,      
      IP2Bus_Ack           => ip2bus_ack,
      IP2Bus_AddrAck       => ip2bus_addrack,      
      IP2Bus_Error         => ip2bus_errack,
      IP2Bus_Retry         => ip2bus_retry,
      IP2Bus_ToutSup       => ip2bus_toutsup,
      
      IP2Bus_PostedWrInh   => ip2bus_postedwrinh,
      
      IP2RFIFO_Data        => ZERO_DATA,
      IP2RFIFO_WrMark      => '0',
      IP2RFIFO_WrRelease   => '0',
      IP2RFIFO_WrReq       => '0',
      IP2RFIFO_WrRestore   => '0',
      RFIFO2IP_AlmostFull  => open,
      RFIFO2IP_Full        => open,
      RFIFO2IP_Vacancy     => open,
      RFIFO2IP_WrAck       => open,
      IP2WFIFO_RdMark      => '0',
      IP2WFIFO_RdRelease   => '0',
      IP2WFIFO_RdReq       => '0',
      IP2WFIFO_RdRestore   => '0',
      WFIFO2IP_AlmostEmpty => open,
      WFIFO2IP_Data        => open,
      WFIFO2IP_Empty       => open,
      WFIFO2IP_Occupancy   => open,
      WFIFO2IP_RdAck       => open,
      
      IP2Bus_IntrEvent     => ip2bus_intrevent,
      IP2INTC_Irpt         => IP2INTC_Irpt,
      
      Freeze               => '0',
      Bus2IP_Freeze        => open,
      
      OPB_Clk              => OPB_Clk,
      Bus2IP_Clk           => Bus2IP_Clk,
      IP2Bus_Clk           => '0',
      Reset                => OPB_Rst,
      Bus2IP_Reset         => Bus2IP_Reset
    );

  gpio_core_1 : entity opb_gpio_v3_01_b.gpio_core
    generic map (
    C_DW                => C_OPB_DWIDTH,
    C_AW                => C_OPB_AWIDTH,
    C_GPIO_WIDTH        => C_GPIO_WIDTH,
    C_ALL_INPUTS        => C_ALL_INPUTS /= 0,
    C_INTERRUPT_PRESENT => C_INTERRUPT_PRESENT /= 0,
    C_IS_BIDIR          => C_IS_BIDIR /= 0,
    C_DOUT_DEFAULT      => C_DOUT_DEFAULT,
    C_TRI_DEFAULT       => C_TRI_DEFAULT,
    C_IS_DUAL           => C_IS_DUAL /= 0,
    C_ALL_INPUTS_2      => C_ALL_INPUTS_2 /= 0,
    C_IS_BIDIR_2        => C_IS_BIDIR_2 /= 0,
    C_DOUT_DEFAULT_2    => C_DOUT_DEFAULT_2,
    C_TRI_DEFAULT_2     => C_TRI_DEFAULT_2)
    
port map (
    Clk          => Bus2IP_Clk,
    Rst          => Bus2IP_Reset,
    ABus_Reg     => Bus2IP_Addr,
    BE_Reg       => Bus2IP_BE(0 to C_OPB_DWIDTH/8-1),
    DBus_Reg     => Bus2IP_Data_i(0 to C_GPIO_WIDTH-1),
    RNW_Reg      => Bus2IP_RNW, 
    select_Reg   => '1',
    seqAddr_Reg  => '1',
    GPIO_DBus        => IP2Bus_Data(0 to C_OPB_DWIDTH-1),
    GPIO_errAck      => open,
    GPIO_retry       => open,
    GPIO_toutSup     => open,
    GPIO_xferAck     => GPIO_xferAck_i,
    GPIO_Select      => bus2ip_cs(0),
    GPIO_intr        => ip2bus_intrevent(0),
    GPIO2_intr       => ip2bus_intrevent(1),
    GPIO_IO_I        => GPIO_IO_I,
    GPIO_IO_O        => GPIO_IO_O,
    GPIO_IO_T        => GPIO_IO_T,
    GPIO_in          => GPIO_in,
    GPIO_d_out       => GPIO_d_out,
    GPIO_t_out       => GPIO_t_out,
    GPIO2_IO_I       => GPIO2_IO_I,
    GPIO2_IO_O       => GPIO2_IO_O,
    GPIO2_IO_T       => GPIO2_IO_T,
    GPIO2_in         => GPIO2_in,
    GPIO2_d_out      => GPIO2_d_out,
    GPIO2_t_out      => GPIO2_t_out);

 
IP2Bus_Ack         <= GPIO_xferAck_i ; 
IP2Bus_AddrAck     <= '0'; 
IP2Bus_Retry       <= '0'; -- no retry
IP2Bus_ErrAck      <= '0'; -- no error
IP2Bus_ToutSup     <= '0'; 

IP2Bus_PostedWrInh <= POSTED_ZEROS ; -- do not inhibit posted write

-- IP2Bus_PostedWrInh <= '0'; -- do not inhibit posted write
--   IP2Bus_PostedWrInh <= '0' when C_INCLUDE_BURST_SUPPORT=1 else '1'; 

BUS_CONV : for i in 0 to C_GPIO_WIDTH-1 generate
Bus2IP_Data_i(i) <= Bus2IP_Data(i+C_OPB_DWIDTH-C_GPIO_WIDTH);
end generate BUS_CONV;

end architecture imp;
-------------------------------------------------------------------------------
--               End of file opb_gpio.vhd                                   --
-------------------------------------------------------------------------------

