library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_BASEADDR                   -- User logic base address
--   C_HIGHADDR                   -- User logic high address
--   C_OPB_AWIDTH                 -- OPB address bus width
--   C_OPB_DWIDTH                 -- OPB data bus width
--   C_FAMILY                     -- Target FPGA architecture
--
-- Definition of Ports:
--   OPB_Clk                      -- OPB Clock
--   OPB_Rst                      -- OPB Reset
--   Sl_DBus                      -- Slave data bus
--   Sl_errAck                    -- Slave error acknowledge
--   Sl_retry                     -- Slave retry
--   Sl_toutSup                   -- Slave timeout suppress
--   Sl_xferAck                   -- Slave transfer acknowledge
--   OPB_ABus                     -- OPB address bus
--   OPB_BE                       -- OPB byte enable
--   OPB_DBus                     -- OPB data bus
--   OPB_RNW                      -- OPB read/not write
--   OPB_select                   -- OPB select
--   OPB_seqAddr                  -- OPB sequential address
--   M_ABus                       -- Master address bus
--   M_BE                         -- Master byte enables
--   M_busLock                    -- Master buslock
--   M_request                    -- Master bus request
--   M_RNW                        -- Master read, not write
--   M_select                     -- Master select
--   M_seqAddr                    -- Master sequential address
--   OPB_errAck                   -- OPB error acknowledge
--   OPB_MGrant                   -- OPB bus grant
--   OPB_retry                    -- OPB bus cycle retry
--   OPB_timeout                  -- OPB timeout error
--   OPB_xferAck                  -- OPB transfer acknowledge
------------------------------------------------------------------------------

entity opb_vga is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_BASEADDR                     : std_logic_vector     := X"12340000"; -- remettre X"FFFFFFFF"
    C_HIGHADDR                     : std_logic_vector     := X"FFFFFFFF"; -- remettre X"00000000"
    C_OPB_AWIDTH                   : integer              := 32;
    C_OPB_DWIDTH                   : integer              := 32;
    C_FAMILY                       : string               := "virtex2p"
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    HSYNC : out std_logic;
    VSYNC : out std_logic;
    RED,GREEN,BLUE : out std_logic;
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    IP2INTC_Irpt : out std_logic;
    OPB_Clk                        : in  std_logic;
    OPB_Rst                        : in  std_logic;
    Sl_DBus                        : out std_logic_vector(0 to C_OPB_DWIDTH-1);
    Sl_errAck                      : out std_logic;
    Sl_retry                       : out std_logic;
    Sl_toutSup                     : out std_logic;
    Sl_xferAck                     : out std_logic;
    OPB_ABus                       : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
    OPB_BE                         : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
    OPB_DBus                       : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
    OPB_RNW                        : in  std_logic;
    OPB_select                     : in  std_logic;
    OPB_seqAddr                    : in  std_logic;
    M_ABus                         : out std_logic_vector(0 to C_OPB_AWIDTH-1);
    M_BE                           : out std_logic_vector(0 to C_OPB_DWIDTH/8-1);
    M_busLock                      : out std_logic;
    M_request                      : out std_logic;
    M_RNW                          : out std_logic;
    M_select                       : out std_logic;
    M_seqAddr                      : out std_logic;
    OPB_errAck                     : in  std_logic;
    OPB_MGrant                     : in  std_logic;
    OPB_retry                      : in  std_logic;
    OPB_timeout                    : in  std_logic;
    OPB_xferAck                    : in  std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute SIGIS : string;
  attribute SIGIS of OPB_Clk       : signal is "Clk";
  attribute SIGIS of OPB_Rst       : signal is "Rst";
end entity opb_vga;



