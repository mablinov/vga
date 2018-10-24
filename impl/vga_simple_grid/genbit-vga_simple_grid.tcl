set outputDir bit
set srcdir ../../

set sources { vga_util.vhd vga_vsync_ctrl.vhd vga_hsync_ctrl.vhd \
    vga_sync_ctrl.vhd vga_pixel_clock.vhd vga_simple_grid.vhd }
set constraints [list constraints.xdc]
set top_ent vga_simple_grid
set part xc7a100tcsg324-1

set fp_sources {}
foreach src $sources { lappend fp_sources "$srcdir$src" }

set fp_constraints [list $constraints]

read_vhdl $fp_sources
read_xdc $fp_constraints

synth_design -top $top_ent -part $part

opt_design
place_design
phys_opt_design

route_design
write_bitstream -force $outputDir/$top_ent.bit

