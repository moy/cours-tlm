-------------------------------------------------------------------------------
-- $Id: timer_control.vhd,v 1.7 2005/02/18 20:08:37 whittle Exp $
-------------------------------------------------------------------------------
-- timer_control - entity/architecture pair
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
-- Filename:        timer_control.vhd
-- Version:         v1.00.b
-- Description:     Control logic for Peripheral Timer/Counter
--
-------------------------------------------------------------------------------
-- Structure:
--
--              timer_control.vhd
-------------------------------------------------------------------------------
-- Author:      BLT
-- History:
--  BLT             05-14-2001      -- First version
-- ^^^^^^
--      First version of control logic.
-- ~~~~~~
--  BLT             03-20-2002      -- Parameterized counter width, added
--                                     Freeze capability
--  BLT             06-04-2002      -- Changed interrupt back to level sensitive
--
--  GAB             11-10-2003
-- ^^^^^^
--                                  -- Qualified Load_Counter_Reg(0) and
--                                      Load_Counter_Reg(1) to not cause
--                                      a load when in capture mode and TC
--                                      is reached to fix counter roll over
--                                      problem CR177658.
--   LCW	Feb 18, 2005	  -- updated for NCSim
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
library proc_common_v1_00_b;
use proc_common_v1_00_b.Common_Types.all;

library unisim;
use unisim.vcomponents.all;

library opb_timer_v1_00_b;
use opb_timer_v1_00_b.TC_Types.all;

entity timer_control is
  generic (
    C_FAMILY           : string  := "virtex2";
    C_Y                : integer := 0;
    C_X                : integer := 0;
    C_U_SET            : string := "timer_control";
    C_TRIG0_ASSERT     : std_logic := '1';
    C_TRIG1_ASSERT     : std_logic := '1';
    C_GEN0_ASSERT      : std_logic := '1';
    C_GEN1_ASSERT      : std_logic := '1'
    );
  port (
    Clk                : in   std_logic;
    Reset              : in   std_logic;
    CaptureTrig0       : in   std_logic;
    CaptureTrig1       : in   std_logic;
    GenerateOut0       : out  std_logic;
    GenerateOut1       : out  std_logic;
    Interrupt          : out  std_logic;
    Counter_TC         : in   std_logic_vector(0 to 1);
    OPB_DBus_Reg       : in   std_logic_vector(0 to 31);
    BE                 : in   std_logic_vector(0 to 3);
    Load_Counter_Reg   : out  std_logic_vector(0 to 1);
    Load_Load_Reg      : out  std_logic_vector(0 to 1);
    Write_Load_Reg     : out  std_logic_vector(0 to 1);
    CaptGen_Mux_Sel    : out  std_logic_vector(0 to 1);
    Counter_En         : out  std_logic_vector(0 to 1);
    Count_Down         : out  std_logic_vector(0 to 1);
    Count_Reset        : out  std_logic_vector(0 to 1);
    TCSR0_Select       : in   std_logic;
    TCSR1_Select       : in   std_logic;
    TCCR0_Select       : in   std_logic;
    TCCR1_Select       : in   std_logic;
    RNW                : in   std_logic;
    Freeze             : in   std_logic;
    TCSR0_Reg          : out  QUADLET_TYPE;
    TCSR1_Reg          : out  QUADLET_TYPE
    );
end entity timer_control;

architecture IMP of timer_control is

