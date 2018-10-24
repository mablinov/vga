set outputDir bit
set srcdir ../../

set sources { vga_util.vhd vga_vsync_ctrl.vhd vga_hsync_ctrl.vhd \
    vga_sync_ctrl.vhd vga_pixel_clock.vhd vga_simple_test.vhd }
set constraints [list constraints.xdc]
set top_ent vga_simple_test
set part xc7a100tcsg324-1

set fp_sources {}
foreach src $sources { lappend fp_sources "$srcdir$src" }

set fp_constraints [list $constraints]

read_vhdl $fp_sources
read_xdc $fp_constraints

synth_design -top $top_ent -part $part
write_checkpoint checkpoint/post-synth.dcp

opt_design
write_checkpoint checkpoint/post-opt.dcp

place_design
write_checkpoint checkpoint/place-design.dcp

phys_opt_design
write_checkpoint checkpoint/phys-opt-design.dcp

route_design
write_checkpoint checkpoint/route-design.dcp

write_bitstream -force $outputDir/$top_ent.bit

