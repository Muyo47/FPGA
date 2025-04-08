library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_1 is
--  Port ( );
end tb_1;

architecture Behavioral of tb_1 is

component top is
  Port ( clk : in std_logic;
         reset : in std_logic;
         clkP : out std_logic;
         clkN : out std_logic;
         dataP : out std_logic_vector (2 downto 0);
         dataN : out std_logic_vector (2 downto 0);
         palsel : in std_logic;
         btn_img : in std_logic;
         weBRAM : in std_logic;
         addrBRAM : in std_logic_vector (8-1 downto 0);
         dinBRAM : in std_logic_vector (8-1 downto 0);
         chipSelectBRAM : in std_logic;
         btnLEDS : in std_logic;
         LEDS : out std_logic_vector(4-1 downto 0));
end component;

signal clk_tb            : std_logic;
signal reset_tb          : std_logic;
signal palsel_tb         : std_logic;
signal btn_img_tb        : std_logic;
signal weBRAM_tb         : std_logic;
signal addrBRAM_tb       : std_logic_vector (8-1 downto 0);
signal dinBRAM_tb        : std_logic_vector (8-1 downto 0);
signal chipSelectBRAM_tb : std_logic;
signal btnLEDS_tb        : std_logic;

begin

top_tb : top
    Port map (
        clk => clk_tb,
        reset => reset_tb,
        palsel => palsel_tb,
        btn_img => btn_img_tb,
        weBRAM => weBRAM_tb,
        addrBRAM => addrBRAM_tb,
        dinBRAM => dinBRAM_tb,
        chipSelectBRAM => chipSelectBRAM_tb,
        btnLEDS => btnLEDS_tb
        );
        
clksim : process
begin
    clk_tb <= '0';
    wait for 4ns;
    clk_tb <= '1';
    wait for 4ns;
end process;

reset_tb <= '1', '0' after 10ns;
palsel_tb <= '0';
btn_img_tb <= '0';
weBRAM_tb <= '0', '1' after 50ns, '0' after 100ns;
addrBRAM_tb <= (others => '0');
dinBRAM_tb <= (others => '0');
chipSelectBRAM_tb <= '1';
btnLEDS_tb <= '0';

end Behavioral;
