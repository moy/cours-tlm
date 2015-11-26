-------------------------------------------------------------------------------
-- $Id: opb_emc.vhd,v 1.4 2005/05/03 17:08:59 gburch Exp $
-------------------------------------------------------------------------------
-- opb_emc.vhd - Entity
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
-- Filename:        opb_emc.vhd
-- Version:         v2.00.a
-- Description:     This is the top-level design file for the OPB External
--                  Memory Controller. 
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--
--              opb_emc.vhd
--                  -- opb_ipif.vhd
--                  -- emc.vhd
--                      -- addr_counter_mux.vhd
--                      -- counters.vhd
--                      -- io_registers.vhd
--                      -- ipic_if.vhd
--                      -- mem_state_machine.vhd
--                  -- mem_steer.vhd
--                      -- select_param.vhd
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_Gmm_SP2 
--  
--  This New version, opb_emc_v2_00_a, supports OPB sequential address 
--  transactions with a burst response.
--
--  The following Parameters have been modified:
--  C_INCLUDE_BURST can now be set to 0 or 1. This version supports
--  sequential address transactions in a burst-like manner. Default value
--  is now 0.
--
--  Fixed problem with memory state machine missing single beat cycles while
--  waiting for read or write recovery.
--
-- @END_CHANGELOG 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_H_SP1
--
-- Fixed problem with ZERO_DATA constant being of the wrong width when
-- C_INCLUDE_DATAWIDTH_MATCHING_0 = 0 and the memory device width was
-- defined as something other than 32-bits wide.
--
-- @END_CHANGELOG 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_H_SP2
--
-- Fixed issue with Mem_DQ_T registers not being packed into the IOB's
--
-- @END_CHANGELOG 
-------------------------------------------------------------------------------
-- Author:      Pankaj
-- History:
--
-- Pankaj      07-05-2004      -- Version 2.00.a
-- ^^^^^^
--  Modification involves integeration of opb_ipif_v3_01_a 
--  and emc_common_v2_00_a to form a top level called opb_emc_v2_00_a.
--  --  Removed following generic parameters
--  1> C_BASEADDR               
--  2> C_HIGHADDR            
--  Added following generic parameter
--  1> C_INCLUDE_BURST
--  
-- ~~~~~~
-- GAB      02-03-2005
-- ^^^^^^
-- Fixed ZERO_DATA constant width.  It was being set to C_OPB_DWIDTH and then
-- used to drive '0' to IP2RFifo_Data which has a width defined by the 
-- ARD_DWIDTH_ARRAY_IN(), which for OPB_EMC is defined as the memory device
-- width.  If the memory width is not 32 then an error will occur during build.
-- ZERO_DATA width was changed to be set by ARD_DWIDTH_ARRAY_IN.  This fixes
-- CR202860.
-- ~~~~~~
-- GAB      05-03-2005
-- ^^^^^^
--  Added attributes to force ISE to not optimize Mem_DQ_T signals down to
--  a single signal.  Also uncommented 'Rst' portion in io_registers.vhd of 
--  'if' clause on outputs to allow 3-state controls, output bus, and input
--  bus to all be registered in the IOB.  This fixes CR204317.
-- ~~~~~~
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
--
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

library Unisim;
use Unisim.all;

library proc_common_v2_00_a;
use proc_common_v2_00_a.proc_common_pkg.all;
use proc_common_v2_00_a.family.all;
use proc_common_v2_00_a.all;

use proc_common_v2_00_a.ipif_pkg.INTEGER_ARRAY_TYPE;
use proc_common_v2_00_a.ipif_pkg.SLV64_ARRAY_TYPE;
use proc_common_v2_00_a.ipif_pkg.IPIF_RST;
use proc_common_v2_00_a.ipif_pkg.IPIF_INTR;
use proc_common_v2_00_a.ipif_pkg.IPIF_WRFIFO_DATA;
use proc_common_v2_00_a.ipif_pkg.IPIF_WRFIFO_REG;
use proc_common_v2_00_a.ipif_pkg.IPIF_RDFIFO_DATA;
use proc_common_v2_00_a.ipif_pkg.IPIF_RDFIFO_REG;
use proc_common_v2_00_a.ipif_pkg.USER_00;
use proc_common_v2_00_a.ipif_pkg.DEPENDENT_PROPS_ARRAY_TYPE;
use proc_common_v2_00_a.ipif_pkg.calc_num_ce;
use proc_common_v2_00_a.ipif_pkg.find_ard_id;
use proc_common_v2_00_a.ipif_pkg.bits_needed_for_vac;
use proc_common_v2_00_a.ipif_pkg.bits_needed_for_occ;
use proc_common_v2_00_a.ipif_pkg.get_id_index;
use proc_common_v2_00_a.ipif_pkg.calc_start_ce_index;
use proc_common_v2_00_a.ipif_pkg.get_id_index_iboe;

library opb_ipif_v3_01_a;
use opb_ipif_v3_01_a.opb_ipif;

library emc_common_v2_00_a;
use emc_common_v2_00_a.emc;

