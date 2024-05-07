//------------------------------------------------------------
// Project: HYBRID_CONTROL_THETA_PHI_OL
// Author: Nicola Zaupa
// Date: (2023/07/26) (00:27:25)
// File: TOP_HybridControl_theta_phi_OL.v
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

module TOP_HybridControl_theta_phi_OL (
   //=======================================================
   //  PORT declarations
   //=======================================================

   //clock + reset
   input  CPU_RESET,
   input  OSC,
   output FAN_CTRL,
   //ADC
   input  signed [13:0]  ADB_DATA,
   input  signed [13:0]  ADA_DATA,
   output [13:0]  DA,
   output [13:0]  DB,
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
   output [7:0]   SEG1,
   output [35:0]  GPIO0
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
wire       ENABLE, ALERT;
wire       Q1, Q2, Q3, Q4;
wire [3:0] MOSFET_theta;
wire [3:0] MOSFET_phi;
wire [3:0] MOSFET_theta_phi;
reg  [3:0] MOSFET;

// ADCs and DACs
reg signed [13:0] ADC_A;
reg signed [13:0] ADC_B;
reg        [13:0] DAA_copy;
reg        [13:0] DAB_copy;

// rectifier
reg  [7:0] ADC_Vbat;
reg  [7:0] ADC_Ibat;
wire [7:0] Vbat_dec;
wire [7:0] Ibat_dec;
wire [7:0] Vbat_seg, Ibat_seg;
wire [6:0] SEG0_Vbat, SEG1_Vbat, SEG0_Ibat, SEG1_Ibat;

reg  [7:0] deadtime = 8'd5;
wire [7:0] cnt_startup;
wire [7:0] cnt_Vg;
reg  [7:0] cnt_startup_reg;


wire  [31:0] debug;
wire  [1:0]  test;

wire [31:0] phi;
wire [31:0] theta;
wire [31:0] phi_HC;
wire [31:0] theta_HC;


wire [1:0] sigma; // internal state

reg  [7:0] SEG0_reg, SEG1_reg;

wire [7:0] digit_0_theta, digit_1_theta, 
           digit_0_phi,   digit_1_phi;
wire [3:0] button, sw;   // debounce buttons and switch
// wire [1:0] sw2;
// assign GPIO0[4:3] = sw2;

wire ON;

//=======================================================
//  Structural coding
//=======================================================
assign ENABLE = sw[0];

// tank ADCs clocks
assign  FPGA_CLK_A_P  =  clk_100M;
assign  FPGA_CLK_A_N  = ~clk_100M;
assign  FPGA_CLK_B_P  =  clk_100M;
assign  FPGA_CLK_B_N  = ~clk_100M; 
// rectifier ADCs clocks
assign  ADC_BAT_V_CONVST = clk_100k;
assign  ADC_BAT_I_CONVST = clk_100k;

// assign for ADC control signal
assign   AD_SCLK    = 1'b1;//SW[2];   // (DFS) Data Format Select
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
assign  DA = debug[20:7];

// ############################
// ##### assign for DEBUG #####
// ############################

// LED for DEBUG on the FPGA card [0==ON]
assign   LED[0]   = ~1'b0;
assign   LED[1]   = ~1'b0;
assign   LED[2]   = ~1'b0;
assign   LED[3]   = ~1'b0;
assign   LED[4]   = ~1'b0;
assign   LED[5]   = ~1'b0;
assign   LED[6]   = ~1'b0;
assign   LED[7]   = ~1'b0;
// RECTIFIER: show the values on 7seg display and LEDs
// assign LED = SW[3] ? ~ADC_Vbat : ~ADC_Ibat;

assign SEG0 = SEG0_reg; //SEG0_reg;
assign SEG1 = SEG1_reg; //SEG1_reg;

// // connected to GPIO1 and available on the rectifier board
// // all are available on the 2×6 connector, 6 of them are connected to LED
// assign EX[0]  = SW[3];     // over voltage
// assign EX[1]  = ~SW[3];    // over current
// assign EX[2]  = ENABLE;    // H-bridge ENABLE
// assign EX[3]  = Q1;        // free
// assign EX[4]  = Q2;        // free
// assign EX[5]  = Q3;        // free
// assign EX[6]  = Q4;        // free
// assign EX[7]  = debug[2];  // free
// assign EX[8]  = 1'b0;      // free
// assign EX[9]  = debug[0];  // LED 3
// assign EX[10] = debug[1];  // LED 2
// assign EX[11] = debug[21];  // LED 1

// // connected to GPIO0
// assign GPIO0[10] = debug[3];
// assign GPIO0[12] = debug[4];
// assign GPIO0[14] = debug[5];
// assign GPIO0[16] = debug[6];


// connected to GPIO1 and available on the rectifier board
// all are available on the 2×6 connector, 6 of them are connected to LEDs
//CO: 22/12/23 update ex bits
assign EX[0]  =  SW[3];      // over voltage
assign EX[1]  = ~SW[3];      // over current
assign EX[2]  = ENABLE;      // H-bridge ENABLE
assign EX[3]  = debug[2];    // Pin 4 D0
assign EX[4]  = debug[3];    // Pin 5 D1
assign EX[5]  = Q1;          // Pin 6 D2  M1_delayed
assign EX[6]  = MOSFET[0];   // Pin 7 D3  M1
assign EX[7]  = test[0];     // Pin 8 D4  b0
assign EX[8]  = test[1];     // Pin 9 D5  b1
assign EX[9]  = debug[14];   // Pin 10 ?
assign EX[10] = debug[15];   // Pin 11 D6
assign EX[11] = debug[21];   // LED 1  D7

assign GPIO0[18] = Q1;   // D12
assign GPIO0[20] = Q2;   // D13
assign GPIO0[22] = Q3;   // D14
assign GPIO0[24] = Q4;   // D15

// connected to GPIO0
// debug for Ci signals
// D8
assign GPIO0[10] = debug[4];
// D9
assign GPIO0[12] = debug[5];
// D10
assign GPIO0[14] = debug[6];
// D11
assign GPIO0[16] = debug[7];

// ##### assign for DEBUG END #####

// --- assign for the H-bridge ---      
// check if there is a short circuit
assign ALERT   = ~((Q1 & Q3) | (Q2 & Q4));

//                  normal        boot-strap      force sigma=1
assign Q[1] = ( (Q2 & ON & VG) | (1'b0 & ~ON) | (1'b0 & ON & ~VG) ) & ENABLE & ALERT;
assign Q[3] = ( (Q4 & ON & VG) | (1'b1 & ~ON) | (1'b1 & ON & ~VG) ) & ENABLE & ALERT;
assign Q[0] = ( (Q1 & ON & VG) | (1'b0 & ~ON) | (1'b1 & ON & ~VG) ) & ENABLE & ALERT;
assign Q[2] = ( (Q3 & ON & VG) | (1'b1 & ~ON) | (1'b0 & ON & ~VG) ) & ENABLE & ALERT;

// assign MOSFET = MOSFET_theta_phi;

// start-up counter - charge the bootstrap capacitor by activating Q3 and Q4 (low side)
assign ON = cnt_startup > 8'd10; //10us to charge bootstrap capacitor
assign VG = cnt_Vg      > 10'd10; //10us to charge bootstrap capacitor

// --- assign for the ADCs in the rectifier ---      
assign Vbat_dec = (ADC_Ibat>>4)*5;  // ADC*0.3125
// raw reconstruction
assign Ibat_dec = (ADC_Ibat>>3) + (~8'd21+1);


// --- assign for the control of the Resonant Tank ---      

assign   phi_HC   = phi;
// assign   theta_HC = sw[3] ? (32'd170+(~phi+1)) : theta;
assign   theta_HC = 32'd10 + (~phi+1);
// assign   theta_HC = 32'd160;


// -------------------------------------
//         modules instantiation
// -------------------------------------

// PLL - manage the clock generation
PLL_theta_phi_OL PLL_inst (
   .inclk0 ( OSC ),
   .c0 ( clk_main ),
   .c1 ( clk_100M ),
   .c2 ( clk_1M ),
   .c3 ( clk_100k ),
   .c4 ( FAN_CTRL )
);

// DIFFERENT WAY TO CONTROL THE RESONANT TANK
//    1. only theta --> frequency modulation
//    2. only phi   --> amplitude modulation
//    3. theta+phi  --> mixte modulation ensuring ZVS

// control law THETA
hybrid_control_theta hybrid_control_theta_inst (
   .o_MOSFET( MOSFET_theta ),   // control signal for the four MOSFETs
   .o_sigma(  ),          // output switching variable
   .o_debug(  ),          // [16bit]
   .i_clock( clk_100M ),  // for sequential behavior
   .i_RESET( CPU_RESET ), // reset signal
   .i_vC( ADC_A ),        // [14bit-signed] input related to z1
   .i_iC( ADC_B ),        // [14bit-signed] input related to z2
   .i_theta( theta )     // [32bit-signed] angle of the switching surface
);

// control law PHI
hybrid_control_phi hybrid_control_inst (
   .o_MOSFET( MOSFET_phi ),  // control signal for the four MOSFETs
   .o_sigma(  ),         // 2 bit for signed sigma -> {-1,0,1}
   .o_debug( ),    // ? random currently
   .i_clock( clk_100M ), // ADA_DCO
   .i_RESET( CPU_RESET ),    //
   .i_vC( ADC_A ),       //
   .i_iC( ADC_B ),       //
   .i_phi( phi )     // phi // pi/4 - 32'h0000004E
);

// control law PHI + THETA
hybrid_control_theta_phi #(.mu_z1(32'd86), .mu_z2(32'd90), .mu_Vg(32'd312000)
) hybrid_control_theta_phi_inst (
   .o_MOSFET( MOSFET_theta_phi ),  // control signal for the four MOSFETs
   .o_sigma( test ),         // 2 bit for signed sigma -> {-1,0,1}
   .o_debug(  ),    // ---
   .i_clock( clk_100M ), // 
   .i_RESET( CPU_RESET),    // 
   .i_vC( ADC_A ),       // 
   .i_iC( ADC_B ),       // 
   .i_theta( theta_HC ),    // 32'd314
   .i_phi( phi_HC ),        // phi // pi/4 - 32'h0000004E
   .i_sigma( ) //{ {31{sigma[1]}} , sigma[0] } )
);

hybrid_control_mixed #(.mu_z1(32'd86), .mu_z2(32'd90)
) hybrid_control_mixed_inst (
   .o_MOSFET(  ),  // control signal for the four MOSFETs
   .o_sigma(  ),         // 2 bit for signed sigma -> {-1,0,1}
   .o_debug( debug ),    // ---
   .i_clock( clk_100M ), // 
   .i_RESET( CPU_RESET ),    // 
   .i_vC( ADC_A ),       // 
   .i_iC( ADC_B ),       // 
   .i_ZVS( 32'd20 ),    // 32'd314
   .i_phi( phi_HC ),        // phi // pi/4 - 32'h0000004E
   .i_sigma( ) //{ {31{sigma[1]}} , sigma[0] } )
);

//angle control

phi_control phi_control_inst(
   .o_seg0(digit_0_phi), //
   .o_seg1(digit_1_phi), // 
   .o_phi32(phi),
   .i_reset(button[0]),
   .i_increase(1'b1),
   .i_decrease(button[1])
);

theta_control theta_control_inst(
   .o_seg0(digit_0_theta), //digit_0
   .o_seg1(digit_1_theta), // digit_1
   .o_theta32(theta),
   .i_reset(button[0]),
   .i_increase(1'b1),
   .i_decrease(button[2])
);

// ----- DEAD TIME ----- //

dead_time #(.DEADTIME(20), .N(4)) dead_time_inst(
   .o_signal( {Q4, Q3, Q2, Q1} ),          // output switching variable
   .i_clock(  clk_100M ),            // for sequential behavior
   .i_signal( MOSFET )
);

// ----- DEBOUNCE ----- //

debounce #(.DEBOUNCE_TIME(5000), .N(4)) debounce_4bit_inst( // 5ms
   .o_switch(button[3:0]),
   .i_clk(clk_1M),
   .i_reset(CPU_RESET),
   .i_switch(BUTTON[3:0])
);

debounce #(.DEBOUNCE_TIME(5000), .N(4)) debounce_SWITCH_inst( // 5ms
   .o_switch(sw),
   .i_clk(clk_1M),
   .i_reset(CPU_RESET),
   .i_switch(SW)
);


