//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2024/05/08) (13:04:28)
// File: rectifier_sensing.v
//------------------------------------------------------------
// Description:
// definition of two modules which will manage the measures 
// from the ADC in the rectifier.
// 
// The ADCs that are used are: AD7822
//    the range is 0-2V (since VDD=3.3V)
// 
// We could also put the sampling...
// 
// In case, here we can introduce a lookup table
// 
//------------------------------------------------------------


// --- CURRENT ---
// the theoretical relation between current and sensed voltage is:
//    Ibat_sens = (gamma*N*Ibat + Vref)*Rif2/(Rif1+Rif2)*(1+Ri2/Ri1)    
//               0.07667*1        1.65       0.712        1+0
// then, the 8-bit ADC has a range 0-2V
//    Ibat_adc = Ibat_sens/2*2^8 = Ibat_sens*128

module sensing_Ibat(
   input   [7:0] Ibat_ADC,
   output  [7:0] Ibat_DEC,
   output [15:0] SEG_HEX,
   output [15:0] SEG_DEC
);

// wire [7:0] Ibat_conversion;

// compute current value in dA (10^-1)
// assign Ibat_DEC = ((Ibat_ADC + (~8'd152+1)) * 31'd23)>>4;
assign Ibat_DEC = (Ibat_ADC*32'd10) >>4;
// assign Ibat_DEC = Ibat_conversion;


// display the hexadecimal encoding
// BIN -> SEG
hex2seg_couple IbatHEX2display(
   .o_SEG(SEG_HEX),
   .i_hex(Ibat_ADC),
   .i_DP(2'b11)
);


// display the decimal value with the digital point
num2seg num2seg_Ibat (
   .o_SEG(SEG_DEC),
   .i_num(Ibat_DEC),
   .i_DP(2'b01)
);
// // DEC -> HEX
// dec2hex dec2hex_inst (
//    .o_seg(Ibat_HEX),
//    .i_dec(Ibat_DEC)
// );
// // HEX -> SEG
// hex2seg_couple IbatDEC2display(
//    .o_SEG(SEG_DEC),
//    .i_hex(Ibat_HEX),
//    .i_DP(2'b01)
// );

endmodule




// --- VOLTAGE ---
// the theoretical relation between output and sensed voltage is:
//    Vbat_sens = 
//               0.07667*1        1.65       0.712        1+0
// then, the 8-bit ADC has a range 0-2V
//    Ibat_adc = Ibat_sens/2*2^8 = Ibat_sens*128

module sensing_Vbat(
   input   [7:0] Vbat_ADC,
   output  [7:0] Vbat_DEC,
   output [15:0] SEG_HEX,
   output [15:0] SEG_DEC
);

// wire [31:0] test, Vbat_32;
// wire [7:0]  test_out;

// compute current value in dA (10^-1)
// assign Vbat_DEC = (Vbat_ADC * 32'd5)>>3;
assign Vbat_DEC = (Vbat_ADC * 32'd11)>>5;
// assign Ibat_DEC = (ADC_Ibat>>3) + (~8'd21+1);
// assign Vbat_32 = {24'b0,Vbat_ADC};

// assign test = (Vbat_32 * 32'd11);
// assign test_out = test[12:5];
// assign Vbat_DEC = test_out;

// display the hexadecimal encoding
// BIN -> SEG
hex2seg_couple VbatHEX2display(
   .o_SEG(SEG_HEX),
   .i_hex(Vbat_ADC),
   .i_DP(2'b11)
);


// display the decimal value with the digital point
// DEC -> HEX
num2seg num2seg_Vbat (
   .o_SEG(SEG_DEC),
   .i_num(Vbat_DEC),
   .i_DP(2'b11)
);
// dec2hex dec2hex_inst (
//    .o_seg(Vbat_HEX),
//    .i_dec(test[12:5])
// );
// // HEX -> SEG
// hex2seg_couple VbatDEC2display(
//    .o_SEG(SEG_DEC),
//    // .i_hex(Vbat_DEC),
//    .i_hex(Vbat_HEX),
//    .i_DP(2'b11)
// );

endmodule

