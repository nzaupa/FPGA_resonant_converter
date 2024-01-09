//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/02/09) (15:16:45)
// File: hybrid_control.v
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module tb_hybrid_control;

integer counter;

integer delay = 50;         // time for which jumps are inhibits


reg  i_clock;
reg  sigma_prev;
reg  sigma;  // output variable sigma {0,1}
wire jump_enable;
wire sigma_reset;
reg  clk_50;

// variable initialization
initial begin
   sigma_prev  = 1;
   counter     = 0;
   clk_50      = 1;
end

always
   begin //100MHz
      i_clock = 1'b1;
      #5
      i_clock = 1'b0;
      #5;
end

always
   begin //
      sigma = 1'b1;
      #10000
      sigma = 1'b0;
      #10000;
end


// latch for the signal feedback
always @(posedge i_clock) begin
   sigma_prev <= sigma;
   clk_50 <= ~clk_50;
end



always @(posedge clk_50 or negedge sigma_reset) begin
   if(~sigma_reset) begin
      counter <= 1;
   end else begin
      if( ~jump_enable ) begin
         if( counter < delay )
            counter <= counter+1;
         else
            counter <= 0;
      end
   end
end

assign sigma_reset = (sigma_prev!=sigma) ? 1'b0 : 1'b1;

assign jump_enable = (counter == 0) ? 1'b1 : 1'b0;

endmodule