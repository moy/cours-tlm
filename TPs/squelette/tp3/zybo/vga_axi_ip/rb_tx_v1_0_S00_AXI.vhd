-- vim:ts=3:noexpandtab:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rb_tx_v1_0_S00_AXI is
	generic (
		-- Users to add parameters here
      SCREEN_SIZE_IN_WORDS : natural := 9600;
		C_S_AXI_MBURST_LEN	: integer	:= 16;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here

		-- Master configuration
		rb_tx_addr_inr		: out std_logic_vector(31 downto 0);
		rb_tx_burstnb_inr : out std_logic_vector(31 downto 0);

		rb_tx_startr		: out std_logic;

		rb_tx_busy			: in std_logic;
		rb_tx_sensor		: in std_logic_vector(31 downto 0);  -- For various debug signals

		-- Data from master to be put into the RX FIFO
		rb_tx_fifor_data	: in std_logic_vector(31 downto 0);
		rb_tx_fifor_en		: in std_logic;
		rb_tx_fifor_cnt	: out std_logic_vector(15 downto 0);

		-- External FIFO interface
		tx_fifo_out_data		: out std_logic_vector(31 downto 0);
		tx_fifo_out_rdy		: out std_logic;
		tx_fifo_out_ack		: in std_logic;

		-- Signal indicating that the VGA is IDLE
		idle                 : out std_logic;

		-- Irq interface
		irq						: in std_logic;
		iak						: out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
				-- privilege and security level of the transaction, and whether
				-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
				-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
				-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave)
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
				-- valid data. There is one write strobe bit for each eight
				-- bits of the write data bus.
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
				-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
				-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
				-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
				-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
				-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
				-- and security level of the transaction, and whether the
				-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
				-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
				-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
				-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
				-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
				-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end rb_tx_v1_0_S00_AXI;

architecture arch_imp of rb_tx_v1_0_S00_AXI is

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 3;

	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------

	---- Number of Slave Registers 16
	signal slv_reg0				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg5				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg6				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg7				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg8				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg9				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg10				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg11				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg12				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg13				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg14				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg15				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_rden			: std_logic;
	signal slv_reg_wren			: std_logic;
	signal slv_reg_rdaddr		: std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	signal slv_reg_wraddr		: std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	signal reg_data_out			: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index				: integer;

	component circbuf_sync is
		generic (
			DATAW : natural := 32;
			DEPTH : natural := 8;
			CNTRW : natural := 16
		);
		port (
			reset				: in  std_logic;
			clk				: in  std_logic;
			fifo_in_data	: in  std_logic_vector(DATAW-1 downto 0);
			fifo_in_rdy		: out std_logic;
			fifo_in_ack		: in  std_logic;
			fifo_out_data	: out std_logic_vector(DATAW-1 downto 0);
			fifo_out_rdy	: out std_logic;
			fifo_out_ack	: in  std_logic;
			cnt				: out std_logic_vector(CNTRW-1 downto 0)
		);
	end component;

	-- TX buffer depth
	constant FIFO_DEPTH        : natural := 64;

	-- RX FIFO signals (FIXME: use the circular buffer generics ?)
	signal rdbuf_clear			: std_logic := '0';
	signal rdbuf_in_data			: std_logic_vector(31 downto 0);
	signal rdbuf_in_rdy			: std_logic := '0';
	signal rdbuf_in_ack			: std_logic := '0';
	signal rdbuf_out_data		: std_logic_vector(31 downto 0);
	signal rdbuf_out_rdy			: std_logic := '0';
	signal rdbuf_out_ack			: std_logic;
	signal rdbuf_cnt				: std_logic_vector(15 downto 0);

	-- Debug counters to check if the FIFOs are correctly driven
	signal rd_pop_cnt				: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal buf_out_ack			: std_logic := '0';

   -- Constant to check for idle
	signal full_zero				: std_logic_vector(31 downto 0) := (others => '0');

