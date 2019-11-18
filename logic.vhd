----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2019 03:25:11 PM
-- Design Name: 
-- Module Name: logicgates - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
---
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity logic is

    Port ( 
           sysclk : in STD_LOGIC;
           sw     : in STD_LOGIC_VECTOR (2 downto 0);
           led    : out STD_LOGIC_VECTOR (3 downto 0) 
         );

end logic;

architecture Behavioral of logic is

begin

process (sysclk)

begin

if rising_edge(sysclk) then

   if sw(2)='1' then
   led <= (others => '0');
   
   else 
     led(3) <= sw(0) and sw(1);     
     led(2) <= sw(0) or sw(1);
     led(1) <= sw(0) xor sw(1);
     led(0) <= sw(0) xnor sw(1);
     
   end if;
   
   
end if;
     
end process;


end Behavioral;
