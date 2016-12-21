--Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2016.2 (lin64) Build 1577090 Thu Jun  2 16:32:35 MDT 2016
--Date        : Tue Nov 29 14:34:09 2016
--Host        : anie running 64-bit Debian GNU/Linux 8.6 (jessie)
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    b : out STD_LOGIC_VECTOR ( 4 downto 0 );
    btn3 : in STD_LOGIC;
    clk : in STD_LOGIC;
    g : out STD_LOGIC_VECTOR ( 5 downto 0 );
    hsync : out STD_LOGIC;
    led0 : out STD_LOGIC;
    r : out STD_LOGIC_VECTOR ( 4 downto 0 );
    reset_rtl : in STD_LOGIC;
    vsync : out STD_LOGIC
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    r : out STD_LOGIC_VECTOR ( 4 downto 0 );
    g : out STD_LOGIC_VECTOR ( 5 downto 0 );
    b : out STD_LOGIC_VECTOR ( 4 downto 0 );
    reset_rtl : in STD_LOGIC;
    hsync : out STD_LOGIC;
    clk : in STD_LOGIC;
    btn3 : in STD_LOGIC;
    led0 : out STD_LOGIC;
    vsync : out STD_LOGIC
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      b(4 downto 0) => b(4 downto 0),
      btn3 => btn3,
      clk => clk,
      g(5 downto 0) => g(5 downto 0),
      hsync => hsync,
      led0 => led0,
      r(4 downto 0) => r(4 downto 0),
      reset_rtl => reset_rtl,
      vsync => vsync
    );
end STRUCTURE;
