//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/07/12) (12:30:00)
// File: peak_detector.v
//------------------------------------------------------------
// Description:
//
// Recognize the peak in a waveform
//
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module peak_detector (
   o_peak,      // [32bit-signed] mean on 4 samples
   o_peak_signed,      // [32bit-signed] mean on 4 samples
   o_peak_detected, // debug signal for when a peak is detected
   i_clock,     // for sequential behavior
   i_RESET,     // reset signal
   i_data       // [32bit-signed] input data to be filtered
);

output signed [31:0]  o_peak;
output signed [31:0]  o_peak_signed;
output                o_peak_detected;
input                 i_clock;
input                 i_RESET;
input  signed [31:0]  i_data;


// INTERNAL VARIABLE
   //reg signed [31:0] x;      // input data
   reg signed [31:0] x_prev; // previous input data
   reg signed [31:0] x_dot;  // derivative estimation
   //reg signed [31:0] x_dot_filt;  // derivative estimation
   reg signed [31:0] x_dot_prev;  // previous derivative estimation
   //reg signed [31:0] diff;  // zero crossing variable
   reg signed [31:0] peak;      // peak value

   wire [31:0] x;
   wire [31:0] x_dot_filt; // for TB

// assign output variable
   // derivative estimation
   assign x_dot = x + (~x_prev+1);
   assign o_peak_detected = x_dot_filt[31] ^ x_dot_prev[31];
   assign o_peak_signed = peak;

// moving average filter
LPF_32 LPF_32_inst(
   .o_mean  (x),
   .i_clock (i_clock),
   .i_RESET (i_RESET),
   .i_data  (i_data)
);

LPF_32 LPF_32_diff_inst(
   .o_mean  (x_dot_filt),
   .i_clock (i_clock),
   .i_RESET (i_RESET),
   .i_data  (x_dot)
);

ABS ABS_inst(
   .o_number(o_peak),
   .i_number(peak)
);


// variable initialization
initial begin
//   x          = 32'b0;
   x_prev     = 32'b0;
   x_dot      = 32'b0;
   x_dot_prev = 32'b0;
end


always @(posedge i_clock or negedge i_RESET) begin
    if (~i_RESET) begin
//      x          <= 32'b0;
      x_prev     <= 32'b0;
      x_dot_prev <= 32'b0;
   end else begin
//      x          <= i_data;
      x_prev     <= x;
      x_dot_prev <= x_dot_filt;
   end
end


always @(posedge o_peak_detected) begin
   //o_peak <= i_data;
   peak <= x;
end

endmodule