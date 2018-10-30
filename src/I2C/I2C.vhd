library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity I2C is
	generic(
		address_Width: integer := 7;
		data_width: integer := 7
	);
	port(
		clk : in std_logic; --system clock
		rst : in std_logic; --reset. Active HIGH reset. 
		ena : in std_logic; --enable => assert 1 when the data is ready. Don't assert if you don't want the system to leave idle mode.
		
		rw : in std_logic; --0 is write; 1 is read. good to use something like addr & rw
		write_one: in std_logic; --1 to write only the register, 0 to write both register and data. 
		
		slave_addr: in std_logic_vector(6 downto 0); --7-bit address, for our application, it will be 0x30
		reg_wr: in std_logic_vector(7 downto 0); 
		data_wr : in std_logic_vector(7 downto 0); --data to write to slave;
		
		data_rd : out STD_LOGIC_VECTOR(7 downto 0); --data read from slave
		
		output_valid : out std_logic; --single pulse indicating that the data_rd is valid
		ready: out std_logic; --signal indicating that the device is ready. 
		ack_error : out std_logic; --flag if improper acknowledge from slave; i.e. if slave was reset, etc.
		
		sda : inout std_logic; --serial data output of i2c bus
		scl : inout std_logic --serial clock output of i2c bus
		);
end I2C;


architecture arch of I2C is
	type i2cState is (idle, start, addr, addr_ack, wr1, wr2, rd, rd_ack, wr1_ack, wr2_ack, stop);
	-- idle state is the default state; nothing occurs
	-- start state - sda is held down for AT LEAST one clk cycle. 
	-- addr state - "transmission behavior" - will send the address and the rw bit. A lot of multiplexors in action here! 
	-- addr_ack - after the 8th bit is transmitted, as soon as scl goes low again, relinquish control (set to 'z') of sda line
	-- wr1 state - if desired data is "write", write the register
	-- wr2 state - write the data TO the register. Cannot have a break, or else the camera will think that you are supplying a new register.
	-- wr_ack - ack for accepted write; also during read state, tells the interface if there is remaining data to be read... 
	-- stop - send stop signal
	
	signal state_reg: i2cState := idle;
	signal state_next: i2cState;
	
	signal sda_reg: std_logic := 'Z';
	signal scl_reg: std_logic := 'Z';
	signal sda_next, scl_next: std_logic; -- do we really want this? or do we want to just write out. 
	
	signal tick_reg: integer := 0; -- counts how many i2c quarter ticks have elapsed.
	signal tick_next: integer;
	
	signal bit_count_reg: integer := 0; --counter for addresses
	signal bit_count_next: integer; 
	
	signal addr_reg: std_logic_vector(7 downto 0) := "00000000";
	signal addr_next: std_logic_vector(7 downto 0);
	
	signal data_reg: std_logic_vector(7 downto 0) := "00000000";
	signal data_next: std_logic_vector(7 downto 0); 
	
	signal out_reg: std_logic_vector(7 downto 0) := "00000000"; 
	signal out_next: std_logic_vector(7 downto 0);
	
	signal s_enable: std_logic; -- internal representation 
	signal s_tick: std_logic;
	
	signal doneRead_Reg: std_logic := '0';
	signal doneRead_next: std_logic;
	
	signal noAck_reg: std_logic := '0';
	signal noAck_next: std_logic;
	
	COMPONENT I2C_Clk_gen
		port(
			clk: in std_logic;
			enable: in std_logic; -- active high
			i2c_tick: out std_logic
		);
	end COMPONENT;
	
	
begin
	I2C_Clk_gen_inst: I2C_Clk_gen port map(clk => clk, enable => s_enable, i2c_tick => s_tick);

	update_reg: process(clk, rst) 
	begin
		if rst = '1' then 
			state_reg <= idle; 
			sda_reg <= 'Z';
			scl_reg <= 'Z';
			tick_reg <= 0;
			bit_count_Reg <= 0;
			addr_reg <= "00000000";
			data_reg <= "00000000";
			out_reg <= "00000000";
			doneRead_reg <= '0';
			noAck_reg <= '0';
		elsif rising_edge(clk) then
			state_reg <= state_next; 
			sda_reg <= sda_next;
			scl_reg <= scl_next;
			tick_reg <= tick_next;
			bit_count_Reg <= bit_count_next;
			addr_reg <= addr_next;
			data_reg <= data_next;
			out_reg <= out_next;
			doneRead_reg <= doneRead_next;
			noAck_reg <= noAck_next;
		end if;
	end process;
	
	

	get_next: process(state_reg, tick_reg, bit_count_Reg, data_reg, addr_reg, out_reg, rw, write_one, slave_addr, reg_wr, data_wr, noAck_reg, s_tick, scl_reg, sda_reg, doneRead_reg, ena, sda)
	begin
		--for each case...
		s_enable <= '1'; 
		state_next <= state_reg; 
		tick_next <= tick_reg; 
		bit_count_next <= bit_count_reg; 
		data_next <= data_reg; 
		addr_next <= addr_reg; 
		out_next <= out_reg;
		scl_next <= scl_reg;
		sda_next <= sda_reg;
		doneRead_next <= doneRead_reg;
		noAck_next <= noAck_reg;
		ack_error <= '0';
		output_valid <= '0'; 
		ready <= '0';
		case state_reg is
