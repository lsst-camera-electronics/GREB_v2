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
  -- 202c2000 GREB v2 first version

  constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"21372106"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "GREB_v2_2_seq: Vivado v2015.3 (x86_64) Built Thu Mar 28 17:22:06 CET 2019 by srusso";

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
-------------------------------------------------------------------------------
