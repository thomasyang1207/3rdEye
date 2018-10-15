library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Receiver_logic is
	generic(
		initial_offset: integer := 7;
		bit_width: integer := 15;
		stop_width: integer := 16
	);
	port(
		clk: in std_logic; --regular clock 
		rst: in std_logic; --reset = active high;
		s_tick: in std_logic;
		rx: in std_logic; --interface for clock
		
		s_enable: out std_logic;
		rx_ready: out std_logic;
		data_out: out std_logic_vector(7 downto 0);
		output_valid: out std_logic
	);
end UART_Receiver_logic; 

architecture arch of UART_Receiver_logic is
	signal counter_reg: unsigned(3 downto 0) := "0000"; 
	signal counter_next: unsigned(3 downto 0);
	
	signal bit_reg: unsigned(2 downto 0) := "000";
	signal bit_next: unsigned(2 downto 0);
	
	signal data_reg : std_logic_vector(7 downto 0); 
	signal data_next : std_logic_vector(7 downto 0); 
	
	type UART_state is (idle, start, busy, stop); --update output during transition from stop condition to 

	signal state_reg : UART_state := start;
	signal state_next: UART_state; 
begin
	upate_state: process(clk, rst, state_next, data_next, counter_next)
	begin
		if(rst = '1') then
			data_reg <= (others=>'0');
			counter_reg <= (others => '0');
			bit_reg <= (others => '0');
			state_reg <= idle;
		elsif(rising_edge(clk)) then
			counter_reg <= counter_next;
			data_reg <= data_next;
			bit_reg <= bit_next;
			state_reg <= state_next;
		end if;
	end process;
	
	next_state: process(state_reg, counter_reg, data_reg, bit_reg, s_tick, rx)
	begin
		state_next <= state_reg; --don't change state by default... 
		data_next <= data_reg;
		bit_next <= bit_reg;
		counter_next <= counter_reg;
		output_valid <= '0';
		s_enable <= '1';
		rx_ready <= '0';
		case state_reg is
			when idle =>
				rx_ready <= '1';
				s_enable <= '0';
				if(rx = '0') then
					state_next <= start;
					s_enable <= '1';
					counter_next <= (others => '0');
				end if;
			when start => 
				--if counter register has reached for start condition
				if s_tick = '1' then
					if(counter_reg = to_unsigned(initial_offset, 4)) then
						state_next <= busy;
						counter_next <= (others => '0');
						bit_next <= (others => '0');
					else
						counter_next <= counter_reg + to_unsigned(1, 4);
					end if;
				end if;
			when busy => 
				--if counter register has reached maximum
				if s_tick = '1' then
					if counter_reg = to_unsigned(bit_width, 4) then
						--Check if we've reached
						counter_next <= (others => '0');
						data_next <= rx & data_reg(7 downto 1);
						if bit_reg = to_unsigned(7, 3) then
							state_next <= stop;
							bit_next <= (others => '0');
						else 
							bit_next <= bit_reg + to_unsigned(1,3);
						end if;
					else 
						counter_next <= counter_reg + to_unsigned(1,4);
					end if;
				end if;
			when stop =>
				--stop condition 
				if s_tick = '1' then
					if counter_reg = to_unsigned(stop_width-1, 4) then
						output_valid <= '1';
						counter_next <= (others => '0');
					else 
						counter_next <= counter_reg + to_unsigned(1, 4);
					end if;
				end if;
		end case;
	end process;
	data_out <= data_reg;
end arch;
