-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's oports are dependent only on the current state.
-- The oport is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is

port (
		 clk   : in  std_logic;                       -- main clock
		 reset : in  std_logic;                       -- reset button

		 PCview : out std_logic_vector( 7 downto 0);  -- debugging oports
		 IRview : out std_logic_vector(15 downto 0);
		 RAview : out std_logic_vector(15 downto 0);
		 RBview : out std_logic_vector(15 downto 0);
		 RCview : out std_logic_vector(15 downto 0);
		 RDview : out std_logic_vector(15 downto 0);
		 REview : out std_logic_vector(15 downto 0);

		 iport : in  std_logic_vector(7 downto 0);    -- iport port
		 oport : out std_logic_vector(15 downto 0)  -- oport port
		
		-- extensions
--		faster	: in std_logic;
--		hexdisplay : out unsigned(27 downto 0); --7 digit display
--		hold	: in std_logic
	);
end entity;

architecture rtl of cpu is

	-- A component declaration declares the interface of an entity or
-- a design unit written in another language.  VHDL requires that
-- you declare a component if you do not intend to instantiate
-- an entity directly.	The component need not declare all the
-- generics and ports in the entity.  It may omit generics/ports
-- with default values.

component ProgramROM

	port
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';	
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);

end component;

component DataRAM

	port
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);

end component;

component alu

  port (
    srcA : in  unsigned(15 downto 0);         -- input A
    srcB : in  unsigned(15 downto 0);         -- input B
    op   : in  std_logic_vector(2 downto 0);  -- operation
    cr   : out std_logic_vector(3 downto 0);  -- condition outputs
    dest : out unsigned(15 downto 0));        -- output value

end component;

--component boxdriver
--
--  port	(
--		a	: in unsigned (3 downto 0);
--		result : out unsigned (6 downto 0)
--		);
--
--end component;


	-- Build an enumerated type for the state machine
	type state_type is (start, fetch, executeSetup, executeProcess, interimState, executeWrite, halt);

	-- Register to hold the current state
	signal state   : state_type;
	
	--other signals
	
	-- ROM, 8 bit address and 16 bit words
	signal PC : unsigned(7 downto 0);
	signal ROMwire	: std_logic_vector(15 downto 0);
	
	-- RAM, 8 bit address and 16 bit words
	signal MAR : unsigned(7 downto 0);
	signal MBR	: unsigned(15 downto 0);
	signal RAMwire	: std_logic_vector(15 downto 0);
	signal writeEnable : std_logic;
	
	-- ALU
	signal SRCA : unsigned(15 downto 0);
	signal SRCB : unsigned(15 downto 0);
	signal DEST : unsigned(15 downto 0);
	signal CR : std_logic_vector(3 downto 0);-- condition
	signal OP : std_logic_vector(2 downto 0);-- operation
	signal TCR : std_logic_vector(3 downto 0);-- temporary condition
	
	-- general purpose registers
	signal RA : unsigned(15 downto 0);
	signal RB : unsigned(15 downto 0);
	signal RC : unsigned(15 downto 0);
	signal RD : unsigned(15 downto 0);
	signal RE : unsigned(15 downto 0);
	
	-- stack pointer
	signal SP : unsigned(15 downto 0);
	
	-- instruction
	signal IR : unsigned(15 downto 0);
	
	
	-- so the board works
	signal slowclock : std_logic;
	
	-- for extensions, button to vary speed
--	signal counter: unsigned (25 downto 0);
--	signal speed: integer := 24;	
	signal startupcounter : unsigned(2 downto 0);
--	signal oport : std_logic_vector(15 downto 0);
--		
	--constants
	constant zeros : unsigned(25 downto 0) := (others => '0');
	
begin
	ROM: ProgramROM
		port map(address => std_logic_vector(PC), clock => clk, q => ROMwire);

	RAM: DataRAM
		port map(address => std_logic_vector(MAR), clock => clk, data => std_logic_vector(MBR), wren => writeEnable, q => RAMwire);
		
	myALU: alu
		port map(srcA => SRCA, srcB => SRCB, op => OP, cr => TCR, dest => DEST);
		
--	HX0: boxdriver
--		port map(a => unsigned(oport(3 downto 0)), result => hexdisplay(6 downto 0));
--	HX1: boxdriver
--		port map(a => unsigned(oport(7 downto 4)), result => hexdisplay(13 downto 7));
--	HX2: boxdriver
--		port map(a => unsigned(oport(11 downto 8)), result => hexdisplay(20 downto 14));
--	HX3: boxdriver
--		port map(a => unsigned(oport(15 downto 12)), result => hexdisplay(27 downto 21));
--		
	-- process to slow down clock cycle
