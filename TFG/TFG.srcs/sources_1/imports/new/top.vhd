library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( 
        clk : in std_logic;
        reset_n : in std_logic;
        pos_x : in std_logic_vector (32-1 downto 0);
        pos_y : in std_logic_vector (32-1 downto 0);
        gap_x : in std_logic_vector (32-1 downto 0);
        background : in std_logic;
        
        clkP : out std_logic;
        clkN : out std_logic;
        dataP : out std_logic_vector (2 downto 0);
        dataN : out std_logic_vector (2 downto 0)
        );
end top;

architecture rtl of top is

component Detector_flanco is
    Port (
        flanco_in : in std_logic;
        flanco_out : out std_logic;
        clk : in std_logic;
        reset : in std_logic );
end component;

component contador is
    Generic (
        n_bits : integer;
        max_count : integer;
        cont_inicial : integer := 0);
    Port (
        enable : in std_logic;                           
        clk : in std_logic;             
        count : out std_logic_vector (n_bits-1 downto 0);
        reset : in std_logic;
        fin_cuenta : out std_logic;
        sentido_c : in std_logic);
end component;

component contador_pasos is
    Generic (
        cont_inicial : integer := 0);
    Port (
        enable : in std_logic;
        clk : in std_logic;
        count : out std_logic_vector (10-1 downto 0);  -- Suficiente para 32 columnas
        reset : in std_logic;
        fin_cuenta : out std_logic;
        max_count : in std_logic_vector (10-1 downto 0);
        sentido_c : in std_logic);
end component;

component fsm_footprint is
  Port ( clk : in std_logic;
         reset : in std_logic;
         pos_x : in unsigned (10-1 downto 0);
         pos_y : in unsigned (10-1 downto 0);
         filas : in unsigned (10-1 downto 0);
         columnas : in unsigned (10-1 downto 0);

         en_gap_cnt : out std_logic;
         trigger_first_ftprint : out std_logic);
end component;

component tilemap_buffer is
    Generic ( 
        PALABRA : integer := 32;
        PROFUNDIDAD : integer := 3);      
    Port (
        clk  : in std_logic;
        cs   : in std_logic;  -- Chip select
        we   : in std_logic;  -- Write enable
        addr : in std_logic_vector(PROFUNDIDAD - 1 downto 0);  -- Direccion
        din  : in std_logic_vector(PALABRA - 1 downto 0);  -- Datos de entrada
        dout : out std_logic_vector(PALABRA - 1 downto 0)  -- Datos de salida
    );
end component;

component VGA is
    Port (
        clkPLL : in std_logic;
        reset : in std_logic;
        hsinc : out std_logic;
        vsinc : out std_logic;
        visible : out std_logic;
        filas : out std_logic_vector (9 downto 0);
        columnas : out std_logic_vector (9 downto 0);
        vblank : out std_logic;
        row_flag : out std_logic);
end component;

component hdmi_rgb2tmds is
    Generic (
        SERIES6 : boolean := false);
    Port(
        -- reset and clocks
        rst : in std_logic;
        pixelclock : in std_logic;  -- Slow pixel clock 1x
        serialclock : in std_logic; -- Fast serial clock 5x

        -- video signals
        video_data : in std_logic_vector(23 downto 0);
        video_active  : in std_logic;
        hsync : in std_logic;
        vsync : in std_logic;

        -- tmds output ports
        clk_p : out std_logic;
        clk_n : out std_logic;
        data_p : out std_logic_vector(2 downto 0);
        data_n : out std_logic_vector(2 downto 0));
end component;

component disp is
    Port (
        -- In ports
        visible        : in std_logic;
        col            : in unsigned(10-1 downto 0);
        fila           : in unsigned(10-1 downto 0);
        sprite_data    : in std_logic_vector(16-1 downto 0);
        sprite_data_2  : in std_logic_vector(16-1 downto 0);
        trigger        : in std_logic;
        gap_count_disp : in std_logic_vector (10-1 downto 0);
        trigger_col_cnt_disp : in std_logic_vector (10-1 downto 0);
        -- Out ports
        rojo           : out std_logic_vector(8-1 downto 0);
        verde          : out std_logic_vector(8-1 downto 0);
        azul           : out std_logic_vector(8-1 downto 0);
        sprite_dir     : out std_logic_vector(8-1 downto 0);
        sprite_dir_2   : out std_logic_vector(8-1 downto 0));
end component;

