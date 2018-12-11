library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Camera_Init_Verification is
	port(
		clk, rst: in std_logic;
		
		sda : inout std_logic; --serial data output of i2c bus
		scl : inout std_logic --serial clock output of i2c bus
	);
end Camera_Init_Verification;


architecture arch of Camera_Init_Verification is
	type state_type is (idle, send, complete);
	signal state_reg: state_type;
	signal state_next: state_type;
	
	
	signal start: std_logic;
	signal done: std_logic;
	COMPONENT Camera_Init
		port(
			clk, rst: in std_logic;
			start: in std_logic;
			done: out std_logic;
			
			sda : inout std_logic; --serial data output of i2c bus
			scl : inout std_logic --serial clock output of i2c bus
		);
	end COMPONENT;
begin

	Camera_inst: Camera_init port map(clk => clk, rst => not rst, start=>start, done=>done, sda=>sda, scl =>scl);
	
	process(clk, rst)
	begin
		if rst = '0' then 
			state_reg <= idle;
		elsif rising_edge(clk) then
			state_reg <= state_next;
		end if;
	end process;
	
	process(state_reg, done)
	begin
		state_next <= state_reg;
		start <= '0';
		case state_reg is
			when idle =>
				start <= '1';
				state_next <= send;
			when send =>
				if done = '1' then
					state_next <= complete;
				end if;
			when others =>
		end case;
	end process;
end arch;