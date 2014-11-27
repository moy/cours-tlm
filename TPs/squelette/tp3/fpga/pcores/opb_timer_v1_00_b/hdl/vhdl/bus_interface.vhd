-------------------------------------------------------------------------------
-- $Id: bus_interface.vhd,v 1.4 2005/02/18 20:08:36 whittle Exp $
-------------------------------------------------------------------------------
-- Bus_Interface - entity/architecture pair
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
-- Filename:        bus_interface.vhd
-- Version:         v1.00.b
-- Description:     Bus Interface for Peripheral Timer/Counter
--
-------------------------------------------------------------------------------
-- Structure:
--
--              bus_interface.vhd
-------------------------------------------------------------------------------
-- Author:      BLT
-- History:
--  BLT             05-15-2001      -- First version
-- ^^^^^^
--      First version of bus interface.
-- ~~~~~~
--  BLT             03-20-2002      -- Parametrized counter width
-- LCW		Feb 18, 2005  -- updated for NCSim
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
use IEEE.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.all;
library proc_common_v1_00_b;
use proc_common_v1_00_b.all;
use proc_common_v1_00_b.Common_Types.all;
library opb_timer_v1_00_b;
use opb_timer_v1_00_b.TC_Types.all;

entity Bus_Interface is
  generic (
    C_FAMILY       : string  := "virtex2";
    C_COUNT_WIDTH  : integer  := 32;
    C_Y            : integer := 0;
    C_X            : integer := 0;
    C_OPB_DWIDTH   : integer := 32;
    C_U_SET        : string  := "timer_control"
    );
  port (
    Clk                : in   std_logic;
    Reset              : in   std_logic;
    OPB_ABus           : in   OPB_AWIDTH_TYPE;
    TC_DBus            : out  OPB_DWIDTH_TYPE;
    TC_select          : in   std_logic;
    TC_xferAck         : out  std_logic;
    LoadReg_DBus       : in   std_logic_vector(0 to C_COUNT_WIDTH*2-1);
    CounterReg_DBus    : in   std_logic_vector(0 to C_COUNT_WIDTH*2-1);
    TCSR0_Select       : out  std_logic;
    TCSR1_Select       : out  std_logic;
    TLR0_Select        : out  std_logic;
    TLR1_Select        : out  std_logic;
    TCR0_Select        : out  std_logic;
    TCR1_Select        : out  std_logic;
    RNW                : in   std_logic;
    TCSR0_Reg          : in   QUADLET_TYPE;
    TCSR1_Reg          : in   QUADLET_TYPE
    );
end entity Bus_Interface;

architecture IMP of Bus_Interface is

attribute U_SET : string;
attribute RLOC  : string;

signal opb_Read_Reg_In  : QUADLET_TYPE;
signal shiftReg         : std_logic;
signal read_Mux_In      : std_logic_vector(0 to 6*32-1);
signal read_Mux_S       : std_logic_vector(0 to 5);
signal xferAck_FF       : std_logic;
signal tc_xferAck_Reg   : std_logic;
signal iTC_xferAck      : std_logic;
signal opb_Read_Reg_Rst : std_logic := '1';
signal out_FF_Reset     : std_logic := '1';
signal sl_xfer_Ack_delay: std_logic;
signal iTCSR0_Select    : std_logic;
signal iTCSR1_Select    : std_logic;
signal iTLR0_Select     : std_logic;
signal iTLR1_Select     : std_logic;
signal iTCR0_Select     : std_logic;
signal iTCR1_Select     : std_logic;

begin -- architecture IMP

REG_SELECT_PROCESS: process (TC_Select,OPB_ABus) is
begin
  iTCSR0_Select <= '0';
  iTCSR1_Select <= '0';
  iTLR0_Select <= '0';
  iTLR1_Select <= '0';
  iTCR0_Select  <= '0';
  iTCR1_Select  <= '0';
  if TC_Select='1' then
    case OPB_ABus(26 to 29) is             -- BETAG
      when X"0" => iTCSR0_Select <= '1';
      when X"1" => iTLR0_Select  <= '1';
      when X"2" => iTCR0_Select  <= '1';
      when X"4" => iTCSR1_Select <= '1';
      when X"5" => iTLR1_Select  <= '1';
      when X"6" => iTCR1_Select  <= '1';
      when others => null;
    end case;
  end if;
