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
		clkT		: in	std_logic;
		resetT	 	: in	std_logic;
		shiftLeftBtn	: in std_logic;
		shiftRightBtn 	: in std_logic;
		rotateLeftBtn	: in std_logic;
		rotateRightBtn 	: in std_logic;
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
	signal counter : unsigned(10 downto 0);
	signal vgaClock : std_logic;
	signal slowclock : std_logic;

	constant blockSize : integer := 30;
	constant zeros : std_logic_vector(11 downto 0) := (others=>'0');
	constant blockWidth : integer := 600/blockSize;
	constant blockHeight : integer := 450/blockSize;
	--A 2-d array declaration, from http://vhdlguru.blogspot.com/2010/02/arrays-and-records-in-vhdl.html
	type rowBlocks is array (0 to blockHeight) of std_logic_vector(11 downto 0); -- 12 bit vector in each cell, 4 bits per color
	type columnBlocks is array (0 to blockWidth) of rowBlocks; 
	signal blockGrid : columnBlocks;-- := --blockGrid is a row*column two dimensional array.
--							 ((others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')),
--							  (others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')),
--							  (others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')));

	--tetris variables for recording player actions
	variable shiftLeft : std_logic;
	variable shiftRight : std_logic;
	variable rotateLeft : std_logic;
	variable rotateRight : std_logic;
begin
	VGA: vgaDriver
		port map(clk => vgaClock, reset => resetT, 
			hsync => hsyncT, vsync => vsyncT, 
			hcounter => hcounterT, vcounter => vcounterT);

	column <= hcounterT - 138;
	row <= vcounterT - 35;
	
	--process to slow set player actions
	process (shiftLeftBtn, shiftRightBtn, rotateLeftBtn, rotateRightBtn)
	begin
		if (falling_edge(shiftLeftBtn)) and shiftRight = '0' and rotateLeft = '0' and rotateRight = '0' then
			shiftLeft <= '1';
		elsif (falling_edge(shiftRightBtn)) and shiftLeft = '0' and rotateLeft = '0' and rotateRight = '0' then
			shiftRight <= '1';
		elsif (falling_edge(rotateLeftBtn)) and shiftLeft = '0' and shiftRight = '0' and rotateRight = '0' then
			rotateLeft <= '1';
		elsif (falling_edge(rotateRightBtn)) and shiftLeft = '0' and shiftRight = '0' and rotateLeft = '0' then
			rotateRight <= '1';
		end if;
	end process;
	
	--process to slow 50MHz clock to 25MHz
	process (clkT)
	begin
		if (rising_edge(clkT)) then
			counter <= counter + 1;
		end if;
	end process;
	vgaClock <= std_logic(counter(0));
	slowclock <= std_logic(counter(7));-- picked 7 arbitrarily, need a state machine clock
	
	-- needs to change to clear dynamically based on array lengths, will be loops
	process (slowclock, resetT)
	begin
		if resetT = '0' then
			--reset all blocks to zeros.
			for i in 0 to blockWidth loop
				for j in 0 to blockHeight loop
					blockGrid(i)(j) <= zeros;
				end loop;
			end loop;
		elsif rising_edge(slowclock) then
			--state machine for the game of tetris
			--have to evaluate the board for generating new blocks
			--and clearing lines, then move b
		end if;
	end process;

	process (column, row)
	begin
		
		--useable area on screen, all pixels will be turned on from here
		if column >= 0 and column < 640 then
			if row >= 0 and row < 480 then
				--initially off
				blueOut <= "0000";	
				
				-- on for border
				if column = 0 or column = 639 or row = 0 or row = 479 then
					blueOut <= "1001";
				end if;
				
				-- turn valid blocks on
				for i in 0 to blockWidth loop
					for j in 0 to blockHeight loop
						if column > 1+(i*blockSize) and column < ((i+1)*blockSize) and row > 1+(j*blockSize) and row < ((j+1)*blockSize) then
							blueOut <= "1001"; --<= blockGrid(i)(j)(3 downto 0)
							--greenOut <= blockGrid(i)(j)(7 downto 4)
							--redOut <= blockGrid(i)(j)(11 downto 8)
						end if;
					end loop;
				end loop;
				
			--not useable area
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

end rtl;
