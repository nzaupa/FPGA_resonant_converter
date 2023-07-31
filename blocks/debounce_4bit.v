//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/30) (17:05:28)
// File: debounce_4bit.v
//------------------------------------------------------------
// Description:
// debounce module applied to four signals
// 
// detect when a signal change of state and activate a counter
// if the counter finish the output signal is changed accordling
// to the input
// BRIEFLY: it introduce a delay in a signal to make sure that
// it is stable and not noise
// 
//------------------------------------------------------------

module debounce_4bit #(
   parameter DEBOUNCE_TIME = 5000
)(
   output [3:0] o_switch,
   input  i_clk,
   input  i_reset,
   input  [3:0] i_switch 
);

debounce #( .DEBOUNCE_TIME(DEBOUNCE_TIME) ) debounce_1_inst(
   .o_switch(o_switch[0]),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_switch[0])
);

debounce #( .DEBOUNCE_TIME(DEBOUNCE_TIME) ) debounce_2_inst(
   .o_switch(o_switch[1]),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_switch[1])
);

debounce #( .DEBOUNCE_TIME(DEBOUNCE_TIME) ) debounce_3_inst(
   .o_switch(o_switch[2]),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_switch[2])
);

debounce #( .DEBOUNCE_TIME(DEBOUNCE_TIME) ) debounce_4_inst(
   .o_switch(o_switch[3]),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_switch[3])
);




endmodule