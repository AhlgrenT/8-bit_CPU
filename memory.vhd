library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.ALL;

-- This is a common memory design and should be used for both the instruction and data memories

entity memory is
    generic (DATA_WIDTH : integer := 8;
             ADDR_WIDTH : integer := 8;
             INIT_FILE : string := "d_memory_lab2.mif");
    port (
        clk     : in std_logic;
        readEn    : in std_logic;
        writeEn   : in std_logic;
        address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        dataIn  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        dataOut : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

Architecture Behavioural of memory is
type MEMORY_ARRAY is ARRAY (0 to 2 ** ADDR_WIDTH -1) of std_logic_vector(DATA_WIDTH-1 downto 0);


impure function init_memory_wfile(mif_file_name : in string) return MEMORY_ARRAY is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
    variable temp_mem : MEMORY_ARRAY;
begin
    for i in MEMORY_ARRAY'range loop
        readline(mif_file, mif_line);
        read(mif_line, temp_bv);
        temp_mem(i) := to_stdlogicvector(temp_bv);
    end loop;
    return temp_mem;
end function;

signal MEMORY: MEMORY_ARRAY := init_memory_wfile(INIT_FILE);

BEGIN

process(clk)
BEGIN
	IF(clk'EVENT AND clk =  '1')THEN
		
		--om read enable
		IF(readEn = '1') THEN
			dataOut <= MEMORY(to_integer(unsigned(address)));
		ELSIF(writeEn = '1') THEN
			MEMORY(to_integer(unsigned(address))) <= dataIn;
		END IF;	
		
	END IF;
END process;	

END Behavioural;
