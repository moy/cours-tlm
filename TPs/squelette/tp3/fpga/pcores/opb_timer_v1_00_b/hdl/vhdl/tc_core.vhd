--SINGLE_FILE_TAG
-------------------------------------------------------------------------------
-- $Id: tc_core.vhd,v 1.5 2005/02/18 20:08:37 whittle Exp $
-------------------------------------------------------------------------------
-- TC_Core - entity/architecture pair
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
-- Filename:        tc_core.vhd
-- Version:         v1.00.b
-- Description:     Dual Timer/Counter for OPB bus
--
-------------------------------------------------------------------------------
-- Structure:
--
--              tc_core.vhd
-------------------------------------------------------------------------------
-- Author:      BLT
-- History:
--  BLT             07-5-2001      -- First version
-- ^^^^^^
--      First version of Dual Timer Counter.
-- ~~~~~~
--  BLT             03-20-2002     -- Parameterized counter width
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
use IEEE.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library opb_timer_v1_00_b;
use opb_timer_v1_00_b.TC_Types.all;
library proc_common_v1_00_b;
use proc_common_v1_00_b.all;
use proc_common_v1_00_b.Common_Types.all;

entity TC_Core is
  generic (
    C_FAMILY           : string  := "virtex2";
    C_COUNT_WIDTH      : integer := 32;
    C_ONE_TIMER_ONLY   : integer := 0;
  C_OPB_DWIDTH       : integer := 32;
  C_OPB_AWIDTH       : integer := 32;
    C_Y                : integer := 0;
    C_X                : integer := 0;
    C_U_SET            : string := "timer_control";
    C_TRIG0_ASSERT     : std_logic := '1';
    C_TRIG1_ASSERT     : std_logic := '1';
    C_GEN0_ASSERT      : std_logic := '1';
    C_GEN1_ASSERT      : std_logic := '1'
    );
  port (
    OPB_Clk            : in  std_logic;
    OPB_Rst            : in  std_logic;

    -- OPB signals
    OPB_ABus_Reg       : in  std_logic_vector(0 to 31);
    OPB_BE_Reg         : in  std_logic_vector(0 to 3);
    OPB_DBus_Reg       : in  std_logic_vector(0 to 31);
    OPB_RNW_Reg        : in  std_logic;
    TC_DBus            : out std_logic_vector(0 to 31);
    TC_errAck          : out std_logic;
    TC_retry           : out std_logic;
    TC_toutSup         : out std_logic;
    TC_xferAck         : out std_logic;

    -- PTC signals
    CaptureTrig0       : in  std_logic;
    CaptureTrig1       : in  std_logic;
    GenerateOut0       : out std_logic;
    GenerateOut1       : out std_logic;
    PWM0               : out std_logic;
    Interrupt          : out std_logic;
    Freeze             : in  std_logic;

    -- Peripheral Select address decode
    TC_Select          : in  std_logic
    );
end entity TC_Core;


architecture IMP of TC_Core is

attribute syn_keep : boolean;

signal load_Counter_Reg     : std_logic_vector(0 to 1);
signal load_Load_Reg        : std_logic_vector(0 to 1);
signal write_Load_Reg       : std_logic_vector(0 to 1);
signal captGen_Mux_Sel      : std_logic_vector(0 to 1);
signal loadReg_DBus         : std_logic_vector(0 to C_COUNT_WIDTH*2-1);
signal counterReg_DBus      : std_logic_vector(0 to C_COUNT_WIDTH*2-1);
signal opb_Read_Reg_CE      : std_logic_vector(0 to 3) := "1111";
signal tCSR0_Select         : std_logic;
signal tCSR1_Select         : std_logic;
signal tCSR2_Select         : std_logic;
signal tCCR0_Select         : std_logic;
signal tCCR1_Select         : std_logic;
signal tCCR2_Select         : std_logic;
signal tCCR3_Select         : std_logic;
signal tCR0_Select          : std_logic;
signal tCR1_Select          : std_logic;
signal tCR2_Select          : std_logic;
signal tCR3_Select          : std_logic;
signal tCSR0_Reg            : QUADLET_TYPE;
signal tCSR1_Reg            : QUADLET_TYPE;

