-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memtest is

	port(
		clk		 : in	std_logic;
		reset	 : in	std_logic;
		faster	: in std_logic;
		hold	: in std_logic;
		output	 : out	std_logic_vector(7 downto 0);
		RAMaddviewdisplay	: out unsigned(6 downto 0)
	);

end entity;

architecture rtl of memtest is
	--component declaration of ROM
	component memrom
		PORT
	(
		address		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	end component;
	
	component memRAM
		PORT
	(
		address		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	end component;
	
	component boxdriver
		port
	(
		a	: in unsigned (3 downto 0);
		result : out unsigned (6 downto 0)
	);
	end component;
	
	--signals
	signal ROMaddress : unsigned(3 downto 0);
	signal ROMdata	: std_logic_vector(7 downto 0);
	signal ROMwire	: std_logic_vector(7 downto 0);
	signal RAMaddress : unsigned(3 downto 0);
	signal RAMdata	: std_logic_vector(7 downto 0);
	signal RAMwire	: std_logic_vector(7 downto 0);
	signal slowclock : std_logic;
	signal counter: unsigned (25 downto 0);
	signal speed: integer := 24;	
	signal writeEnable : std_logic;
	signal startupcounter : unsigned(1 downto 0);
	
	-- state declaration
	signal state   : unsigned(1 downto 0);
	
	--constants
	constant zeros : unsigned(25 downto 0) := (others => '0');
	
begin

	ROM1: memrom
		port map(address  => std_logic_vector(ROMaddress), clock => clk, q => ROMwire);
	
	RAM1: memRAM
		port map(address  => std_logic_vector(RAMaddress), clock => clk, data => RAMdata, wren => writeEnable, q => RAMwire);
		
	right7segment: boxdriver
		port map(a => RAMaddress, result => RAMaddviewdisplay);
		
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
			ROMaddress <= "0000";
			RAMaddress <= "0000";
			state <= "00";
			ROMdata <= "00000000";
			RAMdata <= "00000000";
			startupcounter <= "00";
			writeEnable <= '0';
		elsif (rising_edge(slowclock)) then
			if hold = '0' then
				case state is
					when "00" =>
						startupcounter <= startupcounter + 1;
						if startupcounter = "10" then
							-- to ensure that the last slot in RAM is written too without overwriting the first slot
							writeEnable <= '0';	
							RAMaddress <= "0000";
							state <= state + 1;		
						end if;
					-- displays the value of each slot in RAM sequentially, the RAM address is one ahead of what is being displayed
					when "01" =>
						RAMdata <= RAMwire;
						if RAMaddress = "1111" then
							state <= state + 1;
						else
							RAMaddress <= RAMaddress + 1;
						end if;
					-- pulls the value off of ROM, stops writing, and increments RAM address by one
					when "10" =>
						writeEnable <= '0';
						ROMdata <= ROMwire;
						RAMaddress <= RAMaddress + 1;
						state <= state + 1;
					-- gives ROMdata to RAM, enables writing which takes 1 clock cycle, increments ROM address by one, conditional statement to make sure every slot in ROM gets written to RAM than kicks to the display state
					when others =>
						RAMdata <= ROMdata;
						writeEnable <= '1';
						ROMaddress <= ROMaddress + 1;
						if RAMaddress = "1111" then
							startupcounter <= "10";
							state <= "00";
						else
							state <= "10";
						end if;
				end case;
			end if;
		end if;
		
	end process;
	
output <= RAMdata;
end rtl;
