library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top is
  Port ( clk : in std_logic;
         reset : in std_logic;
         clkP : out std_logic;
         clkN : out std_logic;
         dataP : out std_logic_vector (2 downto 0);
         dataN : out std_logic_vector ( 2 downto 0);
         sel_im : in std_logic );
end top;

architecture Behavioral of top is

component contador is
  Generic ( n_bits : integer := 24;     --Bits necesarios para realizar la cuenta deseada
            max_count : integer := 12500000);     --Generico para asignar la cuenta total a realizar
            
            --En el caso de requerir cuentas mayores, cambiar el numero de bits total!
  Port ( enable : in std_logic;                             --Habilitacion
         clk : in std_logic;                                --Reloj
         count : out std_logic_vector (n_bits-1 downto 0);  --Conteo total
         reset : in std_logic;          --Reset
         fin_cuenta : out std_logic;    --Fin de cuenta
         sentido_c : in std_logic); --0 para ascendente, 1 para descendente
        
end component;

component VGA is
  Port ( clkPLL : in std_logic;
         reset : in std_logic;
         hsinc : out std_logic;
         vsinc : out std_logic;
         visible : out std_logic;
         filas : out std_logic_vector (9 downto 0);
         columnas : out std_logic_vector (9 downto 0));
end component;

component hdmi_rgb2tmds is
    generic (
        SERIES6 : boolean := false
    );
    port(
        -- reset and clocks
        rst : in std_logic;
        pixelclock : in std_logic;  -- slow pixel clock 1x
        serialclock : in std_logic; -- fast serial clock 5x

        -- video signals
        video_data : in std_logic_vector(23 downto 0);
        video_active  : in std_logic;
        hsync : in std_logic;
        vsync : in std_logic;

        -- tmds output ports
        clk_p : out std_logic;
        clk_n : out std_logic;
        data_p : out std_logic_vector(2 downto 0);
        data_n : out std_logic_vector(2 downto 0)
    );
end component;

component disp is
  Port (
    -- In ports
    visible      : in std_logic;
    col          : in unsigned(10-1 downto 0);
    fila         : in unsigned(10-1 downto 0);
    --sprite_sel   : in std_logic;
    sprite_data  : in std_logic_vector(32-1 downto 0);
    -- Out ports
    rojo         : out std_logic_vector(8-1 downto 0);
    verde        : out std_logic_vector(8-1 downto 0);
    azul         : out std_logic_vector(8-1 downto 0);
    sprite_dir   : out std_logic_vector(5-1 downto 0)
  );
end component;

component clock_gen is
        generic ( CLKOUT1_DIV : integer := 40; -- pixel clock divider
                  CLKIN_PERIOD : real := 8.000; -- input clock period (8ns)
                  CLK_MULTIPLY : integer := 8; -- multiplier
                  CLK_DIVIDE : integer := 1; -- divider
                  CLKOUT0_DIV : integer := 8 ); -- serial clock divider
         
        port ( clk_i : in std_logic; -- input clock
               clk0_o : out std_logic; -- serial clock
               clk1_o : out std_logic ); -- pixel clock
end component;

component ROM1b_1f_racetrack_1 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0) 
  );
end component;

component ROM_temp is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0) 
  );
end component;

component mux2a1 is
    Generic( bits_en : integer);   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port ( ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 0
           ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 1
           sel_mux : in STD_LOGIC;                                  --Selector del multiplexor
           sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));  --Salida del multiplexor
end component; 

signal clk0_s : std_logic;
signal clk1_s : std_logic;
signal columnas_s : std_logic_vector (9 downto 0);
signal filas_s : std_logic_vector (9 downto 0);
signal rojo_s : std_logic_vector (7 downto 0);
signal verde_s : std_logic_vector (7 downto 0);
signal azul_s : std_logic_vector (7 downto 0);
signal rgb : std_logic_vector (23 downto 0);
signal visible_2_tmds : std_logic;
signal hsinc_2_tmds : std_logic;
signal vsinc_2_tmds : std_logic;

signal rom_dir : std_logic_vector(5-1 downto 0);
signal rom_data : std_logic_vector(32-1 downto 0);
signal rom_data_2 : std_logic_vector(32-1 downto 0);
signal rom_data_3 : std_logic_vector(32-1 downto 0);

begin

PLL : clock_gen
    Port map( clk_i => clk,
              clk0_o => clk0_s,
              clk1_o => clk1_s);

sincrovga : VGA
    Port map( clkPLL => clk1_s,
              reset => reset,
              columnas => columnas_s,
              filas => filas_s,
              visible => visible_2_tmds,
              hsinc => hsinc_2_tmds,
              vsinc => vsinc_2_tmds);

pinta : disp
    Port map( visible => visible_2_tmds, 
              col => unsigned(columnas_s),
              fila => unsigned(filas_s),
              rojo => rojo_s,
              verde => verde_s,
              azul => azul_s,
              --sprite_sel => sel_im,
              sprite_data => rom_data_3,
              sprite_dir => rom_dir);
              
TMDS : hdmi_rgb2tmds
    Port map ( video_data => rgb,
               rst => reset,
               pixelclock => clk1_s,        --25 MHz
               serialclock => clk0_s,       --125 MHz
               video_active => visible_2_tmds,
               hsync => hsinc_2_tmds,
               vsync => vsinc_2_tmds,
               clk_p => clkP,
               clk_n => clkN,
               data_p => dataP,
               data_n => dataN);
               
rom_ejemplo : ROM1b_1f_racetrack_1
    Port map ( clk => clk,
               addr => rom_dir,
               dout => rom_data);
               
rom2 : ROM_temp
    Port map ( clk => clk,
               addr => rom_dir,
               dout => rom_data_2);
               
mux : mux2a1
    Generic map ( bits_en => 32)   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port map ( ent_mux_0 => rom_data,
               ent_mux_1 => rom_data_2,
               sel_mux => sel_im,                                  --Selector del multiplexor
               sal_mux => rom_data_3);

               

rgb <= rojo_s & verde_s & azul_s;
end Behavioral;