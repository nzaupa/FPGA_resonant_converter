//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/01/26) (12:54:45)
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




`timescale 1 ns / 1 ps

module TOP_SensingTest (
   //clock + reset
   OSC,
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
   //output
   OUT,
   Q,
   SW,      // switches on the main board
   LED     // LEDs on the main board
);


//=======================================================
//  PORT declarations
//=======================================================


input          OSC;
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
//OUTPUT
output [38:0]  OUT;
output [3:0]   Q;
output [13:0]  DA;
output [13:0]  DB;
//debug
input  [3:0]   SW;
output [7:0]   LED;

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire  clk_main;
wire  clk_50k;
wire  clk_10M;
wire  clk_100M;

wire  Q1;
wire  Q2;

wire  reset;
wire  ENABLE;
wire [13:0] jump;
wire w_sigma;

reg signed [13:0] ADC_A;
reg signed [13:0] ADC_B;

reg [13:0] DAA_copy;
reg [13:0] DAB_copy;




//=======================================================
//  Structural coding
//=======================================================
//--- globa signal assign
assign   reset      =  CPU_RESET;
assign   ENABLE     = ~SW[0];
assign   LED[0]     = ~ENABLE;
assign   LED[1]   =  ENABLE ? ~ADA_OR : 1'b1;
assign   LED[2]   =  ENABLE ? ~ADB_OR : 1'b1;
assign   LED[7:3]   = 7'b1111111;

//ADC
assign   FPGA_CLK_A_P   =  clk_100M;
assign   FPGA_CLK_A_N   = ~clk_100M;
assign   FPGA_CLK_B_P   =  clk_100M;
assign   FPGA_CLK_B_N   = ~clk_100M;
assign   AD_SCLK        = 1'b1;//SW[2]; // (DFS)Data Format Select
                                          // 0 -> binary
                                          // 1 -> twos complement
assign   AD_SDIO        = SW[3];    // (DCS)Duty Cycle Stabilizer Select
assign   ADA_OE         = 1'b0;           // enable ADA output
assign   ADA_SPI_CS     = 1'b1;           // disable ADA_SPI_CS (CSB)
assign   ADB_OE         = 1'b0;           // enable ADB output
assign   ADB_SPI_CS     = 1'b1;           // disable ADB_SPI_CS (CSB)

// assign for DAC output
assign   DA = DAA_copy;
assign   DB = DAB_copy;


// OUTPUT
assign   Q[0]  = Q1 & ENABLE;
assign   Q[1]  = Q2 & ENABLE;
assign   Q[2]  = Q2 & ENABLE;
assign   Q[3]  = Q1 & ENABLE;

assign   OUT[4] = jump[13];
assign   OUT[8] = w_sigma;

// PLL
PLL   PLL_inst (
   //.areset ( reset ),
   .inclk0 ( OSC ),
   .c0 ( clk_main ),
   .c1 ( clk_100M ),
   .c2 ( clk_10M ),
   .c3 ( clk_50k )
);


// control law
hybrid_control_half hybrid_control_inst (
   .o_sigma( w_sigma ),  //
   .o_debug(jump),       //
   .i_clock(clk_100M),   //
   .i_RESET( reset ),    //
   .i_vC( ADC_A ),       //
   .i_iC( ADC_B ),       //
   .i_theta( 32'sd314 )  // 3/4 pi
   );

dead_time dead_time_1_inst(
   .o_signal( Q1 ),          // output switching variable
   .i_clock(  clk_100M ),     // for sequential behavior
   .i_signal( clk_50k ),
   .deadtime( 10'd5 )
);

dead_time dead_time_2_inst(
   .o_signal( Q2 ),          // output switching variable
   .i_clock(  clk_100M ),     // for sequential behavior
   .i_signal( ~clk_50k ),
   .deadtime( 10'd5 )
);

always @(posedge ADA_DCO) begin // @(posedge ADA_DATA) vecchio problematico
   ADC_A = -ADA_DATA;
   if(SW[2]==0)
      DAA_copy = -ADA_DATA + 14'd8191;
   else
      DAA_copy = jump;
end

always @(posedge ADB_DCO) begin // @(posedge ADA_DATA) vecchio problematico
   ADC_B = -ADB_DATA;
   if(SW[3]==0)
      DAB_copy = -ADB_DATA + 14'd8191;
   else
      DAB_copy = jump;
end

endmodule




