-------------------------------------------------------------------------------
-- $Id: opb_uartlite_core.vhd,v 1.3 2003/08/04 17:20:53 goran Exp $
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
-- Revision:        $Revision: 1.3 $
-- Date:            $Date: 2003/08/04 17:20:53 $
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

entity OPB_UARTLITE_Core is
  generic (
    C_DATA_BITS  : integer range 5 to 8 := 8;
    C_CLK_FREQ   : integer              := 125_000_000;
    C_BAUDRATE   : integer              := 9600;
    C_USE_PARITY : integer              := 1;
    C_ODD_PARITY : integer              := 1
    );
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
    Interrupt : out std_logic

    );

end entity OPB_UARTLITE_Core;

library unisim;
use unisim.all;

library opb_uartlite_v1_00_b;
use opb_uartlite_v1_00_b.Baud_Rate;
use opb_uartlite_v1_00_b.OPB_UARTLITE_RX;
use opb_uartlite_v1_00_b.OPB_UARTLITE_TX;

architecture IMP of OPB_UARTLITE_Core is

  component Baud_Rate is
    generic (
      C_RATIO      : integer;           -- The ratio between clk and the asked
                                        -- baudrate multiplied with 16
      C_INACCURACY : integer);          -- The maximum inaccuracy of the clk
    port (
      Clk         : in  std_logic;
      EN_16x_Baud : out std_logic);
  end component Baud_Rate;

  component OPB_UARTLITE_RX is
    generic (
      C_DATA_BITS  : integer range 5 to 8;
      C_USE_PARITY : integer;
      C_ODD_PARITY : integer);
    port (
      Clk         : in std_logic;
      Reset       : in std_logic;
      EN_16x_Baud : in std_logic;

      RX               : in  std_logic;
      Read_RX_FIFO     : in  std_logic;
      Reset_RX_FIFO    : in  std_logic;
      RX_Data          : out std_logic_vector(0 to C_DATA_BITS-1);
      RX_Data_Present  : out std_logic;
      RX_BUFFER_FULL   : out std_logic;
      RX_Frame_Error   : out std_logic;
      RX_Overrun_Error : out std_logic;
      RX_Parity_Error  : out std_logic);
  end component OPB_UARTLITE_RX;

  component OPB_UARTLITE_TX is
    generic (
      C_DATA_BITS  : integer range 5 to 8;
      C_USE_PARITY : integer;
      C_ODD_PARITY : integer);
    port (
      Clk         : in std_logic;
      Reset       : in std_logic;
      EN_16x_Baud : in std_logic;

      TX              : out std_logic;
      Write_TX_FIFO   : in  std_logic;
      Reset_TX_FIFO   : in  std_logic;
      TX_Data         : in  std_logic_vector(0 to C_DATA_BITS-1);
      TX_Buffer_Full  : out std_logic;
      TX_Buffer_Empty : out std_logic);
  end component OPB_UARTLITE_TX;

  component FDRE is
    port (
      Q  : out std_logic;
      C  : in  std_logic;
      CE : in  std_logic;
      D  : in  std_logic;
      R  : in  std_logic);
  end component FDRE;

  component FDR is
    port (Q : out std_logic;
          C : in  std_logic;
          D : in  std_logic;
          R : in  std_logic);
  end component FDR;

  signal en_16x_Baud : std_logic;

  constant RX_FIFO_ADR    : std_logic_vector(0 to 1) := "00";
  constant TX_FIFO_ADR    : std_logic_vector(0 to 1) := "01";
  constant STATUS_REG_ADR : std_logic_vector(0 to 1) := "10";
  constant CTRL_REG_ADR   : std_logic_vector(0 to 1) := "11";

  -- Read Only
  signal status_Reg : std_logic_vector(0 to 7);
  -- bit 7 rx_Data_Present
  -- bit 6 rx_Buffer_Full
  -- bit 5 tx_Buffer_Empty
  -- bit 4 tx_Buffer_Full
  -- bit 3 enable_interrupts
  -- bit 2 Overrun Error
  -- bit 1 Frame Error
  -- bit 0 Parity Error (If C_USE_PARITY is true, otherwise '0')

  -- Write Only
  -- Control Register
  -- bit 0-2 Dont'Care
  -- bit 3   enable_interrupts
  -- bit 4-5 Dont'Care
  -- bit 6   Reset_RX_FIFO
  -- bit 7   Reset_TX_FIFO

  signal enable_interrupts : std_logic;
  signal read_RX_FIFO      : std_logic;
  signal reset_RX_FIFO     : std_logic;

  signal rx_Data          : std_logic_vector(0 to C_DATA_BITS-1);
  signal rx_Data_Present  : std_logic;
  signal rx_BUFFER_FULL   : std_logic;
  signal rx_Frame_Error   : std_logic;
  signal rx_Overrun_Error : std_logic;
  signal rx_Parity_Error  : std_logic;

  signal clr_Status : std_logic;

  signal write_TX_FIFO   : std_logic;
  signal reset_TX_FIFO   : std_logic;
  signal tx_BUFFER_FULL  : std_logic;
  signal tx_Buffer_Empty : std_logic;

  signal tx_Buffer_Empty_Pre : std_logic;

  signal xfer_Ack     : std_logic;
  signal sin_Dbus_i : std_logic_vector(0 to 7);

  constant RATIO : integer := C_CLK_FREQ / (16 * C_BAUDRATE);

  signal uart_CS_1 : std_logic;         -- Active as long as UART_CS is active
  signal uart_CS_2 : std_logic;         -- Active only 1 clock cycle during an
  signal uart_CS_3 : std_logic;         -- Active only 1 clock cycle during an
                                        -- access

  signal opb_RNW_1 : std_logic;
  
