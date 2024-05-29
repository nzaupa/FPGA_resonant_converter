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
//    Ibat_sens = gamma*N*Ibat/Rif2/Rif1    
// 
// then, the 8-bit ADC has a range 0-2V
//    Ibat_adc = Ibat_sens/2*2^8 = Ibat_sens*128

module sensing_Ibat(
   input   [7:0] Ibat_ADC,
   output  [7:0] Ibat_DEC,
   output [31:0] Ibat_mA,
   output [15:0] SEG_HEX,
   output [15:0] SEG_DEC
);


// compute current value in dA (10^-1)
assign Ibat_DEC = (Ibat_ADC*32'd10) >>4;

// assign Ibat_mA = (Ibat_ADC*32'd131) >>1;
assign Ibat_mA = Ibat_ADC <<6; // ×64 update from estimation



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

endmodule




// --- VOLTAGE ---
// the theoretical relation between output and sensed voltage is:
//    Vbat_sens = 
// then, the 8-bit ADC has a range 0-2V
//    Vbat_adc = Vbat_sens/2*(2^8-1) = Vbat_sens*255/5

module sensing_Vbat(
   input   [7:0] Vbat_ADC,
   output  [7:0] Vbat_DEC,
   output [15:0] SEG_HEX,
   output [15:0] SEG_DEC
);


// compute current value in dA (10^-1)
assign Vbat_DEC = (Vbat_ADC * 32'd11)>>5;

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

endmodule

