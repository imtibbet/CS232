-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity lights is

	port(
		clk	 : in	std_logic;
		reset	 : in	std_logic;
		faster	: in std_logic;
		hold	: in std_logic;
		lights	: out	std_logic_vector(7 downto 0);
		IRview	: out	std_logic_vector(3 downto 0);
		PCview	: out	std_logic_vector(5 downto 0)
	);

end entity;

architecture rtl of lights is

	component lightrom
		 port 
	  (
		 addr    : in std_logic_vector (5 downto 0);
		 data    : out std_logic_vector (3 downto 0)
	  );
	end component;

--signals
	signal IR : std_logic_vector(3 downto 0);
	signal PC : unsigned(5 downto 0);
	signal LR : unsigned(7 downto 0);
	signal ROMvalue : std_logic_vector(3 downto 0);
	signal slowclock : std_logic;
	signal counter: unsigned (25 downto 0);
	signal speed: integer := 24;	
	
--constants
	constant zeros : unsigned(25 downto 0) := (others => '0');
	
	-- state declaration and register
	type state_type is (sFetch, sExecute);
	signal state   : state_type;

begin

	lightrom1: lightrom
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
			IR <= std_logic_vector(zeros(3 downto 0));
			PC <= zeros(5 downto 0);
			LR <= zeros(7 downto 0);
			
		elsif (rising_edge(slowclock)) then
			if hold = '0' then
				case state is
					when sFetch=>
						IR <= ROMvalue;
						PC <= PC + "1";
						state <= sExecute;
					when sExecute=>
						case IR is
							when "0000"=>
								LR <= zeros(7 downto 0);
							when "0001"=>
								LR <= "0" & LR(7 downto 1);
							when "0010"=>
								LR <= LR(6 downto 0) & "0";
							when "0011"=>
								LR <= LR + "1";
							when "0100"=>
								LR <= LR - "1";
							when "0101"=>
								LR <= not LR; 
							when "0110"=>
								LR <= LR(0) & LR(7 downto 1);
							when "0111"=>
								LR <= LR(6 downto 0) & LR(7);
							when "1000"=>
								LR <= LR(6 downto 0) & "1";
							when others=>
								LR <= LR;
						end case;
						state <= sFetch;
				end case;
			end if;
		end if;
		
					--concurrent signal assignment?
			lights <= std_logic_vector(LR);
			PCview <= std_logic_vector(PC);
			IRview <= IR;
			
	end process;
end rtl;
