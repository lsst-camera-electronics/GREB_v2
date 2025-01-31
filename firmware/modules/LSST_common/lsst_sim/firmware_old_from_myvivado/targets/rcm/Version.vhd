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
-- 00000002 - Truncate Data
-- 00000003 - Zero extend Data
-- 00000004 - Truncated Data V21 of LsstSci
-------------------------------------------------------------------------------
constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"00000004"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Built Mon May 18 15:59:08 PDT 2015 by jgt";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 
-------------------------------------------------------------------------------