-------------------------------------------------------------------------------
-- Definition of Generics:
--  C_NUM_BANKS_MEM                 --  Number of memory banks
--  C_INCLUDE_BURST                 --  Include logic for burst transactions    
--  C_INCLUDE_NEGEDGE_IOREGS        --  include negative edge IO registers
--  C_MEM(0:3)_BASEADDR             --  Memory bank (0:3) base address
--  C_MEM(0:3)_HIGHADDR             --  Memory bank (0:3) high address
--  C_MEM(0:3)_WIDTH                --  Memory bank (0:3) data width
--  C_MAX_MEM_WIDTH                 --  Maximum data width of all memory banks
--  C_INCLUDE_DATAWIDTH_MATCHING_(0:3)  -- Support data width matching for
--                                         memory bank (0:3) 
--  C_SYNCH_MEM_(0:3)               -- Memory bank (0:3) type
--  C_SYNCH_PIPEDELAY_(0:3)         -- Memory bank (0:3) synchronous pipe delay
--  
--  C_TCEDV_PS_MEM_(0:3)            -- Chip Enable to Data Valid Time
--                                  -- (Maximum of TCEDV and TAVDV applied
--                                     as read cycle start to first data valid)
--  C_TAVDV_PS_MEM_(0:3)            -- Address Valid to Data Valid Time
--                                  -- (Maximum of TCEDV and TAVDV applied
--                                     as read cycle start to first data valid)
--  C_THZCE_PS_MEM_(0:3)            -- Chip Enable High to Data Bus High Impedance
--                                     (Maximum of THZCE and THZOE applied as
--                                     Read Recovery before Write)
--  C_THZOE_PS_MEM_(0:3)            -- Output Enable High to Data Bus High Impedance
--                                     (Maximum of THZCE and THZOE applied as
--                                     Read Recovery before Write)
--  C_TWC_PS_MEM_(0:3)              -- Write Cycle Time
--                                     (Maximum of TWC and TWP applied as write
--                                     enable pulse width)
--  C_TWP_PS_MEM_(0:3)              -- Write Enable Minimum Pulse Width
--                                     (Maximum of TWC and TWP applied as write
--                                     enable pulse width)
--  C_TLZWE_PS_MEM_(0:3)            -- Write Enable High to Data Bus Low Impedance
--                                     (Applied as Write Recovery before Read)
--  C_OPB_DWIDTH                    -- OPB Data Bus Width
--  C_OPB_AWIDTH                    -- OPB Address Width
--  C_OPB_CLK_PERIOD_PS             -- OPB clock period to calculate wait
--                                     state pulse widths.
-- 
-- Definition of Ports:
-- OPB Interface
--  OPB_Clk                         -- OPB clock                                               
--  OPB_Rst                         -- OPB Reset                                               
--  OPB_ABus                        -- OPB address bus                                             
--  OPB_DBus                        -- OPB data bus                                                   
--  OPB_select                      -- OPB select                                    
--  OPB_RNW                         -- OPB read not write                                           
--  OPB_seqAddr                     -- OPB sequential address                              
--  OPB_BE                          -- OPB byte enables                                              
--  Sln_DBus                        -- Slave read bus                                         
--  Sln_xferAck                     -- Slave transfer acknowledge                            
--  Sln_errAck                      -- Slave error acknowledge
--  Sln_toutSup                     -- Slave timeout suppress
--  Sln_retry                       -- Slave retry
--
-- Memory Signals
--  Mem_A                           -- Memory address inputs
--  Mem_DQ_I                        -- Memory Input Data Bus
--  Mem_DQ_O                        -- Memory Output Data Bus
--  Mem_DQ_T                        -- Memory Data Output Enable
--  Mem_CEN                         -- Memory Chip Select
--  Mem_OEN                         -- Memory Output Enable
--  Mem_WEN                         -- Memory Write Enable
--  Mem_QWEN                        -- Memory Qualified Write Enable
--  Mem_BEN                         -- Memory Byte Enables
--  Mem_RPN                         -- Memory Reset/Power Down
--  Mem_CE                          -- Memory chip enable
--  Mem_ADV_LDN                     -- Memory counter advance/load (=0)
--  Mem_LBON                        -- Memory linear/interleaved burst order (=0)
--  Mem_CKEN                        -- Memory clock enable (=0)
--  Mem_RNW                         -- Memory read not write
-------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------
entity opb_emc is
   -- Generics to be set by user
  generic (
    C_NUM_BANKS_MEM                   : integer := 2;
    C_INCLUDE_BURST                   : integer := 0;  
    C_INCLUDE_NEGEDGE_IOREGS          : integer := 0;
    C_FAMILY                          : string  := "virtex2";
    C_MEM0_BASEADDR                   : std_logic_vector := X"FFFF_FFFF";
    C_MEM0_HIGHADDR                   : std_logic_vector := X"0000_0000";
    C_MEM1_BASEADDR                   : std_logic_vector := X"FFFF_FFFF";
    C_MEM1_HIGHADDR                   : std_logic_vector := X"0000_0000";
    C_MEM2_BASEADDR                   : std_logic_vector := X"FFFF_FFFF";
    C_MEM2_HIGHADDR                   : std_logic_vector := X"0000_0000";
    C_MEM3_BASEADDR                   : std_logic_vector := X"FFFF_FFFF";
    C_MEM3_HIGHADDR                   : std_logic_vector := X"0000_0000";
    
    
    C_MEM0_WIDTH                      : integer := 32;
    C_MEM1_WIDTH                      : integer := 32;
    C_MEM2_WIDTH                      : integer := 32;
    C_MEM3_WIDTH                      : integer := 32;
    
    C_MAX_MEM_WIDTH                   : integer := 32;
    
    C_INCLUDE_DATAWIDTH_MATCHING_0    : integer := 1; 
    C_INCLUDE_DATAWIDTH_MATCHING_1    : integer := 1; 
    C_INCLUDE_DATAWIDTH_MATCHING_2    : integer := 1; 
    C_INCLUDE_DATAWIDTH_MATCHING_3    : integer := 1; 
    

    -- Memory read and write access times for all memory banks

    C_SYNCH_MEM_0                     : integer := 0;
    C_SYNCH_PIPEDELAY_0               : integer := 2;
    C_TCEDV_PS_MEM_0                  : integer := 15000;
    C_TAVDV_PS_MEM_0                  : integer := 15000;
    C_THZCE_PS_MEM_0                  : integer := 7000;
    C_THZOE_PS_MEM_0                  : integer := 7000;
    C_TWC_PS_MEM_0                    : integer := 15000;
    C_TWP_PS_MEM_0                    : integer := 12000;
    C_TLZWE_PS_MEM_0                  : integer := 0;  

    C_SYNCH_MEM_1                     : integer := 0;
    C_SYNCH_PIPEDELAY_1               : integer := 2;
    C_TCEDV_PS_MEM_1                  : integer := 15000;
    C_TAVDV_PS_MEM_1                  : integer := 15000;
    C_THZCE_PS_MEM_1                  : integer := 7000;
    C_THZOE_PS_MEM_1                  : integer := 7000;
    C_TWC_PS_MEM_1                    : integer := 15000;
    C_TWP_PS_MEM_1                    : integer := 12000;
    C_TLZWE_PS_MEM_1                  : integer := 0;  

    C_SYNCH_MEM_2                     : integer := 0;
    C_SYNCH_PIPEDELAY_2               : integer := 2;
    C_TCEDV_PS_MEM_2                  : integer := 15000;
    C_TAVDV_PS_MEM_2                  : integer := 15000;
    C_THZCE_PS_MEM_2                  : integer := 7000;
    C_THZOE_PS_MEM_2                  : integer := 7000;
    C_TWC_PS_MEM_2                    : integer := 15000;
    C_TWP_PS_MEM_2                    : integer := 12000;
    C_TLZWE_PS_MEM_2                  : integer := 0;  
     
    C_SYNCH_MEM_3                     : integer := 0;
    C_SYNCH_PIPEDELAY_3               : integer := 2;
    C_TCEDV_PS_MEM_3                  : integer := 15000;
    C_TAVDV_PS_MEM_3                  : integer := 15000;
    C_THZCE_PS_MEM_3                  : integer := 7000;
    C_THZOE_PS_MEM_3                  : integer := 7000;
    C_TWC_PS_MEM_3                    : integer := 15000;
    C_TWP_PS_MEM_3                    : integer := 12000;
    C_TLZWE_PS_MEM_3                  : integer := 0;  
    
    --Generics set for IPIF
    C_OPB_DWIDTH                      : integer := 32;
    C_OPB_AWIDTH                      : integer := 32;
    C_OPB_CLK_PERIOD_PS               : integer := 10000
    
        );


  port
      (
       -- System Port Declarations ********************************************

        OPB_Clk               : in    std_logic;
        OPB_Rst               : in    std_logic;

       -- OPB Port Declarations ***********************************************
        OPB_ABus              : in    std_logic_vector(0 to C_OPB_AWIDTH - 1 );
        OPB_DBus              : in    std_logic_vector(0 to C_OPB_DWIDTH - 1 );
        Sln_DBus              : out   std_logic_vector(0 to C_OPB_DWIDTH - 1 );
        OPB_select            : in    std_logic := '0';
        OPB_RNW               : in    std_logic := '0';
        OPB_seqAddr           : in    std_logic := '0';
        OPB_BE                : in    std_logic_vector(0 to C_OPB_DWIDTH/8 - 1 );
        Sln_xferAck           : out   std_logic;
        Sln_errAck            : out   std_logic;
        Sln_toutSup           : out   std_logic;
        Sln_retry             : out   std_logic;


       -- Memory signals 

        Mem_A                 : out   std_logic_vector(0 to C_OPB_AWIDTH-1);
        Mem_DQ_I              : in    std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
        Mem_DQ_O              : out   std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
        Mem_DQ_T              : out   std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
        Mem_CEN               : out   std_logic_vector(0 to C_NUM_BANKS_MEM-1);
        Mem_OEN               : out   std_logic_vector(0 to C_NUM_BANKS_MEM-1);
        Mem_WEN               : out   std_logic;
        Mem_QWEN              : out   std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1); --Qualified WE
        Mem_BEN               : out   std_logic_vector(0 to C_MAX_MEM_WIDTH/8-1);
        Mem_RPN               : out   std_logic;
        Mem_CE                : out   std_logic_vector(0 to C_NUM_BANKS_MEM-1);
        Mem_ADV_LDN           : out   std_logic;
        Mem_LBON              : out   std_logic;
        Mem_CKEN              : out   std_logic;
        Mem_RNW               : out   std_logic
      );
      
 --fan-out attributes for synplicity    
  attribute syn_maxfan                                : integer;
  attribute syn_maxfan   of OPB_Clk                   : signal is 10000;
  attribute syn_maxfan   of OPB_Rst                   : signal is 10000;
 

 --fan-out attributes for XST
  attribute MAX_FANOUT                                : string;
  attribute MAX_FANOUT   of OPB_Clk                   : signal is "10000";
  attribute MAX_FANOUT   of OPB_Rst                   : signal is "10000";
  
  -----------------------------------------------------------------
  -- Start of PSFUtil MPD attributes              
  -----------------------------------------------------------------
  
  attribute MIN_SIZE                                  : string;
  attribute MIN_SIZE of C_MEM0_BASEADDR               : constant is "0x08";
  attribute MIN_SIZE of C_MEM1_BASEADDR               : constant is "0x08";
  attribute MIN_SIZE of C_MEM2_BASEADDR               : constant is "0x08";
  attribute MIN_SIZE of C_MEM3_BASEADDR               : constant is "0x08";
  
  
  attribute ASSIGNMENT                                : string;
  attribute ASSIGNMENT of C_MEM0_BASEADDR             : constant is "REQUIRE";
  attribute ASSIGNMENT of C_MEM0_HIGHADDR             : constant is "REQUIRE";
  attribute ASSIGNMENT of C_OPB_DWIDTH                : constant is "CONSTANT"; 
  attribute ASSIGNMENT of C_OPB_AWIDTH                : constant is "CONSTANT";
  
  attribute ADDR_TYPE                                 : string;
  attribute ADDR_TYPE of C_MEM0_BASEADDR              : constant is "MEMORY";
  attribute ADDR_TYPE of C_MEM0_HIGHADDR              : constant is "MEMORY";
  attribute ADDR_TYPE of C_MEM1_BASEADDR              : constant is "MEMORY";
  attribute ADDR_TYPE of C_MEM1_HIGHADDR              : constant is "MEMORY";
  attribute ADDR_TYPE of C_MEM2_BASEADDR              : constant is "MEMORY";
  attribute ADDR_TYPE of C_MEM2_HIGHADDR              : constant is "MEMORY";
  attribute ADDR_TYPE of C_MEM3_BASEADDR              : constant is "MEMORY";
  attribute ADDR_TYPE of C_MEM3_HIGHADDR              : constant is "MEMORY";

  attribute XRANGE                                    : string;
  attribute XRANGE of C_NUM_BANKS_MEM                 : constant is "(1:4)";
  attribute XRANGE of C_INCLUDE_NEGEDGE_IOREGS        : constant is "(0:1)";
  attribute XRANGE of C_INCLUDE_BURST                 : constant is "(0:1)";

  attribute XRANGE of C_MEM0_WIDTH                    : constant is "(8,16,32)";
  attribute XRANGE of C_MEM1_WIDTH                    : constant is "(8,16,32)";
  attribute XRANGE of C_MEM2_WIDTH                    : constant is "(8,16,32)";
  attribute XRANGE of C_MEM3_WIDTH                    : constant is "(8,16,32)";
  attribute XRANGE of C_MAX_MEM_WIDTH                 : constant is "(8,16,32)";

  attribute XRANGE of C_INCLUDE_DATAWIDTH_MATCHING_0  : constant is "(0:1)";
  attribute XRANGE of C_INCLUDE_DATAWIDTH_MATCHING_1  : constant is "(0:1)";
  attribute XRANGE of C_INCLUDE_DATAWIDTH_MATCHING_2  : constant is "(0:1)";
  attribute XRANGE of C_INCLUDE_DATAWIDTH_MATCHING_3  : constant is "(0:1)";

  attribute XRANGE of C_SYNCH_MEM_0                   : constant is "(0:1)";
  attribute XRANGE of C_SYNCH_MEM_1                   : constant is "(0:1)";
  attribute XRANGE of C_SYNCH_MEM_2                   : constant is "(0:1)";
  attribute XRANGE of C_SYNCH_MEM_3                   : constant is "(0:1)";

  attribute XRANGE of C_SYNCH_PIPEDELAY_0             : constant is "(1:2)";
  attribute XRANGE of C_SYNCH_PIPEDELAY_1             : constant is "(1:2)";
  attribute XRANGE of C_SYNCH_PIPEDELAY_2             : constant is "(1:2)";
  attribute XRANGE of C_SYNCH_PIPEDELAY_3             : constant is "(1:2)";
  
  attribute SIGIS                                     : string;
  attribute SIGIS of OPB_Clk                          : signal is "Clk";
  attribute SIGIS of OPB_Rst                          : signal is "Rst";
  -----------------------------------------------------------------
  -- end of PSFUtil MPD attributes              
  ----------------------------------------------------------------- 
  
  attribute equivalent_register_removal               : string;
  attribute equivalent_register_removal of Mem_DQ_T   : signal is "no";
  
  attribute iob                                       : string;
  attribute iob of Mem_DQ_T                           : signal is "true";
  attribute iob of Mem_DQ_I                           : signal is "true";
  attribute iob of Mem_DQ_O                           : signal is "true";
  

