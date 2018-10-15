library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Sender is
	port(
		clk: in std_logic; 
		rst: in std_logic; --reset = active high;
		rx: in std_logic; --EXTREMELY IMPORTANT
		
		rx_ready: out std_logic;
		data_out: out std_logic_vector(7 downto 0);
		output_valid: out std_logic
	);
end UART_Sender;

architecture arch of UART_Sender is 
	COMPONENT UART_Sender_logic 
		
	end COMPONENT;
begin

end arch;