--------------------------------------------------------------------------------
-- Company: Drake Digital
--
-- File: seven_seg_controller.vhd
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
library work;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.interface_types_pkg.all;

entity seven_seg_controller is
  port(
    clk_20MHz: IN std_ulogic;
	sys_reset: IN std_ulogic;
	frequency: IN freq_t;
	digit_0: OUT byte;
	digit_1: OUT byte;
	digit_2: OUT byte;
	digit_3: OUT byte;
	digit_4: OUT byte;
	digit_5: OUT byte
  );
end seven_seg_controller;

architecture rtl of seven_seg_controller is
  signal digit_0_n : byte;
  signal digit_1_n : byte;
  signal digit_2_n : byte;
  signal digit_3_n : byte;
  signal digit_4_n : byte;
  signal digit_5_n : byte;
  signal segs_0 : std_ulogic_vector(6 downto 0);
  signal segs_1 : std_ulogic_vector(6 downto 0);
  signal segs_2 : std_ulogic_vector(6 downto 0);
  signal segs_3 : std_ulogic_vector(6 downto 0);
  signal segs_4 : std_ulogic_vector(6 downto 0);
  signal segs_5 : std_ulogic_vector(6 downto 0);
  signal dec_pt : std_ulogic;
  signal seven_seg_state: seven_seg_state_t;
  signal digit0_int: digit_t;
  signal digit1_int: digit_t;
  signal digit2_int: digit_t;
  signal digit3_int: digit_t;
  signal digit4_int: digit_t;
  signal digit5_int: digit_t;
  signal digit_slicer_state: digit_slice_state_t;
  signal output_driver_state: output_driver_state_t;
	
begin
-- Continuous Assignments --------------------	
	digit_0 <= digit_0_n;
	digit_1 <= digit_1_n;
	digit_2 <= digit_2_n;
	digit_3 <= digit_3_n;
	digit_4 <= digit_4_n;
	digit_5 <= digit_5_n;
