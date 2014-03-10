library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lightrom is

  port 
  (
    addr    : in std_logic_vector (5 downto 0);
	 data    : out std_logic_vector (3 downto 0)
  );

end entity;

architecture rtl of lightrom is

begin

--uncomment below to see the given testing program
--data(2 downto 0) <= 
--      "000" when addr(3 downto 0) = "0000" else -- move 0s to LR  00000000
--      "101" when addr(3 downto 0) = "0001" else -- bit invert LR  11111111
--      "101" when addr(3 downto 0) = "0010" else -- bit invert LR  00000000
--      "101" when addr(3 downto 0) = "0011" else -- bit invert LR  11111111
--      "001" when addr(3 downto 0) = "0100" else -- shift LR right 01111111
--      "001" when addr(3 downto 0) = "0101" else -- shift LR right 00111111
--      "111" when addr(3 downto 0) = "0110" else -- rotate LR left 01111110
--      "111" when addr(3 downto 0) = "0111" else -- rotate LR left 11111100
--      "111" when addr(3 downto 0) = "1000" else -- rotate LR left 11111001
--      "111" when addr(3 downto 0) = "1001" else -- rotate LR left 11110011
--      "010" when addr(3 downto 0) = "1010" else -- shift LR left  11100110
--      "010" when addr(3 downto 0) = "1011" else -- shift LR left  11001100
--      "011" when addr(3 downto 0) = "1100" else -- add 1 to LR    11001101
--      "100" when addr(3 downto 0) = "1101" else -- sub 1 from LR  11001100
--      "101" when addr(3 downto 0) = "1110" else -- bit invert LR  00110011
--      "011";                        -- add 1 to LR    00110100

----------------------------------------------------------------------------

----uncomment below to see CS232 displayed in morse code
----two pauses between letters
--data <=
----init
--	"0000" when addr = "000000" else -- move 0s to LR
----C
--	"1000" when addr = "000001" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "000010" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "000011" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "000100" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "000101" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "000110" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "000111" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "001000" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "001001" else -- shift LR left, pushing a 1 on right
----space
--	"0010" when addr = "001010" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "001011" else -- shift LR left, pushing a 0 on right
----S
--	"1000" when addr = "001100" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "001101" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "001110" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "001111" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "010000" else -- shift LR left, pushing a 1 on right
----space
--	"0010" when addr = "010001" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "010010" else -- shift LR left, pushing a 0 on right
----2
--	"1000" when addr = "010011" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "010100" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "010101" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "010110" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "010111" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "011000" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "011001" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "011010" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "011011" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "011100" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "011101" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "011110" else -- shift LR left, pushing a 1 on right
----space
--	"0010" when addr = "011111" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "100000" else -- shift LR left, pushing a 0 on right
----3
--	"1000" when addr = "100001" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "100010" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "100011" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "100100" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "100101" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "100110" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "100111" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "101000" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "101001" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "101010" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "101011" else -- shift LR left, pushing a 1 on right
----space
--	"0010" when addr = "101100" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "101101" else -- shift LR left, pushing a 0 on right
----2
--	"1000" when addr = "101110" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "101111" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "110000" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "110001" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "110010" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "110011" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "110100" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "110101" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "110110" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "110111" else -- shift LR left, pushing a 0 on right
--	"1000" when addr = "111000" else -- shift LR left, pushing a 1 on right
--	"1000" when addr = "111001" else -- shift LR left, pushing a 1 on right
----end
--	"0010";
----	"0010" when addr = "111010" else -- shift LR left, pushing a 0 on right
----	"0010" when addr = "111011" else -- shift LR left, pushing a 0 on right
----	"0010" when addr = "111100" else -- shift LR left, pushing a 0 on right
----	"0010" when addr = "111101" else -- shift LR left, pushing a 0 on right
----	"0010" when addr = "111110" else -- shift LR left, pushing a 0 on right
----	"0010" when addr = "111111" else -- shift LR left, pushing a 0 on right

--------------------------------------------------------------------------

--uncomment below to see I love cs
--two pauses between letters
--three pauses between words
data <=
--init
	"0000" when addr = "000000" else -- move 0s to LR
--I
	"1000" when addr = "000001" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "000010" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "000011" else -- shift LR left, pushing a 1 on right
--slash
	"0010" when addr = "000100" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "000101" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "000110" else -- shift LR left, pushing a 1 on right
--love
--l
	"1000" when addr = "000111" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "001000" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "001001" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "001010" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "001011" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "001100" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "001101" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "001110" else -- shift LR left, pushing a 1 on right
--space
	"0010" when addr = "001111" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "010000" else -- shift LR left, pushing a 1 on right
--o
	"1000" when addr = "010001" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "010010" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "010011" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "010100" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "010101" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "010110" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "010111" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "011000" else -- shift LR left, pushing a 1 on right
--space
	"0010" when addr = "011001" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "011010" else -- shift LR left, pushing a 1 on right
--v
	"1000" when addr = "011011" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "011100" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "011101" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "011110" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "011111" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "100000" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "100001" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "100010" else -- shift LR left, pushing a 0 on right
--space
	"0010" when addr = "100011" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "100100" else -- shift LR left, pushing a 0 on right
--e
	"1000" when addr = "100101" else -- shift LR left, pushing a 1 on right
--slash
	"0010" when addr = "100110" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "100111" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "101000" else -- shift LR left, pushing a 1 on right
--cs
--c
	"1000" when addr = "101001" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "101010" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "101011" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "101100" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "101101" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "101110" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "101111" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "110000" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "110001" else -- shift LR left, pushing a 0 on right
--space
	"0010" when addr = "110010" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "110011" else -- shift LR left, pushing a 1 on right
--s
	"1000" when addr = "110100" else -- shift LR left, pushing a 0 on right
	"0010" when addr = "110101" else -- shift LR left, pushing a 1 on right
	"1000" when addr = "110110" else -- shift LR left, pushing a 1 on right
	"0010" when addr = "110111" else -- shift LR left, pushing a 0 on right
	"1000" when addr = "111000" else -- shift LR left, pushing a 1 on right
--end
	"0010";
-- when addr = "111001" else -- shift LR left, pushing a 1 on right
--	"0010" when addr = "111010" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "111011" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "111100" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "111101" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "111110" else -- shift LR left, pushing a 0 on right
--	"0010" when addr = "111111" else -- shift LR left, pushing a 0 on right
end rtl;