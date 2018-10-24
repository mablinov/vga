library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

-- rename to 'vga_text_frame_counter'
entity char_pos_counter is
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
		char_y: out natural range 0 to (videomode.height / CHAR_HEIGHT) - 1 := 0
		
		
	);
end entity;

architecture behavioural of char_pos_counter is
	constant TXT_DISP_WIDTH: positive := videomode.width / CHAR_WIDTH;
	constant TXT_DISP_HEIGHT: positive := videomode.height / CHAR_HEIGHT;
	
	signal int_pixel_local_x: natural range 0 to CHAR_WIDTH - 1 := 0;
	signal int_char_x: natural range 0 to TXT_DISP_WIDTH - 1 := 0;
	signal int_pixel_local_y: natural range 0 to CHAR_HEIGHT - 1 := 0;
	signal int_char_y: natural range 0 to TXT_DISP_HEIGHT - 1 := 0;
	
--	signal int_mem_addr: natural range 0 to MEM_BYTES - 1 := 0;
--	signal int_mem_bank: natural range 0 to MEM_BANKS - 1 := 0;

--	signal int_mem_addr_offset: natural range 0 to MEM_BYTES - 1 := 0;
--	signal int_mem_bank_offset: natural range 0 to MEM_BANKS - 1 := 0;

	signal incr_pixel_local_x: boolean := false;
	signal incr_char_x: boolean := false;
	signal incr_pixel_local_y: boolean := false;
	signal incr_char_y: boolean := false;
	signal incr_frame: boolean := false;

begin
	
	pixel_local_x <= int_pixel_local_x;
	char_x <= int_char_x;
	pixel_local_y <= int_pixel_local_y;
	char_y <= int_char_y;
	
--	mem_addr <= int_mem_addr;
--	mem_bank <= int_mem_bank;
	
	eval_incr_conds: process (int_pixel_local_x, int_char_x, int_pixel_local_y,
		int_char_y, hstate, vstate) is
	begin
		if hstate = HActiveVideo and vstate = VActiveVideo then
			-- Always increment pixel x while active video (trivial)
			incr_pixel_local_x <= true;

			incr_char_x <= int_pixel_local_x = CHAR_WIDTH - 1;

--			if int_pixel_local_x = CHAR_WIDTH - 1 then
--				incr_char_x <= true;
--			else
--				incr_char_x <= false;
--			end if;

			incr_pixel_local_y <= incr_char_x and
				int_char_x = TXT_DISP_WIDTH - 1;
			
--			if int_pixel_local_x = CHAR_WIDTH - 1 AND
--			   int_char_x = TXT_DISP_WIDTH - 1 then
--				incr_pixel_local_y <= true;
--			else
--				incr_pixel_local_y <= false;
--			end if;

			incr_char_y <= incr_pixel_local_y and
				int_pixel_local_y = CHAR_HEIGHT - 1;

--			if int_pixel_local_x = CHAR_WIDTH - 1 AND
--			   int_char_x = TXT_DISP_WIDTH - 1 AND
--			   int_pixel_local_y = CHAR_HEIGHT - 1 then
--				incr_char_y <= true;
--			else
--				incr_char_y <= false;
--			end if;

			incr_frame <= incr_char_y and
				int_char_y = TXT_DISP_HEIGHT - 1;

--			if int_pixel_local_x = CHAR_WIDTH - 1 AND
--			   int_char_x = TXT_DISP_WIDTH - 1 AND
--			   int_pixel_local_y = CHAR_HEIGHT - 1 AND
--			   int_char_y = TXT_DISP_HEIGHT - 1 then
--				incr_frame <= true;
--			else
--				incr_frame <= false;
--			end if;
		else
			incr_pixel_local_x <= false;
			incr_char_x <= false;
			incr_pixel_local_y <= false;
			incr_char_y <= false;
			incr_frame <= false;
		end if;
	end process;
	
	count_position: process(clk, en, reset, int_pixel_local_x,
		int_pixel_local_y, int_char_x, int_char_y,
		hstate, vstate)
	is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				int_pixel_local_x <= 0;
				int_char_x <= 0;
				int_pixel_local_y <= 0;
				int_char_y <= 0;
				
			elsif en = '1' then
				if incr_pixel_local_x then
					if int_pixel_local_x = CHAR_WIDTH - 1 then
						int_pixel_local_x <= 0;
					else
						int_pixel_local_x <= int_pixel_local_x + 1;
					end if;
				end if;
										
				if incr_char_x then
					if int_char_x = TXT_DISP_WIDTH - 1 then
						int_char_x <= 0;
					else
						int_char_x <= int_char_x + 1;
					end if;
				end if;
					
				if incr_pixel_local_y then
					if int_pixel_local_y = CHAR_HEIGHT - 1 then
						int_pixel_local_y <= 0;
					else
						int_pixel_local_y <= int_pixel_local_y + 1;
					end if;
				end if;
					
				if incr_char_y then
					if int_char_y = TXT_DISP_HEIGHT - 1 then
						int_char_y <= 0;
					else
						int_char_y <= int_char_y + 1;
					end if;
				end if;
				
			end if; -- en = '1'
		end if; -- rising_edge(clk)
	end process;
	

	
end architecture;
