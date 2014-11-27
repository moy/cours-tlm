
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
-- Filename:        gpio_core.vhd
-- Version:         v3.02a
-- Description:     General Purpose I/O for OPB bus
--
-------------------------------------------------------------------------------
-- Structure: 
--
--              opb_gpio.vhd
--                opb_ipif.vhd
--                gpio_core.vhd
-------------------------------------------------------------------------------
-- Author:      LSS
-- History:
--      Second version of General Purpose I/O.
-- 
--  Lester Sanders 1/08/2004 Corrected problems with interrupt circuit
--  Lester Sanders 2/18/2004 Changes to allow sim w NCSIM 
--  
--
-- 
--  Vaibhav        8/09/2004 GPIO interrupts are driven low when 
--                           C_INTERRUPT_PRESENT ='0'   
--  Vaibhav        8/09/2004 In process "Two_Only_Inputs", Assignment 
--                           of GPIO_OE2 reg to read_reg_in is removed when 
--                           C_ALL_INPUTS='0' and C_ALL_INPUTS_2='1'  
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library Unisim;
use Unisim.vcomponents.all;

library proc_common_v2_00_a;
use proc_common_v2_00_a.all;
-- use proc_common_v1_00_b.Common_Types.all;
use proc_common_v2_00_a.or_gate;

-------------------------------------------------------------------------------
--                     Defination of Generics :				     --
-------------------------------------------------------------------------------
-- C_DW                -  Data width of OPB BUS.
-- C_AW                -  Address width of OPB BUS.
-- C_GPIO_WIDTH        -  GPIO Data Bus width.
-- C_OPB_DWIDTH        -  Not used in GPIO Core.
-- C_INTERRUPT_PRESENT -  GPIO Interrupt.
-- C_ALL_INPUTS        -  Inputs Only. 
-- C_IS_BIDIR          -  Selects GPIO_IO_I as input.
-- C_DOUT_DEFAULT      -  GPIO_DATA Register reset value.
-- C_TRI_DEFAULT       -  GPIO_TRI Register reset value.
-- C_IS_DUAL           -  Dual Channel GPIO.
-- C_ALL_INPUTS_2      -  Channel2 Inputs only.
-- C_IS_BIDIR_2        -  Selects GPIO2_IO_I as input.
-- C_DOUT_DEFAULT_2    -  GPIO2_DATA Register reset value.
-- C_TRI_DEFAULT_2     -  GPIO2_TRI Register reset value.
-------------------------------------------------------------------------------  

-------------------------------------------------------------------------------
--                  Defination of Ports                                      --
-------------------------------------------------------------------------------
-- Clk         	       - Input clock
-- Rst         	       - Reset
-- ABus_Reg    	       - Bus to IP address
-- BE_Reg      	       - Bus to IP byte enables
-- DBus_Reg    	       - Bus to IP data bus
-- RNW_Reg     	       - Bus to IP read write control
-- select_Reg  	       - Not used in gpio core
-- seqAddr_Reg 	       - Not used in gpio core
-- GPIO_DBus   	       - IP to Bus data bus
-- GPIO_errAck 	       - GPIO error Acknowledge  
-- GPIO_retry  	       - GPIO retry
-- GPIO_toutSup	       - GPIO timeout suppress
-- GPIO_xferAck	       - GPIO transfer acknowledge 
-- GPIO_intr   	       - GPIO channel 1 interrupt to IPIC
-- GPIO2_intr  	       - GPIo channel 2 interrupt to IPIC
-- GPIO_Select 	       - GPIO select
		       
