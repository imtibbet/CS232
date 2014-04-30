-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity finalProject is

	port(
		clkT		 : in	std_logic;
		resetT	 : in	std_logic;
		redOut	 : out	std_logic_vector(3 downto 0);
		greenOut : out	std_logic_vector(3 downto 0);
		blueOut	 : out	std_logic_vector(3 downto 0);
		hsyncT	 : out	std_logic;
		vsyncT	 : out	std_logic	
	);

end entity;

architecture rtl of finalProject is

component vgaDriver

	port
	(
		clk		 : in	std_logic;
		reset	 : in	std_logic;
		hsync	 : out	std_logic;
		vsync	 : out	std_logic;
		hcounter	 : out	integer;
		vcounter	 : out	integer
	);

end component;

	signal hcounterT : integer;
	signal vcounterT : integer;
	signal column : integer;
	signal row : integer;
	signal counter : unsigned(1 downto 0);
	signal slowclock : std_logic;
	
begin
	VGA: vgaDriver
		port map(clk => slowclock, reset => resetT, 
			hsync => hsyncT, vsync => vsyncT, 
			hcounter => hcounterT, vcounter => vcounterT);

	column <= hcounterT - 138;
	row <= vcounterT - 35;
			process (column, row)
			begin
				if column >= 0 and column < 640 then
					if row >= 0 and row < 480 then
					--useable area on screen, all pixels will be turned on from here
						redOut <= "1111";
					else
						redOut <= "0000";
						greenOut <= "0000";
						blueOut <= "0000";
					end if;
				else
					redOut <= "0000";
					greenOut <= "0000";
					blueOut <= "0000";
				end if;
			end process;
		
		
--process to slow 50MHz clock to 25MHz
	process (clkT)
	begin
		if (rising_edge(clkT)) then
			counter <= counter + 1;
		end if;
	end process;
	slowclock <= std_logic(counter(0));

end rtl;
