--------------------------------------------------------------------------------
-- Company: Drake Digital
--
-- File: led_sequencer.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- Controller for the 8 on-board LEDs;
--
-- Targeted device: <Family::IGLOO> <Die::AGLN250V2> <Package::100 VQFP>
-- Author: Micah Drake
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity led_sequencer is
port(
	clk_20MHz: IN std_ulogic;
	sys_reset: IN std_ulogic;
	SW1: IN std_ulogic; 
	SW2: IN std_ulogic;
	SW3: IN std_ulogic;
	SW4: IN std_ulogic
	--LED: OUT std_ulogic_vector(7 downto 0)
	);
end led_sequencer;

architecture rtl of led_sequencer is

signal clk_1Hz: std_ulogic_vector (7 downto 0);
signal counter: std_ulogic_vector(24 downto 0);

begin

Sequence: process (clk_20MHz, sys_reset) is
variable count: natural range 0 to 20 := 0;
begin
clk_1Hz <= (others => '1');

if rising_edge(clk_20MHz) THEN --AND (SW1 <= '0' OR SW2 <= '0' OR SW3 <= '0' OR SW4 <= '0') then
	if counter < "101101110001101100000" then
		counter <= counter + 1;
	elsif (count < 20) then
		count := count + 1;		
		counter <= (others => '0');
	else
		count:=0;
--		clk_1Hz <= (others => '1');  This was put in to turn LEDs OFF since they seemed to default to ON, but not needed now that all 										cases are accounted for below;
	end if;
end if;

if (SW1 <= '0' and SW2 <= '1' and SW3 <= '1' and SW4 <= '1') then
	
		case (count) is
			when 0 => clk_1Hz <= "11111111";
			when 1 => clk_1Hz <= "11111111";
			when 2 => clk_1Hz <= "01111110";
			when 3 => clk_1Hz <= "00111100";
			when 4 => clk_1Hz <= "00011000";
			when 5 => clk_1Hz <= "00000000";
			when 6 => clk_1Hz <= "10000001";
			when 7 => clk_1Hz <= "11000011";
			when 8 => clk_1Hz <= "11100111";
			when 9 => clk_1Hz <= "11111111";
			when others => clk_1Hz <= "11111111";
		end case;
	
elsif (SW1 <= '1' and SW2 <= '0' and SW3 <= '1' and SW4 <= '1') then
	case (count) is
		when 0 => clk_1Hz <= "11110111";
		when 1 => clk_1Hz <= "11110111";
		when 2 => clk_1Hz <= "11110011";
		when 3 => clk_1Hz <= "11110011";
		when 4 => clk_1Hz <= "11110001";
		when 5 => clk_1Hz <= "11110001";
		when 6 => clk_1Hz <= "11110000";
		when 7 => clk_1Hz <= "11110000";
		when 8 => clk_1Hz <= "11110000";
		when 9 => clk_1Hz <= "11110000";
		when others => clk_1Hz <= "11111111";
	end case;

elsif (SW1 <= '1' and SW2 <= '1' and SW3 <= '0' and SW4 <= '1') then
	case (count) is
		when 0 => clk_1Hz <= "11111111";
		when 1 => clk_1Hz <= "00000000";
		when 2 => clk_1Hz <= "11111111";
		when 3 => clk_1Hz <= "00000000";
		when 4 => clk_1Hz <= "11111111";
		when 5 => clk_1Hz <= "00000000";
		when 6 => clk_1Hz <= "11111111";
		when 7 => clk_1Hz <= "00000000";
		when 8 => clk_1Hz <= "00000000";
		when 9 => clk_1Hz <= "00000000";
		when 10 => clk_1Hz <= "00000000";
		when 11 => clk_1Hz <= "00000000";
		when 12 => clk_1Hz <= "00000000";
		when others => clk_1Hz <= "00000000";
	end case;

elsif (SW1 <= '1' and SW2 <= '1' and SW3 <= '1' and SW4 <= '0') then
	case (count) is
		when 0 => clk_1Hz <= "11101111";
		when 1 => clk_1Hz <= "11101111";
		when 2 => clk_1Hz <= "11001111";
		when 3 => clk_1Hz <= "11001111";
		when 4 => clk_1Hz <= "10001111";
		when 5 => clk_1Hz <= "10001111";
		when 6 => clk_1Hz <= "00001111";
		when 7 => clk_1Hz <= "00001111";
		when 8 => clk_1Hz <= "00001111";
		when 9 => clk_1Hz <= "00001111";
		when others => clk_1Hz <= "11111111";
	end case;

else
	case (count) is
		when 0 => clk_1Hz <= "11111111";
		when 1 => clk_1Hz <= "11111111";
		when 2 => clk_1Hz <= "01111110";
		when 3 => clk_1Hz <= "00111100";
		when 4 => clk_1Hz <= "00011000";
		when 5 => clk_1Hz <= "00000000";
		when 6 => clk_1Hz <= "10000001";
		when 7 => clk_1Hz <= "11000011";
		when 8 => clk_1Hz <= "11100111";
		when 9 => clk_1Hz <= "11111111";
		when 10 => clk_1Hz <= "11111111";
		when 11 => clk_1Hz <= "11111111";
		when 12 => clk_1Hz <= "01111110";
		when 13 => clk_1Hz <= "00111100";
		when 14 => clk_1Hz <= "00011000";
		when 15 => clk_1Hz <= "00000000";
		when 16 => clk_1Hz <= "10000001";
		when 17 => clk_1Hz <= "11000011";
		when 18 => clk_1Hz <= "11100111";
		when 19 => clk_1Hz <= "11111111";
		when 20 => clk_1Hz <= "11111111";
		
	end case;
end if;

end process Sequence;


--LED <= clk_1Hz;

end rtl;
