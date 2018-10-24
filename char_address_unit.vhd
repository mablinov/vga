library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity char_address_unit is
	generic (
		MEM_BYTES: positive := 2 ** 12;
		MEM_BANKS: positive := 2
	);
	port (
		clk, en, reset: in std_logic;
		hstate: in vga_hstate;
		vstate: in vga_vstate;

		incr_frame: in boolean;
		incr_char_y: in boolean;
		incr_pixel_y: in boolean;
		incr_char_x: in boolean;
		
		addr_offset: in natural range 0 to MEM_BYTES - 1;
		bank_offset: in natural range 0 to MEM_BANKS - 1;
		offset_reg_ce: in std_logic;
		mem_addr: out natural range 0 to MEM_BYTES - 1 := 0;
		mem_bank: out natural range 0 to MEM_BANKS - 1 := 0
	);
end entity;

architecture rtl of char_address_unit is
	signal int_mem_addr: natural range 0 to MEM_BYTES - 1 := 0;
	signal int_mem_bank: natural range 0 to MEM_BANKS - 1 := 0;
	
	signal start_line_mem_addr: natural range 0 to MEM_BYTES - 1 := 0;
	signal start_line_mem_bank: natural range 0 to MEM_BANKS - 1 := 0;

	signal int_mem_addr_offset: natural range 0 to MEM_BYTES - 1 := 0;
	signal int_mem_bank_offset: natural range 0 to MEM_BANKS - 1 := 0;

begin
	mem_addr <= int_mem_addr;
	mem_bank <= int_mem_bank;
	
	resolve_mem_loc: process (clk, en, reset, hstate, vstate,
		int_mem_addr, int_mem_bank,
		start_line_mem_addr, start_line_mem_bank,
		int_mem_addr_offset, int_mem_bank_offset,
		addr_offset, bank_offset, offset_reg_ce,
		incr_frame, incr_char_y, incr_pixel_y, incr_char_x
	) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				int_mem_addr <= 0;
				int_mem_bank <= 0;
				
				start_line_mem_addr <= 0;
				start_line_mem_bank <= 0;
				
				int_mem_addr_offset <= 0;
				int_mem_bank_offset <= 0;
				
			elsif en = '1' then
				if not (hstate = HActiveVideo and vstate = VActiveVideo) then
					if offset_reg_ce = '1' then
						int_mem_addr <= addr_offset;
						int_mem_bank <= bank_offset;
					
						start_line_mem_addr <= addr_offset;
						start_line_mem_bank <= bank_offset;
					
						int_mem_addr_offset <= addr_offset;
						int_mem_bank_offset <= bank_offset;
					end if;
				
				elsif hstate = HActiveVideo and vstate = VActiveVideo then
					if incr_frame then
						-- Reset the pointer position
						int_mem_addr <= int_mem_addr_offset;
						int_mem_bank <= int_mem_bank_offset;
					
						-- Reset the start line too
						start_line_mem_addr <= int_mem_addr_offset;
						start_line_mem_bank <= int_mem_bank_offset;
						
					elsif incr_char_y then
						-- Increment as usual, but also set the
						-- start line variables so we know where to jump
						-- back to when we get to the end of this line.
						if int_mem_addr = MEM_BYTES - 1 then
							int_mem_addr <= 0;
							start_line_mem_addr <= 0;
							
							if int_mem_bank = MEM_BANKS - 1 then
								int_mem_bank <= 0;
								start_line_mem_bank <= 0;
							else
								int_mem_bank <= int_mem_bank + 1;
								start_line_mem_bank <= int_mem_bank + 1;
							end if;
						else
							int_mem_addr <= int_mem_addr + 1;
							start_line_mem_addr <= int_mem_addr + 1;
							
							-- line below is important
							start_line_mem_bank <= int_mem_bank;
						end if;
						
					elsif incr_pixel_y then
						-- Jump back to the start of the line
						int_mem_addr <= start_line_mem_addr;
						int_mem_bank <= start_line_mem_bank;
					
					elsif incr_char_x then
						-- Increment normally
						if int_mem_addr = MEM_BYTES - 1 then
							int_mem_addr <= 0;
						
							if int_mem_bank = MEM_BANKS - 1 then
								int_mem_bank <= 0;
							else
								int_mem_bank <= int_mem_bank + 1;
							end if;
						else
							int_mem_addr <= int_mem_addr + 1;
						end if;
					end if;
				end if; -- active_video = true
			end if; -- en = '1'
		end if; -- rising_edge(clk)
	end process;
end architecture;

