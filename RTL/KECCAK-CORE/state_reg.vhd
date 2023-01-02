
library ieee;
use ieee.std_logic_1164.all;


entity state_reg is 
		port(clk, ena : in std_logic;
			d_state : in std_logic_vector(0 to 1599);
			q_state : out std_logic_vector(0 to 1599));
end;


architecture arc of state_reg is 
	begin 
		process(clk)
			begin 
				if(clk'event and clk = '1') then 
					if(ena = '1') then
						q_state <= d_state;
					end if;
				end if;
		end process;
end;
