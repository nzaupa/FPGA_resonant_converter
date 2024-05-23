//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2024/05/06) (16:01:04)
// File: hybrid_control_mixed.v
//------------------------------------------------------------
// Description:
//
// Block that implements the hybrid control.
// Consider the possibility to modify independently
// the two angles:
//    - ZVS for the distance from the x-axis
//    - phi for half of the cone aperture
// jump set is implemented as <<half-plane>>
// The input parameters are:
//  - voltage (14bit-signed)
//  - current (14bit-signed)
// NOTE:
//  + sin and cosine are computed internally
//  + sigma is an internal state variable
//  + input vC and iC are signed 14bit except the
//    angle which is 32bit signed
//  + the control law is implemented in the x-plane
//------------------------------------------------------------

`timescale 1 ns / 1 ps

module hybrid_control_mixed #(
   parameter mu_z1 = 32'd86,
   parameter mu_z2 = 32'd90
)(
   output         [3:0]  o_MOSFET,    // command signal for the MOSFETs
   output         [1:0]  o_sigma,     // output switching variable
   output        [29:0]  o_debug,     // [14bit]
   input                 i_clock,     // for sequential behavior
   input                 i_RESET,     // reset signal
   input  signed [13:0]  i_vC,        // [14bit-signed] input related to z1
   input  signed [13:0]  i_iC,        // [14bit-signed] input related to z2
   input  signed [31:0]  i_ZVS,     // [32bit-signed] angle freq. mod.
   input  signed [31:0]  i_phi,       // [32bit-signed] angle phase mod.
   input  signed [31:0]  i_sigma
);

wire signed [31:0]  vC_32;  //
wire signed [31:0]  iC_32;  //

wire signed [31:0]  czvs;  // cos( theta+phi )
wire signed [31:0]  szvs;  // sin( theta+phi )
wire signed [31:0]  cphi;  // cos( theta-phi )
wire signed [31:0]  sphi;  // sin( theta-phi )

// wire [31:0] shift;


// INTERNAL VARIABLE
   integer Z1, Z2, C;     // variable associated to the coordinates
   integer X1, X2;     // variable associated to the coordinates
   integer S0, S1, S3;  // variable to evaluate the current set

   reg  [1:0] counter, counter_prev;   // counter for the automata: sigma => +1 -> 0 -> -1 -> 0 -> +1 -> ...
   wire [1:0] inc;   // increment for the counter
   wire C1, C2, C3, C4; // condition for the jump set, when 1 we are in a jump set 
   // wire C1_db, C2_db, C3_db, C4_db; 
   wire CLK_jump;       // rising edge when is time to go to the next jump set
   reg  CLK_jump_prev,CLK_jump_tmp;   // previous value of the clock
   wire CLK_jump_OR;    // output of the conditions (need to be filtered to avoid constant value 1)
   wire b1, b0;
   wire [1:0] S;     // regularized version of the switching surface
   
   // wire signed [31:0] sigma;
   wire [31:0] sigma;

// assign output variable
   assign o_sigma = sigma[1:0];
// bit conversion from 14bit to 32bit
   assign vC_32 = { {19{i_vC[13]}} , i_vC[12:0] };
   assign iC_32 = { {19{i_iC[13]}} , i_iC[12:0] };

   assign b0 = counter[0];
   assign b1 = counter[1];

   // assign C0 = ( S[0]) & ( S[1]);  // zone where sigma = +1
   // assign C1 =  ~S[0];  // zone where sigma =  0
   // assign C2 = (~S[0]) & (~S[1]);  // zone where sigma = -1
   // assign C3 =   S[0];  // zone where sigma =  0

   assign C0 =  S[1];  // zone where sigma = +1
   assign C1 = ~S[0];  // zone where sigma =  0
   assign C2 = ~S[1];  // zone where sigma = -1
   assign C3 =  S[0];  // zone where sigma =  0

   assign CLK_jump_OR = ( C1 & (~b1) & (~b0) ) | 
                        ( C2 & (~b1) &   b0  ) | 
                        ( C3 &   b1  & (~b0) ) | 
                        ( C0 &   b1  &   b0  );
   assign CLK_jump    = CLK_jump_OR & (~CLK_jump_prev);

   assign o_MOSFET[0] = (~b1) | (b1&b0);
   assign o_MOSFET[1] =   b1  | ((~b1)&b0);
   assign o_MOSFET[2] =   b1  & (~b0);
   assign o_MOSFET[3] = ~(b1  | b0);

   // b1 b0 sigma
   // 0  0   +1
   // 0  1    0
   // 1  0   -1
   // 1  1    0  
   assign sigma   = { {31{b1&(~b0)}} , ~b0 };

   assign o_debug = { 1'b0, S3[30:17],
                     o_sigma[1:0], 4'b0,
                     S1[31], S0[31],
                     C3, C2, C1, C0,
                     S[1], S[0] , b0 , b1};

   assign o_sigma = sigma[1:0];

   // assign inc = (i_phi == 0) ? 2'b10 : 2'b01;
   assign inc = 2'b01;


// function instantiation
trigonometry_deg trigonometry_ZVS_inst (
   .o_cos(czvs),    // cosine of the input
   .o_sin(szvs),    // sine of the input
   .i_theta(i_ZVS)  // input angle "theta+phi"
);

trigonometry_deg trigonometry_phi_ZVS_inst (
   .o_cos(cphi),          // cosine of the input
   .o_sin(sphi),          // sine of the input
   .i_theta(i_ZVS+(i_phi<<1))  // input angle "ZVS+2*phi"
);

// regularize the sign from the switching surface
// this avoid to consider noise/changes in the signal when we are
// sure that there are not going to be changes
// IDEALLY, the sign should change with the frequency of the oscillation
//     i.e. we do not have spikes/short changes in NORMAL behavior
regularization #(
   .DEBOUNCE_TIME(2), // 20ns
   .DELAY(200), // 2us
   .N(2)
) regularization_4bit_inst (
   .o_signal( S ),
   .i_clk(i_clock),
   .i_reset(i_RESET),
   .i_signal({S1[31],S0[31]})
);


// variable initialization
initial begin
   counter_prev  = 2'b00;
   counter       = 2'b00;
   CLK_jump_tmp  = 1'b0;
   CLK_jump_prev = 1'b0;
end

// latch for the signal feedback
// it looks two samples back
// this was improving the simulation where 
// two edges where detected one after the other
always @(posedge i_clock ) begin
   CLK_jump_tmp  <= CLK_jump;
   CLK_jump_prev <= CLK_jump_tmp;
   counter_prev  <= counter;
end

always @(posedge CLK_jump or negedge i_RESET) begin
   if (~i_RESET) begin
      counter <= 2'b10;
   end else begin
      counter <= counter_prev + inc;
   end
end

always @(posedge i_clock) begin
   // compute coordinate transformation
   X1  = $signed(mu_z1) * vC_32;
   X2  = $signed(mu_z2) * iC_32;    

   // compute the switching line, we are just interested in the sign afterwards
   S0 = X1*sphi + (~(X2*cphi)+1);
   S1 = X1*szvs + (~(X2*czvs)+1);
   
end

endmodule

