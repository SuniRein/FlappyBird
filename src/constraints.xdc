# Main clock
set_property PACKAGE_PIN AC18 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]

## T = 10 ns; f = 100 MHz
create_clock -period 10.000 -name clk [get_ports "clk"]

# VGA
set_property PACKAGE_PIN N21 [get_ports {vga_red[0]}]
set_property PACKAGE_PIN N22 [get_ports {vga_red[1]}]
set_property PACKAGE_PIN R21 [get_ports {vga_red[2]}]
set_property PACKAGE_PIN P21 [get_ports {vga_red[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[3]}]
set_property PACKAGE_PIN R22 [get_ports {vga_green[0]}]
set_property PACKAGE_PIN R23 [get_ports {vga_green[1]}]
set_property PACKAGE_PIN T24 [get_ports {vga_green[2]}]
set_property PACKAGE_PIN T25 [get_ports {vga_green[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[3]}]
set_property PACKAGE_PIN T20 [get_ports {vga_blue[0]}]
set_property PACKAGE_PIN R20 [get_ports {vga_blue[1]}]
set_property PACKAGE_PIN T22 [get_ports {vga_blue[2]}]
set_property PACKAGE_PIN T23 [get_ports {vga_blue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[3]}]
set_property PACKAGE_PIN M22 [get_ports vga_hs]
set_property PACKAGE_PIN M21 [get_ports vga_vs]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hs]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vs]

# PS2 Keyboard
set_property PACKAGE_PIN N18 [get_ports PS2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports PS2_clk]
set_property PACKAGE_PIN M19 [get_ports PS2_data]
set_property IOSTANDARD LVCMOS33 [get_ports PS2_data]

# LED
set_property PACKAGE_PIN N26 [get_ports LED_clk]
set_property PACKAGE_PIN N24 [get_ports LED_rstn]
set_property PACKAGE_PIN M26 [get_ports LED_out]
set_property PACKAGE_PIN P18 [get_ports LED_en]
set_property IOSTANDARD LVCMOS33 [get_ports LED_clk]
set_property IOSTANDARD LVCMOS33 [get_ports LED_rstn]
set_property IOSTANDARD LVCMOS33 [get_ports LED_out]
set_property IOSTANDARD LVCMOS33 [get_ports LED_en]

# Segment
set_property PACKAGE_PIN M24 [get_ports seg_clk]
set_property IOSTANDARD LVCMOS33 [get_ports seg_clk]
set_property PACKAGE_PIN M20 [get_ports seg_rstn]
set_property IOSTANDARD LVCMOS33 [get_ports seg_rstn]
set_property PACKAGE_PIN L24 [get_ports seg_out]
set_property IOSTANDARD LVCMOS33 [get_ports seg_out]
set_property PACKAGE_PIN R18 [get_ports seg_en]
set_property IOSTANDARD LVCMOS33 [get_ports seg_en]

# Beep
set_property PACKAGE_PIN AF25 [get_ports beep]
set_property IOSTANDARD LVCMOS33 [get_ports beep]

# Switches
set_property PACKAGE_PIN AA10 [get_ports LED_debug]
set_property PACKAGE_PIN AB10 [get_ports bird_no_fall]
set_property PACKAGE_PIN AA13 [get_ports bird_no_die]
set_property PACKAGE_PIN AA12 [get_ports pillars_no_move]
set_property PACKAGE_PIN Y13  [get_ports music_off]
set_property IOSTANDARD LVCMOS15 [get_ports LED_debug]
set_property IOSTANDARD LVCMOS15 [get_ports bird_no_fall]
set_property IOSTANDARD LVCMOS15 [get_ports bird_no_die]
set_property IOSTANDARD LVCMOS15 [get_ports pillars_no_move]
set_property IOSTANDARD LVCMOS15 [get_ports music_off]

# rstn
set_property PACKAGE_PIN W13 [get_ports rstn]
set_property IOSTANDARD LVCMOS18 [get_ports rstn]

