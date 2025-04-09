library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top is
  Port ( clk : in std_logic;
         reset : in std_logic;
         clkP : out std_logic;
         clkN : out std_logic;
         dataP : out std_logic_vector (2 downto 0);
         dataN : out std_logic_vector (2 downto 0);
         palsel : in std_logic;
         btn_img : in std_logic;
         weBRAM : in std_logic;
         addrBRAM : in std_logic_vector (8-1 downto 0);
         dinBRAM : in std_logic_vector (8-1 downto 0);
         chipSelectBRAM : in std_logic;
         btnLEDS : in std_logic;
         LEDS : out std_logic_vector(4-1 downto 0));
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

component tabla_dir is
  port (
    clk  : in  std_logic;   -- Reloj
    addr : in  std_logic_vector(10-1 downto 0); -- Dirección de 10 bits (30x32 = 960 posiciones)
    dout : out std_logic_vector(4-1 downto 0) -- Datos de 3 bits
  );
end component;

component tabla_dir2 is
  port (
    clk  : in  std_logic;   -- Reloj
    addr : in  std_logic_vector(10-1 downto 0); -- Dirección de 10 bits (30x32 = 960 posiciones)
    dout : out std_logic_vector(4-1 downto 0) -- Datos de 3 bits
  );
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
    sprite_sel   : in std_logic_vector (4-1 downto 0);
    sprite_data  : in std_logic_vector(16-1 downto 0);
    sprite_data_2  : in std_logic_vector(16-1 downto 0);
    paleta_sel   : in std_logic;
    -- Out ports
    rojo         : out std_logic_vector(8-1 downto 0);
    verde        : out std_logic_vector(8-1 downto 0);
    azul         : out std_logic_vector(8-1 downto 0);
    sprite_dir   : out std_logic_vector(8-1 downto 0);
    sprite_dir_2 : out std_logic_vector(8-1 downto 0)
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

component ROMx2 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(8-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

component ROMx is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(8-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

component mux2a1 is
    Generic( bits_en : integer);   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port ( ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 0
           ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 1
           sel_mux : in STD_LOGIC;                                  --Selector del multiplexor
           sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));  --Salida del multiplexor
end component;

component OAM_BRAM is
    Generic (
        PALABRA : integer := 8;
        PROFUNDIDAD : integer := 8);
    Port (
        clk     : in std_logic;
        cs      : in std_logic;
        we      : in std_logic;  -- Señal de escritura (1 = escribir, 0 = leer)
        addr    : in std_logic_vector(8-1 downto 0);  -- Direccion (256 posiciones)
        din     : in std_logic_vector(7 downto 0);  -- Datos de entrada
        dout    : out std_logic_vector(7 downto 0)  -- Datos de salida
    );
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

signal rom_dir : std_logic_vector(8-1 downto 0);
signal rom_dir_2 : std_logic_vector(8-1 downto 0);
signal rom_data : std_logic_vector(16-1 downto 0);
signal rom_data_2 : std_logic_vector(16-1 downto 0);

signal seleccion_img : std_logic_vector(4-1 downto 0);

signal dir_tnombres : std_logic_vector(10-1 downto 0);
signal dout_tnombres : std_logic_vector(4-1 downto 0);
signal dout_tnombres2 : std_logic_vector(4-1 downto 0);
signal doutBRAM : std_logic_vector (8-1 downto 0);

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
              --paleta_sel => palsel,
              sprite_sel => seleccion_img,
              paleta_sel => doutBRAM(3),
              --sprite_sel => doutBRAM (3-1 downto 0),
              sprite_data => rom_data,
              sprite_data_2 => rom_data_2,
              sprite_dir => rom_dir,
              sprite_dir_2 => rom_dir_2);
              
tnombres : tabla_dir
  port map ( clk => clk,
             addr => dir_tnombres,
             dout=> dout_tnombres);
             
tnombres_2 : tabla_dir2
  port map ( clk => clk,
             addr => dir_tnombres,
             dout=> dout_tnombres2);
              
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
                              
plano0ROM : ROMx     --Plano 0 patron
    Port map ( clk => clk,
               addr => rom_dir,
               dout => rom_data);
               
plano1ROM : ROMx2     -- Plano 1 patron
    Port map ( clk => clk,
               addr => rom_dir_2,
               dout => rom_data_2);

               
mux : mux2a1
    Generic map ( bits_en => 4)   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port map ( ent_mux_0 => dout_tnombres,
               ent_mux_1 => dout_tnombres2,
               --sel_mux => btn_img,   --Selector del multiplexor
               sel_mux => doutBRAM(0),
               sal_mux => seleccion_img);
               
RAMoam : OAM_BRAM
    Generic map ( 
        PALABRA => 8,
        PROFUNDIDAD => 8)            
    Port map (
        clk => clk,
        cs => chipSelectBRAM,
        --cs => '1',
        we => weBRAM,     -- Señal de escritura (1 = escribir, 0 = leer)
        addr => addrBRAM,  -- Direccion (256 posiciones)
        din => dinBRAM,
        dout => doutBRAM);


--lectura_BRAM : process (clk, reset, btnLEDS)
--begin
--    if reset = '1' then
--        LEDS <= (others => ('0'));
--    elsif rising_edge (clk) then
--        if btnLEDS = '1' then
--            LEDS <= doutBRAM(4-1 downto 0);
--        end if;
--    end if;
--end process;
               
--im_cambio : process (clk, reset)
--begin
--    if reset = '1' then
--        seleccion_img <= (others => '0');
--    elsif rising_edge (clk) then
--        if btn_img = '1' then
--            if seleccion_img = "110" then
--                seleccion_img <= (others => '0');
--            else
--                seleccion_img <= std_logic_vector(unsigned(seleccion_img) + 1);
--            end if;
--        end if;
--    end if;
--end process;

rgb <= rojo_s & verde_s & azul_s;
dir_tnombres <= filas_s (9-1 downto 4) & columnas_s (9-1 downto 4);
LEDS <= doutBRAM(4-1 downto 0);
end Behavioral;