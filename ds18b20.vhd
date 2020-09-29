library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity ds18b20 is
   Generic(
         clock_sys_Mhz : integer := 100 );-- please put the integer value of the system clock as MHz (i.e 4MHz => 4 )
   Port(
         clk_sys : in std_logic; -- system clock
         reset   : in std_logic; -- system reset
         read_t  : in std_logic; -- start temperature reading
         dq      : inout std_logic; -- onewire
         temp_h  : out std_logic_vector(7 downto 0); -- MSB of temperature reading [0 & (11 downto 5)]
         temp_l  : out std_logic_vector(7 downto 0)  -- LSB of temperature reading [0000 & (4 downto 1)]
   );
end entity;
 
architecture Behavioral of ds18b20 is
 
TYPE STATE_TYPE is (IDLE,START,WAIT_TIME,CMD_CC,WRITE_BYTE,WRITE_LOW,WRITE_HIGH,READ_BIT,CMD_44,CMD_BE,GET_TMP);
signal STATE: STATE_TYPE;
 
signal write_temp : std_logic_vector(7 downto 0):="00000000";
signal TMP        : std_logic_vector(11 downto 0);
signal tmp_bit    : std_logic:='0';
 
signal WRITE_BYTE_CNT  : integer range 0 to 8:=0;
signal WRITE_LOW_CNT   : integer range 0 to 2:=0;
signal WRITE_HIGH_CNT  : integer range 0 to 2:=0;
signal READ_BIT_CNT    : integer range 0 to 3:=0;
signal GET_TMP_CNT     : integer range 0 to 12:=0;
signal WRITE_BYTE_FLAG : integer range 0 to 4:=0;
signal cnt             : integer range 0 to 100001:=0;

signal count      : integer range 0 to (2*clock_sys_Mhz-2):=0;
signal clk_temp   : std_logic:='0';
signal clk        : std_logic;
 
begin
 
ClkDivider:process (clk_sys,clk_temp)
begin
   if rising_edge(clk_sys) then
      if (count = (2*clock_sys_Mhz-2)) then
         count <= 0;
         clk_temp<= not clk_temp;
      else
         count <= count +2;
      end if;
   end if;
   clk<=clk_temp; -- 0.5 Mhz clock to run the thermometer for easy calculation of timing diagram.
