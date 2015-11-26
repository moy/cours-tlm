-------------------------------------------------------------------------------
-- $Id: counter_bit.vhd,v 1.4 2005/02/18 20:08:37 whittle Exp $
-------------------------------------------------------------------------------
-- counter_bit - entity/architecture pair
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
-- Filename:        counter_bit.vhd
--
-- Description:     Implements 1 bit of the counter/timer
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  counter_bit.vhd
--
-------------------------------------------------------------------------------
-- Author:          B.L. Tise
-- Revision:        $Revision: 1.4 $
-- Date:            $Date: 2005/02/18 20:08:37 $
--
-- History:
--   tise           2001-04-04    First Version
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
--      combinatorial signals:                  "*_com"
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
library unisim;
use unisim.vcomponents.all;
library proc_common_v1_00_b;
use proc_common_v1_00_b.Common_Types.all;
library opb_timer_v1_00_b;
use opb_timer_v1_00_b.TC_Types.all;

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity counter_bit is

  generic (
    C_FAMILY : string  := "virtex2";
    C_Y      : integer := 0;
    C_X      : integer := 0;
    C_U_SET  : string  := ""
    );
  port (
    Clk           : in  std_logic;
    Count_In      : in  std_logic;
    Load_In       : in  std_logic;
    Count_Load    : in  std_logic;
    Count_Down    : in  std_logic;
    Carry_In      : in  std_logic;
    Clock_Enable  : in  std_logic;
    Result        : out std_logic;
    Carry_Out     : out std_logic);

end entity counter_bit;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of counter_bit is


  signal    count_AddSub     : std_logic;
  signal    count_Result     : std_logic;
  signal    count_Result_Reg : std_logic;

  attribute INIT       : string;
  attribute RLOC       : string;
  attribute U_SET      : string;

  ----------------------------------------------------------------------------
  -- RLOCs and U_SETs removed until XST supports returning string
  -- from a function. Need to convert string types to something that
  -- Get_RLOC_Name can use.
  ----------------------------------------------------------------------------
  -- constant  RLOC_PLACE : string := Get_RLOC_Name(Target => C_TARGET,
  --                                               Y      => C_Y,
  --                                               X      => C_X);

  -- attribute RLOC of I_ALU_LUT    : label is RLOC_Place;
  -- attribute RLOC of MUXCY_I      : label is RLOC_Place;
  -- attribute RLOC of XOR_I        : label is RLOC_Place;
  -- attribute RLOC of FDRE_I       : label is RLOC_Place;

  -- attribute U_SET of I_ALU_LUT   : label is C_U_SET;
  -- attribute U_SET of MUXCY_I     : label is C_U_SET;
  -- attribute U_SET of XOR_I       : label is C_U_SET;
  -- attribute U_SET of FDRE_I      : label is C_U_SET;

begin  -- VHDL_RTL


  I_ALU_LUT : LUT4
    generic map(
      INIT => X"36C6"
      )
    port map (
      O  => count_AddSub,               -- [out]
      I0 => Count_In,                   -- [in]
      I1 => Count_Down,                 -- [in]
      I2 => Count_Load,                 -- [in]
      I3 => Load_In);                   -- [in]

  MUXCY_I : MUXCY_L
    port map (
      DI => Count_Down,
      CI => Carry_In,
      S  => count_AddSub,
      LO => Carry_Out);

  XOR_I : XORCY
    port map (
      LI => count_AddSub,
      CI => Carry_In,
      O  => count_Result);

  FDRE_I: FDRE
    port map (
      Q  => count_Result_Reg,           -- [out]
      C  => Clk,                        -- [in]
      CE => Clock_Enable,               -- [in]
      D  => count_Result,               -- [in]
      R  => '0'                         -- [in]
    );

  Result <= count_Result_Reg;

end imp;

