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
		--IRview	: out	std_logic_vector(9 downto 0);
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
			
		elsif (rising_edge(slowclock)) then
			if hold = '0' then
				case state is
					when sFetch=>
						IR <= ROMvalue;
						PC <= PC + "1";
						state <= sExecute1;
					when sExecute1=>
						case IR (9 downto 8) is
							when "00"=>
								case IR (5 downto 4) is
									when "00"=>
										SRC <= ACC;
									when "01"=>
										SRC <= LR;
									when "10"=>
										SRC <= unsigned(IR(3) & IR(3) & IR(3) & IR(3) & IR (3 downto 0));
									when others=>
										SRC <= "11111111";
								end case;
							when "01"=>
								case IR (5 downto 4) is
									when "00"=>
										SRC <= ACC;
									when "01"=>
										SRC <= LR;
									when "10"=>
										SRC <= unsigned(IR(1) & IR(1) & IR(1) & IR(1) & IR(1) & IR(1) & IR (1 downto 0));
									when others=>
										SRC <= "11111111";
								end case;
							when "10"=>
							when others=>
								case IR(7) is
									when '0'=>
										SRC <= ACC;
									when '1'=>
										SRC <= LR;
								end case;
						end case;
						state <= sExecute2;
					when sExecute2=>
						case IR (9 downto 8) is
							when "00"=>
								case IR (7 downto 6) is
									when "00"=>
										ACC <= SRC;
									when "01"=>
										LR <= SRC;
									when "10"=>
										ACC (3 downto 0) <= SRC (3 downto 0);
									when others=>
										ACC (7 downto 4) <= SRC (7 downto 4);
								end case;
							when "01"=>
								case IR (2) is
									when '0'=>
										case IR (7 downto 5) is
											when "000"=>
												ACC <= ACC + SRC;
											when "001"=>
												ACC <= ACC - SRC;
											when "010"=>
												ACC <= SRC(6 downto 0) & "0";
											when "011"=>
												ACC <= SRC(7) & SRC(7 downto 1);
											when "100"=>
												ACC <= ACC xor SRC;
											when "101"=>
												ACC <= ACC and SRC;
											when "110"=>
												ACC <= SRC(6 downto 0) & SRC(7);
											when others=>
												ACC <= SRC(0) & SRC(7 downto 1);
										end case;
									when '1'=>
										case IR (7 downto 5) is
											when "000"=>
												LR <= LR + SRC;
											when "001"=>
												LR <= LR - SRC;
											when "010"=>
												LR <= SRC(6 downto 0) & "0";
											when "011"=>
												LR <= SRC(7) & SRC(7 downto 1);
											when "100"=>
												LR <= LR xor SRC;
											when "101"=>
												LR <= LR and SRC;
											when "110"=>
												LR <= SRC(6 downto 0) & SRC(7);
											when others=>
												LR <= SRC(0) & SRC(7 downto 1);
										end case;
								end case;
							when "10"=>
								PC <= unsigned(IR(3 downto 0));
							when others=>
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
			--IRview <= IR;
			
	end process;
end rtl;
