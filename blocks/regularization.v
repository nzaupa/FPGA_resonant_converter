//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/08/02) (17:08:32)
// File: regularization.v
//------------------------------------------------------------
// Description:
// 
// regularization_core:
//    this module take an input signal and:
//       1. debounce it = i.e. allows it to change only if it does  
//          not change for DEBOUNCE_TIME clock cycles
//       2. once the the signal change, it prevents it to change 
//          for a fixed amount of time DELAY
// 
// regularization:
//    instantiates N instance of regularization_core
//------------------------------------------------------------

module regularization_core #(
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
   // wire jump_enable;

   // assign jump_enable = (counter == 0) ? 1'b1 : 1'b0;

   assign o_signal = (counter < DELAY) ? signal_prev : signal_debounced;

   debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) debounce_inst(
      .o_switch(signal_debounced),
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_switch(i_signal)
   );

   always @(posedge i_clk) begin
      signal_prev <= o_signal;
   end

   initial begin
      counter = DELAY;
   end

   always @(posedge i_clk or negedge i_reset) begin
      if (~i_reset) begin
         counter <= DELAY;
      end else begin
         if( counter < DELAY ) begin
            counter <= counter+1'b1;
         end else begin
            if (signal_prev != o_signal) begin
               counter <= 0;
            end else begin
               counter <= counter;
            end
         end
      end
   end

endmodule


module regularization #(
      parameter DEBOUNCE_TIME = 5000,
      parameter DELAY = 20,
      parameter N = 1
   )(
      output [N-1:0] o_signal,
      input  i_clk,
      input  i_reset,
      input  [N-1:0] i_signal
   );

   genvar i;

   generate
      for (i = 0; i < N; i = i + 1) begin : REG
         regularization_core  #( 
               .DEBOUNCE_TIME(DEBOUNCE_TIME), 
               .DELAY(DELAY) 
            ) reg_core(
               .o_signal( o_signal[i] ),
               .i_clk(i_clk),
               .i_reset(i_reset),
               .i_signal( i_signal[i] )
            );
      end
   endgenerate

endmodule



module regularization_core_old #(
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

