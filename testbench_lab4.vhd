library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity testbench_lab4 is
end entity testbench_lab4;

architecture test_arch of testbench_lab4 is
    constant c_CLK_PERIOD : time := 10 ns;
    constant c_MLE_PERIOD : time := 20 ns;
    
    component EDA322_processor is
    generic (dInitFile : string; iInitFile : string);
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);

	status : out std_logic_vector(3 downto 0);
	next_status : out std_logic_vector(3 downto 0);
	opcode_status: out std_logic_vector(3 downto 0);
	data_coming_out : out std_logic_vector(11 downto 0);

        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
	aluOut2seg         : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        ds2seg             : out std_logic_vector(7 downto 0)
    );
    end component EDA322_processor;
    
    signal clk                  : std_logic    := '0';
    signal resetn               : std_logic    := '0';
    signal master_load_enable   : std_logic    := '0';
   
    --signal extIn_tb          : std_logic_vector(7 downto 0);
    signal pc2seg_tb         : std_logic_vector(7 downto 0);
    signal imDataOut2seg_tb  : std_logic_vector(11 downto 0);
    signal dmDataOut2seg_tb  : std_logic_vector(7 downto 0);
    signal acc2seg_tb        : std_logic_vector(7 downto 0);
    signal aluOut2seg_tb     : std_logic_vector(7 downto 0);
    signal busOut2seg_tb     : std_logic_vector(7 downto 0);
    signal ds2seg_tb         : std_logic_vector(7 downto 0);
    signal statusTEST : std_logic_vector(3 DOWNTO 0);
    signal statusTEST2 : std_logic_vector(3 DOWNTO 0);
    signal opcodeTEST : std_logic_vector(3 DOWNTO 0);
    type vector_array is array (natural range <>) of std_logic_vector;

impure function init_memory_wfile(mif_file_name : in string; DATA_WIDTH : in integer; LINES : in integer) return vector_array is
    file mif_file     : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv  : bit_vector(DATA_WIDTH-1 downto 0); --right way? X downto 0 or 0 downto X
    variable temp_mem : vector_array(0 to LINES-1)(DATA_WIDTH-1 downto 0);
    variable i : integer := 0;
begin
    
    while not endfile (mif_file) loop
        readline(mif_file, mif_line);
        read(mif_line, temp_bv);
        temp_mem(i) := to_stdlogicvector(temp_bv);
	i := 1 + i;
    end loop;
    return temp_mem;
end function;
 signal pcTrace : vector_array(0 to 31)(7 downto 0) := init_memory_wfile("pc2seg.trace", 8, 32);
 signal dmTrace : vector_array(0 to 6)(7 downto 0) := init_memory_wfile("dmDataOut2seg.trace", 8, 7);
 signal dsTrace : vector_array(0 to 4)(7 downto 0) := init_memory_wfile("ds2seg.trace", 8, 5);
 signal imTrace : vector_array(0 to 27)(11 downto 0) := init_memory_wfile("imDataOut2seg.trace", 12, 28);
 signal accTrace : vector_array(0 to 7)(7 downto 0) := init_memory_wfile("acc2seg.trace", 8, 8);



        
begin

    clk <= not clk after c_CLK_PERIOD/2;
    master_load_enable <= not master_load_enable after c_MLE_PERIOD/2;
    
    CHACC_dut : component EDA322_processor
        generic map(dInitFile => "d_memory_lab4.mif", iInitFile => "i_memory_lab4.mif")
        port map(
            clk                 => clk,
            resetn              => resetn,
            master_load_enable  => master_load_enable,
            extIn               => "00001111",
            pc2seg              => pc2seg_tb,
	    status             => statusTEST,
	    next_status             => statusTEST2,
            opcode_status => opcodeTest,
            imDataOut2seg       => imDataOut2seg_tb,
            dmDataOut2seg       => dmDataOut2seg_tb,
            acc2seg             => acc2seg_tb,
            aluOut2seg          => aluOut2seg_tb,
            busOut2seg          => busOut2seg_tb,
            ds2seg              => ds2seg_tb
        );
termination: process
Begin
	wait for 1700 ns;
	report "Successful termination" severity failure;
end process termination;

--Assertion errors        
pcChecker: process (pc2seg_tb)
VARIABLE pcCheckerVar: integer := 0;
begin
	if(resetn = '1' AND pcCheckerVar < 32) then
		assert pcTrace(pcCheckerVar) = pc2seg_tb report "Unexpected value for PC, iteration: " & to_string(pcCheckerVar);
		pcCheckerVar := pcCheckerVar + 1;
	end if;
end process pcChecker;

--Passes tests
dmChecker: process (dmDataOut2seg_tb)
VARIABLE dmCheckerVar: integer := 0;
begin
	if(resetn = '1' AND dmCheckerVar < 7) then
		assert dmTrace(dmCheckerVar) = dmDataOut2seg_tb report "Unexpected value for DM, iteration: " & to_string(dmCheckerVar);
		dmCheckerVar := dmCheckerVar +1;
	end if;
end process dmChecker;

--Passes tests
dsChecker: process (ds2seg_tb)
VARIABLE dsCheckerVar: integer := 0;
begin
	if(resetn = '1' AND dsCheckerVar < 5) then
		assert dsTrace(dsCheckerVar) = ds2seg_tb report "Unexpected value for DS, iteration: " & to_string(dsCheckerVar);
		dsCheckerVar := dsCheckerVar + 1;
	end if;
end process dsChecker;

--Gives assertion errors
imChecker: process (imDataOut2seg_tb)
VARIABLE imCheckerVar: integer := 0;
begin
	if(resetn = '1' AND imCheckerVar < 28) then
		assert imTrace(imCheckerVar) = imDataOut2seg_tb report "Unexpected value for IM, iteration: " & to_string(imCheckerVar);
		imCheckerVar := imCheckerVar + 1;
	end if;
end process imChecker;

--Passes tests
accChecker: process (acc2seg_tb)
VARIABLE accCheckerVar: integer := 0;
begin
	if(resetn = '1' AND accCheckerVar < 8) then
		assert accTrace(accCheckerVar) = acc2seg_tb report "Unexpected value for ACC, iteration: " & to_string(accCheckerVar);
		accCheckerVar := accCheckerVar + 1;
	end if;
end process accChecker;

    resetn <= '0', '1' after c_CLK_PERIOD;

end architecture test_arch;