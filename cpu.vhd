-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's oports are dependent only on the current state.
-- The oport is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;

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
    oport : out std_logic_vector(15 downto 0));  -- oport port

end entity;

architecture rtl of cpu is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3);

	-- Register to hold the current state
	signal state   : state_type;

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

begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '1' then
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
				when s1=>
				when s2=>
				when s3 =>
			end case;
		end if;
	end process;

end rtl;
