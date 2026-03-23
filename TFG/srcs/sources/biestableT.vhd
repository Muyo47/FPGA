library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity biestableT is
  Port ( clk : in std_logic;    --Reloj
         enable : in std_logic; --Habilitacion
         reset : in std_logic;  --Reset
         data : in std_logic;   --Entrada del codigo de operacion al biestable
         output_data : out std_logic );     --Salida conmutada de datos del biestable
end biestableT;

architecture Behavioral of biestableT is
signal q : std_logic := '0';        --Señal para operar con los datos

begin

process (clk, reset)
begin
    if reset = '1' then
        q <= '0';       --Reinicio de salida en caso de reset
    elsif rising_edge(clk) then
        if enable = '1' then
            if data = '1' then
                q <= not q;     --Conmuta el estado actual
            end if;
        end if;
    end if;
end process;

output_data <= q;       --Escribimos señal en la salida del biestable

end Behavioral;
