library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Sender is
	port(
		clk: in std_logic; 
		rst: in std_logic;
		tx_start: in std_logic;
		
		tx: out std_logic;
		tx_ready: out std_logic
	);
end UART_Sender;

architecture arch of UART_Sender is 
	COMPONENT UART_Sender_logic 
		port(
			clk: in std_logic; 
			rst: in std_logic;
			data_in: in std_logic_vector(7 downto 0);
			tx_start: in std_logic;
			s_tick: in std_logic;
			
			s_enable: out std_logic;
			tx: out std_logic;
			tx_ready: out std_logic
		);
	end COMPONENT;
	
	COMPONENT Baud_rate_generator
		port(
			clk: in std_logic;
			enable: in std_logic;
			s_tick: out std_logic
		);
	end COMPONENT;
	
	signal s_enable_internal: std_logic;
	signal s_tick_internal: std_logic;
	
	type debounce_state is (idle, pulse_up, pulse_down); 
	signal state_reg: debounce_state := idle;
	signal state_next: debounce_state;
	signal tx_start_reg: std_logic := '0';
	signal tx_start_next: std_logic;
	
	
	signal data_const: std_logic_vector(7 downto 0) := "01100001"; -- 'a'
begin
	uart_inst: UART_Sender_logic port map(
		clk => clk, 
		rst => not rst, 
		data_in => data_const, 
		tx_start => tx_start_reg, 
		s_tick => s_tick_internal, 
		s_enable => s_enable_internal,
		tx => tx, 
		tx_ready => tx_ready
	);
	
	BRG: Baud_rate_generator port map(
		clk => clk, 
		enable => s_enable_internal,
		s_tick => s_tick_internal
	);
	
	process(clk, rst, tx_start_reg)
	begin
		if rst = '0' then
			tx_start_reg <= '0';
			state_reg <= idle;
		elsif rising_edge(clk) then
			state_reg <= state_next;
			tx_start_reg <= tx_start_next;
		end if;
	end process;

	process(state_reg, tx_start)
	begin
		tx_start_next <= '0';
		state_next <= state_reg; 
		case state_reg is
			when idle =>
				if tx_start = '0' then
					tx_start_next <= '1';
					state_next <= pulse_up;
				end if;
			when pulse_up =>
				tx_start_next <= '0';
				state_next <= pulse_down;
			when pulse_down =>
				if tx_start = '1' then
					state_next <= idle;
				end if;
		end case;
	end process;
end arch;