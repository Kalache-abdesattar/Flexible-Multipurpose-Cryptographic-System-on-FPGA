library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity reg_synchronization is 
	port(sys_clk, io_clk : in std_logic;
		  in_signals : in std_logic_vector(0 to 6);
		  out_signals : out std_logic_vector(0 to 6));
end reg_synchronization;


architecture arrr of reg_synchronization is 
	signal Q1, Q2 : std_logic_vector(0 to 6);
	begin
		process(sys_clk)
			begin
				if(io_clk'event and io_clk='1') then
					Q1 <= in_signals;
				end if;
		end process;
		
		
		process(sys_clk)
			begin
				if(sys_clk'event and sys_clk='1') then 
					Q2 <= Q1;
				end if;
		end process;
		
		
		process(sys_clk)
			begin
				if(sys_clk'event and sys_clk='1') then 
					out_signals <= Q2;
				end if;
		end process;
end;

