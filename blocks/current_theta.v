//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/01/16) (21:43:22)
// File: current_theta.v
//------------------------------------------------------------
// Description:
//
// Lookup table for nonlinear function relating the 
// current with the control parameter theta
// 
//------------------------------------------------------------


`timescale 1 ns / 1 ps
//`default_nettype none


module current_theta (
   o_theta,    // cosine of the input
   i_current   // input angle
);

output  signed [31:0] o_theta;
input   signed [31:0] i_current;

reg [31:0] r_theta;

assign o_theta = r_theta;

always @ ( i_current )
begin

// computation of sine and cosine using integers
// taking advanatges of look-up-table
// input angle is multiplied by x100
// trigonometric output is multiplied by x1000

case(i_theta)
      32'h00000000: r_sin = 32'h00000000;
      32'h00000001: r_sin = 32'h0000000A;
      32'h00000139: r_sin = 32'h0000000C;
      32'h0000013A: r_sin = 32'h00000000;
      default: r_sin = 32'h00000000;
endcase


end


endmodule