--	process (clk, reset)
--	begin
--		if reset = '0' then
--		  counter <= zeros;
--		elsif (rising_edge(clk)) then
--		  counter <= counter + 1;
--		end if;
--	end process;
--
--	-- process to control speed using button, extension
--	process (faster)
--	begin
--		if falling_edge(faster) and speed > 15 then
--			speed <= speed - 1;
--		elsif falling_edge(faster) and speed = 15 then
--			speed <= 25;
--		end if;
--	end process;
--	slowclock <= counter(speed);
--	  
	-- Logic to advance to the next state
	process (clk, reset)
	begin
		-- If the reset button is activated, set the registers 
		-- PC, MAR, MBR, RA, RB, RC, RD, RE, SP, and CR to zeros. 
		-- The state should should be reset to the startup state 
		-- and the small counter should be reset to zeros.
		if reset = '0' then
			PC <= zeros(7 downto 0);
			MAR <= zeros(7 downto 0);
			MBR <= zeros(15 downto 0);
			RA <= zeros(15 downto 0);
			RB <= zeros(15 downto 0);
			RC <= zeros(15 downto 0);
			RD <= zeros(15 downto 0);
			RE <= zeros(15 downto 0);
			SP <= zeros(15 downto 0);
			CR <= std_logic_vector(zeros(3 downto 0));
			writeEnable <= '0';
			startupcounter <= zeros(2 downto 0); -- reset startup counter
			state <= start;
		elsif (rising_edge(clk)) then
