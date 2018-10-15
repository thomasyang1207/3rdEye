library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Receiver is
	port(
		clk: in std_logic; 
		rst: in std_logic;
		rx: in std_logic;
		
		rx_ready: out std_logic;
		data_out: out std_logic_vector(7 downto 0);
		output_valid: out std_logic
	);
end UART_Receiver;

architecture arch of UART_Receiver is 
	COMPONENT UART_Receiver_logic 
		port(
			clk: in std_logic;
			rst: in std_logic;
			s_tick: in std_logic;
			rx: in std_logic;
		
			s_enable: out std_logic;
			rx_ready: out std_logic;
			data_out: out std_logic_vector(7 downto 0);
			output_valid: out std_logic
		);
	end COMPONENT;
	
	COMPONENT Baud_rate_generator
		port(
			clk: in std_logic;
			enable: in std_logic; 
			s_tick: out std_logic
		);
	end COMPONENT;

	signal s_tick_internal: std_logic; 
	signal s_enable_internal: std_logic;
begin
	
	UART_Receiver_logic_inst: UART_Receiver_logic port map(
		clk => clk,
		rst => rst,
		s_tick => s_tick_internal,
		rx => rx,
		
		s_enable => s_enable_internal,
		rx_ready => rx_ready,
		data_out => data_out,
		output_valid => output_valid
	);
	
	Baud_rate_generator_inst: Baud_rate_generator port map(
		clk => clk,
		enable => s_enable_internal,
		s_tick => s_tick_internal
	);
	
	
	
	
end arch;