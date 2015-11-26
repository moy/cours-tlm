-------------------------------------------------------------------------------
-- $Id: opb_intfc.vhd,v 1.3 2003/06/29 21:38:05 jcanaris Exp $
-------------------------------------------------------------------------------
-- opb_intfc - entity / architecture pair
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
-- Filename:        opb_intfc.vhd
-- Version:         v1.00c
-- Description:     Include a meaningful description of your file. Multi-line
--                  descriptions should align with each other
-- 
-------------------------------------------------------------------------------
-- Structure:
-- 
--              intc.vhd
--                mb_intc_top.vhd
--                  opb_intfc.vhd
-- 
-------------------------------------------------------------------------------
-- Author:      jam
-- History:
--  jam      08/01/2001  first version
--  jam      08/06/2001  incorporated unisim versions of *_reg
--  jam      08/10/2001  changed to target_family_type in common
--  jam      11/05/2001  changed plain_reg, load_reg, gp_reg, and be_reg
--                       component instantiations to generates using xilinx
--                       primitive registers
--  jam      12/04/2001  change to C_FAMILY
--  jam      11/04/2002  roll to rev c
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

library ieee;
library intc_core_v1_00_c;
library proc_common_v1_00_a;
library unisim;
use ieee.std_logic_1164.all;
use intc_core_v1_00_c.intc_pkg.all;
use proc_common_v1_00_a.pselect;
use proc_common_v1_00_a.Common_Types.all;
use unisim.all;

------------------------------------------------------------------------------
-- Entity
------------------------------------------------------------------------------

entity opb_intfc is
  generic
  (
    C_FAMILY        : string   := "virtex2";
    C_Y             : integer  := 0;
    C_X             : integer  := 0;
    C_U_SET         : string   := "intc";
    C_INTC_BASEADDR : std_logic_vector(0 to ADDR_SIZE - 1) := X"00000000";
    C_BASE_NUM_BITS : positive := 4;
    C_OPB_AWIDTH    : positive := ADDR_SIZE;
    C_OPB_DWIDTH    : positive := WORD_SIZE
  );
  port
  (
    Clk          : in  std_logic;
    Rst          : in  std_logic;
     -- OPB bus interface
    OPB_ABus     : in  std_logic_vector(0 to C_OPB_AWIDTH - 1);
    OPB_BE       : in  std_logic_vector(0 to (C_OPB_DWIDTH / 8) - 1);
    OPB_DBus     : in  std_logic_vector(0 to C_OPB_DWIDTH - 1);
    OPB_RNW      : in  std_logic;
    OPB_select   : in  std_logic;
    OPB_seqAddr  : in  std_logic;
    IntC_DBus    : out std_logic_vector(0 to C_OPB_DWIDTH - 1);
    IntC_xferAck : out std_logic;
    IntC_errAck  : out std_logic;
    IntC_retry   : out std_logic;
    IntC_toutSup : out std_logic;
     -- intc_core interface
    Reg_addr     : out reg_sel_type;
    Intc_rd      : out std_logic;
    Intc_wr      : out std_logic;
    Rd_data      : in  std_logic_vector(C_OPB_DWIDTH - 1 downto 0);
    Wr_data      : out std_logic_vector(C_OPB_DWIDTH - 1 downto 0)
  );

end opb_intfc;

------------------------------------------------------------------------------
-- Architecture
------------------------------------------------------------------------------

architecture imp of opb_intfc is

  signal byte_enables   : std_logic_vector(0 to (C_OPB_DWIDTH / 8) - 1);
  signal intc_addr      : std_logic_vector(0 to C_OPB_AWIDTH - 1);
  signal rnw_reg        : std_logic;
  signal intc_rd_qual   : std_logic;
  signal select_reg     : std_logic;
  signal intc_select    : std_logic;
  signal rst_intc_dbus  : std_logic;
  signal valid_access   : std_logic;
  signal xfer_Ack       : std_logic;
  signal xfer_Ack_dly   : std_logic;
  signal err_ack        : std_logic;
  signal error_detected : std_logic;
  signal data_in        : std_logic_vector(0 to C_OPB_DWIDTH - 1);
  signal data_out       : std_logic_vector(0 to C_OPB_DWIDTH - 1);
  
  component fdr
    port
    (
      Q : out std_logic := 'Z';
      C : in std_logic;
      D : in std_logic;
      R : in std_logic
    );
  end component;

  component fdre
     port
     (
       Q  : out std_logic;
       D  : in std_logic;
       C  : in std_logic;
       CE : in std_logic;
       R  : in std_logic
     );
  end component;

  component pselect
    generic
    (
      C_AB  : integer          := 4;
      C_AW  : integer          := 32;
      C_BAR : std_logic_vector := X"FFFFFFFF"
    );
    port
    (
      A      : in  std_logic_vector(0 to C_AW - 1);
      AValid : in  std_logic;
      CS     : out std_logic
    );
  end component;

