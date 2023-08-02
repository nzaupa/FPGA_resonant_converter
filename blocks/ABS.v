//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/07/13) (19:19:45)
// File: ABS.v
//------------------------------------------------------------
// Description:
//
// compute the absolute value
//
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module ABS (
   output signed [31:0] o_number,
   input  signed [31:0] i_number
);

assign o_number = (i_number[31]) ? (~i_number+1) : i_number;

endmodule