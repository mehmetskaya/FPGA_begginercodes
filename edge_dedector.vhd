----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2020 10:20:01 PM
-- Design Name: 
-- Module Name: edge_dedctor - Behavioral
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

entity edge_dedector is
    Port ( clk : in STD_LOGIC;
           A : in STD_LOGIC;
           B : in STD_LOGIC;
           edge : out STD_LOGIC);
end edge_dedector;

architecture Behavioral of edge_dedector is

begin


end Behavioral;
