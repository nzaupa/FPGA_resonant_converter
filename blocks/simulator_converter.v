//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2024/01/09) (17:59:17)
// File: simulator_converter.v
//------------------------------------------------------------
// Description:
// Simulate different converters. 
// First is an LLC converter with resistive load
// LLC parameters 
//    [L]   = uH
//    [C]   = nF
//    [Lm]  = uH
//    [Req] = mOhm
//    [Vg]  = mV
//    [dt]  = ns
// the discrete model is given by
//    vC_r = vC + (mu_1*iS)>>>20;
//    iS_r = iS + mu_3*sigma_32 + mu_2*(vC +*Vo);
//    Vo_r = Vo + (mu_5*Vo)>>>17 + (mu_6*vC)>>10 + (mu_7*sigma_32)>>10;
// the constants mu_i are given by
//    mu_1 =  (dt*1000*2^10)/(C)
//    mu_2 =  (dt*Vg*1000)/L
//    mu_3 = -dt/L
//    mu_4 = -dt/L
//    mu_5 = -(dt*Req*2^17)*(1+L/Lm)/(L*1e6)
//    mu_6 = -(dt*Req*2^10)/(L*1e6)
//    mu_7 =  (dt*Req*Vg*2^6)/(L*1e3)
// --> there is a Python code 'simulator_converter.py' that compute the constants
// below the constants for the following parameters
//    L   = 10    uH
//    C   = 850   nF
//    Lm  = 30    uH
//    Req = 4200  mOhm
//    Vg  = 24000 mV
//    dt  = 10    ns
//------------------------------------------------------------

`timescale 1 ns / 1 ps

module simulator_LLC #(
   parameter mu_1 =  12,
   parameter mu_2 = -1,
   parameter mu_3 =  24000,
   parameter mu_4 = -4,
   parameter mu_5 = -734,
   parameter mu_6 =  101
)(
   output signed [31:0]  vC_p, 
   output signed [31:0]  iS_p, 
   output signed [31:0]  Vo_p,    
   input                 CLK,    
   input                 RESET,   
   input  signed [1:0]   sigma
);


// INTERNAL VARIABLE
integer vC; // equivalent to reg signed [31:0] vC;
integer iS;
integer Vo;


wire signed [31:0] sigma_32;

// assign output variable

assign vC_p = vC;
assign iS_p = iS;
assign Vo_p = Vo; 
assign sigma_32   = { {30{sigma[1]}} , sigma };

// variable initialization
initial begin
   vC = 0;
   iS = 0;
   Vo = 0;
end


always @(posedge CLK or negedge RESET) begin
   if (~RESET) begin
      vC <= 0;
      iS <= 0;
      Vo <= 0;
   end else begin
      // vC <= vC + ((mu_1*iS)>>>20);
      // iS <= iS + mu_2*sigma_32 + mu_3*vC + mu_4*Vo;
      // Vo <= Vo + mu_7*sigma_32 + ((mu_5*Vo)>>>17) + ((mu_6*vC)>>>10);
      vC <= vC + ((mu_1*iS)>>>20);
      iS <= iS + mu_2*(vC + Vo) + mu_3*sigma_32;
      Vo <= Vo + ((mu_4*vC)>>>10) + ((mu_5*Vo)>>>17) + mu_6*sigma_32;
   end
end



endmodule

//------------------------------------------------------------
// Description:
// Implement the behavior of the sensing chain and the ADC
// take as input:
//    v_in in mV
//    i_in in uA
// The parameters are highly depended on the circuit components
//------------------------------------------------------------

module simulator_ADC_14bit #(
   parameter mu_I = 65,
   parameter mu_V = 140
)(
   output signed [13:0]  v_ADC, 
   output signed [13:0]  i_ADC,   
   input  signed [31:0]  v_in, 
   input  signed [31:0]  i_in
);

// INTERNAL VARIABLE
wire signed [31:0] v_scaled, i_scaled;

// assign output variable
assign v_ADC = v_scaled[13:0];
assign i_ADC = i_scaled[13:0];

assign v_scaled = (v_in*mu_V)>>>10;
assign i_scaled = (i_in*mu_I)>>>17;


endmodule



