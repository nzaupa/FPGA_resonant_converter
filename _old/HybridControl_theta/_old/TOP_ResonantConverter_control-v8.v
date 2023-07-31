//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/02/07) (18:34:45)
// File: TOP_ResonantConverter_control.v
//------------------------------------------------------------
// Description:
// some testing: ...
// hybrid block enhanced
// signed version of ADC
// add the control of theta trough buttons
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

module TOP_ResonantConverter_control (
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
   //output bridge signal
   Q,
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
output [3:0]   Q;
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

reg [13:0] data_A;
reg [13:0] data_B;
reg signed [13:0] ADC_A;
reg signed [13:0] ADC_B;

reg signed [31:0] theta;


reg [13:0] DAA_copy;
reg [13:0] DAB_copy;

wire    w_sigma; // internal state

wire [6:0] segment_0, segment_1;
wire       dp0, dp1;
reg  [7:0] deg, deg_sat;
wire [7:0] to_seg;

//=======================================================
//  Structural coding
//=======================================================
//--- globa signal assign
assign   reset          =  CPU_RESET;
assign   FPGA_CLK_A_P   =  clk_100M;
assign   FPGA_CLK_A_N   = ~clk_100M;
assign   FPGA_CLK_B_P   =  clk_100M;
assign   FPGA_CLK_B_N   = ~clk_100M;

assign   ENABLE = ~SW[0];

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

// LED for DEBUG

assign   LED[0]   = ~ENABLE;
assign   LED[3]   =  ENABLE ? ~ADA_OR : 1'b1;
assign   LED[4]   =  ENABLE ? ~ADB_OR : 1'b1;

//unused
assign   LED[2:1]   = 2'b11;
assign   LED[7:5]   = 3'b111;

assign   dp0  = 0;
assign   dp1  = deg_sat[0];
assign   SEG0 = { ~dp0,segment_0 };
assign   SEG1 = { ~dp1,segment_1 };



// OUTPUT
assign   Q[0]  = Q1 & ENABLE;
assign   Q[1]  = Q2 & ENABLE;
assign   Q[2]  = Q2 & ENABLE;
assign   Q[3]  = Q1 & ENABLE;



// PLL
PLL   PLL_inst (
   .inclk0 ( OSC ),
   .c0 ( clk_main ),
   .c1 ( clk_100M ),
   .c2 ( clk_10M ),
   .c3 ( clk_1M )
   );



// control law
hybrid_control_half hybrid_control_inst (
   .o_sigma( w_sigma ),  //
   .o_debug(jump),       //
   .i_clock(clk_100M),   //
   .i_RESET( reset ),    //
   .i_vC( ADC_A ),       //
   .i_iC( ADC_B ),       //
   .i_theta( theta ) // 3/4 pi - 32'sd236
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

deg2seg deg2seg_inst (
   .o_seg(to_seg),
   .i_dec(deg_sat<<1),
);


seven_segment seven_segment_0_inst(
   .o_seg(segment_0),
   .i_num(to_seg[3:0]),
);

seven_segment seven_segment_1_inst(
   .o_seg(segment_1),
   .i_num(to_seg[7:4]),
);

initial begin
   deg = 8'd180;
end


// ADC: acquire data from when available
always @(posedge ADA_DCO) begin
   ADC_A    = -ADA_DATA;
   DAA_copy = -ADA_DATA + 14'd8191;
end

always @(posedge ADB_DCO) begin
   ADC_B    = -ADB_DATA;
   DAB_copy = -ADB_DATA + 14'd8191;
end

// Control the angle from the buttons
always @( negedge BUTTON[0] or negedge BUTTON[2] or negedge BUTTON[3] ) begin
   if (~BUTTON[0]) begin
      deg <= 8'd180;
   end else begin
      if (~BUTTON[3]) begin
         deg <= deg_sat+8'd5;
      end else begin
         if (~BUTTON[2]) begin
         deg <= deg_sat-8'd5;
         end
      end
   end
end

// control the limit for the angle in degree
always @( deg ) begin
   theta = (deg*1787)>>10;
   if (deg>8'd180)
      deg_sat <= 8'd90;
   else if (deg<8'd90)
      deg_sat <= 8'd180;
   else
      deg_sat <= deg;
end


endmodule