end opb_emc;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of opb_emc is

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
-- Function get_effective_mem_width sets the memory width to the bus width if
-- datawidth matching is included for that memory bank
function get_effective_mem_width(include_data_matching  : integer range 0 to 1;
                                 mem_width              : integer range 1 to 32;
                                 bus_width              : integer range 1 to 32)
                                 return integer is
    variable effective_mem_width : integer range 1 to 32;
begin
    if include_data_matching = 1 then
        effective_mem_width := bus_width;
    else
        effective_mem_width := mem_width;
    end if;
    return effective_mem_width;
end function get_effective_mem_width;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant C_PIPELINE_MODEL    :  integer := 5;
constant OPB_DWIDTH          :  integer := C_OPB_DWIDTH;
constant OPB_AWIDTH          :  integer := C_OPB_AWIDTH;
constant IPIF_AWIDTH         :  integer := C_OPB_AWIDTH;
constant IPIF_DWIDTH         :  integer := C_OPB_DWIDTH;
constant INCLUDE_BURST       :  integer := C_INCLUDE_BURST;


-------------------------------------------------------------------------------
-- Necessary for SLV64_ARRAY_TYPE (64 bits wide) and everything else 32-bit
-------------------------------------------------------------------------------
constant ZEROES              :  std_logic_vector := X"00000000";
 
 
-------------------------------------------------------------------------------
-- Constants necessary for IPIF arrays
-------------------------------------------------------------------------------
       
