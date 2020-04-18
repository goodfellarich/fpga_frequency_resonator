--------------------------------------------------------------------------------
-- Company:  Drake Digital
--
-- File: interface_types_pkg.vhd
-- File history:
--      Initial Revision::2017-09-22
--
-- Description: 
--
-- Definitions for typedefs, constants, etc for the fly resonator logic design;
-- 
-- Targeted device: <Family::IGLOO> <Die::AGLN250V2> <Package::100 VQFP>
-- Author: Micah Drake
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


Package interface_types_pkg is
  subtype byte is std_ulogic_vector(7 downto 0);
  subtype digit_t is natural range 0 to 9;
  subtype ticker_t is natural range 0 to 999;
  subtype freq_t is natural range 0 to 300000;
  type byte_vector is array(natural range <>) of byte;
  
  type seven_seg_state_t is (
     INIT,
	 CLK_COUNTING
  );
  
  type digit_slice_state_t is (
     INIT,
	 ISOLATE_D0,
	 EXTRACT_D0,
	 ISOLATE_D1,
	 EXTRACT_D1,
	 ISOLATE_D2,
	 EXTRACT_D2,
	 ISOLATE_D3,
	 EXTRACT_D3,
	 ISOLATE_D4,
	 EXTRACT_D4,
	 ISOLATE_D5,
	 EXTRACT_D5,
	 DONE
  );
  
  type output_driver_state_t is (
     INIT,
     WAIT_UNTIL_DATA_READY,
	 PREPARE_OUTPUT,
	 DRIVE_OUTPUT,
	 DONE
  );
  
  type range_sweeper_state_t is (
     INIT,
	 WAIT_TO_START,
     SWEEPING
  );
  
  type debouncer_state_t is (
     INIT,
	 READY,
	 DEBOUNCING,
	 DONE
  );
  
  type user_input_state_t is(
     INIT,
     WAIT_TO_START,
	 PROCESSING,
	 DONE
  );
  
  type freq_updater_state_t is(
     INIT,
     WAIT_TO_START,
     INCREMENT_S1,
     INCREMENT_S2,
     INCREMENT_S3,
     INCREMENT_S4,
     DECREMENT_S1,
     DECREMENT_S2,
     DECREMENT_S3,
     DECREMENT_S4,
     DONE
  );
  
  constant COUNTER_1HZ_INIT: unsigned(23 downto 0) := x"FFFFFF"; --.0625s --x"4C4B40";
  constant DEBOUNCE_TIMER_INIT: unsigned(23 downto 0) := x"4C4B40";
  constant COUNTER_TIMEOUT: unsigned(23 downto 0) := (others => '0');
  constant MAXCOUNT: integer := 5000000;
  
  -- Seven Segment Encodings ----------------------
  constant ZERO: std_ulogic_vector := b"1000000";
  constant ONE: std_ulogic_vector := b"1110011";
  constant TWO: std_ulogic_vector := b"0100100";
  constant THREE: std_ulogic_vector := b"0100001";
  constant FOUR: std_ulogic_vector := b"0010011";
  constant FIVE: std_ulogic_vector := b"0001001";
  constant SIX: std_ulogic_vector := b"0011000";
  constant SEVEN: std_ulogic_vector := b"1100011";
  constant EIGHT: std_ulogic_vector := b"0000000";
  constant NINE: std_ulogic_vector := b"0000011";
  CONSTANT OFF: std_ulogic_vector := b"1111111";
  constant DASH: std_ulogic_vector := b"0111111";
  constant UNDERBAR: std_ulogic_vector := b"1111101";
  constant H: std_ulogic_vector := b"0010010";
  constant UPPERBAR: std_ulogic_vector := b"1101111";
  constant I: std_ulogic_vector := b"1011110";
  constant L: std_ulogic_vector := b"1011100";
  

end interface_types_pkg;