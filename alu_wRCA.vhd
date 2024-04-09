library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity alu_wRCA is
    port(
        alu_inA: in std_logic_vector(7 downto 0);
	alu_inB: in std_logic_vector(7 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        alu_out: out std_logic_vector(7 downto 0);
        C: out std_logic;
        E: out std_logic;
        Z: out std_logic
    );
end alu_wRCA;

ARCHITECTURE dataflow OF alu_wRCA IS

	component rotateleft is
	PORT(
		a: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		r: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END COMPONENT;
	
	component rca is
	PORT(
		a, b: in std_logic_vector(7 downto 0);
        	cin: in std_logic;
        	cout: out std_logic;
        	s: out std_logic_vector(7 downto 0)
	);
	END COMPONENT;

	COMPONENT cmp IS
	PORT(
		 a: in   std_logic_vector (7 downto 0);
           	 b: in   std_logic_vector (7 downto 0);
    	   	 e: out  std_logic
	);
	END COMPONENT;

	SIGNAL rotTemp : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL andTemp : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL addTemp : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	SIGNAL tempAlu_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL cin_temp : STD_LOGIC;
	SIGNAL b_temp: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN

	cmp_0: cmp
   	port map(
        	a => alu_inA,
		b => alu_inB,
		e => E
   	);

	rotateleft_0: rotateleft
   	port map(
        	a => alu_inA,
		r => rotTemp
   	);

	rca_0: rca
	port map(
		a => alu_inA,
		b => b_temp,
		cin => cin_temp, 
		cout => C,
		s => addTemp
	);
	
	b_temp <= not alu_inB WHEN alu_op = "11" ELSE alu_inB;
	cin_temp <= alu_op(0);
	

	
	--4-to-1 muliplexer
	 WITH alu_op SELECT tempAlu_out <=
            rotTemp WHEN "00",
            alu_inA AND alu_inB WHEN "01",
            addTemp WHEN "10",
            addTemp WHEN OTHERS;
	

	Z <= not OR_REDUCE(tempAlu_out);
	alu_out <= tempAlu_out;
	

END dataflow;