constant MEM0                : integer := 121;
constant MEM1                : integer := 122;
constant MEM2                : integer := 123;
constant MEM3                : integer := 124;
       

-------------------------------------------------------------------------------
-- Create constant arrays for IPIF
-- Note that functions are used to correctly populate array entries
-------------------------------------------------------------------------------
constant ARD_ID_ARRAY_IN : INTEGER_ARRAY_TYPE :=
        (
         MEM0,     -- Memory Bank 0
         MEM1,     -- Memory Bank 1
         MEM2,     -- Memory Bank 2
         MEM3      -- Memory Bank 3
        );

constant ARD_ADDR_RANGE_ARRAY_IN  : SLV64_ARRAY_TYPE :=
       (
        ZEROES & C_MEM0_BASEADDR,    -- Memory Bank 0     := X"3000_0000"
        ZEROES & C_MEM0_HIGHADDR,    -- Memory Bank 0     := X"3FFF_FFFF"
        ZEROES & C_MEM1_BASEADDR,    -- Memory Bank 1     := X"4000_0000"
        ZEROES & C_MEM1_HIGHADDR,    -- Memory Bank 1     := X"4FFF_FFFF"
        ZEROES & C_MEM2_BASEADDR,    -- Memory Bank 2     := X"5000_0000"
        ZEROES & C_MEM2_HIGHADDR,    -- Memory Bank 2     := X"5FFF_FFFF"
        ZEROES & C_MEM3_BASEADDR,    -- Memory Bank 3     := X"6000_0000"
        ZEROES & C_MEM3_HIGHADDR     -- Memory Bank 3     := X"6FFF_FFFF"
        );

