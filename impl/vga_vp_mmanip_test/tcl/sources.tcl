set sources {
	../../vga_util.vhd \
	../../vga_pixel_clock.vhd \
\
	../../vga_hstate_fsm.vhd \
	../../vga_vstate_fsm.vhd \
	../../vga_state_fsm.vhd \
\
	../../../glyph/glyph_util.vhd \
\
	../../vga_text_frame_counter.vhd \
\
	../../video_pipeline.vhd \
	../../video_pipeline_test.vhd \
\
	../../../ram/ramb64x1.vhd \
	../../../ram/ramb64x8.vhd \
\
	../../character_address_unit.vhd \
\
	../../../signals/debouncer.vhd \
	../../../signals/strobe_if_changed.vhd \
	../../../ssd/ssd_ctrl.vhd \
	../../../mmanip/button_press_sanitizer.vhd \
	../../../mmanip/memory_manipulator.vhd \
	../../../mmanip/mmanip_inst.vhd \
\
	../../vp_mmanip_test.vhd \
}

set constraints "constraints.xdc"
set top_ent vp_mmanip_test
set part xc7a100tcsg324-1
set outputDir bit

read_vhdl $sources
read_xdc $constraints
