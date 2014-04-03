-- Bruce A. Maxwell
-- Spring 2013
-- CS 232
--
-- test program for the memory circuit
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity membench is
end entity;

architecture test of membench is
  constant num_cycles : integer := 100;

  -- this circuit just needs a clock and a reset
  signal clk : std_logic := '1';
  signal reset : std_logic;

  -- lights component
  component memtest
    port( clk, reset : in std_logic;
          output     : out std_logic_vector(7 downto 0) );
  end component;

  -- output signals
  signal output : std_logic_vector(7 downto 0);

begin

  -- start off with a short reset
  reset <= '1', '0' after 1 ns;

  -- create a clock
  process begin
    for i in 1 to num_cycles loop
      clk <= not clk;
      wait for 1 ns;
      clk <= not clk;
      wait for 1 ns;
    end loop;
    wait;
  end process;

  -- port map the circuit
  L0: memtest port map( clk, reset, output );

end test;
