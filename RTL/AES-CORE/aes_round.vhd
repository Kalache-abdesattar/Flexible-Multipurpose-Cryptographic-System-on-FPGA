library ieee;
use ieee.std_logic_1164.all;


entity aes_round is 
	port(in_block : in std_logic_vector(0 to 127);
		 round_key : in std_logic_vector(0 to 127);
		 last_round, ena : in std_logic;
		 out_block : out std_logic_vector(0 to 127));
end aes_round;


architecture beh of aes_round is 
	type router_type is array(0 to 15) of integer range 0 to 120;
	constant router : router_type := (0, 104, 80, 56, 32, 8, 112, 88, 64, 40, 16, 120, 96, 72, 48, 24);
	signal subbed_block, mixed_block, rounded : std_logic_vector(0 to 127);
	
	component sbox_lut is port(in_byte : in std_logic_vector(0 to 7);
		 out_byte : out std_logic_vector(0 to 7));
	end component;
	component mix_columns is port(in_block : in std_logic_vector(0 to 127); 
		 mixed_block : out std_logic_vector(0 to 127));
	end component;
	
	begin 
		---SUBBYTES AND SHIFTROWS STEPS
		gen_0 : for i in 0 to 15 generate 
			sbox_inst : sbox_lut port map(in_block(i * 8 to i * 8 + 7), subbed_block(router(i) to router(i) + 7));
		end generate;
		
		
		---MIXCOLUMNS STEP (EXCEPT FOR THE LAST ROUND)
		mix : mix_columns port map(subbed_block, mixed_block);
		
		
		---ADD ROUNDKEY STEP
		rounded <= (mixed_block xor round_key) when last_round = '0' else (subbed_block xor round_key);
		
		out_block <= rounded when ena = '1' else in_block;
end beh;