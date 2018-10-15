library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--entity

entity Mod_Counter is 
	generic(
		maxNum : integer := 16
	); 
	
	port(
		clk      : in  std_logic;
		disp		: out	std_logic_vector(6 downto 0);
		reset		: in std_logic
	); 
end Mod_Counter; 


architecture arch of Mod_Counter is
	COMPONENT LED_converter 
		port(
		in1: in std_logic_vector(3 downto 0); 
		out1: out std_logic_vector(6 downto 0)
		);
	end COMPONENT;
	
	COMPONENT Mod_Counter_internal
		port(
		clk      : in  std_logic;
		data_out	: out	std_logic_vector(3 downto 0);
		rst		: in 	std_logic
		); 
	end COMPONENT;
	
	COMPONENT SplitClock
		port(
			clk : in std_logic; 
			rst : in std_logic;
			splitClk: out std_logic
		);
	end COMPONENT;
	
	signal counter_disp : std_logic_vector(3 downto 0);
	signal splitClkConnection: std_logic; 
	
	begin
	
	splitClock_inst: SplitClock port map(
		clk => clk,
		rst => reset,
		splitClk => splitClkConnection 
	);
	
	led_inst : LED_converter port map(
		in1 => counter_disp, 
		out1 => disp
	);
	
	mod_counter_inst : Mod_Counter_internal port map(
		clk => splitClkConnection,
		data_out => counter_disp,
		rst => reset
	);
	
end arch;
