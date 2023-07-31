//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/30) (16:33:35)
// File: dead_time.v
//------------------------------------------------------------
// Description:
//
// Introduce a delay at the RISING edge of the input signal
// corresponding to number of clock cycles (DEADTIME)
// of the input clock --> deadtime = DEADTIME/freq_clk (s)
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module dead_time #(
   parameter DEADTIME = 10
)(
   output o_signal,     // output delayed signal
   input  i_clock,      // clock to count the time
   input  i_signal      // input signal
);


reg [9:0] delay;   // keep track of the count
reg signal_delay;

assign o_signal = signal_delay;

initial begin
   delay = 10'b0; // initialize the counter
end

always @(posedge i_clock ) begin
   if( i_signal==0 ) begin
      // if signal is zero do nothing
      signal_delay <= 0;
      delay <= 0;
   end else begin
      //if 1 check for the delay
      if( delay < DEADTIME ) begin
         signal_delay <= 0;
         delay <= delay+1'b1;
      end else begin
         signal_delay <= 1;
      end
   end
end

endmodule