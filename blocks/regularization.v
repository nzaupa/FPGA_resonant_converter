//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/30) (17:30:07)
// File: regularization.v
//------------------------------------------------------------
// Description:
// 
// this module take an input signal and:
//    1. debounce it = i.e. allows it to change only if it does  
//       not change for DEBOUNCE_TIME clock cycles
//    2. once the the signal change, it prevents it to change 
//       for a fixed amount of time DELAY
// 
//------------------------------------------------------------

module regularization #(
   parameter DEBOUNCE_TIME = 2,
   parameter DELAY = 20
)(
   output o_signal,
   input  i_clk,
   input  i_reset,
   input  i_signal
);

wire signal_debounced;
reg  signal_prev;
reg [31:0] counter = 0;
wire jump_enable;

assign jump_enable = (counter == 0) ? 1'b1 : 1'b0;

assign o_signal = jump_enable ? signal_debounced : signal_prev;

debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) debounce_inst(
   .o_switch(signal_debounced),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_signal)
);

always @(posedge i_clk) begin
   signal_prev <= o_signal;
end

always @(posedge i_clk ) begin
   if(signal_prev == o_signal) begin // nothing change, continue to count
      if( counter!=0 ) begin // count if EN=0
         if( counter < DELAY )
            counter <= counter+1'b1;
         else
            counter <= 0; // reset the counter when it reach the limit
      end
   end else begin
      counter <= 10'b1;
   end
end




endmodule