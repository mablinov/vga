library ieee;
use ieee.std_logic_1164.all;

library work;
use work.vga_util.all;

entity vga_hsync_tb is
end entity;

architecture behavioural of vga_hsync_tb is
    function str(arg: vga_hstate) return string is
    begin
        return vga_hstate'image(arg);
    end function;

    constant pixel_clock: time := 39.72194638 ns;
    signal last_time: time := 0 ps;

    signal clk: std_logic := '0';
    signal hsync: std_logic;
    signal transition: std_logic;
    signal state: vga_hstate;
begin
    clk <= not clk after pixel_clock / 2;

    report_state_change: process (state) is
        variable current_time: time := now;
    begin
        if state'event then last_time <= now; end if;
    
        report "At time " & time'image(now)
            & ": hsync = " & std_logic'image(hsync)
            & ", state = " & str(state)
            & ", delta in pixel clocks = " & real'image( real(time'pos(now) - time'pos(last_time)) / real(time'pos(pixel_clock)))
            & ", delta in time = " & time'image( time'val(time'pos(now) - time'pos(last_time)) )
            severity warning;
    end process;
    
    uut: vga_hsync
    generic map (
        timings => get_htimings_from_mode(640, 480, 60)
    ) port map (
        clk => clk,
        hsync => hsync,
        transition => transition,
        state => state
    );
end architecture;

