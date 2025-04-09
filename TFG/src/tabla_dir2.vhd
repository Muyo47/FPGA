library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tabla_dir2 is
  port (
    clk  : in  std_logic;   -- Reloj
    addr : in  std_logic_vector(10-1 downto 0); -- Dirección de 10 bits (30x32 = 960 posiciones)
    dout : out std_logic_vector(4-1 downto 0) -- Datos de 3 bits
  );
end tabla_dir2;

architecture BEHAVIORAL of tabla_dir2 is
  type memostruct is array (0 to 959) of std_logic_vector(4-1 downto 0);
  constant filaimg : memostruct := (
    "1111", "1111", "1101", "0111", "1011", "1111", "0100", "0001",
    "0110", "0111", "1010", "1101", "1110", "0010", "1011", "0111", -- Valores aleatorios de ejemplo
    "0001", "0110", "0111", "1000", "0101", "1010", "0000", "0101",
    -- Continúa hasta completar las 960 posiciones, asegurando que "111" no se usa
    others => "1111" -- Relleno de seguridad
  );

  signal addr_int : integer range 0 to 959;

begin
  addr_int <= TO_INTEGER(unsigned(addr));

  P_ROM: process (clk)
  begin
    if rising_edge(clk) then
      dout <= filaimg(addr_int);
    end if;
  end process;

end BEHAVIORAL;
