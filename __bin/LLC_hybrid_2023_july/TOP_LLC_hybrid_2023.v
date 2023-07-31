//------------------------------------------------------------
// Project: LLC_HYBRID_2023
// Author: Nicola Zaupa
// Date: (2023/07/03) (17:53:31)
// File: TOP_LLC_hybrid_2023.v
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
//        SW[2] --> THETA dependend on PHI (can use a variable offset)
//        SW[3] --> ...
//    BUTTON:
//        BUTTON[0] --> reset angles
//        BUTTON[1] --> increase phi      1deg
//        BUTTON[2] --> decrease theta    5deg
//        BUTTON[3] --> increase deadtime 50ms



`timescale 1 ns / 1 ps

module TOP_LLC_hybrid_2023 (
   //=======================================================
   //  PORT declarations
   //=======================================================

   //clock + reset
   input          CPU_RESET,
   input          OSC,
   //ADC DDC
   input  signed [13:0]  ADB_DATA,
   input  signed [13:0]  ADA_DATA,
   input          ADA_OR,
   input          ADB_OR,
   inout          AD_SCLK,
   inout          AD_SDIO,
   output         ADA_OE,
   output         ADA_SPI_CS,
   output         ADB_OE,
   output         ADB_SPI_CS,
   inout          FPGA_CLK_A_N,
   inout          FPGA_CLK_A_P,
   inout          FPGA_CLK_B_N,
   inout          FPGA_CLK_B_P,
   input          ADA_DCO,
   input          ADB_DCO,
   // ADCs 8bit
   input  [7:0] ADC_BAT_V,
   input        ADC_BAT_V_CONVST,
   input        ADC_BAT_V_EOC,
   input  [7:0] ADC_BAT_I,
   input        ADC_BAT_I_CONVST,
   input        ADC_BAT_I_EOC,
   //output
   output [3:0]   Q,
   output [13:0]  DA,
   output [13:0]  DB,
   output         FAN_CONTROL,
   output [11:0]  EX,
   //debug
   input  [3:0]   SW,
   input  [3:0]   BUTTON,
   output [7:0]   LED,
   output [7:0]   SEG0,
   output [7:0]   SEG1
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire     clk_main;
wire     clk_1M;
wire     clk_1k;
wire     clk_100M;

wire     reset;
wire     ENABLE;
wire     ALERT;
wire [1:0] MODE;
wire [3:0] MOSFET;

reg [13:0] data_A;
reg [13:0] data_B;
reg signed [13:0] ADC_A;
reg signed [13:0] ADC_B;

reg  [7:0] deadtime = 8'd5;

wire [29:0] debug;

wire [31:0] phi;
wire [31:0] theta;
wire [31:0] phi_HC;
wire [31:0] theta_HC;

reg  [13:0] DAA_copy;
reg  [13:0] DAB_copy;

wire [31:0] sigma_FAKE;

wire [1:0] sigma; // internal state

wire Q1, Q2, Q3, Q4;

wire [7:0] digit_0, digit_1;
wire [3:0] button, sw;   // debounce buttons and switch


//=======================================================
//  Structural coding
//=======================================================
//--- globa signal assign
assign  reset         =  CPU_RESET;
assign  FPGA_CLK_A_P  =  clk_100M;
assign  FPGA_CLK_A_N  = ~clk_100M;
assign  FPGA_CLK_B_P  =  clk_100M;
assign  FPGA_CLK_B_N  = ~clk_100M; 
assign  ENABLE = sw[0];
assign  FAN_CONTROL = clk_1k;

// assign for ADC control signal
assign   AD_SCLK    = 1'b1;//SW[2]; // (DFS) Data Format Select
                                          // 0 -> binary
                                          // 1 -> twos complement
assign   AD_SDIO    = 1'b0;           // (DCS) Duty Cycle Stabilizer
assign   ADA_OE     = 1'b0;           // enable ADA output
assign   ADA_SPI_CS = 1'b1;           // disable ADA_SPI_CS (CSB)
assign   ADB_OE     = 1'b0;           // enable ADB output
assign   ADB_SPI_CS = 1'b1;           // disable ADB_SPI_CS (CSB)

// assign for DAC output
// assign  DA = DAA_copy;
assign  DB = DAB_copy;

assign  DA = debug[29:16] + 14'd8191;


// LED for DEBUG

assign  LED[0]   = ~ENABLE;
assign  LED[3]   =  ENABLE ? ~ADA_OR : 1'b1;
assign  LED[4]   =  ENABLE ? ~ADB_OR : 1'b1;
assign  LED[7:6] = ~MODE;
assign  LED[ 5 ] = ALERT;

assign  SEG0 = digit_0;
assign  SEG1 = digit_1;

//unused
assign   LED[2:1]   = debug[1:0];

// OUTPUT      
assign   ALERT   = ~((Q1 & Q3) | (Q2 & Q4));

// assign   OUT[0]  = Q2 & ENABLE & ALERT;
// assign   OUT[2]  = Q4 & ENABLE & ALERT;
// assign   OUT[4]  = Q1 & ENABLE & ALERT;
// assign   OUT[6]  = Q3 & ENABLE & ALERT;

// assign   OUT[1]  = debug[15];   // jump enable
// assign   OUT[3]  = debug[14];   // overflow
// assign   OUT[5]  = Q2 & ENABLE;
// assign   OUT[7]  = Q1 & ENABLE;

// assign   OUT[10]  = debug[13];  // C1_db
// assign   OUT[12]  = debug[14];   // C1
// assign   OUT[14]  = debug[15];   // b0
// assign   OUT[16]  = debug[9];   // b1
// assign   OUT[18]  = debug[10];
// assign   OUT[20]  = debug[11];   // clk_OR  
// assign   OUT[22]  = debug[7];   // clk_JUMP 

// assign   OUT[24]  = debug[10]; // clk_prev   
// assign   OUT[26]  = debug[15]; // C1 
// assign   OUT[28]  = debug[14]; // C2 

// assign   OUT[27]  = debug[3]; // iC
// assign   OUT[29]  = debug[4]; // vC
// assign   OUT[31]  = debug[5]; // vC_filt

// assign   OUT[30]  = debug[6];  // b0

assign   phi_HC   = phi;
assign   theta_HC = sw[3] ? (32'd170+(~phi+1)) : theta;


// assign theta = 32'd314 + (~phi+1);

// PLL
PLL   PLL_inst (
   .inclk0 ( OSC ),
   .c0 ( clk_main ), // 300MHz
   .c1 ( clk_100M ), // 100MHz
   .c2 ( clk_1k ),  // 1kHz
   .c3 ( clk_1M )
);

// control law
// hybrid_control_phi hybrid_control_inst (
//    .o_MOSFET( MOSFET ),  // control signal for the four MOSFETs
//    .o_sigma( sigma ),         // 2 bit for signed sigma -> {-1,0,1}
//    .o_debug( ),    // ? random currently
//    .i_clock( clk_100M ), // ADA_DCO
//    .i_RESET( reset ),    //
//    .i_vC( ADC_A ),       //
//    .i_iC( ADC_B ),       //
//    .i_phi( phi )     // phi // pi/4 - 32'h0000004E
// );


hybrid_control_theta_phi hybrid_control_tf_inst (
   .o_MOSFET( MOSFET ),  // control signal for the four MOSFETs
   .o_sigma(  ),         // 2 bit for signed sigma -> {-1,0,1}
   .o_debug( debug ),    // ---
   .i_clock( clk_100M ), // 
   .i_RESET( reset ),    // 
   .i_vC( ADC_A ),       // 
   .i_iC( ADC_B ),       // 
   .i_theta( theta_HC ),    // 32'd314
   .i_phi( phi_HC ),        // phi // pi/4 - 32'h0000004E
   .i_sigma( ) //{ {31{sigma[1]}} , sigma[0] } )
);

//angle control

phi_control phi_control_inst(
   .o_seg0(digit_0),
   .o_seg1(), //digit_1),
   .o_phi32(phi),
   .i_reset(button[0]),
   .i_increase(1'b1),
   .i_decrease(button[1])
);

theta_control theta_control_inst(
   .o_seg0(digit_1), //digit_0),
   .o_seg1(), //digit_1),
   .o_theta32(theta),
   .i_reset(button[0]),
   .i_increase(1'b1),
   .i_decrease(button[2])
);

// ----- DEAD TIME ----- //

dead_time_4bit dead_time_inst(
   .o_signal( {Q4, Q3, Q2, Q1} ),          // output switching variable
   .i_clock(  clk_100M ),            // for sequential behavior
   .i_signal( MOSFET ),
   .deadtime( deadtime )
);


// ----- DEBOUNCE ----- //

debounce_4bit debounce_4bit_inst(
   .o_switch(button[3:0]),
   .i_clk(clk_1M),
   .i_reset(reset),
   .i_switch(BUTTON[3:0]),
   .debounce_limit(31'd5000)  // 5ms
);

debounce_4bit debounce_SWITCH_inst(
   .o_switch(sw),
   .i_clk(clk_1M),
   .i_reset(reset),
   .i_switch(SW),
   .debounce_limit(31'd5000)  // 5ms
);


// ADC: acquire data from when available
always @(posedge ADA_DCO) begin
   ADC_A    = ~ADA_DATA+14'b1;
   DAA_copy = ~ADA_DATA+14'b1 + 14'd8191;
end

always @(posedge ADB_DCO) begin
   ADC_B    = ~ADB_DATA+14'b1;
   DAB_copy = ~ADB_DATA+14'b1 + 14'd8191;
end

always @(negedge reset or negedge button[3] ) begin
   if (~reset)
      deadtime <= 8'd5;
   else
      deadtime <= deadtime + 8'd5;
end

endmodule


