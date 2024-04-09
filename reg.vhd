library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic (REG_WIDTH: integer := 1);
    port (
        clk: in std_logic;
        resetn: in std_logic;
        loadEnable: in std_logic;
        dataIn: in std_logic_vector(REG_WIDTH-1 downto 0);
        dataOut: out std_logic_vector(REG_WIDTH-1 downto 0)
    );

end entity reg;

architecture dataflow of reg is
begin
	dataOut <= (OTHERS => '0') when resetn = '0' else
                   dataIn when rising_edge(clk) and loadEnable = '1' else
                   dataOut;
end dataflow;