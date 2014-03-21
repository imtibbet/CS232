-- Ian Tibbetts and Ryan Newell
-- Project 5 programFlashAlternatingLoop.vhd
-- Due: Mar 21, 2014
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity programFlashAlternatingLoop is
  port (
    addr : in std_logic_vector (7 downto 0);
    data : out std_logic_vector (9 downto 0));
end entity;

architecture rtl of programFlashAlternatingLoop is

begin

data <= 
-- ON
"0001110000" when addr = "00000000" else -- move all 1's into LR
-- OFF
"0000110000" when addr = "00000001" else -- move all 1's to ACC
"0110011000" when addr = "00000010" else -- xor ACC with all 1's
"0001000000" when addr = "00000011" else -- move ACC to LR
-- SET_10101010
"0010101010" when addr = "00000100" else -- set low 4 bits of ACC
"0011101010" when addr = "00000101" else -- set high 4 bits of ACC
"0001000000" when addr = "00000110" else -- move ACC to LR
-- DO_20
"0010100100" when addr = "00000111" else -- set low 4 bits of ACC
"0011100001" when addr = "00001000" else -- set high 4 bits of ACC
"0110000100" when addr = "00001001" else -- move ACC into LOOP
-- INVERT
"0000010000" when addr = "00001010" else -- move LR to ACC
"0110011000" when addr = "00001011" else -- xor ACC with all 1's
"0001000000" when addr = "00001100" else -- move ACC to LR
-- LOOP
"0100110101" when addr = "00001101" else -- decrement loop register by 1
"1100010000" when addr = "00001110" else -- break when LOOP is zero
"1000001010" when addr = "00001111" else -- branch unconditional to top of loop otherwise
"1000000000"; -- branch to beginning when no more instructions

end rtl;
