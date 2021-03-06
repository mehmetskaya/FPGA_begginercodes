library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
           reset : in STD_LOGIC;
           update: in STD_LOGIC;
           edge : out std_logic_vector(1 downto 0)
         );
end edge_dedector;

architecture Behavioral of edge_dedector is

signal r_edge_count : STD_LOGIC_VECTOR ( 19 downto 0);
signal f_edge_count : STD_LOGIC_VECTOR ( 19 downto 0);
signal twait : STD_LOGIC_VECTOR ( 3 downto 0);
signal Ad  : STD_LOGIC;
signal Bd  : STD_LOGIC;
signal Add :std_logic;
signal Bdd :std_logic;
signal Addd :std_logic;
signal Bddd :std_logic;
signal rising    :std_logic;
signal falling   :std_logic;

type state_type is(off,awake,count,trigger,risingedge,fallingedge);
signal state: state_type;
attribute INIT: STRING;
attribute INIT OF state: SIGNAL IS "off";

begin
Ad <= A;
Bd <= B;

edge_process : process (clk,reset)
begin

if reset = '1' then
edge <= "11";
r_edge_count <= (others => '0');
f_edge_count <= (others => '0');
twait <= (others => '0');
state <= awake;

elsif clk'event and clk='1' then
Add <= Ad;
Addd <= Add;
Bdd <= Bd;
Bddd <= Bdd;
if (Addd='1' and Add='0') or (Bddd='1' and Bdd='0') then
falling <= '1';
f_edge_count <= f_edge_count +'1';
else
falling <= '0';
end if;
if (Addd='0' and Add='1') or (Bddd='0' and Bdd='1') then
rising <= '1';
r_edge_count <= r_edge_count +'1';
else
rising <= '0';
end if;

case state is

when awake =>
edge <= "00";
twait <= twait + '1';
if twait="1111" then
state<=count;
else
state<=awake;
end if;

when count =>
if r_edge_count = "11" then
state<=trigger;
else
state<=count;
end if;
if f_edge_count = "11" then
state<=trigger;
else
state<=count;
end if;

when trigger =>
if f_edge_count > r_edge_count then
state<=fallingedge;
edge <= "01";
else
state<=risingedge;
edge <= "10";
end if;

when fallingedge =>
if update = '1' then
state<=awake;
else
state<=fallingedge;
end if;

when risingedge =>
if update = '1' then
state<=awake;
else
state<=risingedge;
end if;

when others =>
state<=off;

end case;
end if;
end process;
end Behavioral;