-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------

  assert C_OPB_DWIDTH <= 32
    report "OPB data bus width must be less than or equal to 32"
    severity ERROR;

  LE_2_BE_CONV:
  process(data_out,Rd_data)
  begin
    for i in 0 to WORD_SIZE - 1
    loop
      Wr_data(i) <= data_out(WORD_SIZE - 1 - i);
      data_in(WORD_SIZE - 1 - i) <= Rd_data(i);
    end loop;
  end process LE_2_BE_CONV;

  OPB_ABUS_REG_GEN:
  for i in OPB_ABus'range
  generate
    OPB_ABUS_REG_BIT_I : fdr
      port map
      (
        Q => intc_addr(i),
        D => OPB_ABus(i),
        C => Clk,
        R => Rst
      );
  end generate OPB_ABUS_REG_GEN;

  OPB_DBUS_REG_GEN:
  for i in OPB_DBus'range
  generate
    OPB_DBUS_REG_BIT_I : fdr
      port map
      (
        Q => data_out(i),
        D => OPB_DBus(i),
        C => Clk,
        R => Rst
      );
  end generate OPB_DBUS_REG_GEN;

  INTC_DBUS_REG_GEN:
  for i in data_in'range
  generate
    INTC_DBUS_BIT_I : fdre
      port map
      (
        Q  => IntC_DBus(i),
        D  => data_in(i),
        C  => Clk,
        CE => intc_rd_qual,
        R  => rst_intc_dbus
      );
  end generate INTC_DBUS_REG_GEN;

  XFER_ACK_I: fdr
    port map
    (
      Q => xfer_Ack,
      D => intc_select,
      C => Clk,
      R => rst_intc_dbus
    );

  ERR_ACK_I: fdr
    port map
    (
      Q => err_ack,
      D => error_detected,
      C => Clk,
      R => rst_intc_dbus
    );

  XFER_ACK_DLY_I: fdr
    port map
    (
      Q => xfer_Ack_dly,
      D => xfer_Ack,
      C => Clk,
      R => Rst
    );

  BE_REG_GEN:
  for i in OPB_BE'range
  generate
    BE_REG_BIT_I : fdr
      port map
      (
        Q => byte_enables(i),
        D => OPB_BE(i),
        C => Clk,
        R => Rst
      );
  end generate BE_REG_GEN;

  SELECT_REG_I : fdr
    port map
    (
      Q => select_reg,
      D => OPB_Select,
      C => Clk,
      R => Rst
    );

  RNW_REG_I : fdr
    port map
    (
      Q => rnw_reg,
      D => OPB_RNW,
      C => Clk,
      R => Rst
    );

  ADDR_DECODE_I: pselect
    generic map
    (
      C_AB     => C_BASE_NUM_BITS,
      C_AW     => WORD_SIZE,
      C_BAR    => C_INTC_BASEADDR
    )
    port map
    (
      A      => intc_addr,
      AValid => select_reg,
      CS     => intc_select
    );

  BYTE_VAL_ACCESS_GEN:
  if C_OPB_DWIDTH = 8
  generate
    valid_access <= byte_enables(0) and intc_select;
  end generate BYTE_VAL_ACCESS_GEN;

  HALFWORD_VAL_ACCESS_GEN:
  if C_OPB_DWIDTH = 16
  generate
    valid_access <= byte_enables(0) and
                    byte_enables(1) and
                    intc_select;
  end generate HALFWORD_VAL_ACCESS_GEN;

  FULLWORD_VAL_ACCESS_GEN:
  if C_OPB_DWIDTH = 32
  generate
    valid_access <= byte_enables(0) and
                    byte_enables(1) and
                    byte_enables(2) and
                    byte_enables(3) and
                    intc_select;
  end generate FULLWORD_VAL_ACCESS_GEN;

  INVALID_ACCESS_GEN:
  if C_OPB_DWIDTH /= 8  and C_OPB_DWIDTH /= 16 and C_OPB_DWIDTH /= 32
  generate
    valid_access <= '0';
  end generate INVALID_ACCESS_GEN;

  IntC_xferAck <= xfer_Ack;

  rst_intc_dbus <= xfer_Ack or xfer_Ack_dly or Rst;

  IntC_errAck  <= err_ack;

  error_detected <= '1' when intc_select = '1' and valid_access = '0'
                        else '0';

  IntC_toutSup <= '0';
  IntC_retry   <= '0';

   -- for now always assume 32-bit boundary for register accesses
  Reg_addr <= intc_addr(C_OPB_AWIDTH - 5 to C_OPB_AWIDTH - 3);

  intc_rd_qual <= valid_access and rnw_reg;

  Intc_rd <= intc_rd_qual;
  Intc_wr <= valid_access and not rnw_reg;

end imp;

