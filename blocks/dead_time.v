//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/08/02) (16:58:46)
// File: dead_time.v
//------------------------------------------------------------
// Description:
// ...
// dead_time_core:
//    Introduce a delay at the RISING edge of the input signal
//    corresponding to number of clock cycles (DEADTIME)
//    of the input clock --> deadtime = DEADTIME/freq_clk (s)
// 
// dead_time:
//    instantiates N instance of dead_time_core
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module dead_time_core #(
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

module dead_time #(
      parameter DEADTIME = 10,
      parameter N = 1
   )(
      output [N-1:0] o_signal,
      input          i_clock,
      input  [N-1:0] i_signal 
   );

   genvar i;

   generate
      for (i = 0; i < N; i = i + 1) begin : DT
         dead_time_core  #( .DEADTIME(DEADTIME) ) dt_core(
            .o_signal(o_signal[i]),
            .i_clock(i_clock),
            .i_signal(i_signal[i])
         );
      end
   endgenerate

endmodule