-- GPIO_IO_I   	       - Channel 1 General purpose I/O in port
-- GPIO_IO_O   	       - Channel 1 General purpose I/O out port
-- GPIO_IO_T   	       - Channel 1 General purpose I/O TRI-STATE control port
-- GPIO_in     	       - Channel 1 General purpose input
-- GPIO_d_out  	       - Channel 1 GPIO_Data register out
-- GPIO_t_out  	       - Channel 1 GPIO_Tri register out
-- GPIO2_IO_I  	       - Channel 2 General purpose I/O in port
-- GPIO2_IO_O  	       - Channel 2 General purpose I/O out port
-- GPIO2_IO_T  	       - Channel 2 General purpose I/O TRI-STATE control port
-- GPIO2_in    	       - Channel 2 General purpose input
-- GPIO2_d_out 	       - Channel 2 GPIO2_Data register out
-- GPIO2_t_out 	       - Channel 2 GPIO2_Tri register out
-------------------------------------------------------------------------------

   
   
   
entity GPIO_Core is
  generic (
    C_DW                : INTEGER          := 32;
    C_AW                : INTEGER          := 32;
    C_GPIO_WIDTH        : INTEGER          := 32;
    C_OPB_DWIDTH        : INTEGER          := 32;
    C_INTERRUPT_PRESENT : BOOLEAN          := TRUE;
    C_ALL_INPUTS        : BOOLEAN          := FALSE;
    C_IS_BIDIR          : BOOLEAN          := FALSE;
    C_DOUT_DEFAULT      : STD_LOGIC_VECTOR := X"0000_0000";
    C_TRI_DEFAULT       : STD_LOGIC_VECTOR := X"FFFF_FFFF";
    C_IS_DUAL           : BOOLEAN          := TRUE;
    C_ALL_INPUTS_2      : BOOLEAN          := TRUE;
    C_IS_BIDIR_2        : BOOLEAN          := FALSE;
    C_DOUT_DEFAULT_2    : STD_LOGIC_VECTOR := X"0000_0000";
    C_TRI_DEFAULT_2     : STD_LOGIC_VECTOR := X"FFFF_FFFF"
    );   
  port (
    Clk             : in  STD_LOGIC;
    Rst             : in  STD_LOGIC;
    ABus_Reg        : in  STD_LOGIC_VECTOR(0 to C_AW-1);
    BE_Reg          : in  STD_LOGIC_VECTOR(0 to C_DW/8-1);
    DBus_Reg        : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    RNW_Reg         : in  STD_LOGIC;
    select_Reg      : in  STD_LOGIC; -- Not used in gpio core
    seqAddr_Reg     : in  STD_LOGIC; -- Not used in gpio core
    GPIO_DBus       : out STD_LOGIC_VECTOR(0 to C_DW-1);
    GPIO_errAck     : out STD_LOGIC;
    GPIO_retry      : out STD_LOGIC;
    GPIO_toutSup    : out STD_LOGIC;
    GPIO_xferAck    : out STD_LOGIC;
    GPIO_intr       : out STD_LOGIC;
    GPIO2_intr      : out STD_LOGIC;
    GPIO_Select     : in  STD_LOGIC;

    GPIO_IO_I       : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_IO_O       : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_IO_T       : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_in         : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_d_out      : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO_t_out      : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_IO_I      : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_IO_O      : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_IO_T      : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_in        : in  STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_d_out     : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
    GPIO2_t_out     : out STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1)
    );
end entity GPIO_Core;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture IMP of GPIO_Core is
  
  function Boolean_to_Integer (x : BOOLEAN) return INTEGER is
  begin
    if x = FALSE then return 0;
    else return 1;
    end if;
  end function Boolean_to_Integer;

  signal gpio_Data_Select        : STD_LOGIC_VECTOR(0 to Boolean_to_Integer(C_IS_DUAL));
  signal gpio_OE_Select          : STD_LOGIC_VECTOR(0 to Boolean_to_Integer(C_IS_DUAL));
  signal Read_Reg_Rst            : STD_LOGIC;
  signal Read_Reg_In             : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal Read_Reg_CE             : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio_Data_Out           : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio2_Data_Out          : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio_Data_In            : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio2_Data_In           : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio_OE                 : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio2_OE                : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal GPIO_DBus_i             : STD_LOGIC_VECTOR(0 to C_DW-1);
  signal gpio_data_in_xor        : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio_data_in_xor_reg    : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio2_data_in_xor       : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal gpio2_data_in_xor_reg   : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal or_ints                 : STD_LOGIC_VECTOR(0 to 0);
  signal or_ints2                : STD_LOGIC_VECTOR(0 to 0);
  signal iGPIO_xferAck           : STD_LOGIC;
  signal gpio_xferAck_Reg        : STD_LOGIC;
  signal dout_default_i          : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal tri_default_i           : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal dout2_default_i         : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);
  signal tri2_default_i          : STD_LOGIC_VECTOR(0 to C_GPIO_WIDTH-1);


component or_gate
  generic
  ( 
    C_OR_WIDTH   : natural range 1 to 32 := 32;
    C_BUS_WIDTH  : natural range 1 to 64 := 1;
    C_USE_LUT_OR : boolean               := TRUE
  );
  port
  (
    A : in  std_logic_vector(0 to C_OR_WIDTH * C_BUS_WIDTH -1);
    Y : out std_logic_vector(0 to C_BUS_WIDTH -1)
  );
end component;

component fdr
  port
  (
    Q : out std_logic;
    D : in  std_logic;
    C : in  std_logic;
    R : in  std_logic
  );
end component;

begin  -- architecture IMP

  TIE_DEFAULTS_GENERATE : if C_DW >= C_GPIO_WIDTH generate
    SELECT_BITS_GENERATE : for i in 0 to C_GPIO_WIDTH-1 generate
      dout_default_i(i)  <= C_DOUT_DEFAULT(i-C_GPIO_WIDTH+C_DW);
      tri_default_i(i)   <= C_TRI_DEFAULT(i-C_GPIO_WIDTH+C_DW);
      dout2_default_i(i) <= C_DOUT_DEFAULT_2(i-C_GPIO_WIDTH+C_DW);
      tri2_default_i(i)  <= C_TRI_DEFAULT_2(i-C_GPIO_WIDTH+C_DW);
    end generate SELECT_BITS_GENERATE;
  end generate TIE_DEFAULTS_GENERATE;

  Read_Reg_Rst <= iGPIO_xferAck or gpio_xferAck_Reg or (not GPIO_Select) or
                      (GPIO_Select and not RNW_Reg);
                      
