-------------------------------------------------------------------------------------------------------------------------------
-- Buffer FIFO. Este buffer es de tipo FIFO circular, entregando los datos de entrada desde el primero hasta el ultimo (en ese orden)
-- Debe ser operado junto a su controlador FSM FIFO
-- Apto para uso como buffer Tx|Rx UART
-------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bufferFIFO is
    Generic (
        palabraFIFO : integer;
        profundidadFIFO : integer);
    Port ( 
        clk : in std_logic;
        reset : in std_logic;
        
        -- Escritura
        dinFIFO : in std_logic_vector(palabraFIFO - 1 downto 0);    -- Datos de entrada
        weFIFO : in std_logic;      -- Habilitacion de escritura
        
        -- Lectura
        doutFIFO : out std_logic_vector(palabraFIFO - 1 downto 0);  -- Datos de salida
        reFIFO : in std_logic;      -- Habilitacion de lectura
        
        -- Parametros adicionales
        fullFIFO : out std_logic;
        emptyFIFO : out std_logic;
        cfullFIFO : out std_logic;      -- Señal previa al llenado completo
        cemptyFIFO : out std_logic;     -- Señal previa al vaciado completo
        
        cuentaFIFO : out std_logic_vector (profundidadFIFO downto 0)    -- Recuento de elementos en el buffer
        );
end bufferFIFO;

architecture rtl of bufferFIFO is

-- Punteros de control de posicion
signal wptr : unsigned(profundidadFIFO - 1 downto 0);
signal rptr : unsigned(profundidadFIFO - 1 downto 0);

-- Datos adicionales
signal isfull : std_logic;
signal isempty : std_logic;
signal cfull : std_logic;
signal cempty : std_logic;
signal countFIFO : unsigned(profundidadFIFO downto 0);


    type ram_type is array (0 to 2**profundidadFIFO - 1) of std_logic_vector(palabraFIFO - 1 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    
constant maxcFIFO : integer := 2**profundidadFIFO;

begin

escrituraFIFO : process (clk, reset)
    begin
    if reset = '1' then
        wptr <= (others => '0');
        ram <= (others => (others => '0'));
    elsif rising_edge(clk) then
        if isfull = '0' and weFIFO = '1' then
            if wptr = maxcFIFO then
                ram (to_integer (wptr)) <= dinFIFO;
                wptr <= (others => '0');
            else
                ram (to_integer (wptr)) <= dinFIFO;
                wptr <= wptr + 1;
            end if;
        end if;
    end if;
end process;


lecturaFIFO : process (clk, reset)
    begin
    if reset = '1' then
        rptr <= (others => '0');
        doutFIFO <= (others => '0');
    elsif rising_edge(clk) then
        if isempty = '0' and reFIFO = '1' then        -- Se puede leer si el buffer contiene algo
            if rptr = maxcFIFO then
                doutFIFO <= ram (to_integer (rptr));
                rptr <= (others => '0');
            else
                doutFIFO <= ram (to_integer (rptr));
                rptr <= rptr + 1;
            end if;
        end if;
    end if;
end process;

control_cuentaFIFO : process (clk, reset)
begin
    if reset = '1' then
        countFIFO <= (others => '0');
    elsif rising_edge(clk) then
        if weFIFO = '1' and reFIFO = '1' then
            countFIFO <= countFIFO;
        elsif weFIFO = '1' and isfull = '0' then
            countFIFO <= countFIFO + 1;
        elsif reFIFO = '1' and isempty = '0' then
            countFIFO <= countFIFO - 1;
        end if;
    end if;
end process;

-- Flags para saber cuando esta lleno el buffer y evitar overwriting
-- O saber si esta vacio para habilitar lectura
cfull <= '1' when countFIFO = maxcFIFO - 1 else '0';
cempty <= '1' when countFIFO = 1 else '0';
cfullFIFO <= cfull;
cemptyFIFO <= cempty;

isfull <= '1' when countFIFO = maxcFIFO else '0';
isempty <= '1' when countFIFO = 0 else '0';

--countFIFO <= (others=>'0') when reset = '1' else countFIFO + 1 when weFIFO = '1' and isfull = '0' else countFIFO - 1 when reFIFO = '1' and isempty = '0' else countFIFO when reFIFO = '1' and weFIFO = '1';

fullFIFO <= isfull;
emptyFIFO <= isempty;
cuentaFIFO <= std_logic_vector(countFIFO);

end rtl;