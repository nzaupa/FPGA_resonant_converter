//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2022/02/08) (09:21:53)
// File: three_level_MOS.v
//------------------------------------------------------------
// Description:
//
// generate the command signal for output a three level waveform on a full bridge
//
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module three_level_MOS (
   o_MOSFET,
   o_sigma,
   i_CLK
);

output [3:0] o_MOSFET;
output [31:0] o_sigma;
input i_CLK;

reg [7:0] counter;
wire b1, b0;

// with 1MHz clock + bit 2 and 3 -> ~62kHz output with symmetric On-OFF times

assign b1 = counter[3];
assign b0 = counter[2];

assign o_sigma   = { {31{b1&(~b0)}} , ~b0 };

assign o_MOSFET[0] = (~b1) | (b1&b0);
assign o_MOSFET[1] =   b1  | ((~b1)&b0);
assign o_MOSFET[2] = b1 & (~b0);
assign o_MOSFET[3] = ~(b1|b0);

initial  begin
   counter = 0;
end

always @(posedge i_CLK) begin
   counter <= counter + 1;
end

endmodule