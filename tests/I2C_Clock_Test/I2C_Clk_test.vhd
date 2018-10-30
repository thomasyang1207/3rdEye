library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_Clk_test is
end entity;

architecture tb of I2C_Clk_test is 
	signal clk: std_logic;
	signal enable: std_logic;
	signal i2c_tick: std_logic;
begin
	CUT: entity work.I2C_Clk_gen port map(clk => clk, enable => enable, i2c_tick => i2c_tick);
	
	process
	begin
		enable <= '1';
		clk <= '0';
		for i in 1 to 10000000 loop
			clk <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
		end loop;
	wait;
	end process;
end tb;