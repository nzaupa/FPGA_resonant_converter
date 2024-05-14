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

// GIVE AN EXPLANATION HERE
// 
// 
// 
// 
// 


`timescale 1 ns / 1 ps

module TOP_HybridControl_theta_phi_CL (
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
   input  [7:0]   DSW,
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
wire [3:0] Q100, Q200, Q400, Q600;  // different MOSFET control with different deadtimes (in ns)
reg  [3:0] Qout;
wire [3:0] MOSFET_theta;
wire [3:0] MOSFET_phi;
wire [3:0] MOSFET_theta_phi;
reg  [3:0] MOSFET;

// ADCs and DACs
reg signed [13:0] ADC_A, ADC_B;
reg        [13:0] DAA_copy, DAB_copy;

// rectifier
reg  [7:0]  ADC_Vbat, ADC_Ibat;
wire [7:0]  Vbat_DEC, Ibat_DEC;
wire [15:0] SEG_Vbat_HEX, SEG_Ibat_HEX, SEG_Vbat_DEC, SEG_Ibat_DEC;
wire [31:0] Ibat_mA;

// PI controller
wire [31:0] error, Iref_dA;
wire [31:0] error_dA;


// H-bridge control and startup
reg  [7:0] deadtime = 8'd5;
wire [7:0] cnt_startup;
wire [7:0] cnt_Vg;
// reg  [7:0] cnt_startup_reg;


wire  [31:0] debug;
wire  [1:0]  test;

wire [31:0] phi;
wire [31:0] delta;
wire [31:0] phi_HC;
wire [31:0] phi_PI, phi_PI_sat, phi_PI_tmp;


wire [1:0] sigma; // internal state

wire  [7:0] SEG0_reg, SEG1_reg;
wire [15:0] SEG_DELTA, SEG_PHI, SEG_IREF;

wire [3:0] button, sw;   // debounce buttons and switch
// wire [1:0] sw2;
// assign GPIO0[4:3] = sw2;

wire ON, VG, ENABLE_RST;
reg  VG_PREV;

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

   assign SEG0 = ~sw[3] ? SEG_PHI[ 7:0] : SEG0_reg; 
   assign SEG1 = ~sw[3] ? SEG_PHI[15:8] : SEG1_reg; 

   // connected to GPIO1 and available on the rectifier board
   // all are available on the 2×6 connector, 6 of them are connected to LEDs
   //CO: 22/12/23 update ex bits
   // assign EX[0]  =  SW[3];      // over voltage
   // assign EX[1]  = ~SW[3];      // over current
   // assign EX[2]  = ENABLE;      // H-bridge ENABLE
   // assign EX[3]  = debug[2];    // Pin 4 D0
   // assign EX[4]  = debug[3];    // Pin 5 D1
   // assign EX[5]  = debug[8];    // Pin 6 D2  M1_delayed
   // assign EX[6]  = debug[9];    // Pin 7 D3  M1
   // assign EX[7]  = test[0];     // Pin 8 D4  b0
   assign EX[6:0]= sw[1] ? phi_PI[6:0] : error_dA[6:0];
   assign EX[7]  = sw[1] ? phi_PI[31]  : error_dA[31];     
   assign EX[8]  = test[1];     // Pin 9 D5  b1
   assign EX[9]  = debug[14];   // Pin 10 ?
   assign EX[10] = debug[15];   // Pin 11 D6
   assign EX[11] = ENABLE;      // Pin 12 D7  (and LED 1)

   // assign GPIO0[18] = Q[0]; //Q1;   // D12
   // assign GPIO0[20] = Q[1]; //Q2;   // D13
   // assign GPIO0[22] = Q[2]; //Q3;   // D14
   // assign GPIO0[24] = Q[3]; //Q4;   // D15

   // // connected to GPIO0
   // // debug for Ci signals
   // assign GPIO0[10] = ADC_B[13]; // D8   iC sign
   // assign GPIO0[12] = ENABLE_RST; // D9    S0
   // assign GPIO0[14] = ENABLE; // D10   S1
   // assign GPIO0[16] = VG; // D11   b0



   // connected to GPIO0
   // debug for Ci signals
   assign GPIO0[10] = phi_PI_sat[0];// D8
   assign GPIO0[12] = phi_PI_sat[1];// D9
   assign GPIO0[14] = phi_PI_sat[2];// D10
   assign GPIO0[16] = phi_PI_sat[3];// D11
   assign GPIO0[18] = phi_PI_sat[4];// D12
   assign GPIO0[20] = phi_PI_sat[5];// D13
   assign GPIO0[22] = phi_PI_sat[6];// D14
   assign GPIO0[24] = VG;// D15

// ##### assign for DEBUG END #####

// --- assign for the H-bridge ---      
// check if there is a short circuit
assign ALERT   = ~((Q1 & Q3) | (Q2 & Q4));

assign {Q4, Q3, Q2, Q1} = Qout;

//                  normal        boot-strap      force sigma=1
assign Q[0] = ( (Q1 & ON & VG) | (1'b0 & ~ON) | (1'b1 & ON & (~VG)) ) & ENABLE & ALERT;
assign Q[1] = ( (Q2 & ON & VG) | (1'b0 & ~ON) | (1'b0 & ON & (~VG)) ) & ENABLE & ALERT;
assign Q[2] = ( (Q3 & ON & VG) | (1'b1 & ~ON) | (1'b0 & ON & (~VG)) ) & ENABLE & ALERT;
assign Q[3] = ( (Q4 & ON & VG) | (1'b1 & ~ON) | (1'b1 & ON & (~VG)) ) & ENABLE & ALERT;

// assign MOSFET = MOSFET_theta_phi;

// start-up counter - charge the bootstrap capacitor by activating Q3 and Q4 (low side)
assign ON = cnt_startup > 8'd10; //10us to charge bootstrap capacitor
assign VG = cnt_startup > 8'd14; //10us to charge bootstrap capacitor

// create a RESET signal every time the ENABLE button is turned ON
// and the initialization sequence is terminated
assign ENABLE_RST = ~( VG^VG_PREV );

// --- assign for the control of the Resonant Tank ---      
// either from outside, either from the PI controller
assign   phi_HC   = sw[2] ? phi: phi_PI_sat;

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

// CONTROL PHI + DELTA OF THE RESONANT TANK

hybrid_control_mixed #(.mu_z1(32'd86), .mu_z2(32'd90)
) hybrid_control_mixed_inst (
   .o_MOSFET( MOSFET_theta_phi ),
   .o_sigma(  ),
   .o_debug( debug ),
   .i_clock( clk_100M ),
   .i_RESET( CPU_RESET & ENABLE_RST ),
   .i_vC( ADC_A ),
   .i_iC( ADC_B ),
   .i_ZVS( delta ),
   .i_phi( phi_HC )
);

num2seg num2seg_PHI (
   .o_SEG(SEG_PHI),
   .i_num(phi_HC),
   .i_DP(2'b11)
);

//angle control
// PHI
value_control  #(
   .INTEGER_STEP(5),
   .INTEGER_MIN (0),
   .INTEGER_MAX (90),
   .N_BIT       (8) 
) phi_control (
   .i_CLK(clk_100M),
   .i_RST(button[0]),
   .inc_btn(button[1]),
   .dec_btn(1'b0),
   .count(phi),
   .o_seg0(SEG0_PHI),
   .o_seg1(SEG1_PHI)
);

// DELTA (ZVS)
value_control  #(
   .INTEGER_STEP(1),
   .INTEGER_MIN (0),
   .INTEGER_MAX (40),
   .N_BIT       (8) 
) delta_control (
   .i_CLK(clk_100M),
   .i_RST(sw[0]),
   .inc_btn(button[3] & (~sw[1])),
   .dec_btn(button[3] &   sw[1] ),
   .count(delta),
   .o_seg(SEG_DELTA)
);

// Iref (ZVS)
value_control  #(
   .INTEGER_STEP(5),
   .INTEGER_MIN (6),
   .INTEGER_MAX (100),
   .N_BIT       (8) 
) Iref_control (
   .i_CLK(clk_100M),
   .i_RST(sw[0]),
   .inc_btn(button[2] & (~sw[1])),
   .dec_btn(button[2] &   sw[1] ),
   .count(Iref_dA),
   .o_seg(SEG_IREF)
);




// ----- PI CONTROLLER ----- //

   assign phi_PI = (phi_PI_tmp>>>10) + 32'd50;
   // mA because it has a higher precision
   assign error  = ((Ibat_mA>>7)<<7) + (~(Iref_dA*100)+1);
   assign error_dA = {24'b0,Ibat_DEC} + (~(Iref_dA)+1);


   PI #( 
      .Kp  (3), .shift_Kp (3),
      .TsKi(4), .shift_Ki (8),
      .Kaw (0), .shift_Kaw(0) 
   ) PI_inst(
      .o_PI(phi_PI_tmp),   // output value
      .i_CLK(clk_100k),    // for sequential behavior
      .i_RST(CPU_RESET & ENABLE_RST & sw[0]),  // reset signal
      .err(error),  // input error
      .aw(phi_PI_sat + (~phi_PI+1))      // antiwindup
   );


   saturation #(
      .LOWER_LIMIT(8'd0), 
      .UPPER_LIMIT(8'd70), 
      .N_BIT(8)
   ) sat_PHI(
      .u({phi_PI[31],phi_PI[6:0]}),
      .u_sat(phi_PI_sat),
      .u_dz()
   );

   // WITH THE NEXT LINE IT IS WORKING
   //    hard limit to 63 max for PHI
   // assign phi_PI_sat = phi_PI[5:0];




// +++ DEAD TIME +++ 

   dead_time #(.DEADTIME(80), .N(4)) dead_time_inst_1(
      .o_signal( Q100 ),          // output switching variable
      .i_clock(  clk_100M ),            // for sequential behavior
      .i_signal( MOSFET )
   );
   dead_time #(.DEADTIME(20), .N(4)) dead_time_inst_2(
      .o_signal( Q200 ),          // output switching variable
      .i_clock(  clk_100M ),            // for sequential behavior
      .i_signal( MOSFET )
   );
   dead_time #(.DEADTIME(40), .N(4)) dead_time_inst_4(
      .o_signal( Q400 ),          // output switching variable
      .i_clock(  clk_100M ),            // for sequential behavior
      .i_signal( MOSFET )
   );
   dead_time #(.DEADTIME(60), .N(4)) dead_time_inst_6(
      .o_signal( Q600 ),          // output switching variable
      .i_clock(  clk_100M ),            // for sequential behavior
      .i_signal( MOSFET )
   );

// +++ DEBOUNCE +++ 

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

// +++ START UP counters +++
   // -- counter for the bootstrap and charge the tank
   counter_up counter_up_inst    (
      .o_counter(cnt_startup), // Output of the counter
      .enable( ~VG & ENABLE),  // it start with ENABLE and it stops with VG
      .clk(clk_1M),            // clock Input
      .reset(ENABLE)           // reset Input
   );

// +++ RECTIFIER READING +++
   sensing_Ibat sensing_Ibat_inst(
      .Ibat_ADC(ADC_Ibat),    // ADC measure
      .Ibat_DEC(Ibat_DEC),    // converted measure
      .Ibat_mA(Ibat_mA),      // converted measure
      .SEG_HEX(SEG_Ibat_HEX), // show the acquire HEX number
      .SEG_DEC(SEG_Ibat_DEC)  // show the converted DEC number
   );

   sensing_Vbat sensing_Vbat_inst(
      .Vbat_ADC(ADC_Vbat),    // ADC measure
      .Vbat_DEC(Vbat_DEC),    // converted measure
      .SEG_HEX(SEG_Vbat_HEX), // show the acquire HEX number
      .SEG_DEC(SEG_Vbat_DEC)  // show the comverted DEC number
   );

// +++ ADC +++
   // acquire data from ADC when available
   always @(posedge ADA_DCO) begin
      ADC_A    = ~ADA_DATA+14'b1;
      DAA_copy = ~ADA_DATA+14'b1 + 14'd8191;
   end

   always @(posedge ADB_DCO) begin
      ADC_B    = ~ADB_DATA+14'b1;
      DAB_copy = ~ADB_DATA+14'b1 + 14'd8191;
   end

   always @(negedge ADC_BAT_V_EOC) begin
      ADC_Vbat    = ADC_BAT_V;
   end

   always @(negedge ADC_BAT_I_EOC) begin
      ADC_Ibat    = ADC_BAT_I;
   end

// +++ CONTROLLER MODE +++
   // choose the type of controller
   always  begin
      MOSFET   <= MOSFET_theta_phi;
   end

   always @(posedge clk_100M) begin
      VG_PREV <= VG;
   end

   // choose the deadtime
   always  begin
      case (DSW[3:2])
         2'b00 :  
            Qout <= Q100;
         2'b10 : 
            Qout <= Q200;
         2'b01 :  
            Qout <= Q400;
         2'b11 :  
            Qout <= Q600;
         default:  
            Qout <= 4'b0;
      endcase
   end

// +++ 7-SEGMENTS DISPLAY +++
   // choose what to show on the display
   debug_display debug_display_inst (
      .SEG0(SEG0_reg),
      .SEG1(SEG1_reg),
      .SEL({DSW[7:4],DSW[1:0]}),
      .SEG_A(SEG_IREF),
      .SEG_B(SEG_DELTA),
      .SEG_C(SEG_Vbat_HEX),
      .SEG_D(SEG_Ibat_HEX),
      .SEG_E(SEG_Vbat_DEC),
      .SEG_F(SEG_Ibat_DEC) 
   );


endmodule

