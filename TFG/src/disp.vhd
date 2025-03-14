library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp is
  Port (
    -- In ports
    visible      : in std_logic;
    col          : in unsigned(10-1 downto 0);
    fila         : in unsigned(10-1 downto 0);
    --sprite_sel   : in std_logic;
    sprite_data  : in std_logic_vector(32-1 downto 0);
    -- Out ports
    rojo         : out std_logic_vector(8-1 downto 0);
    verde        : out std_logic_vector(8-1 downto 0);
    azul         : out std_logic_vector(8-1 downto 0);
    sprite_dir   : out std_logic_vector(5-1 downto 0);
    sprite_dir_2   : out std_logic_vector(5-1 downto 0)
  );
end disp;

architecture behavioral of disp is
begin

P_pinta: Process (visible, col, fila)
  begin
  
  rojo   <= (others=>'0');
  verde  <= (others=>'0');
  azul   <= (others=>'0');
  
  if visible = '1' then
    sprite_dir <= std_logic_vector(fila(8 downto 4));
        if sprite_data (to_integer(col (9 downto 4))) = '1' then
            rojo   <= (others=>'1');
            verde  <= (others=>'1');
            azul   <= (others=>'1');
         else
            rojo   <= (others=>'1');
            verde  <= (others=>'0');
            azul   <= (others=>'1');
         end if;
  end if;
end process;
  
end Behavioral;