signal TCSR0_In          : QUADLET_TYPE;
signal TCSR0_Reset       : QUADLET_TYPE;
signal TCSR0_Set         : QUADLET_TYPE;
signal TCSR0_CE          : QUADLET_TYPE;
signal TCSR0             : QUADLET_TYPE;
signal TCSR1_In          : QUADLET_TYPE;
signal TCSR1_Reset       : QUADLET_TYPE;
signal TCSR1_Set         : QUADLET_TYPE;
signal TCSR1_CE          : QUADLET_TYPE;
signal TCSR1             : QUADLET_TYPE;
signal captureTrig0_d    : std_logic;
signal captureTrig1_d    : std_logic;
signal captureTrig0_d2   : std_logic;
signal captureTrig1_d2   : std_logic;
signal captureTrig0_Edge : std_logic;
signal captureTrig1_Edge : std_logic;
signal read_done0        : std_logic;
signal read_done1        : std_logic;
signal generateOutPre0   : std_logic;
signal generateOutPre1   : std_logic;
signal pair0_Select      : std_logic;
signal counter_TC_Reg    : std_logic_vector(0 to 1);

-------------------------------------------------------------------------------
-- Bits in Timer Control Status Register 0 (TCSR0)
-------------------------------------------------------------------------------
alias T0INT    : std_logic                is TCSR0(T0INT_POS);
alias ENT0     : std_logic                is TCSR0(ENT0_POS);
alias ENIT0    : std_logic                is TCSR0(ENIT0_POS);
alias RST0     : std_logic                is TCSR0(RST0_POS);
alias ARHT0    : std_logic                is TCSR0(ARHT0_POS);
alias CAPT0    : std_logic                is TCSR0(CAPT0_POS);
alias CMPT0    : std_logic                is TCSR0(CMPT0_POS);
alias UDT0     : std_logic                is TCSR0(UDT0_POS);
alias MDT0     : std_logic                is TCSR0(MDT0_POS);
alias PWMA0    : std_logic                is TCSR0(PWMA0_POS);

-------------------------------------------------------------------------------
-- Bits in Timer Control Status Register 1 (TCSR1)
-------------------------------------------------------------------------------
alias T1INT    : std_logic                is TCSR1(T1INT_POS);
alias ENT1     : std_logic                is TCSR1(ENT1_POS);
alias ENIT1    : std_logic                is TCSR1(ENIT1_POS);
alias RST1     : std_logic                is TCSR1(RST1_POS);
alias ARHT1    : std_logic                is TCSR1(ARHT1_POS);
alias CAPT1    : std_logic                is TCSR1(CAPT1_POS);
alias CMPT1    : std_logic                is TCSR1(CMPT1_POS);
alias UDT1     : std_logic                is TCSR1(UDT1_POS);
alias MDT1     : std_logic                is TCSR1(MDT1_POS);
alias PWMB0    : std_logic                is TCSR1(PWMB0_POS);


-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------

begin -- architecture IMP

pair0_Select <= (TCSR0_Select or TCSR1_Select) and not RNW ;

TCSR0_GENERATE: for i in QUADLET_TYPE'range generate
  TCSR0_FF_I: FDRSE
  port map (
    Q  => TCSR0(i),       -- [out]
    C  => Clk,            -- [in]
    CE => TCSR0_CE(i),    -- [in]
    D  => TCSR0_In(i),    -- [in]
    R  => TCSR0_Reset(i), -- [in]
    S  => TCSR0_Set(i)    -- [in]
  );
end generate TCSR0_GENERATE;

TCSR0_PROCESS: process (TCSR0_Select,OPB_DBus_Reg,RNW,MDT0,
                        captureTrig0_Edge,generateOutPre0,TCSR0,
                        pair0_select,Reset,BE) is
