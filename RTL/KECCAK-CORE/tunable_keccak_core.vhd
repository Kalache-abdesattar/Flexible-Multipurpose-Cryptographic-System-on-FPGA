library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity tunable_keccak is 
	port(clk, sync_reset, sys_ena, done, rd_empty : in std_logic;
		  capacity_ctrl : in std_logic_vector(0 to 1);
		  iterate : in std_logic;
		  in_block : in std_logic_vector(0 to 127);
		  rd_req : out std_logic;
		  digest : out std_logic_vector(0 to 127));
end tunable_keccak;





architecture ar of tunable_keccak is 
	type fsm_state is (idle, load_seed, init, round1, round2, round3, round4, round5, round6, round7, round8, round9, round10, round11, round12, round13, round14, round15, round16, round17, round18, round19, round20, round21, round22, round23, round24, stop);
	signal pr_state, next_state : fsm_state;
		
	signal in_state : std_logic_vector(0 to 1599) := (others => '0');
	signal out_state, in_state_reg, out_state_reg, in_buffer, out_buffer : std_logic_vector(0 to 1599) := (others => '0');

	signal round_constant : std_logic_vector(0 to 63);
	signal out_ena, in_ena, compression_ena, input_sel, seed_ena, reg_ena : std_logic;
	signal instate_sel : std_logic_vector(0 to 1);
	
	component keccak_sponge_round is port(compression_ena : in std_logic; in_state : in std_logic_vector(0 to 1599); iota_constant : in std_logic_vector(0 to 63); 
		out_state : out std_logic_vector(0 to 1599));
	end component;
	component state_reg is port(clk, ena : in std_logic; d_state : in std_logic_vector(0 to 1599);
			q_state : out std_logic_vector(0 to 1599));
	end component;


	begin 		
		process(clk)
			begin 
				if(clk'event and clk = '1') then 
					if(sync_reset = '1') then 
						pr_state <= idle;
					else pr_state <= next_state;
					end if;
				end if;
		end process;
		
		
		
		process(sys_ena, pr_state, done, rd_empty, capacity_ctrl)
			begin 
				case pr_state is 
					when idle => 
						compression_ena <= '0';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '0';
						round_constant <= (others => 'X');
						out_ena <= '0';
						if(sys_ena = '1') then 
							next_state <= load_seed;
						else next_state <= idle;
						end if;
						
					when load_seed =>
						compression_ena <= '0';
						input_sel <= '0';
						seed_ena <= '1';
						in_ena <= '1';
						reg_ena <= '1';
						round_constant <= (others => 'X');
						out_ena <= '0';
						if(rd_empty = '1') then
							next_state <= round1;
						else next_state <= load_seed;
						end if;
						
					when init =>
						compression_ena <= '0';
						if(done = '1') then
							input_sel <= '0';
						else input_sel <= '1';
						end if;
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '1';
						round_constant <= (others => 'X');
						out_ena <= '0';
						next_state <= round1;

												
					when round1 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '1';
						round_constant <= "0000000000000000000000000000000000000000000000000000000000000001";
						out_ena <= '0';
						next_state <= round2;
					
					when round2 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '1';
						round_constant <= "0000000000000000000000000000000000000000000000001000000010000010";
						out_ena <= '0';
						next_state <= round3;
					
					when round3 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							in_ena <= '1';
						else in_ena <= '0';
						end if;
						round_constant <= "1000000000000000000000000000000000000000000000001000000010001010";
						out_ena <= '0';
						next_state <= round4;
					
					when round4 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							in_ena <= '1';
						else in_ena <= '0';
						end if;
						round_constant <= "1000000000000000000000000000000010000000000000001000000000000000";
						out_ena <= '0';
						next_state <= round5;
					
					when round5 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							in_ena <= '1';
						else in_ena <= '0';
						end if;
						round_constant <= "0000000000000000000000000000000000000000000000001000000010001011";
						out_ena <= '0';
						next_state <= round6;
					
					when round6 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							in_ena <= '1';
						else in_ena <= '0';
						end if;
						round_constant <= "0000000000000000000000000000000010000000000000000000000000000001";
						out_ena <= '0';
						next_state <= round7;
					
					when round7 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							in_ena <= '1';
						else in_ena <= '0';
						end if;
						round_constant <= "1000000000000000000000000000000010000000000000001000000010000001";
						out_ena <= '0';
						next_state <= round8;
					
					when round8 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							in_ena <= '1';
						else in_ena <= '0';
						end if;
						round_constant <= "1000000000000000000000000000000000000000000000001000000000001001";
						out_ena <= '0';
						next_state <= round9;
					
					when round9 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							in_ena <= '1';
						else in_ena <= '0';
						end if;
						round_constant <= "0000000000000000000000000000000000000000000000000000000010001010";
						out_ena <= '0';
						next_state <= round10;
					
					when round10 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							in_ena <= '1';
						else in_ena <= '0';
						end if;
						round_constant <= "0000000000000000000000000000000000000000000000000000000010001000";
						out_ena <= '0';
						next_state <= round11;
					
					when round11 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							if(capacity_ctrl = "00" OR capacity_ctrl = "01" OR capacity_ctrl = "10") then
								in_ena <= '1';
							else in_ena <= '0';
							end if;
						else in_ena <= '0';
						end if;
						round_constant <= "0000000000000000000000000000000010000000000000001000000000001001";
						out_ena <= '0';
						next_state <= round12;
					
					when round12 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							if(capacity_ctrl = "00" OR capacity_ctrl = "01") then
								in_ena <= '1';
							else in_ena <= '0';
							end if;
						else in_ena <= '0';
						end if;
						round_constant <= "0000000000000000000000000000000010000000000000000000000000001010";
						out_ena <= '0';
						next_state <= round13;
					
					when round13 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						if(rd_empty = '0') then 
							if(capacity_ctrl = "00") then
								in_ena <= '1';
							else in_ena <= '0';
							end if;
						else in_ena <= '0';
						end if;
						round_constant <= "0000000000000000000000000000000010000000000000001000000010001011";
						out_ena <= '0';
						next_state <= round14;
					
					when round14 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						in_ena <= '0';
						round_constant <= "1000000000000000000000000000000000000000000000000000000010001011";
						out_ena <= '0';
						next_state <= round15;
					
					when round15 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						in_ena <= '0';
						round_constant <= "1000000000000000000000000000000000000000000000001000000010001001";
						out_ena <= '0';
						next_state <= round16;
					
					when round16 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						in_ena <= '0';
						round_constant <= "1000000000000000000000000000000000000000000000001000000000000011";
						out_ena <= '0';
						next_state <= round17;
					
					when round17 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						in_ena <= '0';
						round_constant <= "1000000000000000000000000000000000000000000000001000000000000010";
						out_ena <= '0';
						next_state <= round18;
					
					when round18 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						in_ena <= '0';
						round_constant <= "1000000000000000000000000000000000000000000000000000000010000000";
						out_ena <= '0';
						next_state <= round19;
					
					when round19 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						reg_ena <= '1';
						in_ena <= '0';
						round_constant <= "0000000000000000000000000000000000000000000000001000000000001010";
						out_ena <= '0';
						next_state <= round20;
					
					when round20 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '1';
						round_constant <= "1000000000000000000000000000000010000000000000000000000000001010";
						out_ena <= '0';
						next_state <= round21;
					
					when round21 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '1';
						round_constant <= "1000000000000000000000000000000010000000000000001000000010000001";
						out_ena <= '0';
						next_state <= round22;
										
					when round22 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '1';
						round_constant <= "1000000000000000000000000000000000000000000000001000000010000000";
						out_ena <= '0';
						next_state <= round23;
					
					when round23 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '1';
						round_constant <= "0000000000000000000000000000000010000000000000000000000000000001";
						out_ena <= '0';
						next_state <= round24;
					
					when round24 => 
						compression_ena <= '1';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '1';
						round_constant <= "1000000000000000000000000000000010000000000000001000000000001000";
						out_ena <= '0';
						if(done = '1') then
							next_state <= stop;
						else next_state <= init;
						end if;
						
					when stop => 
						compression_ena <= '0';
						input_sel <= '0';
						seed_ena <= '0';
						in_ena <= '0';
						reg_ena <= '0';
						out_ena <= sys_ena AND done;
						round_constant <= (others => 'X');
						if(sys_ena = '0' OR done = '1' OR rd_empty = '1') then
							next_state <= stop;
						elsif(iterate = '1') then 
							next_state <= round1;
						else next_state <= init;
						end if;
				end case;
		end process;
		
		
		
		process(clk)
			begin 
				if(clk'event and clk = '1') then 
					if(sync_reset = '1') then 
						in_buffer <= (others => '0');
					else
							if (capacity_ctrl = "00") then
								if(in_ena = '1') then 
									in_buffer <= in_buffer(128 to 1407) & in_block & in_buffer(1408 to 1599);
								end if;
							elsif (capacity_ctrl = "01") then
								if(in_ena = '1') then 
									in_buffer <= in_buffer(128 to 1279) & in_block & in_buffer(1280 to 1599);								end if;
							elsif (capacity_ctrl = "10") then
								if(in_ena = '1') then 
									in_buffer <= in_buffer(128 to 1151) & in_block & in_buffer(1152 to 1599);
								end if;
							else
								if(in_ena = '1') then 
									in_buffer <= in_buffer(128 to 1023) & in_block & in_buffer(1024 to 1599);
								end if;
						end if;
					end if;
				end if;
		end process;
		
		
		
		instate_sel <= seed_ena & input_sel;
		
		in_state <= zero_state when(sync_reset='1') else in_buffer when(sync_reset='0' and instate_sel = "10") else in_buffer xor out_state_reg when(instate_sel = "01" and sync_reset='0') else out_state_reg;
		
		reg_upper : state_reg port map(clk, reg_ena, in_state, in_state_reg);
		
		c : keccak_sponge_round port map(compression_ena, in_state_reg, round_constant, out_state);
		
		reg_lower : state_reg port map(clk, '1', out_state, out_state_reg);
		
		digest <= out_state_reg(0 to 127) when(out_ena = '1') else (others => 'Z');

		rd_req <= in_ena;
end;