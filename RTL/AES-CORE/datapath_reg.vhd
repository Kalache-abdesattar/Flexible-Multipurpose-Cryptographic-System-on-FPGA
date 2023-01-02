library ieee;
use ieee.std_logic_1164.all;


entity datapath_reg is 
	port(clk : in std_logic;
		 data : in std_logic_vector(0 to 127);
		 dout : out std_logic_vector(0 to 127));
end;


architecture arc of datapath_reg is 
	begin 
		process(clk)
			begin 
				if(clk'event and clk = '1') then 
					dout <= data;
				end if;
		end process;
end;