-- Definition de l'architecture
architecture IMP of opb_vga is
   -- Signaux pour l'automate OPB
   type TypeEtat_OPB is (IDLE,ReqOPB,SelectOPB);
   signal etatP,etatS : TypeEtat_OPB;
   type TypeEtat_sOPB is (IDLE,WriteConfig,ReadConfig,WriteStatus,ReadStatus,WriteInt,ReadInt);
   signal etatPs,etatSs : TypeEtat_sOPB;
   signal E_Data : std_logic;
   signal Data : std_logic_vector(0 to 63):=X"0000000000000000";
   signal IMG :  std_logic;
   signal X :  std_logic_vector(0 to 10);
   signal Y :  std_logic_vector(0 to 9);
   signal comptX : std_logic_vector (0 to 10);
   signal comptY : std_logic_vector (0 to 9);
   signal pulseX : std_logic;
   signal pulseY: std_logic;
   signal IMGX : std_logic;
   signal IMGY : std_logic;
   signal LectX : std_logic;
   signal E_Config, E_Status, E_Int : std_logic;
   signal Pixel : std_logic;
   signal AD : std_logic_vector(0 to C_OPB_AWIDTH-1);
   signal AD_debut: std_logic_vector(0 to C_OPB_AWIDTH-1) := X"00000000";
   signal Interrupt : std_logic;
