library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Sender_logic is
	generic(
		initial_offset: integer := 15;
		bit_width: integer := 15;
		stop_width: integer := 16
	);
	port(
		clk: in std_logic; 
		rst: in std_logic; --reset = active high;
		data_in: in std_logic_vector(7 downto 0);
		tx_start: in std_logic;
		s_tick: in std_logic;
		
		s_enable: out std_logic;
		tx: out std_logic; --EXTREMELY IMPORTANT
		tx_ready: out std_logic
	);
end UART_Sender_logic; 

architecture arch of UART_Sender_logic is
	type TX_state is (idle, start, data, stop);
	signal state_reg: TX_state := idle;
	signal state_next: TX_state;
	signal s_reg: unsigned(3 downto 0) := "0000";
	signal s_next: unsigned(3 downto 0);--signal
	signal N_reg: unsigned(2 downto 0) := "000";
	signal N_next: unsigned(2 downto 0); --signal
	signal data_reg: std_logic_vector(7 downto 0) := "11111111"; 
	signal data_next: std_logic_vector(7 downto 0); --signal
	
	signal tx_reg: std_logic := '1';
	signal tx_next: std_logic;
begin
	update_state: process(clk, rst)
	begin
		if rst = '1' then
			state_reg <= idle;
			s_reg <= "0000";
			N_reg <= "000";
			data_reg <= "11111111";
			tx_reg <= '1';
		elsif(rising_edge(clk)) then
			state_reg <= state_next;
			s_reg <= s_next;
			N_reg <= N_next;
			data_reg <= data_next;
			tx_reg <= tx_next;
		end if;
	end process;
	
	
	next_state: process(state_reg, s_reg, N_Reg, data_reg)
	begin
		state_next <= state_reg;
		s_next <= s_reg;
		N_next <= N_reg; 
		data_next <= data_reg;
		tx_next <= '1';
		s_enable <= '1';
		tx_ready <= '0';
		case state_reg is
			when idle =>
				tx_ready <= '1';
				tx_next <= '1';
				s_enable <= '0';
				if(tx_start = '1') then
					--begin;
					s_next <= "0000";
					data_next <= data_in;
					state_next <= start;
					s_enable <= '1';
				end if;
			when start =>
				tx_next <= '0'; --might consider setting this inside the transition from idle to start
				--check ticks
				if s_tick = '1' then
					if s_reg = to_unsigned(15, 4) then
						s_next <= "0000";
						N_next <= "000"; --set the bit counter to 0.
						state_next <= data;
					else
						s_next <= s_reg + to_unsigned(1,4);
					end if;
				end if;
			when data =>
				tx_next <= data_reg(0);
				if s_tick = '1' then
					if s_reg = to_unsigned(15, 4) then
						s_next <= "0000";
						data_next <= '0' & data_reg(7 downto 1);
						if N_reg = to_unsigned(7, 4) then --increment bit count;
							state_next <= stop;
							N_next <= "000";
						else 
							N_next <= N_reg + to_unsigned(1, 3); 
						end if;
					else 
						s_next <= s_reg + to_unsigned(1,4);
					end if;
				end if;
			when stop =>
				tx_next <= '1';
				if s_tick = '1' then
					if s_reg = to_unsigned(15, 0) then 
						s_next <= "0000";
						state_next <= idle;
					else
						s_next <= s_reg + to_unsigned(1,4);
					end if;
				end if;
		end case;
	end process;
	
	tx <= tx_reg;
end arch;
