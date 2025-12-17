--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

--entity tb_1 is
--end tb_1;

--architecture Behavioral of tb_1 is

--component top is
--    Port ( 
--        clk : in std_logic;
--        reset_n : in std_logic;
--        fila_in : in std_logic_vector (32-1 downto 0);
--        col_in : in std_logic_vector (32-1 downto 0);   -- Velocidad relativa (distancia entre pasos)
--        fila_in_mirror : in std_logic_vector (32-1 downto 0);
--        background : in std_logic;
        
--        vblank : out std_logic;        -- Para el PS
--        clkP : out std_logic;       -- HDMI
--        clkN : out std_logic;       -- HDMI
--        dataP : out std_logic_vector (2 downto 0);      -- HDMI
--        dataN : out std_logic_vector (2 downto 0));      -- HDMI
--end component;


--signal clk_tb      : std_logic;
--signal reset_tb    : std_logic;
--signal weBRAM_tb   : std_logic;
--signal addrBRAM_tb : std_logic_vector (3-1 downto 0);
--signal dinBRAM_tb  : std_logic_vector (8-1 downto 0);
--signal background_tb   : std_logic;

--begin

        
--clksim : process    -- Frecuencia original 4ns por cada wait for
--begin
--    clk_tb <= '0';
--    wait for 1ps;
--    clk_tb <= '1';
--    wait for 1ps;
--end process;

--reset_tb <= '0', '1' after 10ns;
--weBRAM_tb <= '0', '1' after 50ns, '0' after 100ns;
--addrBRAM_tb <= (others => '0');
--dinBRAM_tb <= (others => '0');
--background_tb <= '1';


--end Behavioral;


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
        fila_in : in std_logic_vector (32-1 downto 0);
        col_in : in std_logic_vector (32-1 downto 0);   -- Velocidad relativa (distancia entre pasos)
        fila_in_mirror : in std_logic_vector (32-1 downto 0);
        background : in std_logic;
        debug1 : out std_logic;
        
        clkP : out std_logic;       -- HDMI
        clkN : out std_logic;       -- HDMI
        dataP : out std_logic_vector (2 downto 0);      -- HDMI
        dataN : out std_logic_vector (2 downto 0));      -- HDMI
end component;

-- Señales
signal clk_tb          : std_logic := '0';
signal reset_tb        : std_logic := '0';
signal filaIN_tb       : std_logic_vector(32 - 1 downto 0);
signal colIN_tb        : std_logic_vector(32 - 1 downto 0);
signal filaINMirror_tb : std_logic_vector (32 - 1 downto 0);
signal background_tb   : std_logic := '0';

begin

    -- Instanciación de la FIFO
topinst : top
    Port map (
        clk            => clk_tb,
        reset_n        => reset_tb,
        fila_in        => filaIN_tb,
        col_in         => colIN_tb,
        fila_in_mirror => filaINMirror_tb,
        background     => background_tb);

    -- Generación de reloj
    clk_process : process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;

    -- Estimulos
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
        log("Inicio de simulación: Reset activo.");
        wait_clock(2);
        reset_tb <= '1';
        log("Reset desactivado. Comienza test.");

        -- Empieza a escribir diferentes valores de fila objetivo
        log("Fase 1: Escritura de datos aleatorios.");
        for i in 0 to 32 - 1 loop
            filaIN_tb <= std_logic_vector(to_unsigned(i, 32));
            wait_clock(10);
            filaINMirror_tb <= std_logic_vector(to_unsigned(i, 32));
            wait_clock(2);
            colIN_tb <= std_logic_vector(to_unsigned(i, 32));
            wait_clock(10);
        end loop;
        
--        log("Fase 2: Escritura de velocidades aleatorias.");
--        for i in 0 to 32 - 1 loop
--            colIN_tb <= std_logic_vector(to_unsigned(i, 32));
--            wait_clock(10);
--        end loop;
        
--        log("Fase 3: Escritura de fila espejo.");
--        for i in 0 to 32 - 1 loop
--            filaINMirror_tb <= std_logic_vector(to_unsigned(i, 32));
--            wait_clock(10);
--        end loop;

        -- Fin de simulacion
        log("Fin de simulación.");
        wait;
    end process;

end qualitySim;
