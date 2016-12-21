library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
    port(clk          : in  std_logic;          
         hs           : out std_logic;
         vs           : out std_logic;
         r            : out unsigned(4 downto 0);
         g            : out unsigned(5 downto 0);
         b            : out unsigned(4 downto 0);
         irq          : out std_logic;
         fifo_in_data : in  std_logic_vector(31 downto 0);
         fifo_in_rdy  : out std_logic;
         fifo_in_ack  : in  std_logic);
end vga;

architecture behavioral of vga is 
   component genesync
      port(clk   : in  std_logic;
           hsync : out std_logic;
           vsync : out std_logic;
           img   : out std_logic;
           x     : out unsigned(9 downto 0);
           y     : out unsigned(8 downto 0));
   end component;

   component genergb
      port (clk    : in  std_logic;
            data   : in  unsigned(31 downto 0);
            img    : in  std_logic;           
            x      : in  unsigned(9 downto 0);
            y      : in  unsigned(8 downto 0);
            r      : out unsigned(4 downto 0);
            g      : out unsigned(5 downto 0);
            b      : out unsigned(4 downto 0);
            irq    : out std_logic;           
            n      : out std_logic;
            v      : in  std_logic);
   end component;

   signal xi :        unsigned(9 downto 0);
   signal yi :        unsigned(8 downto 0);
   signal imgi,imgii: std_logic;
   signal hsi, vsi:   std_logic;
   signal ri :        unsigned(4 downto 0);
   signal gi :        unsigned(5 downto 0);
   signal bi :        unsigned(4 downto 0);

begin
   cgenesync: genesync
   port map(clk => clk, hsync => hsi, vsync => vsi, img => imgi, x => xi, y => yi);

   process (clk)
   begin
      if rising_edge(clk) then
         hs    <= hsi;
         vs    <= vsi;
         imgii <= imgi;
      end if;
   end process;


   cgenegrb: genergb
   port map(clk => clk, img => imgi, x => xi, y => yi, r => ri, g => gi, b => bi,
            data => unsigned(fifo_in_data), irq => irq, n => fifo_in_rdy, v => fifo_in_ack);

   r <= ri when imgii ='1' else (others =>'0');
   g <= gi when imgii ='1' else (others =>'0');
   b <= bi when imgii ='1' else (others =>'0');

end behavioral;