constant ARD_DWIDTH_ARRAY_IN      : INTEGER_ARRAY_TYPE :=
       (
        get_effective_mem_width(C_INCLUDE_DATAWIDTH_MATCHING_0, C_MEM0_WIDTH, C_OPB_DWIDTH),
        get_effective_mem_width(C_INCLUDE_DATAWIDTH_MATCHING_1, C_MEM1_WIDTH, C_OPB_DWIDTH),
        get_effective_mem_width(C_INCLUDE_DATAWIDTH_MATCHING_2, C_MEM2_WIDTH, C_OPB_DWIDTH),
        get_effective_mem_width(C_INCLUDE_DATAWIDTH_MATCHING_3, C_MEM3_WIDTH, C_OPB_DWIDTH)
        
       );

constant ARD_NUM_CE_ARRAY_IN   : INTEGER_ARRAY_TYPE :=
        (
         1,     -- Memory Bank 0 CE number
         1,     -- Memory Bank 1 CE number
         1,     -- Memory Bank 2 CE number
         1      -- Memory Bank 3 CE number
         );

-- functions to correctly populate the arrays
function Get_ARD_ADDR_RANGE_ARRAY return SLV64_ARRAY_TYPE is
  variable ARD_ADDR_RANGE_ARRAY_V : SLV64_ARRAY_TYPE(0 to 7);  
begin
  
  for i in 0 to C_NUM_BANKS_MEM*2-1  loop
      ARD_ADDR_RANGE_ARRAY_V(i)   := ARD_ADDR_RANGE_ARRAY_IN(i);
  end loop;
  
  if C_NUM_BANKS_MEM < 4 then
    for i in C_NUM_BANKS_MEM to 3 loop
        ARD_ADDR_RANGE_ARRAY_V((i-1)*2+2) := ARD_ADDR_RANGE_ARRAY_IN((C_NUM_BANKS_MEM-1)*2);
        ARD_ADDR_RANGE_ARRAY_V((i-1)*2+3) := ARD_ADDR_RANGE_ARRAY_IN((C_NUM_BANKS_MEM-1)*2+1);
    end loop;
  end if;
  
  return ARD_ADDR_RANGE_ARRAY_V;
end function Get_ARD_ADDR_RANGE_ARRAY;

-------------------------------------------------------------------------------
-- Get_ARD_DWIDTH_ARRAY()
---------------------------------------------------------------------------     
function Get_ARD_DWIDTH_ARRAY return INTEGER_ARRAY_TYPE is
  variable ARD_DWIDTH_ARRAY_V : INTEGER_ARRAY_TYPE(0 to 3);  
  begin
  
         for i in 0 to C_NUM_BANKS_MEM - 1 loop
               ARD_DWIDTH_ARRAY_V(i)  := ARD_DWIDTH_ARRAY_IN(i);
             end loop;
  
          -- Copy dwidth array elements to remaining array slots
        if C_NUM_BANKS_MEM < 4 then
             for i in C_NUM_BANKS_MEM to 3 loop
                ARD_DWIDTH_ARRAY_V(i) := ARD_DWIDTH_ARRAY_IN(C_NUM_BANKS_MEM-1);
             end loop;
        end if;
  return ARD_DWIDTH_ARRAY_V;
end function Get_ARD_DWIDTH_ARRAY;

-------------------------------------------------------------------------------
-- Get_ARD_NUM_CE_ARRAY()
-------------------------------------------------------------------------------
function Get_ARD_NUM_CE_ARRAY return INTEGER_ARRAY_TYPE is
  variable ARD_NUM_CE_ARRAY_V : INTEGER_ARRAY_TYPE(0 to 3); 
  begin
        for i in 0 to C_NUM_BANKS_MEM - 1 loop
               ARD_NUM_CE_ARRAY_V(i) := ARD_NUM_CE_ARRAY_IN(i);
            end loop;

        if C_NUM_BANKS_MEM < 4 then
            for i in C_NUM_BANKS_MEM to 3 loop
               ARD_NUM_CE_ARRAY_V(i) := ARD_NUM_CE_ARRAY_IN(C_NUM_BANKS_MEM-1);
            end loop;
        end if;  
        return ARD_NUM_CE_ARRAY_V;
        
end function Get_ARD_NUM_CE_ARRAY;
---------------------------------------------------------------------------         

-------------------------------------------------------------------------
-- assign the constant arrays the values returned by the functions
-------------------------------------------------------------------------     
constant ARD_ID_ARRAY         : INTEGER_ARRAY_TYPE := ARD_ID_ARRAY_IN;
constant ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE   := Get_ARD_ADDR_RANGE_ARRAY;
constant ARD_DWIDTH_ARRAY     : INTEGER_ARRAY_TYPE := Get_ARD_DWIDTH_ARRAY;
constant ARD_NUM_CE_ARRAY     : INTEGER_ARRAY_TYPE := Get_ARD_NUM_CE_ARRAY;



constant IP_INTR_MODE_ARRAY        : INTEGER_ARRAY_TYPE :=
              (
               0, 
               0 
               );

-- No dependent properties
constant ARD_DEPENDENT_PROPS_ARRAY : DEPENDENT_PROPS_ARRAY_TYPE := 
              (
               0 => (others => 0),
               1 => (others => 0),
               2 => (others => 0)
               );


 -- Burst support generics
 -- need both the address counter and the write burst buffer
constant INCLUDE_ADDR_CNTR   : integer  := C_INCLUDE_BURST;
constant INCLUDE_WR_BUF      : integer  := C_INCLUDE_BURST;


 -- parse Memory bank info
