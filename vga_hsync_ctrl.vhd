library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_hsync_ctrl is
	generic	(
	    timings: vga_hsync_timings
	);
	port (
	    clk, en, reset: in std_logic;
		hsync: out std_logic := '0';
		timer: out natural range 0 to get_max_timing(timings) - 1 := 0;
		state: out vga_hstate := vga_hstate'left
	);
end entity;

architecture behavioural of vga_hsync_ctrl is
    signal timer_int: natural range 0 to get_max_timing(timings) - 1 := 0;
	signal state_current, state_next: vga_hstate := vga_hstate'left;
begin
    timer <= timer_int;
	state <= state_current;

    register_video_state: process (clk, en, reset, state_next)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state_current <= HFrontPorch;
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
            state_next <= get_next_hstate(state_current);
        else
            state_next <= state_current;
        end if;
    end process;

    update_hsync_timer: process (clk, en, reset, state_current, timer_int)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                timer_int <= 0;
            elsif en = '1' then
                if timer_int >= get_timer_limit(timings, state_current) then
                    timer_int <= 0;
                else
                    timer_int <= timer_int + 1;
                end if;
            end if;
        end if;
    end process;
	
	emit_syncpulse: process (clk, en, reset, state_current, state_next, timer_int)
        variable on_state_transition: boolean :=
            timer_int = get_timer_limit(timings, state_current);
	begin
	    if rising_edge(clk) then
	        if reset = '1' then
	            hsync <= '0';
	        elsif en = '1' then
                if on_state_transition then
                    if state_next = HSyncPulse then
                        hsync <= '1';
                    else
                        hsync <= '0';
                    end if;
                end if;
            end if;
        end if;
	end process;

end architecture;
	
