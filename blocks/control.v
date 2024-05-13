//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2024/05/10) (17:29:52)
// File: control.v
//------------------------------------------------------------
// Description:
// collection of the modules to implement a PI controller
//------------------------------------------------------------

// PI controller with anti-windup possibility
// a classical PI expression is err*KP+int*KI
//    where int is the integral of the error
//       int = sum{err}*Ts    [Ts -> sampling time]
// the euler scheme is considered for the integration
// 
// for a digital implementation we do as follow:
//    err*KP+err_sum*Ts*KI
// in this way we can collect the gains in two variables: KP and TsKI
// since we are working we only integers numbers.aw
// 
// Ts is the inverse of the sampling frequency: Ts=1/f(i_CLK)

module PI #(
   parameter KP   = 1,       // proportional gain
   parameter TsKI = 0,    // integral gain
   parameter Kaw  = 0,
   parameter shift_KP = 0,
   parameter shift_KI = 0
)
(
   output signed [31:0]  o_PI,   // output value
   input                 i_CLK,  // for sequential behavior
   input                 i_RST,  // reset signal
   input  signed [31:0]  err,    // input error
   input  signed [31:0]  aw      // antiwindup
);


// INTERNAL VARIABLE
   reg signed [31:0] err_sum;
   reg signed [31:0] err_sum_prev;

// assign output variable
   assign o_PI = (err*KP >> shift_KP) + (err_sum*TsKI >> shift_KI);

// variable initialization
initial begin
   err_sum_prev = 32'b0;
   err_sum      = 32'b0;
end

always @(posedge i_CLK or negedge i_RST) begin
    if (~i_RST) begin
      err_sum_prev <= 32'b0;
      err_sum      <= 32'b0;
   end else begin
      err_sum_prev <= err_sum;
      err_sum      <= err_sum_prev + err + aw*Kaw; // compute the cumulated sum without considering the integration step
      // err_sum  <= (err + err_prev)>>1;
   end
end

endmodule



//------------------------------------------------------------
// Description:
// This modules implements a saturation element.
// If the input value exceed the limits, 
// it is clamped to the extreme
//------------------------------------------------------------
module saturation #(
   parameter UPPER_LIMIT = 100,
   parameter LOWER_LIMIT = 0,
   parameter N_BIT = 32
) (
   input  signed [N_BIT-1:0] u,
   output signed [N_BIT-1:0] u_sat
);

reg signed [N_BIT-1:0] u_sat_reg;

assign u_sat = u_sat_reg;
   
always @(u) begin
   if (u>UPPER_LIMIT) begin
      u_sat_reg <= UPPER_LIMIT;
   end
   else if (u<LOWER_LIMIT) begin
      u_sat_reg <= LOWER_LIMIT;
   end
   else begin
      u_sat_reg <= u;
   end
end
endmodule