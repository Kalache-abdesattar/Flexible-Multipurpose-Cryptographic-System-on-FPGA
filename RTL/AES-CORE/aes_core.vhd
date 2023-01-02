
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity aes_core is 
	port(clk, wr_full, rd_empty, sync_reset, enc_enable, source : in std_logic;
		  data_ctrl : in std_logic_vector(0 to 1);
		  in_block : in std_logic_vector(0 to 127);
		  wr_req, rd_req, mux_ctrl : out std_logic;
		  data_out : out std_logic_vector(0 to 127));
end aes_core;




architecture arc of aes_core is 
	type state is (clear, idle, encrypt, random);
	signal pr_state, next_state : state;
	signal pipe_counter : integer range 0 to 15 := 0;

	
	signal reg_ena, out_ena, reg_clr, nonce_ena, key_ena : std_logic;
	
	---- CTR MODE SUTIES
	signal nonce : std_logic_vector(0 to 95) := (others => '1');
	signal counter : unsigned(0 to 31);
	
	---- KEY REGIRSTER (128bits)
	signal key : std_logic_vector(0 to 127) := (others => '0');
	
	------ ROUND PIPELINE'S REGISTERS
	signal din, reg_out_1, reg_out_2, reg_out_3, reg_out_4, reg_out_5, reg_out_6, reg_out_7, reg_out_8, reg_out_9, reg_out_10 : std_logic_vector(0 to 127);
	------ ROUNDS' OUTPUTS
	signal round_1_out, round_2_out, round_3_out, round_4_out, round_5_out, round_6_out, round_7_out, round_8_out, round_9_out, round_10_out : std_logic_vector(0 to 127);
	
	----- KEY-SCHEDULE'S OUTPUTS
	signal round_key_1, round_key_2, round_key_3, round_key_4, round_key_5, round_key_6, round_key_7, round_key_8, round_key_9, round_key_10 : std_logic_vector(0 to 127);
	------ KEY-SCHEDULE PIPELINE'S REGISTERS
	signal round_key_1_reg, round_key_2_reg, round_key_3_reg, round_key_4_reg, round_key_5_reg, round_key_6_reg, round_key_7_reg, round_key_8_reg, round_key_9_reg, round_key_10_reg : std_logic_vector(0 to 127);
	
	------ REGISTER COMPONENT (WITHOUT ASYNCHRONOUS RESET)
	component datapath_reg is port(clk, sync_clr, ena : in std_logic; 
				data : in std_logic_vector(0 to 127); 
				dout : out std_logic_vector(0 to 127));
	end component;
	
	
										--=======AES'S TOP LEVEL COMPONENTS=========--
	--------------------------
	component aes_round is port(in_block : in std_logic_vector(0 to 127); 
				round_key : in std_logic_vector(0 to 127); 
				last_round : in std_logic; 
				out_block : out std_logic_vector(0 to 127));
	end component;
	
	
	component key_sch is port(key_in : in std_logic_vector(0 to 127); 
				round_const : in std_logic_vector(0 to 31); 
				key_out : out std_logic_vector(0 to 127));
	end component;
	----------------------------
	

	begin
		process(clk)
			begin 
				if(clk'event and clk = '1') then 
					if(sync_reset = '1') then 
						pr_state <= clear;	
					elsif(enc_enable = '0') then
						pr_state <= idle;
					else pr_state <= next_state;
					end if;
					
					if(pr_state = encrypt AND pipe_counter < 14) then 
						pipe_counter <= pipe_counter + 1;
					elsif(pr_state = clear) then
						pipe_counter <= 0;
					end if;
				end if;
		end process;
		
		
		process(pr_state, source, data_ctrl, wr_full, rd_empty, pipe_counter)
			begin 
				case pr_state is
					when clear => 
						reg_ena <= '0';
						out_ena <= '0';
						reg_clr <= '1';
						mux_ctrl <= 'X';
						rd_req <= '0';
						key_ena <= '0';
						nonce_ena <= '0';
						next_state <= idle;
						
						
					when idle =>
						reg_ena <= '0';
						out_ena <= '0';
						reg_clr <= '0';
						mux_ctrl <= 'X';
						rd_req <= '0';
						key_ena <= '0';
						nonce_ena <= '0';
						if(rd_empty = '1' OR wr_full = '1') then
							next_state <= idle;
						elsif((data_ctrl(0) XOR data_ctrl(1)) = '1') then 
							next_state <= random;
						else next_state <= encrypt;
						end if;
						
						
					when encrypt =>
						reg_ena <= '1';
						if(pipe_counter > 9) then
							out_ena <= NOT wr_full;
						else out_ena <= '0';
						end if;
						reg_clr <= '0';
						mux_ctrl <= '1';
						rd_req <= NOT rd_empty;
						key_ena <= '0';
						nonce_ena <= '0';
						if(rd_empty = '1' OR wr_full = '1') then 
							next_state <= idle;
						elsif((data_ctrl(1) XOR data_ctrl(0)) = '0') then 
							next_state <= encrypt;
						else next_state <= idle;
						end if;
						
						
					when random => 
						reg_ena <= '0';
						out_ena <='0';
						reg_clr <= '0';
						mux_ctrl <= source;
						rd_req <= NOT rd_empty;
						key_ena <= data_ctrl(0);
						nonce_ena <= data_ctrl(1);
						next_state <= idle;
				end case;
		end process;
	
	
		------- AES-CTR INPUT CONTROLLER 
		
		process(clk)
			begin 
				if(clk'event and clk = '1') then
					if(reg_clr = '1') then 
						counter <= (others => '0');
					elsif(enc_enable = '1') then
						if(counter = x"FFFFFFFF") then 
							counter <= (others => '0');
						else 
							counter <= counter + 1;
						end if;
					end if;
				end if;
		end process;
		
--"11111111111111111111111111111111"		
		
		
		
		-------- KEY REGISTER CONTROLLER
		process(clk)
			begin 
				if(clk'event and clk = '1') then 
					if(key_ena = '1') then
						key <= in_block; 
					end if;
				end if;
		end process;
		
		
		
		process(clk)
			begin 
				if(clk'event and clk = '1') then 
					if(nonce_ena = '1') then 
						nonce <= in_block(0 to 95);
					end if;
				end if;
		end process;
		
		
		
								--==========KEY-SCHEDULE'S PIPELINE============--
		sch_1 : key_sch port map(key, "00000001000000000000000000000000", round_key_1);
		reg_1 : datapath_reg port map(clk, reg_clr, '0', round_key_1, round_key_1_reg);
		
		sch_2 : key_sch port map(round_key_1_reg, "00000010000000000000000000000000", round_key_2);
		reg_2 : datapath_reg port map(clk, reg_clr, '0', round_key_2, round_key_2_reg);
		
		sch_3 : key_sch port map(round_key_2_reg, "00000010000000000000000000000000", round_key_3);
		reg_3 : datapath_reg port map(clk, reg_clr, '0', round_key_3, round_key_3_reg);
		
		sch_4 : key_sch port map(round_key_3_reg, "00001000000000000000000000000000", round_key_4);
		reg_4 : datapath_reg port map(clk, reg_clr, '0', round_key_4, round_key_4_reg);
		
		sch_5 : key_sch port map(round_key_4_reg, "00010000000000000000000000000000", round_key_5);
		reg_5 : datapath_reg port map(clk, reg_clr, '0', round_key_5, round_key_5_reg);
		
		sch_6 : key_sch port map(round_key_5_reg, "00100000000000000000000000000000", round_key_6);
		reg_6 : datapath_reg port map(clk, reg_clr, '0', round_key_6, round_key_6_reg);
		
		sch_7 : key_sch port map(round_key_6_reg, "01000000000000000000000000000000", round_key_7);
		reg_7 : datapath_reg port map(clk, reg_clr, '0', round_key_7, round_key_7_reg);
		
		sch_8 : key_sch port map(round_key_7_reg, "10000000000000000000000000000000", round_key_8);
		reg_8 : datapath_reg port map(clk, reg_clr, '0', round_key_8, round_key_8_reg);
		
		sch_9 : key_sch port map(round_key_8_reg, "00011011000000000000000000000000", round_key_9);
		reg_9 : datapath_reg port map(clk, reg_clr, '0', round_key_9, round_key_9_reg);
		
		sch_10 : key_sch port map(round_key_9_reg, "00110110000000000000000000000000", round_key_10);
		reg_10 : datapath_reg port map(clk, reg_clr, '0', round_key_10, round_key_10_reg);
		
		
		
		
								--==========THE 10 ROUNDS' PIPELINE============--
		din <= (nonce & std_logic_vector(counter)) XOR key;
		
		
		round_1 : aes_round port map(din, round_key_1_reg, '0', round_1_out);
		reg1 : datapath_reg port map(clk, reg_clr, reg_ena, round_1_out, reg_out_1);
		
		round_2 : aes_round port map(reg_out_1, round_key_2_reg, '0', round_2_out);
		reg2 : datapath_reg port map(clk, reg_clr, reg_ena, round_2_out, reg_out_2);
		
		round_3 : aes_round port map(reg_out_2, round_key_3_reg, '0', round_3_out);
		reg3 : datapath_reg port map(clk, reg_clr, reg_ena, round_3_out, reg_out_3);
	
		round_4 : aes_round port map(reg_out_3, round_key_4_reg, '0', round_4_out);
		reg4 : datapath_reg port map(clk, reg_clr, reg_ena, round_4_out, reg_out_4);
		
		round_5 : aes_round port map(reg_out_4, round_key_5_reg, '0', round_5_out);
		reg5 : datapath_reg port map(clk, reg_clr, reg_ena, round_5_out, reg_out_5);
		
		round_6 : aes_round port map(reg_out_5, round_key_6_reg, '0', round_6_out);
		reg6 : datapath_reg port map(clk, reg_clr, reg_ena, round_6_out, reg_out_6);
		
		round_7 : aes_round port map(reg_out_6, round_key_7_reg, '0', round_7_out);
		reg7 : datapath_reg port map(clk, reg_clr, reg_ena, round_7_out, reg_out_7);
		
		round_8 : aes_round port map(reg_out_7, round_key_8_reg, '0', round_8_out);
		reg8 : datapath_reg port map(clk, reg_clr, reg_ena, round_8_out, reg_out_8);
		
		round_9 : aes_round port map(reg_out_8, round_key_9_reg, '0', round_9_out);
		reg9 : datapath_reg port map(clk, reg_clr, reg_ena, round_9_out, reg_out_9);
		
		round_10 : aes_round port map(reg_out_9, round_key_10_reg, '1', round_10_out);
		reg10 : datapath_reg port map(clk, reg_clr, reg_ena, round_10_out, reg_out_10);
		
		
		------- OUTPUT PORT
		data_out <= (reg_out_10 XOR in_block) when(out_ena = '1') else (others => 'Z');
		
		wr_req <= out_ena;

end;