end Process;
 
 
STATE_TRANSITION:
process(STATE,clk,reset)
begin
   
   if reset = '1' then
      STATE<=IDLE;
   elsif rising_edge(clk) then
      case STATE is
         
         when IDLE=>
            if read_t = '1' then
               STATE<=START;
            else
               STATE<=IDLE;
            end if;
         
         when START=>
            if (cnt>=0 and cnt<250) then -- counter values for 0.5 Mhz clock
            --if (cnt>=0 and cnt<500) then -- counter values for 1 Mhz clock
            --if (cnt>=0 and cnt<2000) then -- counter values for 4 Mhz clock
               dq<='0';
               cnt<=cnt+1;
               STATE<=START;
            elsif (cnt>=250 and cnt<500) then -- counter values for 0.5 Mhz clock
            --elsif (cnt>=500 and cnt<1000) then -- counter values for 1 Mhz clock
            --elsif (cnt>=2000 and cnt<4000) then -- counter values for 4 Mhz clock
               dq<='Z';
               cnt<=cnt+1;
               STATE<=START;
            elsif (cnt>=500) then -- counter values for 0.5 Mhz clock
            --elsif (cnt>=1000) then -- counter values for 1 Mhz clock
            --elsif (cnt>=4000) then -- counter values for 4 Mhz clock
               cnt<=0;
               STATE<=CMD_CC;
            end if;

         when WAIT_TIME=>
            if (cnt>=0 and cnt<250) then -- counter values for 0.5 Mhz clock
            --if (cnt>=0 and cnt<500) then -- counter values for 1 Mhz clock
            --if (cnt>=0 and cnt<2000) then -- counter values for 4 Mhz clock
               dq<='0';
               cnt<=cnt+1;
               STATE<=WAIT_TIME;
            elsif (cnt>=250 and cnt<500) then -- counter values for 0.5 Mhz clock
            --elsif (cnt>=500 and cnt<1000) then -- counter values for 1 Mhz clock
            --elsif (cnt>=2000 and cnt<4000) then -- counter values for 4 Mhz clock
               dq<='Z';
               cnt<=cnt+1;
               STATE<=WAIT_TIME;
            elsif (cnt>=500) then -- counter values for 0.5 Mhz clock
            --elsif (cnt>=1000) then -- counter values for 1 Mhz clock
            --elsif (cnt>=4000) then -- counter values for 4 Mhz clock
               cnt<=0;
               STATE<=CMD_CC;
            end if;
         
         when CMD_CC=> -- command CCh ( Skip ROM Command )
            write_temp<="11001100";
            STATE<=WRITE_BYTE;
         
         when CMD_44=> -- command 44h ( Convert Temperature Command )
            write_temp<="01000100";
            STATE<=WRITE_BYTE;
         
         when CMD_BE=> -- command BEh ( Read Scratchpad Command )
            write_temp<="10111110";
            STATE<=WRITE_BYTE;
         
         when WRITE_BYTE=>
            case WRITE_BYTE_CNT is
               when 0 to 7=>
                  if (write_temp(WRITE_BYTE_CNT)='0') then
                     STATE<=WRITE_LOW;
                  else
                     STATE<=WRITE_HIGH;
                  end if;
                  WRITE_BYTE_CNT<=WRITE_BYTE_CNT+1;
               when 8=>
                  if (WRITE_BYTE_FLAG=0) then
                     STATE<=CMD_44;
                     WRITE_BYTE_FLAG<=1;
                  elsif (WRITE_BYTE_FLAG=1) then
                     STATE<=WAIT_TIME;
                     WRITE_BYTE_FLAG<=2;
                  elsif (WRITE_BYTE_FLAG=2) then
                     STATE<=CMD_BE;
                     WRITE_BYTE_FLAG<=3;
                  elsif (WRITE_BYTE_FLAG=3) then
                     STATE<=GET_TMP;
                     WRITE_BYTE_FLAG<=0;
                  end if;
                  WRITE_BYTE_CNT<=0;
            end case;
         
         when WRITE_LOW=>
            case WRITE_LOW_CNT is
               when 0=>
                  dq<='0';
                  if (cnt=39) then -- counter values for 0.5 Mhz clock
                  --if (cnt=78) then -- counter values for 1 Mhz clock
                  --if (cnt=312) then -- counter values for 4 Mhz clock
                     cnt<=0;
                     WRITE_LOW_CNT<=1;
                  else
                     cnt<=cnt+1;
                  end if;
               when 1=>
                  dq<='Z';
                  if (cnt=1) then -- counter values for 0.5 Mhz clock
                  --if (cnt=2) then -- counter values for 1 Mhz clock
                  --if (cnt=8) then -- counter values for 4 Mhz clock
                     cnt<=0;
                     WRITE_LOW_CNT<=2;
                  else
                     cnt<=cnt+1;
                  end if;
               when 2=>
                  STATE<=WRITE_BYTE;
                  WRITE_LOW_CNT<=0;
               when others=>
                  WRITE_LOW_CNT<=0;
            end case;
            
         when WRITE_HIGH=>
            case WRITE_HIGH_CNT is
               when 0=>
                  dq<='0';
                  if (cnt=4) then -- counter values for 0.5 Mhz clock
                  --if (cnt=8) then -- counter values for 1 Mhz clock
                  --if (cnt=32) then -- counter values for 4 Mhz clock
                     cnt<=0;
                     WRITE_HIGH_CNT<=1;
                  else
                     cnt<=cnt+1;
                  end if;
               when 1=>
                  dq<='Z';
                  if (cnt=36) then -- counter values for 0.5 Mhz clock
                  --if (cnt=72) then -- counter values for 1 Mhz clock
                  --if (cnt=288) then -- counter values for 4 Mhz clock
                     cnt<=0;
                     WRITE_HIGH_CNT<=2;
                  else
                     cnt<=cnt+1;
                  end if;
               when 2=>
                  STATE<=WRITE_BYTE;
                  WRITE_HIGH_CNT<=0;
               when others=>
                  WRITE_HIGH_CNT<=0;
            end case;
         
         when READ_BIT=>
            case READ_BIT_CNT is
               when 0=>
                  dq<='0';
                  if (cnt=2) then -- counter values for 0.5 Mhz clock
                  --if (cnt=4) then -- counter values for 1 Mhz clock
                  --if (cnt=16) then -- counter values for 4 Mhz clock
                     READ_BIT_CNT<=1;
                     cnt<=0;
                  else
                     cnt<=cnt+1;
                  end if;
               when 1=>
                  dq<='Z';
                  if (cnt=2) then -- counter values for 0.5 Mhz clock
                  --if (cnt=4) then -- counter values for 1 Mhz clock
                  --if (cnt=16) then -- counter values for 4 Mhz clock
                     READ_BIT_CNT<=2;
                     cnt<=0;
                  else
                     cnt<=cnt+1;
                  end if;
               when 2=>
                  TMP_BIT<=dq;
                  if (cnt=1) then -- counter values for 0.5 Mhz clock *****
                  --if (cnt=1) then -- counter values for 1 Mhz clock
                  --if (cnt=4) then -- counter values for 4 Mhz clock
                     READ_BIT_CNT<=3;
                     TMP(GET_TMP_CNT)<=TMP_BIT;
                     cnt<=0;
                  else
                     cnt<=cnt+1;
                  end if;
               when 3=>
                  if (cnt=22) then -- counter values for 0.5 Mhz clock *****
                  --if (cnt=45) then -- counter values for 1 Mhz clock
                  --if (cnt=180) then -- counter values for 4 Mhz clock
                     cnt<=0;
                     READ_BIT_CNT<=0;
                     STATE<=GET_TMP;
                     GET_TMP_CNT<=GET_TMP_CNT+1;
                  else
                     cnt<=cnt+1;
                  end if;
               when others=>
                  READ_BIT_CNT<=0;
            end case;
         
         when GET_TMP=>
            case GET_TMP_CNT is
               when 0 to 11=>
               STATE<=READ_BIT;
               when 12=>
               GET_TMP_CNT<=0;
               STATE<=IDLE;
            end case;
         
         when others=>
            STATE<=IDLE;
      
      end case;
   
   end if;

end process;
 
temp_h <= TMP(11 downto 4);
temp_l <= "0000"&TMP(3 downto 0);
 
end Behavioral;
