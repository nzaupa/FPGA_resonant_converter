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

module LPF (
   o_mean,      // [32bit-signed] mean on 4 samples
   i_clock,     // for sequential behavior
   i_RESET,     // reset signal
   i_data,      // [32bit-signed] input data to be filtered
);

output signed [31:0]  o_mean;
input                 i_clock;
input                 i_RESET;
input  signed [31:0]  i_data;


// INTERNAL VARIABLE
   reg signed [31:0] z1;   // memory 1 for the data
   reg signed [31:0] z2;   // memory 2 for the data
   reg signed [31:0] z3;   // memory 3 for the data
   reg signed [31:0] z4;   // memory 4 for the data


// assign output variable
   //assign o_mean = (z1>>2) + (z2>>2) + (z3>>2) + (z4>>2);
   assign o_mean = z1 + z2 + z3 + z4;

// variable initialization
initial begin
   z1  = 32'b0;
   z2  = 32'b0;
   z3  = 32'b0;
   z4  = 32'b0;
end
// occhio, potrebbe esserci errore di segno usando solo <<
// ? cosa mette all'inizio, zero o uno?

always @(posedge i_clock or negedge i_RESET) begin
    if (~i_RESET) begin
      z1 <= 32'b0;
      z2 <= 32'b0;
      z3 <= 32'b0;
      z4 <= 32'b0;
   end else begin
      z4 <= z3;
      z3 <= z2;
      z2 <= z1;
      //z1 <= i_data;
      z1 <= i_data>>2;
   end
end

endmodule