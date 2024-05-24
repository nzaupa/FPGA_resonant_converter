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
// a classical PI expression is err*Kp+int*Ki
//    where int is the integral of the error
//       int = sum{err}*Ts    [Ts -> sampling time]
// the euler scheme is considered for the integration
// 
// for a digital implementation we do as follow:
//    err*Kp+err_sum*Ts*Ki
// in this way we can collect the gains in two variables: Kp and TsKi
// since we are working we only integers numbers.aw
// 
// Ts is the inverse of the sampling frequency: Ts=1/f(i_CLK)

module PI #(
   parameter Kp   = 1,        // proportional gain
   parameter TsKi = 0,        // integral gain
   parameter Kaw  = 0,        // antiwindup integral
   parameter shift_Kp  = 0,   // shifting for Kp  (division)
   parameter shift_Ki  = 0,   // shifting for Ki  (division) 
   parameter shift_Kaw = 0    // shifting for Kaw (division)
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
   assign o_PI = ((err*Kp) >>> shift_Kp) + ((err_sum*TsKi) >>> shift_Ki);

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
      // compute the cumulated sum without considering the integration step
      // integration step is integrated in Ki
      err_sum      <= err_sum_prev + err + ( (~((aw*Kaw) >>> shift_Kaw))+1); 
   end
end

endmodule


module PI_old #(
   parameter Kp   = 1,        // proportional gain
   parameter TsKi = 0,        // integral gain
   parameter Kaw  = 0,        // antiwindup integral
   parameter shift_Kp  = 0,   // shifting for Kp  (division)
   parameter shift_Ki  = 0,   // shifting for Ki  (division) 
   parameter shift_Kaw = 0    // shifting for Kaw (division)
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
   assign o_PI = ((err*Kp) >>> shift_Kp) + ((err_sum*TsKi) >>> shift_Ki);

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
      err_sum      <= err_sum_prev + err + ( (~((aw*Kaw) >>> shift_Kaw))+1); // compute the cumulated sum without considering the integration step
      // err_sum  <= (err + err_prev)>>1;
   end
end

endmodule