--			if hold = '0' then
				case state is
					-- wait 8 clock cycles before starting execution
					when start=>
						if startupcounter = "111" then -- if done with 8 cycle startup wait time
							state <= fetch; -- transition to fetch state
						else
							startupcounter <= startupcounter + 1; -- increment starup counter, wait another cycle
						end if;
						
					-- begin machine cycle, starting and looping to fetch sequence
					
					-- The fetch state should copy the ROM data wire contents to the 
					-- IR, increment the PC, and move to the execute-setup state.
					when fetch=>
						IR <= unsigned(ROMwire);
						PC <= PC + 1;
						state <= executeSetup;
						
					-- The execute-setup state should set up each of the instructions. 
					when executeSetup=>
						if IR(15) = '0' then -- non-ALU operation
							case IR(14 downto 12) is
								when "000"=>-- Load from RAM
									-- setting RAM address
									if IR(11) = '1' then
										MAR <= IR(7 downto 0) + RE(7 downto 0);
									else
										MAR <= IR(7 downto 0);
									end if;
								when "001"=>-- Store to RAM
									-- setting RAM address
									if IR(11) = '1' then
										MAR <= IR(7 downto 0) + RE(7 downto 0);
									else
										MAR <= IR(7 downto 0);
									end if;
									-- Table B source assignment
									case IR(10 downto 8) is
										when "000"=>-- RA
											MBR <= RA;
										when "001"=>-- RB
											MBR <= RB;
										when "010"=>-- RC
											MBR <= RC;
										when "011"=>-- RD
											MBR <= RD;
										when "100"=>-- RE
											MBR <= RE;
										when "101"=>-- SP
											MBR <= SP;
										when others=> --incorrect source
											null;
									end case;
								when "010"=>-- Unconditional Branch
									PC <= IR(7 downto 0);
								when "011"=>
									case IR(11 downto 10) is
										when "00"=>-- Conditional Branch
											case IR(9 downto 8) is
												when "00"=>-- branch if zero
													if CR(0) = '1' then
														PC <= IR(7 downto 0);
													end if;
												when "01"=>-- branch if overflow
													if CR(1) = '1' then
														PC <= IR(7 downto 0);
													end if;
												when "10"=>-- branch if negative
													if CR(2) = '1' then
														PC <= IR(7 downto 0);
													end if;
												when others=>-- branch if carry
													if CR(3) = '1' then
														PC <= IR(7 downto 0);
													end if;
												end case;
										when "01"=>-- Call
											PC <= IR(7 downto 0);
											MAR <= SP(7 downto 0);
											MBR <= "0000" & unsigned(CR) & PC;
											SP <= SP + 1;
										when "10"=>-- return
											MAR <= SP(7 downto 0) - 1;
											SP <= SP - 1;
										when others=>-- "00"=> exit
											state <= halt;
									end case;
								when "100"=>-- push
									MAR <= SP(7 downto 0);
									SP <= SP + 1;
									-- Table C source assignment
									case IR(11 downto 9) is
										when "000"=>-- RA
											MBR <= RA;
										when "001"=>-- RB
											MBR <= RB;
										when "010"=>-- RC
											MBR <= RC;
										when "011"=>-- RD
											MBR <= RD;
										when "100"=>-- RE
											MBR <= RE;
										when "101"=>-- SP
											MBR <= SP;
										when "110"=>-- PC
											MBR <= zeros(7 downto 0) & PC;
										when others=> --"111" CR
											MBR <= zeros(11 downto 0) & unsigned(CR);
									end case;
								when "101"=>-- pop
									MAR <= SP(7 downto 0) - 1;
									SP <= SP - 1;
								when "110"=>-- store to output
									null;
								when others=> --"111"=> load from input
									null;
							end case;
						else -- IR(15) = '1' ALU operation
							op <= std_logic_vector(IR(14 downto 12));
							case IR(14 downto 12) is
								when "000" | "001" | "010" | "011" | "100" =>-- add, sub, and, or xor
									-- Table E source A assignment
									case IR(11 downto 9) is
										when "000"=>-- RA
											SRCA <= RA;
										when "001"=>-- RB
											SRCA <= RB;
										when "010"=>-- RC
											SRCA <= RC;
										when "011"=>-- RD
											SRCA <= RD;
										when "100"=>-- RE
											SRCA <= RE;
										when "101"=>-- SP
											SRCA <= SP;
										when "110"=>-- 0s
											SRCA <= zeros(15 downto 0);
										when others=> -- "111" all 1s
											SRCA <= "1111111111111111";
									end case;
									-- Table E source B assignment
									case IR(8 downto 6) is
										when "000"=>-- RA
											SRCB <= RA;
										when "001"=>-- RB
											SRCB <= RB;
										when "010"=>-- RC
											SRCB <= RC;
										when "011"=>-- RD
											SRCB <= RD;
										when "100"=>-- RE
											SRCB <= RE;
										when "101"=>-- SP
											SRCB <= SP;
										when "110"=>-- 0s
											SRCB <= zeros(15 downto 0);
										when others=> -- "111" all 1s
											SRCB <= "1111111111111111";
									end case;
								when "101" | "110" =>-- shift, rotate
									--direction bit
									SRCB <= zeros(15 downto 1) & IR(11);
									-- Table E source A assignment
									case IR(10 downto 8) is
										when "000"=>-- RA
											SRCA <= RA;
										when "001"=>-- RB
											SRCA <= RB;
										when "010"=>-- RC
											SRCA <= RC;
										when "011"=>-- RD
											SRCA <= RD;
										when "100"=>-- RE
											SRCA <= RE;
										when "101"=>-- SP
											SRCA <= SP;
										when "110"=>-- 0s
											SRCA <= zeros(15 downto 0);
										when others=> -- "111" all 1s
											SRCA <= "1111111111111111";
									end case;
								when others=> --"111"=> move
									if IR(11) = '1' then
										SRCA <= IR(10) & IR(10) & IR(10) & IR(10) & IR(10) & IR(10) & IR(10) & IR(10) & IR(10 downto 3);
									else
										-- Table D SRCA assignment
										case IR(10 downto 8) is
											when "000"=>-- RA
												SRCA <= RA;
											when "001"=>-- RB
												SRCA <= RB;
											when "010"=>-- RC
												SRCA <= RC;
											when "011"=>-- RD
												SRCA <= RD;
											when "100"=>-- RE
												SRCA <= RE;
											when "101"=>-- SP
												SRCA <= SP;
											when "110"=>-- PC
												SRCA <= zeros(7 downto 0) & PC;
											when others=>-- "111" IR
												SRCA <= IR;
										end case;
									end if;
								end case;
							end if;
						state <= executeProcess;
						
					-- The execute-process state should set the RAM write enable signal 
					-- to high if the operation is a store (opcode 0001, or integer 1), a push, or a CALL.
					when executeProcess=>
						if IR(15 downto 12) = "0001" or IR(15 downto 12) = "0100" or IR(15 downto 10) = "001101" then --store, push, call
							writeEnable <= '1';
						end if;
						state <= interimState;
					
					when interimState=>
						state <= executeWrite;
					-- The execute-write state should handle the final stage of the various operations. 
					-- At the beginning of the state, it should set the write enable flag to '0'. 
					
					
					when executeWrite=>
						writeEnable <= '0';
						
						if IR(15) = '0' then -- non-ALU operation
							case IR(14 downto 12) is
								when "000"=>-- Load from RAM
									-- Table B dest assignment
									case IR(10 downto 8) is
										when "000"=>-- RA
											RA <= unsigned(RAMwire);
										when "001"=>-- RB
											RB <= unsigned(RAMwire);
										when "010"=>-- RC
											RC <= unsigned(RAMwire);
										when "011"=>-- RD
											RD <= unsigned(RAMwire);
										when "100"=>-- RE
											RE <= unsigned(RAMwire);
										when "101"=>-- SP
											SP <= unsigned(RAMwire);
										when others=> --incorrect source
											null;
									end case;
								when "001" | "010" | "100" =>-- Store to RAM, unconditional branch, push
									null;
								when "011"=>
									case IR(11 downto 10) is
										when "00" | "01" =>-- Conditional Branch, Call
											null;
										when "10"=>-- return
											PC <= unsigned(RAMwire(7 downto 0));
											CR <= RAMwire(11 downto 8);
										when others=>-- "00"=> exit
											null;
									end case;
								when "101"=>-- pop
									-- Table C dest assignment
									case IR(11 downto 9) is
										when "000"=>-- RA
											RA <= unsigned(RAMwire);
										when "001"=>-- RB
											RB <= unsigned(RAMwire);
										when "010"=>-- RC
											RC <= unsigned(RAMwire);
										when "011"=>-- RD
											RD <= unsigned(RAMwire);
										when "100"=>-- RE
											RE <= unsigned(RAMwire);
										when "101"=>-- SP
											SP <= unsigned(RAMwire);
										when "110"=>-- PC
											PC <= unsigned(RAMwire(7 downto 0));
										when others=>-- "111" CR
											CR <= RAMwire(3 downto 0);
									end case;
								when "110"=>-- store to output
									-- Table D SRCA assignment
									case IR(11 downto 9) is
										when "000"=>-- RA
											oport <= std_logic_vector(RA);
										when "001"=>-- RB
											oport <= std_logic_vector(RB);
										when "010"=>-- RC
											oport <= std_logic_vector(RC);
										when "011"=>-- RD
											oport <= std_logic_vector(RD);
										when "100"=>-- RE
											oport <= std_logic_vector(RE);
										when "101"=>-- SP
											oport <= std_logic_vector(SP);
										when "110"=>-- PC
											oport <= std_logic_vector(zeros(7 downto 0) & PC);
										when others=>-- "111" IR
											oport <= std_logic_vector(IR);
									end case;
								when others=> --"111"=> load from input
									-- Table B dest assignment
									case IR(11 downto 9) is
										when "000"=>-- RA
											RA <= zeros(7 downto 0) & unsigned(iport);
										when "001"=>-- RB
											RB <= zeros(7 downto 0) & unsigned(iport);
										when "010"=>-- RC
											RC <= zeros(7 downto 0) & unsigned(iport);
										when "011"=>-- RD
											RD <= zeros(7 downto 0) & unsigned(iport);
										when "100"=>-- RE
											RE <= zeros(7 downto 0) & unsigned(iport);
										when "101"=>-- SP
											SP <= zeros(7 downto 0) & unsigned(iport);
										when others=> --incorrect source
											null;
									end case;
							end case;
						else -- IR(15) = '1' ALU operation
