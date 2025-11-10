# -------------------------------------------------------------------------------
# -- Revision History:
# -- 2000 GREB v2 first release
# -- 2001 GREB v2 two independent sequencers
# -- 2002 GREB v2 silver cable gpio on seuqncer_0_out(16), bias_protection and both CCDs driven bysequnecer 0
# -- 2003 GREB v2 dual sequencer back on, sequencer_1_busy added and gpio_2 driven by sequencer_1_out(16)
# -- 2004 GREB v2 solved a bug on ADC data handler that prevented the image transfer
# -- for a specific clk sequence multiboot feature included
# -- 2005 GREB v2 same as 2005 but with one sequencer
# -- 2006 GREB v2 one sequencer, sync cmd, LAMs added and one wire serial number
# --              corrected
# -- 2106 GREB v2 same as 2006 but with 2 indipendent sequencers
# -- 2007 GREB v2 mask on look at me corrected
# -- 2008 GREB v2 video ADC data from CCD 0 sent to VC0 and data from CCD 1 sent to VC1
# -- 2009 GREB Added STOP Synchronous command 0x30
# --           Fixed bug that caused 160ns of 0 on output when entering default state
# -- 200A GREB Added register START command that specifies a MAIN
# -- 200B GREB Added version number to bitfile
# -- 200C GREB swapped sensors (dead end/deprecated)
# -- 200D GREB Added enable mask for input to DataEncoder
# -- 200E GREB Added bias threshold readback and sequencer override
# -- 200F GREB Bias VUT and HV switch no longer reset by REB reset
# -- 2110 Nominally same as version F, but refactored to use new build system and modern Vivado
# -- 2011 Moving to the parameterized system clock to enable "natural frequency" firmware
# -------------------------------------------------------------------------------

# Define Firmware Version Number (and don't forget to change the register values! :facepalm:)
export PRJ_VERSION = 0x213A2111

export GIT_BYPASS=0
export OVERRIDE_SUBMODULE_LOCKS=0

export GEN_BIT_IMAGE=0
export GEN_BIT_IMAGE_GZIP=1
export GEN_MCS_IMAGE=0
export GEN_MCS_IMAGE_GZIP=0
export GEN_MULTIBOOT_IMAGE=0
export GEN_MULTIBOOT_IMAGE_GZIP=1

# Define target output
target: prom

# Define target part
export PRJ_PART = XC7K160TFFG676-1

# Use top level makefile
include ../../submodules/ruckus/system_vivado.mk
