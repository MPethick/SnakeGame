# clk input is from the 100 MHz oscillator on Boolean board
#create_clock -period 10.000 -name gclk [get_ports clk_100MHz]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports clk]

# Define frequencies for the internally generated clocks
create_generated_clock -name SCORE_CLK -source [get_pins -hierarchical -filter { NAME =~  "*clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0" }] -divide_by 2 [get_pins -hierarchical -filter { NAME =~  "*snake_game_top_0/inst/clock_rectifier_score/trigger_reg/Q" }]
create_generated_clock -name VGA_CLK -source [get_pins -hierarchical -filter { NAME =~  "*clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0" }] -divide_by 4 [get_pins -hierarchical -filter { NAME =~  "*snake_game_top_0/inst/clock_rectifier_vga/trigger_reg/Q" }]
create_generated_clock -name SNAKE_CLK -source [get_pins -hierarchical -filter { NAME =~  "*clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0" }] -divide_by 1000000 [get_pins -hierarchical -filter { NAME =~  "*snake_game_top_0/inst/snake/clock_rectifier_snake/trigger_reg/Q" }]
create_generated_clock -name STROBE_CLK -source [get_pins -hierarchical -filter { NAME =~  "*clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0" }] -divide_by 100000 [get_pins -hierarchical -filter { NAME =~  "*snake_game_top_0/inst/strobe/clock_rectifier_strobe/trigger_reg/Q" }]

# Set Bank 0 voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# On-board Slide Switches
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports reset]

set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports speedup_disable]

# On-board Buttons
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports btn_u]

set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports btn_l]

set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports btn_d]

set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports btn_r]

# On-board 7-Segment display 1
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {seg_select_out[4]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports {seg_select_out[5]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {seg_select_out[6]}]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {seg_select_out[7]}]

set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {dec_out_1[0]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {dec_out_1[1]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {dec_out_1[2]}]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {dec_out_1[3]}]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS33} [get_ports {dec_out_1[4]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS33} [get_ports {dec_out_1[5]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS33} [get_ports {dec_out_1[6]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33} [get_ports {dec_out_1[7]}]

# On-board 7-Segment display 2
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports {seg_select_out[0]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {seg_select_out[1]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {seg_select_out[2]}]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS33} [get_ports {seg_select_out[3]}]

set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {dec_out_2[0]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {dec_out_2[1]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {dec_out_2[2]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {dec_out_2[3]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {dec_out_2[4]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {dec_out_2[5]}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {dec_out_2[6]}]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports {dec_out_2[7]}]

# HDMI Signals
set_property -dict {PACKAGE_PIN T14 IOSTANDARD TMDS_33} [get_ports hdmi_tx_tmds_clk_n]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD TMDS_33} [get_ports hdmi_tx_tmds_clk_p]

set_property -dict {PACKAGE_PIN T15 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_tmds_data_n[0]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_tmds_data_n[1]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_tmds_data_n[2]}]

set_property -dict {PACKAGE_PIN R15 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_tmds_data_p[0]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_tmds_data_p[1]}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_tmds_data_p[2]}]

