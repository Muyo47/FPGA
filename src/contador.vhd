library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador is
  Generic ( n_bits : integer;     --Bits necesarios para realizar la cuenta deseada
            max_count : integer;
            cont_inicial : integer := 0);     --Generico para asignar la cuenta total a realizar
            
            --En el caso de requerir cuentas mayores, cambiar el numero de bits total!
  Port ( enable : in std_logic;                             --Habilitacion
         clk : in std_logic;                                --Reloj
         count : out std_logic_vector (n_bits-1 downto 0);  --Conteo total
         reset : in std_logic;          --Reset
         fin_cuenta : out std_logic;    --Fin de cuenta
         sentido_c : in std_logic); --0 para ascendente, 1 para descendente
        
end contador;
    
architecture Behavioral of contador is                  
signal counter_temp : unsigned (n_bits-1 downto 0);     --Señal para operaciones aritmeticas
begin                                                   
process (clk, reset)        --Lista de sensibilidad del proceso
begin
    if reset = '1' then
        counter_temp <= to_unsigned(cont_inicial, n_bits);      --Reiniciamos la cuenta en caso de que se active reset
     elsif rising_edge (clk) then          
        if enable = '1' then        --Solo cuando esta habilitado
            if sentido_c = '0' then         --Si el sentido de cuenta es ascendente
                if counter_temp = to_unsigned(max_count-1, n_bits) then  --Condicion de fin de cuenta
                    counter_temp <= (others => '0');  --Al alcanzar el conteo total, se reinicia la cuenta
                else counter_temp <= counter_temp + 1; --Aumentamos el conteo en una unidad en caso de que no se alcance el fin de cuenta
                end if;
            elsif sentido_c = '1' then  --Si el sentido es descendente
                if counter_temp = to_unsigned(0, n_bits) then       --Si llega a cero, reiniciamos el conteo desde el valor maximo
                    counter_temp <= to_unsigned(max_count-1, n_bits);
                else counter_temp <= counter_temp - 1;      --Si no hemos llegado al final de cuenta, restamos una unidad
                end if;
            end if;
        end if;
     end if;
    end process;
    count <= std_logic_vector(counter_temp); --Valor total de cuenta
    fin_cuenta <= '1' when (counter_temp = max_count - 1 and sentido_c = '0') or (counter_temp = 0 and sentido_c = '1') else '0';   --Bit de fin de cuenta. Solo cuando la cuenta ha acabado. Se comprueban los dos casos, si esta en modo ascendente o en modo descendente
end Behavioral;