begin
  TCSR0_Reset <= (others => Reset);
  TCSR0_Set   <= (others => '0');
  for i in 0 to 3 loop
    for j in 0 to 7 loop
      TCSR0_CE(i*8+j) <= TCSR0_Select and not RNW and BE(i); -- write
    end loop;
  end loop;
  TCSR0_In    <= OPB_DBus_Reg;

  TCSR0_In(T0INT_POS) <= TCSR0(T0INT_POS);
  if TCSR0_Select='1' and OPB_DBus_Reg(T0INT_POS)='1'
    and RNW='0' then
    TCSR0_Reset(T0INT_POS) <= '1';
  else
    TCSR0_Reset(T0INT_POS) <= '0';
  end if;
  if (MDT0='1' and captureTrig0_Edge='1' and ENT0='1') or
     (MDT0='0' and generateOutPre0='1') then
    TCSR0_Set(T0INT_POS) <= '1';
  else
    TCSR0_Set(T0INT_POS) <= '0';
  end if;
  TCSR0_CE(ENALL_POS) <= pair0_Select and BE(2);
  TCSR0_CE(ENT0_POS)  <= pair0_Select;
  TCSR0_In(ENT0_POS)  <= (OPB_DBus_Reg(ENT0_POS) and TCSR0_Select and BE(3)) or
                         (OPB_DBus_Reg(ENALL_POS) and BE(2)) or
                         (TCSR0(ENT0_POS) and not TCSR0_Select);
end process TCSR0_PROCESS;

TCSR1_GENERATE: for i in QUADLET_TYPE'range generate
  TCSR1_FF_I: FDRSE
  port map (
    Q  => TCSR1(i),       -- [out]
    C  => Clk,            -- [in]
    CE => TCSR1_CE(i),    -- [in]
    D  => TCSR1_In(i),    -- [in]
    R  => TCSR1_Reset(i), -- [in]
    S  => TCSR1_Set(i)    -- [in]
  );
end generate TCSR1_GENERATE;

TCSR1_PROCESS: process (TCSR1_Select,OPB_DBus_Reg,RNW,MDT1,
                        captureTrig1_Edge,generateOutPre1,TCSR1,
                        pair0_Select,Reset,BE) is
begin
  TCSR1_Reset <= (others => Reset);
  TCSR1_Set   <= (others => '0');
  for i in 0 to 3 loop
    for j in 0 to 7 loop
      TCSR1_CE(i*8+j) <= TCSR1_Select and not RNW and BE(i); -- write
    end loop;
  end loop;
  TCSR1_In    <= OPB_DBus_Reg;

  TCSR1_In(T1INT_POS) <= TCSR1(T1INT_POS);
  if TCSR1_Select='1' and OPB_DBus_Reg(T1INT_POS)='1'
    and RNW='0' then
    TCSR1_Reset(T1INT_POS) <= '1';
  else
    TCSR1_Reset(T1INT_POS) <= '0';
  end if;
  if (MDT1='1' and captureTrig1_Edge='1' and ENT1='1') or
     (MDT1='0' and generateOutPre1='1') then
    TCSR1_Set(T1INT_POS) <= '1';
  else
    TCSR1_Set(T1INT_POS) <= '0';
  end if;
  TCSR1_CE(ENALL_POS) <= pair0_Select and BE(2);
  TCSR1_CE(ENT1_POS)  <= pair0_Select;
  TCSR1_In(ENT1_POS)  <= (OPB_DBus_Reg(ENT1_POS) and TCSR1_Select and BE(3)) or
                         (OPB_DBus_Reg(ENALL_POS) and BE(2)) or
                         (TCSR1(ENT1_POS) and not TCSR1_Select);
end process TCSR1_PROCESS;

-------------------------------------------------------------------------------
-- Counter Controls
-------------------------------------------------------------------------------

READ_DONE0_I: FDRSE
  port map (
    Q  => read_done0,        -- [out]
    C  => Clk,               -- [in]
    CE => '1',               -- [in]
    D  => read_done0,        -- [in]
    R  => captureTrig0_Edge, -- [in]
    S  => TCCR0_Select       -- [in]
  );

READ_DONE1_I: FDRSE
  port map (
    Q  => read_done1,        -- [out]
    C  => Clk,               -- [in]
    CE => '1',               -- [in]
    D  => read_done1,        -- [in]
    R  => captureTrig1_Edge, -- [in]
    S  => TCCR1_Select       -- [in]
  );