constant MEM0_NAME_INDEX     : integer  := get_id_index(ARD_ID_ARRAY,MEM0);
constant MEM1_NAME_INDEX     : integer  := get_id_index(ARD_ID_ARRAY,MEM1);
constant MEM2_NAME_INDEX     : integer  := get_id_index(ARD_ID_ARRAY,MEM2);
constant MEM3_NAME_INDEX     : integer  := get_id_index(ARD_ID_ARRAY,MEM3);
       

constant OPB_CLK_PERIOD_PS   : integer  := C_OPB_CLK_PERIOD_PS;
--  The period of the OPB Bus clock in ps (10000 = 10ns)


constant CS_BUS_WIDTH        :  integer := ARD_ADDR_RANGE_ARRAY'LENGTH/2;
constant CE_BUS_WIDTH        :  integer := calc_num_ce(ARD_NUM_CE_ARRAY);
constant IP_NUM_INTR         :  integer := IP_INTR_MODE_ARRAY'length;
constant ZERO_INTREVENT      :  std_logic_vector(0 to IP_NUM_INTR-1):= (others => '0');
                                
                                
constant DEV_MIR_ENABLE      :  integer := 0;
constant DEV_BLK_ID          :  integer := 0;  

-- zero constants for unused IPIF inputs

-- Based width of this constant on ARD_DWIDTH_ARRAY for CR202860.
-- The opb_ipif port, IP2RFIFO_Data, is defined with a width based
-- on ARD_DWIDTH_ARRAY.
constant ZERO_DATA           : std_logic_vector(0 to ARD_DWIDTH_ARRAY(
                                get_id_index_iboe(ARD_ID_ARRAY,
                                IPIF_RDFIFO_DATA)) - 1) := (others => '0');

-- 
constant ZERO_AWIDTH         : std_logic_vector(0 to IPIF_AWIDTH - 1)  := (others => '0');
constant ZERO_DWIDTH         : std_logic_vector(0 to IPIF_DWIDTH - 1)  := (others => '0');
constant ZERO_BE             : std_logic_vector(0 to IPIF_DWIDTH/8 - 1):= (others => '0');



--------------------------------------------------------------------------------
-- Chipscope can be optioned in or out by setting this constant.
--------------------------------------------------------------------------------
constant C_INCLUDE_CHIPSCOPE : boolean   := FALSE;

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------

-- IPIC Used Signals

