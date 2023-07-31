//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/01/19) (23:11:22)
// File: TOP_ResonantConverter_control.v
//------------------------------------------------------------
// Description:
// simulate the control law with a fictituos sinusoidal input
// ADC management and control
//------------------------------------------------------------

//   user interface define
//     LED :
//        LED[0]    --> CONVERTER_ON
//        LED[1]    --> ...
//        LED[2]    --> ...
//        LED[3]    --> ADC_A Out-of-Range indicator.
//        LED[4]    --> ADC_A Out-of-Range indicator.
//        LED[5]    --> ...
//        LED[6]    --> ...
//        LED[7]    --> ...
//      SWITCH :
//        SW[0] --> ENABLE CONVERTER
//        SW[1] --> ...
//        SW[2] --> // (DFS)Data Format Select
//        SW[3] --> // (DCS)Duty Cycle Stabilizer Select
//    BUTTON:
//        BUTTON[0] --> RESET



`timescale 1 ns / 1 ps
//`default_nettype none


module TOP_ResonantConverter_control (
   //clock + reset
   OSC,
   CPU_RESET,
   EXT_RESET,
   //data + out-of-range
   ADA_DATA,
   ADB_DATA,
   ADA_OR,
   ADB_OR,
   AD_SCLK,
   AD_SDIO,
   ADA_OE,
   ADA_SPI_CS,
   ADB_OE,
   ADB_SPI_CS,
   FPGA_CLK_A_N,
   FPGA_CLK_A_P,
   FPGA_CLK_B_N,
   FPGA_CLK_B_P,
   ADA_DCO,
   ADB_DCO,
   //output bridge signal
   OUT,
   //debugging
   SW,      // switches on the main board
   LED,     // LEDs on the main board
   LED_R,   // red LEDs on the adaptor
   LED_G,   // green LEDs on the adaptor
   VCC      // VCC connections for LEDs
);


//=======================================================
//  PORT declarations
//=======================================================


input          OSC;
input          CPU_RESET;
input          EXT_RESET;
//ADC
input  [13:0]  ADA_DATA;
input  [13:0]  ADB_DATA;
input          ADA_OR;
input          ADB_OR;
inout          AD_SCLK;
inout          AD_SDIO;
output         ADA_OE;
output         ADA_SPI_CS;
output         ADB_OE;
output         ADB_SPI_CS;
inout          FPGA_CLK_A_N;
inout          FPGA_CLK_A_P;
inout          FPGA_CLK_B_N;
inout          FPGA_CLK_B_P;
input          ADA_DCO;
input          ADB_DCO;
//output
output [40:0]  OUT;
//debug
input  [3:0]   SW;
output [7:0]   LED;
output [9:0]   LED_R;
output [9:0]   LED_G;
output [19:0]  VCC;

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire     clk_main;
wire     reset;
wire     ENABLE;
wire     clk_10M;
wire     clk_1M;

reg [13:0] data_A;
reg [13:0] data_B;

reg [13:0] SIGNAL_A [199:0];
reg [13:0] SIGNAL_B [199:0];
integer i;

wire    w_sigma; // internal state
reg     w_sigma_bw; // internal state
wire    tb;

wire [31:0] test;
reg sign, sigma;

integer z1, z2, jump;

//=======================================================
//  Structural coding
//=======================================================
//--- globa signal assign
assign   reset          =  CPU_RESET & EXT_RESET;
assign   FPGA_CLK_A_P   =  clk_10M;
assign   FPGA_CLK_A_N   = ~clk_10M;
assign   FPGA_CLK_B_P   =  clk_10M;
assign   FPGA_CLK_B_N   = ~clk_10M;

assign   ENABLE = ~SW[0];

