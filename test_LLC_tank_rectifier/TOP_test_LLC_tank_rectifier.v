//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/23) (22:35:22)
// File: TOP_test_LLC_tank_rectifier.v
//------------------------------------------------------------
// Description:
// The scope is to generate:
//   1. generate a square waveform in the H-bridge
//   2. replicate ADC input to the DAC port
// to test the frequency response of the resonant tank
// 
// 
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
//------------------------------------------------------------




`timescale 1 ns / 1 ps

module TOP_test_LLC_tank_rectifier (
   //clock + reset
   input OSC,
   input CPU_RESET,
   output FAN_CTRL,
   //ADC DDC
   input  signed [13:0]  ADB_DATA,
   input  signed [13:0]  ADA_DATA,
   output [13:0]  DA,
   output [13:0]  DB,
   input  ADA_OR,
   input  ADB_OR,
   inout  AD_SCLK,
   inout  AD_SDIO,
   output ADA_OE,
   output ADA_SPI_CS,
   output ADB_OE,
   output ADB_SPI_CS,
   inout  FPGA_CLK_A_N,
   inout  FPGA_CLK_A_P,
   inout  FPGA_CLK_B_N,
   inout  FPGA_CLK_B_P,
   input  ADA_DCO,
   input  ADB_DCO,
   // ADCs 8bit
   input  [7:0] ADC_BAT_V,
   output       ADC_BAT_V_CONVST,
   input        ADC_BAT_V_EOC,
   input  [7:0] ADC_BAT_I,
   output       ADC_BAT_I_CONVST,
   input        ADC_BAT_I_EOC,
   //output
   // take care that 
   //    Q[0] ->  M1 that on the PCB is Q3 (leg 1)
   //    Q[1] ->  M2 that on the PCB is Q1 (leg 2)
   //    Q[2] ->  M3 that on the PCB is Q4 (leg 1)
   //    Q[3] ->  M4 that on the PCB is Q2 (leg 2)
   output [3:0]   Q,
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

// clock signals
wire     clk_main;
wire     clk_1M;
wire     clk_100M;
wire     clk_100k;

// signal for the MOSFETs
wire       ENABLE, ALERT, Q1, Q2, Q3, Q4;
wire [3:0] MOSFET;


// debugging and control
wire [7:0] digit_0, digit_1;
wire [3:0] button;   // debounce buttons signals
wire sw0_debounced;
reg  [7:0] SEG0_reg, SEG1_reg;

// square waveform generation
wire [31:0] period;
wire sigma;
wire CLK_bridge;
reg [31:0] counter;
wire [7:0] SEG0_freq, SEG1_freq;

// ADCs and DACs
reg signed [13:0] ADC_A;
reg signed [13:0] ADC_B;
reg        [13:0] DAA_copy;
reg        [13:0] DAB_copy;
// rectifier
reg [7:0] ADC_Vbat;
reg [7:0] ADC_Ibat;
wire [31:0] Vbat_dec;
wire [31:0] Ibat_dec;
wire [7:0] Vbat_seg;
wire [7:0] Ibat_seg;
wire [6:0] SEG0_Vbat, SEG1_Vbat, SEG0_Ibat, SEG1_Ibat;

//=======================================================
//  Structural coding
//=======================================================
//--- globa signal assign

// tank ADCs clocks
assign  FPGA_CLK_A_P  =  clk_100M;
assign  FPGA_CLK_A_N  = ~clk_100M;
assign  FPGA_CLK_B_P  =  clk_100M;
assign  FPGA_CLK_B_N  = ~clk_100M; 
// rectifier ADCs clocks
assign  ADC_BAT_V_CONVST = clk_100k;
assign  ADC_BAT_I_CONVST = clk_100k;

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


// LED for DEBUG on the FPGA card
// assign   LED[0]   =  1'b0;
// assign   LED[1]   =  1'b0;
// assign   LED[2]   =  1'b0;
// assign   LED[3]   =  1'b0;
// assign   LED[4]   =  1'b0;
// assign   LED[5]   =  1'b0;
// assign   LED[6]   = ~1'b0;
// assign   LED[7]   = ~1'b0;
// 



// binary values for the signals for the MOSFETs
assign MOSFET = { sigma , ~sigma , ~sigma , sigma };

// OUTPUT      
assign ALERT = ~((Q1 & Q3) | (Q2 & Q4));

assign   Q[1]  = Q2 & ENABLE & ALERT;
assign   Q[3]  = Q4 & ENABLE & ALERT;
assign   Q[0]  = Q1 & ENABLE & ALERT;
assign   Q[2]  = Q3 & ENABLE & ALERT;


// OUTPUT FOR DEBUG
// the option is to debug on GPIO-0 (connected also to JP4 - 14pin header)

assign SEG0 = SEG0_reg;
assign SEG1 = SEG1_reg;

// assign   OUT[10]  = CLK_bridge;    // 0 - cnt-bit2
assign EX[0]  = SW[3];    // over voltage
assign EX[1]  = ~SW[3];    // over current
assign EX[2]  = ENABLE;  // H-bridge ENABLE
assign EX[3]  = clk_100k;    // free
assign EX[4]  = ADC_BAT_V_EOC;    // free
assign EX[5]  = ADC_BAT_I_EOC;    // free
assign EX[6]  = 1'b0;    // free
assign EX[7]  = 1'b0;    // free
assign EX[8]  = 1'b0;    // free
assign EX[9]  = 1'b0;   // LED 3
assign EX[10] = 1'b0;    // LED 2
assign EX[11] = 1'b0;    // LED 1

assign CLK_bridge = (counter>=period);
assign sigma = CLK_bridge;

// RECTIFIER: show the values on 7seg display and LEDs

assign LED = SW[3] ? ~ADC_Vbat : ~ADC_Ibat;

// Vbat = 312*ADC (mV)
// output in V, like 44V or 03V
assign Vbat_dec = (ADC_Vbat*5)>>4;  // ADC*0.3125
// raw reconstruction 
// (Ibat-151)*142 = 142*Ibat - 21442 (mA)
// output in dec of A, like 2.3A
// assign Ibat_dec = ({ {24{1'b0}} , ADC_Ibat }*32'd23)>>4 + (~32'd214+1);
assign Ibat_dec = ({ {24{1'b0}} , ADC_Ibat }*32'd3/32'd2) + (~32'd214+1);




// PLL
PLL_test_LLC PLL_inst (
   .inclk0 ( OSC ),
   .c0 ( clk_main ),
   .c1 ( clk_100M ),
   .c2 ( clk_1M ),
   .c3 ( clk_100k ),
   .c4 ( FAN_CTRL )
);

// control of the frequency at which the H-brisge is working
frequency_control frequency_control_inst(
   .o_period(period),
   .o_seg0(SEG0_freq),
   .o_seg1(SEG1_freq),
   .i_reset(CPU_RESET),
   .i_increase1(button[0]),
   .i_decrease1(button[1]),
   .i_increase5(button[2]),
   .i_decrease5(button[3])
);


// from MOSFET to Q == add a deadtime
dead_time_4bit dead_time_inst(
   .o_signal( {Q4, Q3, Q2, Q1} ),          // output switching variable
   .i_clock(  clk_100M ),            // for sequential behavior
   .i_signal( MOSFET ),
   .deadtime( 10'd25 )  // 25@100MHz = 250ns
);

// ----- DEBOUNCE ----- //

debounce_4bit debounce_4bit_inst(
   .o_switch(button[3:0]),
   .i_clk(clk_1M),
   .i_reset(CPU_RESET),
   .i_switch(BUTTON[3:0]),
   .debounce_limit(31'd5000)  // 5ms
);

debounce_extended debounce_ENABLE_inst(
   .o_switch(ENABLE),
   .i_clk(clk_1M),
   .i_reset(CPU_RESET),
   .i_switch(SW[0]),
   .debounce_limit(31'd5000)  // 5ms
);

// Ibat
dec2seg dec2seg_Ibat_inst (
   .o_seg(Ibat_seg),
   .i_dec(Ibat_dec[7:0])
);

seven_segment seven_segment_0_Ibat_inst(
   .o_seg(SEG0_Ibat),
   .i_num(Ibat_seg[3:0])
);

seven_segment seven_segment_1_Ibat_inst(
   .o_seg(SEG1_Ibat),
   .i_num(Ibat_seg[7:4])
);

// Vbat
dec2seg dec2seg_Vbat_inst (
   .o_seg(Vbat_seg),
   .i_dec(Vbat_dec[7:0])
);

seven_segment seven_segment_0_Vbat_inst(
   .o_seg(SEG0_Vbat),
   .i_num(Vbat_seg[3:0])
);

seven_segment seven_segment_1_Vbat_inst(
   .o_seg(SEG1_Vbat),
   .i_num(Vbat_seg[7:4])
);

// // show the hexadecimal representation of the number read by the ADC
// seven_segment seven_segment_0_Vbat_inst(
//    .o_seg(SEG0_Vbat),
//    .i_num(ADC_Vbat[3:0])
// );

// seven_segment seven_segment_1_Vbat_inst(
//    .o_seg(SEG1_Vbat),
//    .i_num(ADC_Vbat[7:4])
// );

// seven_segment seven_segment_0_Ibat_inst(
//    .o_seg(SEG0_Ibat),
//    .i_num(ADC_Ibat[3:0])
// );

// seven_segment seven_segment_1_Ibat_inst(
//    .o_seg(SEG1_Ibat),
//    .i_num(ADC_Ibat[7:4])
// );


// counter used to generate the square waveform
always @(posedge clk_100M) begin
   if (counter < (period<<1))
      counter <= counter + 32'b1;
   else
      counter <= 32'b0;
end


// ADC: acquire data from when available
// resonant tank
always @(posedge ADA_DCO) begin
   ADC_A    = ~ADA_DATA+14'b1;
   DAA_copy = ~ADA_DATA+14'b1 + 14'd8191;
end

always @(posedge ADB_DCO) begin
   ADC_B    = ~ADB_DATA+14'b1;
   DAB_copy = ~ADB_DATA+14'b1 + 14'd8191;
end

// rectifier ADCs acquisition
always @(negedge ADC_BAT_V_EOC) 
   ADC_Vbat = ADC_BAT_V;

always @(negedge ADC_BAT_I_EOC) 
   ADC_Ibat = ADC_BAT_I;


// debugging rectifier ADC or showing input frequency
always @(posedge clk_100k) begin
   case (SW[2:1])
      2'b00 : begin
         SEG0_reg <= SEG0_freq;
         SEG1_reg <= SEG1_freq;
      end
      2'b01 : begin  // Vbat
         SEG0_reg <= { 1'b1 , SEG0_Vbat };
         SEG1_reg <= { 1'b1 , SEG1_Vbat };
      end
      2'b10 : begin // Ibat
         SEG0_reg <= { 1'b1 , SEG0_Ibat };
         SEG1_reg <= { 1'b0 , SEG1_Ibat };
      end
      default: begin
         SEG0_reg <= 8'b10111111;
         SEG1_reg <= 8'b10111111;
      end
   endcase
   
end


endmodule




