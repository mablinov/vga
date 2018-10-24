library ieee;
use ieee.std_logic_1164.all;

use work.vga_util.all;

entity vp_mmanip_test is
	port (
		clk: in std_logic;
		vga_hs: out std_logic;
		vga_vs: out std_logic;
		vga_r: out std_logic_vector(3 downto 0);
		vga_g: out std_logic_vector(3 downto 0);
		vga_b: out std_logic_vector(3 downto 0);
		
		btnc, btnu, btnl, btnr, btnd: in std_logic;
		sw: in std_logic_vector(15 downto 0);
		dig_en: out std_logic_vector(7 downto 0);
		seg_cs: out std_logic_vector(7 downto 0);
		led: out std_logic_vector(9 downto 0)
	);
end entity;

architecture structural of vp_mmanip_test is
	signal addrb: std_logic_vector(15 downto 0) := X"0000";
	signal dib, dob: std_logic_vector(7 downto 0) := X"00";
	
	signal enb, regceb, web: std_logic := '0';
begin

	video_pipeline_inst: entity work.video_pipeline(rtl)
	generic map (
		videomode => (640, 480, 60)
	) port map (
		clk => clk, en => '1', reset => '0',
		hsync => vga_hs, vsync => vga_vs,
		red => vga_r, green => vga_g, blue => vga_b,
		
		addrb => addrb,
		dib => dib,
		dob => dob,
		enb => enb,
		regceb => regceb,
		web => web
	);
	
	mmanip_inst: entity work.memory_manipulator(rtl)
	port map (
		clk => clk,
		btnc => btnc,
		btnu => btnu,
		btnl => btnl,
		btnr => btnr,
		btnd => btnd,
		sw => sw,
		dig_en => dig_en,
		seg_cs => seg_cs,
		led => led,
		
		address => addrb,
		di => dib,
		do => dob,
		en => enb,
		regce => regceb,
		we => web
	);
	
end architecture;
