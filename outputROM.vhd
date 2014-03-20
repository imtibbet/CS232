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
"0001110000" when addr = "00000000" else -- move all 1's into LR
-- SHIFT_LEFT
"0000010000" when addr = "00000001" else -- move LR to ACC
"0101000000" when addr = "00000010" else -- shift ACC left
"0001000000" when addr = "00000011" else -- move ACC to LR
-- DO_20
"0010100100" when addr = "00000100" else -- set low 4 bits of ACC
"0011100001" when addr = "00000101" else -- set high 4 bits of ACC
"0110000100" when addr = "00000110" else -- move ACC into LOOP
-- ROTATE_LEFT
"0000010000" when addr = "00000111" else -- move LR to ACC
"0111000000" when addr = "00001000" else -- rotate ACC left
"0001000000" when addr = "00001001" else -- move ACC to LR
-- LOOP
"0100110101" when addr = "00001010" else -- decrement loop register by 1
"1100001101" when addr = "00001011" else -- break when LOOP is zero
"1000000111" when addr = "00001100" else -- branch unconditional to top of loop otherwise
"1000000000"; -- branch to beginning when no more instructions

end rtl;
