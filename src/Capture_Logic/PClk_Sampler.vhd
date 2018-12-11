library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PClk_Sampler is
	port(clk: in std_logic;
		  ena: in std_logic; 
		  pclk: in std_logic;
		  pclk_tick: out std_logic
		  );
end PClk_Sampler; 

architecture arch of PClk_Sampler is
	signal pclk_reg: std_logic := '1';
	signal tick_reg: std_logic := '0';
	signal tick_next: std_logic;
begin
	pclk_tick <= tick_reg;
	
	update_next: process(clk, ena, tick_next, pclk)
	begin
		if ena = '0' then
			pclk_reg <= '1';
			tick_reg <= '0';
		elsif rising_edge(clk) then
			pclk_reg <= pclk;
			tick_reg <= tick_next;
		end if;
	end process;
	
	get_next: process(pclk, tick_reg, pclk_reg)
	begin
		tick_next <= '0';
		if pclk = '1' then
			if pclk_reg = '0' then
				tick_next <= '1';
			end if;
		end if;
	end process;

end arch;