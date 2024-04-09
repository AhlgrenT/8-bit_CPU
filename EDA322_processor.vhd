library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EDA322_processor is
    generic (dInitFile : string := "d_memory_lab2.mif";
             iInitFile : string := "i_memory_lab2.mif");
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);

		--REMOVE
	next_status : out std_logic_vector(3 downto 0);
	status : out std_logic_vector(3 downto 0);
	opcode_status : out std_logic_vector(3 downto 0);
	data_coming_out : out std_logic_vector(11 downto 0);

        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        aluOut2seg         : out STD_LOGIC_VECTOR(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        ds2seg             : out std_logic_vector(7 downto 0)
    );
end EDA322_processor;

architecture structural of EDA322_processor is


--Memory (I&D) Declaration
component memory is
    generic (
	DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 8;
        INIT_FILE  : string := "d_memory_lab2.mif");
    port (
        clk        : in std_logic;
        readEn     : in std_logic;
        writeEn    : in std_logic;
        address    : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        dataIn     : in std_logic_vector(DATA_WIDTH-1 downto 0);
        dataOut    : out std_logic_vector(DATA_WIDTH-1 downto 0));
end component;


--Register Declaration
component reg is
    generic (
	REG_WIDTH: integer := 1);
    port (
        clk       : in std_logic;
        resetn    : in std_logic;
        loadEnable: in std_logic;
        dataIn    : in std_logic_vector(REG_WIDTH-1 downto 0);
        dataOut   : out std_logic_vector(REG_WIDTH-1 downto 0));
end component;


--ALU Declaration
component alu_wRCA is
    port(
        alu_inA: in std_logic_vector(7 downto 0);
	alu_inB: in std_logic_vector(7 downto 0);
        alu_op : in std_logic_vector(1 downto 0);
        alu_out: out std_logic_vector(7 downto 0);
        C      : out std_logic;
        E      : out std_logic;
        Z      : out std_logic);
end component;


--Bus Declaration
component proc_bus is
    port (
        decoEnable : in std_logic;
        decoSel    : in std_logic_vector(1 downto 0);
        imDataOut  : in std_logic_vector(7 downto 0);
        dmDataOut  : in std_logic_vector(7 downto 0);
        accOut     : in std_logic_vector(7 downto 0);
        extIn      : in std_logic_vector(7 downto 0);
        busOut     : out std_logic_vector(7 downto 0));
end component;


--RCA Declaration
component rca is
    port(
        a, b : in std_logic_vector(7 downto 0);
        cin  : in std_logic;
        cout : out std_logic;
        s    : out std_logic_vector(7 downto 0));
end component;

--Mux2 declaration
component mux2 is
    generic (d_width: integer := 8);
    port (
        s  : in std_logic;
        i0 : in std_logic_vector(d_width-1 downto 0);
        i1 : in std_logic_vector(d_width-1 downto 0);
        o  : out std_logic_vector(d_width-1 downto 0));
end component;


--ontroller Declaration
component proc_controller is
    port (
        clk: in std_logic;
        resetn: in std_logic;
        master_load_enable: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        e_flag: in std_logic;
        z_flag: in std_logic;
	
	next_status: out std_logic_vector(3 downto 0);
	status: out std_logic_vector(3 downto 0);
	opcode_status : out std_logic_vector(3 downto 0);

        decoEnable: out std_logic;
        decoSel: out std_logic_vector(1 downto 0);
        pcSel: out std_logic;
        pcLd: out std_logic;
        imRead: out std_logic;
        dmRead: out std_logic;
        dmWrite: out std_logic;
        aluOp: out std_logic_vector(1 downto 0);
        flagLd: out std_logic;
        accSel: out std_logic;
        accLd: out std_logic;
        dsLd: out std_logic);
end component;

--INTERNAL SIGNALS LIST
--I/O signals from Controller
SIGNAL decoEnable  : std_logic;
SIGNAL decoSel     : std_logic_vector(1 DOWNTO 0);
SIGNAL pcSel       : std_logic;
SIGNAL pcLd        : std_logic;
SIGNAL imRead      : std_logic; 
SIGNAL dmRead      : std_logic;
SIGNAL dmWrite     : std_logic; 
SIGNAL aluOP       : std_logic_vector(1 DOWNTO 0);
SIGNAL flagLd      : std_logic; --Should there be 1 for each flag? C,E,Z
SIGNAL accSel      : std_logic;
SIGNAL accLd       : std_logic; 
SIGNAL dsLd        : std_logic;

--Output from bus
SIGNAL busOut    : std_logic_vector(7 DOWNTO 0);

--Data out from memories
SIGNAL imDataOut: std_logic_vector(11 DOWNTO 0);
SIGNAL dmDataOut : std_logic_vector(7 DOWNTO 0);

--I/O from ALU and ACC
SIGNAL aluOut    : std_logic_vector(7 DOWNTO 0);
SIGNAL accMuxOut : std_logic_vector(7 DOWNTO 0);
SIGNAL accOut    : std_logic_vector(7 DOWNTO 0);

--I/O for PC Mux
SIGNAL pcIncrOut : std_logic_vector(7 DOWNTO 0):= "00000001"; --Look over these
SIGNAL jumpAddr  : std_logic_vector(7 DOWNTO 0);
SIGNAL nextPC    : std_logic_vector(7 DOWNTO 0):= "00000001"; --Look over these
SIGNAL pcOut     : std_logic_vector(7 DOWNTO 0):= "00000001"; --Look over these

SIGNAL concatenated_signal : std_logic_vector(7 downto 0);



