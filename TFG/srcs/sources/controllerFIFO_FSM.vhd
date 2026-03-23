----------------------------------------------------------------------------------
-- Maquina de estados para controlar el buffer FIFO
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controllerFIFO_FSM is
    Generic (
        palabraFIFO_FSM : integer );
    Port (
        clk : in std_logic;
        reset : in std_logic;
        
        -- Escritura
        weFIFO_FSM : out std_logic;
        
        -- Lectura
        reFIFO_FSM : out std_logic;
        
        -- Parametros adicionales
        --cuentaFIFO_FSM : in std_logic_vector (palabraFIFO_FSM - 1 downto 0);
        --cfullFIFO_FSM : in std_logic;  
        --cemptyFIFO_FSM : in std_logic; 
        fullFIFO_FSM : in std_logic; 
        emptyFIFO_FSM : in std_logic );
end controllerFIFO_FSM;

architecture tempTEST of controllerFIFO_FSM is

    type FIFO is (IDLE, writeFIFO, readFIFO);
    signal eact, esig : FIFO;

begin

seq_P : process(clk, reset)
    begin
    if reset = '1' then
        eact <= IDLE;       -- Condicion de reset, reinicio el estado al estado 0
    elsif rising_edge (clk) then
        eact <= esig;
    end if;
end process;
-----------------------------------------------------------------------------------------------------------------------------------------------



----------PROCESO COMBINACIONAL PARA TRANSICIONAR ENTRE ESTADOS---------------------------------------------------------------------------------
-------- En este proceso, se actualiza el estado de acuerdo al diagrama de estados que hemos implementado.
comb_P : process(eact, fullFIFO_FSM, emptyFIFO_FSM)
    begin
        esig <= eact;        --En caso de que no se cumpla ninguna condicion dentro de los casos
        case eact is
            when IDLE =>
                if fullFIFO_FSM = '1' then
                    esig <= readFIFO;
                elsif emptyFIFO_FSM = '1' then
                    esig <= writeFIFO;
                end if;
            when writeFIFO =>
                if fullFIFO_FSM = '1' then
                    esig <= readFIFO;
                end if;
            when readFIFO =>
                if emptyFIFO_FSM = '1' then
                    esig <= writeFIFO;
                end if;
        end case;
end process;
--------------------------------------------------------------------------------------------------------------------------------------


---------PROCESO COMBINACIONAL PARA ASIGNAR SALIDAS DE NUESTRO CIRCUITO----------------------------------------------------
------- De acuerdo con la teoria de los buffer FIFO, la lectura y escritura simultanea NO ES POSIBLE
------- Ademas, el puntero de lectura no debe superar en ningun momento al puntero de escritura, para
------- evitar leer datos no relevantes, o antiguos
comb_salidas : process(eact)
    begin
        case eact is
            when IDLE => 
                weFIFO_FSM <= '0';
                reFIFO_FSM <= '0';
            when readFIFO =>
                weFIFO_FSM <= '0';
                reFIFO_FSM <= '1';            
            when writeFIFO =>
                weFIFO_FSM <= '1';
                reFIFO_FSM <= '0';         
        end case;
end process;


end tempTEST;