signal counter_TC           : std_logic_vector(0 to 1);
signal counter_En           : std_logic_vector(0 to 1);
signal count_Down           : std_logic_vector(0 to 1);
attribute syn_keep of count_Down : signal is true;
signal count_Reset          : std_logic_vector(0 to 1);

signal iPWM0                : std_logic;
signal iGenerateOut0        : std_logic;
signal iGenerateOut1        : std_logic;
signal pwm_Reset            : std_logic;

begin -- architecture IMP

BUS_INTERFACE_I: entity opb_timer_v1_00_b.Bus_Interface
  generic map (
    C_FAMILY       => C_FAMILY,
    C_COUNT_WIDTH  => C_COUNT_WIDTH,    -- [integer]
    C_Y            => C_Y,
    C_X            => C_X,
    C_U_SET        => C_U_SET )
  port map (
    Clk                => OPB_Clk,          --[in]
    Reset              => OPB_Rst,          --[in]
    OPB_ABus           => OPB_ABus_Reg,     --[in]
    TC_DBus            => TC_DBus,          --[out]
    TC_select          => TC_select,        --[in]
    TC_xferAck         => TC_xferAck,       --[out]
    LoadReg_DBus       => loadReg_DBus,     --[in]
    CounterReg_DBus    => counterReg_DBus,  --[in]
    TCSR0_Select       => tCSR0_Select,     --[out]
    TCSR1_Select       => tCSR1_Select,     --[out]
    TLR0_Select        => tCCR0_Select,     --[out]
    TLR1_Select        => tCCR1_Select,     --[out]
    TCR0_Select        => tCR0_Select,      --[out]
    TCR1_Select        => tCR1_Select,      --[out]
    RNW                => OPB_RNW_Reg,      --[in]
    TCSR0_Reg          => tCSR0_Reg,        --[in]
    TCSR1_Reg          => tCSR1_Reg         --[in]
    );

COUNTER_0_I: entity opb_timer_v1_00_b.count_module
  generic map (
    C_FAMILY          => C_FAMILY,
    C_COUNT_WIDTH     => C_COUNT_WIDTH,
    C_Y               => C_Y,
    C_X               => C_X,
    C_U_SET           => "TC_Counter0" )
  port map (
    Clk               => OPB_Clk,               --[in]
    Reset             => Count_Reset(0),        --[in]
    Load_DBus         => OPB_DBus_Reg(C_OPB_DWIDTH-C_COUNT_WIDTH to C_OPB_DWIDTH-1), --[in]
    Load_Counter_Reg  => load_Counter_Reg(0),   --[in]
    Load_Load_Reg     => load_Load_Reg(0),      --[in]
    Write_Load_Reg    => write_Load_Reg(0),     --[in]
    CaptGen_Mux_Sel   => captGen_Mux_Sel(0),    --[in]
    Counter_En        => counter_En(0),         --[in]
    Count_Down        => count_Down(0),         --[in]
    BE                => OPB_BE_Reg,            --[in]
    LoadReg_DBus      => loadReg_DBus(C_COUNT_WIDTH*0 to C_COUNT_WIDTH*1-1),    --[out]
    CounterReg_DBus   => counterReg_DBus(C_COUNT_WIDTH*0 to C_COUNT_WIDTH*1-1), --[out]
    Counter_TC        => counter_TC(0)          --[out]
    );

GEN_SECOND_TIMER: if C_ONE_TIMER_ONLY /= 1 generate
COUNTER_1_I: entity opb_timer_v1_00_b.count_module
  generic map (
    C_FAMILY          => C_FAMILY,
    C_COUNT_WIDTH     => C_COUNT_WIDTH,
    C_Y               => C_Y,
    C_X               => C_X,
    C_U_SET           => "TC_Counter1" )
  port map (
    Clk               => OPB_Clk,               --[in]
    Reset             => Count_Reset(1),        --[in]
    Load_DBus         => OPB_DBus_Reg(C_OPB_DWIDTH-C_COUNT_WIDTH to C_OPB_DWIDTH-1), --[in]
    Load_Counter_Reg  => load_Counter_Reg(1),   --[in]
    Load_Load_Reg     => load_Load_Reg(1),      --[in]
    Write_Load_Reg    => write_Load_Reg(1),     --[in]
    CaptGen_Mux_Sel   => captGen_Mux_Sel(1),    --[in]
    Counter_En        => counter_En(1),         --[in]
    Count_Down        => count_Down(1),         --[in]
    BE                => OPB_BE_Reg,            --[in]
    LoadReg_DBus      => loadReg_DBus(C_COUNT_WIDTH*1 to C_COUNT_WIDTH*2-1),    --[out]
    CounterReg_DBus   => counterReg_DBus(C_COUNT_WIDTH*1 to C_COUNT_WIDTH*2-1), --[out]
    Counter_TC        => counter_TC(1)          --[out]
    );
