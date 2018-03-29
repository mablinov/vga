library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vga_util is
    type vga_sync_timings is record
        frontporch: positive;
        syncpulse: positive;
        backporch: positive;
        activevideo: positive;
    end record;

    function get_htimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_sync_timings;
    function get_vtimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_sync_timings;

--	subtype vga_4bit_signal is integer range 0 to 15;
--	type vga_channel is (Red, Green, Blue);
--	type vga_4bit_pixel is array (vga_channel range Red to Blue) of vga_4bit_signal;
	
	type vga_state is (
		HFrontPorch, HSyncPulse, HBackPorch, HActiveVideo,
		VFrontPorch, VSyncPulse, VBackPorch, VActiveVideo
	);
	subtype vga_hstate is vga_state range HFrontPorch to HActiveVideo;
	subtype vga_vstate is vga_state range VFrontPorch to VActiveVideo;

--	Component declarations:
    component vga_hsync is
	    generic	(
	        timings: vga_sync_timings
	    );
	    port (
	        clk	: in std_logic;
		    hsync : out std_logic;
		    transition: out std_logic;
		    state: out vga_hstate
	    );
    end component;

    component vga_vsync is
	    generic	(
	        timings: vga_sync_timings
	    );
	    port (
	        clk	: in std_logic;
		    vsync : out std_logic;
		    transition: out std_logic;
		    state: out vga_vstate
	    );
    end component;

end package;

package body vga_util is
    function get_htimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_sync_timings
    is
        type triplet is array (natural range 0 to 2) of positive;
        variable videomode: triplet := (width, height, refresh_rate);
    begin
        if videomode = (640, 480, 60) then
            return vga_sync_timings'(
                frontporch => 16,
                syncpulse => 96,
                backporch => 48,
                activevideo => 640
            );
        else
            report "Invalid videomode submitted to 'get_htimings_from_mode'"
                & ", namely " & positive'image(width)
                & " * " & positive'image(height)
                & " @ " & positive'image(refresh_rate)
                severity error;
        end if;
    end function;

    function get_vtimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_sync_timings
    is
        type triplet is array (natural range 0 to 2) of positive;
        variable videomode: triplet := (width, height, refresh_rate);
    begin
        if videomode = (640, 480, 60) then
            return vga_sync_timings'(
                frontporch => 10 * 800,
                syncpulse => 2 * 800,
                backporch => 33 * 800,
                activevideo => 480 * 800
            );
        else
            report "Invalid videomode submitted to 'get_vtimings_from_mode'"
                & ", namely " & positive'image(width)
                & " * " & positive'image(height)
                & " @ " & positive'image(refresh_rate)
                severity error;
        end if;
    end function;

end package body;