// START UP counter
counter_up counter_up_inst    (
   .o_counter(cnt_startup), // Output of the counter
   .enable( ~ON & ENABLE),    // enable for counter
   .clk(clk_1M),       // clock Input
   .reset(ENABLE)      // reset Input
);

counter_up counter_up_inst_Vg    (
   .o_counter(cnt_Vg), // Output of the counter
   .enable( ~VG & ENABLE),    // enable for counter
   .clk(clk_1M),       // clock Input
   .reset(ENABLE)      // reset Input
);


// ADC: acquire data from ADC when available
always @(posedge ADA_DCO) begin
   ADC_A    = ~ADA_DATA+14'b1;
   DAA_copy = ~ADA_DATA+14'b1 + 14'd8191;
end

always @(posedge ADB_DCO) begin
   ADC_B    = ~ADB_DATA+14'b1;
   DAB_copy = ~ADB_DATA+14'b1 + 14'd8191;
end


// choose what to show on the 7-segment displays
// and the mode of the converter
always  begin
   case (SW[2:1])
      2'b00 : begin // PHI+THETA
         if (~SW[3]) begin // phi
            SEG0_reg <= digit_0_phi;
            SEG1_reg <= digit_1_phi;
         end else begin    // theta
            SEG0_reg <= theta_HC[3:0];
            SEG1_reg <= theta_HC[7:4];
         end
         MOSFET   <= MOSFET_theta_phi;
      end
      2'b01 : begin  // THETA
         SEG0_reg <= digit_0_theta;
         SEG1_reg <= digit_1_theta;
         MOSFET   <= MOSFET_theta;
      end
      2'b10 : begin // PHI
         SEG0_reg <= digit_0_phi;
         SEG1_reg <= digit_1_phi;
         MOSFET   <= MOSFET_phi;
      end
      default: begin // shows '--'
         SEG0_reg <= 8'b10111111;
         SEG1_reg <= 8'b10111111;
         MOSFET   <= 4'b0;
      end
   endcase
   
end


always @(posedge clk_main) begin
   cnt_startup_reg <= cnt_startup;
end
endmodule


