library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--"file" to store the register values and addresses that must be read;
--TODO 
entity cam_registers is 
	generic(
		num_registers : std_logic_vector(7 downto 0) := x"f9"
	); 
	
	port(
		clk      : in  STD_LOGIC;
		resend   : in  STD_LOGIC;
		advance  : in  STD_LOGIC;
		command  : out  std_logic_vector(15 downto 0);
		finished : out  STD_LOGIC
	); 
end cam_registers; 





architecture arch of cam_registers is
-- cam registers is the file entity to begin a sequence of reads to the 
signal address: std_logic_vector(7 downto 0) := (others => '0'); -- address on THIS file; 
signal sreg: std_logic_vector(15 downto 0); -- the output? -- writes to the command; 16 bits to be partially written across the I2C bus; 

begin

command <= sreg;
with sreg select finished  <= '1' when x"FFFF", '0' when others;

process(clk, resend, advance)
	begin
	
		-- process to read from the read-only file; 
		if rising_edge(clk) then
      
			if resend = '1' then 
          address <= (others => '0'); --resend = restart the register sending process; 
        elsif ( (advance = '1') and signed(address) < signed(num_registers) ) then
          address <= std_logic_vector(unsigned(address)+1);
        end if;

			case address is
				-- init packet: 
				when x"00" => sreg <= x"ff01"; 
				
			
			
				-- OV2640_JPEG_INIT; 
				when x"01" => sreg <= x"ff00";
				when x"02" => sreg <= x"2cff";
				when x"03" => sreg <= x"2edf";
				when x"04" => sreg <= x"ff01";
				when x"05" => sreg <= x"3c32";
				when x"06" => sreg <= x"1101";
				when x"07" => sreg <= x"0902";
				when x"08" => sreg <= x"0428";
				when x"09" => sreg <= x"13e5";
				when x"0a" => sreg <= x"1448";
				when x"0b" => sreg <= x"2c0c";
				when x"0c" => sreg <= x"3378";
				when x"0d" => sreg <= x"3a33";
				when x"0e" => sreg <= x"3bfB";
				when x"0f" => sreg <= x"3e00";
				when x"10" => sreg <= x"4311";
				when x"11" => sreg <= x"1610";
				when x"12" => sreg <= x"3992";
				when x"13" => sreg <= x"35da";
				when x"14" => sreg <= x"221a";
				when x"15" => sreg <= x"37c3";
				when x"16" => sreg <= x"2300";
				when x"17" => sreg <= x"34c0";
				when x"18" => sreg <= x"361a";
				when x"19" => sreg <= x"0688";
				when x"1a" => sreg <= x"07c0";
				when x"1b" => sreg <= x"0d87";
				when x"1c" => sreg <= x"0e41";
				when x"1d" => sreg <= x"4c00";
				when x"1e" => sreg <= x"4800";
				when x"1f" => sreg <= x"5B00";
				when x"20" => sreg <= x"4203";
				when x"21" => sreg <= x"4a81";
				when x"22" => sreg <= x"2199";
				when x"23" => sreg <= x"2440";
				when x"24" => sreg <= x"2538";
				when x"25" => sreg <= x"2682";
				when x"26" => sreg <= x"5c00";
				when x"27" => sreg <= x"6300";
				when x"28" => sreg <= x"6170";
				when x"29" => sreg <= x"6280";
				when x"2a" => sreg <= x"7c05";
				when x"2b" => sreg <= x"2080";
				when x"2c" => sreg <= x"2830";
				when x"2d" => sreg <= x"6c00";
				when x"2e" => sreg <= x"6d80";
				when x"2f" => sreg <= x"6e00";
				when x"30" => sreg <= x"7002";
				when x"31" => sreg <= x"7194";
				when x"32" => sreg <= x"73c1";
				when x"33" => sreg <= x"1240";
				when x"34" => sreg <= x"1711";
				when x"35" => sreg <= x"1843";
				when x"36" => sreg <= x"1900";
				when x"37" => sreg <= x"1a4b";
				when x"38" => sreg <= x"3209";
				when x"39" => sreg <= x"37c0";
				when x"3a" => sreg <= x"4f60";
				when x"3b" => sreg <= x"50a8";
				when x"3c" => sreg <= x"6d00";
				when x"3d" => sreg <= x"3d38";
				when x"3e" => sreg <= x"463f";
				when x"3f" => sreg <= x"4f60";
				when x"40" => sreg <= x"0c3c";
				when x"41" => sreg <= x"ff00";
				when x"42" => sreg <= x"e57f";
				when x"43" => sreg <= x"f9c0";
				when x"44" => sreg <= x"4124";
				when x"45" => sreg <= x"e014";
				when x"46" => sreg <= x"76ff";
				when x"47" => sreg <= x"33a0";
				when x"48" => sreg <= x"4220";
				when x"49" => sreg <= x"4318";
				when x"4a" => sreg <= x"4c00";
				when x"4b" => sreg <= x"87d5";
				when x"4c" => sreg <= x"883f";
				when x"4d" => sreg <= x"d703";
				when x"4e" => sreg <= x"d910";
				when x"4f" => sreg <= x"d382";
				when x"50" => sreg <= x"c808";
				when x"51" => sreg <= x"c980";
				when x"52" => sreg <= x"7c00";
				when x"53" => sreg <= x"7d00";
				when x"54" => sreg <= x"7c03";
				when x"55" => sreg <= x"7d48";
				when x"56" => sreg <= x"7d48";
				when x"57" => sreg <= x"7c08";
				when x"58" => sreg <= x"7d20";
				when x"59" => sreg <= x"7d10";
				when x"5a" => sreg <= x"7d0e";
				when x"5b" => sreg <= x"9000";
				when x"5c" => sreg <= x"910e";
				when x"5d" => sreg <= x"911a";
				when x"5e" => sreg <= x"9131";
				when x"5f" => sreg <= x"915a";
				when x"60" => sreg <= x"9169";
				when x"61" => sreg <= x"9175";
				when x"62" => sreg <= x"917e";
				when x"63" => sreg <= x"9188";
				when x"64" => sreg <= x"918f";
				when x"65" => sreg <= x"9196";
				when x"66" => sreg <= x"91a3";
				when x"67" => sreg <= x"91af";
				when x"68" => sreg <= x"91c4";
				when x"69" => sreg <= x"91d7";
				when x"6a" => sreg <= x"91e8";
				when x"6b" => sreg <= x"9120";
				when x"6c" => sreg <= x"9200";
				when x"6d" => sreg <= x"9306";
				when x"6e" => sreg <= x"93e3";
				when x"6f" => sreg <= x"9305";
				when x"70" => sreg <= x"9305";
				when x"71" => sreg <= x"9300";
				when x"72" => sreg <= x"9304";
				when x"73" => sreg <= x"9300";
				when x"74" => sreg <= x"9300";
				when x"75" => sreg <= x"9300";
				when x"76" => sreg <= x"9300";
				when x"77" => sreg <= x"9300";
				when x"78" => sreg <= x"9300";
				when x"79" => sreg <= x"9300";
				when x"7a" => sreg <= x"9600";
				when x"7b" => sreg <= x"9708";
				when x"7c" => sreg <= x"9719";
				when x"7d" => sreg <= x"9702";
				when x"7e" => sreg <= x"970c";
				when x"7f" => sreg <= x"9724";
				when x"80" => sreg <= x"9730";
				when x"81" => sreg <= x"9728";
				when x"82" => sreg <= x"9726";
				when x"83" => sreg <= x"9702";
				when x"84" => sreg <= x"9798";
				when x"85" => sreg <= x"9780";
				when x"86" => sreg <= x"9700";
				when x"87" => sreg <= x"9700";
				when x"88" => sreg <= x"c3ed";
				when x"89" => sreg <= x"a400";
				when x"8a" => sreg <= x"a800";
				when x"8b" => sreg <= x"c511";
				when x"8c" => sreg <= x"c651";
				when x"8d" => sreg <= x"bf80";
				when x"8e" => sreg <= x"c710";
				when x"90" => sreg <= x"b666";
				when x"91" => sreg <= x"b8A5";
				when x"92" => sreg <= x"b764";
				when x"93" => sreg <= x"b97C";
				when x"94" => sreg <= x"b3af";
				when x"95" => sreg <= x"b497";
				when x"96" => sreg <= x"b5FF";
				when x"97" => sreg <= x"b0C5";
				when x"98" => sreg <= x"b194";
				when x"99" => sreg <= x"b20f";
				when x"9a" => sreg <= x"c45c";
				when x"9b" => sreg <= x"c064";
				when x"9c" => sreg <= x"c14B";
				when x"9d" => sreg <= x"8c00";
				when x"9e" => sreg <= x"863D";
				when x"9f" => sreg <= x"5000";
				when x"a0" => sreg <= x"51C8";
				when x"a1" => sreg <= x"5296";
				when x"a2" => sreg <= x"5300";
				when x"a3" => sreg <= x"5400";
				when x"a4" => sreg <= x"5500";
				when x"a5" => sreg <= x"5aC8";
				when x"a6" => sreg <= x"5b96";
				when x"a7" => sreg <= x"5c00";
				when x"a8" => sreg <= x"d300";
				when x"a9" => sreg <= x"c3ed";
				when x"aa" => sreg <= x"7f00";
				when x"ab" => sreg <= x"da00";
				when x"ac" => sreg <= x"e51f";
				when x"ad" => sreg <= x"e167";
				when x"ae" => sreg <= x"e000";
				when x"af" => sreg <= x"dd7f";
				when x"b0" => sreg <= x"0500";
				when x"b1" => sreg <= x"1240";
				when x"b2" => sreg <= x"d304";
				when x"b3" => sreg <= x"c016";
				when x"b4" => sreg <= x"C112";
				when x"b5" => sreg <= x"8c00";
				when x"b6" => sreg <= x"863d";
				when x"b7" => sreg <= x"5000";
				when x"b8" => sreg <= x"512C";
				when x"b9" => sreg <= x"5224";
				when x"ba" => sreg <= x"5300";
				when x"bb" => sreg <= x"5400";
				when x"bc" => sreg <= x"5500";
				when x"bd" => sreg <= x"5A2c";
				when x"be" => sreg <= x"5b24";
				when x"bf" => sreg <= x"5c00";
				
				--YUV_422
				when x"c0" => sreg <= x"FF00";
				when x"c1" => sreg <= x"0500";
				when x"c2" => sreg <= x"DA10";
				when x"c3" => sreg <= x"D703";
				when x"c4" => sreg <= x"DF00";
				when x"c5" => sreg <= x"3380";
				when x"c6" => sreg <= x"3C40";
				when x"c7" => sreg <= x"e177";
				when x"c8" => sreg <= x"0000";
				
				--JPEG 
				when x"c9" => sreg <= x"e014";
				when x"ca" => sreg <= x"e177";
				when x"cb" => sreg <= x"e51f";
				when x"cc" => sreg <= x"d703";
				when x"cd" => sreg <= x"da10";
				when x"ce" => sreg <= x"e000";
				when x"cf" => sreg <= x"FF01";
				when x"d0" => sreg <= x"0408";
				
				
				--JPEG 640x480
				when x"d1" => sreg <= x"ff01";
				when x"d2" => sreg <= x"1101";
				when x"d3" => sreg <= x"1200";
				when x"d4" => sreg <= x"1711";
				when x"d5" => sreg <= x"1875";
				when x"d6" => sreg <= x"3236";
				when x"d7" => sreg <= x"1901";
				when x"d8" => sreg <= x"1a97";
				when x"d9" => sreg <= x"030f";
				when x"da" => sreg <= x"3740";
				when x"db" => sreg <= x"4fbb";
				when x"dc" => sreg <= x"509c";
				when x"dd" => sreg <= x"5a57";
				when x"de" => sreg <= x"6d80";
				when x"df" => sreg <= x"3d34";
				when x"e0" => sreg <= x"3902";
				when x"e1" => sreg <= x"3588";
				when x"e2" => sreg <= x"220a";
				when x"e3" => sreg <= x"3740";
				when x"e4" => sreg <= x"34a0";
				when x"e5" => sreg <= x"0602";
				when x"e6" => sreg <= x"0db7";
				when x"e7" => sreg <= x"0e01";
				
				when x"e8" => sreg <= x"ff00";
				when x"e9" => sreg <= x"e004";
				when x"ea" => sreg <= x"c0c8";
				when x"eb" => sreg <= x"c196";
				when x"ec" => sreg <= x"863d";
				when x"ed" => sreg <= x"5089";
				when x"ee" => sreg <= x"5190";
				when x"ef" => sreg <= x"522c";
				when x"f0" => sreg <= x"5300";
				when x"f1" => sreg <= x"5400";
				when x"f2" => sreg <= x"5588";
				when x"f3" => sreg <= x"5700";
				when x"f4" => sreg <= x"5aa0";
				when x"f5" => sreg <= x"5b78";
				when x"f6" => sreg <= x"5c00";
				when x"f7" => sreg <= x"d304";
				when x"f8" => sreg <= x"e000";
				
				when x"f9" => sreg <= x"ffff";
				when others => sreg <= x"ffff";
				
			end case;
		end if;



end process; 


end arch; 