end process REG_SELECT_PROCESS;

READ_MUX_INPUT: process (TCSR0_Reg,TCSR1_Reg,LoadReg_DBus,CounterReg_DBus) is
begin
  read_Mux_In(0  to 20) <= (others => '0');
  read_Mux_In(21 to 31) <= TCSR0_Reg(21 to 31);
  read_Mux_In(32 to 52) <= (others => '0');
  read_Mux_In(53 to 63) <= TCSR1_Reg(21 to 31);
  if C_COUNT_WIDTH < C_OPB_DWIDTH then
    for i in 1 to C_OPB_DWIDTH-C_COUNT_WIDTH loop
      read_Mux_In(63 +i)  <= '0';
      read_Mux_In(95 +i)  <= '0';
      read_Mux_In(127+i)  <= '0';
      read_Mux_In(159+i)  <= '0';
    end loop;
  end if;
  read_Mux_In(64 +C_OPB_DWIDTH-C_COUNT_WIDTH to  95) <=
    LoadReg_DBus(C_COUNT_WIDTH*0 to C_COUNT_WIDTH*1-1);
  read_Mux_In(96 +C_OPB_DWIDTH-C_COUNT_WIDTH to 127) <=
    LoadReg_DBus(C_COUNT_WIDTH*1 to C_COUNT_WIDTH*2-1);
  read_Mux_In(128+C_OPB_DWIDTH-C_COUNT_WIDTH to 159) <=
    CounterReg_DBus(C_COUNT_WIDTH*0 to C_COUNT_WIDTH*1-1);
  read_Mux_In(160+C_OPB_DWIDTH-C_COUNT_WIDTH to 191) <=
    CounterReg_DBus(C_COUNT_WIDTH*1 to C_COUNT_WIDTH*2-1);
end process READ_MUX_INPUT;

-- Create read mux select input
read_Mux_S <= iTCSR0_Select & iTCSR1_Select & iTLR0_Select &
              iTLR1_Select & iTCR0_Select & iTCR1_Select;

--READ_SELECT_GEN: for i in QUADLET_TYPE'range generate
--  read_Mux_S(i*6 to i*6+5) <= read_Mux_S_bit;
--end generate READ_SELECT_GEN;

READ_MUX_I: entity proc_common_v1_00_b.mux_onehot
  generic map(
      C_DW => 32,
      C_NB => 6 )
  port map(
      D    => read_Mux_In,     --[in]
      S    => read_Mux_S,      --[in]
      Y    => opb_Read_Reg_In  --[out]
      );


READ_REG_GEN: for i in QUADLET_TYPE'range generate
  READ_REG_FF_I: FDR
    port map (
      Q  => TC_DBus(i),            -- [out]
      C  => Clk,                   -- [in]
      D  => opb_Read_Reg_In(i),    -- [in]
      R  => opb_Read_Reg_Rst       -- [in]
    );
end generate READ_REG_GEN;


  XFERACK_FF_I: FDR
  port map (
    Q  => iTC_xferAck,   -- [out]
    C  => Clk,           -- [in]
    D  => TC_Select,     -- [in]
    R  => out_FF_Reset   -- [in]
  );

  XFERACK_FF_DELAYED_I: FDR
  port map (
    Q  => sl_xfer_Ack_delay,   -- [out]
    C  => Clk,                 -- [in]
    D  => iTC_xferAck,         -- [in]
    R  => Reset              -- [in]
  );

  out_FF_Reset <= iTC_xferAck or sl_xfer_Ack_delay or Reset;
  opb_Read_Reg_Rst <= out_FF_Reset or not RNW;

  TC_xferAck <= iTC_xferAck;

TC_xferAck  <= iTC_xferAck;

TCSR0_Select <=  iTCSR0_Select;
TCSR1_Select <=  iTCSR1_Select;
TLR0_Select  <=  iTLR0_Select;
TLR1_Select  <=  iTLR1_Select;
TCR0_Select  <=  iTCR0_Select;
TCR1_Select  <=  iTCR1_Select;

end architecture IMP;
