set sources {
	../../vga_util.vhd \
	../../vga_vsync_ctrl.vhd \
	../../vga_hsync_ctrl.vhd \
	../../vga_sync_ctrl.vhd \
	../../vga_pixel_clock.vhd \
\
	../../vga_hstate_fsm.vhd \
	../../vga_vstate_fsm.vhd \
	../../vga_state_fsm.vhd \
\
	../../../glyph/glyph_util.vhd \
\
	../../vga_text_frame_counter.vhd \
	../../char_address_unit.vhd \
	../../framebuffer36E1x8.vhd \
\
	../../video_pipeline.vhd \
	../../video_pipeline_test.vhd \
\
	../../../ram/ramb64x1.vhd \
	../../../ram/ramb64x8.vhd \
\
	../../character_address_unit.vhd \
}

set constraints "constraints.xdc"
set top_ent video_pipeline_test
set part xc7a100tcsg324-1
set outputDir bit

read_vhdl $sources
read_xdc $constraints
