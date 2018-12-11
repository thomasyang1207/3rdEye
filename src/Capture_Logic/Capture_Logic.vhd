library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity Capture_Logic is
	port(
		clk: in std_logic;
		rst: in std_logic;
		ena: in std_logic; --once again, want this to be a single pulse.
		
		href: in std_logic;
		vsync: in std_logic;
		pclk: in std_logic;
		
		data: in std_logic_vector(7 downto 0);
		
		pixel_valid: out std_logic; --high on single clock cycle
		data_out: out std_logic_vector(7 downto 0);
		
		capture_done: out std_logic;
		capture_length: out unsigned(19 downto 0)
	);
end Capture_Logic;


architecture arch of Capture_Logic is
	
	type state_type is (idle, wait1, capture, ffd9, done);
	--idle - rest mode; camera not actively trying to sample or track anything. 
	--wait1 - waiting for ffd8 to load in the FIFO buffer
	
	
	signal state_reg: state_type := idle;
	signal state_next: state_type;
	
	signal FIFO_reg: std_logic_vector(15 downto 0); -- continuously write into this; 
	signal FIFO_next: std_logic_vector(15 downto 0);
	
	signal output_valid_reg : std_logic := '0';
	signal output_valid_next : std_logic;

	signal addr_generated: unsigned(19 downto 0);
	
	signal s_enable: std_logic;
	signal p_tick: std_logic;
	
	signal get_new_addr: std_logic;
	signal set_addr_zero: std_logic;
	
	COMPONENT PClk_Sampler is
		port(
			clk: in std_logic;
			ena: in std_logic; 
			pclk: in std_logic;
			pclk_tick: out std_logic
		);
	end COMPONENT;
	
	COMPONENT Addr_gen is
		port(
			clk: in std_logic; 
			rst: in std_logic;
			act: in std_logic;
			restart: in std_logic;
			addr: out unsigned(19 downto 0)
		);
	end COMPONENT;

	
begin
	pixel_valid <= output_valid_reg;
	data_out <= FIFO_reg(15 downto 8);
	
	PClk_Sampler_inst: PClk_Sampler port map(clk => clk, ena => s_enable, pclk => pclk, pclk_tick => p_tick);
	Addr_gen_inst: Addr_gen port map(clk => clk, rst => rst, act => get_new_addr, restart => set_addr_zero, addr => addr_generated);
	
	clocked: process(clk, rst, ena)
	begin
		s_enable <= '1';
		if rst = '1' or ena = '0' then
			state_reg <= idle;
			s_enable <= '0'; 
			FIFO_reg <= (others => '0');
		elsif rising_edge(clk) then
			state_reg <= state_next;
			FIFO_reg <= FIFO_next;
			output_valid_reg <= output_valid_next;
		end if;
	end process;
	
	get_next: process(state_reg, FIFO_reg, output_valid_reg, p_tick, data, vsync, href, addr_generated)
	begin
		get_new_addr <= '0';
		set_addr_zero <= '0';
		state_next <= state_reg;
		FIFO_next <= FIFO_reg;
		output_valid_next <= '0';
		capture_done <= '0';
		capture_length <= (others => '0');
		case state_reg is
			when idle =>
				--wait for vsync, href, and pclk to go high.
				set_addr_zero <= '1';
				if p_tick = '1' then
					if vsync = '1' and href = '1' then
						state_next <= wait1; 
						FIFO_next <= FIFO_reg(7 downto 0) & data; -- read the data in, and shift bits over.
					end if;
				end if;
			when wait1 =>
				if p_tick = '1' then
					if vsync = '1' and href = '1' then
						if FIFO_reg = x"ffd8" then
							get_new_addr <= '1';
							state_next <= capture; 
							FIFO_next <= FIFO_reg(7 downto 0) & data; -- read the data in, and shift bits over.
						end if;
					end if;
				end if;
			when capture =>
				if p_tick = '1' then
					if vsync = '1' and href = '1' then
						--capture this bit, 
						get_new_addr <= '1';
						FIFO_next <= FIFO_reg(7 downto 0) & data;
						output_valid_next <= '1';
						if FIFO_reg = x"ffd9" then
							state_next <= ffd9;
						end if;
					else 
						--Reset all registers, etc; ran into a capture error... 
						FIFO_next <= (others => '0');
						state_next <= wait1;
						set_addr_zero <= '1';
					end if;
				end if;
			when ffd9 =>
				if p_tick = '1' then -- very important, because you want to give some time for the write to be done.
						get_new_addr <= '1';
						FIFO_next <= FIFO_reg(7 downto 0) & x"00";
						state_next <= done;
				end if;
			when done =>
				--prepare for stopping;
				capture_done <= '1';
				capture_length <= addr_generated;
				state_next <= idle;
		end case;
	end process;
	
end arch;