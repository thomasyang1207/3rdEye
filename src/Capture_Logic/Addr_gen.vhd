library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity Addr_gen is 
	port(
		clk: in std_logic; 
		rst: in std_logic;
		act: in std_logic; --single pulse high; when high, increment the address on the next high address
		restart: in std_logic; -- single pulse, set address to 0 when active; 
		
		addr: out unsigned(19 downto 0)
	);
end Addr_gen;

architecture arch of Addr_gen is
	signal addr_reg: unsigned(19 downto 0) := (others => '0');
	signal addr_next: unsigned(19 downto 0); 
begin
	addr <= addr_reg;

	update: process(clk, rst)
	begin
		if rst = '1' then
			addr_reg <= (others => '0');
		elsif rising_edge(clk) then
			addr_reg <= addr_next;
		end if;
	end process;
	
	get_next: process(act, restart, addr_reg)
	begin 
		addr_next <= addr_reg;
		if act = '1' then 
			addr_next <= addr_reg + to_unsigned(1, 20);
		end if;
		if restart = '1' then 
			addr_next <= (others => '0');
		end if;
	end process;
end arch;