library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity character_address_unit is
	port (
		clk, reset: in std_logic;

		incr_frame: in boolean;
		incr_char_y: in boolean;
		incr_pixel_y: in boolean;
		incr_char_x: in boolean;
		
		offset: in std_logic_vector(15 downto 0);
		load_offset: in std_logic;
		
		addr: out std_logic_vector(15 downto 0) := X"0000"
	);
end entity;

architecture rtl of character_address_unit is
	-- sl = start line, sf = start frame
	signal address, sl_address, sf_address:
		std_logic_vector(15 downto 0) := X"0000";
begin
	addr <= address;

	address_ctrl: process (clk, reset, incr_frame, incr_char_y,
		incr_pixel_y, incr_char_x,
		address, sl_address, sf_address) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				address <= X"0000";
			
			elsif incr_frame then
				address <= sf_address;
			
			elsif incr_char_y then
				address <= std_logic_vector(unsigned(address) + 1);
			
			elsif incr_pixel_y then
				address <= sl_address;
			
			elsif incr_char_x then
				address <= std_logic_vector(unsigned(address) + 1);
			
			end if;
		end if;
	end process;
	
	sl_address_ctrl: process (clk, reset, sl_address, address, load_offset,
		offset) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				sl_address <= X"0000";
			
			elsif incr_frame then
				sl_address <= sf_address;
			
			elsif incr_char_y then
				sl_address <= std_logic_vector(unsigned(address) + 1);
			
			end if;
		end if;
	end process;

	sf_address_ctrl: process (clk, reset, offset) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				sf_address <= X"0000";
			
			elsif load_offset = '1' then
				sf_address <= offset;
			
			end if;
		end if;
	end process;

end architecture;

