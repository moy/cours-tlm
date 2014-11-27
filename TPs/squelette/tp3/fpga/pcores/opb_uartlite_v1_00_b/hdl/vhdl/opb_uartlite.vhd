-------------------------------------------------------------------------------
-- $Id: opb_uartlite.vhd,v 1.2 2003/01/16 22:32:37 tise Exp $
-------------------------------------------------------------------------------
-- opb_uartlite.vhd
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
-- Filename:        opb_uartlite.vhd
--
-- Description:     
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--              opb_uartlite.vhd
--
-------------------------------------------------------------------------------
-- Author:          goran
-- Revision:        $Revision: 1.2 $
-- Date:            $Date: 2003/01/16 22:32:37 $
--
-- History:
--   goran  2001-05-11    First Version
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
library IEEE;
use IEEE.std_logic_1164.all;

entity OPB_UARTLITE is
  generic (
    C_OPB_AWIDTH : integer                   := 32;
    C_OPB_DWIDTH : integer                   := 32;
    C_BASEADDR   : std_logic_vector(0 to 31) := X"FFFF_8000";
    C_HIGHADDR   : std_logic_vector          := X"FFFF_80FF";
    C_DATA_BITS  : integer range 5 to 8      := 8;
    C_CLK_FREQ   : integer                   := 125_000_000;
    C_BAUDRATE   : integer                   := 19_200;
    C_USE_PARITY : integer                   := 0;
    C_ODD_PARITY : integer                   := 1
    );
  port (
    -- Global signals
    OPB_Clk : in std_logic;
    OPB_Rst : in std_logic;

    -- OPB signals
    OPB_ABus    : in std_logic_vector(0 to 31);
    OPB_BE      : in std_logic_vector(0 to 3);
    OPB_RNW     : in std_logic;
    OPB_select  : in std_logic;
    OPB_seqAddr : in std_logic;
    OPB_DBus    : in std_logic_vector(0 to 31);

    UART_DBus    : out std_logic_vector(0 to 31);
    UART_errAck  : out std_logic;
    UART_retry   : out std_logic;
    UART_toutSup : out std_logic;
    UART_xferAck : out std_logic;

    -- UART signals
    Interrupt : out std_logic;
    RX        : in  std_logic;
    TX        : out std_logic
    );

end entity OPB_UARTLITE;

library Common_v1_00_a;
use Common_v1_00_a.pselect;

library unisim;
use unisim.all;

library opb_uartlite_v1_00_b;
use opb_uartlite_v1_00_b.opb_uartlite_core;

architecture IMP of OPB_UARTLITE is

  component pselect is
    generic (
      C_AB  : integer;
      C_AW  : integer;
      C_BAR : std_logic_vector);
    port (
      A      : in  std_logic_vector(0 to C_AW-1);
      AValid : in  std_logic;
      ps     : out std_logic);
  end component pselect;

  component OPB_UARTLITE_Core is
    generic (
      C_DATA_BITS  : integer range 5 to 8;
      C_CLK_FREQ   : integer;
      C_BAUDRATE   : integer;
      C_USE_PARITY : integer;
      C_ODD_PARITY : integer);
    port (
      Clk   : in std_logic;
      Reset : in std_logic;

      UART_CS : in std_logic;

      -- OPB signals
      OPB_ABus : in std_logic_vector(0 to 1);
      OPB_RNW  : in std_logic;
      OPB_DBus : in std_logic_vector(0 to 7);

      SIn_xferAck : out std_logic;
      SIn_DBus    : out std_logic_vector(0 to 7);

      -- UART signals
      RX        : in  std_logic;
      TX        : out std_logic;
      Interrupt : out std_logic);
  end component OPB_UARTLITE_Core;

  function Addr_Bits (x, y : std_logic_vector(0 to C_OPB_AWIDTH-1)) return integer is
    variable addr_nor : std_logic_vector(0 to C_OPB_AWIDTH-1);
  begin
    addr_nor := x xor y;
    for i in 0 to C_OPB_AWIDTH-1 loop
      if addr_nor(i) = '1' then return i;
      end if;
    end loop;
    return(C_OPB_AWIDTH);
  end function Addr_Bits;

  constant C_AB : integer := Addr_Bits(C_HIGHADDR, C_BASEADDR);

  signal uart_CS : std_logic;
  
begin  -- architecture IMP


  -----------------------------------------------------------------------------
  -- Handling the OPB bus interface
  -----------------------------------------------------------------------------

  -- Do the OPB address decoding
  pselect_I : pselect
    generic map (
      C_AB  => C_AB,                    -- [integer]
      C_AW  => C_OPB_AWIDTH,            -- [integer]
      C_BAR => C_BASEADDR)              -- [std_logic_vector]
    port map (
      A      => OPB_ABus,               -- [in  std_logic_vector(0 to C_AW-1)]
      AValid => OPB_select,             -- [in  std_logic]
      ps     => uart_CS);               -- [out std_logic]


  UART_DBus(0 to C_OPB_DWIDTH-9) <= (others => '0');
  UART_errAck                    <= '0';
  UART_retry                     <= '0';
  UART_toutSup                   <= '0';

  -----------------------------------------------------------------------------
  -- Instanciating the UART core
  -----------------------------------------------------------------------------
  OPB_UARTLITE_Core_I : OPB_UARTLITE_Core
    generic map (
      C_DATA_BITS  => C_DATA_BITS,      -- [integer range 5 to 8]
      C_CLK_FREQ   => C_CLK_FREQ,       -- [integer]
      C_BAUDRATE   => C_BAUDRATE,       -- [integer]
      C_USE_PARITY => C_USE_PARITY,     -- [integer]
      C_ODD_PARITY => C_ODD_PARITY)     -- [integer]
    port map (
      Clk         => OPB_Clk,           -- [in  std_logic]
      Reset       => OPB_Rst,           -- [in  std_logic]
      UART_CS     => uart_CS,           -- [in  std_logic]
      OPB_ABus    => OPB_ABus(C_OPB_AWIDTH-4 to C_OPB_AWIDTH-3),  -- [in  std_logic_vector(0 to 1)]
      OPB_RNW     => OPB_RNW,           -- [in  std_logic]
      OPB_DBus    => OPB_DBus(C_OPB_DWIDTH-8 to C_OPB_DWIDTH-1),  -- [in  std_logic_vector(0 to 7)]
      SIn_xferAck => UART_xferAck,      -- [out std_logic]
      SIn_DBus    => UART_DBus(C_OPB_DWIDTH-8 to C_OPB_DWIDTH-1),  -- [out std_logic_vector(0 to 7)]
      RX          => RX,                -- [in  std_logic]
      TX          => TX,                -- [out std_logic]
      Interrupt   => Interrupt);        -- [out std_logic]


end architecture IMP;



