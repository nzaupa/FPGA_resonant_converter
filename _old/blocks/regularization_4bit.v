//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2022/02/23) (08:59:01)
// File: regularization_4bit.v
//------------------------------------------------------------
// Description:
//
// regularize 4 independent signals
//  1. debounce a signal according to 'debounce_limit'
//  2. prevent the signal from changing according to 'delay'
//------------------------------------------------------------

module regularization_4bit (
   output [3:0] o_signal,
   input  i_clk,
   input  i_reset,
   input  [3:0] i_signal,
   input  [15:0] debounce_limit,
   input  [15:0] delay
);

regularization regularization_1_inst (
   .o_signal( o_signal[0] ),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_signal( i_signal[0] ),
   .debounce_limit(debounce_limit),
   .delay(delay)
);

regularization regularization_2_inst (
   .o_signal( o_signal[1] ),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_signal( i_signal[1] ),
   .debounce_limit(debounce_limit),
   .delay(delay)
);

regularization regularization_3_inst (
   .o_signal( o_signal[2] ),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_signal( i_signal[2] ),
   .debounce_limit(debounce_limit),
   .delay(delay)
);

regularization regularization_4_inst (
   .o_signal( o_signal[3] ),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_signal( i_signal[3] ),
   .debounce_limit(debounce_limit),
   .delay(delay)
);




endmodule