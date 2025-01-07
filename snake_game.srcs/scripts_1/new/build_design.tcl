## This variable will store the base directory of this script
set ::baseScriptDir [file dirname [file normalize [info script]]]

##------------------------------------------------------------------------------
## These procs allow an in depth report of Vivado variables. Occasionally 
## useful, when searching for Simulator stuff.
## Single lines to keep this file compact. Expand for your interest. 
##------------------------------------------------------------------------------
proc listns {{parentns ::}} { set result [list] ; foreach ns [namespace children ${parentns}] { lappend result {*}[listns ${ns}] ${ns} } ; return $result }
proc dumpAllVariablesInNamespace  {} {foreach  nameSpace [listns] { puts ${nameSpace}; foreach varName [info vars ${nameSpace}::*] { catch { puts "    [format %-40s ${varName}] = [set ${varName}]" } } } }
## Show the project settings for this Project. Again single line, expand for understanding. However this form is useful to modify for objects in IPI
proc show_project_settings { } { foreach prop [list_property [current_project] ] { set retStr "[format %-50s ${prop}] [get_property ${prop} [current_project]]"; puts "${retStr}" } }
proc show_bdcell_settings  { ipName } { foreach prop [list_property [get_bd_cells ${ipName}] ] { set retStr "  dict set ip_config [format %-50s ${prop}] [get_property ${prop} [get_bd_cells ${ipName}]]"; puts "${retStr}" } }

proc putsBanner {myStr} { puts "##[string repeat "-" 78]\n## ${myStr}\n##[string repeat "-" 78]" }

## --- Synthesis and implementation shorthands
proc uuSynth     { } {  reset_run synth_1; uuLaunchRun synth_1 }
proc uuImpl      { } {  reset_run impl_1 ; uuLaunchRun impl_1  }
proc uuSynthImpl { } {  uuSynth; close_design; uuImpl; }

## --- Common launcher
proc uuLaunchRun { runType } {

  launch_runs        ${runType} -jobs 16 
  wait_on_run        ${runType}
  open_run           ${runType}
  uuDoCustomAnalysis ${runType} 1 3 10

}

## --- Report timing to a file, add a tag so we know where it was called post synthesis or impl
proc uuDoCustomAnalysis { runName depth levels {paths 30}} {

  report_control_sets    -hierarchical -hierarchical_depth ${depth}                                                                                                        
  report_design_analysis -timing -routes -logic_level_distribution -of_timing_paths [get_timing_paths -routable_nets -max_paths ${paths} -filter "LOGIC_LEVELS >= ${levels}" ]
  report_design_analysis -timing -show_all -max_paths ${paths} -full_logical_pin
  report_utilization     -hierarchical -hierarchical_depth ${depth}

  foreach stat [list_property [get_runs ${runName}]] { 
    if {[regexp STATS\..+ ${stat}]} {  puts "      -> [format %-40s ${stat}] [get_property ${stat} [get_runs ${runName}]]" }
  }
}

## -----------------------------------------------------------------------------
## --- Main call routine. Passed one argument thats interperted.
## -----------------------------------------------------------------------------
proc do_stuff { cmdArgs } {
  
  set cmdArgs [string tolower ${cmdArgs}]

  if { [regex bool ${cmdArgs}] } { 
    set board "bool"

    if { [regex diag ${cmdArgs}] } { 
      set button_config "diag"
    } else {
      set button_config "square"
    }
  } elseif { [regex arty ${cmdArgs}] } { 
    set board "arty"
    set button_config "line"
  } else {
    putsBanner "Please select a board to use via command line input (arty or bool)."
  }

  set myNAME "${board}_snake_game_[clock format [clock seconds] -format "%Y%m%d_%H%M%S"]"
  set myPATH ./${myNAME}

  if { ${board} eq "arty" } {
    set myPART "xc7a35ticsg324-1L"; # Artix-7
  } elseif { ${board} eq "bool" } {
    set myPART "xc7s50csga324-1"; # Spartan-7
  }

  ## Skip using a Board File if we are just doing HDL
  create_project ${myNAME} ${myPATH} -part ${myPART} -force

  putsBanner "Set Target language Verilog. Windows can default to VHDL"
  set_property target_language Verilog [current_project]

  if { [regex proj ${cmdArgs}] } { return 0 }

  build_snake_game_design ${board}

  validate_bd_design -force
  set_property synth_checkpoint_mode None [get_files *.bd]  
  generate_target all                     [get_files *.bd]   
  export_ip_user_files -of_objects        [get_files *.bd] -no_script -sync -force -quiet
  add_files -norecurse [ make_wrapper -files [get_files *.bd] -top ]
  set_property top snake_game_bd_wrapper [current_fileset]
  
  # show_ip_settings
  show_bdcell_settings snake_game_top_0

  if { [regex ipi ${cmdArgs}] } { putsBanner "When ready you can use uuSynthImpl to run Syntheis/implementation and generate the most useful reports." }
  
  if { [regex impl ${cmdArgs}] } { uuSynthImpl }

}

