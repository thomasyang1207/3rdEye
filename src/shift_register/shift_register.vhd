library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register is
	generic(
		bit_width : integer := 8
	);
	port(
		data_in : in std_logic_vector(7 downto 0); 
		clk: in std_logic;
		reset: in std_logic;
		rd: in std_logic;
		s : out std_logic;
		done : out std_logic
	);
end shift_register;

architecture arch of shift_register is
	COMPONENT SplitClock
		port(
			clk : in std_logic; 
			rst : in std_logic;
			splitClk: out std_logic
		);
	end COMPONENT;
	
	signal actualClock : std_logic; 
	
	-- Control states;
	type control_state is (idle, busy); 
	signal state_reg : control_state := idle;
	signal state_next: control_state;
	
	signal data_reg: std_logic_vector(7 downto 0);
	signal data_next: std_logic_vector(7 downto 0);
	
begin
	
	s <= s_reg;
	
	splitClock_inst : SplitClock port map(
		clk => clk,
		rst => reset,
		splitClk => actualclock
	);
	
	--read reset signal and actual clock signal; 
	
	update_state: process(actualClock, reset, state_next, s_next) 
	begin
		if(reset = '0') then
			state_reg <= idle;
			data_reg <= "00000000";
			s_reg <= '0';
		elsif(actualClock = '1')
			if(state_next = 
			s_reg <= data_reg(7); -- get most significant bit
			data_reg <= data_reg(6 downto 0) & '0'; 
		end if; 
	end process; 
	
	
	
	
	
end arch;