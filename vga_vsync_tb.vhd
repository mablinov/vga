library ieee;
use ieee.std_logic_1164.all;

library work;
use work.vga_util.all;

entity vga_vsync_tb is
end entity;

architecture behavioural of vga_vsync_tb is
    function str(arg: vga_vstate) return string is
    begin
        return vga_vstate'image(arg);
    end function;

    constant pixel_clock: time := 39.72194638 ns;
    signal last_time: time := 0 ps;

    signal clk: std_logic := '0';
    signal vsync: std_logic;
    signal transition: std_logic;
    signal state: vga_vstate;
begin
    clk <= not clk after pixel_clock / 2;

    report_state_change: process (state) is
        variable current_time: time := now;
    begin
        if state'event then last_time <= now; end if;
    
        report "At time " & time'image(now)
            & ": vsync = " & std_logic'image(vsync)
            & ", state = " & str(state)
            & ", delta in pixel clocks = " & real'image( real(time'pos(now) - time'pos(last_time)) / real(time'pos(pixel_clock)))
            & ", delta in time = " & time'image( time'val(time'pos(now) - time'pos(last_time)) )
            severity warning;
    end process;
    
    uut: vga_vsync_ctrl
    generic map (
        timings => get_vtimings_from_mode(640, 480, 60)
    ) port map (
        clk => clk,
        vsync => vsync,
        transition => transition,
        state => state
    );
end architecture;

