library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_vsync is
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

architecture behavioural of vga_vsync is
	function int2slv(arg: integer; length: positive) return std_logic_vector is
	begin return std_logic_vector(to_unsigned(arg, length)); end function;

    function max4(a1: positive; a2: positive; a3: positive; a4: positive)
        return positive
    is
        variable max12: positive := a1;
        variable max34: positive := a3;
    begin
        if a1 > a2 then max12 := a1; else max12 := a2; end if;
        if a3 > a4 then max34 := a3; else max34 := a4; end if;
        if max12 > max34 then return max12; else return max34; end if;
    end function;

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

	subtype vsync_counter_t is natural range 0 to max4(
	    timings.frontporch, timings.syncpulse,
	    timings.backporch, timings.activevideo
	) - 1;

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
	