begin  -- architecture IMP

  uart_CS_1_DFF : FDR
    port map (
      Q => uart_CS_1,                   -- [out std_logic]
      C => Clk,                         -- [in  std_logic]
      D => UART_CS,                     -- [in  std_logic]
      R => xfer_Ack);                   -- [in std_logic]

  uart_CS_2_DFF: process (Clk, Reset) is
  begin  -- process uart_CS_2_DFF
    if Reset = '1' then                 -- asynchronous reset (active high)
      uart_CS_2 <= '0';
      uart_CS_3 <= '0';
      opb_RNW_1 <= '0';
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      uart_CS_2 <= uart_CS_1 and not uart_CS_2 and not uart_CS_3;
      uart_CS_3 <= uart_CS_2;
      opb_RNW_1 <= OPB_RNW;
    end if;
  end process uart_CS_2_DFF;
  
  -----------------------------------------------------------------------------
  -- Instanciating the BaudRate module
  -----------------------------------------------------------------------------
  Baud_Rate_I : Baud_Rate
    generic map (
      C_RATIO      => RATIO,            -- [integer]
      C_INACCURACY => 20)               -- [integer]
    port map (
      Clk         => Clk,               -- [in  std_logic]
      EN_16x_Baud => en_16x_Baud);      -- [out std_logic]

  -----------------------------------------------------------------------------
  -- Status register handling
  -----------------------------------------------------------------------------
  status_Reg(7) <= rx_Data_Present;
  status_Reg(6) <= rx_BUFFER_FULL;
  status_Reg(5) <= tx_Buffer_Empty;
  status_Reg(4) <= tx_BUFFER_FULL;
  status_Reg(3) <= enable_interrupts;

  clr_Status <= uart_CS_3 and OPB_RNW_1 when (OPB_ABus = STATUS_REG_ADR)
                else '0';
  
  OverRun_Error_DFF : FDRE
    port map (
      Q  => status_Reg(2),              -- [out std_logic]
      C  => Clk,                        -- [in  std_logic]
      CE => rx_Overrun_Error,           -- [in  std_logic]
      D  => rx_Overrun_Error,           -- [in  std_logic]
      R  => clr_Status);                -- [in std_logic]

  Frame_Error_DFF : FDRE
    port map (
      Q  => status_Reg(1),              -- [out std_logic]
      C  => Clk,                        -- [in  std_logic]
      CE => rx_Frame_Error,             -- [in  std_logic]
      D  => rx_Frame_Error,             -- [in  std_logic]
      R  => clr_Status);                -- [in std_logic]

  Using_Parity : if (C_USE_PARITY = 1) generate
    Parity_Error_DFF : FDRE
      port map (
        Q  => status_Reg(0),            -- [out std_logic]
        C  => Clk,                      -- [in  std_logic]
        CE => rx_Parity_Error,          -- [in  std_logic]
        D  => rx_Parity_Error,          -- [in  std_logic]
        R  => clr_Status);              -- [in std_logic]
  end generate Using_Parity;

  No_Parity : if (C_USE_PARITY = 0) generate
    status_Reg(0) <= '0';
  end generate No_Parity;

  -----------------------------------------------------------------------------
  -- Control Register Handling 
  -----------------------------------------------------------------------------
  Ctrl_Reg_DFF : process (Clk, Reset) is
  begin  -- process Ctrl_Reg_DFF
    if Reset = '1' then                 -- asynchronous reset (active high)
      reset_TX_FIFO     <= '1';
      reset_RX_FIFO     <= '1';
      enable_interrupts <= '0';
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      reset_TX_FIFO <= '0';
      reset_RX_FIFO <= '0';
      if (uart_CS_2 = '1') and (OPB_RNW_1 = '0') and (OPB_ABus = CTRL_REG_ADR) then
        reset_RX_FIFO     <= OPB_DBus(6);
        reset_TX_FIFO     <= OPB_DBus(7);
        enable_interrupts <= OPB_DBus(3);
      end if;
    end if;
  end process Ctrl_Reg_DFF;

  -----------------------------------------------------------------------------
  -- Interrupt handling
  -----------------------------------------------------------------------------

  -- Sampling the tx_Buffer_Empty signal in order to detect a rising edge
  TX_Buffer_Empty_FDRE : FDRE
    port map (
      Q  => tx_Buffer_Empty_Pre,        -- [out std_logic]
      C  => Clk,                        -- [in  std_logic]
      CE => '1',                        -- [in  std_logic]
      D  => tx_Buffer_Empty,            -- [in  std_logic]
      R  => write_TX_FIFO);             -- [in std_logic]

  Interrupt_DFF: process (Clk, Reset)
  begin  -- process Interrupt_DFF
    if Reset = '1' then                 -- asynchronous reset (active high)
      Interrupt <= '0';
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      Interrupt <= enable_interrupts and (rx_Data_Present or
                                          (tx_Buffer_Empty and not tx_Buffer_Empty_Pre));
    end if;
  end process Interrupt_DFF;

  -----------------------------------------------------------------------------
  -- Handling the OPB bus interface
  -----------------------------------------------------------------------------
  
  Read_Mux : process (status_reg, OPB_ABus, rx_data) is
  begin  -- process Read_Mux
    sin_Dbus_i <= (others => '0');
    if (OPB_ABus = STATUS_REG_ADR) then
      sin_Dbus_i(status_reg'range) <= status_reg;
    else
      sin_Dbus_i(7-C_DATA_BITS+1 to 7) <= rx_data;
    end if;
  end process Read_Mux;

  OPB_rdDBus_DFF : for I in sin_DBus_i'range generate
    OPB_rdBus_FDRE : FDRE
      port map (
        Q  => SIn_DBus(I),              -- [out std_logic]
        C  => Clk,                      -- [in  std_logic]
        CE => uart_CS_2,                -- [in  std_logic]
        D  => sin_Dbus_i(I),            -- [in  std_logic]
        R  => xfer_Ack);                -- [in std_logic]
  end generate OPB_rdDBus_DFF;

  -- Generating read and write pulses to the FIFOs
  write_TX_FIFO <= uart_CS_2 and (not OPB_RNW_1) when (OPB_ABus = TX_FIFO_ADR) else '0';
  read_RX_FIFO <= uart_CS_2 and OPB_RNW_1 when (OPB_ABus = RX_FIFO_ADR) else '0';
  
  XFER_Control : process (Clk, Reset) is
  begin  -- process XFER_Control
    if Reset = '1' then                 -- asynchronous reset (active high)
      xfer_Ack    <= '0';
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      xfer_Ack <= uart_CS_2;
    end if;
  end process XFER_Control;
  
  SIn_xferAck <= xfer_Ack;
  
  -----------------------------------------------------------------------------
  -- Instanciating the receive and transmit modules
  -----------------------------------------------------------------------------
  OPB_UARTLITE_RX_I : OPB_UARTLITE_RX
    generic map (
      C_DATA_BITS  => C_DATA_BITS,      -- [integer range 5 to 8]
      C_USE_PARITY => C_USE_PARITY,     -- [integer]
      C_ODD_PARITY => C_ODD_PARITY)     -- [integer]
    port map (
      Clk              => Clk,          -- [in  std_logic]
      Reset            => Reset,        -- [in  std_logic]
      EN_16x_Baud      => en_16x_Baud,  -- [in  std_logic]
      RX               => RX,           -- [in  std_logic]
      Read_RX_FIFO     => read_RX_FIFO,      -- [in  std_logic]
      Reset_RX_FIFO    => reset_RX_FIFO,     -- [in  std_logic]
      RX_Data          => rx_Data,  -- [out std_logic_vector(0 to C_DATA_BITS-1)]
      RX_Data_Present  => rx_Data_Present,   -- [out std_logic]
      RX_BUFFER_FULL   => rx_BUFFER_FULL,    -- [out std_logic]
      RX_Frame_Error   => rx_Frame_Error,    -- [out std_logic]
      RX_Overrun_Error => rx_Overrun_Error,  -- [out std_logic]
      RX_Parity_Error  => rx_Parity_Error);  -- [out std_logic]

  OPB_UARTLITE_TX_I : OPB_UARTLITE_TX
    generic map (
      C_DATA_BITS  => C_DATA_BITS,      -- [integer range 5 to 8]
      C_USE_PARITY => C_USE_PARITY,     -- [integer]
      C_ODD_PARITY => C_ODD_PARITY)     -- [integer]
    port map (
      Clk             => Clk,           -- [in  std_logic]
      Reset           => Reset,         -- [in  std_logic]
      EN_16x_Baud     => en_16x_Baud,   -- [in  std_logic]
      TX              => TX,            -- [out std_logic]
      Write_TX_FIFO   => write_TX_FIFO,                 -- [in  std_logic]
      Reset_TX_FIFO   => reset_TX_FIFO,                 -- [in  std_logic]
      TX_Data         => OPB_DBus(8-C_DATA_BITS to 7),  -- [in  std_logic_vector(0 to C_DATA_BITS-1)]
      TX_Buffer_Full  => tx_Buffer_Full,                -- [out std_logic]
      TX_Buffer_Empty => tx_Buffer_Empty);              -- [out std_logic]

end architecture IMP;



