//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2022/02/13) (18:57:14)
// File: debounce_4bit.v
//------------------------------------------------------------
// Description:
//
// debounce 4 independent signals
//------------------------------------------------------------

module debounce_4bit (
   output [3:0] o_switch,
   input  i_clk,
   input  i_reset,
   input  [3:0] i_switch,
   input  [31:0] debounce_limit 
);

debounce_extended debounce_1_inst(
   .o_switch(o_switch[0]),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_switch[0]),
   .debounce_limit(debounce_limit)
);

debounce_extended debounce_2_inst(
   .o_switch(o_switch[1]),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_switch[1]),
   .debounce_limit(debounce_limit)
);

debounce_extended debounce_3_inst(
   .o_switch(o_switch[2]),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_switch[2]),
   .debounce_limit(debounce_limit)
);

debounce_extended debounce_4_inst(
   .o_switch(o_switch[3]),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_switch[3]),
   .debounce_limit(debounce_limit)
);




endmodule