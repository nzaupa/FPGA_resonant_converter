//------------------------------------------------------------
// Project: HYBRID_CONTROL_PHI
// Author: Nicola Zaupa
// Date: (2022/02/14) (09:21:05)
// File: hybrid_control_phi_regularization.v
//------------------------------------------------------------
// Description:
//
// Block that implements the hybrid control.
// jump set is implemented as <<half-plane>>
// The input parameters are:
//  - voltage (14bit-signed)
//  - current (14bit-signed)
// NOTE:
//  + sin and cosine are computed internally
//  + sigma is an internal state variable
//  + input vC and iC are signed 14bit except the
//    angle which is 32bit signed
//------------------------------------------------------------


`timescale 1 ns / 1 ps

module hybrid_control_phi_regularization (
   o_MOSFET,    // command signal for the MOSFETs
   o_sigma,     // output switching variable
   o_debug,     // [14bit]
   i_clock,     // for sequential behavior
   i_RESET,     // reset signal
   i_vC,        // [14bit-signed] input related to z1
   i_iC,        // [14bit-signed] input related to z2
   i_phi        // [32bit-signed] angle of the switching surface
);

output        [3:0]  o_MOSFET;
output        [1:0]  o_sigma;
output       [29:0]  o_debug;
input                i_clock;
input                i_RESET;
input signed [13:0]  i_vC;
input signed [13:0]  i_iC;
input signed [31:0]  i_phi;

wire  signed [31:0]  vC_32;  //
wire  signed [31:0]  iC_32;  //
// wire  signed [31:0]  vC_32_filt;  //
// wire  signed [31:0]  iC_32_filt;  //
wire  signed [31:0]  cphi;  //
wire  signed [31:0]  sphi;  //


// CONSTANTS
   integer mu_z1 = 32'd16;//110;        // multiplier for z1 (voltage)
   integer mu_z2 = 32'd17;//121;        // multiplier for z2 (current), include sqrt(L/C)    17 = 12/0.7 (0.7 found with MATLAB)
   integer Vg    = 24000;//130000;     // input voltage scaled accordingly to z1
   // reg [9:0] delay = 10'd200;        // time for which jumps are inhibits

// INTERNAL VARIABLE
   integer A, B, C;     // variable associated to the coordinates
   integer S1, S2, S3;  // variable to evaluate the current set

   reg [1:0] counter, counter_prev;   // counter for the automata: sigma => +1 -> 0 -> -1 -> 0 -> +1 -> ...
   wire [1:0] inc;
   wire C1, C2, C3, C4; // condition for the jump set, when 1 we are in a jump set 
   wire [3:0] C_dd;
   wire C1_db, C2_db, C3_db, C4_db; 
   wire CLK_jump;       // rising edge when is time to go to the next jump set
   reg  CLK_jump_prev;   // previous value of the clock
   wire CLK_jump_OR;    // output of the conditions (need to be filtered to avoid constant value 1)
   wire b1, b0;
   
   wire [31:0] sigma;
   // wire [13:0] S2_14;

// assign output variable
   assign o_sigma = sigma[1:0];
   // bit conversion from 14bit to 32bit
   assign vC_32 = { {19{i_vC[13]}} , i_vC[12:0] };
   assign iC_32 = { {19{i_iC[13]}} , i_iC[12:0] };

   assign b0 = counter[0];
   assign b1 = counter[1];
   assign C1_db = ~S1[31];
   assign C2_db =  S2[31];
   assign C3_db =  S3[31];
   assign C4_db = ~S2[31];

   assign CLK_jump_OR = ( C1 & (~b1) & (~b0) ) | ( C2 & (~b1) & b0 ) | ( C3 & b1 & (~b0) ) | ( C4 & b1 & b0 );
   assign CLK_jump    = CLK_jump_OR & (~CLK_jump_prev);

   assign o_MOSFET[0] = (~b1) | (b1&b0);
   assign o_MOSFET[1] =   b1  | ((~b1)&b0);
   assign o_MOSFET[2] = b1 & (~b0);
   assign o_MOSFET[3] = ~(b1|b0);

   assign sigma   = { {31{b1&(~b0)}} , ~b0 };

   assign o_debug = { {S2[31], S2[26:14]},//S2_14[12:0]},
                     C1_db , C2_db , C3_db, C4_db,
                     C1 , C2 , C3, C4, 
                     4'b0, //~vC_32_filt[31],~iC_32_filt[31],
                     CLK_jump , CLK_jump_OR,  
                     ~i_vC[13], ~i_iC[13] };
   
   assign o_sigma = sigma[1:0];

   assign inc = (i_phi == 0) ? 2'b10 : 2'b01;

   // assign S2_14 = S2 >>> 13;


// function instantiation
trigonometry_deg trigonometry_inst (
   .o_cos(cphi),    // cosine of the input
   .o_sin(sphi),    // sine of the input
   .i_theta(i_phi)  // input angle
);

// debunce jump set condition
debounce_4bit debounce_4bit_inst(
   .o_switch( C_dd ),
   .i_clk(i_clock),
   .i_reset(i_RESET),
   .i_switch( {C4_db,C3_db,C2_db,C1_db} ),
   .debounce_limit(8'd5)  // 10ns  //31'd5
);

regularization_4bit regularization_4bit_inst (
   .o_signal( {C4,C3,C2,C1} ),
   .i_clk(i_clock),
   .i_reset(i_RESET),
   .i_signal({C4_db,C3_db,C2_db,C1_db}),
   .debounce_limit(16'd2),
   .delay(16'd500)
);

// variable initialization
initial begin
   counter_prev  = 2'b00;
   counter       = 2'b00;
end

// latch for the signal feedback
always @(posedge i_clock  ) begin
   CLK_jump_prev <= CLK_jump;
   counter_prev  <= counter;
end

always @(posedge CLK_jump or negedge i_RESET) begin
   if (~i_RESET) begin
      counter <= 2'b00;
   end else begin
      counter <= counter_prev + inc;
   end
end


always @(posedge i_clock) begin
   // compute coordinate transformation
   A  = ( mu_z1*(vC_32) + (~sigma+1)*Vg ) * sphi; // z1*sin(phi)
   B  = ( mu_z2*(iC_32) ) * cphi;        // z2*cos(phi) 32'd1638
   C  = Vg * sphi;                                // Vg*sin(phi)

   S1 = A + (~B+1) + C;          // z1*cos(phi)-z2*cos(phi)+Vg*sin(phi)
   S2 = A + B;                   // z1*cos(phi)+z2*cos(phi)
   S3 = A + (~B+1) + (~C+1);     // z1*cos(phi)-z2*cos(phi)-Vg*sin(phi)
end

endmodule


// LPF_32 LPF_32_inst_vC(
//    .o_mean(vC_32_filt),      // [32bit-signed] mean on 4 samples
//    .i_clock(i_clock),     // for sequential behavior
//    .i_RESET(i_RESET),     // reset signal
//    .i_data(vC_32)       // [32bit-signed] input data to be filtered
// );

// LPF_32 LPF_32_inst_iC(
//    .o_mean(iC_32_filt),      // [32bit-signed] mean on 4 samples
//    .i_clock(i_clock),     // for sequential behavior
//    .i_RESET(i_RESET),     // reset signal
//    .i_data(iC_32)       // [32bit-signed] input data to be filtered
// );
