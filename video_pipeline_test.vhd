library ieee;
use ieee.std_logic_1164.all;

use work.vga_util.all;

entity video_pipeline_test is
	port (
		clk: in std_logic;
		vga_hs: out std_logic;
		vga_vs: out std_logic;
		vga_r: out std_logic_vector(3 downto 0);
		vga_g: out std_logic_vector(3 downto 0);
		vga_b: out std_logic_vector(3 downto 0)
	);
end entity;

architecture structural of video_pipeline_test is
begin
	video_pipeline_inst: entity work.video_pipeline(rtl)
	generic map (
		videomode => (640, 480, 60)
	) port map (
		clk => clk, en => '1', reset => '0',
		hsync => vga_hs, vsync => vga_vs,
		red => vga_r, green => vga_g, blue => vga_b,
		
		addrb => X"0000",
		dib => X"00",
		dob => open,
		enb => '0',
		regceb => '0',
		web => '0'
	);
end architecture;
