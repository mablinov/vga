library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vga_util.all;

entity vga_simple_test is
    port (
        clk: in std_logic;
    
        vga_r: out std_logic_vector(3 downto 0);
        vga_g: out std_logic_vector(3 downto 0);
        vga_b: out std_logic_vector(3 downto 0);
        vga_hs: out std_logic;
        vga_vs: out std_logic
    );
end entity;

architecture behavioural of vga_simple_test is
    signal pixel_clk: std_logic;
    signal hstate: vga_hstate;
    signal vstate: vga_vstate;
begin
    pixel_clock: vga_pixel_clock
    port map (
        clk => clk,
        pixel_clk => pixel_clk
    );

    sync_ctrl: vga_sync_ctrl
    generic map (
        mode => (width => 640, height => 480, refresh_rate => 60)
    ) port map (
        clk => pixel_clk,
        en => '1',
        reset => '0',
        hsync => vga_hs,
        vsync => vga_vs,
        htimer => open,
        vtimer => open,
        hstate => hstate,
        vstate => vstate
    );

    emit_pixel: process (hstate, vstate)
    begin
        if hstate = HActiveVideo and vstate = VActiveVideo then
            vga_r <= (others => '1');
            vga_g <= (others => '1');
            vga_b <= (others => '1');
        else
            vga_r <= (others => '0');
            vga_g <= (others => '0');
            vga_b <= (others => '0');
        end if;
    end process;
    
end architecture;
