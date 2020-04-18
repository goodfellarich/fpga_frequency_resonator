--------------------------------------------------------------------------------
-- Company:  Drake Digital
--
-- File: fly_resonator_top.vhd
-- File history:
--      Initial Revision::2017-09-19
--
-- Targeted device: <Family::IGLOO> <Die::AGLN250V2> <Package::100 VQFP>
-- Author: Micah Drake
--
-- Description: 
-- Top level module of the fly resonator logic design;
-- Sub-system instantions and port connections are handled here;
--
--
--------------------------------------------------------------------------------

library IEEE;
library work;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.interface_types_pkg.all;

entity fly_resonator_top is
port(
    sys_clk: IN std_ulogic;
    sys_reset_n: IN std_ulogic;
	button_1xUP_n: IN std_ulogic;
	button_1xDN_n: IN std_ulogic;
	start_sweep_n: IN std_ulogic;
    seven_seg0_n: OUT byte;
	seven_seg1_n: OUT byte;
	seven_seg2_n: OUT byte;
	seven_seg3_n: OUT byte;
	seven_seg4_n: OUT byte;
	seven_seg5_n: OUT byte
	);
end fly_resonator_top;

architecture rtl of fly_resonator_top is
signal sys_reset: std_ulogic;
signal clk_20MHz: std_ulogic;
signal start_sweep: std_ulogic;
signal digit_0: byte;
signal digit_1: byte;
signal digit_2: byte;
signal digit_3: byte;
signal digit_4: byte;
signal digit_5: byte;
signal frequency: freq_t;
signal sweeper_state: range_sweeper_state_t;
signal user_freq: freq_t;
signal user_freq_valid: std_ulogic;
signal button_1xUP: std_ulogic;
signal button_1xDN: std_ulogic;

begin
-- Continuous Assignments ------
sys_reset <= not(sys_reset_n);
clk_20MHz <= sys_clk;
start_sweep <= not(start_sweep_n);
button_1xUP <= not(button_1xUP_n);
button_1xDN <= not(button_1xDN_n);
seven_seg0_n <= digit_0;
seven_seg1_n <= digit_1;
seven_seg2_n <= digit_2;
seven_seg3_n <= digit_3;
seven_seg4_n <= digit_4;
seven_seg5_n <= digit_5;
---------------------------------

-- Component Instantiations -----------------------------------
-- board_led_controller : entity work.led_sequencer(rtl)
-- port map(
   -- clk_20MHz => clk_20MHz,
   -- sys_reset => sys_reset,
   -- SW1 => buttons(0),
   -- SW2 => buttons(1),
   -- SW3 => buttons(2),
   -- SW4 => buttons(3)
   -- --LED => LED_vector
-- );

seven_segment_controller : entity work.seven_seg_controller(rtl)
port map(
   clk_20MHz => clk_20MHz,
   sys_reset => sys_reset,
   frequency => frequency,
   digit_0 => digit_0,
   digit_1 => digit_1,
   digit_2 => digit_2,
   digit_3 => digit_3,
   digit_4 => digit_4,
   digit_5 => digit_5
);

freq_gen : entity work.frequency_generator(rtl)
port map(
   clk_20MHz => clk_20MHz,
   sys_reset => sys_reset,
   start_sweep => start_sweep,
   sweeper_state => sweeper_state,
   user_freq => user_freq,
   user_freq_valid => user_freq_valid,
   frequency => frequency
);

user_intf : entity work.user_input_processor(rtl)
port map(
   clk_20MHz => clk_20MHz,
   sys_reset => sys_reset,
   sweeper_state => sweeper_state,
   button_1xUP => button_1xUP,
   button_1xDN => button_1xDN,
   frequency => frequency,
   user_freq => user_freq,
   user_freq_valid => user_freq_valid
);


end rtl;
