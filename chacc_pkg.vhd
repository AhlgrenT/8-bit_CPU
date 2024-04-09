library ieee;
use ieee.std_logic_1164.all;

package chacc_pkg is

    -- Package containing a lot of useful constants for the creation of the ChAcc processor

    -- OPCODES
    subtype op_t is std_logic_vector(3 downto 0);
    constant O_NOOP: op_t := "0000";
    constant O_IN  : op_t := "0001";
    constant O_DS  : op_t := "0010";
    constant O_MOV : op_t := "0011";
    constant O_JE  : op_t := "0100";
    constant O_JNE : op_t := "0101";
    constant O_JZ  : op_t := "0110";
    constant O_CMP : op_t := "0111";
    constant O_ROL : op_t := "1000";
    constant O_AND : op_t := "1001";
    constant O_ADD : op_t := "1010";
    constant O_SUB : op_t := "1011";
    constant O_LB  : op_t := "1100";
    constant O_SB  : op_t := "1101";
    constant O_LBI : op_t := "1110";
    constant O_SBI : op_t := "1111";

    -- BUS states
    subtype bsel_t is std_logic_vector(1 downto 0);
    constant B_IMEM : bsel_t := "00";
    constant B_DMEM : bsel_t := "01";
    constant B_ACC  : bsel_t := "10";
    constant B_EXT  : bsel_t := "11";

    -- ALU OPs
    subtype alu_t is std_logic_vector(1 downto 0);
    constant A_ROL : alu_t := "00";
    constant A_AND : alu_t := "01";
    constant A_ADD : alu_t := "10";
    constant A_SUB : alu_t := "11";

end package chacc_pkg;
