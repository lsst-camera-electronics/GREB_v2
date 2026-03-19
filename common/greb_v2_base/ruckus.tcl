# Load RUCKUS library
source $::env(RUCKUS_PROC_TCL)

# Load Source Code
loadSource -lib common -dir "$::DIR_PATH/rtl/"
loadConstraints        -path "$::DIR_PATH/rtl/GREB_v2_phys.xdc"
# Load specific timing constraints from tarket ruckus.tcl
# loadConstraints        -path "$::DIR_PATH/rtl/GREB_v2_time.xdc"
# loadConstraints        -path "$::DIR_PATH/rtl/GREB_v2_natural_time.xdc"
