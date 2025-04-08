library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifoTB is
end fifoTB;

architecture Behavioral of fifoTB is

component bufferFIFO is
    Generic (
        palabraFIFO : integer;
        profundidadFIFO : integer);
    Port ( 
        clk   : in std_logic;
        reset : in std_logic;
        
        -- Escritura
        dinFIFO : in std_logic_vector(palabraFIFO - 1 downto 0);
        weFIFO  : in std_logic;
        
        -- Lectura
        doutFIFO : out std_logic_vector(palabraFIFO - 1 downto 0);
        reFIFO   : in std_logic;
        
        -- Parametros adicionales
        fullFIFO   : out std_logic;
        emptyFIFO  : out std_logic;
        cfullFIFO  : out std_logic;
        cemptyFIFO : out std_logic;
        
        cuentaFIFO : out std_logic_vector (palabraFIFO - 1 downto 0)
        );
end component;

signal clk_tb            : std_logic;
signal reset_tb          : std_logic;
signal reFIFO_tb         : std_logic;
signal weFIFO_tb         : std_logic;
signal dinFIFO_tb        : std_logic_vector (1 - 1 downto 0);
signal doutFIFO_tb       : std_logic_vector (1 - 1 downto 0);
signal fullFIFO_tb       : std_logic;
signal emptyFIFO_tb      : std_logic;


begin

bufferf : bufferFIFO
    Generic map (
        palabraFIFO => 1,
        profundidadFIFO => 4)
    Port map ( 
        clk => clk_tb,
        reset => reset_tb,
        
        -- Escritura
        dinFIFO => dinFIFO_tb,
        weFIFO => weFIFO_tb,
        
        -- Lectura
        doutFIFO => doutFIFO_tb,
        reFIFO => reFIFO_tb,
        
        -- Parametros adicionales
        fullFIFO => fullFIFO_tb,
        emptyFIFO => emptyFIFO_tb
         );

clksim : process
begin
    clk_tb <= '0';
    wait for 4ns;
    clk_tb <= '1';
    wait for 4ns;
end process;

reset_tb <= '1', '0' after 30ns;
dinFIFO_tb <= "1", "0" after 98ns, "1" after 110ns, "0" after 200ns;
weFIFO_tb <= '0', '1' after 30ns, '0' after 205ns;
--reFIFO_tb <= '0', '1' after 215ns, '0' after 330ns;
reFIFO_tb <= '0', '1' after 515ns, '0' after 730ns;


end Behavioral;
