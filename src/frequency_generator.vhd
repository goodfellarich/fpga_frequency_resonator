--------------------------------------------------------------------------------
-- Company: Drake Digital
--
-- File: frequency_generator.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- Generates frequency from 0 to XXXXXX Hz.
-- Sweep rate is XXXX;
--
-- Targeted device: <Family::IGLOO> <Die::AGLN250V2> <Package::100 VQFP>
-- Author: Micah Drake
--
--------------------------------------------------------------------------------

library IEEE;
library work;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.interface_types_pkg.all;

entity frequency_generator is
port(
	clk_20MHz: IN std_ulogic;
	sys_reset: IN std_ulogic;
	start_sweep: IN std_ulogic;
    user_freq: IN freq_t;
    user_freq_valid: IN std_ulogic;
    sweeper_state: OUT range_sweeper_state_t;
	frequency: OUT freq_t
	);
end frequency_generator;

architecture rtl of frequency_generator is
signal range_sweeper_state: range_sweeper_state_t;
signal debouncer_state: debouncer_state_t;
signal user_input_state: user_input_state_t;
signal frequency_i: freq_t;
signal counter: unsigned(23 downto 0);
signal debounce_timer: unsigned(23 downto 0);
signal start_debounce: std_ulogic;

begin

-- Continuous Assignments --------------------	
  frequency <= frequency_i;
  sweeper_state <= range_sweeper_state;
----------------------------------------------


-----------------------------------------------------
-- FREQUENCY RANGE SWEEPER PROCESS
-----------------------------------------------------
range_sweeper: process (clk_20MHz, sys_reset) is
  begin
   if(sys_reset = '1') then
     range_sweeper_state <= INIT;
     start_debounce <= '0';
     frequency_i <= 0;
	 counter <= COUNTER_1HZ_INIT;
   elsif rising_edge(clk_20MHz) THEN
   	 case(range_sweeper_state) is
	   ------------
	   when INIT =>
	   ------------
		 counter <= COUNTER_1HZ_INIT;
         start_debounce <= '0';
		 range_sweeper_state <= WAIT_TO_START;
		
	   ---------------------
	   when WAIT_TO_START =>
	   ---------------------
	     if(start_sweep = '1') then
	       start_debounce <= '1';
	     end if;         
         if(debouncer_state = DONE) then
           start_debounce <= '0';
           range_sweeper_state <= SWEEPING;
         end if;
         if(user_freq_valid = '1') then
           frequency_i <= user_freq;
         end if;
	   
	   ----------------
	   when SWEEPING =>
	   ----------------
	     counter <= counter - 1;
		 if(counter = COUNTER_TIMEOUT) then
		   frequency_i <= frequency_i + 1;
		   counter <= COUNTER_1HZ_INIT;  --reset timer;
		 end if;
		 
		 if(start_sweep = '1') then
	       start_debounce <= '1';
	     end if;         
         if(debouncer_state = DONE) then
           start_debounce <= '0';
           range_sweeper_state <= WAIT_TO_START;
         end if;
       
	   --------------
	   when others =>
	   --------------
	     range_sweeper_state <= INIT;
		 
	 end case;
	
   end if;

end process range_sweeper;

-----------------------------------------------------
-- DEBOUNCER PROCESS
-----------------------------------------------------
debouncer: process(clk_20MHz, sys_reset) is
  begin
    if(sys_reset = '1') then
	  debounce_timer <= DEBOUNCE_TIMER_INIT;
      debouncer_state <= INIT;
	elsif rising_edge(clk_20MHz) then
	  case(debouncer_state) is
	    ------------
        when INIT =>
        ------------
          debounce_timer <= DEBOUNCE_TIMER_INIT;
          debouncer_state <= READY;
		-------------
        when READY =>
        -------------
          if(start_debounce = '1') then
            debouncer_state <= DEBOUNCING;
          end if;
        ------------------
        when DEBOUNCING =>
        ------------------
          debounce_timer <= debounce_timer - 1;
          if(debounce_timer = COUNTER_TIMEOUT) then
            debouncer_state <= DONE;
          end if;
        ------------
        when DONE =>
        ------------
          debouncer_state <= INIT;
        --------------
        when others =>
        --------------
          debouncer_state <= INIT;
      end case;
	end if;
end process debouncer;


end rtl;
