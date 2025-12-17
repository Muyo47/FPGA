library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador_pasos is
    Generic (
        cont_inicial : integer := 0);
    Port (
        enable : in std_logic;
        clk : in std_logic;
        count : out std_logic_vector (10-1 downto 0);  -- Suficioente para 32 columnas
        reset : in std_logic;
        fin_cuenta : out std_logic;
        max_count : in std_logic_vector (10-1 downto 0);
        sentido_c : in std_logic); --0 para ascendente, 1 para descendente
end contador_pasos;

architecture rtl of contador_pasos is                  
signal counter_temp : unsigned (10-1 downto 0);
begin                                                   
process (clk, reset)
begin
    if reset = '1' then
        counter_temp <= to_unsigned(cont_inicial, 10);      --Reiniciamos la cuenta en caso de que se active reset
     elsif rising_edge (clk) then          
        if enable = '1' then        --Solo cuando esta habilitado
            if sentido_c = '0' then         --Si el sentido de cuenta es ascendente
                if counter_temp = unsigned(max_count) - 1 then  --Condicion de fin de cuenta
                    counter_temp <= (others => '0');  --Al alcanzar el conteo total, se reinicia la cuenta
                else counter_temp <= counter_temp + 1; --Aumentamos el conteo en una unidad en caso de que no se alcance el fin de cuenta
                end if;
            elsif sentido_c = '1' then  --Si el sentido es descendente
                if counter_temp = 0 then       --Si llega a cero, reiniciamos el conteo desde el valor maximo
                    counter_temp <= unsigned(max_count) - 1;
                else counter_temp <= counter_temp - 1;      --Si no hemos llegado al final de cuenta, restamos una unidad
                end if;
            end if;
        end if;
     end if;
    end process;
    count <= std_logic_vector(counter_temp); --Valor total de cuenta
    fin_cuenta <= '1' when (counter_temp = unsigned(max_count) - 1 and sentido_c = '0') or (counter_temp = 0 and sentido_c = '1') else '0';   --Bit de fin de cuenta. Solo cuando la cuenta ha acabado. Se comprueban los dos casos, si esta en modo ascendente o en modo descendente
end rtl;

