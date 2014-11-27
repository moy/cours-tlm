--SINGLE_FILE_TAG
-------------------------------------------------------------------------------
-- $Id: opb_timer.vhd,v 1.6 2005/02/18 20:08:37 whittle Exp $
-------------------------------------------------------------------------------
-- OPB_Timer - entity/architecture pair
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
-- Filename:        opb_timer.vhd
-- Version:         v1.00.b
-- Description:     Timer/Counter for OPB bus
--
-------------------------------------------------------------------------------
-- Structure:
--
--              opb_timer.vhd
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_H_SP1
-- Updated library statements to support NCSim
-- @END_CHANGELOG
-------------------------------------------------------------------------------
-- Author:      BLT
-- History:
--  BLT             07-05-2001      -- First version
-- ^^^^^^
--      First version of Timer Counter.
-- ~~~~~~
--  BLT             03-19-2002      -- Parameterized count widths
-- ^^^^^^
--      Second version of Timer Counter.
-- ~~~~~~
--  BLT             06-04-2002      -- Made interrupt level sensitive
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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library opb_timer_v1_00_b;
use opb_timer_v1_00_b.TC_Types.all;
library proc_common_v1_00_b;
use proc_common_v1_00_b.all;
use proc_common_v1_00_b.Common_Types.all;

-------------------------------------------------------------------------------
-- Port declarations
-------------------------------------------------------------------------------

entity OPB_Timer is
    generic (
        C_FAMILY           : string    := "virtex2";
        C_COUNT_WIDTH      : integer   := 32;
        C_ONE_TIMER_ONLY   : integer   := 0;
        C_TRIG0_ASSERT     : std_logic := '1';
        C_TRIG1_ASSERT     : std_logic := '1';
        C_GEN0_ASSERT      : std_logic := '1';
        C_GEN1_ASSERT      : std_logic := '1';
        C_OPB_AWIDTH       : integer := 32;
        C_OPB_DWIDTH       : integer := 32;
        C_BASEADDR         : std_logic_vector := X"FFFF_FFFF";
        C_HIGHADDR         : std_logic_vector := X"0000_0000"
    );
    port (
        OPB_Clk            : in  std_logic;
        OPB_Rst            : in  std_logic;

        -- OPB signals
        OPB_ABus           : in  std_logic_vector(0 to 31);
        OPB_BE             : in  std_logic_vector(0 to 3);
        OPB_DBus           : in  std_logic_vector(0 to 31);
        OPB_RNW            : in  std_logic;
        OPB_select         : in  std_logic;
        OPB_seqAddr        : in  std_logic;
        TC_DBus            : out std_logic_vector(0 to 31);
        TC_errAck          : out std_logic;
        TC_retry           : out std_logic;
        TC_toutSup         : out std_logic;
        TC_xferAck         : out std_logic;

        -- TC signals
        CaptureTrig0       : in  std_logic;
        CaptureTrig1       : in  std_logic;
        GenerateOut0       : out std_logic;
        GenerateOut1       : out std_logic;
        PWM0               : out std_logic;
        Interrupt          : out std_logic;
        Freeze             : in  std_logic
    );

    -- Fan-out attributes for XST
    attribute MAX_FANOUT                : string;
    attribute MAX_FANOUT of OPB_Clk     : signal is "10000";
    attribute MAX_FANOUT of OPB_Rst     : signal is "10000";

    -- PSFUtil MPD attributes
    attribute IP_GROUP                  : string;
    attribute IP_GROUP of opb_timer     : entity is "LOGICORE";

    attribute MIN_SIZE                  : string;
    attribute MIN_SIZE of C_BASEADDR    : constant is "0x1F";

    attribute SIGIS                     : string;
    attribute SIGIS of OPB_Clk          : signal is "Clk";
    attribute SIGIS of OPB_Rst          : signal is "Rst";
    attribute SIGIS of Interrupt        : signal is "INTR_LEVEL_HIGH";

end entity OPB_Timer;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture IMP of OPB_Timer is

function Addr_Bits (x,y : std_logic_vector(0 to C_OPB_AWIDTH-1)) return integer is
  variable addr_nor : std_logic_vector(0 to C_OPB_AWIDTH-1);
begin
  addr_nor := x xor y;
  for i in 0 to C_OPB_AWIDTH-1 loop
    if addr_nor(i)='1' then return i;
    end if;
  end loop;
  return(C_OPB_AWIDTH);
end function Addr_Bits;

function Integer_to_Boolean (x: integer) return boolean is
begin
  if x=0 then return false;
  else return true;
  end if;
end function Integer_to_Boolean;

-- Address decode signals
signal tc_Select            : std_logic;
signal opb_ABus_Reg         : std_logic_vector(0 to 31);
signal opb_DBus_Reg         : std_logic_vector(0 to 31);
signal opb_BE_Reg           : std_logic_vector(0 to 3);
signal opb_RNW_Reg          : std_logic;
signal opb_select_Reg       : std_logic;
signal opb_seqAddr_Reg      : std_logic;

