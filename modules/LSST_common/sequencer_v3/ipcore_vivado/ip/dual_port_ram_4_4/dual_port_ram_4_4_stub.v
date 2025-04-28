// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.3 (lin64) Build 1368829 Mon Sep 28 20:06:39 MDT 2015
// Date        : Wed Sep 21 14:25:58 2016
// Host        : lsst-daq03 running 64-bit Red Hat Enterprise Linux Server release 6.8 (Santiago)
// Command     : write_verilog -force -mode synth_stub
//               /u1/srusso/Xilinx_prj/LSST_prj/DREB_prj/GREB_v1_daq_v1/firmware/modules/LSST_common/sequencer_v3/ipcore_vivado/ip/dual_port_ram_4_4/dual_port_ram_4_4_stub.v
// Design      : dual_port_ram_4_4
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tffg676-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_9,Vivado 2015.3" *)
module dual_port_ram_4_4(a, d, dpra, clk, we, spo, dpo)
/* synthesis syn_black_box black_box_pad_pin="a[3:0],d[3:0],dpra[3:0],clk,we,spo[3:0],dpo[3:0]" */;
  input [3:0]a;
  input [3:0]d;
  input [3:0]dpra;
  input clk;
  input we;
  output [3:0]spo;
  output [3:0]dpo;
endmodule
