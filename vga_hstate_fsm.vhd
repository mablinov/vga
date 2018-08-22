library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_hstate_fsm is
    generic (
	    timings: vga_hsync_timings
        timer_init: natural := 0;
        state_init: vga_hstate := vga_hstate'left
    );
    port (
        clk, en, reset: in std_logic;
		timer: out natural range 0 to get_max_timing(timings) - 1 := timer_init;
		state: out vga_hstate := state_init
    );
end entity;

architecture behavioural of vga_hstate_fsm is
    signal timer_int: natural range 0 to get_max_timing(timings) - 1 := timer_init;
	signal state_current, state_next: vga_hstate := state_init;
begin
    timer <= timer_int;
	state <= state_current;

    register_video_state: process (clk, en, reset, state_next)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state_current <= state_init;
            elsif en = '1' then
                state_current <= state_next;
            end if;
        end if;
    end process;

    decide_next_state: process (state_current, timer_int)
        variable timer_reached_limit: boolean :=
            timer_int = get_timer_limit(timings, state_current);
    begin
        if timer_reached_limit then
            state_next <= get_next_vga_state(state_current);
        else
            state_next <= state_current;
        end if;
    end process;

    update_hsync_timer: process (clk, en, reset, state_current, timer_int)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                timer_int <= timer_init;
            elsif en = '1' then
                if timer_int >= get_timer_limit(timings, state_current) then
                    timer_int <= 0;
                else
                    timer_int <= timer_int + 1;
                end if;
            end if;
        end if;
    end process;

end architecture;