component clock_gen is
    Generic (
        CLKOUT1_DIV : integer := 40; -- pixel clock divider
        CLKIN_PERIOD : real := 8.000; -- input clock period (8ns)
        CLK_MULTIPLY : integer := 8; -- multiplier
        CLK_DIVIDE : integer := 1; -- divider
        CLKOUT0_DIV : integer := 8 ); -- serial clock divider        
    Port (
        clk_i : in std_logic; -- input clock
        clk0_o : out std_logic; -- serial clock
        clk1_o : out std_logic ); -- pixel clock
end component;

component ROMx2 is
    Port (
        clk  : in  std_logic;   -- reloj
        addr : in  std_logic_vector(8-1 downto 0);
        dout : out std_logic_vector(16-1 downto 0));
end component;

component ROMx is
    Port (
        clk  : in  std_logic;   -- reloj
        addr : in  std_logic_vector(8-1 downto 0);
        dout : out std_logic_vector(16-1 downto 0));
end component;

component mux2a1 is
    Generic (
        bits_en : integer);
    Port (
        ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 0
        ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 1
        sel_mux : in STD_LOGIC;                                  --Selector del multiplexor
        sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));  --Salida del multiplexor
end component;

component biestableT is
  Port ( clk : in std_logic;    --Reloj
         enable : in std_logic; --Habilitacion
         reset : in std_logic;  --Reset
         data : in std_logic;   --Entrada del codigo de operacion al biestable
         output_data : out std_logic );     --Salida conmutada de datos del biestable
end component;

-- Señal de reset activa bajo
signal reset : std_logic;

-- Reloj basico de 125 MHz y reloj pll pixel clock de 25 MHz
signal clk0_s : std_logic;
signal clk1_s : std_logic;

-- Señales para display VGA
signal columnas_s : std_logic_vector (10-1 downto 0);
signal filas_s : std_logic_vector (10-1 downto 0);
signal rojo_s : std_logic_vector (8-1 downto 0);
signal verde_s : std_logic_vector (8-1 downto 0);
signal azul_s : std_logic_vector (8-1 downto 0);
signal rgb : std_logic_vector (24-1 downto 0);
signal visible_2_tmds : std_logic;
signal hsinc_2_tmds : std_logic;
signal vsinc_2_tmds : std_logic;
signal row_flag_s : std_logic;

-- Señales de gestion de memorias ROM
signal rom_dir : std_logic_vector(8-1 downto 0);
signal rom_dir_2 : std_logic_vector(8-1 downto 0);
signal rom_data : std_logic_vector(16-1 downto 0);
signal rom_data_2 : std_logic_vector(16-1 downto 0);

-- BRAM adicional mux
signal background_s : std_logic_vector(4-1 downto 0);

-- BRAM y tabla de nombres
signal dir_tnombres : std_logic_vector(10-1 downto 0);
signal dout_tnombres : std_logic_vector(4-1 downto 0);
signal dout_tnombres2 : std_logic_vector(4-1 downto 0);

-- Temporal
-- No se muy bien que he hecho aqui, intentar limpiar nombre de señales y eliminar no usadas
signal vblank_s : std_logic;
signal trigger_gap_cnt : std_logic;
signal en_gap_cnt : std_logic;
signal vblank_flank : std_logic;
signal vblank_inv : std_logic;
signal reset_gap_cnt : std_logic;
signal trigger_huella : std_logic;
signal trigger_first_ftprint : std_logic;
signal gap_count_disp : std_logic_vector (10-1 downto 0);

signal en_row_gap_cnt : std_logic;
signal cs_cnt_col_gap : std_logic;
signal fc_cnt_col_gap : std_logic;
signal en_cnt_col_gap : std_logic;
signal gap_col_count_disp : std_logic_vector (10-1 downto 0);

begin

PLL : clock_gen
    Port map(
        clk_i => clk,
        clk0_o => clk0_s,
        clk1_o => clk1_s
        );

sincrovga : VGA
    Port map(
        clkPLL => clk1_s,
        reset => reset,
        columnas => columnas_s,
        filas => filas_s,
        visible => visible_2_tmds,
        hsinc => hsinc_2_tmds,
        vsinc => vsinc_2_tmds,
        vblank => vblank_s,
        row_flag => row_flag_s
        );

pinta : disp
    Port map(
        visible => visible_2_tmds, 
        col => unsigned(columnas_s),
        fila => unsigned(filas_s),
        rojo => rojo_s,
        verde => verde_s,
        azul => azul_s,
        sprite_data => rom_data,
        sprite_data_2 => rom_data_2,
        sprite_dir => rom_dir,
        sprite_dir_2 => rom_dir_2,
        trigger => trigger_huella,
        gap_count_disp => gap_count_disp,
        trigger_col_cnt_disp => gap_col_count_disp
        );
              