--							case IR(14 downto 12) is
--								when "000"=>-- add	
--								when "001"=>-- subtract
--								when "010"=>-- and
--								when "011"=>-- or
--								when "100"=>-- xor
--								when "101"=>-- shift
--								when "110"=>-- rotate
--								when others=> --"111"=> move
--							end case;
							-- Table B dest assignment
							case IR(2 downto 0) is
								when "000"=>-- RA
									RA <= DEST;
								when "001"=>-- RB
									RB <= DEST;
								when "010"=>-- RC
									RC <= DEST;
								when "011"=>-- RD
									RD <= DEST;
								when "100"=>-- RE
									RE <= DEST;
								when "101"=>-- SP
									SP <= DEST;
								when others=>--incorrect
									null;
							end case;
							CR <= TCR;
						end if;
						
						state <= fetch;
					
					when halt=>
						state <= state; -- wait in halt state
						
				--end state case
				end case;
			-- end hold if
--			end if;
		-- end reset if
		end if;
	-- end state advancement process
	end process;
	
	 PCview  <= std_logic_vector(PC);
	 IRview  <= std_logic_vector(IR);
	 RAview  <= std_logic_vector(RA);
	 RBview  <= std_logic_vector(RB);
	 RCview  <= std_logic_vector(RC);
	 RDview  <= std_logic_vector(RD);
	 REview  <= std_logic_vector(RE);

end rtl;