---------------------------------------------------------------------------------
			when idle => 
				ready <= '1';
				s_enable <= '0';
				if ena = '1' then --the addr, data, and 
					ready <= '0';
					state_next <= start;
					addr_next <= slave_addr & rw;
					tick_next <= 0; 
					sda_next <= '0'; 
					s_enable <= '1';
				end if;
---------------------------------------------------------------------------------
			when start => -- two ticks
				ack_error <= '0';
				s_enable <= '1';
				if s_tick = '1' then
					tick_next <= tick_reg + 1;
					if tick_reg = 0 then
						scl_next <= '0';
					elsif tick_reg = 1 then
						state_next <= addr;
						sda_next <= addr_reg(7);
						addr_next <= addr_reg(6 downto 0) & '0';
						tick_next <= 0;
					end if;
				end if;
---------------------------------------------------------------------------------
			when addr =>
				if s_tick = '1' then
					tick_next <= tick_reg + 1;
					if tick_reg = 0 then
						scl_next <= '1'; -- clock high
					elsif tick_reg = 2 then
						scl_next <= '0'; -- clock low
					elsif tick_reg = 3 then
						tick_next <= 0; --time to reset the tick counter
						if bit_count_reg = address_width then 
							bit_count_next <= 0;
							state_next <= addr_ack; 
							sda_next <= 'Z';
						else
							bit_count_next <= bit_count_reg + 1;
							sda_next <= addr_reg(7);
							addr_next <= addr_reg(6 downto 0) & '0';
						end if;
					end if;
				end if;
---------------------------------------------------------------------------------
			when addr_ack => 
				if s_tick = '1' then
					--no matter what, do not TOUCH sda here
					if tick_reg = 0 then 
						tick_next <= tick_reg + 1;
						scl_next <= '1';
					elsif tick_reg = 1 then
						tick_next <= tick_reg + 1;
						--READ THE ACK from the camera
						if sda /= '0' then
							noAck_next <= '1';
						else
							--prepare the data
							data_next <= reg_wr; --register address;
						end if;
					elsif tick_reg = 2 then
						tick_next <= tick_reg + 1;
						scl_next <= '0';
					else
						bit_count_next <= 0;
						if noAck_reg = '1' then
							state_next <= stop;
						else 
							if rw = '0' then
								state_next <= wr1;
								bit_count_next <= 0;
								sda_next <= data_reg(7);
								data_next <= data_reg(6 downto 0) & '0';
							else 
								state_next <= rd; 
								sda_next <= 'Z';
							end if;
						end if;
						tick_next <= 0;
					end if;
				end if;
---------------------------------------------------------------------------------
			when wr1 =>
				if s_tick = '1' then
					tick_next <= tick_reg + 1;
					if tick_reg = 0 then
						scl_next <= '1'; -- clock high
					elsif tick_reg = 2 then
						scl_next <= '0'; -- clock low
					elsif tick_reg = 3 then
						tick_next <= 0; --time to reset the tick counter
						if bit_count_reg = data_width then 
							bit_count_next <= 0;
							state_next <= wr1_ack; 
							sda_next <= 'Z';
						else
							bit_count_next <= bit_count_reg + 1;
							sda_next <= data_reg(7);
							data_next <= data_reg(6 downto 0) & '0';
						end if;
					end if;
				end if;
