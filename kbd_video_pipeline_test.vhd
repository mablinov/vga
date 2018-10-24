library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;
use work.ps2_util.all;

entity kbd_video_pipeline_test is
	port (
		clk: in std_logic;
		ps2_clk, ps2_data: in std_logic;
		vga_hs: out std_logic;
		vga_vs: out std_logic;
		vga_r: out std_logic_vector(3 downto 0);
		vga_g: out std_logic_vector(3 downto 0);
		vga_b: out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of kbd_video_pipeline_test is
	constant HEIGHT: natural := 60;
	constant WIDTH: natural := 80;
	
	-- PS2 controller signals
	signal keycode: ps2_keycode_T;
	signal kc_strobe, make, err: std_logic := '0';

	signal addr: std_logic_vector(15 downto 0) := X"0000";
	signal di, do: std_logic_vector(7 downto 0) := X"00";
	signal en, regce, we: std_logic := '0';
begin
	kbd_intf: process
	begin
		if rising_edge(clk) then
			case 

	video_pipeline_inst: entity work.video_pipeline(rtl)
	generic map (
		videomode => (640, 480, 60)
	) port map (
		clk => clk, en => '1', reset => '0',
		hsync => vga_hs, vsync => vga_vs,
		red => vga_r, green => vga_g, blue => vga_b,
		
		addrb => addr,
		dib => di
		dob => do,
		enb => en,
		regceb => regce,
		web => we
	);
	
	ps2_kbd_intf_inst: entity work.ps2_interface(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		
		keycode => keycode,
		kc_strobe => kc_strobe,
		make => make,
		err => err
	);
end architecture;
