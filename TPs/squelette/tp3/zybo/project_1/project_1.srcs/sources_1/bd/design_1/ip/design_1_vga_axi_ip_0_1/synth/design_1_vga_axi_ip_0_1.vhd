-- (c) Copyright 1995-2016 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: user.org:user:vga_axi_ip:1.0
-- IP Revision: 2

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY design_1_vga_axi_ip_0_1 IS
  PORT (
    hsync : OUT STD_LOGIC;
    vsync : OUT STD_LOGIC;
    r : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    g : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    b : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    irq : OUT STD_LOGIC;
    s00_axi_aclk : IN STD_LOGIC;
    s00_axi_aresetn : IN STD_LOGIC;
    s00_axi_awaddr : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    s00_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s00_axi_awvalid : IN STD_LOGIC;
    s00_axi_awready : OUT STD_LOGIC;
    s00_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s00_axi_wvalid : IN STD_LOGIC;
    s00_axi_wready : OUT STD_LOGIC;
    s00_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s00_axi_bvalid : OUT STD_LOGIC;
    s00_axi_bready : IN STD_LOGIC;
    s00_axi_araddr : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    s00_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s00_axi_arvalid : IN STD_LOGIC;
    s00_axi_arready : OUT STD_LOGIC;
    s00_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s00_axi_rvalid : OUT STD_LOGIC;
    s00_axi_rready : IN STD_LOGIC;
    m00_axi_aclk : IN STD_LOGIC;
    m00_axi_aresetn : IN STD_LOGIC;
    m00_axi_arid : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m00_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m00_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m00_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m00_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m00_axi_arlock : OUT STD_LOGIC;
    m00_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m00_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m00_axi_arqos : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m00_axi_aruser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m00_axi_arvalid : OUT STD_LOGIC;
    m00_axi_arready : IN STD_LOGIC;
    m00_axi_rid : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    m00_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m00_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m00_axi_rlast : IN STD_LOGIC;
    m00_axi_ruser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    m00_axi_rvalid : IN STD_LOGIC;
    m00_axi_rready : OUT STD_LOGIC
  );
END design_1_vga_axi_ip_0_1;

ARCHITECTURE design_1_vga_axi_ip_0_1_arch OF design_1_vga_axi_ip_0_1 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF design_1_vga_axi_ip_0_1_arch: ARCHITECTURE IS "yes";
  COMPONENT vga_axi_ip IS
    GENERIC (
      C_S00_AXI_DATA_WIDTH : INTEGER;
      C_S00_AXI_ADDR_WIDTH : INTEGER;
      C_M00_AXI_TARGET_SLAVE_BASE_ADDR : STD_LOGIC_VECTOR;
      C_M00_AXI_BURST_LEN : INTEGER;
      C_M00_AXI_ID_WIDTH : INTEGER;
      C_M00_AXI_ADDR_WIDTH : INTEGER;
      C_M00_AXI_DATA_WIDTH : INTEGER;
      C_M00_AXI_AWUSER_WIDTH : INTEGER;
      C_M00_AXI_ARUSER_WIDTH : INTEGER;
      C_M00_AXI_WUSER_WIDTH : INTEGER;
      C_M00_AXI_RUSER_WIDTH : INTEGER;
      C_M00_AXI_BUSER_WIDTH : INTEGER
    );
    PORT (
      hsync : OUT STD_LOGIC;
      vsync : OUT STD_LOGIC;
      r : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      g : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
      b : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      irq : OUT STD_LOGIC;
      s00_axi_aclk : IN STD_LOGIC;
      s00_axi_aresetn : IN STD_LOGIC;
      s00_axi_awaddr : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      s00_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s00_axi_awvalid : IN STD_LOGIC;
      s00_axi_awready : OUT STD_LOGIC;
      s00_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s00_axi_wvalid : IN STD_LOGIC;
      s00_axi_wready : OUT STD_LOGIC;
      s00_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s00_axi_bvalid : OUT STD_LOGIC;
      s00_axi_bready : IN STD_LOGIC;
      s00_axi_araddr : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      s00_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s00_axi_arvalid : IN STD_LOGIC;
      s00_axi_arready : OUT STD_LOGIC;
      s00_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s00_axi_rvalid : OUT STD_LOGIC;
      s00_axi_rready : IN STD_LOGIC;
      m00_axi_aclk : IN STD_LOGIC;
      m00_axi_aresetn : IN STD_LOGIC;
      m00_axi_arid : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m00_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m00_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m00_axi_arlock : OUT STD_LOGIC;
      m00_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m00_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_arqos : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m00_axi_aruser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_arvalid : OUT STD_LOGIC;
      m00_axi_arready : IN STD_LOGIC;
      m00_axi_rid : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m00_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      m00_axi_rlast : IN STD_LOGIC;
      m00_axi_ruser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m00_axi_rvalid : IN STD_LOGIC;
      m00_axi_rready : OUT STD_LOGIC
    );
  END COMPONENT vga_axi_ip;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF design_1_vga_axi_ip_0_1_arch: ARCHITECTURE IS "vga_axi_ip,Vivado 2016.2";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF design_1_vga_axi_ip_0_1_arch : ARCHITECTURE IS "design_1_vga_axi_ip_0_1,vga_axi_ip,{}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF irq: SIGNAL IS "xilinx.com:signal:interrupt:1.0 irq INTERRUPT";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 s00_axi_aclk CLK";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 s00_axi_aresetn RST";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 m00_axi_aclk CLK";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 m00_axi_aresetn RST";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arid: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARID";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARLEN";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARBURST";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arlock: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arqos: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARQOS";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_aruser: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARUSER";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_rid: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi RID";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_rlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi RLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_ruser: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi RUSER";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m00_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 m00_axi RREADY";
