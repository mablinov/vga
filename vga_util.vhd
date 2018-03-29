library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vga_util is
    type vga_videomode is record
        width: positive;
        height: positive;
        refresh_rate: positive;
    end record;

    type vga_sync_timings is record
        frontporch: positive;
        syncpulse: positive;
        backporch: positive;
        activevideo: positive;
    end record;

    function get_greatest_delay(timings: vga_sync_timings)
        return positive;

    function get_htimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_sync_timings;
    function get_htimings_from_videomode(mode: vga_videomode)
        return vga_sync_timings;

    function get_vtimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_sync_timings;
    function get_vtimings_from_videomode(mode: vga_videomode)
        return vga_sync_timings;

	function int2slv(arg: integer; length: positive) return std_logic_vector;

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
    component vga_hsync_ctrl is
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

    component vga_vsync_ctrl is
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

    component vga_sync_ctrl is
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
    end component;

    component vga_pixel_clock is
	    port (
	        clk: in std_logic;
		    pixel_clk: out std_logic
	    );
    end component;

end package;

package body vga_util is
	function int2slv(arg: integer; length: positive) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(arg, length));
	end function;

    function get_greatest_delay(timings: vga_sync_timings)
        return positive
    is
        variable a1: positive := timings.frontporch;
        variable a2: positive := timings.syncpulse;
        variable a3: positive := timings.backporch;
        variable a4: positive := timings.activevideo;

        variable max12: positive := a1;
        variable max34: positive := a3;
    begin
        if a1 > a2 then max12 := a1; else max12 := a2; end if;
        if a3 > a4 then max34 := a3; else max34 := a4; end if;
        if max12 > max34 then return max12; else return max34; end if;
    end function;

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
                & " - resorting to default 640 * 480 @ 60"
                severity error;
            return vga_sync_timings'(
                frontporch => 16,
                syncpulse => 96,
                backporch => 48,
                activevideo => 640
            );
        end if;
    end function;

    function get_htimings_from_videomode(mode: vga_videomode)
        return vga_sync_timings is
    begin
        return get_htimings_from_mode(mode.width, mode.height,
            mode.refresh_rate);
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
                & " - resorting to default 640 * 480 @ 60"
                severity error;
            return vga_sync_timings'(
                frontporch => 16,
                syncpulse => 96,
                backporch => 48,
                activevideo => 640
            );
        end if;
    end function;

    function get_vtimings_from_videomode(mode: vga_videomode)
        return vga_sync_timings is
    begin
        return get_vtimings_from_mode(mode.width, mode.height,
            mode.refresh_rate);
    end function;

end package body;

