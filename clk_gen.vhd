---------------------------------------------------------------------------------
-- Company:        
-- Engineer:       SKaya
--
-- Create Date:    11:33:33 01/22/2020 
-- Design Name:    Clock Generation
-- Module Name:    clk_gen - Behavioral 
-- Project Name:   Step Motor
-- Target Devices: Spartan 6 (Mimas V2)
-- Tool versions:  ISE 14.7
-- Description:    This module is created to generate clock needed for components
--
-- Dependencies:   -
-- Revision:       0.01
-- Comments:       Revision 0.01 - File Created
---------------------------------------------------------------------------------
-- Purpose:
---------------------------------------------------------------------------------
-- The purpose of this module is to create a slower clock for components to run.
-- It takes the value of N_times and bits_needed, and it creates a register of 
-- bits_needed length with a constant value of N_times -1 (count_full_c). Also 
-- another register of bits_needed length (count_r) is incremented to reach the
-- value of constant valued register, once reached it toggles the clk_out_buf. This
-- way clk_comp is created with a period of 2*N_times times of the feeded clk period.
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clk_gen is
   Generic(
      bits_needed : integer ;    -- Bits needed for the value of N_times -1.
      N_times     : integer);    -- 2*N_times time slower clock generation.
   Port ( 
      clk      : in  STD_LOGIC;  -- System Clock
      reset_n  : in  STD_LOGIC;  -- Asynchronous active low reset
      clk_out  : out  STD_LOGIC  -- Generated Clock
      );                         -- [T_clk_out=T_clk/(2*N_times)]
end clk_gen;

architecture Behavioral of clk_gen is

--Counter Register that counts up to the N_times-1 value.
signal count_r        : std_logic_vector((bits_needed-1) downto 0);
--Counter Constant that keeps the full value of N_times-1.
signal count_full_c   : std_logic_vector((bits_needed-1) downto 0);

-- Input clock buffering
signal clk_in_buf        : std_logic ;

-- Output clock buffering
signal clk_out_buf       : std_logic ;

-------------------------------------------------------------------------------
-- For Clock Generation Input/Output Buffering is needed to meet the time
-- constraints. Note that since IBUFG and BUFG are Xilinx Components/Primitives,
-- it does not needed to component declerations, but only uncomment the 
-- relative library.
-------------------------------------------------------------------------------

begin

-- assign the value of count_full_c to N_times-1.
count_full_c<= std_logic_vector(to_unsigned((N_times)-1,count_full_c'length));

-------------------------------------
-- Input buffering
-------------------------------------
clkin_buffer : IBUFG
port map(
   O => clk_in_buf,
   I => clk);
-------------------------------------

-------------------------------------   
-- Clock Generation
------------------------------------- 
clk_gen : process (clk_in_buf, reset_n)
   begin
      if reset_n='0' then  -- If active low reset is asserted
         count_r <= (others => '0');-- Initialize the counter registers
         clk_out_buf <= '0'; -- Clk output is pulled low
      elsif clk_in_buf'event and clk_in_buf = '1' then -- elsif on rising edge of clk
      count_r <= count_r + '1'; -- increment the counter register
         if count_r = count_full_c then -- if counter register is equal to N_times-1
            count_r <= (others => '0'); -- reset the counter register
            clk_out_buf <= not clk_out_buf;-- toggle the clk_out_buf
         else -- else counter register is not equal to N_times-1
            clk_out_buf <= clk_out_buf;-- keep the clk_out_buf the same
         end if;
      end if;
   end process;
-------------------------------------

-------------------------------------
-- Output buffering
-------------------------------------
clkout_buffer : BUFG
port map(
   O => clk_out,
   I => clk_out_buf);
-------------------------------------
    
end Behavioral;
