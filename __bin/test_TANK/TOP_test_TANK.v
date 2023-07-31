//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/23) (00:18:20)
// File: TOP_test_TANK.v
//------------------------------------------------------------
// Description:
// The scope is to generate:
//   1. generate a square waveform in the H-bridge
//   2. replicate ADC input to the DAC port
// to test the frequency response of the resonant tank
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

module TOP_Hbridge_frequency (
   //clock + reset
   OSC,
   CPU_RESET,
   FAN_CTRL,
   //output bridge signal
   Q,
   EX,
   GPIO0,
   //debugging
   BUTTON,  // button on the main board
   SW,      // switches on the main board
   LED,     // LEDs on the main board
   SEG0,    // 7-segments display LSB
   SEG1,    // 7-segments display MSB
   // ADC + DAC daughter board
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
   DA,
   DB,
);


//=======================================================
//  PORT declarations
//=======================================================

input OSC;
input CPU_RESET;
output FAN_CTRL;

//output
output [3:0]   Q;
output [11:0]  EX;
output [35:0]  GPIO0;
//debug
input  [3:0]   SW;
input  [3:0]   BUTTON;
output [7:0]   LED;
output [7:0]   SEG0;
output [7:0]   SEG1;
// ADC + DAC daughter board

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire     clk_main;
wire     clk_FAN;
wire     clk_1M;
wire     clk_100M;

wire     reset;
wire     ENABLE, ALERT, Q1, Q2, Q3, Q4;
wire [1:0] MODE;
wire [3:0] MOSFET;


reg [31:0] counter;
wire b1, b0;

wire [7:0] digit_0, digit_1;
wire [3:0] button;   // debounce buttons signals
wire sw0_debounced;

wire [31:0] period;
wire sigma;
wire CLK_bridge;


//=======================================================
//  Structural coding
//=======================================================
//--- globa signal assign
assign   reset  =  CPU_RESET;
assign   FAN_CTRL = clk_FAN;
assign   ENABLE = sw0_debounced;

// LED for DEBUG

assign   LED[0]   = ~ENABLE;
assign   LED[3]   =  1'b0;
assign   LED[4]   =  1'b0;
assign   LED[7:6] = ~MODE;
assign   LED[ 5 ] = ALERT;

// assign   SEG0 = digit_0;
// assign   SEG1 = digit_1;

// assign b0 = counter[1];
// assign b1 = counter[2];

// assign MOSFET[0] = sigma;
// assign MOSFET[1] = ~sigma;
// assign MOSFET[2] = ~sigma;
// assign MOSFET[3] = sigma;
assign MOSFET = { sigma , ~sigma , ~sigma , sigma };
//unused
// assign   LED[2:1]   = debug[1:0];

// OUTPUT      
assign ALERT = ~((Q1 & Q3) | (Q2 & Q4));

assign   OUT[0]  = Q2 & ENABLE & ALERT;
assign   OUT[2]  = Q4 & ENABLE & ALERT;
assign   OUT[4]  = Q1 & ENABLE & ALERT;
assign   OUT[6]  = Q3 & ENABLE & ALERT;

// assign   OUT[1]  = debug[15];   // jump enable
// assign   OUT[3]  = debug[14];   // overflow
// assign   OUT[5]  = Q2 & ENABLE;
// assign   OUT[7]  = Q1 & ENABLE;

assign   OUT[10]  = CLK_bridge;    // 0 - cnt-bit2
assign   OUT[12]  = sigma;    // 1 - b0
// assign   OUT[14]  = debug[1];    // 2 - b1
assign   OUT[16]  = Q1; //debug[15];   // 3 - C1
assign   OUT[18]  = Q2; //debug[14];   // 4 - C2
assign   OUT[20]  = Q3; //debug[13];   // 5 - C3
assign   OUT[22]  = Q4; //debug[12];   // 6 - C4
assign   OUT[24]  = MOSFET[0]; //debug[11];   // 7 - CLK_OR
assign   OUT[26]  = MOSFET[1];   // 8 - CLK_prev
// assign   OUT[28]  = debug[9];    // 9 - CLK
assign   OUT[30]  = ALERT;       // 10- non delayed output

assign CLK_bridge = (counter>=period);
assign sigma = CLK_bridge;


// PLL
PLL PLL_inst (
   .inclk0 ( OSC ),
   .c0 ( clk_main ),
   .c1 ( clk_100M ),
   .c2 ( clk_1M ),
   .c3 ( clk_100k ),
   .c3 ( clk_FAN )
);


frequency_control frequency_control_inst(
   .o_period(period),
   .o_seg0(SEG0),
   .o_seg1(SEG1),
   .i_reset(CPU_RESET),
   .i_increase1(button[0]),
   .i_decrease1(button[1]),
   .i_increase5(button[2]),
   .i_decrease5(button[3])
);


dead_time_4bit dead_time_inst(
   .o_signal( {Q4, Q3, Q2, Q1} ),          // output switching variable
   .i_clock(  clk_100M ),            // for sequential behavior
   .i_signal( MOSFET ),
   .deadtime( 10'd25 )
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



always @(posedge clk_100M) begin
   if (counter < (period<<1))
      counter <= counter + 32'b1;
   else
      counter <= 32'b0;

end



// always @(posedge CLK_bridge ) begin
//    sigma <= ~sigma;
// end



endmodule




