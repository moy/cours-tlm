-------------------------------------------------------------------------------
-- $Id: count_module.vhd,v 1.6 2005/02/18 20:08:36 whittle Exp $
-------------------------------------------------------------------------------
-- count_module - entity/architecture pair
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
-- Filename:        count_module.vhd
-- Version:         v1.00.b
-- Description:     Module with one counter and load register
--
-------------------------------------------------------------------------------
-- Structure:
--
--              count_module.vhd
--              -- counter.vhd
--              ---- counter_bit.vhd
--              -- counter_reg.vhd
-------------------------------------------------------------------------------
-- Author:      BLT
-- History:
--  BLT             04-25-2001      -- First version
-- ^^^^^^
--      Contains four general purpose timers with capture/compare
--      capabilities.
-- ~~~~~~
--  BLT             03-20-2002      -- Parameterized counter width
-- LCW		Feb 18, 2005	-- updated for NCSim
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

--library proc_common_v1_00_b;
--use proc_common_v1_00_b.Common_Types.all;
library opb_timer_v1_00_b;
use opb_timer_v1_00_b.TC_Types.all;

-------------------------------------------------------------------------------
-- Port declarations
-------------------------------------------------------------------------------

entity count_module is

  generic (
    C_FAMILY          : string   := "virtex2";
    C_COUNT_WIDTH     : integer  := 32;
    C_Y               : integer  := 0;
    C_X               : integer  := 0;
    C_U_SET           : string   := ""
    );
  port (
    Clk               : in  std_logic;
    Reset             : in  std_logic;
    Load_DBus         : in  std_logic_vector(0 to C_COUNT_WIDTH-1);
    Load_Counter_Reg  : in  std_logic;
    Load_Load_Reg     : in  std_logic;
    Write_Load_Reg    : in  std_logic;  -- from OPB
    CaptGen_Mux_Sel   : in  std_logic;
    Counter_En        : in  std_logic;
    Count_Down        : in  std_logic;
    BE                : in  std_Logic_vector(0 to 3);
    LoadReg_DBus      : out std_logic_vector(0 to C_COUNT_WIDTH-1);
    CounterReg_DBus   : out std_logic_vector(0 to C_COUNT_WIDTH-1);
    Counter_TC        : out std_logic
    );

end entity count_module;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture IMP of count_module is

signal iCounterReg_DBus   : std_logic_vector(0 to C_COUNT_WIDTH-1);
signal counter_out        : std_logic_vector(0 to C_COUNT_WIDTH-1);
signal loadRegIn          : std_logic_vector(0 to C_COUNT_WIDTH-1);
signal load_Reg           : std_logic_vector(0 to C_COUNT_WIDTH-1);
signal load_load_reg_be   : std_logic_vector(0 to C_COUNT_WIDTH-1);
signal carry_out          : std_logic;

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------

begin -- Architecture IMP

CAPTGEN_MUX_PROCESS: process (CaptGen_Mux_Sel,Load_DBus,iCounterReg_DBus ) is
begin
  if CaptGen_Mux_Sel='1' then
    loadRegIn <= Load_DBus;
  else
    loadRegIn <= iCounterReg_DBus;
  end if;
end process CAPTGEN_MUX_PROCESS;

LOAD_REG_GEN: for i in 0 to C_COUNT_WIDTH-1 generate
  load_load_reg_be(i) <= Load_Load_Reg or
                         (Write_Load_Reg and BE((i-C_COUNT_WIDTH+32)/8));
  LOAD_REG_I: FDRE
    port map (
      Q  => load_Reg(i),                -- [out]
      C  => Clk,                        -- [in]
      CE => load_load_reg_be(i),        -- [in]
      D  => loadRegIn(i),               -- [in]
      R  => '0'                         -- [in]
    );
end generate LOAD_REG_GEN;

COUNTER_I: entity opb_timer_v1_00_b.counter
  generic map (
    C_FAMILY      => C_FAMILY,         -- [string]
    C_COUNT_WIDTH => C_COUNT_WIDTH,    -- [integer]
    C_Y           => C_Y,              -- [integer]
    C_X           => C_X,              -- [integer]
    C_U_SET       => C_U_SET )         -- [string]
  port map (
    Clk           => Clk,              -- [in  std_logic]
    Rst           => Reset,            -- [in  std_logic]
    Carry_Out     => carry_out,        -- [out std_logic]
    Load_In       => load_Reg,         -- [in  std_logic_vector]
    Count_Enable  => Counter_En,       -- [in  std_logic]
    Count_Load    => Load_Counter_Reg, -- [in  std_logic]
    Count_Down    => Count_Down,       -- [in  std_logic]
    Count_Out     => iCounterReg_DBus  -- [out std_logic_vector]
    );

Counter_TC       <= carry_out;
LoadReg_DBus     <= load_Reg;
CounterReg_DBus  <= iCounterReg_DBus;

end architecture imp;


