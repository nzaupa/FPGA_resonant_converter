//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/02/07) (17:27:45)
// File: dead_time.v
//------------------------------------------------------------
// Description:
//
// Introduce a delay at the rising edge of the input signal
// corresponding to number of clock cycles (deadtime - 10bit)
// of the input clock
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module dead_time (
   o_signal,     // output delayed signal
   i_clock,      // clock to count the time
   i_signal,     // input signal
   deadtime      // number of clock cycles to wait
);

output      o_signal;
input       i_clock;
input       i_signal;
input [9:0] deadtime;

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
      if( delay < deadtime ) begin
         signal_delay <= 0;
         delay <= delay+1'b1;
      end else begin
         signal_delay <= 1;
      end
   end
end

endmodule