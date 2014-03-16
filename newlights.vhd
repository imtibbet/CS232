-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity newlights is

	port(
		clk	 : in	std_logic;
		reset	 : in	std_logic;
		faster	: in std_logic;
		hold	: in std_logic;
		lights	: out	std_logic_vector(7 downto 0);
		IRview	: out	std_logic_vector(4 downto 0);
		PCview	: out	std_logic_vector(3 downto 0)
	);

end entity;

architecture rtl of newlights is

	component newlightrom
		 port 
	  (
		 addr    : in std_logic_vector (3 downto 0);
		 data    : out std_logic_vector (9 downto 0)
	  );
	end component;

--signals
	signal IR : std_logic_vector(9 downto 0);
	signal PC : unsigned(3 downto 0);
	signal LR : unsigned(7 downto 0);
	signal ROMvalue : std_logic_vector(9 downto 0);
	signal slowclock : std_logic;
	signal counter: unsigned (25 downto 0);
	signal speed: integer := 24;	
	signal ACC : unsigned(7 downto 0);
	signal SRC : unsigned(7 downto 0);
	
--constants
	constant zeros : unsigned(25 downto 0) := (others => '0');
	
	-- state declaration and register
	type state_type is (sFetch, sExecute1, sExecute2);
	signal state   : state_type;

begin

	lightrom1: newlightrom
		port map( addr => std_logic_vector(PC), data => ROMvalue);

	-- process to slow down clock cycle
	process (clk, reset)
	begin
      if reset = '0' then
        counter <= zeros;
      elsif (rising_edge(clk)) then
        counter <= counter + 1;
      end if;
  end process;

	process (faster)
	begin
		if falling_edge(faster) and speed > 15 then
			speed <= speed - 1;
		elsif falling_edge(faster) and speed = 15 then
			speed <= 25;
		end if;
	end process;
  slowclock <= counter(speed);
  
	-- Logic to advance to the next state
	process (slowclock, reset)
	begin
		if reset = '0' then
			state <= sFetch;
			IR <= std_logic_vector(zeros(9 downto 0));
			PC <= zeros(3 downto 0);
			LR <= zeros(7 downto 0);
			ACC <= zeros(7 downto 0);
			
		elsif (rising_edge(slowclock)) then
			if hold = '0' then
				case state is
					when sFetch=>
						IR <= ROMvalue;
						PC <= PC + "1";
						state <= sExecute1;
					when sExecute1=> -- assigns SRC from IR
						case IR (9 downto 8) is
							when "00"=> -- MOVE
								case IR (5 downto 4) is -- SRC gets
									when "00"=> -- ACC
										SRC <= ACC;
									when "01"=> -- LR
										SRC <= LR;
									when "10"=> -- IR low 4 sign entended
										SRC <= unsigned(IR(3) & IR(3) & IR(3) & IR(3) & IR (3 downto 0));
									when others=> -- "11" all 1's
										SRC <= "11111111";
								end case;
							when "01"=> -- BINARY OPERATION
								case IR (4 downto 3) is -- SRC gets
									when "00"=> -- ACC
										SRC <= ACC;
									when "01"=> -- LR
										SRC <= LR;
									when "10"=> -- IR low 2 sign entended
										SRC <= unsigned(IR(1) & IR(1) & IR(1) & IR(1) & IR(1) & IR(1) & IR (1 downto 0));
									when others=> -- "11" all 1's
										SRC <= "11111111";
								end case;
							when "10"=> -- BRANCH uncond, SRC unaffected
								SRC <= SRC;
							when others=> -- "11" BRANCHZ
								case IR(7) is -- SRC gets
									when '0'=> -- ACC
										SRC <= ACC;
									when others=> -- '1' LR
										SRC <= LR;
								end case;
						end case;
						state <= sExecute2;
					when sExecute2=> -- executes instruction
						case IR (9 downto 8) is
							when "00"=> -- MOVE
								case IR (7 downto 6) is -- DEST gets SRC
									when "00"=> -- DEST is ACC
										ACC <= SRC;
									when "01"=> -- DEST is LR
										LR <= SRC;
									when "10"=> -- DEST is ACC low 4 bits
										ACC (3 downto 0) <= SRC (3 downto 0);
									when others=> -- "11" DEST is ACC high 4 bits
										ACC (7 downto 4) <= SRC (3 downto 0);
								end case;
							when "01"=> -- BINARY OPERATION
								case IR (2) is
									when '0'=> -- DEST is ACC
										case IR (7 downto 5) is -- DEST gets DEST op SRC
											when "000"=> -- op is ADD
												ACC <= ACC + SRC;
											when "001"=> -- op is SUB
												ACC <= ACC - SRC;
											when "010"=> -- op is shift left
												ACC <= SRC(6 downto 0) & "0";
											when "011"=> -- op is shift right
												ACC <= SRC(7) & SRC(7 downto 1);
											when "100"=> -- op is xor
												ACC <= ACC xor SRC;
											when "101"=> -- op is binary and
												ACC <= ACC and SRC;
											when "110"=> -- op is rotate left
												ACC <= SRC(6 downto 0) & SRC(7);
											when others=> -- "111" op is rotate right
												ACC <= SRC(0) & SRC(7 downto 1);
										end case;
									when others=> -- DEST is LR
										case IR (7 downto 5) is -- DEST gets DEST op SRC
											when "000"=> -- op is ADD
												LR <= LR + SRC;
											when "001"=> -- op is SUB
												LR <= LR - SRC;
											when "010"=> -- op is shift left
												LR <= SRC(6 downto 0) & "0";
											when "011"=> -- op is shift right
												LR <= SRC(7) & SRC(7 downto 1);
											when "100"=> -- op is xor
												LR <= LR xor SRC;
											when "101"=> -- op is binary and
												LR <= LR and SRC;
											when "110"=> -- op is rotate left
												LR <= SRC(6 downto 0) & SRC(7);
											when others=> -- "111" op is rotate right
												LR <= SRC(0) & SRC(7 downto 1);
										end case;
								end case;
							when "10"=> -- BRANCH uncond
								PC <= unsigned(IR(3 downto 0));
							when others=> -- "11" BRANCHZ
								if SRC = zeros(7 downto 0) then
									PC <= unsigned(IR(3 downto 0));
								end if;
						end case;
						state <= sFetch;
				end case;
			end if;
		end if;
		
					--concurrent signal assignment?
			lights <= std_logic_vector(LR);
			PCview <= std_logic_vector(PC);
			IRview <= std_logic_vector(ACC(4 downto 0));
			
	end process;
end rtl;