BEGIN
  U0 : vga_axi_ip
    GENERIC MAP (
      C_S00_AXI_DATA_WIDTH => 32,
      C_S00_AXI_ADDR_WIDTH => 6,
      C_M00_AXI_TARGET_SLAVE_BASE_ADDR => X"40000000",
      C_M00_AXI_BURST_LEN => 16,
      C_M00_AXI_ID_WIDTH => 1,
      C_M00_AXI_ADDR_WIDTH => 32,
      C_M00_AXI_DATA_WIDTH => 32,
      C_M00_AXI_AWUSER_WIDTH => 0,
      C_M00_AXI_ARUSER_WIDTH => 0,
      C_M00_AXI_WUSER_WIDTH => 0,
      C_M00_AXI_RUSER_WIDTH => 0,
      C_M00_AXI_BUSER_WIDTH => 0
    )
    PORT MAP (
      hsync => hsync,
      vsync => vsync,
      r => r,
      g => g,
      b => b,
      irq => irq,
      s00_axi_aclk => s00_axi_aclk,
      s00_axi_aresetn => s00_axi_aresetn,
      s00_axi_awaddr => s00_axi_awaddr,
      s00_axi_awprot => s00_axi_awprot,
      s00_axi_awvalid => s00_axi_awvalid,
      s00_axi_awready => s00_axi_awready,
      s00_axi_wdata => s00_axi_wdata,
      s00_axi_wstrb => s00_axi_wstrb,
      s00_axi_wvalid => s00_axi_wvalid,
      s00_axi_wready => s00_axi_wready,
      s00_axi_bresp => s00_axi_bresp,
      s00_axi_bvalid => s00_axi_bvalid,
      s00_axi_bready => s00_axi_bready,
      s00_axi_araddr => s00_axi_araddr,
      s00_axi_arprot => s00_axi_arprot,
      s00_axi_arvalid => s00_axi_arvalid,
      s00_axi_arready => s00_axi_arready,
      s00_axi_rdata => s00_axi_rdata,
      s00_axi_rresp => s00_axi_rresp,
      s00_axi_rvalid => s00_axi_rvalid,
      s00_axi_rready => s00_axi_rready,
      m00_axi_aclk => m00_axi_aclk,
      m00_axi_aresetn => m00_axi_aresetn,
      m00_axi_arid => m00_axi_arid,
      m00_axi_araddr => m00_axi_araddr,
      m00_axi_arlen => m00_axi_arlen,
      m00_axi_arsize => m00_axi_arsize,
      m00_axi_arburst => m00_axi_arburst,
      m00_axi_arlock => m00_axi_arlock,
      m00_axi_arcache => m00_axi_arcache,
      m00_axi_arprot => m00_axi_arprot,
      m00_axi_arqos => m00_axi_arqos,
      m00_axi_aruser => m00_axi_aruser,
      m00_axi_arvalid => m00_axi_arvalid,
      m00_axi_arready => m00_axi_arready,
      m00_axi_rid => m00_axi_rid,
      m00_axi_rdata => m00_axi_rdata,
      m00_axi_rresp => m00_axi_rresp,
      m00_axi_rlast => m00_axi_rlast,
      m00_axi_ruser => m00_axi_ruser,
      m00_axi_rvalid => m00_axi_rvalid,
      m00_axi_rready => m00_axi_rready
    );
END design_1_vga_axi_ip_0_1_arch;
