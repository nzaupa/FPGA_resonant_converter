//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/01/24) (17:17:45)
// File: hybrid_control.v
//------------------------------------------------------------
// Description:
//
// Block that implements the hybrid control
// jump set is implemented as half-plane
// sin and cosine are computed internally
// sigma is an internal state variable
//------------------------------------------------------------


`timescale 1 ns / 1 ps
//`default_nettype none


module hybrid_control (
   o_sigma,   	// output switching variable
	o_sigma_neg,// output switching variable (negate)
   i_RESET,   	// reset signal
   i_vC,      	// input related to z1
   i_iC,      	// input related to z2
   i_theta,  	// angle of the switching surface
);

output         o_sigma;
output         o_sigma_neg;
input          i_RESET;
input  [13:0]  i_vC;
input  [13:0]  i_iC;
input  [31:0]  i_theta;

//wire          o_sigma;     //
//wire          o_sigma_neg; //
wire          i_RESET;
//wire  [13:0]  i_vC;      //
//wire  [13:0]  i_iC;      //
wire  [31:0]  ctheta;  //
wire  [31:0]  stheta;  //




// CONSTANTS
   integer offset = 8191;        // 2^14bit/2 -> offset to shifts the bit from the ADC
   integer sqrt_L_over_C = 1;    // x100 3180 --> constant which multiply the current
   // multipliers considering sensors sensitivity
   integer mu_z1 = 1;            // 10 --> multiplier for z1 (voltage)
   integer mu_z2 = 1;            // 1  --> multiplier for z2 (current)
   integer Vg = 1966;            // 24V fullscale of vC=100V on 8192 bit

// INTERNAL VARIABLE
   integer z1;             // state z1
   integer z2;             // state z1
   integer z1_2, z2_2;
   reg signed [1:0] sigma_bi, sigma_bi2;       // state sigma {-1,1}
   integer jump, jump_1, jump_2;   // variable to evaluate the current set
   reg sigma_prev;
   reg sigma;            // output variable sigma {0,1}

// DEBUG
   reg tb;

// assign output variable
   assign o_sigma     =  sigma;
   assign o_sigma_neg =  tb;


// function instantiation
trigonometry trigonometry_inst (
   .o_cos(ctheta),    // cosine of the input
   .o_sin(stheta),    // sine of the input
   .i_theta(i_theta)  // input angle
);

// variable initialization
initial begin
   sigma_prev = 0;
   tb = 0;
end

// latch for the signal feedback (maybe can be inside)
always @(sigma) begin
   sigma_prev <= sigma;
end



// // control law which look at half plane
// always @(i_vC or i_iC or i_theta or i_RESET) begin
//    if(~i_RESET) begin
//       sigma <= 0;
//    end else begin
//       // check in which set the trajectory is
//       sigma_bi = (sigma<<1)-1;      // sigma from {0,1} to {-1,1}
//       z1       = mu_z1*(i_vC-offset)-sigma_bi*Vg;
//       z2       = mu_z2*(i_iC-offset)*sqrt_L_over_C;
//       jump     = z1*stheta + z2*ctheta;
//       if (jump<0)
//          sigma <= 1'b1;
//       else
//          sigma <= 1'b0;
//    end
// end

// // control law which look at one quarter of plane
// always @(i_vC or i_iC or i_theta or i_RESET) begin
//    if(~i_RESET) begin
//       tb <= 0;
//    end else begin
//       // check in which set the trajectory is
//       sigma_bi2= (tb<<1)-1;      // sigma from {0,1} to {-1,1}
//       z1_2       = mu_z1*(i_vC-offset)-sigma_bi*Vg;
//       z2_2       = mu_z2*(i_iC-offset)*sqrt_L_over_C;
//       jump_1   = sigma_bi2*( z1_2*stheta + z2_2*ctheta);
//       jump_2   = sigma_bi2*(-z1_2*ctheta + z2_2*stheta);
//       // detect if need to change the set
//       if (jump_1<0 & jump_2>0) begin
//          tb <= ~tb;
//       end

//    end
// end

// control law which look at one quarter of plane - probably robust to reset
always @(*) begin //@(i_vC or i_iC or i_theta or sigma_prev or i_RESET) begin
   // compute coordinate transformation
   sigma_bi2 = (sigma_prev<<1)-1;      // sigma from {0,1} to {-1,1}
   z1_2      = mu_z1*(i_vC-offset)-sigma_bi*Vg;
   z2_2      = mu_z2*(i_iC-offset)*sqrt_L_over_C;
   jump_1    = sigma_bi2*( z1_2*stheta + z2_2*ctheta);
   jump_2    = sigma_bi2*(-z1_2*ctheta + z2_2*stheta);
   jump      = z1_2*stheta + z2_2*ctheta;
   // detect if need to change the set
   if(~i_RESET) begin
      sigma <= jump_1[31];
   end else begin
      // check in which set the trajectory is

      if (jump_1<0 & jump_2>0) begin //
         sigma <= ~sigma_prev;
         //sigma <= jump_1[31];
      end else begin
         sigma <= sigma_prev;
      end
   end
   tb <= jump[31];
end


endmodule