Count_Reset(0)   <= RST0;
Counter_En(0)    <= not Freeze and ENT0 and (MDT0 or (not Counter_TC(0) or (ARHT0 or PWMA0)));
Count_Down(0)    <= UDT0;
Count_Reset(1)   <= RST1;
Counter_En(1)    <= not Freeze and ENT1 and (MDT1 or (not Counter_TC(1) or (ARHT1 or PWMB0)));
Count_Down(1)    <= UDT1;

Load_Counter_Reg(0)  <=  (Counter_TC(0) and (ARHT0 or PWMA0) and (not MDT0)) or RST0;
Load_Counter_Reg(1)  <=  (Counter_TC(1) and ARHT1 and not PWMB0 and (not MDT1)) or
                          RST1 or (Counter_TC(0) and PWMB0);

Load_Load_Reg(0) <=  (MDT0 and captureTrig0_Edge and ARHT0) or
                     (MDT0 and captureTrig0_Edge and not ARHT0 and read_done0);
Load_Load_Reg(1) <=  (MDT1 and captureTrig1_Edge and ARHT1) or
                     (MDT1 and captureTrig1_Edge and not ARHT1 and read_done1);
Write_Load_Reg(0) <= (TCCR0_Select and (not RNW));
Write_Load_Reg(1) <= (TCCR1_Select and (not RNW));
CaptGen_Mux_Sel(0)  <=  TCCR0_Select and (not RNW);
CaptGen_Mux_Sel(1)  <=  TCCR1_Select and (not RNW);

CAPTGEN_SYNC_PROCESS: process(Clk) is
begin
  if Clk'event and Clk='1' then
    if Reset='1' then
      captureTrig0_d <= not C_TRIG0_ASSERT;
      captureTrig1_d <= not C_TRIG1_ASSERT;
    else
      captureTrig0_d <= (CaptureTrig0 xor not(C_TRIG0_ASSERT)) and CAPT0;
      captureTrig1_d <= (CaptureTrig1 xor not(C_TRIG1_ASSERT)) and CAPT1;
    end if;

    if Reset='1' then
      captureTrig0_d2 <= '0';
      captureTrig1_d2 <= '0';
    else
      captureTrig0_d2 <= captureTrig0_d;
      captureTrig1_d2 <= captureTrig1_d;
    end if;

    if Reset='1' then
      counter_TC_Reg(0) <= '0';
      counter_TC_Reg(1) <= '0';
    else
      counter_TC_Reg(0) <= Counter_TC(0);
      counter_TC_Reg(1) <= Counter_TC(1);
    end if;

    if Reset='1' then
      generateOutPre0 <= '0';
      generateOutPre1 <= '0';
    else
      generateOutPre0 <= Counter_TC(0) and not counter_TC_Reg(0);
      generateOutPre1 <= Counter_TC(1) and not counter_TC_Reg(1);
    end if;

    if Reset='1' then
      GenerateOut0 <= not C_GEN0_ASSERT;
      GenerateOut1 <= not C_GEN1_ASSERT;
    else
      GenerateOut0 <= (generateOutPre0 and CMPT0) xor not(C_GEN0_ASSERT);
      GenerateOut1 <= (generateOutPre1 and CMPT1) xor not(C_GEN1_ASSERT);
    end if;

    if Reset='1' then
      Interrupt <= '0';
    else
      -- for edge sensitive interrupt
      -- Interrupt <= (ENIT0 and TCSR0_Set(T0INT_POS)) or
      --              (ENIT1 and TCSR1_Set(T1INT_POS));
      -- for level-sensitive interrupt
      Interrupt <= (ENIT0 and T0INT) or
                   (ENIT1 and T1INT);
    end if;

  end if;
end process CAPTGEN_SYNC_PROCESS;

captureTrig0_Edge <= captureTrig0_d and not captureTrig0_d2;
captureTrig1_Edge <= captureTrig1_d and not captureTrig1_d2;

TCSR0_Reg <= TCSR0;
TCSR1_Reg <= TCSR1;

end architecture IMP;
