library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_vsync_ctrl is
	generic	(
	    timings: vga_sync_timings
	);
	port (
	    clk	: in std_logic;
		vsync : out std_logic;
		transition: out std_logic;
		state: out vga_vstate
	);
end entity;

architecture behavioural of vga_vsync_ctrl is
	function get_next_state(cur_state: vga_vstate) return vga_vstate is
    begin
	    case cur_state is
	        when VFrontPorch => return VSyncPulse;
	        when VSyncPulse => return VBackPorch;
	        when VBackPorch => return VActiveVideo;
	        when VActiveVideo => return VFrontPorch;
        end case;
    end function;

	function get_counter_limit(cur_state: vga_vstate) return natural is
	begin
	    case cur_state is
		    when VFrontPorch => return timings.frontporch - 1;
		    when VSyncPulse => return timings.syncpulse - 1;
		    when VBackPorch => return timings.backporch - 1;
		    when VActiveVideo => return timings.activevideo - 1;
	    end case;
	end function;

	subtype vsync_counter_t is natural
	    range 0 to get_greatest_delay(timings) - 1;

	signal state_cntr: vsync_counter_t := 0;
	signal cur_state: vga_vstate := VFrontPorch;
begin
	state <= cur_state;

	state_machine: process (clk)
	begin
		if rising_edge(clk) then
			if state_cntr = get_counter_limit(cur_state) then
    			cur_state <= get_next_state(cur_state);
				state_cntr <= 0;
			else
				state_cntr <= state_cntr + 1;
			end if;
		end if;
	end process;
	
	emit_syncpulse: process (cur_state)
	begin
        if cur_state = VSyncPulse then
            vsync <= '1';
        else
            vsync <= '0';
        end if;
	end process;
	
	emit_transition: process (cur_state, state_cntr)
	begin
	    if state_cntr = get_counter_limit(cur_state) then
	        transition <= '1';
	    else
	        transition <= '0';
        end if;
    end process;
end architecture;
	
