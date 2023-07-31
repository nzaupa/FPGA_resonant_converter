//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/26) (15:26:54)
// File: hybrid_control_theta.v
//------------------------------------------------------------
// Description:
//
// Block that implements the hybrid control. 
// It works with time regularization (inhibit jump for a while)
// jump set is implemented as <<half-plane>>
// The input parameters are:
//  - voltage (14bit-signed)
//  - current (14bit-signed)
//  - control selection (2bit)
// NOTE:
//  + sin and cosine are computed internally
//  + sigma is an internal state variable
//  + input numbers are signed 14bit except the
//    angle which is 32bit
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module hybrid_control_theta (
   output        [3:0]  o_MOSFET,
   output               o_sigma,     // output switching variable
   output        [15:0] o_debug,     // [16bit]
   input                i_clock,     // for sequential behavior
   input                i_RESET,     // reset signal
   input  signed [13:0] i_vC,        // [14bit-signed] input related to z1
   input  signed [13:0] i_iC,        // [14bit-signed] input related to z2
   input  signed [31:0] i_theta      // [32bit-signed] angle of the switching surface
);



wire signed [31:0]  vC_32;   //
wire signed [31:0]  iC_32;   //
wire signed [31:0]  ctheta;  //
wire signed [31:0]  stheta;  //


// CONSTANTS
   integer mu_z1 = 86;        // multiplier for z1 (voltage)
   integer mu_z2 = 90;        // multiplier for z2 (current), include sqrt(L/C)
   integer Vg    = 312000;     // input voltage scaled accordingly to z1
   reg [9:0] delay = 10'd400;        // time for which jumps are inhibits

// INTERNAL VARIABLE
   integer z1;                   // state z1
   integer z2;                   // state z1
   integer jump;
   reg [9:0] counter;

   reg  sigma_prev, sigma;  // output variable sigma {0,1}
   wire jump_enable, sigma_reset;


   wire signed [31:0] sigma_not;   // state ~sigma {-1,1} !! is the negate

// assign output variable
   assign o_sigma = sigma;
   // bit conversion from 14bit to 32bit
   assign vC_32   = { {19{i_vC[13]}} , i_vC[12:0] };
   assign iC_32   = { {19{i_iC[13]}} , i_iC[12:0] };
   // sigma from {0,1} to {-1,1}
   assign sigma_not = { {31{sigma_prev}} , 1'b1 }; // NOTE that is reverse to avoid minus sign

   assign o_MOSFET = { sigma_prev , ~sigma_prev , ~sigma_prev , sigma_prev };


//   assign o_debug = { jump_enable, sigma_reset , {{ jump[31] , jump[22:10] }+14'sd8191}};
   assign o_debug = { jump[31]};


// function instantiation
trigonometry_deg trigonometry_inst (
   .o_cos(ctheta),    // cosine of the input
   .o_sin(stheta),    // sine of the input
   .i_theta(i_theta)  // input angle
);


// variable initialization
initial begin
   sigma_prev  = 1'b1;
   sigma       = 1'b1;
   counter     = 10'b0;
end



// latch for the signal feedback
always @(posedge i_clock) begin
   sigma_prev <= sigma;
end


always @(*) begin
   // compute coordinate transformation
   z1       = mu_z1*(vC_32)+sigma_not*Vg;  // note that sigma is already inverted
   z2       = mu_z2*(iC_32);
   jump     = z1*stheta + z2*ctheta;
   // jump_1   = ( z1*stheta + z2*ctheta ) * sigma_not;
   // jump_2   = ((~z1+1)*ctheta + z2*stheta ) * sigma_not;
   if (jump_enable) begin           // can jump
      sigma <= jump[31];
   end else begin
      sigma <= sigma_prev;
   end
end

always @(posedge i_clock ) begin
   if(sigma_prev == sigma) begin // nothing change, continue to count
      if( counter!=0 ) begin // count if EN=0
         if( counter < delay )
            counter <= counter+1'b1;
         else
            counter <= 10'b0; // reset the counter when it reach the limit
      end
   end else begin
      counter <= 10'b1;
   end
end

assign jump_enable = (counter == 0) ? 1'b1 : 1'b0;




endmodule