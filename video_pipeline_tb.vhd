library ieee;
use ieee.std_logic_1164.all;

use work.vga_util.all;

entity video_pipeline_tb is
end entity;

architecture rtl of video_pipeline_tb is
	signal clk, en, reset: std_logic := '0';
	signal vga_hs, vga_vs: std_logic := '0';
	signal vga_r, vga_g, vga_b: std_logic_vector(3 downto 0) := (others => '0');
begin

	process
	begin
		wait for 5 ns;
		clk <= not clk;
	end process;

	video_pipeline_inst: entity work.video_pipeline(rtl)
	generic map (
		videomode => (640, 480, 60)
	) port map (
		clk => clk, en => '1', reset => '0',
		hsync => vga_hs, vsync => vga_vs,
		red => vga_r, green => vga_g, blue => vga_b
	);

end architecture;
