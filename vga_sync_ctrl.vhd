library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_sync_ctrl is
	generic	(
	    timings: vga_sync_timings
    );
	port (
	    clk, en, reset: in std_logic;
		hsync, vsync: out std_logic;
        htimer: out natural range 0 to get_max_timing(timings.h);
        vtimer: out natural range 0 to get_max_timing(timings.v);
		hstate: out vga_hstate;
		vstate: out vga_vstate
	);
end entity;

architecture structural of vga_sync_ctrl is
begin
	hsync_ctrl: vga_hsync_ctrl
	generic map (
	    timings => timings.h
    ) port map (
		clk => clk,
		en => en,
		reset => reset,
		hsync => hsync,
        timer => htimer,
		state => hstate
	);

	vsync_ctrl: vga_vsync_ctrl
	generic map (
	    timings => timings.v
	) port map (
		clk => clk,
		en => en,
		reset => reset,
		vsync => vsync,
        timer => vtimer,
        state => vstate
	);
end architecture;

