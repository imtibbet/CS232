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
	signal counter : unsigned(26 downto 0);
	signal sCounter : unsigned(27 downto 0);
	signal sWaitCounter : unsigned(27 downto 0);
	signal vgaClock : std_logic;
	signal slowclock : std_logic;

	constant blockSize : integer := 30;
	constant zeros : std_logic_vector(11 downto 0) := (others=>'0');
	constant blockWidth : integer := 640/blockSize-1;
	constant blockHeight : integer := 480/blockSize-2;
	--A 2-d array declaration, from http://vhdlguru.blogspot.com/2010/02/arrays-and-records-in-vhdl.html
	type rowBlocks is array (0 to blockHeight) of std_logic_vector(11 downto 0); -- 12 bit vector in each cell, 4 bits per color
	type columnBlocks is array (0 to blockWidth) of rowBlocks; 
	signal blockGrid : columnBlocks;-- := --blockGrid is a row*column two dimensional array.
--							 ((others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')),
--							  (others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')),
--							  (others=>(others=>'0')),(others=>(others=>'0')),(others=>(others=>'0')));

	--tetris variables for recording player actions
	type intArray is array(0 to 1) of integer;
	signal activeBlock : intArray := (others=>0);
	signal prevBlock : intArray := (others=>0);
	signal moveFlag : std_logic;
	
	-- Build an enumerated type for the state machine
	type state_type is (sStart, sCount, sStepDown, sMoveLeft, sMoveRight, sWaitLeftUp, sWaitRightUp, sStepDownLeft, sStepDownRight);

	-- Register to hold the current state
	signal state   : state_type;
	
begin
	VGA: vgaDriver
		port map(clk => vgaClock, reset => resetT, 
			hsync => hsyncT, vsync => vsyncT, 
			hcounter => hcounterT, vcounter => vcounterT);

	column <= hcounterT - 138;
	row <= vcounterT - 35;
	
	--process to slow 50MHz clock to 25MHz
	process (clkT)
	begin
		if (rising_edge(clkT)) then
			counter <= counter + 1;
		end if;
	end process;
	vgaClock <= std_logic(counter(0));
	slowclock <= std_logic(counter(25));-- 25th bit of 50MHz clock gets 1.5 times a second, need a state machine clock
	

	
	--process to slow set player actions
	process (clkT, resetT)
	begin
		if resetT = '0' then
			--reset all blocks to zeros.
			for i in 0 to blockWidth loop
				for j in 0 to blockHeight loop
					blockGrid(i)(j) <= zeros;
				end loop;
			end loop;
			activeBlock(0) <= 0;
			activeBlock(1) <= 0;
			sCounter <= "0000000000000000000000000000";
			sWaitCounter <= "0000000000000000000000000000";
		elsif rising_edge(clkT) then
			
			case state is
				when sStart =>
					activeBlock(0) <= 0;
					activeBlock(1) <= 0;
					sCounter <= "0000000000000000000000000000";
					if sWaitCounter(26) = '1' then
						state <= sCount;
					else
						sWaitCounter <= sWaitCounter + 1;
						state <= sStart;
					end if;
				when sCount =>
					if sCounter(25) = '1' then
						state <= sStepDown;
					elsif shiftLeftBtn = '0' then
						state <= sMoveLeft;
					elsif shiftRightBtn = '0' then
						state <= sMoveRight;
					else
						sCounter <= sCounter + 1;
						state <= sCount;
					end if;
				when sStepDown =>
					sCounter <= "0000000000000000000000000000";
					if blockGrid(activeBlock(0))(activeBlock(1) + 1) /= zeros then
						blockGrid(activeBlock(0))(activeBlock(1) + 1) <= "000000001001";
					else
						blockGrid(activeBlock(0))(activeBlock(1) + 1) <= "100100000000";
					end if;
					activeBlock(1) <= activeBlock(1) + 1;
					state <= sCount;
				when sMoveLeft =>
					if blockGrid(activeBlock(0) - 1)(activeBlock(1)) /= zeros then
						blockGrid(activeBlock(0) - 1)(activeBlock(1)) <= "000000001001";
					else
						blockGrid(activeBlock(0) - 1)(activeBlock(1)) <= "100100000000";
					end if;
					activeBlock(0) <= activeBlock(0) - 1;
					sCounter <= sCounter + 1;
					state <= sWaitLeftUp;
				when sMoveRight =>
					if blockGrid(activeBlock(0) + 1)(activeBlock(1)) /= zeros then
						blockGrid(activeBlock(0) + 1)(activeBlock(1)) <= "000000001001";
					else
						blockGrid(activeBlock(0) + 1)(activeBlock(1)) <= "100100000000";
					end if;
					activeBlock(0) <= activeBlock(0) + 1;
					sCounter <= sCounter + 1;
					state <= sWaitRightUp;
				when sWaitLeftUp =>
					if sCounter(25) = '1' then
						state <= sStepDownLeft;
					elsif shiftLeftBtn = '1' then
						sCounter <= sCounter + 1;
						state <= sCount;
					else
						sCounter <= sCounter + 1;
						state <= sWaitLeftUp;
					end if;
				when sWaitRightUp =>
					if sCounter(25) = '1' then
						state <= sStepDownRight;
					elsif shiftRightBtn = '1' then
						sCounter <= sCounter + 1;
						state <= sCount;
					else
						sCounter <= sCounter + 1;
						state <= sWaitRightUp;
					end if;
				when sStepDownLeft =>
					sCounter <= "0000000000000000000000000000";
					if blockGrid(activeBlock(0))(activeBlock(1) + 1) /= zeros then
						blockGrid(activeBlock(0))(activeBlock(1) + 1) <= "000000001001";
					else
						blockGrid(activeBlock(0))(activeBlock(1) + 1) <= "100100000000";
					end if;
					activeBlock(1) <= activeBlock(1) + 1;
					if shiftLeftBtn = '1' then
						state <= sCount;
					else
						state <= sWaitLeftUp;
					end if;
				when sStepDownRight =>
					sCounter <= "0000000000000000000000000000";
					if blockGrid(activeBlock(0))(activeBlock(1) + 1) /= zeros then
						blockGrid(activeBlock(0))(activeBlock(1) + 1) <= "000000001001";
					else
						blockGrid(activeBlock(0))(activeBlock(1) + 1) <= "100100000000";
					end if;
					activeBlock(1) <= activeBlock(1) + 1;
					if shiftRightBtn = '1' then
						state <= sCount;
					else
						state <= sWaitRightUp;
					end if;
				when others =>
					sWaitCounter <= "0000000000000000000000000000";
					state <= sStart;
			end case;
		end if;
	end process;

	--sets the pixels to be turned on, blocks in a grid
	process (column, row)
	begin
		
		--useable area on screen, all pixels will be turned on from here
		if column >= 0 and column < 640 then
			if row >= 0 and row < 480 then
				--initially off
				blueOut <= "0000";	
				redOut <= "0000";	
				greenOut <= "0000";	
				
				-- on for border
				if column = 0 or column = 639 or row = 0 or row = 479 then
					blueOut <= "1001";
				--else 

				end if;

				-- turn valid blocks on
				for i in 0 to blockWidth loop
					for j in 0 to blockHeight loop
						if column > 1+(i*blockSize) and column < ((i+1)*blockSize) and row > 1+(j*blockSize) and row < ((j+1)*blockSize) then
--							blueOut <= "1001";
							blueOut <= blockGrid(i)(j)(3 downto 0);
							greenOut <= blockGrid(i)(j)(7 downto 4);
							redOut <= blockGrid(i)(j)(11 downto 8);
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
