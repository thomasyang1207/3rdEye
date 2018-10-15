library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Mod_Counter_internal is 
	generic(
		maxNum : integer := 15
	); 
	
	port(
		clk      : in  std_logic;
		data_out	: out	std_logic_vector(3 downto 0);
		rst		: in 	std_logic
	); 
end Mod_Counter_internal; 

architecture arch of Mod_Counter_internal is
	signal curCount : unsigned(3 downto 0) := (others => '0');
	signal nextCount : unsigned(3 downto 0);
begin
	data_out <= std_logic_vector(curCount);
	
	process(clk, rst)
		begin
		if rst = '0' then 
			curCount <= "0000";
		elsif rising_edge(clk) then
			curCount <= nextCount;
		end if;
	end process;
	
	process(curCount)
		begin
		nextCount <= curCount + 1;
		if (curCount = to_unsigned(maxNum, 4)) then
			nextCount <= "0000";
		end if;
	end process;
	
end arch;