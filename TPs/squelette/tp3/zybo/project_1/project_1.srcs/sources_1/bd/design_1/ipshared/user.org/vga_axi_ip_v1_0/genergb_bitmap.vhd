library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity genergb is
    port(clk    : in  std_logic;
         data   : in  unsigned(31 downto 0);
         img    : in  std_logic;
         x      : in  unsigned(9 downto 0);
         y      : in  unsigned(8 downto 0);
         r      : out unsigned(4 downto 0);
         g      : out unsigned(5 downto 0);
         b      : out unsigned(4 downto 0);
         irq    : out std_logic;
         n      : out std_logic;   -- next  : pop the fifo
         v      : in  std_logic);  -- valid : is there something meaningfull in that fifo?
end genergb;

architecture behavioral of genergb is
    signal reg   : unsigned(4 downto 0);
    signal cnt   : unsigned(2 downto 0);
    signal pixel : std_logic;
    signal start : std_logic := '0';
begin

   process (clk)
   begin
      if rising_edge(clk) then
         reg <= x(4 downto 0);
      end if;
   end process;

   process (clk)
   begin
      if rising_edge(clk) then
         if img = '0' or cnt = 4 then
            cnt <= (others => '0');
         else
            cnt <= cnt + 1;
         end if;
      end if;
   end process;

   -- Start displaying the image only when :
   -- a) the beam is at the start of the image
   -- b) and the content of the fifo is valid
   process (clk)
   begin
      if rising_edge(clk) then
         if x = 0 and y = 0 and img = '1' and v = '1' then
            start <= '1';
         end if;
      end if;
   end process;

   -- Indicate that we have exhausted the current data
   -- and we should pop the fifo so that we use the next word
   n <= '1' when (start = '1' and img = '1' and reg = 31 and cnt = 4) else '0';

   -- Generate an irq when reaching the last point of the screen
   irq <= '1' when y = 479 and x = 639 else '0';
   
   pixel <=  std_logic(data(31 - to_integer(reg)));
   b <= (pixel,pixel, others => '0');
   g <= (pixel,pixel, others => '0');
   r <= (pixel,pixel, others => '0');
end behavioral;
