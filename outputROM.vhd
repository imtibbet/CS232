-- Ian Tibbetts and Ryan Newell
-- Project 5 Generated ROM
-- Due: Mar 21, 2014
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity outputROM is
  port (
    addr : in std_logic_vector (7 downto 0);
    data : out std_logic_vector (9 downto 0));
end entity;

architecture rtl of outputROM is

begin

data <= 
-- ON
"0001110000" when addr = "00000000" else -- ON
-- SHIFT_LEFT
"0000010000" when addr = "00000001" else -- SHIFT_LEFT
"0101000000" when addr = "00000010" else -- SHIFT_LEFT
"0001000000" when addr = "00000011" else -- SHIFT_LEFT
-- SHIFT_LEFT
"0000010000" when addr = "00000100" else -- SHIFT_LEFT
"0101000000" when addr = "00000101" else -- SHIFT_LEFT
"0001000000" when addr = "00000110" else -- SHIFT_LEFT
-- ROTATE_RIGHT
"0000010000" when addr = "00000111" else -- ROTATE_RIGHT
"0111100000" when addr = "00001000" else -- ROTATE_RIGHT
"0001000000" when addr = "00001001" else -- ROTATE_RIGHT
-- SHIFT_LEFT
"0000010000" when addr = "00001010" else -- SHIFT_LEFT
"0101000000" when addr = "00001011" else -- SHIFT_LEFT
"0001000000" when addr = "00001100" else -- SHIFT_LEFT
-- SHIFT_RIGHT
"0000010000" when addr = "00001101" else -- SHIFT_RIGHT
"0101100000" when addr = "00001110" else -- SHIFT_RIGHT
"0001000000" when addr = "00001111" else -- SHIFT_RIGHT
-- ROTATE_LEFT
"0000010000" when addr = "00010000" else -- ROTATE_LEFT
"0111000000" when addr = "00010001" else -- ROTATE_LEFT
"0001000000" when addr = "00010010" else -- ROTATE_LEFT
-- OFF
"0000110000" when addr = "00010011" else -- OFF
"0110011000" when addr = "00010100" else -- OFF
"0001000000" when addr = "00010101" else -- OFF
-- DO_8
"0101000100" when addr = "00010110" else -- shift left loop register
"0101000100" when addr = "00010111" else -- shift left loop register
"0101000100" when addr = "00011000" else -- shift left loop register
"0101000100" when addr = "00011001" else -- shift left loop register
"0101000100" when addr = "00011010" else -- shift left loop register
"0100010101" when addr = "00011011" else -- increment loop register by 1
"0101000100" when addr = "00011100" else -- shift left loop register
"0101000100" when addr = "00011101" else -- shift left loop register
"0101000100" when addr = "00011110" else -- shift left loop register
-- ON
"0001110000" when addr = "00011111" else -- ON
-- OFF
"0000110000" when addr = "00100000" else -- OFF
"0110011000" when addr = "00100001" else -- OFF
"0001000000" when addr = "00100010" else -- OFF
-- LOOP
"0100110101" when addr = "00100011" else -- decrement loop register by 1
"1100100110" when addr = "00100100" else -- break when LOOP is zero
"0000011111" when addr = "00100101" else -- branch unconditional to top of loop otherwise
"0000000000"; 

end rtl;
