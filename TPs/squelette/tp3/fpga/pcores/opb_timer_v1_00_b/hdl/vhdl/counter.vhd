-------------------------------------------------------------------------------
-- $Id: counter.vhd,v 1.6 2005/02/18 20:08:36 whittle Exp $
-------------------------------------------------------------------------------
-- Counter - entity/architecture pair
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
-- Filename:        counter.vhd
--
-- Description:     Implements 32-bit timer/counter
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  counter.vhd
--
-------------------------------------------------------------------------------
-- Author:          B.L. Tise
-- Revision:        $Revision: 1.6 $
-- Date:            $Date: 2005/02/18 20:08:36 $
--
-- History:
--   tise           2001-07-05    First Version
--   tise           2002-03-20    Parameterized counter widths
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
--library proc_common_v1_00_b;
--use proc_common_v1_00_b.Common_Types.all;
library unisim;
use unisim.vcomponents.all;
library opb_timer_v1_00_b;
use opb_timer_v1_00_b.TC_Types.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--   C_FAMILY             -- Which Xilinx FPGA family to target when
--                           syntesizing, affect the RLOC string values
--   C_Y                  -- Which Y position the RLOC should start from
--   C_X                  -- Which X position the RLOC should start from
--   C_U_SET              -- Which User Set the RLOCs belong to
--
-- Definition of Ports:
--   Clk                  -- The global clock
--
-------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity Counter is
  generic (
    C_FAMILY      : string  := "virtex2";
    C_COUNT_WIDTH : integer := 32;
    C_Y           : integer := 0;
    C_X           : integer := 0;
    C_U_SET       : string  := "Set1"
    );
  port (
    Clk           : in  std_logic;
    Rst           : in  std_logic;
    Carry_Out     : out std_logic;
    Load_In       : in  std_logic_vector(0 to C_COUNT_WIDTH-1);
    Count_Enable  : in  std_logic;
    Count_Load    : in  std_logic;
    Count_Down    : in  std_logic;
    Count_Out     : out std_logic_vector(0 to C_COUNT_WIDTH-1)
    );
end entity Counter;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of Counter is


  constant CY_START : integer := (1-Next_MSB_Bit)/2;

  signal alu_cy            : std_logic_vector(0 to C_COUNT_WIDTH);
  signal iCount_Out        : std_logic_vector(0 to C_COUNT_WIDTH-1);
  -- signal count_load_be     : std_logic_vector(0 to C_COUNT_WIDTH-1);
  signal count_clock_en    : std_logic;
  signal carry_active_high : std_logic;

begin  -- VHDL_RTL

  -----------------------------------------------------------------------------
  -- Generate the Load vector
  -----------------------------------------------------------------------------
-- COUNT_LOAD_BE_PROC: process (BE,Count_Load) is
--  begin
--    for i in 0 to C_COUNT_WIDTH-1 loop
--      count_load_be(i) <= BE((i-C_COUNT_WIDTH+32)/8) and Count_Load;
--    end loop;
--  end process COUNT_LOAD_BE_PROC;
--
  -----------------------------------------------------------------------------
  -- Generate the Counter bits
  -----------------------------------------------------------------------------
  alu_cy(C_COUNT_WIDTH) <= (Count_Down and Count_Load) or
                           (not Count_Down and not Count_load);
  count_clock_en <= Count_Enable or Count_Load;

  I_ADDSUB_GEN : for I in C_COUNT_WIDTH-1 downto 0 generate
  begin
    Counter_Bit_I : entity opb_timer_v1_00_b.counter_bit
      generic map (
        C_FAMILY      => C_FAMILY,
        C_Y           => C_Y + ((C_COUNT_WIDTH-1-I)/2),
        C_X           => C_X,
        C_U_SET       => C_U_SET)
      port map (
        Clk           => Clk,                      -- [in]
        Count_In      => iCount_Out(i),            -- [in]
        Load_In       => Load_In(i),               -- [in]
        Count_Load    => Count_Load,               -- [in]
        Count_Down    => Count_Down,               -- [in]
        Carry_In      => alu_cy(I+CY_Start),       -- [in]
        Clock_Enable  => count_clock_en,           -- [in]
        Result        => iCount_Out(I),            -- [out]
        Carry_Out     => alu_cy(I+(1-CY_Start)));  -- [out]
  end generate I_ADDSUB_GEN;

  carry_active_high <= alu_cy(0) xor Count_Down;

  CARRY_OUT_I: FDRE
    port map (
      Q  => Carry_Out,                             -- [out]
      C  => Clk,                                   -- [in]
      CE => count_clock_en,                        -- [in]
      D  => carry_active_high,                     -- [in]
      R  => Rst                                    -- [in]
    );

  Count_Out <= iCount_Out;

end architecture imp;

