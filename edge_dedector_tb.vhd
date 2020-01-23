LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
entity edge_dedector_tb IS
end edge_dedector_tb;
 
architecture behavior of edge_dedector_tb is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component edge_dedector
    port(
         clk : IN  std_logic;
         A : IN  std_logic;
         B : IN  std_logic;
         reset : IN  std_logic;
         update : IN  std_logic;
         edge : OUT  std_logic_vector(1 downto 0)
        );
    end component;
    

   --Inputs
   signal clk : std_logic ;
   signal A : std_logic ;
   signal B : std_logic ;
   signal update : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal edge : std_logic_vector(1 downto 0):= "00";

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clkA_period : time := 200 ns;
   constant clkB_period : time := 400 ns;
   
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: stepper PORT MAP (
          clk => clk,
          A => A,
          B => B,
          reset => reset,
          update => update,
          edge => edge
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
       
   -- Stimulus process
   stim_proc: process
   begin		
      wait for clkA_period;
      reset<='1';
      wait for clkB_period;
      reset<='0';
      
      for i in 1 to 5 loop
      B <= '0';
      wait for 10*clk_period;
      A <= '0';
      wait for 10*clk_period;
      B <= '1';
      wait for 15*clk_period;
      A <= '1';
      wait for 10*clk_period;
      end loop;
      B <= '0';
      wait for 10*clk_period;
      A <= '0';
      
      wait for clkA_period;
      reset <= '1';
      wait for clkB_period;

      assert false
      report "Simulation Ended"
      severity failure;
   end process;

end;
