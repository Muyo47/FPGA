library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp is
  Port (
    -- In ports
    visible      : in std_logic;
    col          : in unsigned(10-1 downto 0);
    fila         : in unsigned(10-1 downto 0);
    sprite_data  : in std_logic_vector(16-1 downto 0);
    sprite_data_2  : in std_logic_vector(16-1 downto 0);
    paleta_sel   : in std_logic;
    sprite_sel   : in std_logic_vector (4-1 downto 0);
    -- Out ports
    rojo         : out std_logic_vector(8-1 downto 0);
    verde        : out std_logic_vector(8-1 downto 0);
    azul         : out std_logic_vector(8-1 downto 0);
    sprite_dir   : out std_logic_vector(8-1 downto 0);
    sprite_dir_2   : out std_logic_vector(8-1 downto 0));
end disp;

architecture behavioral of disp is

signal dataP0 : std_logic_vector(16-1 downto 0);
signal dataP1 : std_logic_vector(16-1 downto 0);
signal rgb : std_logic_vector(24-1 downto 0);

begin

P_pinta: Process (visible, col, fila)
  begin
  
  sprite_dir <= sprite_sel & std_logic_vector(fila(4-1 downto 0));     -- Plano 0
  sprite_dir_2 <= sprite_sel & std_logic_vector(fila(4-1 downto 0));     -- Plano 1
  
  rgb    <= (others=>'1');  
  if visible = '1' then
  
    if col >= 512 then
        rgb <= X"000000";
    elsif sprite_data(to_integer(col (3 downto 0))) = '0' and sprite_data_2(to_integer(col (3 downto 0))) = '0' then
        if paleta_sel = '1' then
                --rgb <= X"0000";  -- Negro rgb565
                rgb <= X"000000";
            else
                rgb <= X"CDC79D";       -- Paleta 0 beis
        end if;
    elsif sprite_data(to_integer(col (3 downto 0))) = '0' and sprite_data_2(to_integer(col (3 downto 0))) = '1' then
        if paleta_sel = '1' then
            --rgb <= X"07E0";  -- Verde
            rgb <= X"00FF00";
        else
            rgb <= X"000000";
        end if;
    elsif sprite_data(to_integer(col (3 downto 0))) = '1' and sprite_data_2(to_integer(col (3 downto 0))) = '0' then
        if paleta_sel = '1' then
            --rgb <= X"FDA0";   -- Naranja
            rgb <= X"FFC080";
        else
            rgb <= X"000000";
        end if;
    elsif sprite_data(to_integer(col (3 downto 0))) = '1' and sprite_data_2(to_integer(col (3 downto 0))) = '1' then
        if paleta_sel = '1' then
            --rgb <= X"867D";   -- Azul
            rgb <= X"0000FF";
        else
            rgb <= X"1B91DA";
        end if;
    end if;
    --end if;

  end if;
end process;

rojo <= rgb(24-1 downto 16);
verde <= rgb(16-1 downto 8);
azul <= rgb(8-1 downto 0);
  
end Behavioral;