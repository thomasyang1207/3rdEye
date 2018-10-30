library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_Test is
end I2C_Test;


architecture tb of I2C_Test is
	--Our DATA
	type sample is record
		addr : std_logic_vector(6 downto 0); 
		reg : std_logic_vector(7 downto 0);
		data : std_logic_vector(7 downto 0);
	end record;
	
	type outputSample is record
		a0: std_logic;
		a1: std_logic;
		a2: std_logic;
		a3: std_logic;
		a4: std_logic;
		a5: std_logic;
		a6: std_logic;
		rw0: std_logic;
		reg0: std_logic;
		reg1: std_logic;
		reg2: std_logic;
		reg3: std_logic;
		reg4: std_logic;
		reg5: std_logic;
		reg6: std_logic;
		reg7: std_logic;
		data0: std_logic;
		data1: std_logic;
		data2: std_logic;
		data3: std_logic;
		data4: std_logic;
		data5: std_logic;
		data6: std_logic;
		data7: std_logic;
	end record;
	
	type sample_array is array (natural range <>) of sample;
	type result_array is array (natural range <>) of outputSample;
	
	constant test_data: sample_array :=
	(
		("1001010", x"01", x"30"),
		("1001010", x"01", x"21")
	);
	
	constant test_expected: result_array :=
	(
		('1', '0', '0', '1', '0', '1', '0', '0', 
		 '0', '0', '0', '0', '0', '0', '0', '1',
		 '0', '0', '1', '1', '0', '0', '0', '0'),
		('1', '0', '0', '1', '0', '1', '0', '0', 
		 '0', '0', '0', '0', '0', '0', '0', '1',
		 '0', '0', '1', '0', '0', '0', '0', '1')
	);
	
	
	--Sample response
	
	--COMPONENTS
	signal clk, rst, ena, rw, write_one: std_logic;
	signal slave_addr: std_logic_vector(6 downto 0);
	signal reg_wr, data_wr, data_rd: std_logic_vector(7 downto 0);
	signal output_valid, ready, ack_error: std_logic;
	
	signal sda, scl: std_logic; --tristate signals...
	
	--test signals; counters;
	signal tick_count: integer := 0;
	signal scl_old: std_logic := '1'; 
begin

	CUT: entity work.I2C port map(clk, 
		rst, 
		ena,
		rw, 
		write_one, 
		slave_addr, 
		reg_wr, 
		data_wr, 
		data_rd, 
		output_valid,
		ready, 
		ack_error,
		sda,
		scl); 

	process
	begin
		--starting signals; 
		clk <= '0';
		rst <= '0'; 
		ena <= '0';
		rw <= '0';
		write_one <= '0';
		slave_addr <= "0000000";
		reg_wr <= "00000000";
		data_wr <= "00000000";
		sda <= 'Z';
		scl <= 'Z';
		-- this is about to be the messiest testbench y'all ever seen.
		for i in test_data'range loop
			-- for one single set of test data: 
			
			-- Test Reset
			rst <= '1';
			wait for 5 ns;
			assert ready = '1'
				report "reset doesn't set state back to idle"
				severity error;
			assert ack_error = '0'
				report "reset doesn't set state back to idle"
				severity error;
			assert data_rd = "00000000"
				report "reset doesn't set state back to idle"
				severity error;
			
			wait for 5 ns;
			rst <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
			clk <= '0';
			
			ena <= '0';
			--Test Idle state with no enable;
			for j in 0 to 7 loop
				wait for 5 ns;
				clk <= '1';
				assert ready = '1'
					report "reset doesn't set state back to idle"
					severity error;
				assert ack_error = '0'
					report "reset doesn't set state back to idle"
					severity error;
				wait for 5 ns;
				clk <= '0';
			end loop;
			
			--Test one write iteration... DIFFICULT!
			ena <= '1';
			slave_addr <= test_data(i).addr;
			reg_wr <= test_data(i).reg;
			data_wr <= test_data(i).data;
			write_one <= '0';
			rw <= '0';
			
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns; 
			clk <= '0';
			wait for 5 ns;
			ena <= '0';
			while ready = '0' loop
				clk <= '1';
				--check values; maybe do a count too; 
				if scl = '1' and scl_old = '0' then
					case tick_count is
						when 0 =>
							assert sda = test_expected(i).a0
								report "address bit 0 is wrong"
								severity error;
						when 1 =>
							assert sda = test_expected(i).a1
								report "address bit 1 is wrong"
								severity error;
						when 2 =>
							assert sda = test_expected(i).a2
								report "address bit 2 is wrong"
								severity error;
						when 3 =>
							assert sda = test_expected(i).a3
								report "address bit 3 is wrong"
								severity error;
						when 4 =>
							assert sda = test_expected(i).a4
								report "address bit 4 is wrong"
								severity error;
						when 5 =>
							assert sda = test_expected(i).a5
								report "address bit 5 is wrong"
								severity error;
						when 6 =>
							assert sda = test_expected(i).a6
								report "address bit 6 is wrong"
								severity error;
						when 7 =>
							assert sda = test_expected(i).rw0
								report "rw bit is wrong"
								severity error;
						when 8 =>
							sda <= '0';
						when 9 =>
						
						when 10 =>
						when 11 =>
						when 12 =>
						when 13 =>
						when 14 =>
						when 15 =>
						when 16 =>
						when 17 =>
							sda <= '0';
						when 18 =>
						when 19 =>
						when 20 =>
						when 21 =>
						when 22 =>
						when 23 =>
						when others=>
					end case;
					tick_count <= tick_count + 1;
				end if;
				if scl = '0' and scl_old = '1' then
					sda <= 'Z';
				end if;
				scl_old <= scl;
				wait for 5 ns;
				clk <= '0';
				--update values;
				wait for 5 ns;
			end loop;
			
			
		end loop;
		
		wait; 
	end process;

end tb;