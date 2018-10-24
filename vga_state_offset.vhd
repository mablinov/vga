library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;

entity vga_state_offset is
    generic (
        offset: integer := 0;
    );
    port (
        clk, en, reset: in std_logic;

        htimer_in: in natural range 0 to get_max_timing(
            get_htimings_from_videomode(mode)
        );
        vtimer_in: in natural range 0 to get_max_timing(
            get_vtimings_from_videomode(mode)
        );
		hstate_in: in vga_hstate;
		vstate_in: in vga_vstate;

        htimer_out: out natural range 0 to get_max_timing(
            get_htimings_from_videomode(mode)
        );
        vtimer_out: out natural range 0 to get_max_timing(
            get_vtimings_from_videomode(mode)
        );
		hstate_out: out vga_hstate;
    	vstate_out: out vga_vstate
    );
end entity;

architecture rtl of vga_state_offset is
begin

end architecture;

