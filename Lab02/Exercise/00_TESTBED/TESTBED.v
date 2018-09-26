//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2018 Fall
//   Lab02 Exercise		: Inverse Matrix Calculater
//   Author     		: Ping-Yuan Tsai (bubblegame@si2lab.org)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESETBED.v
//   Module Name : TESETBED
//   Release version : V1.0 (Release Date: 2018-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`timescale 1ns/10ps

`include "PATTERN.v"
`ifdef RTL
  `include "IMC.v"
`endif
`ifdef GATE
  `include "IMC_SYN.v"
`endif
	  		  	
module TESTBED;

wire          clk, rst_n, IN_VALID;
wire  [ 3:0]  IN;
wire          OUT_VALID;
wire  [13:0]  OUT;


initial begin
  `ifdef RTL
    $fsdbDumpfile("IMC.fsdb");
    $fsdbDumpvars();
  `endif
  `ifdef GATE
    $sdf_annotate("IMC_SYN.sdf", u_IMC);
    $fsdbDumpfile("IMC_SYN.fsdb");
    $fsdbDumpvars();    
  `endif
end

IMC u_IMC(
    .clk(clk),
    .rst_n(rst_n),
    .IN_VALID(IN_VALID),
    .IN(IN),
    .OUT_VALID(OUT_VALID),
    .OUT(OUT)
    );
	
PATTERN u_PATTERN(
    .clk(clk),
    .rst_n(rst_n),
    .IN_VALID(IN_VALID),
    .IN(IN),
    .OUT_VALID(OUT_VALID),
    .OUT(OUT)
    );
  
 
endmodule
