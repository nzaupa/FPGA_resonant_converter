//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/07/12) (12:05:45)
// File: LPF.v
//------------------------------------------------------------
// Description:
//
// Block that implements a moving average filter on 4 samples
//
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module LPF_32 (
   o_mean,      // [32bit-signed] mean on 4 samples
   i_clock,     // for sequential behavior
   i_RESET,     // reset signal
   i_data       // [32bit-signed] input data to be filtered
);

output signed [31:0]  o_mean;
input                 i_clock;
input                 i_RESET;
input  signed [31:0]  i_data;

// INTERNAL VARIABLE
reg signed [31:0] z1;
reg signed [31:0] z2;
reg signed [31:0] z3;
reg signed [31:0] z4;
reg signed [31:0] z5;
reg signed [31:0] z6;
reg signed [31:0] z7;
reg signed [31:0] z8;
reg signed [31:0] z9;
reg signed [31:0] z10;
reg signed [31:0] z11;
reg signed [31:0] z12;
reg signed [31:0] z13;
reg signed [31:0] z14;
reg signed [31:0] z15;
reg signed [31:0] z16;
reg signed [31:0] z17;
reg signed [31:0] z18;
reg signed [31:0] z19;
reg signed [31:0] z20;
reg signed [31:0] z21;
reg signed [31:0] z22;
reg signed [31:0] z23;
reg signed [31:0] z24;
reg signed [31:0] z25;
reg signed [31:0] z26;
reg signed [31:0] z27;
reg signed [31:0] z28;
reg signed [31:0] z29;
reg signed [31:0] z30;
reg signed [31:0] z31;
reg signed [31:0] z32;

wire [31:0] o_mean_scaled;

// assign output variable
assign o_mean_scaled = z1 + z2 + z3 + z4 + z5 + z6 + z7 + z8 + z9 + z10 + z11 + z12 + z13 + z14 + z15 + z16 + z17 + z18 + z19 + z20 + z21 + z22 + z23 + z24 + z25 + z26 + z27 + z28 + z29 + z30 + z31 + z32 ;

assign o_mean =  { {5{o_mean_scaled[31]}} , o_mean_scaled[31:5]};

// variable initialization
initial begin
   z1 = 32'b0;
   z2 = 32'b0;
   z3 = 32'b0;
   z4 = 32'b0;
   z5 = 32'b0;
   z6 = 32'b0;
   z7 = 32'b0;
   z8 = 32'b0;
   z9 = 32'b0;
   z10 = 32'b0;
   z11 = 32'b0;
   z12 = 32'b0;
   z13 = 32'b0;
   z14 = 32'b0;
   z15 = 32'b0;
   z16 = 32'b0;
   z17 = 32'b0;
   z18 = 32'b0;
   z19 = 32'b0;
   z20 = 32'b0;
   z21 = 32'b0;
   z22 = 32'b0;
   z23 = 32'b0;
   z24 = 32'b0;
   z25 = 32'b0;
   z26 = 32'b0;
   z27 = 32'b0;
   z28 = 32'b0;
   z29 = 32'b0;
   z30 = 32'b0;
   z31 = 32'b0;
   z32 = 32'b0;
end

always @(posedge i_clock or negedge i_RESET) begin
   if (~i_RESET) begin
      z1 <= 32'b0;
      z2 <= 32'b0;
      z3 <= 32'b0;
      z4 <= 32'b0;
      z5 <= 32'b0;
      z6 <= 32'b0;
      z7 <= 32'b0;
      z8 <= 32'b0;
      z9 <= 32'b0;
      z10 <= 32'b0;
      z11 <= 32'b0;
      z12 <= 32'b0;
      z13 <= 32'b0;
      z14 <= 32'b0;
      z15 <= 32'b0;
      z16 <= 32'b0;
      z17 <= 32'b0;
      z18 <= 32'b0;
      z19 <= 32'b0;
      z20 <= 32'b0;
      z21 <= 32'b0;
      z22 <= 32'b0;
      z23 <= 32'b0;
      z24 <= 32'b0;
      z25 <= 32'b0;
      z26 <= 32'b0;
      z27 <= 32'b0;
      z28 <= 32'b0;
      z29 <= 32'b0;
      z30 <= 32'b0;
      z31 <= 32'b0;
      z32 <= 32'b0;
   end else begin
      z1 <= i_data;
      z2 <= z1;
      z3 <= z2;
      z4 <= z3;
      z5 <= z4;
      z6 <= z5;
      z7 <= z6;
      z8 <= z7;
      z9 <= z8;
      z10 <= z9;
      z11 <= z10;
      z12 <= z11;
      z13 <= z12;
      z14 <= z13;
      z15 <= z14;
      z16 <= z15;
      z17 <= z16;
      z18 <= z17;
      z19 <= z18;
      z20 <= z19;
      z21 <= z20;
      z22 <= z21;
      z23 <= z22;
      z24 <= z23;
      z25 <= z24;
      z26 <= z25;
      z27 <= z26;
      z28 <= z27;
      z29 <= z28;
      z30 <= z29;
      z31 <= z30;
      z32 <= z31;
   end
end

endmodule