library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity OAM_BRAM is
    Generic ( 
        PALABRA : integer := 8;
        PROFUNDIDAD : integer := 8);      
    Port (
        clk  : in std_logic;
        cs   : in std_logic;  -- Chip select
        we   : in std_logic;  -- Write enable
        addr : in std_logic_vector(PROFUNDIDAD - 1 downto 0);  -- Direccion
        din  : in std_logic_vector(PALABRA - 1 downto 0);  -- Datos de entrada
        dout : out std_logic_vector(PALABRA - 1 downto 0)  -- Datos de salida
    );
end entity;

architecture rtl of OAM_BRAM is
    type ram_type is array (0 to 2**profundidad - 1) of std_logic_vector(palabra - 1 downto 0);
    signal ram : ram_type := (others => (others => '0'));

begin
    WriteRead : process (clk)
    begin
        if rising_edge(clk) then
            if cs = '1' then    -- Es obligatorio accionar chip select
                if we = '1' then
                    ram(to_integer(unsigned(addr))) <= din;  -- Escritura
                else
                    dout <= ram(to_integer(unsigned(addr)));  -- Lectura
                end if;
            end if;
        end if;
    end process;
end architecture;
