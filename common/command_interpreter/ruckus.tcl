# Load RUCKUS library
source $::env(RUCKUS_PROC_TCL)

# Load Source Code
loadSource -lib common -path "$::DIR_PATH/rtl/GREB_v2_commands_package.vhd"
loadSource -lib common -path "$::DIR_PATH/rtl/GREB_v2_cmd_interpreter.vhd"

# Load Simulation
#loadSource -lib common -sim_only -dir "$::DIR_PATH/TB"
