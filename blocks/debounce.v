//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/30) (16:59:45)
// File: debounce.v
//------------------------------------------------------------
// Description:
// detect when a signal change of state and activate a counter
// if the counter finish the output signal is changed accordling
// to the input
// BRIEFLY: it introduce a delay in a signal to make sure that
// it is stable and not noise
//------------------------------------------------------------

module debounce #(
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
   r_switch_state = 1;
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