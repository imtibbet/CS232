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
-- DO_8
"0101000100" when addr = "00000000" else -- shift left loop register
"0101000100" when addr = "00000001" else -- shift left loop register
"0101000100" when addr = "00000010" else -- shift left loop register
"0101000100" when addr = "00000011" else -- shift left loop register
"0101000100" when addr = "00000100" else -- shift left loop register
"0100010101" when addr = "00000101" else -- increment loop register by 1
"0101000100" when addr = "00000110" else -- shift left loop register
"0101000100" when addr = "00000111" else -- shift left loop register
"0101000100" when addr = "00001000" else -- shift left loop register
-- ON
"0001110000" when addr = "00001001" else -- ON
-- OFF
"0000110000" when addr = "00001010" else -- OFF
"0110011000" when addr = "00001011" else -- OFF
"0001000000" when addr = "00001100" else -- OFF
-- LOOP
"0100110101" when addr = "00001101" else -- decrement loop register by 1
"1100010000" when addr = "00001110" else -- break when LOOP is zero
"0000001001" when addr = "00001111" else -- branch unconditional to top of loop otherwise
"0000000000"; 

end rtl;
