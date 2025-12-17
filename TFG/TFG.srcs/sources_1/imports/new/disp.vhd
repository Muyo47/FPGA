library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp is
    Port (
        -- In ports
        visible        : in std_logic;
        col            : in unsigned(10-1 downto 0);
        fila           : in unsigned(10-1 downto 0);
        sprite_data    : in std_logic_vector(16-1 downto 0);
        sprite_data_2  : in std_logic_vector(16-1 downto 0);
        trigger        : in std_logic;
        gap_count_disp : in std_logic_vector (10-1 downto 0);
        trigger_col_cnt_disp : in std_logic_vector (10-1 downto 0);
        -- Out ports
        rojo           : out std_logic_vector(8-1 downto 0);
        verde          : out std_logic_vector(8-1 downto 0);
        azul           : out std_logic_vector(8-1 downto 0);
        sprite_dir     : out std_logic_vector(8-1 downto 0);
        sprite_dir_2   : out std_logic_vector(8-1 downto 0));
end disp;

architecture rtl of disp is

signal dataP0 : std_logic_vector(16-1 downto 0);
signal dataP1 : std_logic_vector(16-1 downto 0);
signal rgb : std_logic_vector(24-1 downto 0);

begin

P_pinta: Process (visible, col, fila, trigger)
  begin
  
  sprite_dir <= "1111" & std_logic_vector(gap_count_disp(4-1 downto 0));     -- Plano 0
  sprite_dir_2 <= "1111" & std_logic_vector(gap_count_disp(4-1 downto 0));     -- Plano 1
  
  rgb    <= (others=>'1');
  

  if visible = '1' then
    if col >= 512 then
      rgb <= X"000000";
    --elsif trigger = '1' then
    --    rgb <= X"000000";  -- Negro rgb565
    elsif sprite_data(to_integer(unsigned(trigger_col_cnt_disp(4-1 downto 0)))) = '0' then
      if sprite_data_2(to_integer(unsigned(trigger_col_cnt_disp(4-1 downto 0)))) = '1' then
        rgb <= X"0066FF";       -- Azul
      else 
        rgb <= X"000000";       -- Negro
      end if;
    elsif sprite_data(to_integer(unsigned(trigger_col_cnt_disp(4-1 downto 0)))) = '1' then
      if sprite_data_2(to_integer(unsigned(trigger_col_cnt_disp(4-1 downto 0)))) = '1' then
        rgb <= X"00FF00";       -- Verde
      else 
        rgb <= X"FFCCAA";       -- Tono piel claro
      end if;
    end if;
  else
    rgb <= X"202020";           -- Gris oscuro
  end if;
end process;

rojo <= rgb(24-1 downto 16);
verde <= rgb(16-1 downto 8);
azul <= rgb(8-1 downto 0);
  
end rtl;