signal ip2bus_rdack             : std_logic;
signal ip2bus_wrack             : std_logic;
signal ip2bus_ack               : std_logic;
signal ip2bus_addrack           : std_logic;
signal ip2bus_toutsup           : std_logic;
signal ip2bus_retry             : std_logic;
signal ip2bus_errack            : std_logic;
signal ip2bus_postedWrInh       : std_logic_vector(0 to ARD_ID_ARRAY'length-1);
signal ip2bus_data              : std_logic_vector(0 to IPIF_DWIDTH - 1);
signal bus2ip_addr              : std_logic_vector(0 to IPIF_AWIDTH - 1);
signal bus2ip_addrvalid         : std_logic;
signal bus2ip_addrvalid_d1      : std_logic;  
signal bus2ip_data              : std_logic_vector(0 to IPIF_DWIDTH - 1);
signal bus2ip_rnw               : std_logic;
signal bus2ip_rdreq             : std_logic;
signal bus2ip_wrreq             : std_logic;
signal bus2ip_cs                : std_logic_vector(0 to ((ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
signal bus2ip_ce                : std_logic_vector(0 to calc_num_ce(ARD_NUM_CE_ARRAY)-1);
signal bus2ip_rdce              : std_logic_vector(0 to calc_num_ce(ARD_NUM_CE_ARRAY)-1);
signal bus2ip_wrce              : std_logic_vector(0 to calc_num_ce(ARD_NUM_CE_ARRAY)-1);
signal bus2ip_be                : std_logic_vector(0 to (IPIF_DWIDTH / 8) - 1);
signal bus2ip_burst             : std_logic;
signal bus2ip_clk               : std_logic;
signal bus2ip_reset             : std_logic;
signal bus2ip_addrvalid_re      : std_logic; 

signal  memcon_cs_bus           : Std_logic_vector(0 to C_NUM_BANKS_MEM-1);
signal  memcon_cs_bus_full      : Std_logic_vector(0 to 3);

signal  Sln_DBus_i              : std_logic_vector(0 to C_OPB_DWIDTH -1);
signal  Sln_xferAck_i           : std_logic;
signal  Sln_errAck_i            : std_logic;
signal  Sln_toutSup_i           : std_logic;

signal  Mem_DQ_O_i              : std_logic_vector(0 to C_MAX_MEM_WIDTH -1);
signal  Mem_DQ_T_i              : std_logic_vector(0 to C_MAX_MEM_WIDTH-1);
signal  Mem_CEN_i               : std_logic_vector(0 to C_NUM_BANKS_MEM -1);
signal  Mem_OEN_i               : std_logic_vector(0 to C_NUM_BANKS_MEM -1);
signal  Mem_WEN_i               : std_logic;
signal  Mem_QWEN_i              : std_logic_vector(0 to C_MAX_MEM_WIDTH/8 -1);
signal  Mem_BEN_i               : std_logic_vector(0 to C_MAX_MEM_WIDTH/8 -1);
signal  Mem_ADV_LDN_i           : std_logic;
signal  Mem_CKEN_i              : std_logic;
signal  Mem_CE_i                : std_logic_vector(0 to C_NUM_BANKS_MEM -1);
signal  Mem_A_i                 : std_logic_vector(0 to C_OPB_AWIDTH -1);



begin -- architecture IMP


Mem_A        <=  Mem_A_i    ;
Mem_DQ_O     <=  Mem_DQ_O_i ;
Mem_DQ_T     <=  Mem_DQ_T_i ;
Mem_CEN      <=  Mem_CEN_i  ;
Mem_OEN      <=  Mem_OEN_i  ;
Mem_WEN      <=  Mem_WEN_i  ;
Mem_QWEN     <=  Mem_QWEN_i ;
Mem_BEN      <=  Mem_BEN_i  ;
Mem_CE       <=  Mem_CE_i   ;
Mem_ADV_LDN  <=  Mem_ADV_LDN_i;
Mem_CKEN     <=  Mem_CKEN_i  ;


-- now build the intermediate memory CS bus of all possible memory chip selects
 memcon_cs_bus_full(0) <= bus2ip_cs(MEM0_NAME_INDEX);
 memcon_cs_bus_full(1) <= bus2ip_cs(MEM1_NAME_INDEX);
 memcon_cs_bus_full(2) <= bus2ip_cs(MEM2_NAME_INDEX);
 memcon_cs_bus_full(3) <= bus2ip_cs(MEM3_NAME_INDEX);
 

-- now populate the size restricted MEM_CON CS bus
COLLECT_MEM_CS : process (memcon_cs_bus_full)
  begin
    for cs_index in 0 to C_NUM_BANKS_MEM-1 loop
        memcon_cs_bus(cs_index) <=  memcon_cs_bus_full(cs_index);
    end loop;
end process COLLECT_MEM_CS;



-- Detect rising edge of bus2ip_addrvalid
RE_DET: process (OPB_Clk)
begin
    if OPB_Clk'event and OPB_Clk='1' then
        if OPB_Rst = RESET_ACTIVE then
            bus2ip_addrvalid_d1 <= '0';
        else
            bus2ip_addrvalid_d1 <= bus2ip_addrvalid;
        end if;
    end if;
end process RE_DET;


-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------

OPB_IPIF_I: entity opb_ipif_v3_01_a.opb_ipif
  generic map(
     -- Generics to be set for ipif
    C_ARD_ID_ARRAY              => ARD_ID_ARRAY,
    C_ARD_ADDR_RANGE_ARRAY      => ARD_ADDR_RANGE_ARRAY,
    C_ARD_DWIDTH_ARRAY          => ARD_DWIDTH_ARRAY,
    C_ARD_NUM_CE_ARRAY          => ARD_NUM_CE_ARRAY,

    C_ARD_DEPENDENT_PROPS_ARRAY => ARD_DEPENDENT_PROPS_ARRAY,
    C_PIPELINE_MODEL            => C_PIPELINE_MODEL,

    C_DEV_BLK_ID                => DEV_BLK_ID,
    C_DEV_MIR_ENABLE            => DEV_MIR_ENABLE,

    C_OPB_AWIDTH                => C_OPB_AWIDTH,
    C_OPB_DWIDTH                => C_OPB_DWIDTH,
    C_FAMILY                    => C_FAMILY,
    C_IP_INTR_MODE_ARRAY        => IP_INTR_MODE_ARRAY,

    C_DEV_BURST_ENABLE          => C_INCLUDE_BURST,
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
          Bus2IP_CE            => bus2ip_ce,
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
          
          IP2Bus_IntrEvent     => ZERO_INTREVENT,
          IP2INTC_Irpt         => open,
          
          Freeze               => '0',
          Bus2IP_Freeze        => open,
          
          OPB_Clk              => OPB_Clk,
          Bus2IP_Clk           => bus2ip_clk,
          IP2Bus_Clk           => '0',
          Reset                => OPB_Rst,
          Bus2IP_Reset         => bus2ip_reset
    );
    
    
    
    
 -------------------------------------------------------------------------------
 -- Miscellaneous assignments to match EMC controller to IPIC
 -------------------------------------------------------------------------------
  
 -- Detect rising edge of Bus2IP_AddrValid
  bus2ip_addrvalid_re <= '1' when ((bus2ip_addrvalid = '1') and (bus2ip_addrvalid_d1 = '0')) else '0';
                  
 -- Use Bus2IP_Burst to determine use of Bus2IP_AddrValid to generate RdReq and WrReq                
  
  bus2ip_rdreq        <= or_reduce(bus2ip_rdce(0 to C_NUM_BANKS_MEM-1)) 
                            and ((bus2ip_addrvalid and bus2ip_burst) or
                            (bus2ip_addrvalid_re and not bus2ip_burst));
  
  bus2ip_wrreq        <= or_reduce(bus2ip_wrce(0 to C_NUM_BANKS_MEM-1)) 
                            and ((bus2ip_addrvalid and bus2ip_burst) or
                            (bus2ip_addrvalid_re and not bus2ip_burst));

    
  ip2bus_ack                <= ip2bus_rdack or ip2bus_wrack;
  ip2bus_postedwrinh        <= (others=>'0') when C_INCLUDE_BURST=1
                               else (others=>'1');
    -----------------------------------------------------------------------------
    -- Instantiate the EMC Controller
    -----------------------------------------------------------------------------

EMC_CTRL_I: entity emc_common_v2_00_a.emc
  generic map(      
       C_NUM_BANKS_MEM              =>   C_NUM_BANKS_MEM,
       C_INCLUDE_NEGEDGE_IOREGS     =>   C_INCLUDE_NEGEDGE_IOREGS,
       C_INCLUDE_BURST              =>   C_INCLUDE_BURST,
       C_IPIF_DWIDTH                =>   OPB_DWIDTH,
       C_IPIF_AWIDTH                =>   OPB_AWIDTH,
       C_MEM0_WIDTH                 =>   C_MEM0_WIDTH,
       C_MEM1_WIDTH                 =>   C_MEM1_WIDTH,  
       C_MEM2_WIDTH                 =>   C_MEM2_WIDTH,  
       C_MEM3_WIDTH                 =>   C_MEM3_WIDTH,  
       C_MAX_MEM_WIDTH              =>   C_MAX_MEM_WIDTH,

       C_INCLUDE_DATAWIDTH_MATCHING_0   =>  C_INCLUDE_DATAWIDTH_MATCHING_0,
       C_INCLUDE_DATAWIDTH_MATCHING_1   =>  C_INCLUDE_DATAWIDTH_MATCHING_1,
       C_INCLUDE_DATAWIDTH_MATCHING_2   =>  C_INCLUDE_DATAWIDTH_MATCHING_2,
       C_INCLUDE_DATAWIDTH_MATCHING_3   =>  C_INCLUDE_DATAWIDTH_MATCHING_3,
       
       -- Memory read and write access times for all memory banks
       C_BUS_CLOCK_PERIOD_PS        =>    OPB_CLK_PERIOD_PS,

       C_SYNCH_MEM_0                =>    C_SYNCH_MEM_0,
       C_SYNCH_PIPEDELAY_0          =>    C_SYNCH_PIPEDELAY_0,
       C_TCEDV_PS_MEM_0             =>    C_TCEDV_PS_MEM_0,   
       C_TAVDV_PS_MEM_0             =>    C_TAVDV_PS_MEM_0,  
       C_THZCE_PS_MEM_0             =>    C_THZCE_PS_MEM_0,   
       C_THZOE_PS_MEM_0             =>    C_THZOE_PS_MEM_0,   
       C_TWC_PS_MEM_0               =>    C_TWC_PS_MEM_0,     
       C_TWP_PS_MEM_0               =>    C_TWP_PS_MEM_0,     
       C_TLZWE_PS_MEM_0             =>    C_TLZWE_PS_MEM_0,   

       C_SYNCH_MEM_1                =>    C_SYNCH_MEM_1,
       C_SYNCH_PIPEDELAY_1          =>    C_SYNCH_PIPEDELAY_1,
       C_TCEDV_PS_MEM_1             =>    C_TCEDV_PS_MEM_1,   
       C_TAVDV_PS_MEM_1             =>    C_TAVDV_PS_MEM_1,  
       C_THZCE_PS_MEM_1             =>    C_THZCE_PS_MEM_1,   
       C_THZOE_PS_MEM_1             =>    C_THZOE_PS_MEM_1,   
       C_TWC_PS_MEM_1               =>    C_TWC_PS_MEM_1,     
       C_TWP_PS_MEM_1               =>    C_TWP_PS_MEM_1,     
       C_TLZWE_PS_MEM_1             =>    C_TLZWE_PS_MEM_1,  

       C_SYNCH_MEM_2                =>    C_SYNCH_MEM_2,
       C_SYNCH_PIPEDELAY_2          =>    C_SYNCH_PIPEDELAY_2,
       C_TCEDV_PS_MEM_2             =>    C_TCEDV_PS_MEM_2,   
       C_TAVDV_PS_MEM_2             =>    C_TAVDV_PS_MEM_2,  
       C_THZCE_PS_MEM_2             =>    C_THZCE_PS_MEM_2,   
       C_THZOE_PS_MEM_2             =>    C_THZOE_PS_MEM_2,   
       C_TWC_PS_MEM_2               =>    C_TWC_PS_MEM_2,     
       C_TWP_PS_MEM_2               =>    C_TWP_PS_MEM_2,     
       C_TLZWE_PS_MEM_2             =>    C_TLZWE_PS_MEM_2,  

       C_SYNCH_MEM_3                =>    C_SYNCH_MEM_3,
       C_SYNCH_PIPEDELAY_3          =>    C_SYNCH_PIPEDELAY_3,
       C_TCEDV_PS_MEM_3             =>    C_TCEDV_PS_MEM_3,   
       C_TAVDV_PS_MEM_3             =>    C_TAVDV_PS_MEM_3,  
       C_THZCE_PS_MEM_3             =>    C_THZCE_PS_MEM_3,   
       C_THZOE_PS_MEM_3             =>    C_THZOE_PS_MEM_3,   
       C_TWC_PS_MEM_3               =>    C_TWC_PS_MEM_3,     
       C_TWP_PS_MEM_3               =>    C_TWP_PS_MEM_3,     
       C_TLZWE_PS_MEM_3             =>    C_TLZWE_PS_MEM_3  
     
       )

    port map (
       Bus2IP_Clk              => bus2ip_clk,
       Bus2IP_Reset            => bus2ip_reset,
       Bus2IP_Addr             => bus2ip_addr,
       Bus2IP_BE               => bus2ip_be,
       Bus2IP_Data             => bus2ip_data,
       Bus2IP_RNW              => bus2ip_rnw,
       Bus2IP_Burst            => bus2ip_burst, 
       Bus2IP_IBurst           => bus2ip_burst,
       Bus2IP_WrReq            => bus2ip_wrreq,
       Bus2IP_RdReq            => bus2ip_rdreq,
       Bus2IP_Mem_CS           => memcon_cs_bus,
       IP2Bus_Data             => ip2bus_data,
       IP2Bus_errAck           => ip2bus_errack,
       IP2Bus_retry            => ip2bus_retry,
       IP2Bus_toutSup          => ip2bus_toutsup,
       IP2Bus_RdAck            => ip2bus_rdack,
       IP2Bus_WrAck            => ip2bus_wrack,
       IP2Bus_AddrAck          => ip2bus_addrack,
       Mem_A                   => Mem_A_i,
       Mem_DQ_I                => Mem_DQ_I,
       Mem_DQ_O                => Mem_DQ_O_i,
       Mem_DQ_T                => Mem_DQ_T_i,
       Mem_CEN                 => Mem_CEN_i,
       Mem_OEN                 => Mem_OEN_i,
       Mem_WEN                 => Mem_WEN_i,
       Mem_QWEN                => Mem_QWEN_i,
       Mem_BEN                 => Mem_BEN_i,
       Mem_RPN                 => Mem_RPN,

       Mem_CE                  => Mem_CE_i,
       Mem_ADV_LDN             => Mem_ADV_LDN_i,
       Mem_LBON                => Mem_LBON,
       Mem_CKEN                => Mem_CKEN_i,
       Mem_RNW                 => Mem_RNW
       );

end implementation;