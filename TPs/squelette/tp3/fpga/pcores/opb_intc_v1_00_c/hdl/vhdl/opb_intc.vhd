-------------------------------------------------------------------------------
-- $Id: opb_intc.vhd,v 1.3 2004/11/23 00:59:12 jcanaris Exp $
-------------------------------------------------------------------------------
-- opb_intc - entity / architecture pair
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
-- Filename:        opb_intc.vhd
-- Version:         v1.00c
-- Description:     opb bus intc
--
-------------------------------------------------------------------------------
-- Structure:
--
--                  opb_intc.vhd  (wrapper for top level)
--
-------------------------------------------------------------------------------
-- Author:      jam
-- History:
--  jam      11/16/2001  first version
--  jam      12/04/2001  change to C_FAMILY
--  jam      06/17/2002  changed to intc_core v1.00b
--  jam      06/24/2002  changed C_DWIDTH in intc_core declaration to positive
--  jam      11/04/2002  roll to rev c
--  LCW	Oct 18, 2004	  -- updated for NCSim
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
use ieee.std_logic_1164.all;
use intc_core_v1_00_c.intc_pkg.all;

library unisim;
use unisim.vcomponents.all;

library opb_intc_v1_00_c;


------------------------------------------------------------------------------
-- Entity
------------------------------------------------------------------------------

entity opb_intc is
  generic
  (
    C_FAMILY : string  := "virtex2";
    C_Y      : integer := 0;
    C_X      : integer := 0;
    C_U_SET  : string  := "intc";

    C_OPB_AWIDTH  : integer := WORD_SIZE;
    C_OPB_DWIDTH  : integer := WORD_SIZE;

    C_BASEADDR : std_logic_vector := X"70800000";
    C_HIGHADDR : std_logic_vector := X"7FFFFFFF";

    C_NUM_INTR_INPUTS : integer := 2;

    C_KIND_OF_INTR : std_logic_vector(WORD_SIZE - 1 downto 0) :=
                                           "11111111111111111111111111111111";
    C_KIND_OF_EDGE : std_logic_vector(WORD_SIZE - 1 downto 0) :=
                                           "11111111111111111111111111111111";
    C_KIND_OF_LVL  : std_logic_vector(WORD_SIZE - 1 downto 0) :=
                                           "11111111111111111111111111111111";

    C_HAS_IPR : integer := 1;
    C_HAS_SIE : integer := 1;
    C_HAS_CIE : integer := 1;
    C_HAS_IVR : integer := 1;

    C_IRQ_IS_LEVEL : integer   := 1;
    C_IRQ_ACTIVE   : std_logic := '1'

  );
  port
  (
    OPB_Clk      : in  std_logic;
    OPB_Rst      : in  std_logic;
    OPB_select   : in  std_logic;
    OPB_ABus     : in  std_logic_vector(0 to C_OPB_AWIDTH - 1);
    OPB_RNW      : in  std_logic;
    OPB_BE       : in  std_logic_vector(0 to C_OPB_DWIDTH/8 - 1);
    OPB_DBus     : in  std_logic_vector(0 to C_OPB_DWIDTH - 1);
    IntC_DBus    : out std_logic_vector(0 to C_OPB_DWIDTH - 1);
    IntC_xferAck : out std_logic;
    IntC_errAck  : out std_logic;
    OPB_seqAddr  : in  std_logic;
    IntC_retry   : out std_logic;
    IntC_toutSup : out std_logic;
    Intr         : in  std_logic_vector(C_NUM_INTR_INPUTS - 1 downto 0);
    Irq          : out std_logic
  );
end opb_intc;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture imp of opb_intc is

-------------------------------------------------------------------------------
-- Component Declarations
-------------------------------------------------------------------------------

  constant BASE_NUM_BITS : integer := Addr_Bits(C_BASEADDR,C_HIGHADDR);

  signal register_address : reg_sel_type;
  signal intc_read        : std_logic;
  signal intc_write       : std_logic;
  signal read_data        : std_logic_vector(C_OPB_DWIDTH - 1 downto 0);
  signal write_data       : std_logic_vector(C_OPB_DWIDTH - 1 downto 0);

begin

-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------
INTC_CORE_I : entity intc_core_v1_00_c.intc_core
  generic map
  (
    C_FAMILY          => C_FAMILY,
    C_Y               => C_Y,
    C_X               => C_X,
    C_U_SET           => C_U_SET,
    C_DWIDTH          => C_OPB_DWIDTH,
    C_NUM_INTR_INPUTS => C_NUM_INTR_INPUTS,
    C_KIND_OF_INTR    => C_KIND_OF_INTR,
    C_KIND_OF_EDGE    => C_KIND_OF_EDGE,
    C_KIND_OF_LVL     => C_KIND_OF_LVL,
    C_HAS_IPR         => int2bool(C_HAS_IPR),
    C_HAS_SIE         => int2bool(C_HAS_SIE),
    C_HAS_CIE         => int2bool(C_HAS_CIE),
    C_HAS_IVR         => int2bool(C_HAS_IVR),
    C_IRQ_IS_LEVEL    => int2bool(C_IRQ_IS_LEVEL),
    C_IRQ_ACTIVE      => C_IRQ_ACTIVE
  )
  port map
  (
    Clk      => OPB_Clk,
    Rst      => OPB_Rst,
    Intr     => Intr,
    Irq      => Irq,
    Reg_addr => register_address,
    Valid_rd => intc_read,
    Valid_wr => intc_write,
    Wr_data  => write_data,
    Rd_data  => read_data
  );

OPB_INTFC_I : entity opb_intc_v1_00_c.opb_intfc
  generic map
  (
    C_FAMILY        => C_FAMILY,
    C_Y             => C_Y,
    C_X             => C_X,
    C_U_SET         => C_U_SET,
    C_INTC_BASEADDR => C_BASEADDR,
    C_BASE_NUM_BITS => BASE_NUM_BITS,
    C_OPB_AWIDTH    => C_OPB_AWIDTH,
    C_OPB_DWIDTH    => C_OPB_DWIDTH
  )
  port map
  (
    Clk          => OPB_Clk,
    Rst          => OPB_Rst,
    OPB_ABus     => OPB_ABus,
    OPB_BE       => OPB_BE,
    OPB_DBus     => OPB_DBus,
    OPB_RNW      => OPB_RNW,
    OPB_select   => OPB_select,
    OPB_seqAddr  => OPB_seqAddr,
    IntC_DBus    => IntC_DBus,
    IntC_xferAck => IntC_xferAck,
    IntC_errAck  => IntC_errAck,
    IntC_retry   => IntC_retry,
    IntC_toutSup => IntC_toutSup,
    Reg_addr     => register_address,
    Intc_rd      => intc_read,
    Intc_wr      => intc_write,
    Rd_data      => read_data,
    Wr_data      => write_data
  );

end imp;
