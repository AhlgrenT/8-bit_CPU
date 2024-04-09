library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--Generic tri-state-buffer
entity tri_state_buffer is
    Generic(
	DATA_WIDTH : INTEGER := 8
    );
    Port (
        input_signal 	 : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        enable		 : in STD_LOGIC;
        output_signal 	 : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
    );
end tri_state_buffer;

architecture Dataflow of tri_state_buffer is

begin
    output_signal <= input_signal when enable = '1' else (OTHERS => 'Z');
end Dataflow;
