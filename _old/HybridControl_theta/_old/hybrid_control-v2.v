//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/01/16) (21:43:22)
// File: hybrid_control.v
//------------------------------------------------------------
// Description:
//
// Block that implements the hybrid control
// jump set is implemented as half-plane
//------------------------------------------------------------


`timescale 1 ns / 1 ps
//`default_nettype none


module hybrid_control (
   o_sigma,   	// output switching variable
	o_sigma_neg,// output switching variable (negate)
   i_CLK,     	// clock which trigger the output
   i_RESET,   	// reset signal
   i_vC,      	// input related to z1
   i_iC,      	// input related to z2
   i_sigma,   	// feeback variable
   i_ctheta,  	// cos(theta) times a multiplier
   i_stheta   	// sin(theta) times a multiplier
);

output         o_sigma;
output         o_sigma_neg;
input          i_CLK;
input          i_RESET;
input  [13:0]  i_vC;
input  [13:0]  i_iC;
input          i_sigma;
input  [31:0]  i_ctheta;
input  [31:0]  i_stheta;

wire          o_sigma;     //
wire          o_sigma_neg; //
wire          i_CLK;
wire          i_RESET;
wire  [13:0]  i_vC;      //
wire  [13:0]  i_iC;      //
wire          i_sigma;   //
wire  [31:0]  i_ctheta;  //
wire  [31:0]  i_stheta;  //


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
   integer sigma_bi;       // state sigma {-1,1}
   integer jump_1, jump_2;   // variable to evaluate the current set
   integer tmp;
   reg control;            // output variable sigma {0,1}
   reg tb;

// assign output variable
   assign o_sigma     =  control;//jump[31];
   assign o_sigma_neg =  tb;

// always @(i_vC or i_iC)
// begin : proc_control_law
//    if(~i_RESET) begin
//       control <= 0;
//    end else begin
//       // check in which set the trajectory is
//       sigma_bi = (i_sigma<<1)-1;
//       z1   = mu_z1*(i_vC-offset)-sigma_bi*Vg;
//       z2   = mu_z2*(i_iC-offset)*sqrt_L_over_C;
//       jump  = z1*i_stheta + z2*i_ctheta;
//       // detect if need to change the set
//       if (jump<0) begin
//          control = 1'b1;
//       end else begin
//          control = 1'b0;
//       end
//      // tb = jump[31];
//    end
// end


always @(i_vC or i_iC or i_RESET) begin
   if(~i_RESET) begin
      control <= 0;
   end else begin
      // check in which set the trajectory is
      sigma_bi = (i_sigma<<1)-1;
      z1   = mu_z1*(i_vC-offset)-sigma_bi*Vg;
      z2   = mu_z2*(i_iC-offset)*sqrt_L_over_C;
      jump_1  = z1*i_stheta + z2*i_ctheta;//sigma_bi*( z1*i_stheta + z2*i_ctheta);
      jump_2  = sigma_bi*(-z1*i_ctheta + z2*i_stheta);
      // detect if need to change the set
      // if (jump_1<0 & jump_2>0) begin
      //    control <= ~i_sigma;
      // end
      if (jump_1<0)
         control <= 1'b1;
      else
         control <= 1'b0;
     // tb = jump[31];
   end
end

always @(i_vC or i_RESET) begin
   if(~i_RESET) begin
      tb <= 0;
   end else begin
      // check in which set the trajectory is
      tmp  = (i_vC-offset)*(i_iC-offset);
      if (tmp>0)
         tb <= 1'b1;
      else
         tb <= 1'b0;
   end
end

endmodule