##------------------------------------------------------------------------------
proc show_help_run_input { argc argv } {
  
  puts "${argc} - number items of arguments passed to a script."
  puts "${argv} - list of the arguments.\n${argv}[0]"
  puts "Running from Directory ${::baseScriptDir}"

puts "
do_stuff \{board_name\}proj     ## Just open the project
                              ## Use with sim as also.
do_stuff \{board_name\}ipi      ## Just open the IPI design
do_stuff \{board_name\}impl     ## Open the project and run implementation

"
  if { ${argc} > 0 } { do_stuff [lindex ${argv} 0] }
  
}

##------------------------------------------------------------------------------
## You can load design files in a varity of ways. YAML files can be loaded 
## directly in Vivado TCL for example, or use a dict, proc.
## Do not use IPI generated BD files. These can be useful for snapshots, but
## are non-simple to maintain and expand on. Generally a handful of TCL 
## commands can be used to create quite complex IPI systems.
##------------------------------------------------------------------------------
proc build_snake_game_design { board } {

  ## Add the files we need from a known root point.
  add_files -fileset sources_1 ${::baseScriptDir}/../../sources_1/new
  add_files -fileset sim_1     ${::baseScriptDir}/../../sim_1/new
  ## Allow customisation of button layout for boolean board via constraints
  if {${button_config} eq "diag" } {
    add_files -fileset constrs_1 ${::baseScriptDir}/../../constrs_1/new/${board}_diag_constraints.xdc
  } else {
    add_files -fileset constrs_1 ${::baseScriptDir}/../../constrs_1/new/${board}_constraints.xdc
  }
  
  create_bd_design "snake_game_bd"

  create_bd_port -dir I -type clk -freq_hz 100000000 clk

  # Note the version is removed.
  create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0

  set_property -dict [ list                                        \
                       CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.000} \
                       CONFIG.USE_RESET                  {false}   \
                     ] [get_bd_cells clk_wiz_0]

  connect_bd_net [get_bd_ports clk] [get_bd_pins clk_wiz_0/clk_in1]

  create_bd_port -dir I -type rst reset 

  set_property -dict [ list                        \
                       CONFIG.POLARITY ACTIVE_HIGH \
                     ] [get_bd_ports reset]


  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0

  connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net [get_bd_ports reset]             [get_bd_pins proc_sys_reset_0/ext_reset_in]

  ## Add Module Reference Flow Object (MRF), any Verilog module can be used
  ## in IPI. If you want to use an SV or VHDL, just create a 121 port wrapper.
  create_bd_cell -type module -reference snake_game_top snake_game_top_0

  create_bd_port -dir I speedup_disable
  create_bd_port -dir I btn_l
  create_bd_port -dir I btn_u
  create_bd_port -dir I btn_r
  create_bd_port -dir I btn_d
  
  connect_bd_net [get_bd_pins  clk_wiz_0/clk_out1]               [get_bd_pins snake_game_top_0/clk]
  # connect_bd_net [get_bd_ports clk]                              [get_bd_pins snake_game_top_0/clk]
  connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_reset] [get_bd_pins snake_game_top_0/reset]
  # connect_bd_net [get_bd_ports reset]                            [get_bd_pins snake_game_top_0/reset]
  connect_bd_net [get_bd_ports speedup_disable]                  [get_bd_pins snake_game_top_0/speedup_disable]
  connect_bd_net [get_bd_ports btn_l]                            [get_bd_pins snake_game_top_0/btn_l]
  connect_bd_net [get_bd_ports btn_u]                            [get_bd_pins snake_game_top_0/btn_u]
  connect_bd_net [get_bd_ports btn_r]                            [get_bd_pins snake_game_top_0/btn_r]
  connect_bd_net [get_bd_ports btn_d]                            [get_bd_pins snake_game_top_0/btn_d]

  create_bd_port -dir O -from 11 -to 0 led_out

  connect_bd_net [get_bd_pins snake_game_top_0/led_out]    [get_bd_ports led_out] 

  # Arty board uses a VGA output and colour LEDs for the score
  if { ${board} eq "arty" } {
    create_bd_port -dir O                h_sync
    create_bd_port -dir O                v_sync
    create_bd_port -dir O -from 11 -to 0 colour_out

    connect_bd_net [get_bd_pins snake_game_top_0/h_sync]     [get_bd_ports h_sync] 
    connect_bd_net [get_bd_pins snake_game_top_0/v_sync]     [get_bd_ports v_sync]
    connect_bd_net [get_bd_pins snake_game_top_0/colour_out] [get_bd_ports colour_out] 
  }
  
  # Boolean board uses a HDMI output and a 7-seg display for the score
  if { ${board} eq "bool" } {
    create_bd_port -dir O -from 1 -to 0 seg_select_out
    create_bd_port -dir O -from 7 -to 0 dec_out

    connect_bd_net [get_bd_pins snake_game_top_0/seg_select_out] [get_bd_ports seg_select_out] 
    connect_bd_net [get_bd_pins snake_game_top_0/dec_out]        [get_bd_ports dec_out] 

    ## Add VGA to HDMI Encoder IP to the project 
    set_property ip_repo_paths ${::baseScriptDir}/../../sources_1/imports [current_project]
    update_ip_catalog

    create_bd_cell -type ip -vlnv realdigital.org:realdigital:hdmi_tx:1.0 vga_to_hdmi_encoder_0
    set_property -dict [ list                     \
                         CONFIG.C_BLUE_WIDTH {4}  \
                         CONFIG.C_GREEN_WIDTH {4} \
                         CONFIG.C_RED_WIDTH {4}   \
                         CONFIG.MODE {HDMI}       \
                       ] [get_bd_cells vga_to_hdmi_encoder_0]

    #=======================
    # VGA Input to Encoder
    #=======================

    # Creat a secondary clock which is 5x the VGA clock frequency
    set_property -dict [ list                                        \
                         CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.000} \
                         CONFIG.CLKOUT2_USED {true}                  \
                       ] [get_bd_cells clk_wiz_0]

    # Connect the VGA outputs from the snake game to the Encoder
    connect_bd_net [get_bd_pins snake_game_top_0/vga_clk]          [get_bd_pins vga_to_hdmi_encoder_0/pix_clk]
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out2]                [get_bd_pins vga_to_hdmi_encoder_0/pix_clkx5]
    connect_bd_net [get_bd_pins clk_wiz_0/locked]                  [get_bd_pins vga_to_hdmi_encoder_0/pix_clk_locked] 
    connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_reset] [get_bd_pins vga_to_hdmi_encoder_0/rst]
    connect_bd_net [get_bd_pins snake_game_top_0/h_sync]           [get_bd_pins vga_to_hdmi_encoder_0/hsync]
    connect_bd_net [get_bd_pins snake_game_top_0/v_sync]           [get_bd_pins vga_to_hdmi_encoder_0/vsync]
    connect_bd_net [get_bd_pins snake_game_top_0/vde]              [get_bd_pins vga_to_hdmi_encoder_0/vde]

    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0

    set_property -dict [ list                  \
                         CONFIG.DIN_WIDTH {12} \
                         CONFIG.DIN_FROM {3}   \
                       ] [get_bd_cells xlslice_0]

    connect_bd_net [get_bd_pins snake_game_top_0/colour_out] [get_bd_pins xlslice_0/Din]
    connect_bd_net [get_bd_pins xlslice_0/Dout]              [get_bd_pins vga_to_hdmi_encoder_0/red] 
    
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1

    set_property -dict [ list                  \
                         CONFIG.DIN_WIDTH {12} \
                         CONFIG.DIN_FROM {7}   \
                         CONFIG.DIN_TO {4}     \
                       ] [get_bd_cells xlslice_1]

    connect_bd_net [get_bd_pins snake_game_top_0/colour_out] [get_bd_pins xlslice_1/Din]
    connect_bd_net [get_bd_pins xlslice_1/Dout]              [get_bd_pins vga_to_hdmi_encoder_0/green]

    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_2

    set_property -dict [ list                  \
                         CONFIG.DIN_WIDTH {12} \
                         CONFIG.DIN_FROM {11}   \
                         CONFIG.DIN_TO {8}     \
                       ] [get_bd_cells xlslice_2]

    connect_bd_net [get_bd_pins snake_game_top_0/colour_out] [get_bd_pins xlslice_2/Din]
    connect_bd_net [get_bd_pins xlslice_2/Dout]              [get_bd_pins vga_to_hdmi_encoder_0/blue]

    #=======================
    # Constants
    #=======================

    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0

    set_property -dict [ list                   \
                        CONFIG.CONST_VAL {0}   \
                        CONFIG.CONST_WIDTH {4} \
                      ] [get_bd_cells xlconstant_0]

    connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins vga_to_hdmi_encoder_0/aux0_din]
    connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins vga_to_hdmi_encoder_0/aux1_din]
    connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins vga_to_hdmi_encoder_0/aux2_din]

    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1

    set_property -dict [ list                 \
                        CONFIG.CONST_VAL {0} \
                      ] [get_bd_cells xlconstant_1]

    connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins vga_to_hdmi_encoder_0/ade] 

    #=======================
    # HDMI Output
    #=======================

    create_bd_intf_port -mode Master -vlnv xilinx.com:interface:hdmi_rtl:2.0 hdmi_tx

    connect_bd_intf_net [get_bd_intf_pins vga_to_hdmi_encoder_0/hdmi_tx] [get_bd_intf_ports hdmi_tx]
  }

  regenerate_bd_layout

}

##------------------------------------------------------------------------------
## END oF PROCS
##------------------------------------------------------------------------------

## Right, here we go!
show_help_run_input ${argc} ${argv}
