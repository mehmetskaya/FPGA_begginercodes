----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2019 03:51:46 PM
-- Design Name: 
-- Module Name: logicgates_top - Behavioral
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
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity logicgates_top is
    Port ( sw : in STD_LOGIC_VECTOR (1 downto 0);
           led : out STD_LOGIC_VECTOR (3 downto 0));
end logicgates_top;

architecture Behavioral of logicgates_top is

component logicgates is 
  port (
     a : in STD_LOGIC;
     b : in STD_LOGIC;
     z : out STD_LOGIC_VECTOR (3 downto 0)
   );
end component;

begin
comp1 : logicgates
  port map
   (
     a=> sw(1),
     b=> sw(0),
     z=> led 
   );
end Behavioral;