-------------------------------------------------------------------------------
-- READ_REG_CE_PROCESS
-------------------------------------------------------------------------------
-- This process generates the enable signal for GPIO registers ,using OPB_BE --
-------------------------------------------------------------------------------
  READ_REG_CE_PROCESS : process(BE_Reg) is
  begin
    for i in 0 to C_GPIO_WIDTH-1 loop
      Read_Reg_CE(i) <= BE_Reg((i-C_GPIO_WIDTH+C_DW)/8);
      -- Read_Reg_CE(i) <= '1';
    end loop;
  end process READ_REG_CE_PROCESS;

  READ_REG_GEN : for i in 0 to C_GPIO_WIDTH-1 generate
    READ_REG_FF_I : FDRE
      port map (
        Q  => GPIO_DBus_i(i-C_GPIO_WIDTH+C_DW),  -- [out]
        C  => Clk,                         -- [in]
        D  => Read_Reg_In(i),              -- [in]
        R  => Read_Reg_Rst,                -- [in]
        CE => Read_Reg_CE(i)               -- [in]
        );
  end generate READ_REG_GEN;

  GPIO_DBus <= GPIO_DBus_i;

  TIE_DBUS_GENERATE : if C_DW > C_GPIO_WIDTH generate
    GPIO_DBus_i(0 to C_DW-C_GPIO_WIDTH-1) <= (others => '0');
  end generate TIE_DBUS_GENERATE;
  