begin

   -- Registres d'etat Maitre/Escalve OPB
   process (OPB_CLK,OPB_Rst)
   begin  -- process
      if OPB_Rst= '1' then -- asynchronous reset (active low)
         etatP<=IDLE;
         etatPs<=IDLE;
      elsif (OPB_CLK'event and OPB_CLK = '1') then -- rising clock edge
         etatP<=etatS;
         etatPs<=etatSs;
         if (E_Config='1') then
            AD_debut<=OPB_Dbus;
         end if;
      end if;
   end process;

   IP2INTC_Irpt <= '1' when (comptY=(2+29+480)) else '0';

   process (OPB_CLK, OPB_Rst)
     begin
      if OPB_Rst = '1' then
         Interrupt <= '0';
      elsif (OPB_CLK'event and OPB_CLK = '1') then
         if (E_Int='1') then
            Interrupt <= '0';
         elsif (comptY=(2+29+480)) then
            Interrupt <= '1';
         end if;
      end if;
   end process;

   -- Automate Esclave OPB
   process (etatPs,OPB_ABus,OPB_RNW,OPB_Select,AD_Debut,LectX,IMGY)
   begin
      E_Int<='0';
      E_Config<='0';
      Sl_xferAck<='0';
      Sl_DBus<=(others => '0');
      Sl_errAck<='0';
      Sl_retry<='0';
      Sl_toutSup<='0';
      case etatPs is
         when IDLE => 
            if (OPB_Select ='1' and OPB_ABus>=C_BASEADDR and OPB_ABus<=C_HIGHADDR) then
               if (OPB_ABus<=C_BASEADDR) then
                  if (OPB_RNW='1') then 
                     etatSs <= ReadConfig;
                  else
                     etatSs <= WriteConfig;
                  end if;
               elsif (OPB_ABus<=C_BASEADDR+4) then
                  if (OPB_RNW='1') then 
                     etatSs <= ReadStatus;
                  else
                     etatSs <= WriteStatus;
                  end if;
               elsif (OPB_ABus<=C_BASEADDR+8) then
                  if (OPB_RNW='1') then 
                     etatSs <= ReadInt;
                  else
                     etatSs <= WriteInt;
                  end if;
               else 
                  etatSs<=IDLE;
               end if;
            else 
               etatSs<=IDLE;
            end if;
         when WriteConfig =>
            E_Config<='1';
            etatSs<=IDLE;
            Sl_xferAck<='1';
         when ReadConfig =>
            Sl_DBus<=AD_Debut;
            Sl_xferAck<='1';
            etatSs<=IDLE;
         when WriteStatus =>
            E_Status<='1';
            etatSs<=IDLE;
            Sl_xferAck<='1';
         when ReadStatus =>
            Sl_DBus<=(others => '1');
            Sl_xferAck<='1';
            etatSs<=IDLE;
         when WriteInt =>
            E_Int<='1';
            etatSs<=IDLE;
            Sl_xferAck<='1';
         when ReadInt =>
            Sl_DBus<=(31 => Interrupt, others => '0');
            Sl_xferAck<='1';
            etatSs<=IDLE;
      end case;
   end process;

   -- Automate Maitre OPB
   process (etatP,X,AD,OPB_MGrant,OPB_timeout,OPB_errAck,OPB_xferAck)
   begin  
      E_Data<='0';
      M_ABus<=(others =>'0');
      M_BE<=(others =>'0');
      M_busLock<='0';
      M_request<='0';
      M_RNW<='0';
      M_select<='0';
      M_seqAddr<='0';
      case etatP is
      when IDLE => 
         if ( LectX='1' and IMGY='1' and X(5 to 10)="000001") then 
            etatS<=ReqOPB;
         else
            etatS<=IDLE;
         end if;
      when ReqOPB =>
         M_request<='1';
         if (OPB_MGrant ='1') then
            etatS<=SelectOPB;
         elsif (OPB_timeout='1' OR OPB_errAck='1') then 
            etatS<=IDLE;
         else 
            etatS<=ReqOPB;
         end if;
      when SelectOPB =>
         M_select<='1';
         M_ABus<=AD;
         M_BE<=(others =>'1');
         M_RNW<='1';
         if (OPB_xferAck ='1') then
            etatS<=IDLE;
            E_Data<='1';
         elsif (OPB_timeout='1' OR OPB_errAck='1') then 
            etatS<=IDLE;
         else 
            etatS<=SelectOPB;
         end if;
      end case;
   end process;
   
   -- Partie concernant le VGA
   HSYNC<=pulseX;
   VSYNC<=pulseY;
   IMG<=IMGX AND IMGY;
   AD <= (X"0000" & Y (1 to 9) & X(0 to 4) & "00") OR (AD_debut AND X"FFFF0000");
   RED<=Pixel;
   GREEN<=Pixel;
   BLUE<=Pixel;

   -- Lecture des mots pour la carte VGA
   process (OPB_CLK)
   begin
      if (OPB_CLK'event and OPB_CLK = '1') then
         if (E_Data='1' and X(4)='1' ) then
               Data(0 to 31)<=OPB_DBUS;
         elsif (E_Data='1' and X(4)='0' ) then
               Data(32 to 63)<=OPB_DBUS;
         end if;
      end if;
   end process;

   process (OPB_Clk)
   begin
      if (OPB_CLK'event and OPB_CLK='1') then
         if comptX<(2*800) then
            comptX<=comptX+1;
         else
            comptX<=(others => '0');
         end if;
         if comptX=0 then 
            if comptY<521 then 
               comptY<=comptY+1;
            else
               comptY<=(others => '0');
            end if;
         end if;
      end if;
   end process;

   process (comptX)
   begin 
      if (comptX<(96*2)) then 
         X<=(others => '0'); pulseX<='0';IMGX<='0'; LectX<='0';
      elsif (comptX<((96+48-32)*2)) then 
         X<=(others => '0');pulseX<='1';   IMGX<='0'; LectX<='0';
      elsif (comptX<((96+48)*2)) then 
         X<=comptX-((96+48-32)*2);pulseX<='1';   IMGX<='0'; LectX<='1';
      elsif (comptX<((96+48+640)*2)) then 
         X<=comptX-((96+48-32)*2);IMGX<='1';pulseX<='1'; LectX<='1';
      else 
         X<=(others => '0');pulseX<='1';   IMGX<='0'; LectX<='0';
      end if;
   end process;

   process (comptY)
   begin 
      if (comptY<2) then 
         Y<=(others => '0');pulseY<='0';IMGY<='0';
      elsif (comptY<(2+29)) then 
         Y<=(others => '0');pulseY<='1';   IMGY<='0';
      elsif (comptY<((2+29+480))) then 
         Y<=(comptY-2-29);pulseY<='1';IMGY<='1';
      else 
         Y<=(others => '0');pulseY<='1';IMGY<='0';
      end if;
   end process;

   process (X,IMG,Data)
   begin 
      if (IMG='1') then 
         Pixel<=Data(conv_integer(X(4 to 9)));
      else   
         Pixel <='0';
      end if;
   end process;
end IMP;
