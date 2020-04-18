--------------------------------------------------------------------------------
-- Company: Drake Digital
--
-- File: user_input_processor.vhd
-- File history:
--      Initial build: 2017-10-02
--
-- Description: 
--
-- User interface -> accepts pushbutton inputs from user to increment or decrement
-- the frequency setting;  After input is complete, frequency sweep may be resumed.
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

entity user_input_processor is
port(
	clk_20MHz: IN std_ulogic;
	sys_reset: IN std_ulogic;
    sweeper_state: IN range_sweeper_state_t;
	button_1xUP: IN std_ulogic;
	button_1xDN: IN std_ulogic;
    frequency: IN freq_t;
	user_freq: OUT freq_t;
    user_freq_valid: OUT std_ulogic
	);
end user_input_processor;

architecture rtl of user_input_processor is

constant COUNTER_INIT_SLOW: unsigned(23 downto 0) := x"989680";
constant COUNTER_INIT_MED: unsigned(23 downto 0) := x"0F4240";
constant COUNTER_INIT_FAST: unsigned(23 downto 0) := x"0186A0";
constant COUNTER_INIT_WARP: unsigned(23 downto 0) := x"002710";

signal debouncer_state: debouncer_state_t;
signal user_input_state: user_input_state_t;
signal freq_updater_state: freq_updater_state_t;
signal frequency_i: freq_t;
signal data_valid: std_ulogic;
signal counter: unsigned(23 downto 0);
signal debounce_timer: unsigned(23 downto 0);
signal start_debounce: std_ulogic;
signal start_increment: std_ulogic;
signal start_decrement: std_ulogic;

begin

-- Continuous Assignments --------------------	
  user_freq <= frequency_i;
  user_freq_valid <= data_valid;
----------------------------------------------


-----------------------------------------------------
-- USER INPUT PROCESS
-----------------------------------------------------
user_input_processor: process(clk_20MHz, sys_reset) is
  begin
    if(sys_reset = '1') then
      start_debounce <= '0';
      start_increment <= '0';
      start_decrement <= '0';
      user_input_state <= INIT;
      
    elsif rising_edge(clk_20MHz) then
      case(user_input_state) is
        ------------
        when INIT =>
        ------------
          start_debounce <= '0';
          start_increment <= '0';
          start_decrement <= '0';
          user_input_state <= WAIT_TO_START;
          
        ---------------------
        when WAIT_TO_START =>
        ---------------------
          if(sweeper_state = WAIT_TO_START) then
            if((button_1xUP = '1') OR (button_1xDN = '1')) then
              start_debounce <= '1';
            end if;
            if(debouncer_state = DONE) then
              user_input_state <= PROCESSING;
            end if;
          end if;
          
        
        ------------------  
        when PROCESSING =>
        ------------------
          if(button_1xUP = '1') then
            start_increment <= '1';
          elsif(button_1xDN = '1') then
            start_decrement <= '1';
          end if;
          
          if(freq_updater_state = DONE) then --wait until active input finishes;
            user_input_state <= DONE;
          end if;
        
        ------------
        when DONE =>
        ------------
          user_input_state <= INIT;
        
        --------------
        when others =>
        --------------
          user_input_state <= INIT;
          
      end case;
    end if;
end process user_input_processor;
-----------------------------------------------------


