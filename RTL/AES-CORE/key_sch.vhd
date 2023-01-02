library ieee;
use ieee.std_logic_1164.all;



entity key_sch is 
	port(key_in : in std_logic_vector(0 to 127);
		 round_const : in std_logic_vector(0 to 31);
		 key_out : out std_logic_vector(0 to 127));
end key_sch;




architecture arc of key_sch is 	
	component sbox_lut is port(in_byte : in std_logic_vector(0 to 7);
			out_byte : out std_logic_vector(0 to 7));
	end component;
	
	signal subbed_0, shifted_0, tmp_sig : std_logic_vector(0 to 31);
	begin 
		---SHIFT THE FIRST WORD TO THE LEFT (<<< 1)
		shifted_0 <= key_in(104 to 127) & key_in(96 to 103);
		
		
		---SUBBYTES OF THE FIRST WORD 
		gen_00 : for i in 0 to 3 generate 
			s : sbox_lut port map(shifted_0(i * 8 to i * 8 + 7), subbed_0(i * 8 to i * 8 + 7));
		end generate;
		
		
		---XOR THE FIRST WORD WITH ROUND CONSTANT 
		tmp_sig <= (subbed_0 xor round_const xor key_in(0 to 31));
		
		
		---COMBINE THE FIRST WORD WITH THE REMAINING WORDS 
		key_out <= tmp_sig & (tmp_sig xor key_in(32 to 63)) & (tmp_sig xor key_in(32 to 63) xor key_in(64 to 95)) & (tmp_sig xor key_in(32 to 63) xor key_in(64 to 95) xor key_in(96 to 127)); 
end;