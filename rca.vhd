library ieee;
use ieee.std_logic_1164.all;

entity rca is
    port(
        a, b: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic_vector(7 downto 0)
    );
end rca;




ARCHITECTURE STRUCTURAL OF RCA IS

 	component fa is
	PORT(
		a, b: IN STD_LOGIC;
		cin: IN STD_LOGIC;
		cout: OUT STD_LOGIC;
		s: OUT STD_LOGIC
	);
	END COMPONENT;

signal carry_signals: STD_LOGIC_VECTOR(7 DOWNTO 0);


BEGIN
	gen_fa_1: fa
   	port map(
        a => b(0),
	b => a(0),
        cin => cin,
        cout => carry_signals(0),
        s => s(0)
   	);

		
	gen_fa: for i in 1 to 7 generate
		fa_inst: fa port map(a(i), b(i), carry_signals(i-1), carry_signals(i), s(i));
	end generate gen_fa;

	cout <= carry_signals(7);

END STRUCTURAL;