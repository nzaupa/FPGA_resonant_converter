//------------------------------------------------------------
// Project: HYBRID_CONTROL_PHI
// Author: Nicola Zaupa
// Date: (2022/02/03) (11:19:05)
// File: TOP_ResonantConverter_phi.v
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
//        BUTTON[0] --> reset phi to pi
//        BUTTON[1] --> ...
//        BUTTON[2] --> decrease phi
//        BUTTON[3] --> increase phi



`timescale 1 ns / 1 ps

module TOP_ResonantConverter_phi (
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
wire     ALERT;
wire [3:0] MOSFET;

reg [13:0] data_A;
reg [13:0] data_B;
reg signed [13:0] ADC_A;
reg signed [13:0] ADC_B;

wire [29:0] debug;

wire [31:0] phi;

reg [13:0] DAA_copy;
reg [13:0] DAB_copy;

wire Q1, Q2, Q3, Q4;

wire [7:0] digit_0, digit_1;
wire [3:0] button;   // debounce buttons signals
wire sw0_debounced;
wire [1:0] sigma;


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
// assign   MODE   = SW[2:1];

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
// assign   DA = DAA_copy;
assign   DB = DAB_copy;

assign   DA = debug[29:16] + 14'd8191;


// LED for DEBUG

assign   LED[0]   = ~ENABLE;
assign   LED[3]   =  ENABLE ? ~ADA_OR : 1'b1;
assign   LED[4]   =  ENABLE ? ~ADB_OR : 1'b1;
// assign   LED[7:6] = ~MODE;
assign   LED[ 5 ] = ALERT;

assign   SEG0 = digit_0;
assign   SEG1 = digit_1;

//unused
assign   LED[2:1]   = debug[1:0];

// OUTPUT      
assign ALERT = ~((Q1 & Q3) | (Q2 & Q4));

assign   OUT[0]  = Q2 & ENABLE & ALERT;
assign   OUT[2]  = Q4 & ENABLE & ALERT;
assign   OUT[4]  = Q1 & ENABLE & ALERT;
assign   OUT[6]  = Q3 & ENABLE & ALERT;
   
assign   OUT[1]  = debug[15];   // jump enable
assign   OUT[3]  = debug[14];   // overflow
assign   OUT[5]  = Q2 & ENABLE;
assign   OUT[7]  = Q1 & ENABLE;

assign  OUT[10]  = debug[15];  // C1 original
assign  OUT[12]  = debug[11];  // C1 regularized
assign  OUT[14]  = debug[4];   // C1 debounced
assign  OUT[16]  = debug[0];   // sign iC
assign  OUT[18]  = debug[4];   // sign vC
assign  OUT[20]  = debug[1];   // clk_JUMP  
assign  OUT[22]  = debug[5];   //  

assign  OUT[24]  = sigma[1];  //    
assign  OUT[26]  = debug[15]; // C1 
assign  OUT[28]  = debug[14]; // C2 

assign  OUT[27]  = debug[3]; // iC
assign  OUT[29]  = debug[4]; // vC
assign  OUT[31]  = debug[5]; // vC_filt

assign  OUT[30]  = debug[6];  // b0



// PLL
PLL   PLL_inst (
   .inclk0 ( OSC ),
   .c0 ( clk_main ),
   .c1 ( clk_100M ),
   .c2 ( clk_10M ),
   .c3 ( clk_1M )
);

// control law
hybrid_control_phi_regularization hybrid_control_inst (
   .o_MOSFET( MOSFET ),  // control signal for the four MOSFETs
   .o_sigma( sigma ),         // 2 bit for signed sigma -> {-1,0,1}
   .o_debug( debug ),    // ? random currently
   .i_clock( clk_100M ), // ADA_DCO
   .i_RESET( reset ),    //
   .i_vC( ADC_A ),       //
   .i_iC( ADC_B ),       //
   .i_phi( phi )     // phi // pi/4 - 32'h0000004E
);



phi_control phi_control_inst(
   .o_seg0(digit_0),
   .o_seg1(digit_1),
   .o_phi32(phi),
   .i_reset(button[0]),
   .i_increase(button[2]),
   .i_decrease(button[1])
);

// ----- DEAD TIME ----- //

dead_time_4bit dead_time_inst(
   .o_signal( {Q4, Q3, Q2, Q1} ),          // output switching variable
   .i_clock(  clk_100M ),            // for sequential behavior
   .i_signal( MOSFET ),
   .deadtime( 10'd5 )
);



// ----- DEBOUNCE ----- //

debounce_4bit debounce_4bit_inst(
   .o_switch(button[3:0]),
   .i_clk(clk_1M),
   .i_reset(reset),
   .i_switch(BUTTON[3:0]),
   .debounce_limit(31'd5000)  // 5ms
);

debounce_extended debounce_ENABLE_inst(
   .o_switch(sw0_debounced),
   .i_clk(clk_1M),
   .i_reset(reset),
   .i_switch(SW[0]),
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

endmodule