-----------------------------------------------------
-- RESPONSE TO INPUT PROCESS
-----------------------------------------------------
frequency_updater: process(clk_20MHz, sys_reset) is
  variable digit_ticker: ticker_t := 0;
  begin
    if(sys_reset = '1') then
	  frequency_i <= frequency;
      counter <= COUNTER_INIT_SLOW;
      data_valid <= '0';
      digit_ticker := 0;
      freq_updater_state <= INIT;
      
	elsif rising_edge(clk_20MHz) then
	  case(freq_updater_state) is
	    ------------
        when INIT =>
        ------------
          frequency_i <= frequency;
          counter <= COUNTER_INIT_SLOW;
          data_valid <= '0';
          digit_ticker := 0;
          freq_updater_state <= WAIT_TO_START;
        
        ---------------------
        when WAIT_TO_START =>
        ---------------------
          frequency_i <= frequency;
          if(start_increment = '1') then
            freq_updater_state <= INCREMENT_S1;
          elsif(start_decrement = '1') then
            freq_updater_state <= DECREMENT_S1;
          end if;
        
        --------------------
        when INCREMENT_S1 =>
        --------------------
          counter <= counter - 1;
          if(counter = COUNTER_TIMEOUT) then
            frequency_i <= frequency_i + 1;
            counter <= COUNTER_INIT_SLOW;
            data_valid <= '1';
            digit_ticker := digit_ticker + 1;
          end if;
          
          if(digit_ticker = 9) then
            counter <= COUNTER_INIT_MED;
            digit_ticker := 0;
            freq_updater_state <= INCREMENT_S2;
          end if;
          
          if(button_1xUP = '0') then
            freq_updater_state <= DONE;
          end if;
        
        --------------------
        when INCREMENT_S2 =>
        --------------------
          counter <= counter - 1;
          if(counter = COUNTER_TIMEOUT) then
            frequency_i <= frequency_i + 1;
            counter <= COUNTER_INIT_MED;
            data_valid <= '1';
            digit_ticker := digit_ticker + 1;
          end if;
          
          if(digit_ticker = 99) then
            counter <= COUNTER_INIT_FAST;
            digit_ticker := 0;
            freq_updater_state <= INCREMENT_S3;
          end if;
          
          if(button_1xUP = '0') then
            freq_updater_state <= DONE;
          end if;
        
        --------------------
        when INCREMENT_S3 =>
        --------------------
          counter <= counter - 1;
          if(counter = COUNTER_TIMEOUT) then
            frequency_i <= frequency_i + 1;
            data_valid <= '1';
            counter <= COUNTER_INIT_FAST;
          end if;
          
          if(digit_ticker = 99) then
            counter <= COUNTER_INIT_WARP;
            digit_ticker := 0;
            freq_updater_state <= INCREMENT_S4;
          end if;
          
          if(button_1xUP = '0') then
            freq_updater_state <= DONE;
          end if;
        
        --------------------
        when INCREMENT_S4 =>
        --------------------
          counter <= counter - 1;
          if(counter = COUNTER_TIMEOUT) then
            frequency_i <= frequency_i + 1;
            data_valid <= '1';
            counter <= COUNTER_INIT_WARP;
          end if;
          
          if(button_1xUP = '0') then
            freq_updater_state <= DONE;
          end if;
        
        
        --------------------
        when DECREMENT_S1 =>
        --------------------
          counter <= counter - 1;
          if(counter = COUNTER_TIMEOUT) then
            frequency_i <= frequency_i - 1;
            data_valid <= '1';
            counter <= COUNTER_INIT_SLOW;
            digit_ticker := digit_ticker + 1;
          end if;
          
          if(digit_ticker = 9) then
            counter <= COUNTER_INIT_MED;
            digit_ticker := 0;
            freq_updater_state <= DECREMENT_S2;
          end if;
          
          if(button_1xDN = '0') then
            freq_updater_state <= DONE;
          end if;
        
        --------------------
        when DECREMENT_S2 =>
        --------------------
          counter <= counter - 1;
          if(counter = COUNTER_TIMEOUT) then
            frequency_i <= frequency_i - 1;
            data_valid <= '1';
            counter <= COUNTER_INIT_MED;
            digit_ticker := digit_ticker + 1;
          end if;
          
          if(digit_ticker = 99) then
            counter <= COUNTER_INIT_FAST;
            digit_ticker := 0;
            freq_updater_state <= DECREMENT_S3;
          end if;
          
          if(button_1xDN = '0') then
            freq_updater_state <= DONE;
          end if;
        
        --------------------
        when DECREMENT_S3 =>
        --------------------
          counter <= counter - 1;
          if(counter = COUNTER_TIMEOUT) then
            frequency_i <= frequency_i - 1;
            data_valid <= '1';
            counter <= COUNTER_INIT_FAST;
          end if;
          
          if(digit_ticker = 999) then
            counter <= COUNTER_INIT_WARP;
            digit_ticker := 0;
            freq_updater_state <= DECREMENT_S4;
          end if;
          
          if(button_1xDN = '0') then
            freq_updater_state <= DONE;
          end if;
        
        
        --------------------
        when DECREMENT_S4 =>
        --------------------
          counter <= counter - 1;
          if(counter = COUNTER_TIMEOUT) then
            frequency_i <= frequency_i - 1;
            data_valid <= '1';
            counter <= COUNTER_INIT_FAST;
          end if;
          
          if(button_1xDN = '0') then
            freq_updater_state <= DONE;
          end if;
        
        ------------
        when DONE =>
        ------------
          freq_updater_state <= INIT;
          
      end case;
    end if;
  end process frequency_updater;


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
