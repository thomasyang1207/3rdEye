library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Command_interpreter is
	port(
		clk,rst: in std_logic;
		
		command_complete: in std_logic;
		data_in: in unsigned(7 downto 0);
		
		buffer_empty: in std_logic;
		buffer_full: in std_logic;
		
		clear_buffer: out std_logic;
		get_next_byte: out std_logic;
		output_code: out unsigned(3 downto 0);
		output_valid: out std_logic
	);
end Command_interpreter;


architecture arch of Command_interpreter is
	--current byte, that was just processed.
	signal cur_byte_reg: unsigned(7 downto 0) := (others => '0');
	signal cur_byte_next: unsigned(7 downto 0);
	
	--States
	type state_type is (idle, parsing, done);
	type parse_type is (unknown, start_transfer, complete, no_clients, other_command);
	signal state_reg: state_type := idle;
	signal state_next: state_type;
	signal parse_state_reg: parse_type := unknown;
	signal parse_state_next: parse_type;
	
	--outputs
	signal output_code_reg : unsigned(3 downto 0) := (others => '0');
	signal output_code_next: unsigned(3 downto 0);
begin
	output_code <= output_code_reg;
	
	process(clk, rst)
	begin
		if rst = '1' then
			cur_byte_reg <= (others => '0');
			state_reg <= idle;
			parse_state_reg <= unknown;
			output_code_reg <= (others => '0');
		elsif rising_edge(clk) then
			cur_byte_reg <= cur_byte_next;
			state_reg <= state_next;
			parse_state_reg <= parse_state_next;
			output_code_reg <= output_code_next;
		end if;
	end process;
	
	get_next: process(state_reg, buffer_empty, buffer_full, cur_byte_reg, cur_byte_next, parse_state_reg, 
							data_in, command_complete, output_code_reg, parse_state_next)
	begin
		state_next <= state_reg;
		parse_state_next <= parse_state_reg;
		cur_byte_next <= cur_byte_reg;
		output_code_next <= output_code_reg;
		output_valid <= '0';
		get_next_byte <= '0';
		clear_buffer <= '0';
		case state_reg is
			when idle =>
				if command_complete = '0' or buffer_full = '1' then
					if buffer_empty = '0' then
						state_next <= parsing;
					end if;
				end if;
			when parsing =>
				
				if buffer_empty = '1' then
					state_next <= done;
					--check if we're ending on the right character
					case parse_state_reg is
						when start_transfer =>
							if cur_byte_reg /= x"72" then
								parse_state_next <= other_command;
							end if;
						when complete =>
							if cur_byte_reg /= x"65" then
								parse_state_next <= other_command;
							end if;
						when no_clients =>
							if cur_byte_reg /= x"65" then
								parse_state_next <= other_command;
							end if;
						when others => 
							parse_state_next <= other_command;
					end case;
					
					case parse_state_next is
						when start_transfer =>
							output_code_next <= x"1";
						when complete =>
							output_code_next <= x"2";
						when no_clients=>
							output_code_next <= x"3";
						when others =>
							output_code_next <= x"0";
					end case;
				else
					--get next character;
					cur_byte_next <= data_in;
					get_next_byte <= '1';
					case parse_state_reg is
						when unknown =>
							case cur_byte_next is
								when x"4e" =>
									parse_state_next <= no_clients;
								when x"53" =>
									parse_state_next <= start_transfer;
								when x"43" =>
									parse_state_next <= complete;
								when others =>
									parse_state_next <= other_command;
							end case;
						when start_transfer =>
							case cur_byte_reg is
								when x"53" =>
									if cur_byte_next /= x"74" then
										parse_state_next <= other_command;
									end if;
								when x"74" =>
									if cur_byte_next /= x"61" and cur_byte_next /= x"20" and cur_byte_next /= x"72" then
										parse_state_next <= other_command;
									end if;
								when x"61" =>
									if cur_byte_next /= x"72" and cur_byte_next /= x"6e" then 
										parse_state_next <= other_command;
									end if;
								when x"72" =>
									if cur_byte_next /= x"74" and cur_byte_next /= x"61" then 
										parse_state_next <= other_command;
									end if;
								when x"20" =>
									if cur_byte_next /= x"74" then
										parse_state_next <= other_command;
									end if;
								when x"6e" =>
									if cur_byte_next /= x"73" then
										parse_state_next <= other_command;
									end if;
								when x"73" =>
									if cur_byte_next /= x"66" then
										parse_state_next <= other_command;
									end if;
								when x"66" =>
									if cur_byte_next /= x"65" then
										parse_state_next <= other_command;
									end if;
								when x"65" =>
									if cur_byte_next /= x"72" then
										parse_state_next <= other_command;
									end if;
								when others =>
							end case;
						when complete =>
							case cur_byte_reg is
								when x"43" =>
									if cur_byte_next /= x"6f" then
										parse_state_next <= other_command;
									end if;
								when x"6f" =>
									if cur_byte_next /= x"6d" then
										parse_state_next <= other_command;
									end if;
								when x"6d" =>
									if cur_byte_next /= x"70" then
										parse_state_next <= other_command;
									end if;
								when x"70" =>
									if cur_byte_next /= x"6c" then
										parse_state_next <= other_command;
									end if;
								when x"6c" =>
									if cur_byte_next /= x"65" then
										parse_state_next <= other_command;
									end if;
								when x"65" =>
									if cur_byte_next /= x"74" then
										parse_state_next <= other_command;
									end if;
								when x"74" =>
									if cur_byte_next /= x"65" then
										parse_state_next <= other_command;
									end if;
								when others =>
							end case;
						when no_clients =>
							case cur_byte_reg is
								when x"4e" =>
									if cur_byte_next /= x"6f" then
										parse_state_next <= other_command;
									end if;
								when x"6f" =>
									if cur_byte_next /= x"6e" then
										parse_state_next <= other_command;
									end if;
								when x"6e" =>
									if cur_byte_next /= x"65" then
										parse_state_next <= other_command;
									end if;
								when others =>
									
							end case;
						when others =>
					end case;
				end if;
			when done =>
				output_valid <= '1';
				clear_buffer <= '1';
				state_next <= idle;
				parse_state_next <= unknown;
			when others =>
				--nothing really 
		end case;
	end process;

end arch;