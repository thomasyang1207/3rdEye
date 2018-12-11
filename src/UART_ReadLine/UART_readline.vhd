library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


entity UART_readline is
	port(
		clk: in std_logic;
		rst: in std_logic;
		rx: in std_logic;	
		command_complete: in std_logic; --from wifi to UART. Refer to the manual for more details. 
		
		output_code: out unsigned(3 downto 0);
		output_valid: out std_logic
	);
end UART_readline;


architecture arch of UART_readline is
	COMPONENT UART_Receiver
	port(
		clk: in std_logic;
		rst: in std_logic;
		rx: in std_logic;
		
		rx_ready: out std_logic;
		data_out: out std_logic_vector(7 downto 0);
		output_valid: out std_logic
	);
	end COMPONENT;
	
	COMPONENT FIFO_Buffer
	port(
		clk: in std_logic;
		rst: in std_logic;
		
		rd: in std_logic; --signal that the current value in data_out has been read.
		wr: in std_logic; --signal that current value in data_in is valid, and should be written to the buffer.
		clear_buf: in std_logic;
		
		buffer_empty: out std_logic;
		buffer_full: out std_logic;
		data_in: in unsigned(7 downto 0);
		data_out: out unsigned(7 downto 0)
	);
	end COMPONENT;
	
	COMPONENT Command_interpreter
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
	end COMPONENT;
	
	--Receiving side; from the UART port to the buffer...?
	--straight wires;
	signal rx_ready_in: std_logic;
	signal data_from_rx: std_logic_vector(7 downto 0);
	signal output_valid_in: std_logic;
	signal buffer_full_in: std_logic;
	
	
	--output side from FIFO Buffer;
	--wires
	signal fifo_data_out: unsigned(7 downto 0);
	signal buffer_empty_in: std_logic;
	signal get_next_byte: std_logic;
	
	--fifo control
	signal clear_fifo: std_logic;
	
begin
	UART_Receiver_inst: UART_Receiver port map(clk => clk, rst => rst, rx => rx, rx_ready => rx_ready_in, 
															data_out => data_from_rx, output_valid => output_valid_in);
	FIFO_buffer_inst: FIFO_Buffer port map(clk => clk, rst => rst, rd => get_next_byte, wr => output_valid_in, clear_buf => clear_fifo,
														buffer_empty => buffer_empty_in, buffer_full => buffer_full_in, data_in => unsigned(data_from_rx), data_out => fifo_data_out);
	
	Command_interpreter_inst: Command_interpreter port map(clk => clk, rst => rst, command_complete => command_complete, 
																			 data_in => fifo_data_out, buffer_empty => buffer_empty_in, buffer_full => buffer_full_in,
																			 clear_buffer => clear_fifo, get_next_byte => get_next_byte, output_code =>output_code, output_valid => output_valid);
														
	
end arch;