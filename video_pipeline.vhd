library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_util.all;
use work.glyph_util.all;

--enum __font_config {
--	BLINK = 0x80,
--	BRIGHT = 0x08,
--
--	BG_BLACK = 0x00,
--	BG_BLUE = 0x10,
--	BG_GREEN = 0x20,
--	BG_CYAN = 0x30,
--	BG_RED = 0x40,
--	BG_MAGENTA = 0x50,
--	BG_BROWN = 0x60,
--	BG_LIGHTGRAY = 0x70,
--	
--	FG_BLACK = BG_BLACK,
--	FG_BLUE = BG_BLUE >> 4,
--	FG_GREEN = BG_GREEN >> 4,
--	FG_CYAN = BG_CYAN >> 4,
--	FG_RED = BG_RED >> 4,
--	FG_MAGENTA = BG_MAGENTA >> 4,
--	FG_BROWN = BG_BROWN >> 4,
--	FG_LIGHTGRAY = BG_LIGHTGRAY >> 4
--};

entity video_pipeline is
	generic (
		videomode: vga_videomode := (640, 480, 60)
	);
	port (
		clk, en, reset: in std_logic;
		hsync, vsync: out std_logic := '0';
		red, green, blue: out std_logic_vector(3 downto 0) := X"0";

		addrb: in std_logic_vector(15 downto 0);
		dib: in std_logic_vector(7 downto 0);
		dob: out std_logic_vector(7 downto 0) := X"00";
		enb, regceb, web: in std_logic
	);
end entity;

architecture rtl of video_pipeline is
	-- Predefined control values
	constant CHAR_WIDTH: natural := 8;
	constant CHAR_HEIGHT: natural := 8;

	-- Helper variable
	constant timings: vga_sync_timings := get_timings_from_videomode(videomode);
	
	subtype htimer_T is natural range 0 to get_max_timing(timings.h);
	subtype vtimer_T is natural range 0 to get_max_timing(timings.v);
	
	type vga_beam_state is record
		htimer: htimer_T;
		vtimer: vtimer_T;
		hstate: vga_hstate;
		vstate: vga_vstate;
	end record;
	constant VGA_BEAM_STATE_INIT: vga_beam_state :=	(
		htimer => 0, vtimer => 0,
		hstate => vga_hstate'left, vstate => vga_vstate'left
	);
	
	type vga_text_counters is record
		pixel_local_x: natural range 0 to CHAR_WIDTH - 1;
		char_x: natural range 0 to (videomode.width / CHAR_WIDTH) - 1;
		pixel_local_y: natural range 0 to CHAR_HEIGHT - 1;
		char_y: natural range 0 to (videomode.height / CHAR_HEIGHT) - 1;

		incr_pixel_x: boolean;
		incr_char_x: boolean;
		incr_pixel_y: boolean;
		incr_char_y: boolean;
		incr_frame: boolean;
		
		addr: std_logic_vector(15 downto 0);
	end record;
	constant VGA_TEXT_COUNTERS_INIT: vga_text_counters := (
		pixel_local_x => 0, char_x => 0,
		pixel_local_y => 0, char_y => 0,
		
		incr_pixel_x => false,
		incr_char_x => false,
		incr_pixel_y => false,
		incr_char_y => false,
		incr_frame => false,
		
		addr => X"0000"
	);
	
	type vga_pipeline_stage is record
		bs: vga_beam_state;
		tc: vga_text_counters;
	end record;
	constant VGA_PIPELINE_STAGE_INIT: vga_pipeline_stage :=	(
		bs => VGA_BEAM_STATE_INIT,
		tc => VGA_TEXT_COUNTERS_INIT
	);
	
	type vga_pipeline is array (positive range 1 to 6) of vga_pipeline_stage;
	constant VGA_PIPELINE_INIT: vga_pipeline :=
		(others => VGA_PIPELINE_STAGE_INIT);
	
	type scratchpad_T is record
		ascii_char: std_logic_vector(7 downto 0);
		glyph: glyph_bitmap;
		row: std_logic_vector(0 to 7);
		pixel: std_logic;
	end record;
	
	function have_active_video(stage: vga_pipeline_stage) return boolean is
	begin
		if stage.bs.hstate = HActiveVideo and stage.bs.vstate = VActiveVideo then
			return true;
		else
			return false;
		end if;
	end function;

	function have_new_char(stage: vga_pipeline_stage) return boolean is
	begin
		if have_active_video(stage) and stage.tc.pixel_local_x = 0 then
			return true;
		else
			return false;
		end if;
	end function;
	
	-- *** Signals ***
	
	signal pixel_clk: std_logic := '0';
	
	signal new_stage: vga_pipeline_stage := VGA_PIPELINE_STAGE_INIT;
	signal pipeline: vga_pipeline := VGA_PIPELINE_INIT;

	signal scratchpad: scratchpad_T := (
		ascii_char => X"00",
		glyph => get_gb(nul),
		row => X"00",
		pixel => '0'
	);

	-- Memory interface		
	signal addra: std_logic_vector(15 downto 0) := X"0000";
	signal doa: std_logic_vector(7 downto 0) := X"00";
	signal ena, regcea: std_logic := '0';
	
