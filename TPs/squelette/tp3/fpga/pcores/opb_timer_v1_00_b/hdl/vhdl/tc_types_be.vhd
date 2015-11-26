-------------------------------------------------------------------------------
-- $Id: tc_types_be.vhd,v 1.3 2005/02/18 20:08:37 whittle Exp $
-------------------------------------------------------------------------------
-- TC_TYPES_BE - package
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
-- Filename:        tc_types_be.vhd
-- Version:         v1.00.b
-- Description:     Type definitions for Timer/Counter
--
-------------------------------------------------------------------------------
-- Structure:
--
--              tc_types_be.vhd
-------------------------------------------------------------------------------
-- Author:      BLT
-- History:
--  BLT             05-14-2001      -- First version
-- ^^^^^^
--      Initial definition of types for Peripheral Timer/Counter (PTC)
-- ~~~~~~
--  BLT             03-20-2002      -- Parameterized counter widths
--  LCW	Feb 18, 2005	  -- updated for NCSim
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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

library proc_common_v1_00_b;
use proc_common_v1_00_b.Common_Types.all;

library unisim;
use unisim.vcomponents.all;

package TC_Types is


  subtype  QUADLET_TYPE             is std_logic_vector(0 to 31);
  subtype  QUADLET_PLUS1_TYPE       is std_logic_vector(0 to 32);
  subtype  BYTE_TYPE                is std_logic_vector(0 to 7);
  subtype  ALU_OP_TYPE              is std_logic_vector(0 to 1);
  subtype  ADDR_WORD_TYPE           is std_logic_vector(0 to 31);
  subtype  BYTE_ENABLE_TYPE         is std_logic_vector(0 to 3);
  subtype  DATA_WORD_TYPE           is QUADLET_TYPE;
  subtype  INSTRUCTION_WORD_TYPE    is QUADLET_TYPE;

  -- Bus interface data types
  subtype  OPB_DWIDTH_TYPE          is QUADLET_TYPE;
  subtype  OPB_AWIDTH_TYPE          is QUADLET_TYPE;
  subtype  OPB_BEWIDTH_TYPE         is std_logic_vector(0 to 3);
  subtype  BYTE_PLUS1_TYPE          is std_logic_vector(0 to 8);
  subtype  NIBBLE_TYPE              is std_logic_vector(0 to 3);
  type     TWO_QUADLET_TYPE         is array (0 to 1) of QUADLET_TYPE;

  constant ENALL_POS    : integer := 21;
  constant PWMA0_POS    : integer := 22;
  constant T0INT_POS    : integer := 23;
  constant ENT0_POS     : integer := 24;
  constant ENIT0_POS    : integer := 25;
  constant RST0_POS     : integer := 26;
  constant ARHT0_POS    : integer := 27;
  constant CAPT0_POS    : integer := 28;
  constant CMPT0_POS    : integer := 29;
  constant UDT0_POS     : integer := 30;
  constant MDT0_POS     : integer := 31;

  constant PWMB0_POS    : integer := 22;
  constant T1INT_POS    : integer := 23;
  constant ENT1_POS     : integer := 24;
  constant ENIT1_POS    : integer := 25;
  constant RST1_POS     : integer := 26;
  constant ARHT1_POS    : integer := 27;
  constant CAPT1_POS    : integer := 28;
  constant CMPT1_POS    : integer := 29;
  constant UDT1_POS     : integer := 30;
  constant MDT1_POS     : integer := 31;

  constant LS_ADDR      : std_logic_vector(0 to 1) := "11";

  constant NEXT_MSB_BIT : integer := -1;
  constant NEXT_LSB_BIT : integer := 1;

  -- The following four constants arer reversed from what's
  -- in microblaze_isa_be_pkg.vhd
  constant BYTE_ENABLE_BYTE_0 : natural       := 0;
  constant BYTE_ENABLE_BYTE_1 : natural       := 1;
  constant BYTE_ENABLE_BYTE_2 : natural       := 2;
  constant BYTE_ENABLE_BYTE_3 : natural       := 3;

end package TC_TYPES;
