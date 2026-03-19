# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lsst_sci
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lsst_reb
loadRuckusTcl $::env(PROJ_DIR)/../../common

# Load local Source Code and constraints
loadSource      -path "$::DIR_PATH/hdl/GREB_v2_6p4ns_2_seq.vhd"
loadConstraints -path $::env(PROJ_DIR)/../../common/greb_v2_base/rtl/GREB_v2_natural_time.xdc
