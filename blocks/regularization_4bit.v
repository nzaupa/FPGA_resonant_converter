//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/30) (17:30:19)
// File: regularization_4bit.v
//------------------------------------------------------------
// Description:
//
// apply regularization module to 4 signals
// 
// this module take an input signal and:
//    1. debounce it = i.e. allows it to change only if it does  
//       not change for DEBOUNCE_TIME clock cycles
//    2. once the the signal change, it prevents it to change 
//       for a fixed amount of time DELAY
// //------------------------------------------------------------

module regularization_4bit #(
   parameter DEBOUNCE_TIME = 2,
   parameter DELAY = 20
)(
   output [3:0] o_signal,
   input  i_clk,
   input  i_reset,
   input  [3:0] i_signal
);

regularization #(
   .DEBOUNCE_TIME(DEBOUNCE_TIME), 
   .DELAY(DELAY)
) regularization_1_inst (
   .o_signal( o_signal[0] ),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_signal( i_signal[0] )
);

regularization #(
   .DEBOUNCE_TIME(DEBOUNCE_TIME), 
   .DELAY(DELAY)
) regularization_2_inst (
   .o_signal( o_signal[1] ),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_signal( i_signal[1] )
);

regularization #(
   .DEBOUNCE_TIME(DEBOUNCE_TIME), 
   .DELAY(DELAY)
) regularization_3_inst (
   .o_signal( o_signal[2] ),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_signal( i_signal[2] )
);

regularization #(
   .DEBOUNCE_TIME(DEBOUNCE_TIME), 
   .DELAY(DELAY)
) regularization_4_inst (
   .o_signal( o_signal[3] ),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_signal( i_signal[3] )
);




endmodule