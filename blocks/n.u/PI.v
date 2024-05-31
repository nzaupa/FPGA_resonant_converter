//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/07/13) (19:19:45)
// File: PI.v
//------------------------------------------------------------
// Description:
//
// Block that implements a PI controller
//
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module PI (
   o_correction, // [32bit-signed] mean on 4 samples
   i_clock,      // for sequential behavior
   i_RESET,      // reset signal
   i_error      // [32bit-signed] input data to be filtered
);

output signed [31:0]  o_correction;
input                 i_clock;
input                 i_RESET;
input  signed [31:0]  i_error;



// CONSTANTS
   integer Kp = 1;
   integer Ki = 32'd6000;


// INTERNAL VARIABLE
   reg signed [31:0] err_int;
   reg signed [31:0] err;
   reg signed [31:0] err_prev;

// assign output variable
   assign err = i_error;
   assign o_correction = err*Kp + err_int*Ki;

// variable initialization
initial begin
   err      = 32'b0;
   err_prev = 32'b0;
   err_int  = 32'b0;
   err_int  = 32'b0;
end
// occhio, potrebbe esserci errore di segno usando solo <<
// ? cosa mette all'inizio, zero o uno?

always @(posedge i_clock or negedge i_RESET) begin
    if (~i_RESET) begin
      err      <= 32'b0;
      err_prev <= 32'b0;
      err_int  <= 32'b0;
   end else begin
      err_prev <= err;
      err_int  <= (err + err_prev)>>1;
   end
end

endmodule