--Flag signals
SIGNAL E: std_logic;
SIGNAL C: std_logic;
SIGNAL Z: std_logic;
SIGNAL flag: std_logic;
SIGNAL E_to_cont: std_logic;
SIGNAL C_to_cont: std_logic;
SIGNAL Z_to_cont: std_logic;

SIGNAL b_temp: std_logic_vector(7 DOWNTO 0);

BEGIN
--Controller
controller : proc_controller
	port map(
	--IN
	clk        => clk,
	resetn     => resetn,
	master_load_enable => master_load_enable,
	opcode     => imDataOut(11 downto 8),
	e_flag     => E_to_cont,        --TODO
	z_flag     => Z_to_cont,        --TODO
	--OUT
	status => status,
	next_status => next_status,	
	opcode_status => opcode_status,

	decoEnable => decoEnable,       
        decoSel    => decoSel,        
        pcSel      => pcSel,       
        pcLd       => pcLd,        
        imRead     => imRead,        
        dmRead     => dmRead,       
        dmWrite    => dmWrite,        
        aluOp      => aluOP,        
        flagLd     => flagLd,      --TODO, see signal declaration
        accSel     => accSel,     
        accLd      => accLd,       
        dsLd       => dsLd         
);
	
--Instruction Memory
instruction_memory : memory
	generic map (
        DATA_WIDTH => 12,
        ADDR_WIDTH => 8,
        INIT_FILE  => iInitFile
      	)
	port map (
	clk     => clk,
        readEn  => imRead,          
        writeEn => '0',             --ROM
        address => pcOut,
        dataIn  => "000000000000",  --ROM, does not matter since writeEn = '0'
        dataOut => imDataOut      
);


--Data Memory
data_memory : memory
	generic map (
        DATA_WIDTH => 8,
        ADDR_WIDTH => 8,
        INIT_FILE  => dInitFile
      	)
	port map (
	clk     => clk,
        readEn  => dmRead,
        writeEn => dmWrite, 
        address => busOut,   
        dataIn  => accOut,  
        dataOut => dmDataOut
);


--ALU
alu : alu_wRCA
        port map(
        alu_inA => accOut,
	alu_inB => busOut,
        alu_op  => aluOp,  
        alu_out => aluOut, 
       	C       => C,
        E       => E,
        Z       => Z
);


--DS
DS : reg
	generic map(
	REG_WIDTH => 8
	)
	port map(
        clk        => clk,
        resetn     => resetn,
        loadEnable => dsLd, 
        dataIn     => accOut,
        dataOut    => ds2seg
);


--PC
PC : reg
	generic map(REG_WIDTH => 8)
	port map(
        clk        => clk,
        resetn     => resetn,	
        loadEnable => pcLd,
        dataIn     => nextPC,
        dataOut    => pcOut
);

--ACC
ACC : reg
	generic map(REG_WIDTH => 8)
	port map(
        clk        => clk,
        resetn     => resetn,     
        loadEnable => accLd,
        dataIn     => accMuxOut,
        dataOut    => accOut
);

--E reg
regE : reg
	generic map(REG_WIDTH => 1)
	port map(
        clk        => clk,
        resetn     => resetn,     
        loadEnable => flagLd,
        dataIn(0)     => E,
        dataOut(0)    => E_to_cont
);

--C reg
regC : reg
	generic map(REG_WIDTH => 1)
	port map(
        clk        => clk,
        resetn     => resetn,     
        loadEnable => flagLd,
        dataIn(0)     => C,
        dataOut(0)    => flag --flag unnessecary, can remove, carry unused
);

--Z reg
regZ : reg
	generic map(REG_WIDTH => 1)
	port map(
        clk        => clk,
        resetn     => resetn,     
        loadEnable => flagLd,
        dataIn(0)     => Z,
        dataOut(0)    => Z_to_cont
);

--Bus
internal_bus : proc_bus 
    port map (
        decoEnable => decoEnable,
        decoSel    => decoSel,	  
        imDataOut  => imDataOut(7 downto 0),
        dmDataOut  => dmDataOut,
        accOut     => accOut,
        extIn      => extIn,
        busOut     => busOut      
);

--Multiplexer for ALU
MuxACC : mux2
    generic map(d_width => 8)
    port map(
        s  => accSel,  
        i0 => aluOut,  --Make sure the inputs are connected right
        i1 => busOut,  --Make sure the inputs are connected right
        o  => accMuxOut
);

--Multiplexer for PC
MuxPC : mux2
    generic map(d_width => 8)
    port map(
        s  => pcSel,     
        i0 => pcIncrOut,--pcIncrOut --Make sure the inputs are connected right
        i1 => jumpAddr,  --Make sure the inputs are connected right
        o  => nextPC       
);

--RCA +
adder : rca
   	port map(
        a    => pcOut,
	b    => "00000001", --Increment by one
        cin  => '0',        --No carry in
        cout => OPEN,       --No carry out
        s    => pcIncrOut
);



concatenated_signal <= "0" & busOut(6 downto 0);
b_temp <= concatenated_signal WHEN busOut(7) = '0' else not concatenated_signal;

adderJump : rca
	port map(
        a    => pcOut,
	b    => b_temp,
        cin  => busOut(7),        
        cout => OPEN,  
        s    => jumpAddr
);
pc2seg <= pcOut;
imDataOut2seg   <= imDataOut;
dmDataOut2seg <= dmDataOut;
aluOut2seg <= aluOut;
acc2seg  <= accOut;
busOut2seg <=  busOut;
    
--DEBUG
data_coming_out <= imDataOut;

end structural;