begin
	addra <= pipeline(1).tc.addr;
	scratchpad.ascii_char <= doa;
	
	pipeline_event_dispatcher: process (pixel_clk, new_stage, pipeline,
		scratchpad)
	is
		variable char: character;
	begin
		if have_new_char(pipeline(1)) then
			ena <= '1';
		else
			ena <= '0';
		end if;
		
		if have_new_char(pipeline(2)) then
			regcea <= '1';
		else
			regcea <= '0';
		end if;
		
		char := character'val( to_integer(unsigned(scratchpad.ascii_char)) );
		
		if rising_edge(pixel_clk) then
			if have_new_char(pipeline(3)) then
				scratchpad.glyph <= get_gb(char);
			end if;
		end if;

		if rising_edge(pixel_clk) then
			if have_active_video(pipeline(4)) then
				scratchpad.row <=
					scratchpad.glyph(pipeline(4).tc.pixel_local_y);
			end if;
		end if;

		if rising_edge(pixel_clk) then
			if have_active_video(pipeline(5)) then
				scratchpad.pixel <=
					scratchpad.row(pipeline(5).tc.pixel_local_x);
			end if;
		end if;
	end process;
	
	
	shift_pipeline_forward: process (pixel_clk, en, reset, new_stage, pipeline) is
	begin
		if rising_edge(pixel_clk) then
			if reset = '1' then
				pipeline <= VGA_PIPELINE_INIT;
				
			elsif en = '1' then
				pipeline(1) <= new_stage;
				pipeline(2) <= pipeline(1);
				pipeline(3) <= pipeline(2);
				pipeline(4) <= pipeline(3);
				pipeline(5) <= pipeline(4);
				pipeline(6) <= pipeline(5);
			end if;
		end if;
	end process;
	
	
	drive_output: process (new_stage, pipeline, scratchpad) is
		variable ActiveVideo: boolean;
		variable addr_slv: std_logic_vector(15 downto 0);
		
		variable output_stage: vga_pipeline_stage;
	begin
		ActiveVideo := output_stage.bs.hstate = HActiveVideo
		  and output_stage.bs.vstate = VActiveVideo;
		
		output_stage := pipeline(6);
--		output_stage := new_stage;
	
		addr_slv := output_stage.tc.addr;
	
		if output_stage.bs.hstate = HSyncPulse then
			hsync <= '1';
		else
			hsync <= '0';
		end if;
		
		if output_stage.bs.vstate = VSyncPulse then
			vsync <= '1';
		else
			vsync <= '0';
		end if;
		
		if ActiveVideo then
			if addr_slv /= addrb then
				if scratchpad.pixel = '1' then
--					red <= "1111";
					green <= "1111";
--					blue <= "1111";
				else
--					red <= "0000";
					green <= "0000";
--					blue <= "0000";
				end if;
			
			else
				-- Invert colours
				if scratchpad.pixel = '1' then
--					red <= "0000";
					green <= "0000";
--					blue <= "0000";
				else
--					red <= "1111";
					green <= "1111";
--					blue <= "1111";
				end if;
			end if;
				
--			green <= addr_slv(3 downto 0);
--			red <= addr_slv(7 downto 4);
--			blue <= addr_slv(11 downto 8);
		else
			red <= "0000";
			green <= "0000";
			blue <= "0000";
		end if;

	end process;
	
	-- *** Components ***
	
	fb0: entity work.ramb64x8(structural)
	port map (
		clka => pixel_clk,
		addra => addra,
		dia => X"00",
		doa => doa,
		
		ena => ena,
		regcea => regcea,
		rstrama => '0',
		rstrega => '0',
		wea => '0',
		
		clkb => clk,
		addrb => addrb,
		dib => dib,
		dob => dob,
		
		enb => enb,
		regceb => regceb,
		rstramb => '0',
		rstregb => '0',
		web => web
	);
	
	cau_inst: entity work.character_address_unit(rtl)
	port map (
		clk => pixel_clk, reset => '0',
		
		incr_frame => new_stage.tc.incr_frame,
		incr_char_y => new_stage.tc.incr_char_y,
		incr_pixel_y => new_stage.tc.incr_pixel_y,
		incr_char_x => new_stage.tc.incr_char_x,

		offset => X"0000",
		load_offset => '0',

		addr => new_stage.tc.addr
	);
	
	
	vtfc_inst: entity work.vga_text_frame_counter(rtl)
	generic map (
		videomode => videomode,
		CHAR_WIDTH => CHAR_WIDTH,
		CHAR_HEIGHT => CHAR_HEIGHT
	) port map (
		clk => pixel_clk, en => en, reset => reset,
		hstate => new_stage.bs.hstate,
		vstate => new_stage.bs.vstate,
		
		pixel_local_x => new_stage.tc.pixel_local_x,
		char_x => new_stage.tc.char_x,
		pixel_local_y => new_stage.tc.pixel_local_y,
		char_y => new_stage.tc.char_y,

		incr_pixel_x => new_stage.tc.incr_pixel_x,
		incr_char_x => new_stage.tc.incr_char_x,
		incr_pixel_y => new_stage.tc.incr_pixel_y,
		incr_char_y => new_stage.tc.incr_char_y,
		incr_frame => new_stage.tc.incr_frame
	);
	
	vs_fsm: entity work.vga_state_fsm(structural)
	generic map (
		timings => get_timings_from_videomode(videomode)
	) port map (
		clk => pixel_clk, en => en, reset => reset,
		
		htimer => new_stage.bs.htimer,
		hstate => new_stage.bs.hstate,
		vtimer => new_stage.bs.vtimer,
		vstate => new_stage.bs.vstate
	);
	
	vga_pixel_clk_inst: vga_pixel_clock
	port map (
		clk => clk,
		pixel_clk => pixel_clk
	);
end architecture;

