library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_buffer is
	generic(
		W: integer := 8
	);
	port(
		clk, rst: in std_logic;
		
		rd,wr: in std_logic; --signal that the current value in data_out has been read.
		clear_buf: in std_logic;
		
		buffer_empty, buffer_full: out std_logic;
		
		data_in: in unsigned(7 downto 0);
		data_out: out unsigned(7 downto 0)
	);
end FIFO_buffer;

architecture arch of FIFO_buffer is
	type buf_type is array ((2**W)-1 downto 0) of std_logic_vector(7 downto 0);
	signal buf: buf_type := (others=>(others=>'0'));
	signal w_ptr_reg: unsigned(W downto 0) := (others => '0');
	signal w_ptr_next, w_ptr_succ: unsigned(W downto 0);
	signal r_ptr_reg: unsigned(W downto 0) := (others => '0');
	signal r_ptr_next, r_ptr_succ: unsigned(W downto 0);
	
	signal full_reg: std_logic := '0';
	signal empty_reg: std_logic := '1';
	signal full_next, empty_next: std_logic;
	
	signal wr_op: std_logic_vector(1 downto 0);
	signal wr_en: std_logic;
	
begin
	process(rst, clear_buf, clk)
	begin
		if rst='1' or clear_buf = '1' then
			buf <= (others=>(others=>'0'));
		elsif rising_edge(clk) then
			if wr_en = '1' then
				buf(to_integer(w_ptr_reg)) <= std_logic_vector(data_in);
			end if;
		end if;
	end process;
	data_out <= unsigned(buf(to_integer(r_ptr_reg)));
	wr_en <= wr and (not full_reg);
	
	wr_op <= wr & rd;
	process(clk, rst)
	begin
		if rst = '1' then
			w_ptr_reg <= (others => '0');
			r_ptr_reg <= (others => '0');
			full_reg <= '0';
			empty_reg <= '1';
		elsif rising_edge(clk) then
			w_ptr_reg <= w_ptr_next;
			r_ptr_reg <= r_ptr_next;
			full_reg <= full_next;
			empty_reg <= empty_next;
		end if;
	end process;
	
	w_ptr_succ <= w_ptr_reg + 1;
	r_ptr_succ <= r_ptr_reg + 1;
	
	process(w_ptr_reg, w_ptr_succ, r_ptr_reg, r_ptr_succ, wr_op, empty_reg, full_reg)
	begin
		w_ptr_next <= w_ptr_reg; 
		r_ptr_next <= r_ptr_reg;
		full_next <= full_reg; 
		empty_next <= empty_reg;
		case wr_op is
			when "00" =>
			when "01" =>
				if empty_reg /= '1' then
					r_ptr_next <= r_ptr_succ;
					full_next <= '0';
					if r_ptr_succ = w_ptr_reg then
						empty_next <= '1';
					end if;
				end if;
			when "10" =>
				if full_reg /= '1' then
					w_ptr_next <= w_ptr_succ;
					empty_next <= '0';
					if w_ptr_succ = r_ptr_reg then
						full_next <= '1';
					end if;
				end if;
			when others =>
				w_ptr_next <= w_ptr_succ;
				r_ptr_next <= r_ptr_succ;
		end case;
	end process;
	
	buffer_full <= full_reg; 
	buffer_empty <= empty_reg;
	
end arch;