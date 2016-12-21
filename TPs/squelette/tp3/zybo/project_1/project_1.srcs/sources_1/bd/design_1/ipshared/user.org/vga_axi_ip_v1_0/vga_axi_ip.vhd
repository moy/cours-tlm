-- vim:ts=3:noexpandtab:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_axi_ip is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH		: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH		: integer	:= 6;

		-- Parameters of Axi Master Bus Interface M00_AXI
		C_M00_AXI_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"73A00000";
		C_M00_AXI_BURST_LEN		: integer	:= 16;
		C_M00_AXI_ID_WIDTH		: integer	:= 1;
		C_M00_AXI_ADDR_WIDTH		: integer	:= 32;
		C_M00_AXI_DATA_WIDTH		: integer	:= 32;
		C_M00_AXI_AWUSER_WIDTH	: integer	:= 0;
		C_M00_AXI_ARUSER_WIDTH	: integer	:= 0;
		C_M00_AXI_WUSER_WIDTH	: integer	:= 0;
		C_M00_AXI_RUSER_WIDTH	: integer	:= 0;
		C_M00_AXI_BUSER_WIDTH	: integer	:= 0
	);
	port (
		-- Users to add ports here
		hsync					: out std_logic;
		vsync					: out std_logic;
		r						: out unsigned(4 downto 0);
		g						: out unsigned(5 downto 0);
		b						: out unsigned(4 downto 0);
		irq					: out std_logic;
		-- User ports ends

		-- Do not modify the ports beyond this line

		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXI
		m00_axi_aclk	: in std_logic;
		m00_axi_aresetn	: in std_logic;
		m00_axi_arid	: out std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
		m00_axi_araddr	: out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
		m00_axi_arlen	: out std_logic_vector(7 downto 0);
		m00_axi_arsize	: out std_logic_vector(2 downto 0);
		m00_axi_arburst	: out std_logic_vector(1 downto 0);
		m00_axi_arlock	: out std_logic;
		m00_axi_arcache	: out std_logic_vector(3 downto 0);
		m00_axi_arprot	: out std_logic_vector(2 downto 0);
		m00_axi_arqos	: out std_logic_vector(3 downto 0);
		m00_axi_aruser	: out std_logic_vector(C_M00_AXI_ARUSER_WIDTH-1 downto 0);
		m00_axi_arvalid	: out std_logic;
		m00_axi_arready	: in std_logic;
		m00_axi_rid	: in std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
		m00_axi_rdata	: in std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
		m00_axi_rresp	: in std_logic_vector(1 downto 0);
		m00_axi_rlast	: in std_logic;
		m00_axi_ruser	: in std_logic_vector(C_M00_AXI_RUSER_WIDTH-1 downto 0);
		m00_axi_rvalid	: in std_logic;
		m00_axi_rready	: out std_logic
	);
end vga_axi_ip;