end generate GEN_SECOND_TIMER;

GEN_NO_SECOND_TIMER: if C_ONE_TIMER_ONLY = 1 generate
  loadReg_DBus(C_COUNT_WIDTH*1 to C_COUNT_WIDTH*2-1)    <= (others => '0');
  counterReg_DBus(C_COUNT_WIDTH*1 to C_COUNT_WIDTH*2-1) <= (others => '0');
  counter_TC(1) <= '0';
end generate GEN_NO_SECOND_TIMER;

TIMER_CONTROL_I: entity opb_timer_v1_00_b.timer_control
  generic map (
    C_FAMILY           => C_FAMILY,
    C_Y                => C_Y,
    C_X                => C_X,
    C_U_SET            => C_U_SET,
    C_TRIG0_ASSERT     => C_TRIG0_ASSERT,
    C_TRIG1_ASSERT     => C_TRIG1_ASSERT,
    C_GEN0_ASSERT      => C_GEN0_ASSERT,
    C_GEN1_ASSERT      => C_GEN1_ASSERT
    )
  port map (
    Clk                => OPB_Clk,            -- [in]
    Reset              => OPB_Rst,            -- [in]
    CaptureTrig0       => CaptureTrig0,       -- [in]
    CaptureTrig1       => CaptureTrig1,       -- [in]
    GenerateOut0       => iGenerateOut0,      -- [out]
    GenerateOut1       => iGenerateOut1,      -- [out]
    Interrupt          => Interrupt,          -- [out]
    Counter_TC         => counter_TC,         -- [in]
    OPB_DBus_Reg       => OPB_DBus_Reg,       -- [in]
    BE                 => OPB_BE_Reg,         -- [in]
    Load_Counter_Reg   => load_Counter_Reg,   -- [out]
    Load_Load_Reg      => load_Load_Reg,      -- [out]
    Write_Load_Reg     => write_Load_Reg,     -- [out]
    CaptGen_Mux_Sel    => captGen_Mux_Sel,    -- [out]
    Counter_En         => counter_En,         -- [out]
    Count_Down         => count_Down,         -- [out]
    Count_Reset        => count_Reset,        -- [out]
    TCSR0_Select       => tCSR0_Select,       -- [in]
    TCSR1_Select       => tCSR1_Select,       -- [in]
    TCCR0_Select       => tCCR0_Select,       -- [in]
    TCCR1_Select       => tCCR1_Select,       -- [in]
    RNW                => OPB_RNW_Reg,        -- [in]
    Freeze             => Freeze,             -- [in]
    TCSR0_Reg          => tCSR0_Reg,          -- [out]
    TCSR1_Reg          => tCSR1_Reg           -- [out]
    );

pwm_Reset <= iGenerateOut1 or
             (not tCSR0_Reg(PWMA0_POS) and not tCSR1_Reg(PWMB0_POS));

PWM_FF_I: FDRS
    port map (
      Q  => iPWM0,                  -- [out]
      C  => OPB_Clk,                -- [in]
      D  => iPWM0,                  -- [in]
      R  => pwm_Reset,              -- [in]
      S  => iGenerateOut0           -- [in]
    );

PWM0         <= iPWM0;
GenerateOut0 <= iGenerateOut0;
GenerateOut1 <= iGenerateOut1;

TC_errAck   <= '0';
TC_retry    <= '0';
TC_toutSup  <= '0';

end architecture IMP;
