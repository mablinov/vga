library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_state_fsm is
    generic (
	    timings: vga_sync_timings;
        htimer_init: natural := 0;
        hstate_init: vga_hstate := vga_hstate'left;
        vtimer_init: natural := 0;
        vstate_init: vga_vstate := vga_vstate'left
    );
    port (
        clk, en, reset: in std_logic;
		htimer: out natural range 0 to get_max_timing(timings.h) - 1;
		hstate: out vga_hstate;
		vtimer: out natural range 0 to get_max_timing(timings.v) - 1;
		vstate: out vga_vstate
    );
end entity;

architecture structural of vga_state_fsm is
begin

	h_fsm: entity work.vga_hstate_fsm(rtl)
	generic map (
		timings => timings.h,
		timer_init => htimer_init,
		state_init => hstate_init
	) port map (
		clk => clk, en => en, reset => reset,
		timer => htimer,
		state => hstate
	);
	
	v_fsm: entity work.vga_vstate_fsm(rtl)
	generic map (
		timings => timings.v,
		timer_init => vtimer_init,
		state_init => vstate_init
	) port map (
		clk => clk, en => en, reset => reset,
		timer => vtimer,
		state => vstate
	);
end architecture;

