-- SIMULACION DE CALIDAD

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity topTestBench is
end topTestBench;

architecture qualitySim of topTestBench is

component top is
    Port ( 
        clk : in std_logic;
        reset_n : in std_logic;
        pos_x : in std_logic_vector (32-1 downto 0);
        pos_y : in std_logic_vector (32-1 downto 0);
        gap_x : in std_logic_vector (32-1 downto 0);
        background : in std_logic;
        
        clkP : out std_logic;       -- HDMI
        clkN : out std_logic;       -- HDMI
        dataP : out std_logic_vector (2 downto 0);      -- HDMI
        dataN : out std_logic_vector (2 downto 0));      -- HDMI
end component;

-- Senales
signal clk_tb          : std_logic := '0';
signal reset_tb        : std_logic := '0';
signal pos_x_tb        : std_logic_vector(32 - 1 downto 0);
signal pos_y_tb        : std_logic_vector(32 - 1 downto 0);
signal gap_x_tb        : std_logic_vector(32 - 1 downto 0);
signal background_tb   : std_logic := '0';

begin

    -- Instanciacion de TOP
    topinst : top
        Port map (
            clk            => clk_tb,
            reset_n        => reset_tb,
            pos_x          => pos_x_tb,
            pos_y          => pos_y_tb,
            gap_x          => gap_x_tb,
            background     => background_tb);

    -- Generacion de reloj
    clk_process : process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;

    stim_proc : process
        procedure log(s : string) is
        begin
            report "[LOG] " & s severity note;
        end;

        procedure wait_clock(n : integer) is
        begin
            for i in 1 to n loop
                wait until rising_edge(clk_tb);
            end loop;
        end;

    begin
        log("Inicio de simulacion: Reset activo.");
        wait_clock(2);
        reset_tb <= '1';
        log("Reset desactivado. Comienza test.");

        -- Configuracion inicial y valores constantes (diferentes) para normal y mirror
        background_tb <= '0';
        gap_x_tb <= (others => '0');
        gap_x_tb(9 downto 0) <= std_logic_vector(to_unsigned(16, 10));  -- Hueco fijo

        -- Coordenadas normales (bajas) y mirror (medias)
        pos_x_tb <= (others => '0');
        pos_x_tb(9 downto 0) <= std_logic_vector(to_unsigned(20, 10));      -- pos_x
        pos_x_tb(19 downto 10) <= std_logic_vector(to_unsigned(45, 10));    -- pos_x_mirror
        pos_y_tb <= (others => '0');
        pos_y_tb(9 downto 0) <= std_logic_vector(to_unsigned(3, 10));      -- pos_y
        pos_y_tb(19 downto 10) <= std_logic_vector(to_unsigned(24, 10));    -- pos_y_mirror
        wait_clock(100000);  -- simulacion larga con valores constantes

        -- Fin de simulacion
        log("Fin de simulacion.");
        wait;
    end process;

end qualitySim;
