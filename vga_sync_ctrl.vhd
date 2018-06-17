library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_sync_ctrl is
	generic	(
	    mode: vga_videomode
    );
	port (
	    clk, en, reset: in std_logic;
		hsync, vsync: out std_logic;
        htimer: out natural range 0 to get_max_timing(
            get_htimings_from_videomode(mode)
        );
        vtimer: out natural range 0 to get_max_timing(
            get_vtimings_from_videomode(mode)
        );
		hstate: out vga_hstate;
		vstate: out vga_vstate
	);
end entity;

architecture structural of vga_sync_ctrl is
begin
	hsync_ctrl: vga_hsync_ctrl
	generic map (
	    timings => get_htimings_from_videomode(mode)
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
	    timings => get_vtimings_from_videomode(mode)
	) port map (
		clk => clk,
		en => en,
		reset => reset,
		vsync => vsync,
        timer => vtimer,
        state => vstate
	);
end architecture;

