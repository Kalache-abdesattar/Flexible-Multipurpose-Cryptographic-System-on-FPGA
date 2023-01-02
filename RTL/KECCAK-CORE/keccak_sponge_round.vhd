library ieee;
use ieee.std_logic_1164.all;




entity keccak_sponge_round is 
	port(compression_ena : in std_logic;
		in_state : in std_logic_vector(0 to 1599);
		iota_constant : in std_logic_vector(0 to 63);
		out_state : out std_logic_vector(0 to 1599));
end keccak_sponge_round;




architecture arc of keccak_sponge_round is 
	signal state_theta, state_rhoPi, state_chi : std_logic_vector(0 to 1599);
	signal rhoPi_lanes : std_logic_vector(0 to 1625);
	signal theta_c, theta_d, theta_lanes : std_logic_vector(0 to 319);
 
	type router_type is array(0 to 24) of integer range 0 to 200;
	constant theta_router : router_type := (0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4);
	constant Pi_router : router_type := (0, 10, 20, 5, 15, 16, 1, 11, 21, 6, 7, 17, 2, 12, 22, 23, 8, 18, 3, 13, 14, 24, 9, 19, 4);
	constant rho_router : router_type := (0, 1, 62, 28, 27, 36, 44, 6, 55, 20, 3, 10, 43, 25, 39, 41, 45, 15, 21, 8, 18, 2, 61, 56, 14);
	
	begin 

		---COMPACT FORM
		--tmp_gen_00 : for i in 0 to 4 generate 
			--tmp_theta_c(i*64 to i*64+63) <= in_state(i*64 to i*64+63) xor in_state(64*i+320 to i*64+383) xor in_state(i*64+640 to i*64+703) xor in_state(64*i+960 to 64*i+1023) xor in_state(64*i+1280 to 64*i+1343);
		--end generate;
		
		---	EXPLICIT FORM 
		theta_c(0 to 63) <= in_state(0 to 63) xor in_state(320 to 383) xor in_state(640 to 703) xor in_state(960 to 1023) xor in_state(1280 to 1343);
		theta_c(64 to 127) <= in_state(64 to 127) xor in_state(384 to 447) xor in_state(704 to 767) xor in_state(1024 to 1087) xor in_state(1344 to 1407);
		theta_c(128 to 191) <= in_state(128 to 191) xor in_state(448 to 511) xor in_state(768 to 831) xor in_state(1088 to 1151) xor in_state(1408 to 1471);
		theta_c(192 to 255) <= in_state(192 to 255) xor in_state(512 to 575) xor in_state(832 to 895) xor in_state(1152 to 1215) xor in_state(1472 to 1535);
		theta_c(256 to 319) <= in_state(256 to 319) xor in_state(576 to 639) xor in_state(896 to 959) xor in_state(1216 to 1279) xor in_state(1536 to 1599);


		tmp_gen_01 : for i in 0 to 4 generate
			theta_lanes(i*64 to i*64+63) <= theta_c(((i+1) mod 5)*64 to ((i+1) mod 5)*64 + 63);
			theta_d(i*64 to i*64+63) <= theta_c(((i-1) mod 5)*64 to ((i-1) mod 5)*64 + 63) xor (theta_lanes(64*i+1 to 64*i+63) & theta_lanes(64*i));
		end generate;
		
		
		tmp_gen_02 : for i in 0 to 24 generate
			state_theta(i*64 to i*64+63) <= (theta_d(theta_router(i)*64 to theta_router(i)*64+63) xor in_state(i*64 to i*64+63));
		end generate;
		
		
		-------------------------------------------------------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------------------------------------------------------
		
		
		gen_00 : for i in 0 to 24 generate 
			rhoPi_lanes(i*65 to i*65+64) <= state_theta(i*64+rho_router(i) to i*64+63) & state_theta(i*64 to i*64+rho_router(i));
			state_rhoPi(Pi_router(i)*64 to Pi_router(i)*64+63) <= rhoPi_lanes(i*64 to i*64+63);
		end generate;
		
		
		-------------------------------------------------------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------------------------------------------------------


		gen_01 : for i in 0 to 24 generate
			state_chi(i*64 to i*64+63) <= state_rhoPi(i*64 to i*64+63) xor (not state_rhoPi(((i+1) mod 5)*64 to ((i+1) mod 5)*64+63) and state_rhoPi(((i+2) mod 5)*64 to ((i+2) mod 5)*64+63));
		end generate;
		
		
		out_state <= (state_chi(0 to 63) xor iota_constant) & state_chi(64 to 1599) when(compression_ena = '1') else in_state;
end;




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