----------------------------------------------

  digit_slicer: process(clk_20MHz, sys_reset) is
    variable x1: freq_t := 0;
	variable x2: freq_t := 0;
	variable x3: freq_t := 0;
	variable x4: freq_t := 0;
	variable x5: freq_t := 0;
	variable x1_mod: freq_t :=0;
	variable x2_mod: freq_t :=0;
	variable x3_mod: freq_t :=0;
	variable x4_mod: freq_t :=0;
	variable x5_mod: freq_t :=0;
	begin
	  if(sys_reset = '1') then
	    digit0_int <= 0;
	    digit1_int <= 0;
	    digit2_int <= 0;
	    digit3_int <= 0;
	    digit4_int <= 0;
	    digit5_int <= 0;
		x1 := 0;
		x2 := 0;
		x3 := 0;
		x4 := 0;
		x5 := 0;
		x1_mod :=0;
		x2_mod :=0;
		x3_mod :=0;
		x4_mod :=0;
		x5_mod :=0;
	    digit_slicer_state <= INIT;
	  elsif rising_edge(clk_20MHz) then
	    case(digit_slicer_state) is
		  ------------
		  when INIT =>
		  ------------
		    digit0_int <= 0;
			digit1_int <= 0;
			digit2_int <= 0;
			digit3_int <= 0;
			digit4_int <= 0;
			digit5_int <= 0;
		    x1 := 0;
		    x2 := 0;
		    x3 := 0;
		    x4 := 0;
		    x5 := 0;
			x1_mod :=0;
		    x2_mod :=0;
		    x3_mod :=0;
		    x4_mod :=0;
		    x5_mod :=0;
			digit_slicer_state <= EXTRACT_D0;
			
		  ------------------
	      when EXTRACT_D0 =>
		  ------------------
		    digit0_int <= frequency MOD(10);
			digit_slicer_state <= ISOLATE_D1;
		    
		  ------------------
	      when ISOLATE_D1 =>
		  ------------------
		    x1 := frequency - digit0_int;
			x1_mod := x1 MOD(100);
			digit_slicer_state <= EXTRACT_D1;
			
		  ------------------
	      when EXTRACT_D1 =>
		  ------------------
			digit1_int <= x1_mod / 10;
			digit_slicer_state <= ISOLATE_D2;
			
		  ------------------
	      when ISOLATE_D2 =>
		  ------------------
			x2 := x1 - x1_mod;
			x2_mod := x2 MOD(1000);
			digit_slicer_state <= EXTRACT_D2;
			
		  ------------------
		  when EXTRACT_D2 =>
		  ------------------
			digit2_int <= x2_mod / 100;
			digit_slicer_state <= ISOLATE_D3;
			
		  ------------------
	      when ISOLATE_D3 =>
		  ------------------
			x3 := x2 - x2_mod;
			x3_mod := x3 MOD(10000);
			digit_slicer_state <= EXTRACT_D3;
			
		  ------------------
		  when EXTRACT_D3 =>
		  ------------------
			digit3_int <= x3_mod / 1000;
			digit_slicer_state <= ISOLATE_D4;
			
		  ------------------
	      when ISOLATE_D4 =>
		  ------------------
		    x4 := x3 - x3_mod;
			x4_mod := x4 MOD(100000);
			digit_slicer_state <= EXTRACT_D4;
			
		  ------------------
		  when EXTRACT_D4 =>
		  ------------------
			digit4_int <= x4_mod / 10000;
			digit_slicer_state <= ISOLATE_D5;
			
		  ------------------
	      when ISOLATE_D5 =>
		  ------------------
			--x5 := x4 - x4_mod;  --FIXME
			--x5_mod := x5 MOD(100000);
			digit_slicer_state <= EXTRACT_D5;
			
		  ------------------
		  when EXTRACT_D5 =>
		  ------------------
			--digit5_int <= x5_mod / 10000;
			digit_slicer_state <= DONE;
			
		  ------------
		  when DONE =>
		  ------------
			--hold new output finishes;
			if(output_driver_state = DONE) then
			  digit_slicer_state <= INIT;
			end if;
		
		  --------------
		  when others =>
		  --------------
		    digit_slicer_state <= INIT;
		  
		end case;			
	  end if;
  end process digit_slicer;
  
  
  output_driver: process(clk_20MHz, sys_reset) is
    begin
	  if(sys_reset = '1') then
	    output_driver_state <= INIT;
		digit_0_n <= (others =>'1'); --display off;
	    digit_1_n <= (others =>'1');
	    digit_2_n <= (others =>'1');
	    digit_3_n <= (others =>'1');
	    digit_4_n <= (others =>'1');
	    digit_5_n <= (others =>'1');
		segs_0 <= (others =>'1');
		segs_1 <= (others =>'1');
		segs_2 <= (others =>'1');
		segs_3 <= (others =>'1');
		segs_4 <= (others =>'1');
		segs_5 <= (others =>'1');
		dec_pt <= '1';
	  elsif rising_edge(clk_20MHz) then
	    case(output_driver_state) is
		  ------------
		  when INIT =>
		  ------------
			segs_0 <= ZERO;
		    segs_1 <= ZERO;
		    segs_2 <= ZERO;
		    segs_3 <= ZERO;
		    segs_4 <= ZERO;
		    segs_5 <= ZERO;
		    dec_pt  <= '1';
			output_driver_state <= WAIT_UNTIL_DATA_READY;
			
		  -----------------------------
		  when WAIT_UNTIL_DATA_READY =>
		  -----------------------------
		    if(digit_slicer_state = DONE) then
			  output_driver_state <= PREPARE_OUTPUT;
			end if;
		  
		  ----------------------
		  when PREPARE_OUTPUT =>
		  ----------------------
		    case(digit0_int) is
		      when(0) => segs_0 <= ZERO;
			  when(1) => segs_0 <= ONE;
			  when(2) => segs_0 <= TWO;
			  when(3) => segs_0 <= THREE;
			  when(4) => segs_0 <= FOUR;
			  when(5) => segs_0 <= FIVE;
			  when(6) => segs_0 <= SIX;
			  when(7) => segs_0 <= SEVEN;
			  when(8) => segs_0 <= EIGHT;
			  when(9) => segs_0 <= NINE;
			  when others => segs_0 <= OFF;
		    end case;
			
			case(digit1_int) is
		      when(0) => segs_1 <= ZERO;
			  when(1) => segs_1 <= ONE;
			  when(2) => segs_1 <= TWO;
			  when(3) => segs_1 <= THREE;
			  when(4) => segs_1 <= FOUR;
			  when(5) => segs_1 <= FIVE;
			  when(6) => segs_1 <= SIX;
			  when(7) => segs_1 <= SEVEN;
			  when(8) => segs_1 <= EIGHT;
			  when(9) => segs_1 <= NINE;
			  when others => segs_1 <= OFF;
		    end case;
			
			case(digit2_int) is
		      when(0) => segs_2 <= ZERO;
			  when(1) => segs_2 <= ONE;
			  when(2) => segs_2 <= TWO;
			  when(3) => segs_2 <= THREE;
			  when(4) => segs_2 <= FOUR;
			  when(5) => segs_2 <= FIVE;
			  when(6) => segs_2 <= SIX;
			  when(7) => segs_2 <= SEVEN;
			  when(8) => segs_2 <= EIGHT;
			  when(9) => segs_2 <= NINE;
			  when others => segs_2 <= OFF;
		    end case;
			
			case(digit3_int) is
		      when(0) => segs_3 <= ZERO;
			  when(1) => segs_3 <= ONE;
			  when(2) => segs_3 <= TWO;
			  when(3) => segs_3 <= THREE;
			  when(4) => segs_3 <= FOUR;
			  when(5) => segs_3 <= FIVE;
			  when(6) => segs_3 <= SIX;
			  when(7) => segs_3 <= SEVEN;
			  when(8) => segs_3 <= EIGHT;
			  when(9) => segs_3 <= NINE;
			  when others => segs_3 <= OFF;
		    end case;
			
			case(digit4_int) is
		      when(0) => segs_4 <= ZERO;
			  when(1) => segs_4 <= ONE;
			  when(2) => segs_4 <= TWO;
			  when(3) => segs_4 <= THREE;
			  when(4) => segs_4 <= FOUR;
			  when(5) => segs_4 <= FIVE;
			  when(6) => segs_4 <= SIX;
			  when(7) => segs_4 <= SEVEN;
			  when(8) => segs_4 <= EIGHT;
			  when(9) => segs_4 <= NINE;
			  when others => segs_4 <= OFF;
		    end case;
			
			case(digit5_int) is
		      when(0) => segs_5 <= ZERO;
			  when(1) => segs_5 <= ONE;
			  when(2) => segs_5 <= TWO;
			  when(3) => segs_5 <= THREE;
			  when(4) => segs_5 <= FOUR;
			  when(5) => segs_5 <= FIVE;
			  when(6) => segs_5 <= SIX;
			  when(7) => segs_5 <= SEVEN;
			  when(8) => segs_5 <= EIGHT;
			  when(9) => segs_5 <= NINE;
			  when others => segs_5 <= OFF;
		    end case;
		    
			--Save power using underbar instead of "0" if not in use;
			if(frequency < 10) then
			  segs_1 <= UNDERBAR;
			  segs_2 <= UNDERBAR;
			  segs_3 <= UNDERBAR;
			  segs_4 <= UNDERBAR;
			  segs_5 <= UNDERBAR;
			elsif(frequency < 100) then
			  segs_2 <= UNDERBAR;
			  segs_3 <= UNDERBAR;
			  segs_4 <= UNDERBAR;
			  segs_5 <= UNDERBAR;
			elsif(frequency < 1000) then
			  segs_3 <= UNDERBAR;
			  segs_4 <= UNDERBAR;
			  segs_5 <= UNDERBAR;
			elsif(frequency < 10000) then
			  segs_4 <= UNDERBAR;
			  segs_5 <= UNDERBAR;
			elsif(frequency < 100000) then
			  segs_5 <= UNDERBAR;
			end if;
			output_driver_state <= DRIVE_OUTPUT;
		  
		  --------------------
		  when DRIVE_OUTPUT =>
		  --------------------
		    digit_0_n <= (segs_0(6), segs_0(5), segs_0(4), segs_0(3), dec_pt, segs_0(2), segs_0(1), segs_0(0));
		    digit_1_n <= (segs_1(6), segs_1(5), segs_1(4), segs_1(3), dec_pt, segs_1(2), segs_1(1), segs_1(0));
		    digit_2_n <= (segs_2(6), segs_2(5), segs_2(4), segs_2(3), dec_pt, segs_2(2), segs_2(1), segs_2(0));
		    digit_3_n <= (segs_3(6), segs_3(5), segs_3(4), segs_3(3), dec_pt, segs_3(2), segs_3(1), segs_3(0));
		    digit_4_n <= (segs_4(6), segs_4(5), segs_4(4), segs_4(3), dec_pt, segs_4(2), segs_4(1), segs_4(0));
		    digit_5_n <= (segs_5(6), segs_5(5), segs_5(4), segs_5(3), dec_pt, segs_5(2), segs_5(1), segs_5(0));
		    output_driver_state <= DONE;
			
		  ------------
		  when DONE =>
		  ------------
		    output_driver_state <= WAIT_UNTIL_DATA_READY;
			
		  --------------
		  when others =>
		  --------------
		    output_driver_state <= INIT;
			
		end case;
	  end if;
    end process output_driver;
  
  
  
  
  -- init_sequence: process(clk_20MHz, sys_reset) is
    -- variable seg_count : integer := 0;
    -- variable clk_count : integer := 0;
    -- begin
	-- if(sys_reset = '1') then
	  -- seg_count := 0;
	  -- clk_count := 0;
	  -- segs_0 <= (others =>'1');
	  -- dec_pt  <= '1';
	  -- digit_0_n <= (others =>'1'); --display off;
	  -- digit_1_n <= (others =>'1');
	  -- digit_2_n <= (others =>'1');
	  -- digit_3_n <= (others =>'1');
	  -- digit_4_n <= (others =>'1');
	  -- digit_5_n <= (others =>'1');
	  -- seven_seg_state <= INIT;
    -- elsif rising_edge(clk_20MHz) then
	  -- case(seven_seg_state) is
	    -- --------------
		-- when(INIT) =>
		-- --------------
		  -- seg_count := 0;
	      -- clk_count := 0;
		  -- segs_0 <= (others =>'1');
		  -- digit_0_n <= (others =>'1');
		  -- digit_1_n <= (others =>'1');
		  -- digit_2_n <= (others =>'1');
	      -- digit_3_n <= (others =>'1');
		  -- digit_4_n <= (others =>'1');
	      -- digit_5_n <= (others =>'1');
		  -- seven_seg_state <= CLK_COUNTING;
		
		-- ---------------------
		-- when(CLK_COUNTING) =>
		-- ---------------------
		  -- digit_0_n <= (segs_0(6), segs_0(5), segs_0(4), segs_0(3), dec_pt, segs_0(2), segs_0(1), segs_0(0));
		  -- digit_1_n <= (segs_0(6), segs_0(5), segs_0(4), segs_0(3), dec_pt, segs_0(2), segs_0(1), segs_0(0));
		  -- digit_2_n <= (segs_0(6), segs_0(5), segs_0(4), segs_0(3), dec_pt, segs_0(2), segs_0(1), segs_0(0));
		  -- digit_3_n <= (segs_0(6), segs_0(5), segs_0(4), segs_0(3), dec_pt, segs_0(2), segs_0(1), segs_0(0));
		  -- digit_4_n <= (segs_0(6), segs_0(5), segs_0(4), segs_0(3), dec_pt, segs_0(2), segs_0(1), segs_0(0));
		  -- digit_5_n <= (segs_0(6), segs_0(5), segs_0(4), segs_0(3), dec_pt, segs_0(2), segs_0(1), segs_0(0));
		  -- clk_count := clk_count + 1;
          -- if(clk_count = MAXCOUNT) then
		    -- seg_count := seg_count + 1;
            -- clk_count := 0;
	      -- end if;
          -- if (seg_count = 10) then
            -- seven_seg_state <= INIT;
          -- end if;
		  -- case(seg_count) is
		    -- when(0) => segs_0 <= ZERO;
			-- when(1) => segs_0 <= ONE;
			-- when(2) => segs_0 <= TWO;
			-- when(3) => segs_0 <= THREE;
			-- when(4) => segs_0 <= FOUR;
			-- when(5) => segs_0 <= FIVE;
			-- when(6) => segs_0 <= SIX;
			-- when(7) => segs_0 <= SEVEN;
			-- when(8) => segs_0 <= EIGHT;
			-- when(9) => segs_0 <= NINE;
			-- when others => segs_0 <= OFF;
		  -- end case;
		  
		-- ---------------
		-- when others => seven_seg_state <= INIT;
		-- ---------------
	  -- end case;
    -- end if;
  -- end process;
  
end rtl;