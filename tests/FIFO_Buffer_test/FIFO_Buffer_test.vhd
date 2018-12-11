library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity FIFO_Buffer_test is
end entity;

architecture tb of FIFO_Buffer_test is
	signal clk: std_logic;
	signal rst: std_logic;
		
	signal rd: std_logic;
	signal wr: std_logic;
	signal clear_buf: std_logic;
	
	signal buffer_empty: std_logic;
	signal buffer_full: std_logic;
	signal data_in: unsigned(7 downto 0);
	signal data_out: unsigned(7 downto 0);
begin

	CUT: entity work.FIFO_Buffer port map(
		clk,
		rst,
		rd,
		wr,
		clear_buf,
		buffer_empty,
		buffer_full,
		data_in,
		data_out); 
	
	process
	begin
		clk <= '0';
		rst <= '1';
		rd <= '0';
		wr <= '0';
		clear_buf <= '0';
		data_in <= (others => '0');
		
		--test reset;
		rst <= '1';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		rst <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		--write 1 bytes
		wr <= '1';
		data_in <= x"01";
		wait for 5 ns;
		clk <= '1'; 
		wait for 5 ns;
		clk <= '0';
		data_in <= x"03";
		wr <= '1';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		
		
		--read 5 bytes;
		wr <= '0';
		rd <= '1';
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
		wait for 5 ns;
		
		
		wait;
	end process;

end tb;