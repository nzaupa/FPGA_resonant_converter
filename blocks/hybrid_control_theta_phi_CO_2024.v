//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/28) (09:05:37)
// File: hybrid_control_theta_phi.
// ------------------------------------------------------------
// Description:
//
// Block that implements the hybrid control.
// Consider the possibility to modify independently
// the two angles
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

module hybrid_control_theta_phi_CO24 #(
   parameter mu_z1 = 32'd86,
   parameter mu_z2 = 32'd90,
   parameter mu_Vg = 312000
)(
   output         [3:0]  o_MOSFET,    // command signal for the MOSFETs
   output         [1:0]  o_sigma,     // output switching variable
   output        [29:0]  o_debug,     // [14bit]
   input                 i_clock,     // for sequential behavior
   input                 i_RESET,     // reset signal
   input  signed [13:0]  i_vC,        // [14bit-signed] input related to z1
   input  signed [13:0]  i_iC,        // [14bit-signed] input related to z2
   input  signed [31:0]  i_theta,     // [32bit-signed] angle freq. mod.
   input  signed [31:0]  i_phi,       // [32bit-signed] angle phase mod.
   input  signed [31:0]  i_sigma
);

wire signed [31:0]  vC_32;  //
wire signed [31:0]  iC_32;  //

wire signed [31:0]  ctpf;  // cos( theta+phi )
wire signed [31:0]  stpf;  // sin( theta+phi )
wire signed [31:0]  ctmf;  // cos( theta-phi )
wire signed [31:0]  stmf;  // sin( theta-phi )

// CO COMPARE PHI
wire  signed [31:0]  cphi;
wire  signed [31:0]  sphi;

// wire [31:0] shift;


// INTERNAL VARIABLE
   integer Z1, Z2, C;     // variable associated to the coordinates
   integer S1, S2, S3;  // variable to evaluate the current set
	
	// CO: variable to evaluate the current set
	integer S11, S22, S33;  
	
	// CO COMPARE PHI
	integer Aphi, Bphi, Cphi;     // variable associated to the coordinates
   integer S1phi, S2phi, S3phi;  // variable to evaluate the current set
	wire C1phi_db, C2phi_db, C3phi_db, C4phi_db; 
	wire C1phi, C2phi, C3phi, C4phi; // condition for the jump set, when 1 we are in a jump set 

   reg  [1:0] counter, counter_prev;   // counter for the automata: sigma => +1 -> 0 -> -1 -> 0 -> +1 -> ...
   wire [1:0] inc;   // increment for the counter
   wire C1, C2, C3, C4; // condition for the jump set, when 1 we are in a jump set 
   wire C1_db, C2_db, C3_db, C4_db; 
   wire CLK_jump;       // rising edge when is time to go to the next jump set
   reg  CLK_jump_prev;   // previous value of the clock
   wire CLK_jump_OR;    // output of the conditions (need to be filtered to avoid constant value 1)
   wire b1, b0;
	reg [1:0] b; //CO : this is the register of the state machine
   
   // wire signed [31:0] sigma;
   wire [31:0] sigma;

// assign output variable
   assign o_sigma = sigma[1:0];
