library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vga_util.all;

entity vga_pixel_clock_tb is
end entity;

architecture behavioural of vga_pixel_clock_tb is
    signal clk: std_logic := '0';
    signal pixel_clk: std_logic;
begin
    clk <= not clk after 5 ns; -- 100MHz

    uut: vga_pixel_clock
    port map (
        clk => clk,
        pixel_clk => pixel_clk
    );
end architecture;

