//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2022/02/13) (18:25:55)
// File: debounce_extended.v
//------------------------------------------------------------
// Description:
//
// debounce the signals from the buttons
//------------------------------------------------------------

module debounce_extended (
   output o_switch,
   input  i_clk,
   input  i_reset,
   input  i_switch,
   input  [31:0] debounce_limit 
);


reg [31:0] counter;
reg r_switch_state;
// reg [31:0] debounce_limit = 5000;

assign o_switch = r_switch_state;

initial begin
   counter = 0;
   r_switch_state = 1;
end

always @(posedge i_clk or negedge i_reset) begin
   if (~i_reset)
      counter <= 0;
   else begin
      if ( (i_switch != r_switch_state) & (counter<debounce_limit) ) begin
         counter <= counter+1;
      end else begin
         if (counter==debounce_limit) begin
            r_switch_state <= i_switch;
            counter <= 0;
         end else begin
            counter <= 0;
         end
      end
   end
end



endmodule