TMDS : hdmi_rgb2tmds
    Port map (
        video_data => rgb,
        rst => reset,
        pixelclock => clk1_s,        -- 25 MHz
        serialclock => clk0_s,       -- 125 MHz
        video_active => visible_2_tmds,
        hsync => hsinc_2_tmds,
        vsync => vsinc_2_tmds,
        clk_p => clkP,
        clk_n => clkN,
        data_p => dataP,
        data_n => dataN
        );
                              
plano0ROM : ROMx     -- Plano 0 patron
    Port map (
        clk => clk1_s,
        addr => rom_dir,
        dout => rom_data
        );
               
plano1ROM : ROMx2     -- Plano 1 patron
    Port map (
        clk => clk1_s,
        addr => rom_dir_2,
        dout => rom_data_2
        );
     
mux : mux2a1
    Generic map (
        bits_en => 4)
    Port map (
        ent_mux_0 => dout_tnombres,
        ent_mux_1 => dout_tnombres2,
        sel_mux => background,
        sal_mux => background_s
        );

maquina_huellas : fsm_footprint
    Port map(
        -- In ports
        clk => clk1_s,
        reset => reset,
        pos_x => unsigned(pos_x(10-1 downto 0)),
        pos_y => unsigned(pos_y(10-1 downto 0)),
        filas => unsigned(filas_s),
        columnas => unsigned(columnas_s),

        -- Out ports
        en_gap_cnt => en_gap_cnt,
        trigger_first_ftprint => trigger_first_ftprint
        );

contador_gap : contador_pasos
    Generic map(
        cont_inicial => 0)
    Port map(
        clk => clk1_s,      -- 25 MHz ya que debe contar columnas
        enable => en_gap_cnt,
        reset => reset_gap_cnt,
        sentido_c => '0',
        max_count => gap_x(10-1 downto 0),
        fin_cuenta => trigger_gap_cnt
        );

contador_fila_rom_gap : contador_pasos
    Generic map(
        cont_inicial => 0)
    Port map(
        clk => clk1_s,      -- 25 MHz ya que debe contar columnas
        enable => en_row_gap_cnt,
        reset => reset_gap_cnt,
        sentido_c => '0',
        count => gap_count_disp,
        max_count => "0000001111"       -- De momento limitamos asi
        --fin_cuenta => trigger_gap_cnt
        );

contador_columnas_gap : contador_pasos
    Generic map(
        cont_inicial => 0)
    Port map(
        clk => clk1_s,      -- 25 MHz ya que debe contar columnas
        enable => en_cnt_col_gap,
        reset => reset_gap_cnt,
        sentido_c => '0',
        count => gap_col_count_disp,
        max_count => "0000001111",       -- De momento limitamos asi
        fin_cuenta => fc_cnt_col_gap
        );

cs_contador_col : biestableT
    Port map (
        clk => clk1_s,
        reset => reset,
        data => cs_cnt_col_gap,
        output_data => en_cnt_col_gap,
        enable => '1'
    );

vb_flank : Detector_flanco
    Port map(
        clk => clk1_s,
        reset => reset,
        flanco_in => vblank_s,
        flanco_out => vblank_flank
        );

--tilemap_buffer : buff1
--    Generic map ( 
--        PALABRA => 32,
--        PROFUNDIDAD => 3)    
--    Port map (
--        clk  => clk1_s,
--        cs   => trigger_huella,
--        we   => trigger_huella,
--        addr : in std_logic_vector(PROFUNDIDAD - 1 downto 0);  -- Direccion
--        din  : in std_logic_vector(PALABRA - 1 downto 0);  -- Datos de entrada
--        dout : out std_logic_vector(PALABRA - 1 downto 0)  -- Datos de salida
--    );
        
rgb <= rojo_s & verde_s & azul_s;
dir_tnombres <= filas_s (9-1 downto 4) & columnas_s (9-1 downto 4);

reset <= not reset_n;

vblank_inv <= not vblank_s;

trigger_huella <= trigger_gap_cnt or trigger_first_ftprint;

reset_gap_cnt <= reset or vblank_flank;

en_row_gap_cnt <= row_flag_s and en_gap_cnt;

cs_cnt_col_gap <= fc_cnt_col_gap or trigger_gap_cnt;

end rtl;





