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
-- INVERT
"0000010000" when addr = "00000001" else -- INVERT
"0110011000" when addr = "00000010" else -- INVERT
"0001000000" when addr = "00000011" else -- INVERT
-- INVERT
"0000010000" when addr = "00000100" else -- INVERT
"0110011000" when addr = "00000101" else -- INVERT
"0001000000" when addr = "00000110" else -- INVERT
-- OFF
"0000110000" when addr = "00000111" else -- OFF
"0110011000" when addr = "00001000" else -- OFF
"0001000000" when addr = "00001001" else -- OFF
-- SET_10101111
"0010101111" when addr = "00001010" else -- SET_10101111
"0011101010" when addr = "00001011" else -- SET_10101111
"0001000000" when addr = "00001100" else -- SET_10101111
-- DO_8
"0010101000" when addr = "00001101" else -- DO_8
"0011100000" when addr = "00001110" else -- DO_8
"0110011000" when addr = "00001111" else -- DO_8
"0110000100" when addr = "00010000" else -- DO_8
-- ON
"0001110000" when addr = "00010001" else -- ON
-- OFF
"0000110000" when addr = "00010010" else -- OFF
"0110011000" when addr = "00010011" else -- OFF
"0001000000" when addr = "00010100" else -- OFF
-- LOOP
"0100110101" when addr = "00010101" else -- decrement loop register by 1
"1100011000" when addr = "00010110" else -- break when LOOP is zero
"1000010001" when addr = "00010111" else -- branch unconditional to top of loop otherwise
"1000000000"; 

end rtl;
