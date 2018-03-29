library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_sync_ctrl is
	generic	(
	    mode: vga_videomode
    );
	port (
	    clk: in std_logic;
		hsync: out std_logic;
		vsync: out std_logic;
		htransition: out std_logic;
		vtransition: out std_logic;
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
		hsync => hsync,
		transition => htransition,
		state => hstate
	);

	vsync_ctrl: vga_vsync_ctrl
	generic map (
	    timings => get_vtimings_from_videomode(mode)
	) port map (
		clk => clk,
		vsync => vsync,
        transition => vtransition,
        state => vstate
	);
end architecture;

