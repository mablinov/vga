library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_text_frame_counter is
	generic (
		videomode: vga_videomode;
		CHAR_WIDTH: positive := 8;
		CHAR_HEIGHT: positive := 8
	);
	port (
		clk, en, reset: in std_logic;
		hstate: in vga_hstate;
		vstate: in vga_vstate;
		
		pixel_local_x: out natural range 0 to CHAR_WIDTH - 1 := 0;
		char_x: out natural range 0 to (videomode.width / CHAR_WIDTH) - 1 := 0;
		pixel_local_y: out natural range 0 to CHAR_HEIGHT - 1 := 0;
		char_y: out natural range 0 to (videomode.height / CHAR_HEIGHT) - 1 := 0;
		
		incr_pixel_x: out boolean := false;
		incr_char_x: out boolean := false;
		incr_pixel_y: out boolean := false;
		incr_char_y: out boolean := false;
		incr_frame: out boolean := false
	);
end entity;

architecture rtl of vga_text_frame_counter is
	constant TXT_DISP_WIDTH: positive := videomode.width / CHAR_WIDTH;
	constant TXT_DISP_HEIGHT: positive := videomode.height / CHAR_HEIGHT;
	
	signal int_pixel_local_x: natural range 0 to CHAR_WIDTH - 1 := 0;
	signal int_char_x: natural range 0 to TXT_DISP_WIDTH - 1 := 0;
	signal int_pixel_local_y: natural range 0 to CHAR_HEIGHT - 1 := 0;
	signal int_char_y: natural range 0 to TXT_DISP_HEIGHT - 1 := 0;
	
	signal int_incr_pixel_x: boolean := false;
	signal int_incr_char_x: boolean := false;
	signal int_incr_pixel_y: boolean := false;
	signal int_incr_char_y: boolean := false;
	signal int_incr_frame: boolean := false;

begin
	
	eval_incr_conds: process (hstate, vstate,
		int_pixel_local_x, int_char_x,
		int_pixel_local_y, int_char_y,
		int_incr_char_x, int_incr_pixel_y,
		int_incr_char_y)
	is
	begin
		if hstate = HActiveVideo and vstate = VActiveVideo then
			-- Always increment pixel x while active video
			int_incr_pixel_x <= true;

			int_incr_char_x <= int_pixel_local_x = CHAR_WIDTH - 1;

			int_incr_pixel_y <= int_incr_char_x and
				int_char_x = TXT_DISP_WIDTH - 1;

			int_incr_char_y <= int_incr_pixel_y and
				int_pixel_local_y = CHAR_HEIGHT - 1;

			int_incr_frame <= int_incr_char_y and
				int_char_y = TXT_DISP_HEIGHT - 1;
		else
			int_incr_pixel_x <= false;
			int_incr_char_x <= false;
			int_incr_pixel_y <= false;
			int_incr_char_y <= false;
			int_incr_frame <= false;
		end if;
	end process;
	
	count_position: process(clk, en, reset,	hstate, vstate,
		int_pixel_local_x, int_char_x,
		int_pixel_local_y, int_char_y,
		int_incr_pixel_x, int_incr_char_x,
		int_incr_pixel_y, int_incr_char_y)
	is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				int_pixel_local_x <= 0;
				int_char_x <= 0;
				int_pixel_local_y <= 0;
				int_char_y <= 0;
				
			elsif en = '1' then
				if int_incr_pixel_x then
					if int_pixel_local_x = CHAR_WIDTH - 1 then
						int_pixel_local_x <= 0;
					else
						int_pixel_local_x <= int_pixel_local_x + 1;
					end if;
				end if;
										
				if int_incr_char_x then
					if int_char_x = TXT_DISP_WIDTH - 1 then
						int_char_x <= 0;
					else
						int_char_x <= int_char_x + 1;
					end if;
				end if;
					
				if int_incr_pixel_y then
					if int_pixel_local_y = CHAR_HEIGHT - 1 then
						int_pixel_local_y <= 0;
					else
						int_pixel_local_y <= int_pixel_local_y + 1;
					end if;
				end if;
					
				if int_incr_char_y then
					if int_char_y = TXT_DISP_HEIGHT - 1 then
						int_char_y <= 0;
					else
						int_char_y <= int_char_y + 1;
					end if;
				end if;
				
			end if;
		end if;
	end process;
	
	pixel_local_x <= int_pixel_local_x;
	char_x <= int_char_x;
	pixel_local_y <= int_pixel_local_y;
	char_y <= int_char_y;
	
	incr_pixel_x <= int_incr_pixel_x;
	incr_char_x <= int_incr_char_x;
	incr_pixel_y <= int_incr_pixel_y;
	incr_char_y <= int_incr_char_y;
	incr_frame <= int_incr_frame;
	
end architecture;
