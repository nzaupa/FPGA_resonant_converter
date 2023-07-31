//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2022/02/14) (15:29:26)
// File: dead_time_4bit.v
//------------------------------------------------------------
// Description:
//
// Introduce a delay at the rising edge of the input signal
// corresponding to number of clock cycles (deadtime - 10bit)
// of the input clock. It operates on a four bit signal.
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module dead_time_4bit (
   output [3:0] o_signal,     // output delayed signal
   input        i_clock,      // clock to count the time
   input  [3:0] i_signal,     // input signal
   input  [9:0] deadtime      // number of clock cycles to wait
);


dead_time dead_time_1_inst(
   .o_signal( o_signal[0] ),          // output switching variable
   .i_clock(  i_clock ),     // for sequential behavior
   .i_signal( i_signal[0] ),
   .deadtime( deadtime )
);

dead_time dead_time_2_inst(
   .o_signal( o_signal[1] ),          // output switching variable
   .i_clock(  i_clock ),     // for sequential behavior
   .i_signal( i_signal[1] ),
   .deadtime( deadtime )
);

dead_time dead_time_3_inst(
   .o_signal( o_signal[2] ),          // output switching variable
   .i_clock(  i_clock ),     // for sequential behavior
   .i_signal( i_signal[2] ),
   .deadtime( deadtime )
);

dead_time dead_time_4_inst(
   .o_signal( o_signal[3] ),          // output switching variable
   .i_clock(  i_clock ),     // for sequential behavior
   .i_signal( i_signal[3] ),
   .deadtime( deadtime )
);

endmodule