# ==================================================================================================
# start_project.tcl
# TCL script to initialize project constraints and files for easy
# implementation and bitstream generation.
# Updated from Anton Potocnik, 02.10.2016 - 14.12.2017 (http://antonpotocnik.com/?cat=29)
#
# Rev: 1
# January 5, 2023
#
# by Ebrahim Hussain 41184342 (UBC)
# ==================================================================================================

# first, set the working directory and project name in the TCL console by the following commands:
# EXAMPLE WORKING DIRECTORY: set base_path C:/Users/ehussain/Desktop/Projects/qmi-redpitaya-starting
# EXAMPLE PROJECT NAME: set project_name led_switch_interface
#
# the variables MUST be named base_path and project_name. Then your project will open by running:
# source $base_path/start_project.tcl and will be found in the default Vivado directory

# =================================================================================================

set part_name xc7z010clg400-1
set bd_path $base_path/$project_name/$project_name.srcs/sources_1/bd/system
file delete -force $base_path/$project_name
create_project $project_name $base_path/$project_name -part $part_name
create_bd_design system

# Load Red Pitaya ports
source $base_path/cfg/ports.tcl

# Set Path for the custom IP cores
set_property IP_REPO_PATHS $base_path/cores [current_project]
update_ip_catalog

# Zynq processing system with Red Pitaya specific preset
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_IMPORT_BOARD_PRESET {cfg/red_pitaya.xml}] [get_bd_cells processing_system7_0]
endgroup

# Differential I/O Buffers
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0
set_property -dict [list CONFIG.C_SIZE {2}] [get_bd_cells util_ds_buf_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_1
set_property -dict [list CONFIG.C_SIZE {2}] [get_bd_cells util_ds_buf_1]
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_2
set_property -dict [list CONFIG.C_SIZE {2}] [get_bd_cells util_ds_buf_2]
set_property -dict [list CONFIG.C_BUF_TYPE {OBUFDS}] [get_bd_cells util_ds_buf_2]
endgroup

# LED
set_property LEFT 7 [get_bd_ports led_o]

# Connections
connect_bd_net [get_bd_ports adc_clk_p_i] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
connect_bd_net [get_bd_ports adc_clk_n_i] [get_bd_pins util_ds_buf_0/IBUF_DS_N]
connect_bd_net [get_bd_ports daisy_p_i] [get_bd_pins util_ds_buf_1/IBUF_DS_P]
connect_bd_net [get_bd_ports daisy_n_i] [get_bd_pins util_ds_buf_1/IBUF_DS_N]
connect_bd_net [get_bd_ports daisy_p_o] [get_bd_pins util_ds_buf_2/OBUF_DS_P]
connect_bd_net [get_bd_ports daisy_n_o] [get_bd_pins util_ds_buf_2/OBUF_DS_N]
connect_bd_net [get_bd_pins util_ds_buf_1/IBUF_OUT] [get_bd_pins util_ds_buf_2/OBUF_IN]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]

# Generate output products and wrappers
generate_target all [get_files $bd_path/system.bd]
make_wrapper -files [get_files $bd_path/system.bd] -top
add_files -norecurse $bd_path/hdl/system_wrapper.v

# Add constraint files
set files [glob -nocomplain $base_path/cfg/*.xdc]
if {[llength $files] > 0} {
  add_files -norecurse -fileset constrs_1 $files
}

set_property VERILOG_DEFINE {TOOL_VIVADO} [current_fileset]
set_property STRATEGY Flow_PerfOptimized_High [get_runs synth_1]
set_property STRATEGY Performance_NetDelay_high [get_runs impl_1]

