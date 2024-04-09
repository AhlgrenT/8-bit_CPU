library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;

entity proc_bus is
    port (
        decoEnable : in std_logic;
        decoSel    : in std_logic_vector(1 downto 0);
        imDataOut  : in std_logic_vector(7 downto 0);
        dmDataOut  : in std_logic_vector(7 downto 0);
        accOut     : in std_logic_vector(7 downto 0);
        extIn      : in std_logic_vector(7 downto 0);
        busOut     : out std_logic_vector(7 downto 0)
    );
end proc_bus;

architecture dataflow of proc_bus is

	component tri_state_buffer is
	Generic(
		DATA_WIDTH   : INTEGER := 8
	);
	Port (
       	 	input_signal : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        	enable	     : in STD_LOGIC;
       		output_signal: out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
    	);
	END COMPONENT;

signal imDataOutEnable : STD_LOGIC;
signal dmDataOutEnable : STD_LOGIC;
signal accOutEnable    : STD_LOGIC;
signal exitInEnable    : STD_LOGIC;



begin
	--2:4 decoder. Ska busOut = 'Z' då decoEnable = '0'?
	imDataOutEnable <= '1' when decoSel = B_IMEM AND decoEnable = '1' else '0';
    	dmDataOutEnable <= '1' when decoSel = B_DMEM AND decoEnable = '1' else '0';
    	accOutEnable <=    '1' when decoSel = B_ACC AND decoEnable = '1' else '0';
    	exitInEnable <=    '1' when decoSel = B_EXT AND decoEnable = '1' else '0';


	--Tri State Buffers instanceiation
	buffer_imDataOut : tri_state_buffer
		generic map (
          	  DATA_WIDTH => 8
      		  )
		port map (
		input_signal => imDataOut,
           	enable => imDataOutEnable,
            	output_signal => busOut
        	);
	buffer_dmDataOut : tri_state_buffer
		generic map (
          	  DATA_WIDTH => 8
      		  )
		port map (
		input_signal => dmDataOut,
           	enable => dmDataOutEnable,
            	output_signal => busOut
        	);
	buffer_accOut : tri_state_buffer
		generic map (
          	  DATA_WIDTH => 8
      		  )
		port map (
		input_signal => accOut,
           	enable => accOutEnable,
            	output_signal => busOut
        	);
	buffer_extInOut : tri_state_buffer
		generic map (
          	  DATA_WIDTH => 8
      		  )
		port map (
		input_signal => extIn,
           	enable => exitInEnable,
            	output_signal => busOut
        	);
	
end dataflow;