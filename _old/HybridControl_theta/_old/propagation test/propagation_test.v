//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/02/09) (15:16:45)
// File: hybrid_control.v
//------------------------------------------------------------
// Description:
//
// Block that implements the hybrid control. It can work
// in three different modalities:
//  00 - jump set is half plane
//  01 - jump set is one quarter plane
//  10 - time regularization (inhibit jump for a while)
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

module propagation_test (
   o_sigma,     // output switching variable
   o_debug,     // [14bit]
   i_clock,     // for sequential behavior
   i_RESET,     // reset signal
   i_vC,        // [14bit-signed] input related to z1
   i_iC,        // [14bit-signed] input related to z2
   i_theta,     // [32bit-signed] angle of the switching surface
   i_mode       // [2bit] control mode
);

output                o_sigma;
output        [15:0]  o_debug;
input                 i_clock;
input                 i_RESET;
input  signed [13:0]  i_vC;
input  signed [13:0]  i_iC;
input  signed [31:0]  i_theta;
input         [1:0]   i_mode;


wire signed [31:0]  vC_32;  //
wire signed [31:0]  iC_32;  //
reg signed [31:0]  vC_32_p;  //
reg signed [31:0]  iC_32_p;  //
reg signed [31:0]  jump_p;  //
wire signed [31:0]  ctheta;  //
wire signed [31:0]  stheta;  //


// CONSTANTS
   integer mu_z1 = 110;        // multiplier for z1 (voltage)
   integer mu_z2 = 121;        // multiplier for z2 (current), include sqrt(L/C)
   integer Vg    = 240000;     // input voltage scaled accordingly to z1
   integer delay = 100;         // time for which jumps are inhibits

// INTERNAL VARIABLE
   integer z1;                   // state z1
   integer z2;                   // state z1
   integer jump, jump_1, jump_2; // variable to evaluate the current set
   integer counter;

   reg  sigma_prev, sigma;  // output variable sigma {0,1}
   reg  overflow = 1'b0;
   wire jump_enable, sigma_reset;
   reg  clk_50;
   reg  toggle_in,toggle_out;
   reg  toggle_in_p,toggle_out_p;

   wire signed [31:0] sigma_not;   // state ~sigma {-1,1} !! is the negate

// assign output variable
   assign o_sigma = sigma;
   // bit conversion from 14bit to 32bit
   assign vC_32   = { {19{i_vC[13]}} , i_vC[12:0] };
   assign iC_32   = { {19{i_iC[13]}} , i_iC[12:0] };
   // sigma from {0,1} to {-1,1}
   assign sigma_not = { {31{sigma_prev}} , 1'b1 }; // NOTE that is reverse to avoid minus sign


//   assign o_debug = { jump_enable, sigma_reset , {{ jump[31] , jump[22:10] }+14'sd8191}};
   assign o_debug = { jump_enable, sigma_reset , 10'b0,clk_50, toggle_out, 1'b0, toggle_in};


// function instantiation
trigonometry trigonometry_inst (
   .o_cos(ctheta),    // cosine of the input
   .o_sin(stheta),    // sine of the input
   .i_theta(i_theta)  // input angle
);


// variable initialization
initial begin
   sigma_prev  = 1;
   sigma       = 1;
   counter     = 0;
   clk_50      = i_clock;
   toggle_in   = 0;
   toggle_out  = 0;
end

always @(vC_32 or iC_32 or jump) begin
   if ( (vC_32!=vC_32_p) |  (iC_32!=iC_32_p))
      toggle_in <= ~toggle_in_p;

   if (jump!=jump_p)
      toggle_out <= ~toggle_out_p;
end



// latch for the signal feedback
always @(posedge i_clock) begin
   sigma_prev <= sigma;
   clk_50 <= ~clk_50;
   toggle_out_p <= toggle_out;
   toggle_in_p  <= toggle_in;
   vC_32_p <= vC_32;
   iC_32_p <= iC_32;
   jump_p  <= jump;
end


always @(*) begin
   // compute coordinate transformation
   z1       = mu_z1*(vC_32)+sigma_not*Vg;  // note that sigma is already inverted
   z2       = mu_z2*(iC_32);
   jump     =   z1*stheta + z2*ctheta;
   jump_1   = ( z1*stheta + z2*ctheta ) * sigma_not;
   jump_2   = ((~z1+1)*ctheta + z2*stheta ) * sigma_not;
   sigma   <= jump[31];
end

always @(posedge clk_50 or negedge sigma_reset) begin
   if(~sigma_reset) begin
      counter <= 1;
   end else begin
      if( ~jump_enable ) begin
         if( counter < delay )
            counter <= counter+1;
         else
            counter <= 0;
      end
   end
end

assign sigma_reset = (sigma_prev!=sigma) ? 1'b0 : 1'b1;

assign jump_enable = (counter == 0) ? 1'b1 : 1'b0;

endmodule