// assign for ADC control signal
assign   AD_SCLK        = SW[2];    // (DFS)Data Format Select
assign   AD_SDIO        = SW[3];    // (DCS)Duty Cycle Stabilizer Select
assign   ADA_OE         = 1'b0;           // enable ADA output
assign   ADA_SPI_CS     = 1'b1;           // disable ADA_SPI_CS (CSB)
assign   ADB_OE         = 1'b0;           // enable ADB output
assign   ADB_SPI_CS     = 1'b1;           // disable ADB_SPI_CS (CSB)

assign   LED[0]   = ~ENABLE;
assign   LED[3]   = ENABLE ? ~ADA_OR : 1'b1;
assign   LED[4]   = ENABLE ? ~ADB_OR : 1'b1;

//unused
assign   LED[2:1]   = 2'b11;
assign   LED[7:5]   = 3'b111;

assign   VCC[19:0]    = 20'h0;
assign   LED_R[9:0]   = 10'h0;
assign   LED_G[9:0]   = 10'h0;

// OUTPUT

assign   OUT[20]  =  tb;
assign   OUT[24]  =  i[5];
assign   OUT[30]  =  data_A[13];
assign   OUT[3]   =  w_sigma & ENABLE;
assign   OUT[4]   = ~w_sigma & ENABLE;
assign   OUT[10]  = ADA_DCO;
assign   OUT[12]  = ADB_DCO;
assign   OUT[14]  = FPGA_CLK_A_P;


// PLL
PLL   PLL_inst (
   //.areset ( reset ),
   .inclk0 ( OSC ),
   .c0 ( clk_main ),
   .c1 ( clk_10M ),
   .c2 ( clk_1M )
   );



