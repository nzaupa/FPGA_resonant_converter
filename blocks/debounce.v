//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/08/02) (16:45:56)
// File: debounce.v
//------------------------------------------------------------
// Description:
// debounce_core:
//    detect when a signal change of state and activate a counter
//    if the counter finish the output signal is changed accordling
//    to the input
// debounce:
//    instantiates N instance of debounce_core
// 
// --> new debounce which replace all the others
//------------------------------------------------------------


module debounce_core #(
      parameter DEBOUNCE_TIME = 5000
   )(
      output o_switch,
      input  i_clk,
      input  i_reset,
      input  i_switch
   );


   reg [31:0] counter;
   reg r_switch_state;

   assign o_switch = r_switch_state;

   initial begin
      counter = 0;
      r_switch_state = 0;
   end

   always @(posedge i_clk or negedge i_reset) begin
      if (~i_reset)
         counter <= 0;
      else begin
         if ( (i_switch != r_switch_state) & (counter<DEBOUNCE_TIME) ) begin
            counter <= counter+1;
         end else begin
            if (counter==DEBOUNCE_TIME) begin
               r_switch_state <= i_switch;
               counter <= 0;
            end else begin
               counter <= 0;
            end
         end
      end
   end

endmodule


module debounce #(
      parameter DEBOUNCE_TIME = 5000,
      parameter N = 1
   )(
      output [N-1:0] o_switch,
      input  i_clk,
      input  i_reset,
      input  [N-1:0] i_switch 
   );

   genvar i;

   generate
      for (i = 0; i < N; i = i + 1) begin : DB
         debounce_core  #( .DEBOUNCE_TIME(DEBOUNCE_TIME) ) db_core(
            .o_switch(o_switch[i]),
            .i_clk(i_clk),
            .i_reset(i_reset),
            .i_switch(i_switch[i])
         );
      end
   endgenerate

endmodule

