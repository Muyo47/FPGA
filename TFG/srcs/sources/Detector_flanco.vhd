library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Detector_flanco is
  Port ( flanco_in : in std_logic;
         flanco_out : out std_logic;
         clk : in std_logic;
         reset : in std_logic );
end Detector_flanco;

architecture Behavioral of Detector_flanco is

component biestableD is
  Port ( clk : in std_logic;
         enable : in std_logic;
         reset : in std_logic;
         data : in std_logic;
         output_data : out std_logic );
end component;

signal conector_uno : std_logic;
signal conector_dos : std_logic;

begin

Biestable_uno : biestableD
    Port map ( enable => '1',
               clk => clk,
               reset => reset,
               data => flanco_in,
               output_data => conector_uno );
               
Biestable_dos : biestableD
    Port map( clk => clk,
              enable => '1',
              reset => reset,
              data => conector_uno,
              output_data => conector_dos);
              
flanco_out <= conector_uno and not conector_dos;

end Behavioral;
