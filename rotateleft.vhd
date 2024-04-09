library ieee;
use ieee.std_logic_1164.all;

entity rotateleft is
    port(   
    	    a: in   std_logic_vector (7 downto 0);
    	    r: out  std_logic_vector (7 downto 0)
   	);
end rotateleft;

ARCHITECTURE dataflow of rotateleft IS
BEGIN

		r(0) <= a(7);
		r(7 DOWNTO 1) <= a(6 DOWNTO 0);
END dataflow;