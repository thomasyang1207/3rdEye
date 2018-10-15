library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Baud_rate_generator is 
	generic(
		clk_freq: integer := 50000000;
		baud_rate: integer := 115200;
		sample_rate: integer := 16
	);
	port(
		clk: in std_logic;
		enable: in std_logic;
		s_tick: out std_logic
	);
end Baud_rate_generator; 

architecture arch of Baud_rate_generator is
	constant limit : integer := clk_freq / (baud_rate * sample_rate);
	signal count_reg : unsigned(4 downto 0) := "00000"; 
	signal count_next : unsigned(4 downto 0);
	
	signal s_tick_reg : std_logic := '0';
	signal s_tick_next : std_logic; 
begin
	s_tick <= s_tick_reg;
	
	update_reg: process(clk, enable)
	begin
		if(enable = '0') then
			s_tick_reg <= '0';
			count_reg <= "00000";
		elsif(rising_edge(clk)) then
			count_reg <= count_next;
			s_tick_reg <= s_tick_next;
		end if;
	end process;
	
	combinational: process(s_tick_reg, count_reg)
	begin 
		count_next <= count_reg + to_unsigned(1,5);
		s_tick_next <= '0';
		if(count_reg = to_unsigned(limit, 5)) then
			count_next <= "00000";
		elsif(count_reg = to_unsigned(limit-1, 5)) then
			s_tick_next <= '1';
		end if;
	end process;
	
	
end arch;