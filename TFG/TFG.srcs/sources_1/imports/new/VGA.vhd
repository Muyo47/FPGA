library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA is
  Port ( clkPLL : in std_logic;
         reset : in std_logic;
         hsinc : out std_logic;
         vsinc : out std_logic;
         visible : out std_logic;
         filas : out std_logic_vector (9 downto 0);
         columnas : out std_logic_vector (9 downto 0);
         vblank : out std_logic;
         row_flag : out std_logic);

end VGA;

architecture Behavioral of VGA is

component contador is
  Generic ( n_bits : integer;     --Bits necesarios para realizar la cuenta deseada
            max_count : integer;
            cont_inicial : integer);     --Generico para asignar la cuenta total a realizar
  Port ( enable : in std_logic;                             --Habilitacion
         clk : in std_logic;                                --Reloj
         count : out std_logic_vector (n_bits-1 downto 0);  --Conteo total
         reset : in std_logic;          --Reset
         fin_cuenta : out std_logic;    --Fin de cuenta
         sentido_c : in std_logic); --0 para ascendente, 1 para descendente
end component;

signal new_line : std_logic;
signal new_frame : std_logic;
signal filas_s : std_logic_vector (9 downto 0);
signal columnas_s : std_logic_vector (9 downto 0);
signal pxl_visible : std_logic;
signal line_visible : std_logic;
begin

conta_cols : contador
    Generic map( n_bits => 10,
                 max_count => 800,      -- 800
                 cont_inicial => 0)    --5 ciclos son 40ns
    Port map( enable => '1',
              clk => clkPLL,
              reset => reset,
              sentido_c => '0',
              fin_cuenta => new_line,
              count => columnas_s );
              
conta_filas : contador
    Generic map( n_bits => 10,
                 max_count => 525,      -- 525
                 cont_inicial => 0)
    Port map ( enable => new_line,
               clk => clkPLL,
               reset => reset,
               sentido_c => '0',
               fin_cuenta => new_frame,
               count => filas_s );
               
               
--hsinc <= '1' when unsigned(columnas_s) < (6+1) or unsigned(columnas_s) > (6+1+9) else '0';       
hsinc <= '1' when unsigned(columnas_s) < (640+16) or unsigned(columnas_s) > (640+16+96) else '0';
--vsinc <= '1' when unsigned(filas_s) < (4+9) or unsigned(filas_s) > (4+1) else '0';     
vsinc <= '1' when unsigned(filas_s) < (480+9) or unsigned(filas_s) > (480+11) else '0';
--pxl_visible <= '1' when unsigned(columnas_s) < 6 else '0';
--line_visible <= '1' when unsigned(filas_s) < 4 else '0';
pxl_visible <= '1' when unsigned(columnas_s) < 640 else '0';
line_visible <= '1' when unsigned(filas_s) < 480 else '0';
visible <= pxl_visible and line_visible;
filas <= filas_s;
vblank <= not line_visible;
columnas <= columnas_s;
row_flag <= new_line;
end Behavioral;