-------------------------------------------------------------------------------
-- XFER_ACK_PROCESS
-------------------------------------------------------------------------------
--        Generation of Transfer Ack signal for one clock pulse              --
-------------------------------------------------------------------------------
  XFER_ACK_PROCESS : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      iGPIO_xferAck <= '0';
    elsif (Clk'EVENT and Clk = '1') then
      iGPIO_xferAck <= GPIO_Select and not gpio_xferAck_Reg;
      if iGPIO_xferAck = '1' then
        iGPIO_xferAck <= '0';
      end if;
    end if;
  end process XFER_ACK_PROCESS;
  
-------------------------------------------------------------------------------
-- DELAYED_XFER_ACK_PROCESS
-------------------------------------------------------------------------------
--        Single Reg stage to make Transfer Ack period one clock pulse wide  --
-------------------------------------------------------------------------------
  DELAYED_XFER_ACK_PROCESS : process (Clk, Rst) is
  begin
    if (Rst = '1') then
      gpio_xferAck_Reg <= '0';
    elsif (Clk'EVENT and Clk = '1') then
      gpio_xferAck_Reg <= iGPIO_xferAck;
    end if;
  end process DELAYED_XFER_ACK_PROCESS;

  GPIO_xferAck <= iGPIO_xferAck;
 
  -----------------------------------------------------------------------------
  --         Drive GPIO interrupts to '0' when interrupt not present         --
  -----------------------------------------------------------------------------
  
   DONT_GEN_INTERRUPT : if (not C_INTERRUPT_PRESENT) generate
  	gpio_intr  <= '0';
  	gpio2_intr <= '0';
    end generate DONT_GEN_INTERRUPT;
  
 
  Not_Dual : if (not C_IS_DUAL) generate
  -----------------------------------------------------------------------------
  -- REG_SELECT_PROCESS
  -----------------------------------------------------------------------------
  --      GPIO REGISTER selection decoder for single channel configuration   --
  -----------------------------------------------------------------------------
    REG_SELECT_PROCESS : process (GPIO_Select, ABus_Reg) is
    begin
      gpio_Data_Select(0) <= '0';
      gpio_OE_Select(0)   <= '0';
      
      if GPIO_Select = '1' then
        case ABus_Reg(29) is        -- bit A29
          when '0'    => gpio_Data_Select(0) <= '1';
          when '1'    => gpio_OE_Select(0)   <= '1';
          when others => null;
        end case;
      end if;
    end process REG_SELECT_PROCESS;

    BIRDIR_GEN_0 : if (C_IS_BIDIR) generate
    ---------------------------------------------------------------------------
    -- GPIO_INDATA_BIRDIR_PROCESS
    ---------------------------------------------------------------------------
    --     Reading of channel 1 data from Bidirectional GPIO port            --
    --     to GPIO_DATA REGISTER                                             --
    ---------------------------------------------------------------------------
      GPIO_INDATA_BIRDIR_PROCESS : process(Clk) is
      begin
        if Clk = '1' and Clk'EVENT then
          gpio_Data_In <= GPIO_IO_I;
        end if;
      end process GPIO_INDATA_BIRDIR_PROCESS;
    end generate BIRDIR_GEN_0;

    BIRDIR_NOT_GEN_0 : if (not C_IS_BIDIR) generate
    ---------------------------------------------------------------------------
    -- GPIO_INDATA_BIRDIR_NOT_PROCESS
    ---------------------------------------------------------------------------
    --     Reading of channel 1 data from GPIO_in port                       --
    --     to GPIO_DATA REGISTER                                             --
    ---------------------------------------------------------------------------
      GPIO_INDATA_BIRDIR_NOT_PROCESS : process(Clk) is
      begin
        if Clk = '1' and Clk'EVENT then
          gpio_Data_In <= GPIO_in;
        end if;
      end process GPIO_INDATA_BIRDIR_NOT_PROCESS;
    end generate BIRDIR_NOT_GEN_0;

    Only_Inputs : if (C_ALL_INPUTS) generate
      Read_Reg_In <= gpio_Data_In;
      GPIO_IO_O       <= (others => '0');  -- All output three-stated
      GPIO_d_out      <= (others => '0');
      GPIO_t_out      <= (others => '0');  -- All output three-stated
      GPIO_IO_T       <= (others => '1');  -- All output three-stated
    end generate Only_Inputs;

    Inputs_And_Outputs : if (not C_ALL_INPUTS) generate
    ---------------------------------------------------------------------------
    -- READ_MUX_PROCESS
    ---------------------------------------------------------------------------
    -- Selects GPIO_TRI control or GPIO_DATA Register to be read             --
    ---------------------------------------------------------------------------
      READ_MUX_PROCESS : process (gpio_Data_In, gpio_Data_Select, gpio_OE,
                                  gpio_OE_Select) is
      begin
        Read_Reg_In <= (others => '0');
        if gpio_Data_Select(0) = '1' then
          Read_Reg_In <= gpio_Data_In;
        elsif gpio_OE_Select(0) = '1' then
          Read_Reg_In <= gpio_OE;
        end if;
      end process READ_MUX_PROCESS;
      
    ---------------------------------------------------------------------------
    -- GPIO_OUTDATA_PROCESS
    ---------------------------------------------------------------------------
    --     Writing to Channel 1 GPIO_DATA REGISTER                           --
    ---------------------------------------------------------------------------
      GPIO_OUTDATA_PROCESS : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio_Data_Out <= dout_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_Data_Select(0) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio_Data_Out(i) <= DBus_Reg(i);
              else
                gpio_Data_Out(i) <= gpio_Data_Out(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO_OUTDATA_PROCESS;
      
    ---------------------------------------------------------------------------
    -- GPIO_OE_PROCESS
    ---------------------------------------------------------------------------
    --     Writing to Channel 1 GPIO_TRI Control REGISTER                    --
    ---------------------------------------------------------------------------
      GPIO_OE_PROCESS : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio_OE <= tri_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_OE_Select(0) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio_OE(i) <= DBus_Reg(i);
              else
                gpio_OE(i) <= gpio_OE(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO_OE_PROCESS;

      GPIO_IO_O  <= gpio_Data_Out;
      GPIO_d_out <= gpio_Data_Out;
      GPIO_IO_T  <= gpio_OE;
      GPIO_t_out <= gpio_OE;

    end generate Inputs_And_Outputs;


-- Add interrupt section for Not Dual

gen_interrupt : if (C_INTERRUPT_PRESENT) generate

   INTR_BIDIR: if (C_IS_BIDIR)  generate
   gen_xor : for i in 0 to C_GPIO_WIDTH-1 generate
     gpio_data_in_xor(i) <= gpio_Data_In(i) xor GPIO_IO_I(i);
   end generate gen_xor;
   end generate INTR_BIDIR;

   INTR_NOT_BIDIR: if (not C_IS_BIDIR)  generate
   gen_xor : for i in 0 to C_GPIO_WIDTH-1 generate
     gpio_data_in_xor(i) <= gpio_Data_In(i) xor GPIO_In(i);
   end generate gen_xor;
   end generate INTR_NOT_BIDIR;


   REGISTER_XORs : for i in 0 to C_GPIO_WIDTH-1 generate
     REG_XOR_I : FDR
     port map (
      Q =>  gpio_data_in_xor_reg(i),
      C => Clk,
      D => gpio_data_in_xor(i),
      R => Rst
      );
   end generate REGISTER_XORs;

   OR_INTS_I : or_gate
    generic map
    (
      C_OR_WIDTH => C_GPIO_WIDTH,
      C_BUS_WIDTH => 1,
      C_USE_LUT_OR => TRUE
    )
    port map
    (
      A => gpio_data_in_xor_reg,
      Y => or_ints
    );

   FDR_I : fdr -- 
     port map
     (
       Q => GPIO_intr,
       C => Clk,
       D => or_ints(0),
       R => Rst
     );
     
  gpio2_intr          <= '0';  -- Channel 2 interrupt is driven low
  
  end generate gen_interrupt;

  end generate Not_Dual;

  Dual : if (C_IS_DUAL) generate
  -----------------------------------------------------------------------------
  -- DUAL_REG_SELECT_PROCESS
  -----------------------------------------------------------------------------
  --      GPIO REGISTER selection decoder for Dual channel configuration   --
  ----------------------------------------------------------------------------- 
DUAL_REG_SELECT_PROCESS : process (GPIO_Select, ABus_Reg) is
 variable ABus_reg_select : std_logic_vector(0 to 1);
    begin
     ABus_reg_select := ABus_Reg(28 to 29);  
      gpio_Data_Select <= (others => '0');
      gpio_OE_Select   <= (others => '0');
      if GPIO_Select = '1' then
--        case ABus_Reg(28 to 29) is  -- bit A28,A29 for dual
        case ABus_reg_select is  -- bit A28,A29 for dual
          when "00"   => gpio_Data_Select(0) <= '1';
          when "01"   => gpio_OE_Select(0)   <= '1';
          when "10"   => gpio_Data_Select(1) <= '1';
          when "11"   => gpio_OE_Select(1)   <= '1';
          when others => null;
        end case;
      end if;
    end process DUAL_REG_SELECT_PROCESS;

    BIRDIR_GEN_2_1 : if (C_IS_BIDIR) generate
    ---------------------------------------------------------------------------
    -- GPIO_INDATA_BIRDIR_PROCESS
    ---------------------------------------------------------------------------
    --     Reading of channel 1 data from Bidirectional GPIO port            --
    --     to GPIO_DATA REGISTER                                             --
    ---------------------------------------------------------------------------
      GPIO_INDATA_BIRDIR_PROCESS : process(Clk) is
      begin
        if Clk = '1' and Clk'EVENT then
          gpio_Data_In <= GPIO_IO_I;
        end if;
      end process GPIO_INDATA_BIRDIR_PROCESS;
    end generate BIRDIR_GEN_2_1;
    
    BIRDIR_NOT_GEN_2_1 : if (not C_IS_BIDIR) generate
    ---------------------------------------------------------------------------
    -- GPIO_INDATA_BIRDIR_NOT_PROCESS
    ---------------------------------------------------------------------------
    --     Reading of channel 1 data from GPIO_in port                       --
    --     to GPIO_DATA REGISTER                                             --
    ---------------------------------------------------------------------------
      GPIO_INDATA_BIRDIR_NOT_PROCESS : process(Clk) is
      begin
        if Clk = '1' and Clk'EVENT then
          gpio_Data_In <= GPIO_in;
        end if;
      end process GPIO_INDATA_BIRDIR_NOT_PROCESS;
    end generate BIRDIR_NOT_GEN_2_1;
    
    BIRDIR_GEN_2_2 : if (C_IS_BIDIR_2) generate
    ---------------------------------------------------------------------------
    -- GPIO2_INDATA_BIRDIR_PROCESS
    ---------------------------------------------------------------------------
    --     Reading of channel 2 data from Bidirectional GPIO2 port           --
    --     to GPIO2_DATA REGISTER                                            --
    ---------------------------------------------------------------------------
      GPIO2_INDATA_BIRDIR_PROCESS : process(Clk) is
      begin
        if Clk = '1' and Clk'EVENT then
          gpio2_Data_In <= GPIO2_IO_I;
        end if;
      end process GPIO2_INDATA_BIRDIR_PROCESS;
    end generate BIRDIR_GEN_2_2;
    
    BIRDIR_NOT_GEN_2_2 : if (not C_IS_BIDIR_2) generate
    ---------------------------------------------------------------------------
    -- GPIO2_INDATA_BIRDIR_NOT_PROCESS
    ---------------------------------------------------------------------------
    --     Reading of channel 2 data from GPIO2_in port                      --
    --     to GPIO2_DATA REGISTER                                            --
    ---------------------------------------------------------------------------
      GPIO2_INDATA_BIRDIR_NOT_PROCESS : process(Clk) is
      begin
        if Clk = '1' and Clk'EVENT then
          gpio2_Data_In <= GPIO2_in;
        end if;
      end process GPIO2_INDATA_BIRDIR_NOT_PROCESS;
    end generate BIRDIR_NOT_GEN_2_2;

    Only_Inputs : if (C_ALL_INPUTS and C_ALL_INPUTS_2) generate
    ---------------------------------------------------------------------------
    -- READ_MUX_PROCESS_1_1
    ---------------------------------------------------------------------------
    -- Selects Channel 1's or Channel 2's,GPIOX_DATA REGISTER to be read     --
    ---------------------------------------------------------------------------
      READ_MUX_PROCESS_1_1 : process (gpio2_Data_In, gpio_Data_In,
                                      gpio_Data_Select) is
      begin
        Read_Reg_In <= (others => '0');
        if gpio_Data_Select(0) = '1' then
          Read_Reg_In <= gpio_Data_In;
        elsif gpio_Data_Select(1) = '1' then
          Read_Reg_In <= gpio2_Data_In;
        end if;
      end process READ_MUX_PROCESS_1_1;

      GPIO_IO_O  <= (others => '0');    -- All output 0
      GPIO_d_out <= (others => '0');    -- All output 0
      GPIO_t_out <= (others => '0');    -- All output 0
      GPIO_IO_T  <= (others => '1');    -- All output three-stated

      GPIO2_IO_O  <= (others => '0');   -- All output 0
      GPIO2_d_out <= (others => '0');   -- All output 0
      GPIO2_t_out <= (others => '0');   -- All output 0
      GPIO2_IO_T  <= (others => '1');   -- All output three-stated

    end generate Only_Inputs;

    Two_Only_Inputs : if ((not C_ALL_INPUTS) and C_ALL_INPUTS_2) generate
    ---------------------------------------------------------------------------
    -- READ_MUX_PROCESS_0_1
    ---------------------------------------------------------------------------
    -- Selects among Channel 1's GPIO_DATA ,GPIO_TRI and  Channel 2's        -- 
    -- GPIO2_DATA REGISTERS for reading                                      --
    ---------------------------------------------------------------------------
      READ_MUX_PROCESS_0_1 : process (gpio2_Data_In, gpio_Data_In,
                                      gpio_Data_Select, gpio_OE,
                                      gpio_OE_Select) is
      begin
        Read_Reg_In <= (others => '0');
        if gpio_Data_Select(0) = '1' then
          Read_Reg_In <= gpio_Data_In;
        elsif gpio_Data_Select(1) = '1' then
          Read_Reg_In <= gpio2_Data_In;
        elsif gpio_OE_Select(0) = '1' then
          Read_Reg_In <= gpio_OE;
        end if;
      end process READ_MUX_PROCESS_0_1;
      
    ---------------------------------------------------------------------------
    -- GPIO_OUTDATA_PROCESS_0_1
    ---------------------------------------------------------------------------
    --     Writing to Channel 1 GPIO_DATA REGISTER                           --
    ---------------------------------------------------------------------------
      GPIO_OUTDATA_PROCESS_0_1 : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio_Data_Out <= dout_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_Data_Select(0) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio_Data_Out(i) <= DBus_Reg(i);
              else
                gpio_Data_Out(i) <= gpio_Data_Out(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO_OUTDATA_PROCESS_0_1;
      
    ---------------------------------------------------------------------------
    -- GPIO_OE_PROCESS_0_1
    ---------------------------------------------------------------------------
    --     Writing to Channel 1 GPIO_TRI Control REGISTER                    --
    ---------------------------------------------------------------------------
      GPIO_OE_PROCESS_0_1 : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio_OE <= tri_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_OE_Select(0) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio_OE(i) <= DBus_Reg(i);
              else
                gpio_OE(i) <= gpio_OE(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO_OE_PROCESS_0_1;

      GPIO_IO_O  <= gpio_Data_Out;
      GPIO_d_out <= gpio_Data_Out;
      GPIO_IO_T  <= gpio_OE;
      GPIO_t_out <= gpio_OE;

      GPIO2_IO_O  <= (others => '0');   -- All output 0
      GPIO2_d_out <= (others => '0');   -- All output 0
      GPIO2_t_out <= (others => '0');   -- All output 0
      GPIO2_IO_T  <= (others => '1');   -- All output three-stated

    end generate Two_Only_Inputs;

    One_Only_Inputs : if (C_ALL_INPUTS and (not C_ALL_INPUTS_2)) generate
    ---------------------------------------------------------------------------
    -- READ_MUX_PROCESS_1_0
    ---------------------------------------------------------------------------
    -- Selects among Channel 1 GPIO_DATA and Channel 2 GPIO2_DATA ,GPIO2_TRI--
    -- REGISTERS for reading                                                --
    ---------------------------------------------------------------------------
      READ_MUX_PROCESS_1_0 : process (gpio2_Data_In, gpio2_OE, gpio_Data_In,
                                      gpio_Data_Select, gpio_OE_Select) is
      begin
        Read_Reg_In <= (others => '0');
        if gpio_Data_Select(0) = '1' then
          Read_Reg_In <= gpio_Data_In;
        elsif gpio_Data_Select(1) = '1' then
          Read_Reg_In <= gpio2_Data_In;
        elsif gpio_OE_Select(1) = '1' then
          Read_Reg_In <= gpio2_OE;
        end if;
      end process READ_MUX_PROCESS_1_0;
      
    ---------------------------------------------------------------------------
    -- GPIO2_OUTDATA_PROCESS_1_0
    ---------------------------------------------------------------------------
    --     Writing to Channel 2 GPIO2_DATA REGISTER                          --
    ---------------------------------------------------------------------------
      GPIO2_OUTDATA_PROCESS_1_0 : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio2_Data_Out <= dout2_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_Data_Select(1) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio2_Data_Out(i) <= DBus_Reg(i);
              else
                gpio2_Data_Out(i) <= gpio2_Data_Out(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO2_OUTDATA_PROCESS_1_0;
      
    ---------------------------------------------------------------------------
    -- GPIO2_OE_PROCESS_1_0
    ---------------------------------------------------------------------------
    --     Writing to Channel 2 GPIO2_TRI Control REGISTER                   --
    ---------------------------------------------------------------------------
      GPIO2_OE_PROCESS_1_0 : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio2_OE <= tri2_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_OE_Select(1) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio2_OE(i) <= DBus_Reg(i);
              else
                gpio2_OE(i) <= gpio2_OE(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO2_OE_PROCESS_1_0;

      GPIO_IO_O  <= (others => '0');    -- All output 0
      GPIO_d_out <= (others => '0');    -- All output 0
      GPIO_t_out <= (others => '0');    -- All output 0
      GPIO_IO_T  <= (others => '1');    -- All output three-stated

      GPIO2_IO_O  <= gpio2_Data_Out;
      GPIO2_d_out <= gpio2_Data_Out;
      GPIO2_IO_T  <= gpio2_OE;
      GPIO2_t_out <= gpio2_OE;

    end generate One_Only_Inputs;

    All_Inputs_And_Outputs : if ((not C_ALL_INPUTS) and (not C_ALL_INPUTS_2)) generate
    ---------------------------------------------------------------------------
    -- READ_MUX_PROCESS_0_0
    ---------------------------------------------------------------------------
    -- Selects among Channel 1 GPIO_DATA ,GPIO_TRI and Channel 2 GPIO2_DATA  --
    -- GPIO2_TRI REGISTERS for reading                                       --
    ---------------------------------------------------------------------------
      READ_MUX_PROCESS_0_0 : process (gpio2_Data_In, gpio2_OE, gpio_Data_In,
                                      gpio_Data_Select, gpio_OE,
                                      gpio_OE_Select) is
      begin
        Read_Reg_In <= (others => '0');
        if gpio_Data_Select(0) = '1' then
          Read_Reg_In <= gpio_Data_In;
        elsif gpio_OE_Select(0) = '1' then
          Read_Reg_In <= gpio_OE;
        elsif gpio_Data_Select(1) = '1' then
          Read_Reg_In <= gpio2_Data_In;
        elsif gpio_OE_Select(1) = '1' then
          Read_Reg_In <= gpio2_OE;
        end if;
      end process READ_MUX_PROCESS_0_0;
      
    ---------------------------------------------------------------------------
    -- GPIO_OUTDATA_PROCESS_0_0
    ---------------------------------------------------------------------------
    --     Writing to Channel 1 GPIO_DATA REGISTER                           --
    ---------------------------------------------------------------------------
      GPIO_OUTDATA_PROCESS_0_0 : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio_Data_Out <= dout_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_Data_Select(0) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio_Data_Out(i) <= DBus_Reg(i);
              else
                gpio_Data_Out(i) <= gpio_Data_Out(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO_OUTDATA_PROCESS_0_0;
      
    ---------------------------------------------------------------------------
    -- GPIO_OE_PROCESS_0_0
    ---------------------------------------------------------------------------
    --     Writing to Channel 1 GPIO_TRI Control REGISTER                    --
    ---------------------------------------------------------------------------
      GPIO_OE_PROCESS_0_0 : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio_OE <= tri_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_OE_Select(0) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio_OE(i) <= DBus_Reg(i);
              else
                gpio_OE(i) <= gpio_OE(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO_OE_PROCESS_0_0;
      
    ---------------------------------------------------------------------------
    -- GPIO2_OUTDATA_PROCESS_0_0
    ---------------------------------------------------------------------------
    --     Writing to Channel 2 GPIO2_DATA REGISTER                          --
    ---------------------------------------------------------------------------
      GPIO2_OUTDATA_PROCESS_0_0 : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio2_Data_Out <= dout2_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_Data_Select(1) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio2_Data_Out(i) <= DBus_Reg(i);
              else
                gpio2_Data_Out(i) <= gpio2_Data_Out(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO2_OUTDATA_PROCESS_0_0;
      
    ---------------------------------------------------------------------------
    -- GPIO2_OE_PROCESS_0_0
    ---------------------------------------------------------------------------
    --     Writing to Channel 2 GPIO2_TRI Control REGISTER                   --
    ---------------------------------------------------------------------------
      GPIO2_OE_PROCESS_0_0 : process(Clk, Rst) is
      begin
        if (Rst = '1') then
          gpio2_OE <= tri2_default_i;
        elsif Clk = '1' and Clk'EVENT then
          if gpio_OE_Select(1) = '1' and RNW_Reg = '0' then
            for i in 0 to C_GPIO_WIDTH-1 loop
              if Read_Reg_CE(i) = '1' then
                gpio2_OE(i) <= DBus_Reg(i);
              else
                gpio2_OE(i) <= gpio2_OE(i);
              end if;
            end loop;
          end if;
        end if;
      end process GPIO2_OE_PROCESS_0_0;

      GPIO_IO_O  <= gpio_Data_Out;
      GPIO_d_out <= gpio_Data_Out;
      GPIO_IO_T  <= gpio_OE;
      GPIO_t_out <= gpio_OE;

      GPIO2_IO_O  <= gpio2_Data_Out;
      GPIO2_d_out <= gpio2_Data_Out;
      GPIO2_IO_T  <= gpio2_OE;
      GPIO2_t_out <= gpio2_OE;

    end generate All_Inputs_And_Outputs;

-- Add interrupt section for Dual

gen_interrupt_dual : if (C_INTERRUPT_PRESENT) generate

INTR_BIDIR_1_BIDIR_2 : if (C_IS_BIDIR and C_IS_BIDIR_2)  generate
gen_xor : for i in 0 to C_GPIO_WIDTH-1 generate
     gpio_data_in_xor(i) <= gpio_Data_In(i) xor GPIO_IO_I(i);
     gpio2_data_in_xor(i) <= gpio2_Data_In(i) xor GPIO2_IO_I(i);
end generate gen_xor;
end generate INTR_BIDIR_1_BIDIR_2;

INTR_BIDIR_1_NOT_BIDIR_2 : if (C_IS_BIDIR and not C_IS_BIDIR_2)  generate
gen_xor : for i in 0 to C_GPIO_WIDTH-1 generate
     gpio_data_in_xor(i) <= gpio_Data_In(i) xor GPIO_IO_I(i);
     gpio2_data_in_xor(i) <= gpio2_Data_In(i) xor GPIO2_In(i);
end generate gen_xor;
end generate INTR_BIDIR_1_NOT_BIDIR_2;

INTR_NOT_BIDIR_1_NOT_BIDIR_2 : if (not C_IS_BIDIR and not C_IS_BIDIR_2)  generate
gen_xor : for i in 0 to C_GPIO_WIDTH-1 generate
     gpio_data_in_xor(i) <= gpio_Data_In(i) xor GPIO_In(i);
     gpio2_data_in_xor(i) <= gpio2_Data_In(i) xor GPIO2_In(i);
end generate gen_xor;
end generate INTR_NOT_BIDIR_1_NOT_BIDIR_2;

INTR_NOT_BIDIR_1_BIDIR_2 : if (not C_IS_BIDIR and C_IS_BIDIR_2)  generate
gen_xor : for i in 0 to C_GPIO_WIDTH-1 generate
     gpio_data_in_xor(i) <= gpio_Data_In(i) xor GPIO_In(i);
     gpio2_data_in_xor(i) <= gpio2_Data_In(i) xor GPIO2_IO_I(i);
end generate gen_xor;
end generate INTR_NOT_BIDIR_1_BIDIR_2;


   REGISTER_XORs : for i in 0 to C_GPIO_WIDTH-1 generate
     REG_XOR_I : FDR
     port map (
      Q =>  gpio_data_in_xor_reg(i),
      C => Clk,
      D => gpio_data_in_xor(i),
      R => Rst
      );
   end generate REGISTER_XORs;

   REGISTER_XOR2s : for i in 0 to C_GPIO_WIDTH-1 generate
     REG_XOR_I : FDR
     port map (
      Q =>  gpio2_data_in_xor_reg(i),
      C => Clk,
      D => gpio2_data_in_xor(i),
      R => Rst
      );
   end generate REGISTER_XOR2s;

   OR_INTS_I : or_gate
    generic map
    (
      C_OR_WIDTH => C_GPIO_WIDTH,
      C_BUS_WIDTH => 1,
      C_USE_LUT_OR => TRUE
    )
    port map
    (
      A => gpio_data_in_xor_reg,
      Y => or_ints
    );

   OR_INTS_I_2 : or_gate
    generic map
    (
      C_OR_WIDTH => C_GPIO_WIDTH,
      C_BUS_WIDTH => 1,
      C_USE_LUT_OR => TRUE
    )
    port map
    (
      A => gpio2_data_in_xor_reg,
      Y => or_ints2
    );

   FDR_I : fdr 
     port map
     (
       Q => GPIO_intr,
       C => Clk,
       D => or_ints(0),
       R => Rst
     );

   FDR2_I : fdr 
     port map
     (
       Q => GPIO2_intr,
       C => Clk,
       D => or_ints2(0),
       R => Rst
     );

  end generate gen_interrupt_dual;

  end generate Dual;

  GPIO_errAck  <= '0';
  GPIO_retry   <= '0';
  GPIO_toutSup <= '0';

end architecture IMP;
-------------------------------------------------------------------------------
--               End of file gpio_core.vhd                                   --
-------------------------------------------------------------------------------
