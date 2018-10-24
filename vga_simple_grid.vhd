library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vga_util.all;

entity vga_simple_grid is
    port (
        clk: in std_logic;
    
        vga_r: out std_logic_vector(3 downto 0);
        vga_g: out std_logic_vector(3 downto 0);
        vga_b: out std_logic_vector(3 downto 0);
        vga_hs: out std_logic;
        vga_vs: out std_logic
    );
end entity;

architecture rtl of vga_simple_grid is
	function int2slv(arg: integer; length: positive) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(arg, length));
	end function;

    signal pixel_clk: std_logic;
    signal hstate: vga_hstate;
    signal vstate: vga_vstate;
    
    signal pc_x: natural range 0 to 640 - 1 := 0;
    signal pc_y: natural range 0 to 480 - 1 := 0;

begin
    current_pixel: process (pixel_clk, hstate, vstate)
    begin
        if rising_edge(pixel_clk) then
            if hstate = HActiveVideo and vstate = VActiveVideo then
                if pc_x = 640 - 1 then
                    pc_x <= 0;
                    
                    if pc_y = 480 - 1 then
                        pc_y <= 0;
                    else
                        pc_y <= pc_y + 1;
                    end if;
                else
                    pc_x <= pc_x + 1;
                end if;
            end if;
        end if;
    end process;

    emit_pixel: process (pc_y, pc_x, hstate, vstate)
    begin
    	if hstate = HActiveVideo and vstate = VActiveVideo then
            vga_r <= int2slv(pc_x mod 2 ** vga_g'length, vga_g'length);
			vga_b <= int2slv(pc_y mod 2 ** vga_b'length, vga_b'length);
			vga_g <= (others => '0');
        else
        	vga_r <= (others => '0');
        	vga_g <= (others => '0');
        	vga_b <= (others => '0');
        end if;
    end process;

    pixel_clock: vga_pixel_clock
    port map (
        clk => clk,
        pixel_clk => pixel_clk
    );

    sync_ctrl: vga_sync_ctrl
    generic map (
        timings => get_timings_from_videomode(width => 640, height => 480,
            refresh_rate => 60)
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

end architecture;
