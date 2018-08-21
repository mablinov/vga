library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vga_util is
    type vga_videomode is record
        width: positive;
        height: positive;
        refresh_rate: positive;
    end record;

--    type vga_sync_timings is record
--        frontporch: positive;
--        syncpulse: positive;
--        backporch: positive;
--        activevideo: positive;
--    end record;

    type vga_hsync_timings is record
        hfrontporch: positive;
        hsyncpulse: positive;
        hbackporch: positive;
        hactivevideo: positive;
    end record;

    type vga_vsync_timings is record
        vfrontporch: positive;
        vsyncpulse: positive;
        vbackporch: positive;
        vactivevideo: positive;
    end record;

    type vga_hstate is (HFrontPorch, HSyncPulse, HBackPorch, HActiveVideo);
    type vga_vstate is (VFrontPorch, VSyncPulse, VBackPorch, VActiveVideo);

    function get_max_timing(timings: vga_hsync_timings) return positive;
    function get_max_timing(timings: vga_vsync_timings) return positive;

    function get_htimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_hsync_timings;
    function get_htimings_from_videomode(mode: vga_videomode)
        return vga_hsync_timings;
	function get_timer_limit(timings: vga_hsync_timings; cur_state: vga_hstate)
	    return positive;
    function get_next_hstate(state: vga_hstate) return vga_hstate;


    function get_vtimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_vsync_timings;
    function get_vtimings_from_videomode(mode: vga_videomode)
        return vga_vsync_timings;
	function get_timer_limit(timings: vga_vsync_timings; cur_state: vga_vstate)
	    return positive;
    function get_next_vstate(state: vga_vstate) return vga_vstate;

    component vga_hsync_ctrl is
	    generic	(
	        timings: vga_hsync_timings
	    );
	    port (
	        clk, en, reset: in std_logic;
		    hsync: out std_logic := '0';
		    timer: out natural range 0 to get_max_timing(timings) - 1 := 0;
		    state: out vga_hstate := vga_hstate'left
	    );
    end component;

    component vga_vsync_ctrl is
	    generic	(
	        timings: vga_vsync_timings
	    );
	    port (
	        clk, en, reset: in std_logic;
		    vsync: out std_logic := '0';
		    timer: out natural range 0 to get_max_timing(timings) - 1 := 0;
		    state: out vga_vstate := vga_vstate'left
	    );
    end component;

    component vga_sync_ctrl is
	    generic	(
	        mode: vga_videomode
        );
	    port (
	        clk, en, reset: in std_logic;
		    hsync, vsync: out std_logic;
            htimer: out natural range 0 to get_max_timing(
                get_htimings_from_videomode(mode)
            );
            vtimer: out natural range 0 to get_max_timing(
                get_vtimings_from_videomode(mode)
            );
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
    function get_max_timing(timings: vga_hsync_timings)
        return positive
    is
        variable a1: positive := timings.hfrontporch;
        variable a2: positive := timings.hsyncpulse;
        variable a3: positive := timings.hbackporch;
        variable a4: positive := timings.hactivevideo;

        variable max12: positive := a1;
        variable max34: positive := a3;
    begin
        if a1 > a2 then max12 := a1; else max12 := a2; end if;
        if a3 > a4 then max34 := a3; else max34 := a4; end if;
        if max12 > max34 then return max12; else return max34; end if;
    end function;

    function get_max_timing(timings: vga_vsync_timings)
        return positive
    is
        variable a1: positive := timings.vfrontporch;
        variable a2: positive := timings.vsyncpulse;
        variable a3: positive := timings.vbackporch;
        variable a4: positive := timings.vactivevideo;

        variable max12: positive := a1;
        variable max34: positive := a3;
    begin
        if a1 > a2 then max12 := a1; else max12 := a2; end if;
        if a3 > a4 then max34 := a3; else max34 := a4; end if;
        if max12 > max34 then return max12; else return max34; end if;
    end function;

    function get_htimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_hsync_timings
    is
        type triplet is array (natural range 0 to 2) of positive;
        variable videomode: triplet := (width, height, refresh_rate);
    begin
        if videomode = (640, 480, 60) then
            return vga_hsync_timings'(
                hfrontporch => 16,
                hsyncpulse => 96,
                hbackporch => 48,
                hactivevideo => 640
            );
        else
            report "Invalid videomode submitted to 'get_htimings_from_mode'"
                & ", namely " & positive'image(width)
                & " * " & positive'image(height)
                & " @ " & positive'image(refresh_rate)
                & " - resorting to default 640 * 480 @ 60"
                severity error;
            return vga_hsync_timings'(
                hfrontporch => 16,
                hsyncpulse => 96,
                hbackporch => 48,
                hactivevideo => 640
            );
        end if;
    end function;

    function get_htimings_from_videomode(mode: vga_videomode)
        return vga_hsync_timings is
    begin
        return get_htimings_from_mode(mode.width, mode.height,
            mode.refresh_rate);
    end function;

	function get_timer_limit(timings: vga_hsync_timings; cur_state: vga_hstate)
	    return positive
    is
	begin
	    case cur_state is
		    when HFrontPorch => return timings.hfrontporch - 1;
		    when HSyncPulse => return timings.hsyncpulse - 1;
		    when HBackPorch => return timings.hbackporch - 1;
		    when HActiveVideo => return timings.hactivevideo - 1;
	    end case;
	end function;

    function get_next_hstate(state: vga_hstate) return vga_hstate is
    begin
        case state is
            when HFrontPorch =>
                return HSyncPulse;
            when HSyncPulse =>
                return HBackPorch;
            when HBackPorch =>
                return HActiveVideo;
            when HActiveVideo =>
                return HFrontPorch;
        end case;
    end function;



    function get_vtimings_from_mode(width: positive; height: positive;
        refresh_rate: positive) return vga_vsync_timings
    is
        type triplet is array (natural range 0 to 2) of positive;
        variable videomode: triplet := (width, height, refresh_rate);
    begin
        if videomode = (640, 480, 60) then
            return vga_vsync_timings'(
                vfrontporch => 10 * 800,
                vsyncpulse => 2 * 800,
                vbackporch => 33 * 800,
                vactivevideo => 480 * 800
            );
        else
            report "Invalid videomode submitted to 'get_vtimings_from_mode'"
                & ", namely " & positive'image(width)
                & " * " & positive'image(height)
                & " @ " & positive'image(refresh_rate)
                & " - resorting to default 640 * 480 @ 60"
                severity error;
            return vga_vsync_timings'(
                vfrontporch => 16,
                vsyncpulse => 96,
                vbackporch => 48,
                vactivevideo => 640
            );
        end if;
    end function;

    function get_vtimings_from_videomode(mode: vga_videomode)
        return vga_vsync_timings is
    begin
        return get_vtimings_from_mode(mode.width, mode.height,
            mode.refresh_rate);
    end function;

	function get_timer_limit(timings: vga_vsync_timings; cur_state: vga_vstate)
	    return positive
    is
	begin
	    case cur_state is
		    when VFrontPorch => return timings.vfrontporch - 1;
		    when VSyncPulse => return timings.vsyncpulse - 1;
		    when VBackPorch => return timings.vbackporch - 1;
		    when VActiveVideo => return timings.vactivevideo - 1;
	    end case;
	end function;

    function get_next_vstate(state: vga_vstate) return vga_vstate is
    begin
        case state is
            when VFrontPorch =>
                return VSyncPulse;
            when VSyncPulse =>
                return VBackPorch;
            when VBackPorch =>
                return VActiveVideo;
            when VActiveVideo =>
                return VFrontPorch;
        end case;
    end function;

end package body;

