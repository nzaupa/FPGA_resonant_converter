//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/01/27) (23:16:45)
// File: hybrid_control.v
//------------------------------------------------------------
// Description:
//
//
// Block that implements the hybrid control
// jump set is implemented as <<half-plane>>
// sin and cosine are computed internally
// sigma is an internal state variable
// input numbers are signed 14bit except the
// angle which is 32bit
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module hybrid_control (
   o_sigma,     // output switching variable
   o_debug,     // [14bit]
   i_clock,     // for sequential behavior
   i_RESET,     // reset signal
   i_vC,        // [14bit-signed] input related to z1
   i_iC,        // [14bit-signed] input related to z2
   i_theta      // [32bit-signed] angle of the switching surface
);

output         o_sigma;
output [13:0]  o_debug;
input          i_clock;
input          i_RESET;
input  signed [13:0]  i_vC;
input  signed [13:0]  i_iC;
input  signed [31:0]  i_theta;


wire                i_RESET;
wire signed [31:0]  vC_32;  //
wire signed [31:0]  iC_32;  //
wire signed [31:0]  ctheta;  //
wire signed [31:0]  stheta;  //


// CONSTANTS
   //integer offset = 8191;      // 2^14bit/2 -> offset to shifts the bit from the ADC
   //integer sqrt_L_over_C = 318;    // x100 3180 --> constant which multiply the current
   // multipliers considering sensors sensitivity
   // integer mu_z1 = 109880;       // 10 --> multiplier for z1 (voltage)  [10988 uV + 10 L/C]
   // integer mu_z2 = 394;            // 1  --> multiplier for z2 (current)
   // integer Vg    = 24000000;        // 24V fullscale of vC=100V on 8192 bi
   integer sqrt_L_over_C = 1;    // x100 3180 --> constant which multiply the current
   integer mu_z1 = 110;       // 10 --> multiplier for z1 (voltage)  [10988 uV + 10 L/C]
   integer mu_z2 = 25;            // 1  --> multiplier for z2 (current)
   integer Vg    = 24000;        // 24V fullscale of vC=100V on 8192 bit

// INTERNAL VARIABLE
   integer z1;             // state z1
   integer z2;             // state z1
   integer jump;           // variable to evaluate the current set

   reg sigma_prev, sigma;  // output variable sigma {0,1}

   wire signed [31:0] sigma_not;   // state ~sigma {-1,1} !! is the negate

// assign output variable
   assign o_sigma     =  sigma;
   // bit conversion from 14bit to 32bit
   assign vC_32 = { {19{i_vC[13]}} , i_vC[12:0] };
   assign iC_32 = { {19{i_iC[13]}} , i_iC[12:0] };
   // sigma from {0,1} to {-1,1}
   assign sigma_not = { {31{sigma_prev}} , 1'b1 }; // NOTE that is reverse to avoid minus sign

   assign o_debug = { jump[31] , jump[30:18] }+14'sd8191;


// function instantiation
trigonometry trigonometry_inst (
   .o_cos(ctheta),    // cosine of the input
   .o_sin(stheta),    // sine of the input
   .i_theta(i_theta)  // input angle
);

// variable initialization
initial begin
   sigma_prev = 1;
   sigma = 1;
end

// latch for the signal feedback
always @(posedge i_clock) begin
   sigma_prev <= sigma;
end

always @(*) begin
   // compute coordinate transformation
   z1       = mu_z1*(vC_32)+sigma_not*Vg;
   z2       = mu_z2*(iC_32)*sqrt_L_over_C;
   jump     = z1*stheta + z2*ctheta;
   // jump>0 --> sigma=0
   // jump<0 --> sigma=1
   sigma   <= jump[31];

end



endmodule