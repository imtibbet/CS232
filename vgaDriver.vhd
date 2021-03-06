-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vgaDriver is

	port(
		clk		 : in	std_logic;
		reset	 : in	std_logic;
		hsync	 : out	std_logic;
		vsync	 : out	std_logic;
		hcounter	 : out	integer;
		vcounter	 : out	integer
	);

end entity;

architecture rtl of vgaDriver is

	signal hcountInt : integer;
	signal vcountInt : integer;
	
begin

--horizontal timing 800 cycles
	--0 to 92 (93) sync pulse
	--93 to 137 (45) front porch
	--138 to 777 (640) data
	--778 to 799 (22) back porch
	
--vertical timing 525 cycles
	--0 to 1 (2) sync pulse
	--2 to 34 (33) front porch
	--35 to 514 (480) data
	--515 to 524 (10) back porch

	process (clk, reset)
	begin
		if reset = '0' then
			hcountInt <= 0;
			vcountInt <= 0;
		elsif (rising_edge(clk)) then
			case vcountInt is 
				when 0 to 1 => --v sync pulse
					vsync <= '0';
					case hcountInt is
						when 0 to 92 => --h sync pulse
							hsync <= '0';
							hcountInt <= hcountInt + 1;
						when 93 to 137 => --h front porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 138 to 777 => --h data
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 778 to 798 => --h back porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when others => --h back porch, loop back to right of screen, increment line
							hsync <= '1';
							hcountInt <= 0;
							vcountInt <= vcountInt + 1;
					end case;
				when 2 to 34 => -- v front porch
					vsync <= '1';
					case hcountInt is
						when 0 to 92 => --h sync pulse
							hsync <= '0';
							hcountInt <= hcountInt + 1;
						when 93 to 137 => --h front porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 138 to 777 => --h data
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 778 to 798 => --h back porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when others => --h back porch, loop back to right of screen, increment line
							hsync <= '1';
							hcountInt <= 0;
							vcountInt <= vcountInt + 1;
					end case;
				when 35 to 514 => --v data
					vsync <= '1';
					case hcountInt is
						when 0 to 92 => --h sync pulse
							hsync <= '0';
							hcountInt <= hcountInt + 1;
						when 93 to 137 => --h front porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 138 to 777 => --h data
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 778 to 798 => --h back porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when others => --h back porch, loop back to right of screen, increment line
							hsync <= '1';
							hcountInt <= 0;
							vcountInt <= vcountInt + 1;
					end case;
				when 515 to 523 => --v back porch
					vsync <= '1';
					case hcountInt is
						when 0 to 92 => --h sync pulse
							hsync <= '0';
							hcountInt <= hcountInt + 1;
						when 93 to 137 => --h front porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 138 to 777 => --h data
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 778 to 798 => --h back porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when others => --h back porch, loop back to right of screen, increment line
							hsync <= '1';
							hcountInt <= 0;
							vcountInt <= vcountInt + 1;
					end case;
				when others => --last cycle of v back porch, returns to top right of screen at end 
					vsync <= '1';
					case hcountInt is
						when 0 to 92 => --h sync pulse
							hsync <= '0';
							hcountInt <= hcountInt + 1;
						when 93 to 137 => --h front porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 138 to 777 => --h data
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when 778 to 798 => --h back porch
							hsync <= '1';
							hcountInt <= hcountInt + 1;
						when others => --h back porch, loop back to top right of screen
							hsync <= '1';
							hcountInt <= 0;
							vcountInt <= 0;
					end case;
			end case;
		end if;
	end process;

	hcounter <= hcountInt;
	vcounter <= vcountInt;
	
end rtl;
