library ieee;				 
use ieee.std_logic_1164.all;


entity mix_columns is 
	port(in_block : in std_logic_vector(0 to 127);
		 mixed_block : out std_logic_vector(0 to 127));
end mix_columns;



architecture arc of mix_columns is 
	signal mult_by2, mult_by3 : std_logic_vector(0 to 127);
	begin 
		process(in_block)
			variable shift_2 : std_logic_vector(0 to 8);
			begin
				for i in 0 to 15 loop
					shift_2 := in_block(i * 8 to i * 8 + 7) & '0';
					if(shift_2(0) = '0') then
						mult_by2(i * 8 to i * 8 + 7) <= shift_2(1 to 8);
					else mult_by2(i * 8 to i * 8 + 7) <= shift_2(1 to 8) xor "00011011";
					end if;
				end loop;
		end process;
		
		
		process(in_block)
			variable shift_3 : std_logic_vector(0 to 8);
			begin
				for i in 0 to 15 loop
					shift_3 := (in_block(i * 8 to i * 8 + 7) & '0') xor ('0' & in_block(i * 8 to i * 8 + 7));
					if(shift_3(0) = '0') then
						mult_by3(i * 8 to i * 8 + 7) <= shift_3(1 to 8);
					else mult_by3(i * 8 to i * 8 + 7) <= shift_3(1 to 8) xor "00011011";
					end if;
				end loop;
		end process;
		
			
			
		mixed_block(0 to 31) <= (mult_by2(0 to 7) xor mult_by3(8 to 15) xor in_block(16 to 23) xor in_block(24 to 31)) & (in_block(0 to 7) xor mult_by2(8 to 15) xor mult_by3(16 to 23) xor in_block(24 to 31)) & (in_block(0 to 7) xor in_block(8 to 15) xor mult_by2(16 to 23) xor mult_by3(24 to 31)) & (mult_by3(0 to 7) xor in_block(8 to 15) xor in_block(16 to 23) xor mult_by2(24 to 31));
		
		mixed_block(32 to 63) <= (mult_by2(32 to 39) xor mult_by3(40 to 47) xor in_block(48 to 55) xor in_block(56 to 63)) & (in_block(32 to 39) xor mult_by2(40 to 47) xor mult_by3(48 to 55) xor in_block(56 to 63)) & (in_block(32 to 39) xor in_block(40 to 47) xor mult_by2(48 to 55) xor mult_by3(56 to 63)) & (mult_by3(32 to 39) xor in_block(40 to 47) xor in_block(48 to 55) xor mult_by2(56 to 63));
		
		mixed_block(64 to 95) <= (mult_by2(64 to 71) xor mult_by3(72 to 79) xor in_block(80 to 87) xor in_block(88 to 95)) & (in_block(64 to 71) xor mult_by2(72 to 79) xor mult_by3(80 to 87) xor in_block(88 to 95)) & (in_block(64 to 71) xor in_block(72 to 79) xor mult_by2(80 to 87) xor mult_by3(88 to 95)) & (mult_by3(64 to 71) xor in_block(72 to 79) xor in_block(80 to 87) xor mult_by2(88 to 95));
		
		mixed_block(96 to 127) <= (mult_by2(96 to 103) xor mult_by3(104 to 111) xor in_block(112 to 119) xor in_block(120 to 127)) & (in_block(96 to 103) xor mult_by2(104 to 111) xor mult_by3(112 to 119) xor in_block(120 to 127)) & (in_block(96 to 103) xor in_block(104 to 111) xor mult_by2(112 to 119) xor mult_by3(120 to 127)) & (mult_by3(96 to 103) xor in_block(104 to 111) xor in_block(112 to 119) xor mult_by2(120 to 127));
end;	