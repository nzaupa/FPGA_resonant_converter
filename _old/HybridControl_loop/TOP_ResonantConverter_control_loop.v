//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/02/09) (14:54:45)
// File: TOP_ResonantConverter_control.v
//------------------------------------------------------------
// Description:
// some testing: ...
// hybrid block enhanced
// signed version of ADC
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
//        SW[2] --> ...
//        SW[3] --> ...
//    BUTTON:
//        BUTTON[0] --> reset theta to pi
//        BUTTON[1] --> ...
//        BUTTON[2] --> decrease theta
//        BUTTON[3] --> increase theta



`timescale 1 ns / 1 ps

module TOP_ResonantConverter_control_loop (
   //clock + reset
   OSC,
   CLK_2,
   CPU_RESET,
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
   // DAC
   DA,
   DB,
   //output bridge signal
   OUT,
   //debugging
   BUTTON,  // button on the main board
   SW,      // switches on the main board
   LED,     // LEDs on the main board
   SEG0,    // 7-segments display LSB
   SEG1     // 7-segments display MSB
);


//=======================================================
//  PORT declarations
//=======================================================

input          OSC;
input          CLK_2;
input          CPU_RESET;
//ADC
input  signed [13:0]  ADA_DATA;
input  signed [13:0]  ADB_DATA;
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
output [35:0]  OUT;
output [13:0]  DA;
output [13:0]  DB;
//debug
input  [3:0]   SW;
input  [3:0]   BUTTON;
output [7:0]   LED;
output [7:0]   SEG0;
output [7:0]   SEG1;

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire     clk_main;
wire     clk_1M;
wire     clk_10M;
wire     clk_100M;

wire     reset;
wire     ENABLE;
wire [1:0] MODE;

//reg [13:0] data_A;
//reg [13:0] data_B;
reg signed [13:0] ADC_A;
reg signed [13:0] ADC_B;
reg signed [31:0] error;
reg signed [31:0] i_reference = 32'd13333;
reg signed [31:0] i_corrected;

wire [15:0] debug;
wire [31:0] i_estimated;
wire [31:0] correction;
wire debug_bit;

wire signed [31:0] theta;

reg [13:0] DAA_copy;
reg [13:0] DAB_copy;

wire  w_sigma; // internal state
wire Q1;
wire Q2;

wire [7:0] digit_0, digit_1;
wire [3:0] button;   // debounce buttons signals
wire sw0_debounced;


//=======================================================
//  Structural coding
//=======================================================
//--- globa signal assign
assign   reset          =  CPU_RESET;
assign   FPGA_CLK_A_P   =  clk_100M;
assign   FPGA_CLK_A_N   = ~clk_100M;
assign   FPGA_CLK_B_P   =  clk_100M;
assign   FPGA_CLK_B_N   = ~clk_100M;

assign   ENABLE = sw0_debounced;
assign   MODE   = SW[2:1];

// assign for ADC control signal
assign   AD_SCLK        = 1'b1;//SW[2]; // (DFS) Data Format Select
                                          // 0 -> binary
                                          // 1 -> twos complement
assign   AD_SDIO        = 1'b0;           // (DCS) Duty Cycle Stabilizer
assign   ADA_OE         = 1'b0;           // enable ADA output
assign   ADA_SPI_CS     = 1'b1;           // disable ADA_SPI_CS (CSB)
assign   ADB_OE         = 1'b0;           // enable ADB output
assign   ADB_SPI_CS     = 1'b1;           // disable ADB_SPI_CS (CSB)

// assign for DAC output
assign   DA = DAA_copy;
assign   DB = DAB_copy;

// assign for the PI controller
assign   error       = i_reference + (~i_estimated+1);
assign   i_corrected = i_reference + correction;

// LED for DEBUG

assign   LED[0]   = ~ENABLE;
assign   LED[3]   =  ENABLE ? ~ADA_OR : 1'b1;
assign   LED[4]   =  ENABLE ? ~ADB_OR : 1'b1;
assign   LED[7:6] = ~MODE;
assign   LED[ 5 ] = debug[14];

assign   SEG0 = digit_0;
assign   SEG1 = digit_1;

//unused
assign   LED[2:1]   = 2'b11;

// OUTPUT
assign   OUT[0]  = Q1 & ENABLE;
assign   OUT[2]  = Q2 & ENABLE;
assign   OUT[4]  = Q2 & ENABLE;
assign   OUT[6]  = Q1 & ENABLE;

assign   OUT[1]  = debug[15];   // jump enable
assign   OUT[3]  = debug[14];   // overflow
assign   OUT[5]  = Q2 & ENABLE;
assign   OUT[7]  = Q1 & ENABLE;

assign   OUT[10]  = ENABLE;    // 0 - cnt-bit2
assign   OUT[12]  = debug[4];    // 1 - cnt-bit4
assign   OUT[14]  = debug[6];    // 2 - cnt-bit6
assign   OUT[16]  = debug[15];   // 3 - JUMP ENABLE
assign   OUT[18]  = debug[14];   // 4 - SIGMA RESET
assign   OUT[20]  = debug[10];   // 5 - jump[31]
assign   OUT[22]  = Q2;          // 6 - delayed output
assign   OUT[24]  = w_sigma;     // 7 - non delayed output

// TB
assign   clk_100M = CLK_2;



peak_detector peak_detector_inst(
   .o_peak  (i_estimated),      // [32bit-signed] mean on 4 samples
   .o_peak_signed  (),      // [32bit-signed] mean on 4 samples
   .o_peak_detected (debug_bit), // debug signal for when a peak is detected
   .i_clock (clk_100M),     // for sequential behavior
   .i_RESET (reset),     // reset signal
   .i_data  ({ {19{ADC_A[13]}} , ADC_A[12:0] })     // [32bit-signed] input data to be filtered
);

// PLL
// PLL   PLL_inst (
//    .inclk0 ( OSC ),
//    .c0 ( clk_main ),
//    .c1 ( clk_100M ),
//    .c2 ( clk_10M ),
//    .c3 ( clk_1M )
// );


PI PI_inst(
   .o_correction(correction), // [32bit-signed] mean on 4 samples
   .i_clock(clk_100M),        // for sequential behavior
   .i_RESET(reset),           // reset signal
   .i_error(error)            // [32bit-signed] input data to be filtered
);

// control law
hybrid_control hybrid_control_inst (
   .o_sigma( w_sigma ),  //
   .o_debug( debug ),       //
   .i_clock( clk_100M ),   //clk_100M
   //.i_update( clk_10M ),   //clk_100M
   .i_RESET( reset ),    //
   .i_vC( ADC_A ),       //
   .i_iC( ADC_B ),       //
   .i_theta( theta ), // 3/4 pi - 32'sd236
   .i_mode( MODE )
);

dead_time dead_time_1_inst(
   .o_signal( Q1 ),          // output switching variable
   .i_clock(  clk_100M ),     // for sequential behavior
   .i_signal( ~w_sigma ),
   .deadtime( 10'd5 )
);

dead_time dead_time_2_inst(
   .o_signal( Q2 ),          // output switching variable
   .i_clock(  clk_100M ),     // for sequential behavior
   .i_signal( w_sigma ),
   .deadtime( 10'd5 )
);

// theta_control theta_control_inst(
//    .o_seg0(digit_0),
//    .o_seg1(digit_1),
//    .o_theta32(theta),
//    .i_reset(button[0]),
//    .i_increase(button[2]),
//    .i_decrease(button[1])
// );

// debounce debounce_0_inst(
//    .o_switch(button[0]),
//    .i_clk(clk_1M),
//    .i_reset(reset),
//    .i_switch(BUTTON[0])
// );

// debounce debounce_1_inst(
//    .o_switch(button[1]),
//    .i_clk(clk_1M),
//    .i_reset(reset),
//    .i_switch(BUTTON[1])
// );

// debounce debounce_2_inst(
//    .o_switch(button[2]),
//    .i_clk(clk_1M),
//    .i_reset(reset),
//    .i_switch(BUTTON[2])
// );

// debounce debounce_3_inst(
//    .o_switch(button[3]),
//    .i_clk(clk_1M),
//    .i_reset(reset),
//    .i_switch(BUTTON[3])
// );

// debounce debounce_4_inst(
//    .o_switch(sw0_debounced),
//    .i_clk(clk_1M),
//    .i_reset(reset),
//    .i_switch(SW[0])
// );


// ADC: acquire data from when available
always @(posedge ADA_DCO) begin
   ADC_A    = -ADA_DATA;
   DAA_copy = -ADA_DATA + 14'd8191;
end

always @(posedge ADB_DCO) begin
   ADC_B    = -ADB_DATA;
   DAB_copy = -ADB_DATA + 14'd8191;
end




endmodule




