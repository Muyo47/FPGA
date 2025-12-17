--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity fifoTB is
--end fifoTB;

--architecture Behavioral of fifoTB is

--component bufferFIFO is
--    Generic (
--        palabraFIFO : integer;
--        profundidadFIFO : integer);
--    Port ( 
--        clk   : in std_logic;
--        reset : in std_logic;
        
--        -- Escritura
--        dinFIFO : in std_logic_vector(palabraFIFO - 1 downto 0);
--        weFIFO  : in std_logic;
        
--        -- Lectura
--        doutFIFO : out std_logic_vector(palabraFIFO - 1 downto 0);
--        reFIFO   : in std_logic;
        
--        -- Parametros adicionales
--        fullFIFO   : out std_logic;
--        emptyFIFO  : out std_logic;
--        cfullFIFO  : out std_logic;
--        cemptyFIFO : out std_logic;
        
--        cuentaFIFO : out std_logic_vector (profundidadFIFO downto 0)
--        );
--end component;

--signal clk_tb            : std_logic;
--signal reset_tb          : std_logic;
--signal reFIFO_tb         : std_logic;
--signal weFIFO_tb         : std_logic;
--signal dinFIFO_tb        : std_logic_vector (4 - 1 downto 0);
--signal doutFIFO_tb       : std_logic_vector (4 - 1 downto 0);
--signal fullFIFO_tb       : std_logic;
--signal emptyFIFO_tb      : std_logic;


--begin

--bufferFirstInFirstOut : bufferFIFO
--    Generic map (
--        palabraFIFO => 4,
--        profundidadFIFO => 4)
--    Port map ( 
--        clk => clk_tb,
--        reset => reset_tb,
        
--        -- Escritura
--        dinFIFO => dinFIFO_tb,
--        weFIFO => weFIFO_tb,
        
--        -- Lectura
--        doutFIFO => doutFIFO_tb,
--        reFIFO => reFIFO_tb,
        
--        -- Parametros adicionales
--        fullFIFO => fullFIFO_tb,
--        emptyFIFO => emptyFIFO_tb
--         );

--clksim : process
--begin
--    clk_tb <= '0';
--    wait for 4ns;
--    clk_tb <= '1';
--    wait for 4ns;
--end process;

--reset_tb <= '1', '0' after 30ns;
--dinFIFO_tb <= "0101", "1110" after 98ns, "1001" after 110ns, "1111" after 200ns;
--weFIFO_tb <= '0', '1' after 30ns, '0' after 205ns;
--reFIFO_tb <= '0', '1' after 225ns, '0' after 400ns;


--end Behavioral;


-- SIMULACION DE CALIDAD

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifoTB is
end fifoTB;

architecture Behavioral of fifoTB is

    component bufferFIFO is
        generic (
            palabraFIFO     : integer;
            profundidadFIFO : integer
        );
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            dinFIFO   : in  std_logic_vector(palabraFIFO - 1 downto 0);
            weFIFO    : in  std_logic;
            doutFIFO  : out std_logic_vector(palabraFIFO - 1 downto 0);
            reFIFO    : in  std_logic;
            fullFIFO  : out std_logic;
            emptyFIFO : out std_logic;
            cfullFIFO : out std_logic;
            cemptyFIFO: out std_logic;
            cuentaFIFO: out std_logic_vector(profundidadFIFO downto 0)
        );
    end component;

    -- Parámetros
    constant palabra : integer := 4;
    constant profundidad : integer := 4;

    -- Señales
    signal clk_tb       : std_logic := '0';
    signal reset_tb     : std_logic := '1';
    signal dinFIFO_tb   : std_logic_vector(palabra - 1 downto 0);
    signal doutFIFO_tb  : std_logic_vector(palabra - 1 downto 0);
    signal weFIFO_tb    : std_logic := '0';
    signal reFIFO_tb    : std_logic := '0';
    signal fullFIFO_tb  : std_logic;
    signal emptyFIFO_tb : std_logic;
    signal cfullFIFO_tb : std_logic;
    signal cemptyFIFO_tb: std_logic;
    signal cuentaFIFO_tb: std_logic_vector(profundidad downto 0);

begin

    -- Instanciación de la FIFO
    uut: bufferFIFO
        generic map (
            palabraFIFO     => palabra,
            profundidadFIFO => profundidad
        )
        port map (
            clk        => clk_tb,
            reset      => reset_tb,
            dinFIFO    => dinFIFO_tb,
            weFIFO     => weFIFO_tb,
            doutFIFO   => doutFIFO_tb,
            reFIFO     => reFIFO_tb,
            fullFIFO   => fullFIFO_tb,
            emptyFIFO  => emptyFIFO_tb,
            cfullFIFO  => cfullFIFO_tb,
            cemptyFIFO => cemptyFIFO_tb,
            cuentaFIFO => cuentaFIFO_tb
        );

    -- Generación de reloj
    clk_process : process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;

    -- Estímulos
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
        reset_tb <= '0';
        log("Reset desactivado. Comienza test.");

        -- Llenar la FIFO
        log("Fase 1: Escritura secuencial hasta llenar la FIFO.");
        for i in 0 to profundidad - 1 loop
            dinFIFO_tb <= std_logic_vector(to_unsigned(i, palabra));
            weFIFO_tb <= '1';
            wait_clock(10);
            weFIFO_tb <= '0';
            --wait_clock(1);
            log("Escrito: " & integer'image(i) & " | Full = " & std_logic'image(fullFIFO_tb));
        end loop;

        -- Vaciar la FIFO
        log("Fase 3: Lectura secuencial hasta vaciar la FIFO.");
        for i in 0 to profundidad - 1 loop
            reFIFO_tb <= '1';
            wait_clock(1);
            reFIFO_tb <= '0';
            log("Leído: " & integer'image(to_integer(unsigned(doutFIFO_tb))) & " | Empty = " & std_logic'image(emptyFIFO_tb));
            wait_clock(1);
        end loop;

        -- Intentar leer con FIFO vacía
        log("Fase 4: Intentar leer con FIFO vacía.");
        reFIFO_tb <= '1';
        wait_clock(1);
        reFIFO_tb <= '0';
        log("Lectura forzada con FIFO vacía. Empty = " & std_logic'image(emptyFIFO_tb));
        wait_clock(2);

        -- Escritura y lectura simultánea
        log("Fase 5: Escritura y lectura simultánea.");
        for i in 10 to 13 loop
            dinFIFO_tb <= std_logic_vector(to_unsigned(i, palabra));
            weFIFO_tb <= '1';
            reFIFO_tb <= '1';
            wait_clock(1);
            weFIFO_tb <= '0';
            reFIFO_tb <= '0';
            log("Escrito y leído en simultáneo. Entrada = " & integer'image(i) & " | Salida = " & integer'image(to_integer(unsigned(doutFIFO_tb))));
            wait_clock(1);
        end loop;

        -- Fin de simulación
        log("Fin de simulación.");
        wait;
    end process;

end Behavioral;
