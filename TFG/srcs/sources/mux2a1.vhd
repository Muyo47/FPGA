library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity mux2a1 is
    Generic( bits_en : integer);   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port ( ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 0
           ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 1
           sel_mux : in STD_LOGIC;                                  --Selector del multiplexor
           sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));  --Salida del multiplexor
end mux2a1; 

architecture Behavioral of mux2a1 is
begin
         sal_mux <= ent_mux_0 when sel_mux = '0'  
         else ent_mux_1 when sel_mux = '1';     --Concurrente, entrada 0 cuando sel=0, entrada 1 en el otro caso

end Behavioral;
