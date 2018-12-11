library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Command_terpreter_test is
end entity;

architecture tb of Command_terpreter_test is 
	signal clk,rst: std_logic;
	signal ena: std_logic;
		
	signal command_complete: std_logic;
	signal data_in: unsigned(7 downto 0);
		
	signal buffer_empty: std_logic;
	signal buffer_full: std_logic;
		
	signal clear_buffer: std_logic;
	signal get_next_byte: std_logic;
	signal output_code: unsigned(3 downto 0);
	signal output_valid: std_logic;
	
	type word is array (natural range<>) of unsigned(7 downto 0);
	
	constant testWord: word := (x"53", x"74", x"61", x"72", x"74", x"20", x"74", 
										 x"72", x"61", x"6e", x"73", x"66", x"65", x"72");
begin
	CUT: entity work.Command_interpreter port map(clk, rst, ena, command_complete, data_in, buffer_empty, buffer_full, 
																 clear_buffer, get_next_byte, output_code, output_valid);
	
	
	process
		variable i : integer range 0 to 20;
	begin	
		i := 0;
		clk <= '0'; 
		rst <= '1';
		ena <= '0';
		command_complete <= '0';
		data_in <= (others => '0');
		buffer_empty <= '0';
		buffer_full <= '0';
		
		wait for 5 ns;
		clk <= '1'; 
		wait for 5 ns; 
		clk <= '0';
		--start;
		command_complete <= '0';
		rst <= '0';
		ena <= '1';
		buffer_empty <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		
		while i < 14 loop
			command_complete <= '1';
			data_in <= testWord(i);
			if get_next_byte = '1' then
				i := i + 1;
			end if;
			
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
			clk <= '0';
		end loop;
		buffer_empty <= '1';
		
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns; 
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns; 
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns; 
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait;
	end process;
end tb;