// control law
hybrid_control hybrid_control_inst (
   .o_sigma( w_sigma ),      //
   .o_sigma_neg(tb),      //
   .i_CLK( clk_main ),     //
   .i_RESET( reset ),      //
   .i_vC( data_A ),      //
   .i_iC( data_B ),      //
   .i_sigma( w_sigma_bw ),      //
   .i_ctheta( -32'd707 ),  // d707
   .i_stheta( +32'd707 )   // d707
   );

// sine and cosine test
trigonometry trigonometry_inst (
   .o_cos(),    // cosine of the input
   .o_sin(test),    // sine of the input
   .i_theta(32'd33)   // input angle
);
// timing for creating two sin waves
// phase shift: A = 0, B = 90
// frequency waves: 50 kHz
// frequency ADC: 10 MSPS
// number of samples: 200


initial begin
   i = 0;
   SIGNAL_A[0] = 14'b01111111111111;
   SIGNAL_B[0] = 14'b11111111111111;
   SIGNAL_A[1] = 14'b10000100000000;
   SIGNAL_B[1] = 14'b11111111111010;
   SIGNAL_A[2] = 14'b10001000000001;
   SIGNAL_B[2] = 14'b11111111101110;
   SIGNAL_A[3] = 14'b10001100000010;
   SIGNAL_B[3] = 14'b11111111011010;
   SIGNAL_A[4] = 14'b10010000000010;
   SIGNAL_B[4] = 14'b11111110111110;
   SIGNAL_A[5] = 14'b10010100000000;
   SIGNAL_B[5] = 14'b11111110011010;
   SIGNAL_A[6] = 14'b10010111111110;
   SIGNAL_B[6] = 14'b11111101101101;
   SIGNAL_A[7] = 14'b10011011111010;
   SIGNAL_B[7] = 14'b11111100111001;
   SIGNAL_A[8] = 14'b10011111110100;
   SIGNAL_B[8] = 14'b11111011111101;
   SIGNAL_A[9] = 14'b10100011101100;
   SIGNAL_B[9] = 14'b11111010111001;
   SIGNAL_A[10] = 14'b10100111100010;
   SIGNAL_B[10] = 14'b11111001101110;
   SIGNAL_A[11] = 14'b10101011010110;
   SIGNAL_B[11] = 14'b11111000011010;
   SIGNAL_A[12] = 14'b10101111000110;
   SIGNAL_B[12] = 14'b11110110111111;
   SIGNAL_A[13] = 14'b10110010110100;
   SIGNAL_B[13] = 14'b11110101011101;
   SIGNAL_A[14] = 14'b10110110011111;
   SIGNAL_B[14] = 14'b11110011110011;
   SIGNAL_A[15] = 14'b10111010000110;
   SIGNAL_B[15] = 14'b11110010000010;
   SIGNAL_A[16] = 14'b10111101101001;
   SIGNAL_B[16] = 14'b11110000001001;
   SIGNAL_A[17] = 14'b11000001001001;
   SIGNAL_B[17] = 14'b11101110001010;
   SIGNAL_A[18] = 14'b11000100100100;
   SIGNAL_B[18] = 14'b11101100000011;
   SIGNAL_A[19] = 14'b11000111111011;
   SIGNAL_B[19] = 14'b11101001110110;
   SIGNAL_A[20] = 14'b11001011001110;
   SIGNAL_B[20] = 14'b11100111100010;
   SIGNAL_A[21] = 14'b11001110011100;
   SIGNAL_B[21] = 14'b11100101001000;
   SIGNAL_A[22] = 14'b11010001100100;
   SIGNAL_B[22] = 14'b11100010100111;
   SIGNAL_A[23] = 14'b11010100101000;
   SIGNAL_B[23] = 14'b11100000000000;
   SIGNAL_A[24] = 14'b11010111100110;
   SIGNAL_B[24] = 14'b11011101010010;
   SIGNAL_A[25] = 14'b11011010011111;
   SIGNAL_B[25] = 14'b11011010011111;
   SIGNAL_A[26] = 14'b11011101010010;
   SIGNAL_B[26] = 14'b11010111100110;
   SIGNAL_A[27] = 14'b11100000000000;
   SIGNAL_B[27] = 14'b11010100101000;
   SIGNAL_A[28] = 14'b11100010100111;
   SIGNAL_B[28] = 14'b11010001100100;
   SIGNAL_A[29] = 14'b11100101001000;
   SIGNAL_B[29] = 14'b11001110011100;
   SIGNAL_A[30] = 14'b11100111100010;
   SIGNAL_B[30] = 14'b11001011001110;
   SIGNAL_A[31] = 14'b11101001110110;
   SIGNAL_B[31] = 14'b11000111111011;
   SIGNAL_A[32] = 14'b11101100000011;
   SIGNAL_B[32] = 14'b11000100100100;
   SIGNAL_A[33] = 14'b11101110001010;
   SIGNAL_B[33] = 14'b11000001001001;
   SIGNAL_A[34] = 14'b11110000001001;
   SIGNAL_B[34] = 14'b10111101101001;
   SIGNAL_A[35] = 14'b11110010000010;
   SIGNAL_B[35] = 14'b10111010000110;
   SIGNAL_A[36] = 14'b11110011110011;
   SIGNAL_B[36] = 14'b10110110011111;
   SIGNAL_A[37] = 14'b11110101011101;
   SIGNAL_B[37] = 14'b10110010110100;
   SIGNAL_A[38] = 14'b11110110111111;
   SIGNAL_B[38] = 14'b10101111000110;
   SIGNAL_A[39] = 14'b11111000011010;
   SIGNAL_B[39] = 14'b10101011010110;
   SIGNAL_A[40] = 14'b11111001101110;
   SIGNAL_B[40] = 14'b10100111100010;
   SIGNAL_A[41] = 14'b11111010111001;
   SIGNAL_B[41] = 14'b10100011101100;
   SIGNAL_A[42] = 14'b11111011111101;
   SIGNAL_B[42] = 14'b10011111110100;
   SIGNAL_A[43] = 14'b11111100111001;
   SIGNAL_B[43] = 14'b10011011111010;
   SIGNAL_A[44] = 14'b11111101101101;
   SIGNAL_B[44] = 14'b10010111111110;
   SIGNAL_A[45] = 14'b11111110011010;
   SIGNAL_B[45] = 14'b10010100000000;
   SIGNAL_A[46] = 14'b11111110111110;
   SIGNAL_B[46] = 14'b10010000000010;
   SIGNAL_A[47] = 14'b11111111011010;
   SIGNAL_B[47] = 14'b10001100000010;
   SIGNAL_A[48] = 14'b11111111101110;
   SIGNAL_B[48] = 14'b10001000000001;
   SIGNAL_A[49] = 14'b11111111111010;
   SIGNAL_B[49] = 14'b10000100000000;
   SIGNAL_A[50] = 14'b11111111111111;
   SIGNAL_B[50] = 14'b01111111111111;
   SIGNAL_A[51] = 14'b11111111111010;
   SIGNAL_B[51] = 14'b01111011111110;
   SIGNAL_A[52] = 14'b11111111101110;
   SIGNAL_B[52] = 14'b01110111111101;
   SIGNAL_A[53] = 14'b11111111011010;
   SIGNAL_B[53] = 14'b01110011111100;
   SIGNAL_A[54] = 14'b11111110111110;
   SIGNAL_B[54] = 14'b01101111111100;
   SIGNAL_A[55] = 14'b11111110011010;
   SIGNAL_B[55] = 14'b01101011111110;
   SIGNAL_A[56] = 14'b11111101101101;
   SIGNAL_B[56] = 14'b01101000000000;
   SIGNAL_A[57] = 14'b11111100111001;
   SIGNAL_B[57] = 14'b01100100000100;
   SIGNAL_A[58] = 14'b11111011111101;
   SIGNAL_B[58] = 14'b01100000001010;
   SIGNAL_A[59] = 14'b11111010111001;
   SIGNAL_B[59] = 14'b01011100010010;
   SIGNAL_A[60] = 14'b11111001101110;
   SIGNAL_B[60] = 14'b01011000011100;
   SIGNAL_A[61] = 14'b11111000011010;
   SIGNAL_B[61] = 14'b01010100101000;
   SIGNAL_A[62] = 14'b11110110111111;
   SIGNAL_B[62] = 14'b01010000111000;
   SIGNAL_A[63] = 14'b11110101011101;
   SIGNAL_B[63] = 14'b01001101001010;
   SIGNAL_A[64] = 14'b11110011110011;
   SIGNAL_B[64] = 14'b01001001011111;
   SIGNAL_A[65] = 14'b11110010000010;
   SIGNAL_B[65] = 14'b01000101111000;
   SIGNAL_A[66] = 14'b11110000001001;
   SIGNAL_B[66] = 14'b01000010010101;
   SIGNAL_A[67] = 14'b11101110001010;
   SIGNAL_B[67] = 14'b00111110110101;
   SIGNAL_A[68] = 14'b11101100000011;
   SIGNAL_B[68] = 14'b00111011011010;
   SIGNAL_A[69] = 14'b11101001110110;
   SIGNAL_B[69] = 14'b00111000000011;
   SIGNAL_A[70] = 14'b11100111100010;
   SIGNAL_B[70] = 14'b00110100110000;
   SIGNAL_A[71] = 14'b11100101001000;
   SIGNAL_B[71] = 14'b00110001100010;
   SIGNAL_A[72] = 14'b11100010100111;
   SIGNAL_B[72] = 14'b00101110011010;
   SIGNAL_A[73] = 14'b11100000000000;
   SIGNAL_B[73] = 14'b00101011010110;
   SIGNAL_A[74] = 14'b11011101010010;
   SIGNAL_B[74] = 14'b00101000011000;
   SIGNAL_A[75] = 14'b11011010011111;
   SIGNAL_B[75] = 14'b00100101011111;
   SIGNAL_A[76] = 14'b11010111100110;
   SIGNAL_B[76] = 14'b00100010101100;
   SIGNAL_A[77] = 14'b11010100101000;
   SIGNAL_B[77] = 14'b00011111111110;
   SIGNAL_A[78] = 14'b11010001100100;
   SIGNAL_B[78] = 14'b00011101010111;
   SIGNAL_A[79] = 14'b11001110011100;
   SIGNAL_B[79] = 14'b00011010110110;
   SIGNAL_A[80] = 14'b11001011001110;
   SIGNAL_B[80] = 14'b00011000011100;
   SIGNAL_A[81] = 14'b11000111111011;
   SIGNAL_B[81] = 14'b00010110001000;
   SIGNAL_A[82] = 14'b11000100100100;
   SIGNAL_B[82] = 14'b00010011111011;
   SIGNAL_A[83] = 14'b11000001001001;
   SIGNAL_B[83] = 14'b00010001110100;
   SIGNAL_A[84] = 14'b10111101101001;
   SIGNAL_B[84] = 14'b00001111110101;
   SIGNAL_A[85] = 14'b10111010000110;
   SIGNAL_B[85] = 14'b00001101111100;
   SIGNAL_A[86] = 14'b10110110011111;
   SIGNAL_B[86] = 14'b00001100001011;
   SIGNAL_A[87] = 14'b10110010110100;
   SIGNAL_B[87] = 14'b00001010100001;
   SIGNAL_A[88] = 14'b10101111000110;
   SIGNAL_B[88] = 14'b00001000111111;
   SIGNAL_A[89] = 14'b10101011010110;
   SIGNAL_B[89] = 14'b00000111100100;
   SIGNAL_A[90] = 14'b10100111100010;
   SIGNAL_B[90] = 14'b00000110010000;
   SIGNAL_A[91] = 14'b10100011101100;
   SIGNAL_B[91] = 14'b00000101000101;
   SIGNAL_A[92] = 14'b10011111110100;
   SIGNAL_B[92] = 14'b00000100000001;
   SIGNAL_A[93] = 14'b10011011111010;
   SIGNAL_B[93] = 14'b00000011000101;
   SIGNAL_A[94] = 14'b10010111111110;
   SIGNAL_B[94] = 14'b00000010010001;
   SIGNAL_A[95] = 14'b10010100000000;
   SIGNAL_B[95] = 14'b00000001100100;
   SIGNAL_A[96] = 14'b10010000000010;
   SIGNAL_B[96] = 14'b00000001000000;
   SIGNAL_A[97] = 14'b10001100000010;
   SIGNAL_B[97] = 14'b00000000100100;
   SIGNAL_A[98] = 14'b10001000000001;
   SIGNAL_B[98] = 14'b00000000010000;
   SIGNAL_A[99] = 14'b10000100000000;
   SIGNAL_B[99] = 14'b00000000000100;
   SIGNAL_A[100] = 14'b01111111111111;
   SIGNAL_B[100] = 14'b00000000000000;
   SIGNAL_A[101] = 14'b01111011111110;
   SIGNAL_B[101] = 14'b00000000000100;
   SIGNAL_A[102] = 14'b01110111111101;
   SIGNAL_B[102] = 14'b00000000010000;
   SIGNAL_A[103] = 14'b01110011111100;
   SIGNAL_B[103] = 14'b00000000100100;
   SIGNAL_A[104] = 14'b01101111111100;
   SIGNAL_B[104] = 14'b00000001000000;
   SIGNAL_A[105] = 14'b01101011111110;
   SIGNAL_B[105] = 14'b00000001100100;
   SIGNAL_A[106] = 14'b01101000000000;
   SIGNAL_B[106] = 14'b00000010010001;
   SIGNAL_A[107] = 14'b01100100000100;
   SIGNAL_B[107] = 14'b00000011000101;
   SIGNAL_A[108] = 14'b01100000001010;
   SIGNAL_B[108] = 14'b00000100000001;
   SIGNAL_A[109] = 14'b01011100010010;
   SIGNAL_B[109] = 14'b00000101000101;
   SIGNAL_A[110] = 14'b01011000011100;
   SIGNAL_B[110] = 14'b00000110010000;
   SIGNAL_A[111] = 14'b01010100101000;
   SIGNAL_B[111] = 14'b00000111100100;
   SIGNAL_A[112] = 14'b01010000111000;
   SIGNAL_B[112] = 14'b00001000111111;
   SIGNAL_A[113] = 14'b01001101001010;
   SIGNAL_B[113] = 14'b00001010100001;
   SIGNAL_A[114] = 14'b01001001011111;
   SIGNAL_B[114] = 14'b00001100001011;
   SIGNAL_A[115] = 14'b01000101111000;
   SIGNAL_B[115] = 14'b00001101111100;
   SIGNAL_A[116] = 14'b01000010010101;
   SIGNAL_B[116] = 14'b00001111110101;
   SIGNAL_A[117] = 14'b00111110110101;
   SIGNAL_B[117] = 14'b00010001110100;
   SIGNAL_A[118] = 14'b00111011011010;
   SIGNAL_B[118] = 14'b00010011111011;
   SIGNAL_A[119] = 14'b00111000000011;
   SIGNAL_B[119] = 14'b00010110001000;
   SIGNAL_A[120] = 14'b00110100110000;
   SIGNAL_B[120] = 14'b00011000011100;
   SIGNAL_A[121] = 14'b00110001100010;
   SIGNAL_B[121] = 14'b00011010110110;
   SIGNAL_A[122] = 14'b00101110011010;
   SIGNAL_B[122] = 14'b00011101010111;
   SIGNAL_A[123] = 14'b00101011010110;
   SIGNAL_B[123] = 14'b00011111111110;
   SIGNAL_A[124] = 14'b00101000011000;
   SIGNAL_B[124] = 14'b00100010101100;
   SIGNAL_A[125] = 14'b00100101011111;
   SIGNAL_B[125] = 14'b00100101011111;
   SIGNAL_A[126] = 14'b00100010101100;
   SIGNAL_B[126] = 14'b00101000011000;
   SIGNAL_A[127] = 14'b00011111111110;
   SIGNAL_B[127] = 14'b00101011010110;
   SIGNAL_A[128] = 14'b00011101010111;
   SIGNAL_B[128] = 14'b00101110011010;
   SIGNAL_A[129] = 14'b00011010110110;
   SIGNAL_B[129] = 14'b00110001100010;
   SIGNAL_A[130] = 14'b00011000011100;
   SIGNAL_B[130] = 14'b00110100110000;
   SIGNAL_A[131] = 14'b00010110001000;
   SIGNAL_B[131] = 14'b00111000000011;
   SIGNAL_A[132] = 14'b00010011111011;
   SIGNAL_B[132] = 14'b00111011011010;
   SIGNAL_A[133] = 14'b00010001110100;
   SIGNAL_B[133] = 14'b00111110110101;
   SIGNAL_A[134] = 14'b00001111110101;
   SIGNAL_B[134] = 14'b01000010010101;
   SIGNAL_A[135] = 14'b00001101111100;
   SIGNAL_B[135] = 14'b01000101111000;
   SIGNAL_A[136] = 14'b00001100001011;
   SIGNAL_B[136] = 14'b01001001011111;
   SIGNAL_A[137] = 14'b00001010100001;
   SIGNAL_B[137] = 14'b01001101001010;
   SIGNAL_A[138] = 14'b00001000111111;
   SIGNAL_B[138] = 14'b01010000111000;
   SIGNAL_A[139] = 14'b00000111100100;
   SIGNAL_B[139] = 14'b01010100101000;
   SIGNAL_A[140] = 14'b00000110010000;
   SIGNAL_B[140] = 14'b01011000011100;
   SIGNAL_A[141] = 14'b00000101000101;
   SIGNAL_B[141] = 14'b01011100010010;
   SIGNAL_A[142] = 14'b00000100000001;
   SIGNAL_B[142] = 14'b01100000001010;
   SIGNAL_A[143] = 14'b00000011000101;
   SIGNAL_B[143] = 14'b01100100000100;
   SIGNAL_A[144] = 14'b00000010010001;
   SIGNAL_B[144] = 14'b01101000000000;
   SIGNAL_A[145] = 14'b00000001100100;
   SIGNAL_B[145] = 14'b01101011111110;
   SIGNAL_A[146] = 14'b00000001000000;
   SIGNAL_B[146] = 14'b01101111111100;
   SIGNAL_A[147] = 14'b00000000100100;
   SIGNAL_B[147] = 14'b01110011111100;
   SIGNAL_A[148] = 14'b00000000010000;
   SIGNAL_B[148] = 14'b01110111111101;
   SIGNAL_A[149] = 14'b00000000000100;
   SIGNAL_B[149] = 14'b01111011111110;
   SIGNAL_A[150] = 14'b00000000000000;
   SIGNAL_B[150] = 14'b01111111111111;
   SIGNAL_A[151] = 14'b00000000000100;
   SIGNAL_B[151] = 14'b10000100000000;
   SIGNAL_A[152] = 14'b00000000010000;
   SIGNAL_B[152] = 14'b10001000000001;
   SIGNAL_A[153] = 14'b00000000100100;
   SIGNAL_B[153] = 14'b10001100000010;
   SIGNAL_A[154] = 14'b00000001000000;
   SIGNAL_B[154] = 14'b10010000000010;
   SIGNAL_A[155] = 14'b00000001100100;
   SIGNAL_B[155] = 14'b10010100000000;
   SIGNAL_A[156] = 14'b00000010010001;
   SIGNAL_B[156] = 14'b10010111111110;
   SIGNAL_A[157] = 14'b00000011000101;
   SIGNAL_B[157] = 14'b10011011111010;
   SIGNAL_A[158] = 14'b00000100000001;
   SIGNAL_B[158] = 14'b10011111110100;
   SIGNAL_A[159] = 14'b00000101000101;
   SIGNAL_B[159] = 14'b10100011101100;
   SIGNAL_A[160] = 14'b00000110010000;
   SIGNAL_B[160] = 14'b10100111100010;
   SIGNAL_A[161] = 14'b00000111100100;
   SIGNAL_B[161] = 14'b10101011010110;
   SIGNAL_A[162] = 14'b00001000111111;
   SIGNAL_B[162] = 14'b10101111000110;
   SIGNAL_A[163] = 14'b00001010100001;
   SIGNAL_B[163] = 14'b10110010110100;
   SIGNAL_A[164] = 14'b00001100001011;
   SIGNAL_B[164] = 14'b10110110011111;
   SIGNAL_A[165] = 14'b00001101111100;
   SIGNAL_B[165] = 14'b10111010000110;
   SIGNAL_A[166] = 14'b00001111110101;
   SIGNAL_B[166] = 14'b10111101101001;
   SIGNAL_A[167] = 14'b00010001110100;
   SIGNAL_B[167] = 14'b11000001001001;
   SIGNAL_A[168] = 14'b00010011111011;
   SIGNAL_B[168] = 14'b11000100100100;
   SIGNAL_A[169] = 14'b00010110001000;
   SIGNAL_B[169] = 14'b11000111111011;
   SIGNAL_A[170] = 14'b00011000011100;
   SIGNAL_B[170] = 14'b11001011001110;
   SIGNAL_A[171] = 14'b00011010110110;
   SIGNAL_B[171] = 14'b11001110011100;
   SIGNAL_A[172] = 14'b00011101010111;
   SIGNAL_B[172] = 14'b11010001100100;
   SIGNAL_A[173] = 14'b00011111111110;
   SIGNAL_B[173] = 14'b11010100101000;
   SIGNAL_A[174] = 14'b00100010101100;
   SIGNAL_B[174] = 14'b11010111100110;
   SIGNAL_A[175] = 14'b00100101011111;
   SIGNAL_B[175] = 14'b11011010011111;
   SIGNAL_A[176] = 14'b00101000011000;
   SIGNAL_B[176] = 14'b11011101010010;
   SIGNAL_A[177] = 14'b00101011010110;
   SIGNAL_B[177] = 14'b11100000000000;
   SIGNAL_A[178] = 14'b00101110011010;
   SIGNAL_B[178] = 14'b11100010100111;
   SIGNAL_A[179] = 14'b00110001100010;
   SIGNAL_B[179] = 14'b11100101001000;
   SIGNAL_A[180] = 14'b00110100110000;
   SIGNAL_B[180] = 14'b11100111100010;
   SIGNAL_A[181] = 14'b00111000000011;
   SIGNAL_B[181] = 14'b11101001110110;
   SIGNAL_A[182] = 14'b00111011011010;
   SIGNAL_B[182] = 14'b11101100000011;
   SIGNAL_A[183] = 14'b00111110110101;
   SIGNAL_B[183] = 14'b11101110001010;
   SIGNAL_A[184] = 14'b01000010010101;
   SIGNAL_B[184] = 14'b11110000001001;
   SIGNAL_A[185] = 14'b01000101111000;
   SIGNAL_B[185] = 14'b11110010000010;
   SIGNAL_A[186] = 14'b01001001011111;
   SIGNAL_B[186] = 14'b11110011110011;
   SIGNAL_A[187] = 14'b01001101001010;
   SIGNAL_B[187] = 14'b11110101011101;
   SIGNAL_A[188] = 14'b01010000111000;
   SIGNAL_B[188] = 14'b11110110111111;
   SIGNAL_A[189] = 14'b01010100101000;
   SIGNAL_B[189] = 14'b11111000011010;
   SIGNAL_A[190] = 14'b01011000011100;
   SIGNAL_B[190] = 14'b11111001101110;
   SIGNAL_A[191] = 14'b01011100010010;
   SIGNAL_B[191] = 14'b11111010111001;
   SIGNAL_A[192] = 14'b01100000001010;
   SIGNAL_B[192] = 14'b11111011111101;
   SIGNAL_A[193] = 14'b01100100000100;
   SIGNAL_B[193] = 14'b11111100111001;
   SIGNAL_A[194] = 14'b01101000000000;
   SIGNAL_B[194] = 14'b11111101101101;
   SIGNAL_A[195] = 14'b01101011111110;
   SIGNAL_B[195] = 14'b11111110011010;
   SIGNAL_A[196] = 14'b01101111111100;
   SIGNAL_B[196] = 14'b11111110111110;
   SIGNAL_A[197] = 14'b01110011111100;
   SIGNAL_B[197] = 14'b11111111011010;
   SIGNAL_A[198] = 14'b01110111111101;
   SIGNAL_B[198] = 14'b11111111101110;
   SIGNAL_A[199] = 14'b01111011111110;
   SIGNAL_B[199] = 14'b11111111111010;
end




always @(posedge clk_10M )
begin
   data_A = SIGNAL_A[i];
   data_B = SIGNAL_B[i];
   i = i+1;
   if( i >= 200 )
      i = 0;
end


always @(posedge clk_main) begin
   if(data_A>14'b10000000000000)
      sign = 1;
   else
      sign = 0;
end

always @(posedge OSC) begin
   w_sigma_bw <= w_sigma;
end

// always @(posedge clk_main or negedge reset)
// begin : proc_overflow
//    if(~reset) begin
//       sigma <= 0;
//    end else begin
//       z1   = data_A-8191;
//       z2   = data_B-8191;
//       jump  = z1*707-z2*707;
//       if (jump<0) begin
//          sigma <= 1'b1;
//       end else begin
//          sigma <= 1'b0;
//       end
//       //z1_test <= real'(SIGNAL_A-8191)*0.75;
//       //z1_test <= (SIGNAL_A-8191)*0.75;
//    end
// end


endmodule