// bit conversion from 14bit to 32bit
   assign vC_32 = { {19{i_vC[13]}} , i_vC[12:0] };
   assign iC_32 = { {19{i_iC[13]}} , i_iC[12:0] };

   assign b0 = counter[0];
   assign b1 = counter[1];
	
   // CO 13/02/24: remove regularization approach A
	//assign C1_db = ~S1[31]; // if the last bit [31] is 1, S1 < 0, if it is 0, then S1 > 0
   //assign C2_db = ~S2[31];
   //assign C3_db =  S3[31];
   //assign C4_db =  S2[31];
	assign C1 = ~S1[31]; // if the last bit [31] is 1, S1 < 0, if it is 0, then S1 > 0
   assign C2 = ~S2[31];
   assign C3 =  S3[31];
   assign C4 =  S2[31];

	// CO COMPARE PHI: these are the conditions from phi control
	assign C1phi_db = ~S1phi[31];
   assign C2phi_db =  S2phi[31];
   assign C3phi_db =  S3phi[31];
   assign C4phi_db = ~S2phi[31];
	

   assign CLK_jump_OR = ( C1 & (~b1) & (~b0) ) | 
                        ( C2 & (~b1) &   b0  ) | 
                        ( C3 &   b1  & (~b0) ) | 
                        ( C4 &   b1  &   b0  );
   assign CLK_jump    = CLK_jump_OR & (~CLK_jump_prev);

	
	// CO 13/02/24: use state machine - approach B
	// This needs revision.
   // assign o_MOSFET[0] = (~b[1]) | (b[1]&b[0]);
   // assign o_MOSFET[1] =   b[1]  | ((~b[1])&b[0]);
   // assign o_MOSFET[2] =   b[1]  & (~b[0]);
   // assign o_MOSFET[3] = ~(b[1] | b[0]);
   // assign sigma   = { {31{b[1]&(~b[0])}} , ~b[0] };
	assign o_MOSFET[0] = (~b1) | (b1&b0);
   assign o_MOSFET[1] =   b1  | ((~b1)&b0);
   assign o_MOSFET[2] =   b1  & (~b0);
   assign o_MOSFET[3] = ~(b1  | b0);
   assign sigma   = { {31{b1&(~b0)}} , ~b0 };

	
	
   assign o_debug = { C3_db, S3[30:17],
							 o_sigma[1:0], b[1:0],
                      C4phi, C3phi, C2phi, C1phi,
							 C4, C3, C2, C1,
                      CLK_jump, CLK_jump , b0 , b1};

   //assign o_debug = { C3_db, S3[30:17],
   //                   //C4,C3,C2,C1,
	//						 C4, C3, b[1:0],
   //                   CLK_jump , b0 , b1};

   // assign o_debug = {   {S2[31], S2[26:14]},
   //                      C1_db , C2_db , C3_db, C4_db,
   //                      C1 , C2 , C3, C4, 
   //                      CLK_jump , CLK_jump_OR, 
   //                      1'b0 , ~vC_32[31] , ~iC_32[31] , CLK_jump_prev, counter[1:0] };

   assign o_sigma = sigma[1:0];

   assign inc = (i_phi == 0) ? 2'b10 : 2'b01;
   // assign inc = 2'b01;

   // assign shift = 32'b1;
   // assign shift = (i_phi==0) ? 32'b0 : 32'b1;

// variable initialization
initial begin
   counter_prev = 2'b00;
   counter      = 2'b00;
	b = 2'b00;
end


// ======================================== //
// =========== SEQUENTIAL PART ============ //
// ======================================== //
// latch for the signal feedback
always @(posedge i_clock ) begin
   CLK_jump_prev <= CLK_jump;
   counter_prev  <= counter;
end

always @(posedge CLK_jump or negedge i_RESET) begin
   if (~i_RESET) begin
      counter <= 2'b00;
		//b <= 2'b00;
   end else begin
      counter <= counter_prev + inc;
   end
end

