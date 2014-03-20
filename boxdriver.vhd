-- Quartus II VHDL Template
-- Boxdriver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity boxdriver is

	port 
	(
		a	   : in unsigned  (3 downto 0);
		result : out unsigned (6 downto 0)
	);

end entity;

architecture rtl of boxdriver is
begin
--result is 7 segment display "0123456"
--   0
-- 5   1
--   6
-- 4   2
--   3
result <= "1000000" when a = "0000" else--0
			"1111001" when a = "0001" else--1
			"0100100" when a = "0010" else--2
			"0110000" when a = "0011" else--3
			"0011001" when a = "0100" else--4
			"0010010" when a = "0101" else--5
			"0000010" when a = "0110" else--6
			"1111000" when a = "0111" else--7
			"0000000" when a = "1000" else--8
			"0011000" when a = "1001" else--9
			"0001000" when a = "1010" else--A
			"0000011" when a = "1011" else--b
			"1000110" when a = "1100" else--C
			"0100001" when a = "1101" else--d
			"0000110" when a = "1110" else--E
			"0001110" when a = "1111" else--F
			"0000001";--default

end rtl;
