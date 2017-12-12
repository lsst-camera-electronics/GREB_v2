-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.3 (lin64) Build 1368829 Mon Sep 28 20:06:39 MDT 2015
-- Date        : Wed Sep 21 14:28:55 2016
-- Host        : lsst-daq03 running 64-bit Red Hat Enterprise Linux Server release 6.8 (Santiago)
-- Command     : write_vhdl -force -mode synth_stub
--               /u1/srusso/Xilinx_prj/LSST_prj/DREB_prj/GREB_v1_daq_v1/firmware/modules/LSST_common/sequencer_v3/ipcore_vivado/ip/seq_param_fifo_v3/seq_param_fifo_v3_stub.vhdl
-- Design      : seq_param_fifo_v3
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k160tffg676-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seq_param_fifo_v3 is
  Port ( 
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC
  );

end seq_param_fifo_v3;

architecture stub of seq_param_fifo_v3 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,srst,din[31:0],wr_en,rd_en,dout[31:0],full,empty";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_0_0,Vivado 2015.3";
begin
end;
