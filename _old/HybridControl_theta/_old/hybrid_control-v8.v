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

module hybrid_control (
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
wire signed [31:0]  ctheta;  //
wire signed [31:0]  stheta;  //


// CONSTANTS
   integer mu_z1 = 110;        // multiplier for z1 (voltage)
   integer mu_z2 = 121;        // multiplier for z2 (current), include sqrt(L/C)
   integer Vg    = 240000;     // input voltage scaled accordingly to z1
   integer delay = 600;         // time for which jumps are inhibits

// INTERNAL VARIABLE
   integer z1;                   // state z1
   integer z2;                   // state z1
   integer jump, jump_1, jump_2; // variable to evaluate the current set
   integer counter,cnt2;

   reg  sigma_prev, sigma;  // output variable sigma {0,1}
   reg  overflow = 1'b0;
   wire jump_enable, sigma_reset;
   reg  sigma_reset_enl;
   reg  clk_50;

   wire signed [31:0] sigma_not;   // state ~sigma {-1,1} !! is the negate

// assign output variable
   assign o_sigma = sigma;
   // bit conversion from 14bit to 32bit
   assign vC_32   = { {19{i_vC[13]}} , i_vC[12:0] };
   assign iC_32   = { {19{i_iC[13]}} , i_iC[12:0] };
   // sigma from {0,1} to {-1,1}
   assign sigma_not = { {31{sigma_prev}} , 1'b1 }; // NOTE that is reverse to avoid minus sign


//   assign o_debug = { jump_enable, sigma_reset , {{ jump[31] , jump[22:10] }+14'sd8191}};
   assign o_debug = { jump_enable, sigma_reset , 10'b0,clk_50,  2'b0, sigma_reset_enl };


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
   cnt2        = 0;
   clk_50      = i_clock;
end



// latch for the signal feedback
always @(posedge i_clock) begin
   sigma_prev <= sigma;
   clk_50 <= ~clk_50;
end


always @(*) begin
   // compute coordinate transformation
   z1       = mu_z1*(vC_32)+sigma_not*Vg;  // note that sigma is already inverted
   z2       = mu_z2*(iC_32);
   jump     =   z1*stheta + z2*ctheta;
   jump_1   = ( z1*stheta + z2*ctheta ) * sigma_not;
   jump_2   = ((~z1+1)*ctheta + z2*stheta ) * sigma_not;
   case(i_mode)
      //---------------------
      // HALF PLANE
      //---------------------
      2'b00: begin
         sigma <= jump[31];
      end
      //---------------------
      // ONE QUARTER PLANE
      //---------------------
      2'b01: begin
         if (jump_1<0 & jump_2<0)
            sigma <= ~sigma_prev;
         else
            sigma <= sigma_prev;
      end
      //---------------------
      // TIME REGULARIZATION
      //---------------------
      2'b10: begin
         if (jump_enable) begin           // can jump
            sigma <= jump[31];
         end else begin
            sigma <= sigma_prev;
         end
      end
      //---------------------
      // DEFAULT
      //---------------------
      default: begin
         sigma <= 1;
      end
   endcase
end

always @(posedge i_clock or negedge sigma_reset) begin
   if(~sigma_reset) begin  // start the counter
      counter <= 1;
   end else begin
      if( ~jump_enable ) begin // count if EN=0
         if( counter < delay )
            counter <= counter+1;
         else
            counter <= 0; // reset the counter when it reach the limit
      end
   end
end

always @(negedge sigma_reset or posedge i_clock) begin
   if(~sigma_reset) begin
      sigma_reset_enl <= 0;
   end else begin
      if(cnt2<150 & sigma_reset_enl==0) begin
         sigma_reset_enl <= 0;
         cnt2 <= cnt2+1;
      end else begin
         sigma_reset_enl <= 1;
         cnt2 <= 0;
      end
   end
end

assign sigma_reset = (sigma_prev!=sigma) ? 1'b0 : 1'b1;

assign jump_enable = (counter == 0) ? 1'b1 : 1'b0;

endmodule