always @(posedge i_clock) begin
   // compute coordinate transformation
   // CO: Update the update of Z1, Z2 and C using signed versions of the inputs
	//Z1  = ( mu_z1 * (vC_32) + (~sigma+1)*mu_Vg ); // z1
   //Z2  = ( mu_z2 * (iC_32) ) ;                   // z2
   //C   =   mu_Vg *  stmf;                        // Vg*sin(theta-phi)

	Z1  = $signed(mu_z1) * vC_32 + (~($signed(sigma)*$signed(mu_Vg))+1); // z1
   Z2  = $signed(mu_z2) * iC_32;                   // z2
   C   = $signed(mu_Vg) *  stmf;  

	S1 = Z1*stmf + Z2*ctmf + C;          // change z1*sin(theta-phi)-z2*cos(theta-phi)+Vg*sin(theta-phi)
	S2 = Z1*stpf + Z2*ctpf;              // change z1*sin(theta+phi)+z2*cos(theta+phi)
	S3 = Z1*stmf + Z2*ctmf + (~C+1);     // change z1*sin(theta-phi)-z2*cos(theta-phi)-Vg*sin(theta-phi)		
	// CO: I have updated the code below
   // S1 = Z1*stmf + Z2*ctmf + C*shift;          // change z1*sin(theta-phi)-z2*cos(theta-phi)+Vg*sin(theta-phi)
   // S2 = Z1*stpf + Z2*ctpf;              // change z1*sin(theta+phi)+z2*cos(theta+phi)
   // S3 = Z1*stmf + Z2*ctmf + (~C+1)*shift;     // change z1*sin(theta-phi)-z2*cos(theta-phi)-Vg*sin(theta-phi)
	
	// CO COMPARE PHI: and this is the controller from phi control
	// compute coordinate transformation
   Aphi  = ( mu_z1*(vC_32) + (~sigma+1)*mu_Vg ) * sphi; // z1*sin(phi)
   Bphi  = ( mu_z2*(iC_32) ) * cphi;        // z2*cos(phi) 32'd1638
   Cphi  = mu_Vg * sphi;                                // Vg*sin(phi)
   S1phi = Aphi + (~Bphi+1) + Cphi;          // z1*cos(phi)-z2*cos(phi)+Vg*sin(phi)
   S2phi = Aphi + Bphi;                   // z1*cos(phi)+z2*cos(phi)
   S3phi = Aphi + (~Bphi+1) + (~Cphi+1);     // z1*cos(phi)-z2*cos(phi)-Vg*sin(phi)
	
	
	case (b[1:0])
	   2'b00 : begin
			// TODO: can we debounce this input?
			S11 <= Z1*stmf + Z2*ctmf + C;          // change z1*sin(theta-phi)-z2*cos(theta-phi)+Vg*sin(theta-phi)
			S22[31] <= 1; // S2 < 0
			S33[31] <= 0; // S3 > 0
         //if (~S11[31])&() begin // we are in b=[00] AND S1 > 0 TODO: AND regularization = 1
		 if (~S11[31]) begin // we are in b=[00] AND S1 > 0
            b <= 2'b01;
         end
      end
      2'b01 : begin
			S11[31] <= 1; // S1 < 0
			S22 <= Z1*stpf + Z2*ctpf;              // change z1*sin(theta+phi)+z2*cos(theta+phi)
			S33[31] <= 0; // S3 > 0
		   if (~S22[31]) begin // we are in b=[01] and S2 > 0
				b <= 2'b10;
			end
      end
      2'b10 : begin 
			S11[31] <= 1; // S1 < 0
			S22[31] <= 0; // S2 > 0
			S33 <= Z1*stmf + Z2*ctmf + (~C+1);     // change z1*sin(theta-phi)-z2*cos(theta-phi)-Vg*sin(theta-phi)		
         if (S33[31]) begin // we are in b=[10] and S3 < 0
				b <= 2'b11;
			end
      end
		2'b11 : begin 
			S11[31] <= 1; // S1 < 0
			S22 <= Z1*stpf + Z2*ctpf;              // change z1*sin(theta+phi)+z2*cos(theta+phi)		
			S33[31] <= 0; // S3 > 0
         if (S22[31]) begin // we are in b=[11] and S2 < 0
				b <= 2'b00;
			end
      end
   endcase
	// CO: End of updated code
end

// ======================================== //
// ============== Functions =============== //
// ======================================== //
// function instantiation
trigonometry_deg trigonometry_plus_inst (
   .o_cos(ctpf),    // cosine of the input
   .o_sin(stpf),    // sine of the input
   .i_theta(i_theta)  // input angle
);

trigonometry_deg trigonometry_minus_inst (
   .o_cos(ctmf),    // cosine of the input
   .o_sin(stmf),    // sine of the input
   .i_theta(i_theta+(~i_phi+1))  // input angle
);

// CO COMPARE PHI
trigonometry_deg trigonometry_inst (
   .o_cos(cphi),    // cosine of the input
   .o_sin(sphi),    // sine of the input
   .i_theta(i_phi)  // input angle
);


// debunce jump set condition

// CO 13/02/24: remove regularization approach A
//regularization_4bit #(
//   .DEBOUNCE_TIME(2), 
//   .DELAY(20)
//) regularization_4bit_inst (
//   .o_signal( {C4,C3,C2,C1} ),
//   .i_clk(i_clock),
//   .i_reset(i_RESET),
//   .i_signal({C4_db,C3_db,C2_db,C1_db})
//);

// CO COMPARE PHI debunce jump set condition

// regularization_4bit #(
//    .DEBOUNCE_TIME(2), 
//    .DELAY(20)
// ) regularization_4bit_inst_phi (
//    .o_signal( {C4phi,C3phi,C2phi,C1phi} ),
//    .i_clk(i_clock),
//    .i_reset(i_RESET),
//    .i_signal({C4phi_db,C3phi_db,C2phi_db,C1phi_db})
// );



endmodule

