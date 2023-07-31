//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2022/02/18) (14:35:56)
// File: regularization.v
//------------------------------------------------------------
// Description:
//
// debounce signal and apply regularization
//------------------------------------------------------------

module regularization (
   output o_signal,
   input  i_clk,
   input  i_reset,
   input  i_signal,
   input  [15:0] debounce_limit,
   input  [15:0] delay
);

wire signal_debounced;
reg  signal_prev;
reg [31:0] counter = 0;
wire jump_enable;

assign jump_enable = (counter == 0) ? 1'b1 : 1'b0;

assign o_signal = jump_enable ? signal_debounced : signal_prev;

debounce_extended debounce_inst(
   .o_switch(signal_debounced),
   .i_clk(i_clk),
   .i_reset(i_reset),
   .i_switch(i_signal),
   .debounce_limit(debounce_limit)
);

always @(posedge i_clk) begin
   signal_prev <= o_signal;
end

always @(posedge i_clk ) begin
   if(signal_prev == o_signal) begin // nothing change, continue to count
      if( counter!=0 ) begin // count if EN=0
         if( counter < delay )
            counter <= counter+1'b1;
         else
            counter <= 0; // reset the counter when it reach the limit
      end
   end else begin
      counter <= 10'b1;
   end
end



// always @(*) begin
//          if (jump_enable) begin           // can jump
//             o_signal <= jump[31];
//          end else begin
//             o_signal <= sigma_prev;
//          end
// end


endmodule