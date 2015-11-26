-------------------------------------------------------------------------------
-- $Id: lmb_bram_if_cntlr.vhd,v 1.1 2002/12/06 16:15:36 goran Exp $
-------------------------------------------------------------------------------
-- lmb_bram_if_cntlr.vhd
-------------------------------------------------------------------------------
--
--                  ****************************
--                  ** Copyright Xilinx, Inc. **
--                  ** All rights reserved.   **
--                  ****************************
--
-------------------------------------------------------------------------------
-- Filename:        lmb_bram_if_cntlr.vhd
--
-- Description:
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--              lmb_bram_if_cntlr.vhd
--
-------------------------------------------------------------------------------
-- Author:          goran
-- Revision:        $Revision: 1.1 $
-- Date:            $Date: 2002/12/06 16:15:36 $
--
-- History:
--   paulo  2002-07-08    First Version
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY proc_common_v1_00_c;
USE proc_common_v1_00_c.pselect_mask;

ENTITY lmb_bram_if_cntlr IS
  GENERIC (
    C_HIGHADDR : STD_LOGIC_VECTOR(0 to 31) := X"00000000";
    C_BASEADDR : STD_LOGIC_VECTOR(0 to 31) := X"FFFFFFFF";
    C_MASK         : STD_LOGIC_VECTOR(0 to 31) := X"00800000";
    C_LMB_AWIDTH   : INTEGER                   := 32;
    C_LMB_DWIDTH   : INTEGER                   := 32
    );
  PORT (
    LMB_Clk : IN STD_LOGIC := '0';
    LMB_Rst : IN STD_LOGIC := '0';

    -- Instruction Bus
    LMB_ABus        : IN  STD_LOGIC_VECTOR(0 TO C_LMB_AWIDTH-1);
    LMB_WriteDBus   : IN  STD_LOGIC_VECTOR(0 TO C_LMB_DWIDTH-1);
    LMB_AddrStrobe  : IN  STD_LOGIC;
    LMB_ReadStrobe  : IN  STD_LOGIC;
    LMB_WriteStrobe : IN  STD_LOGIC;
    LMB_BE          : IN  STD_LOGIC_VECTOR(0 TO (C_LMB_DWIDTH/8 - 1));
    Sl_DBus      : OUT STD_LOGIC_VECTOR(0 TO C_LMB_DWIDTH-1);
    Sl_Ready     : OUT STD_LOGIC;

    -- ports to memory block
    BRAM_Rst_A  : OUT STD_LOGIC;
    BRAM_Clk_A  : OUT STD_LOGIC;
    BRAM_Addr_A : OUT STD_LOGIC_VECTOR(0 TO C_LMB_AWIDTH-1);
    BRAM_EN_A   : OUT STD_LOGIC;
    BRAM_WEN_A  : OUT STD_LOGIC_VECTOR(0 TO C_LMB_DWIDTH/8-1);
    BRAM_Dout_A : OUT STD_LOGIC_VECTOR(0 TO C_LMB_DWIDTH-1);
    BRAM_Din_A  : IN  STD_LOGIC_VECTOR(0 TO C_LMB_DWIDTH-1)
    );
END lmb_bram_if_cntlr;

ARCHITECTURE imp OF lmb_bram_if_cntlr IS

--------------------------------------------------------------------------------
-- component declarations
--------------------------------------------------------------------------------

COMPONENT pselect_mask IS
GENERIC (
      C_AW   : INTEGER                   := 32;
      C_BAR  : STD_LOGIC_VECTOR(0 TO 31) := X"00000000";
      C_MASK : STD_LOGIC_VECTOR(0 TO 31) := X"00800000");
PORT (
      A     : in  STD_LOGIC_VECTOR(0 TO 31);
      CS    : out STD_LOGIC;
      Valid : in  STD_LOGIC);
END COMPONENT;

--------------------------------------------------------------------------------
-- internal signals
--------------------------------------------------------------------------------

  SIGNAL lmb_select : STD_LOGIC;

  SIGNAL lmb_select_1 : STD_LOGIC;

  SIGNAL lmb_we : STD_LOGIC_VECTOR(0 TO 3);

BEGIN  -- architecture IMP

--------------------------------------------------------------------------------
-- Top-level port assignments

-- Port A
BRAM_Rst_A  <= '0';
BRAM_Clk_A  <= LMB_Clk;
BRAM_Addr_A <= LMB_ABus;
BRAM_EN_A   <= '1';
BRAM_WEN_A  <= lmb_we;
BRAM_Dout_A <= LMB_WriteDBus;
Sl_DBus  <= BRAM_Din_A;

-----------------------------------------------------------------------------
-- Handling the LMB bus interface
-----------------------------------------------------------------------------

Ready_Handling : PROCESS (LMB_Clk, LMB_Rst) IS
BEGIN  -- PROCESS Ready_Handling
    IF (LMB_Rst = '1') THEN
      Sl_Ready <= '0';
    ELSIF (LMB_Clk'EVENT AND LMB_Clk = '1') THEN  -- rising clock edge
      Sl_Ready <= LMB_AddrStrobe AND lmb_select;
    END IF;
END PROCESS Ready_Handling;

LMB_Select_Handling : PROCESS (LMB_Clk, LMB_Rst) IS
BEGIN  -- PROCESS LMB_Select_Handling
    IF (LMB_Rst = '1') THEN
      lmb_select_1 <= '0';
    ELSIF (LMB_Clk'EVENT AND LMB_Clk = '1') THEN  -- rising clock edge
      lmb_select_1 <= lmb_select;
    END IF;
END PROCESS LMB_Select_Handling;

lmb_we(0) <= LMB_BE(0) and LMB_WriteStrobe and lmb_select_1;
lmb_we(1) <= LMB_BE(1) and LMB_WriteStrobe and lmb_select_1;
lmb_we(2) <= LMB_BE(2) and LMB_WriteStrobe and lmb_select_1;
lmb_we(3) <= LMB_BE(3) and LMB_WriteStrobe and lmb_select_1;

--------------------------------------------------------------------------------
-- Do the LMB address decoding
--------------------------------------------------------------------------------
pselect_mask_lmb : pselect_mask
generic map (
      C_AW   => LMB_ABus'length,
      C_BAR  => C_BASEADDR,
      C_MASK => C_MASK)
port map (
      A     => LMB_ABus,
      CS    => lmb_select,
      Valid => LMB_AddrStrobe);

END ARCHITECTURE imp;