---------------------------------------------------------------------------------
			when wr2 =>
				if s_tick = '1' then
					tick_next <= tick_reg + 1;
					if tick_reg = 0 then
						scl_next <= '1'; -- clock high
					elsif tick_reg = 2 then
						scl_next <= '0'; -- clock low
					elsif tick_reg = 3 then
						tick_next <= 0; --time to reset the tick counter
						if bit_count_reg = data_width then 
							bit_count_next <= 0;
							state_next <= wr2_ack; 
							sda_next <= 'Z';
						else
							bit_count_next <= bit_count_reg + 1;
							sda_next <= data_reg(7);
							data_next <= data_reg(6 downto 0) & '0';
						end if;
					end if;
				end if;
---------------------------------------------------------------------------------
			when rd =>
				sda_next <= 'Z';
				if s_tick = '1' then
					tick_next <= tick_reg + 1;
					case tick_reg is
						when 0 =>
							scl_next <= '1';
						when 1 =>
							--shift data into the register
							out_next <= out_reg(6 downto 0) & sda;
							bit_count_next <= bit_count_reg + 1; 
						when 2 => 
							scl_next <= '0'; -- scl low
						when 3 =>
							tick_next <= 0; 
							if bit_count_reg = data_width + 1 then
								bit_count_next <= 0;
								state_next <= rd_ack;
							end if;
						when others =>
					end case;
				end if;
---------------------------------------------------------------------------------
			when rd_ack =>
				if s_tick = '1' then
					case tick_reg is
						when 0 => 
							tick_next <= tick_reg + 1; 
							scl_next <= '1';
						when 1 =>
							tick_next <= tick_reg + 1;
							--PURPOSELY look for ACK in the Camera.
							if sda /= '0' then
								doneRead_next<= '1';
							end if;
						when 2 =>
							tick_next <= tick_reg + 1;
							scl_next <= '0';
						when 3 =>
							if doneRead_reg <= '1' then
								state_next <= stop;
							else
								state_next <= rd;
							end if;
						when others =>
					end case;
				end if;
---------------------------------------------------------------------------------
			when wr1_ack =>
				if s_tick = '1' then
					--no matter what, do not TOUCH sda here
					if tick_reg = 0 then 
						tick_next <= tick_reg + 1;
						scl_next <= '1';
					elsif tick_reg = 1 then
						tick_next <= tick_reg + 1;
						--READ THE ACK from the camera
						if sda /= '0' then
							noAck_next <= '1';
						else
							output_valid <= '1';
							--prepare the data
							data_next <= data_wr; --register address; 
						end if;
					elsif tick_reg = 2 then
						tick_next <= tick_reg + 1;
						scl_next <= '0';
					else
						if noAck_reg = '1' then
							state_next <= stop;
						else 
							if write_one = '1' then
								state_next <= stop;
							else
								state_next <= wr2; 
								sda_next <= data_reg(7); 
								data_next <= data_reg(6 downto 0) & '0';
							end if;
						end if;
						tick_next <= 0;
					end if;
				end if;
---------------------------------------------------------------------------------
			when wr2_ack =>
				if s_tick = '1' then
					--no matter what, do not TOUCH sda here
					if tick_reg = 0 then 
						tick_next <= tick_reg + 1;
						scl_next <= '1';
					elsif tick_reg = 1 then
						tick_next <= tick_reg + 1;
						--READ THE ACK from the camera
						if sda /= '0' then
							noAck_next <= '1';
						else
							--prepare the data
							data_next <= reg_wr; --register address; 
						end if;
					elsif tick_reg = 2 then
						tick_next <= tick_reg + 1;
						scl_next <= '0';
					else
						if noAck_reg = '1' then
							state_next <= stop;
							sda_next <= '0';
						else 
							state_next <= wr1;
							sda_next <= data_reg(7); 
							data_next <= data_reg(6 downto 0) & '0';
						end if;
						tick_next <= 0;
					end if;
				end if;
---------------------------------------------------------------------------------
			when stop =>
				if noAck_reg = '1' then
					ack_error <= '1';
				end if;
				if s_tick = '1' then
					tick_next <= tick_reg + 1;
					case tick_reg is
						when 0 =>
							sda_next <= '0';
							scl_next <= '1';
						when 1 =>
							sda_next <= '1';
							scl_next <= '1';
							state_next <= idle;
							--clear all registers... 
							addr_next <= "00000000";
							data_next <= "00000000";
							out_next <= "00000000";
							tick_next <= 0;
							bit_count_next <= 0; 
						when others =>
					end case;
				end if;
		end case;
	
	end process;
	
	sda <= sda_reg;
	scl <= scl_reg;
	data_rd <= out_reg;
	
end arch;