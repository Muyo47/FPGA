library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity biestableD is
  Port ( clk : in std_logic;
         enable : in std_logic;
         reset : in std_logic;
         data : in std_logic;
         output_data : out std_logic );
end biestableD;

architecture Behavioral of biestableD is
begin

process (clk, reset)
begin
    if reset = '1' then
        output_data <= '0';
    elsif rising_edge(clk) then
        if enable = '1' then
            output_data <= data;
        end if;
    end if;
end process;


end Behavioral;