architecture arch_imp of vga_axi_ip is

	-- component declaration
	component rb_tx_v1_0_S00_AXI is
		generic (
		C_S_AXI_MBURST_LEN	: integer	:= 16; -- Strange but I need it!
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
		port (

		rb_tx_addr_inr			: out std_logic_vector(31 downto 0);

		rb_tx_burstnb_inr		: out std_logic_vector(31 downto 0);

		rb_tx_startr			: out std_logic;
		rb_tx_busy				: in std_logic;
		rb_tx_sensor			: in std_logic_vector(31 downto 0);  -- For various debug signals

		rb_tx_fifor_data		: in std_logic_vector(31 downto 0);
		rb_tx_fifor_en			: in std_logic;
		rb_tx_fifor_cnt		: out std_logic_vector(15 downto 0);

		tx_fifo_out_data	: out std_logic_vector(31 downto 0);
		tx_fifo_out_rdy	: out std_logic;
		tx_fifo_out_ack	: in std_logic;

		idle					: out std_logic;

		irq					: in std_logic;
		iak					: out std_logic;

		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component rb_tx_v1_0_S00_AXI;

	component rb_tx_v1_0_M00_AXI is
		generic (
		C_M_AXI_BURST_LEN		: integer	:= 16;
		C_M_AXI_ID_WIDTH		: integer	:= 1;
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 32;
		C_M_AXI_AWUSER_WIDTH	: integer	:= 0;
		C_M_AXI_ARUSER_WIDTH	: integer	:= 0;
		C_M_AXI_WUSER_WIDTH	: integer	:= 0;
		C_M_AXI_RUSER_WIDTH	: integer	:= 0;
		C_M_AXI_BUSER_WIDTH	: integer	:= 0
		);
		port (

		rb_tx_addr_inr : in std_logic_vector(31 downto 0);

		rb_tx_startr : in std_logic;
		rb_tx_busy   : out std_logic;
		rb_tx_sensor : out std_logic_vector(31 downto 0);  -- For various debug signals

		rb_tx_burstnb_inr : in std_logic_vector(31 downto 0);

		rb_tx_fifor_data : out std_logic_vector(31 downto 0);
		rb_tx_fifor_en   : out std_logic;
		rb_tx_fifor_cnt  : in std_logic_vector(15 downto 0);

		M_AXI_ACLK	: in std_logic;
		M_AXI_ARESETN	: in std_logic;
		M_AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_ARLEN	: out std_logic_vector(7 downto 0);
		M_AXI_ARSIZE	: out std_logic_vector(2 downto 0);
		M_AXI_ARBURST	: out std_logic_vector(1 downto 0);
		M_AXI_ARLOCK	: out std_logic;
		M_AXI_ARCACHE	: out std_logic_vector(3 downto 0);
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		M_AXI_ARQOS	: out std_logic_vector(3 downto 0);
		M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
		M_AXI_ARVALID	: out std_logic;
		M_AXI_ARREADY	: in std_logic;
		M_AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_RRESP	: in std_logic_vector(1 downto 0);
		M_AXI_RLAST	: in std_logic;
		M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
		M_AXI_RVALID	: in std_logic;
		M_AXI_RREADY	: out std_logic
		);
	end component rb_tx_v1_0_M00_AXI;

   -- VGA related stuff
	component vga
		 port(clk				: in  std_logic;          
				hs					: out std_logic;
				vs					: out std_logic;
				r					: out unsigned(4 downto 0);
				g					: out unsigned(5 downto 0);
				b					: out unsigned(4 downto 0);
				irq				: out std_logic;
				fifo_in_data	: in  std_logic_vector(31 downto 0);
				fifo_in_rdy		: out std_logic;
				fifo_in_ack		: in  std_logic);
	end component;

	signal rb_tx_addr_inr		: std_logic_vector(31 downto 0);

	signal rb_tx_burstnb_inr	: std_logic_vector(31 downto 0);

	signal rb_tx_startr			: std_logic;
	signal rb_tx_busy				: std_logic;
	signal rb_tx_sensor			: std_logic_vector(31 downto 0);

	signal rb_tx_fifor_data		: std_logic_vector(31 downto 0);
	signal rb_tx_fifor_en		: std_logic;
	signal rb_tx_fifor_cnt		: std_logic_vector(15 downto 0);

	signal tx_fifo_out_data		: std_logic_vector(31 downto 0);
	signal tx_fifo_out_rdy		: std_logic;
	signal tx_fifo_out_ack		: std_logic;

	signal irq_state				: std_logic;
	signal irq_signal				: std_logic;
	signal iak_signal				: std_logic;

	signal vga_data				: std_logic_vector(31 downto 0);
	signal idle_signal			: std_logic;

begin

-- Instantiation of Axi Bus Interface S00_AXI
rb_tx_v1_0_S00_AXI_inst : rb_tx_v1_0_S00_AXI
	generic map (
		C_S_AXI_MBURST_LEN	=> C_M00_AXI_BURST_LEN,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (

		rb_tx_addr_inr => rb_tx_addr_inr,

		rb_tx_burstnb_inr => rb_tx_burstnb_inr,

		rb_tx_startr => rb_tx_startr,
		rb_tx_busy   => rb_tx_busy,
		rb_tx_sensor => rb_tx_sensor,

		rb_tx_fifor_data => rb_tx_fifor_data,
		rb_tx_fifor_en   => rb_tx_fifor_en,
		rb_tx_fifor_cnt  => rb_tx_fifor_cnt,

		tx_fifo_out_data		=> tx_fifo_out_data,
		tx_fifo_out_rdy		=> tx_fifo_out_rdy,
		tx_fifo_out_ack		=> tx_fifo_out_ack,

		idle                 => idle_signal,

		irq						=> irq_state,
		iak						=> iak_signal,

		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

-- Instantiation of Axi Bus Interface M00_AXI
rb_tx_v1_0_M00_AXI_inst : rb_tx_v1_0_M00_AXI
	generic map (
		C_M_AXI_BURST_LEN		=> C_M00_AXI_BURST_LEN,
		C_M_AXI_ID_WIDTH		=> C_M00_AXI_ID_WIDTH,
		C_M_AXI_ADDR_WIDTH	=> C_M00_AXI_ADDR_WIDTH,
		C_M_AXI_DATA_WIDTH	=> C_M00_AXI_DATA_WIDTH,
		C_M_AXI_AWUSER_WIDTH	=> C_M00_AXI_AWUSER_WIDTH,
		C_M_AXI_ARUSER_WIDTH	=> C_M00_AXI_ARUSER_WIDTH,
		C_M_AXI_WUSER_WIDTH	=> C_M00_AXI_WUSER_WIDTH,
		C_M_AXI_RUSER_WIDTH	=> C_M00_AXI_RUSER_WIDTH,
		C_M_AXI_BUSER_WIDTH	=> C_M00_AXI_BUSER_WIDTH
	)
	port map (

		rb_tx_addr_inr => rb_tx_addr_inr,

		rb_tx_burstnb_inr => rb_tx_burstnb_inr,

		rb_tx_startr => rb_tx_startr,
		rb_tx_busy   => rb_tx_busy,
		rb_tx_sensor => rb_tx_sensor,

		rb_tx_fifor_data => rb_tx_fifor_data,
		rb_tx_fifor_en   => rb_tx_fifor_en,
		rb_tx_fifor_cnt  => rb_tx_fifor_cnt,

		M_AXI_ACLK	=> m00_axi_aclk,
		M_AXI_ARESETN	=> m00_axi_aresetn,
		M_AXI_ARID	=> m00_axi_arid,
		M_AXI_ARADDR	=> m00_axi_araddr,
		M_AXI_ARLEN	=> m00_axi_arlen,
		M_AXI_ARSIZE	=> m00_axi_arsize,
		M_AXI_ARBURST	=> m00_axi_arburst,
		M_AXI_ARLOCK	=> m00_axi_arlock,
		M_AXI_ARCACHE	=> m00_axi_arcache,
		M_AXI_ARPROT	=> m00_axi_arprot,
		M_AXI_ARQOS	=> m00_axi_arqos,
		M_AXI_ARUSER	=> m00_axi_aruser,
		M_AXI_ARVALID	=> m00_axi_arvalid,
		M_AXI_ARREADY	=> m00_axi_arready,
		M_AXI_RID	=> m00_axi_rid,
		M_AXI_RDATA	=> m00_axi_rdata,
		M_AXI_RRESP	=> m00_axi_rresp,
		M_AXI_RLAST	=> m00_axi_rlast,
		M_AXI_RUSER	=> m00_axi_ruser,
		M_AXI_RVALID	=> m00_axi_rvalid,
		M_AXI_RREADY	=> m00_axi_rready
	);

	--
	-- Add user logic here
	--
	-- Draw something when idle so that we know the VGA is alive
	vga_data <= b"1111_0111_0011_0001_0000_1000_1100_1110" when idle_signal = '1' else tx_fifo_out_data;
	-- Instanciate the vga stuff
   vga_engine : vga 
	port map(clk          => s00_axi_aclk,
				hs           => hsync,
				vs           => vsync,
				r            => r,
				g            => g,
				b            => b,
				irq          => irq_signal,
				fifo_in_data => vga_data,
				fifo_in_rdy  => tx_fifo_out_ack,
				fifo_in_ack  => tx_fifo_out_rdy);

	-- Handling the behavior of the interrupt
	irq <= irq_state;

	process (s00_axi_aclk)
	begin
		if rising_edge(s00_axi_aclk) then
			if s00_axi_aresetn = '0' then
					irq_state <= '0';
			else
				if irq_signal = '1' then 
					irq_state <= '1';
				end if;
				if iak_signal = '1' then 
					irq_state <= '0';
				end if;
			end if;
		end if;
	end process;
	--
	-- User logic ends
	--
end arch_imp;
