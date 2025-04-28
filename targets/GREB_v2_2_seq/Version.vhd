-------------------------------------------------------------------------------
-- Title         : Version File
-- Project       : 
-------------------------------------------------------------------------------
-- File          : 
-- Author        : 
-- Created       : 
-------------------------------------------------------------------------------
-- Description:
-- Version Constant Module.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by SLAC National Accelerator Laboratory. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is
-------------------------------------------------------------------------------
-- Version History
-------------------------------------------------------------------------------

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"2139210D"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "GREB_v2_2_seq: Vivado v2018.3 (x86_64) Built Tue Jan 28 16:29:06 PST 2025 by jgt";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 2000 GREB v2 first release
-- 2001 GREB v2 two independent sequencers
-- 2002 GREB v2 silver cable gpio on seuqncer_0_out(16), bias_protection and both CCDs driven bysequnecer 0
-- 2003 GREB v2 dual sequencer back on, sequencer_1_busy added and gpio_2 driven by sequencer_1_out(16)
-- 2004 GREB v2 solved a bug on ADC data handler that prevented the image transfer
-- for a specific clk sequence multiboot feature included
-- 2005 GREB v2 same as 2005 but with one sequencer
-- 2006 GREB v2 one sequencer, sync cmd, LAMs added and one wire serial number
--              corrected
-- 2106 GREB v2 same as 2006 but with 2 indipendent sequencers
-- 2007 GREB v2 mask on look at me corrected
-- 2008 GREB v2 video ADC data from CCD 0 sent to VC0 and data from CCD 1 sent to VC1  
-- 2009 GREB Added STOP Synchronous command 0x30
--           Fixed bug that caused 160ns of 0 on output when entering default state
-- 200A GREB Added register START command that specifies a MAIN
-- 200B GREB Added version number to bitfile
-- 200C GREB swapped sensors (dead end/deprecated)
-- 200D GREB Added enable mask for input to DataEncoder
-------------------------------------------------------------------------------
