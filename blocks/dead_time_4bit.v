//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/30) (16:43:56)
// File: dead_time_4bit.v
//------------------------------------------------------------
// Description:
// ...
// Introduce a delay at the RISING edge of the input signal
// corresponding to number of clock cycles (DEADTIME)
// of the input clock --> deadtime = DEADTIME/freq_clk (s)
// It operates on a four bit signal.
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module dead_time_4bit #(
   parameter DEADTIME = 10
)(
   output [3:0] o_signal,     // output delayed signal
   input        i_clock,      // clock to count the time
   input  [3:0] i_signal      // input signal
);


dead_time #( .DEADTIME(DEADTIME) ) dead_time_1_inst(
   .o_signal( o_signal[0] ),          // output switching variable
   .i_clock(  i_clock ),     // for sequential behavior
   .i_signal( i_signal[0] )
);

dead_time #( .DEADTIME(DEADTIME) ) dead_time_2_inst(
   .o_signal( o_signal[1] ),          // output switching variable
   .i_clock(  i_clock ),     // for sequential behavior
   .i_signal( i_signal[1] )
);

dead_time #( .DEADTIME(DEADTIME) ) dead_time_3_inst(
   .o_signal( o_signal[2] ),          // output switching variable
   .i_clock(  i_clock ),     // for sequential behavior
   .i_signal( i_signal[2] )
);

dead_time #( .DEADTIME(DEADTIME) ) dead_time_4_inst(
   .o_signal( o_signal[3] ),          // output switching variable
   .i_clock(  i_clock ),     // for sequential behavior
   .i_signal( i_signal[3] )
);

endmodule