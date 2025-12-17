--/======================================================================\
--| Esta máquina de estados gestiona el pintado de huellas              |
--| Dispara una huella única una vez se alcance las coord. objetivo     |
--| Habilita el disparador de huellas                                    |
--| Deshabilita pintado                                                  |
--\======================================================================/


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_footprint is
  Port ( clk : in std_logic;
         reset : in std_logic;
         pos_x : in unsigned (10-1 downto 0);
         pos_y : in unsigned (10-1 downto 0);
         filas : in unsigned (10-1 downto 0);
         columnas : in unsigned (10-1 downto 0);

         en_gap_cnt : out std_logic;
         trigger_first_ftprint : out std_logic);
end fsm_footprint;

architecture rtl of fsm_footprint is

    type fsm_huella is (IDLE, pos_all, pos_fil);
    signal e_actual, e_siguiente : fsm_huella;

begin

----------------------------------------------------------------------------------------------------------------------------------------------
seq_P : process(reset,clk)
    begin
        if reset = '1' then
            e_actual <= IDLE;       --Condicion de reset, reinicio el estado al estado 0
        elsif rising_edge (clk) then
            e_actual <= e_siguiente;
        end if;
end process;
-----------------------------------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------------------------------------------

comb_P : process(e_actual, filas, columnas, pos_x, pos_y)
    begin
        e_siguiente <= e_actual;
        case e_actual is
            when IDLE =>
                if (filas >= pos_y) and (filas < (pos_y + 16)) then
                    if pos_x = columnas then
                        e_siguiente <= pos_all;
                    end if;
                end if;
            when pos_all =>
                if pos_x /= columnas then
                    e_siguiente <= pos_fil;                 
                end if;
            when pos_fil =>
                --if pos_y /= filas then
                --    e_siguiente <= IDLE;
                --end if;
                if (filas < pos_y) or (filas >= (pos_y + 16)) then
                    e_siguiente <= IDLE;
                end if;
        end case;
end process; 
-----------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------
comb_salidas : process(e_actual)
    begin
    en_gap_cnt <= '0';
    trigger_first_ftprint <= '0';
        case e_actual is
            when IDLE => 
                en_gap_cnt <= '0';
                trigger_first_ftprint <= '0';
            when pos_all =>
                en_gap_cnt <= '0';
                trigger_first_ftprint <= '1';
            when pos_fil =>
                en_gap_cnt <= '1';
                trigger_first_ftprint <= '0';
        end case;
end process;
-----------------------------------------------------------------------------------------------------------------------------------------------

end rtl;