constant C_AB             : integer := Addr_Bits(C_HIGHADDR,C_BASEADDR);

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------

begin -- architecture IMP

  -----------------------------------------------------------------------------
  -- Register all the OPB input signals
  -----------------------------------------------------------------------------
  WRDBUS_FF_GENERATE: for i in OPB_DWIDTH_TYPE'range generate
    WRDBUS_FF_I: FDR
    port map (
      Q  => opb_DBus_Reg(i), -- [out]
      C  => OPB_Clk,         -- [in]
      D  => OPB_DBus(i),     -- [in]
      R  => OPB_Rst          -- [in]
    );
  end generate WRDBUS_FF_GENERATE;

  ABUS_FF_GENERATE: for i in OPB_AWIDTH_TYPE'range generate
    ABUS_FF_I: FDR
    port map (
      Q  => opb_ABus_Reg(i),   -- [out]
      C  => OPB_Clk,           -- [in]
      D  => OPB_ABus(i),       -- [in]
      R  => OPB_Rst            -- [in]
    );
  end generate ABUS_FF_GENERATE;

  BE_FF_GENERATE: for i in OPB_BEWIDTH_TYPE'range generate
    BE_FF_I: FDR
    port map (
      Q  => opb_BE_Reg(i),  -- [out]
      C  => OPB_Clk,        -- [in]
      D  => OPB_BE(i),      -- [in]
      R  => OPB_Rst         -- [in]
    );
  end generate BE_FF_GENERATE;

  RNW_FF_I: FDR
  port map (
    Q  => opb_RNW_Reg,      -- [out]
    C  => OPB_Clk,          -- [in]
    D  => OPB_RNW,          -- [in]
    R  => OPB_Rst           -- [in]
  );
  SELECT_FF_I: FDR
  port map (
    Q  => opb_select_Reg,   -- [out]
    C  => OPB_Clk,          -- [in]
    D  => OPB_select,       -- [in]
    R  => OPB_Rst           -- [in]
  );
  SEQADDR_FF_I: FDR
  port map (
    Q  => opb_seqAddr_Reg,  -- [out]
    C  => OPB_Clk,          -- [in]
    D  => OPB_seqAddr,      -- [in]
    R  => OPB_Rst           -- [in]
  );

  -----------------------------------------------------------------------------
  -- Address decode and register selects
  -----------------------------------------------------------------------------

  TC_Select_I: entity proc_common_v1_00_b.pselect
    generic map (
      C_AB     => C_AB,
      C_AW     => C_OPB_AWIDTH,
      C_BAR    => C_BASEADDR )
    port map (
      A        => opb_ABus_Reg,    -- [in]
      AValid   => opb_Select_Reg,  -- [in]
      CS       => tc_Select);      -- [out]

  TC_CORE_I: entity opb_timer_v1_00_b.TC_Core
    generic map (
      C_FAMILY           => C_FAMILY,
      C_COUNT_WIDTH      => C_COUNT_WIDTH,
      C_ONE_TIMER_ONLY   => C_ONE_TIMER_ONLY,
      C_OPB_DWIDTH       => C_OPB_DWIDTH,
      C_OPB_AWIDTH       => C_OPB_AWIDTH,
      C_TRIG0_ASSERT     => C_TRIG0_ASSERT,
      C_TRIG1_ASSERT     => C_TRIG1_ASSERT,
      C_GEN0_ASSERT      => C_GEN0_ASSERT,
      C_GEN1_ASSERT      => C_GEN1_ASSERT
      )

    port map (
      -- OPB signals
      OPB_Clk            => OPB_Clk,         --[in]
      OPB_Rst            => OPB_Rst,         --[in]
      OPB_ABus_Reg       => opb_ABus_Reg,    --[in]
      OPB_BE_Reg         => opb_BE_Reg,      --[in]
      OPB_DBus_Reg       => opb_DBus_Reg,    --[in]
      OPB_RNW_Reg        => opb_RNW_Reg,     --[in]
      TC_DBus            => TC_DBus,        --[out]
      TC_errAck          => TC_errAck,      --[out]
      TC_retry           => TC_retry,       --[out]
      TC_toutSup         => TC_toutSup,     --[out]
      TC_xferAck         => TC_xferAck,     --[out]

      -- TC signals
      CaptureTrig0       => CaptureTrig0,    --[in]
      CaptureTrig1       => CaptureTrig1,    --[in]
      GenerateOut0       => GenerateOut0,    --[out]
      GenerateOut1       => GenerateOut1,    --[out]
      PWM0               => PWM0,            --[out]
      Interrupt          => Interrupt,       --[out]
      Freeze             => Freeze,          --[in]

      -- Peripheral Select address decode
      TC_Select          => tc_Select       --[in]
      );

end architecture IMP;