begin

	-- I/O Connections assignments
	S_AXI_AWREADY <= axi_awready;
	S_AXI_WREADY  <= axi_wready;
	S_AXI_BRESP   <= axi_bresp;
	S_AXI_BVALID  <= axi_bvalid;
	S_AXI_ARREADY <= axi_arready;
	S_AXI_RDATA   <= axi_rdata;
	S_AXI_RRESP   <= axi_rresp;
	S_AXI_RVALID  <= axi_rvalid;

	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_awready <= '0';
			else
				if axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' then
					-- slave is ready to accept write address when
					-- there is a valid write address and write data
					-- on the write address and data bus. This design
					-- expects no outstanding transactions.
					axi_awready <= '1';
				else
					axi_awready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both
	-- S_AXI_AWVALID and S_AXI_WVALID are valid.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_awaddr <= (others => '0');
			else
				if axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' then
					-- Write Address latching
					axi_awaddr <= S_AXI_AWADDR;
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_wready <= '0';
			else
				if axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' then
					-- slave is ready to accept write data when
					-- there is a valid write address and write data
					-- on the write address and data bus. This design
					-- expects no outstanding transactions.
					axi_wready <= '1';
				else
					axi_wready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;
	slv_reg_wraddr <= axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then -- {
                        iak <= '0';
			-- automatic restart of the reads from memory when reaching the end
			-- dedicated to a "looping" interface
			if rb_tx_busy = '0' and slv_reg0 /= full_zero then
				rb_tx_startr <= '1';
			else
				rb_tx_startr <= '0';
			end if;

			if S_AXI_ARESETN = '0' then -- {
				slv_reg0	<= (others => '0');
				slv_reg1	<= (others => '0');
				slv_reg2	<= (others => '0');
				slv_reg3	<= (others => '0');
				slv_reg4 <= (others => '0');
				slv_reg5 <= (others => '0');
				slv_reg6 <= (others => '0');
				slv_reg7 <= (others => '0');
				slv_reg8 <= (others => '0');
				slv_reg9 <= (others => '0');
				slv_reg10 <= (others => '0');
				slv_reg11 <= (others => '0');
				slv_reg12 <= (others => '0');
				slv_reg13 <= (others => '0');
				slv_reg14 <= (others => '0');
				slv_reg15 <= (others => '0');
			else
				if (slv_reg_wren = '1') then -- {
					case slv_reg_wraddr is
						when b"0000" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 0
									slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

							-- Launch rescan unless address is zero
							--if slv_reg0 /= full_zero then
							--	rb_tx_startr <= '1';
							--end if;

						when b"0001" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 1
									slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"0010" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 2
									slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
							-- Acknowlegde the interrupt if 1 has been written into this register
							iak <= slv_reg2(0);

						when b"0011" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 3
									slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"0100" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 4
									slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"0101" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 5
									slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"0110" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 6
									slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"0111" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 7
									slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"1000" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 8
									slv_reg8(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"1001" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 9
									slv_reg9(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"1010" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 10
									slv_reg10(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"1011" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 11
									slv_reg11(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"1100" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 12
									slv_reg12(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"1101" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 13
									slv_reg13(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"1110" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 14
									slv_reg14(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when b"1111" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index) = '1' then
									-- Respective byte enables are asserted as per write strobes
									-- slave register 15
									slv_reg15(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;

						when others =>
							slv_reg0 <= slv_reg0;
							slv_reg1 <= slv_reg1;
							slv_reg2 <= slv_reg2;
							slv_reg3 <= slv_reg3;
							slv_reg4 <= slv_reg4;
							slv_reg5 <= slv_reg5;
							slv_reg6 <= slv_reg6;
							slv_reg7 <= slv_reg7;
							slv_reg8 <= slv_reg8;
							slv_reg9 <= slv_reg9;
							slv_reg10 <= slv_reg10;
							slv_reg11 <= slv_reg11;
							slv_reg12 <= slv_reg12;
							slv_reg13 <= slv_reg13;
							slv_reg14 <= slv_reg14;
							slv_reg15 <= slv_reg15;
					end case;
				end if; -- }
			end if; -- }
		end if; -- }
	end process;

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
	-- This marks the acceptance of address and indicates the status of
	-- write transaction.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_bvalid  <= '0';
				axi_bresp   <= "00"; --need to work more on the responses
			else
				if axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0' then
					axi_bvalid <= '1';
					axi_bresp  <= "00";
				elsif S_AXI_BREADY = '1' and axi_bvalid = '1' then   --check if bready is asserted while bvalid is high)
					axi_bvalid <= '0';                                --(there is a possibility that bready is always asserted high)
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is
	-- de-asserted when reset (active low) is asserted.
	-- The read address is also latched when S_AXI_ARVALID is
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_arready <= '0';
				axi_araddr  <= (others => '1');
			else
				if axi_arready = '0' and S_AXI_ARVALID = '1' then
					-- indicates that the slave has acceped the valid read address
					axi_arready <= '1';
					-- Read Address latching
					axi_araddr  <= S_AXI_ARADDR;
				else
					axi_arready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers
	-- data are available on the axi_rdata bus at this instance. The
	-- assertion of axi_rvalid marks the validity of read data on the
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are
	-- cleared to zero on reset (active low).

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_rvalid <= '0';
				axi_rresp  <= "00";
			else
				if axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0' then
					-- Valid read data is available at the read data bus
					axi_rvalid <= '1';
					axi_rresp  <= "00"; -- 'OKAY' response
				elsif axi_rvalid = '1' and S_AXI_RREADY = '1' then
					-- Read data is accepted by the master
					axi_rvalid <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.

	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);
	slv_reg_rdaddr <= axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);


	process (
		slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7,
		slv_reg8, slv_reg9, slv_reg10, slv_reg11, slv_reg12, slv_reg13, slv_reg14, slv_reg15,
		rb_tx_busy, rb_tx_sensor, rdbuf_out_data, rdbuf_cnt, rd_pop_cnt,
		axi_araddr, S_AXI_ARESETN, slv_reg_rden, slv_reg_rdaddr, irq
	)
	begin
		-- Address decoding for reading registers
		case slv_reg_rdaddr is
			when b"0000" =>
				reg_data_out <= slv_reg0;
			when b"0001" =>
				reg_data_out <= slv_reg1;
			when b"0010" =>
				reg_data_out <= (others => '0');
				reg_data_out(0) <= irq;
			when b"0011" =>
				reg_data_out <= slv_reg3;
			when b"0100" =>
				reg_data_out <= slv_reg4;
			when b"0101" =>
				reg_data_out <= slv_reg5;
			when b"0110" =>
				reg_data_out <= slv_reg6;
			when b"0111" =>
				reg_data_out <= slv_reg7;

			-- Registers used for outputing debugging information
			when b"1000" =>
				reg_data_out <= (others => '0');
				reg_data_out(0) <= rb_tx_busy;
			when b"1001" =>
				reg_data_out <= rb_tx_sensor;
			when b"1010" =>
				reg_data_out <= rdbuf_out_data;
			when b"1011" =>
				reg_data_out <= (others => '0');
				reg_data_out(15 downto 0) <= rdbuf_cnt;
			when b"1100" =>
				reg_data_out <= rd_pop_cnt;
			when b"1101" =>
				reg_data_out <= slv_reg13;
			when b"1110" =>
				reg_data_out <= slv_reg14;
			when b"1111" =>
				reg_data_out <= slv_reg15;
			when others =>
				reg_data_out  <= (others => '0');
		end case;
	end process;

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
		if rising_edge (S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_rdata  <= (others => '0');
			else
				if (slv_reg_rden = '1') then
					-- When there is a valid read address (S_AXI_ARVALID) with
					-- acceptance of read address by the slave (axi_arready),
					-- output the read dada
					-- Read address mux
					axi_rdata <= reg_data_out;     -- register read data
				end if;
			end if;
		end if;
	end process;


	-- Add user logic here

	-- Process that activates reading the RX FIFO to check its contents, for debug only
	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				buf_out_ack <= '0';
			else
				if slv_reg_rden = '1' and slv_reg_rdaddr = b"0010" then
					buf_out_ack <= '1';
				else 
					buf_out_ack <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Checking RX FIFO counter
	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				rd_pop_cnt <= (others => '0');
			else 
			   if buf_out_ack = '1' then
					rd_pop_cnt <= std_logic_vector(unsigned(rd_pop_cnt) + 1);
				end if;
			end if;
		end if;
	end process;

   -- Register values given to the Master FSM
	rb_tx_addr_inr <= slv_reg0;
	-- Carve up in burst len pieces
	rb_tx_burstnb_inr <= std_logic_vector(to_unsigned(SCREEN_SIZE_IN_WORDS/C_S_AXI_MBURST_LEN, 32));

	-- Indicates if the VGA is idle
	idle <= '1' when slv_reg0 = full_zero else '0';

	-- Instantiate the RX FIFO (read values from memory)
	rdbuf : circbuf_sync
	generic map (
		DATAW => 32,
		DEPTH => FIFO_DEPTH,
		CNTRW => 16
	)
	port map (
		clk           => S_AXI_ACLK,
		reset         => rdbuf_clear,
		fifo_in_data  => rdbuf_in_data,
		fifo_in_rdy   => rdbuf_in_rdy,
		fifo_in_ack   => rdbuf_in_ack,
		fifo_out_data => rdbuf_out_data,
		fifo_out_rdy  => rdbuf_out_rdy,
		fifo_out_ack  => rdbuf_out_ack,
		cnt           => rdbuf_cnt
	);

	rdbuf_clear   <= not S_AXI_ARESETN;
	rdbuf_in_data <= rb_tx_fifor_data;
	rdbuf_in_ack  <= rb_tx_fifor_en;

	rb_tx_fifor_cnt <= std_logic_vector(to_unsigned(FIFO_DEPTH, rb_tx_fifor_cnt'length) - unsigned(rdbuf_cnt));

	tx_fifo_out_data <= rdbuf_out_data;
	tx_fifo_out_rdy  <= rdbuf_out_rdy;
	rdbuf_out_ack    <= tx_fifo_out_ack;

	-- User logic ends

end arch_imp;
