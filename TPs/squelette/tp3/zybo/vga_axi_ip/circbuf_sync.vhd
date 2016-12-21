
-- FIFO implemented as a circular buffer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity circbuf_sync is
	generic (
		DATAW : natural := 32;
		DEPTH : natural := 8;
		CNTRW : natural := 16
	);
	port (
		reset : in  std_logic;
		clk : in  std_logic;
		fifo_in_data : in  std_logic_vector(DATAW-1 downto 0);
		fifo_in_rdy : out std_logic;
		fifo_in_ack : in  std_logic;
		fifo_out_data : out std_logic_vector(DATAW-1 downto 0);
		fifo_out_rdy : out std_logic;
		fifo_out_ack : in  std_logic;
		cnt : out std_logic_vector(CNTRW-1 downto 0)
	);
end circbuf_sync;

architecture augh of circbuf_sync is

	-- Compute the minimum number of bits needed to store the input value
	function storebitsnb(vin : natural) return natural is
		variable r : natural := 1;
		variable v : natural := vin;
	begin
		loop
			exit when v <= 1;
			r := r + 1;
			v := v / 2;
		end loop;
		return r;
	end function;

	-- Some constants
	constant IDXW : natural := storebitsnb(DEPTH-1);

	-- The embedded memory
	type mem_type is array (0 to DEPTH-1) of std_logic_vector(DATAW-1 downto 0);
	signal mem : mem_type := (others => (others => '0'));

	-- Internal registers
	signal idx_in       : unsigned(IDXW-1 downto 0) := (others => '0');
	signal idx_in_next  : unsigned(IDXW-1 downto 0) := (others => '0');
	signal idx_out      : unsigned(IDXW-1 downto 0) := (others => '0');
	signal idx_out_next : unsigned(IDXW-1 downto 0) := (others => '0');

	signal reg_cnt      : unsigned(CNTRW-1 downto 0) := (others => '0');
	signal reg_cnt_next : unsigned(CNTRW-1 downto 0) := (others => '0');

	signal readbuf : std_logic_vector(DATAW-1 downto 0) := (others => '0');
	signal readbuf_rdy, readbuf_rdy_n : std_logic := '0';

	-- Write enable
	signal wen : std_logic := '0';

begin

	-- Sequential process
	process (clk)
	begin
		if rising_edge(clk) then
			idx_in  <= idx_in_next;
			idx_out <= idx_out_next;
			reg_cnt <= reg_cnt_next;
			-- Write the input value
			if wen = '1' then
				mem(to_integer(idx_in)) <= fifo_in_data;
			end if;
			-- The read buffer and Ready signal
			readbuf <= mem(to_integer(idx_out_next));
			readbuf_rdy <= readbuf_rdy_n;
		end if;
	end process;

	-- Combinatorial process
	process (idx_in, idx_out, fifo_in_ack, fifo_out_ack, reg_cnt, readbuf_rdy, reset)
		variable var_doin  : std_logic := '0';
		variable var_doout : std_logic := '0';
	begin

		-- Default values for ports
		fifo_in_rdy <= '0';

		-- Default values for internal signals and registers
		idx_in_next  <= idx_in;
		idx_out_next <= idx_out;
		reg_cnt_next <= reg_cnt;

		readbuf_rdy_n <= readbuf_rdy;

		wen <= '0';

		-- Default values for the variables
		var_doin  := '0';
		var_doout := '0';

		-- Handle output
		if readbuf_rdy = '1' and fifo_out_ack = '1' then
			var_doout := '1';
			-- Increment index
			if idx_out = DEPTH-1 then
				idx_out_next <= (others => '0');
			else
				idx_out_next <= idx_out + 1;
			end if;
		end if;

		-- Handle input
		if reg_cnt < DEPTH or var_doout = '1' then
			fifo_in_rdy <= '1';
			if fifo_in_ack = '1' then
				wen <= '1';
				var_doin := '1';
				-- Increment index
				if idx_in = DEPTH-1 then
					idx_in_next <= (others => '0');
				else
					idx_in_next <= idx_in + 1;
				end if;
			end if;
		end if;
		-- Next values for the counter
		if var_doin = '1' and var_doout = '0' then
			reg_cnt_next <= reg_cnt + 1;
		end if;
		if var_doin = '0' and var_doout = '1' then
			reg_cnt_next <= reg_cnt - 1;
		end if;

		-- Next value for the out_rdy register
		if reg_cnt = 1 then
			readbuf_rdy_n <= not var_doout;
		end if;

		-- Handle reset
		-- Note: The memory content is not affected by reset
		if reset = '1' then
			idx_in_next  <= (others => '0');
			idx_out_next <= (others => '0');
			reg_cnt_next <= (others => '0');
			readbuf_rdy_n <= '0';
		end if;

	end process;

	-- Assignment of top-level ports
	cnt <= std_logic_vector(reg_cnt);
	fifo_out_data <= readbuf;
	fifo_out_rdy <= readbuf_rdy;

end architecture;

