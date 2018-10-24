library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_state_fsm_tb is
end entity;

architecture structural of vga_state_fsm_tb is
	    constant timings: vga_sync_timings := get_timings_from_videomode(640, 480, 60);
        constant htimer_init: natural := 0;
        constant hstate_init: vga_hstate := vga_hstate'left;
        constant vtimer_init: natural := 0;
        constant vstate_init: vga_vstate := vga_vstate'left;

        signal clk, en, reset: std_logic := '0';
		signal htimer: natural range 0 to get_max_timing(timings.h) - 1;
		signal hstate: vga_hstate;
		signal vtimer: natural range 0 to get_max_timing(timings.v) - 1;
		signal vstate: vga_vstate;
begin

	en <= '1';
	
	process
	begin
		wait for 5 ns;
		clk <= not clk;
	end process;

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

