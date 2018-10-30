library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity I2C_Clk_gen is
	generic(
		clk_freq : integer := 50000000; --FPGA Board clock speed = 50 MHz. Can change in the future.
		i2c_freq : integer := 100000; --400Khz clock speed
		division : integer := 4 --the module will tick 4 times per i2c clock cycle... 
	);
	port(
		clk: in std_logic;
		enable: in std_logic; -- active high
		i2c_tick: out std_logic
	);
end entity;


architecture arch of I2C_Clk_gen is
	constant limit: integer := clk_freq / i2c_freq / division; --be on the safe side... 
	signal count_reg : integer := 0;
	signal count_next : integer;
begin
	
	update_clked: process(clk, enable)
	begin
		if enable = '0' then
			count_reg <= 0;
		elsif rising_edge(clk) then
			count_reg <= count_next;
		end if;
	end process;
	
	next_num: process(count_reg)
	begin
		i2c_tick <= '0';
		count_next <= count_reg + 1;
		if(count_reg = limit) then
			count_next <= 0; --reset counter
			i2c_tick <= '1';
		end if;
	end process;
	
end arch;