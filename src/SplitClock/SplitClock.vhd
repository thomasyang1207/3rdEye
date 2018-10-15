library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SplitClock is
	generic(
		clkFreq : integer := 50000000;
		clkPeriod: integer := 1 --one second; 
	);
	port(
		clk : in std_logic; 
		rst : in std_logic;
		splitClk: out std_logic
	);
end SplitClock;


architecture arch of SplitClock is
	signal clkReg : unsigned(25 downto 0) := to_unsigned(0,26);
	signal clkNext : unsigned(25 downto 0);
begin
	updateReg: process(clk, rst)
		begin
			if(rst = '0') then 
				clkReg <= to_unsigned(0,26);
			elsif rising_edge(clk) then
				clkReg <= clkNext;
			end if;
	end process;
	
	getNextClkCount: process(clkReg)
		begin
			clkNext <= clkReg + to_unsigned(1, 26);
			if(clkReg = to_unsigned(clkFreq * clkPeriod,26)) then 
				clkNext <= to_unsigned(0,26);
			end if;
	end process; 
	
	setClockOutput: process(clkReg)
		begin
			splitClk <= '0';
			if(clkReg = to_unsigned(0, 26)) then 
				splitClk <= '1';
			end if;
		
	end process;
	
	

end arch; 