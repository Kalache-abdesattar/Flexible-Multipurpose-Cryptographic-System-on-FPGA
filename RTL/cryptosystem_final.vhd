library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity cryptosystem_final is 
	port(sys_clk, io_clk, wr_req, done, sync_reset, sha_ena, adc_out, iterate : in std_logic;
		  source, enc_enable, rd_req_out, adc_sel : in std_logic;
		  capacity_ctrl : in std_logic_vector(0 to 1);
		  data_ctrl : in std_logic_vector(0 to 1);
		  data : in std_logic_vector(0 to 15);
		  wr_full, rd_empty_out, adc_din : out std_logic;
		  sclk, adc_cs_n : buffer std_logic;
		  DATA_OUT_HEX : out std_logic_vector(0 to 15));
end cryptosystem_final;





architecture arr of cryptosystem_final is
	signal rd_req, rd_empty, mux_ctrl, wr_req_out, wr_full_out : std_logic;
	signal q : std_logic_vector(0 to 127);
	signal digest : std_logic_vector(0 to 127);
	signal aes_out, data_bus : std_logic_vector(0 to 127);
	signal sha_rd_req, aes_rd_req : std_logic;
	signal in_sig, synch_sig : std_logic_vector(0 to 6);
	
	SIGNAL DATA_OUT, adc_buff_in, adc_buff_out, fifo_data_in : STD_LOGIC_VECTOR(0 TO 15);
	signal adc_dout : std_logic_vector(11 downto 0);
	
	component reg_synchronization is 
		port(sys_clk, io_clk : in std_logic;
			 in_signals : in std_logic_vector(0 to 6);
			 out_signals : out std_logic_vector(0 to 6));
	end component;
	
	component adc_fifo is
		PORT(
			aclr		: IN STD_LOGIC  := '0';
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	end component;
	
	
	component adc_control is
		port (
			CLOCK    : in  std_logic                     := 'X'; -- clk
			ADC_SCLK : out std_logic;                            -- SCLK
			ADC_CS_N : out std_logic;                            -- CS_N
			ADC_DOUT : in  std_logic                     := 'X'; -- DOUT
			ADC_DIN  : out std_logic;                            -- DIN
			CH0      : out std_logic_vector(11 downto 0);        -- CH0
			CH1      : out std_logic_vector(11 downto 0);        -- CH1
			CH2      : out std_logic_vector(11 downto 0);        -- CH2
			CH3      : out std_logic_vector(11 downto 0);        -- CH3
			CH4      : out std_logic_vector(11 downto 0);        -- CH4
			CH5      : out std_logic_vector(11 downto 0);        -- CH5
			CH6      : out std_logic_vector(11 downto 0);        -- CH6
			CH7      : out std_logic_vector(11 downto 0);        -- CH7
			RESET    : in  std_logic                     := 'X'  -- reset
		);
	end component adc_control;


	
	
	component tunable_keccak is port(clk, sync_reset, sys_ena, done, rd_empty : in std_logic;
		  capacity_ctrl : in std_logic_vector(0 to 1);
		  iterate : in std_logic;
		  in_block : in std_logic_vector(0 to 127);
		  rd_req : out std_logic;
		  digest : out std_logic_vector(0 to 127));
	end component;


	component dsffo is PORT(aclr : in std_logic; data : IN STD_LOGIC_VECTOR (15 DOWNTO 0); rdclk : IN STD_LOGIC; rdreq : IN STD_LOGIC; 
		wrclk : IN STD_LOGIC; 
		wrreq	: IN STD_LOGIC;
		q: OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
		rdempty : OUT STD_LOGIC;
		wrfull : OUT STD_LOGIC);
	end component;
	
	
	component aes_dsffo PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (127 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
	end component;

	
	component aes_core is 
		port(clk, wr_full, rd_empty, sync_reset, enc_enable, source : in std_logic;
		  data_ctrl : in std_logic_vector(0 to 1);
		  in_block : in std_logic_vector(0 to 127);
		  wr_req, rd_req, mux_ctrl : out std_logic;
		  data_out : out std_logic_vector(0 to 127));
	end component;

	
	signal adc_read_empty, adc_wr_full : std_logic;
	
	begin 
	
		in_sig <= sync_reset & enc_enable & sha_ena & done & source & data_ctrl;
	
		synch : reg_synchronization port map(sys_clk, io_clk, in_sig, synch_sig);
		
		adc : adc_control port map(sys_clk, sclk, adc_cs_n, adc_out, adc_din, adc_dout, open, open, 
				open, open, open, open, open, sync_reset);
					
		adc_buff_in <= adc_dout & "1111";
		
		--adc_buffer : adc_fifo PORT MAP(sync_reset, adc_buff_in, sys_clk, rd_req, sclk, adc_cs_n, adc_buff_out, adc_read_empty, adc_wr_full);----FOR SYNCHRONIZATION
		
		fifo_data_in <= adc_buff_in when(adc_sel = '1') else data;
	
		in_fifo : dsffo port map(synch_sig(0), fifo_data_in, sys_clk, rd_req, io_clk, wr_req, q, rd_empty, wr_full);
		
		sha3 : tunable_keccak port map(sys_clk, synch_sig(0), synch_sig(2), synch_sig(3), rd_empty, capacity_ctrl, iterate, q, sha_rd_req, digest);
			
		rd_req <= sha_rd_req OR aes_rd_req;
		
		data_bus <= digest when(mux_ctrl = '0') else q; 
		
		aes : aes_core port map(sys_clk, wr_full_out, rd_empty, synch_sig(0), synch_sig(1), synch_sig(4), 
				synch_sig(5 to 6), data_bus, wr_req_out, aes_rd_req, mux_ctrl, aes_out);
		
		out_fifo : aes_dsffo port map(synch_sig(0), aes_out, io_clk, rd_req_out, sys_clk,
				wr_req_out, data_out, rd_empty_out, wr_full_out);
		
		DATA_OUT_HEX <= data_out;
	
end;
