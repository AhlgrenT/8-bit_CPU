library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;


entity proc_controller is
    port (
        clk: in std_logic;
        resetn: in std_logic;
        master_load_enable: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        e_flag: in std_logic;
        z_flag: in std_logic;

		--REMOVE
	next_status: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	status: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	opcode_status: out STD_LOGIC_VECTOR(3 DOWNTO 0);


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
        dsLd: out std_logic
    );
end proc_controller;

architecture Behavioural of proc_controller is

type state_type is (FE, DE1, DE2, EX, ME);
signal curr_state: state_type := FE;
signal next_state: state_type;

begin

state_register: process (clk, resetn)
    begin
        if resetn = '0' then
            curr_state <= FE; 
        elsif rising_edge(clk) and master_load_enable = '1' then
            	curr_state <= next_state;
        end if;
    end process state_register;

next_state_logic: process(curr_state, opcode)
begin
	case curr_state is
        when FE =>        
	    next_state <= DE1; 

	when DE1 =>
            case opcode is
	    when O_NOOP =>
		next_state <= FE;
	    when O_CMP | O_AND | O_ADD | O_SUB | O_LB =>
		next_state <= EX;
	    when O_IN | O_DS | O_MOV | O_ROL | O_JE | O_JNE | O_JZ => 
		next_state <= EX;
	    when O_SB => 
		next_state <= ME;
 	    when O_SBI =>
		next_state <= ME;
	    when O_LBI =>
		next_state <= DE2;
	    when OTHERS =>  --Unreachable state (?)
		--next_state <= DE1; --Remain in same state!
	    end case;

        when DE2 =>
            next_state <= EX;

	when EX =>
            next_state <= FE;
	    
	when ME =>
		next_state <= FE;
	   
        end case;
end process next_state_logic;

output_logic : process(curr_state, opcode, master_load_enable, e_flag, z_flag)
begin

    if master_load_enable = '1' then
	decoEnable <= '0';
	decoSel <= "00";
	pcSel <= '0';
	aluOp <= "00";
	accSel <= '0';
	case curr_state is
        when FE =>         
	    imRead <= '1';
	    pcLd <= '1';   

	when DE1 =>
            case opcode is
	    when O_NOOP =>
		
	    when O_CMP | O_AND | O_ADD | O_SUB | O_LB =>
		dmRead <= '1';
		decoEnable <= '1';
		
	    when O_IN | O_DS | O_MOV | O_ROL | O_JE | O_JNE | O_JZ =>
		
	    when O_SB =>  --no ctrl signals
		
 	    when O_SBI =>
		dmRead  <= '1';
		decoEnable <= '1';
		
	    when O_LBI =>
		dmRead <= '1';
		decoEnable <= '1';
	    when OTHERS =>
	    end case;

        when DE2 =>
	    dmRead <= '1';
	    decoEnable <= '1';
	    decoSel <= "01";

	when EX =>
	    case opcode is
	    when O_IN =>
		decoEnable <= '1';
		decoSel <= "11";
		accSel <= '1';
		accLd <= '1';

	    when O_DS =>
		dsLd <= '1';
          
	    when O_MOV =>
		decoEnable <= '1';
		accSel <= '1';
		accLd <= '1';

	    when O_JE =>
		if (e_flag = '1') then
			decoEnable <= '1';
			pcSel <= '1';
			pcLd <= '1';
		end if;
	    when O_JNE =>
		if (e_flag = '0') then
			decoEnable <= '1';
			pcSel <= '1';
			pcLd <= '1';
		end if;
	    when O_JZ => 
		if (z_flag = '1') then   
			decoEnable <= '1';
			pcSel <= '1';
			pcLd <= '1';
		end if;
	    when O_CMP =>
		decoEnable <= '1';
		decoSel <= "01";
		flagLd <= '1';

	    when O_ROL =>	
		flagLd <= '1';
		accLd <= '1';

	    when O_AND =>
		decoEnable <= '1';
		decoSel <= "01";
		aluOp <= "01";
		flagLd <= '1';
		accLd <= '1';

	    when O_ADD =>
		decoEnable <= '1';
		decoSel <= "01";
		aluOp <= "10";
		flagLd <= '1';
		accLd <= '1';

	    when O_SUB =>
		decoEnable <= '1';
		decoSel <= "01";
		aluOp <= "11";
		flagLd <= '1';
		accLd <= '1';

	    when O_LB | O_LBI =>
		decoEnable <= '1';
		decoSel <= "01";
		accSel <= '1';
		accLd <= '1';
	    when OTHERS =>
	    end case;
          
	    

	when ME =>
	    case opcode is
	    when O_SB =>
	    	decoEnable <= '1';
	    	dmWrite <= '1';		
	    when O_SBI =>
	    	decoEnable <= '1';
	    	decoSel <= "01";
	    	dmWrite <= '1';
	    when OTHERS =>
	    end case;
	when OTHERS =>
        end case;
    else 
		pcLd    <= '0';
		imRead  <= '0';
		dmRead  <= '0';
        	dmWrite <= '0';
        	flagLd  <= '0';
        	accLd   <= '0';
        	dsLd    <= '0'; 
    end if;
end process output_logic;




----------------------------------------------------------
status <=
	"0001" WHEN curr_state = FE ELSE
	"0010" WHEN curr_state = DE1 ELSE
	"0011" WHEN curr_state = DE2 ELSE
	"0100" WHEN curr_state = EX ELSE
	"0101" WHEN curr_state = ME ELSE
	"1111";
next_status <=
	"0001" WHEN next_state = FE ELSE
	"0010" WHEN next_state = DE1 ELSE
	"0011" WHEN next_state = DE2 ELSE
	"0100" WHEN next_state = EX ELSE
	"0101" WHEN next_state = ME ELSE
	"1111";
opcode_status <= opcode;

end Behavioural;