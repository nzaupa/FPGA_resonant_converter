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
reg  [3:0] MOSFET;
wire [3:0] MOSFET_theta_z, MOSFET_theta_x, MOSFET_phi, MOSFET_delta;

// ADCs and DACs
reg signed [13:0] ADC_A, ADC_B;
reg        [13:0] DAA_copy, DAB_copy;

// rectifier
reg  [7:0]  ADC_Vbat, ADC_Ibat;
wire [7:0]  Vbat_DEC, Ibat_DEC;
wire [15:0] SEG_Vbat_HEX, SEG_Ibat_HEX, SEG_Vbat_DEC, SEG_Ibat_DEC;


reg  [7:0] deadtime = 8'd5;
wire [7:0] cnt_startup;
wire [7:0] cnt_Vg;
// reg  [7:0] cnt_startup_reg;


wire  [31:0] debug;
wire  [1:0]  test;

wire [31:0] phi;
wire [31:0] delta;
wire [31:0] theta_z;
wire [31:0] theta_x;
// wire [31:0] phi_HC;
// wire [31:0] theta_HC;


wire [1:0] sigma; // internal state

wire  [7:0] SEG0_dsw, SEG1_dsw;
reg  [15:0] SEG_ctrl;

wire [15:0] SEG_DELTA, SEG_PHI, SEG_THETA_z, SEG_THETA_x;
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

   // assign SEG0 = SEG0_dsw;
   // assign SEG1 = SEG1_dsw;
   assign SEG0 = ~sw[3] ? SEG_ctrl[ 7:0] : SEG0_dsw; //SEG0_dsw;
   assign SEG1 = ~sw[3] ? SEG_ctrl[15:8] : SEG1_dsw; //SEG1_dsw;

   // connected to GPIO1 and available on the rectifier board
   // all are available on the 2×6 connector, 6 of them are connected to LEDs
   //CO: 22/12/23 update ex bits
   assign EX[0]  =  SW[3];      // over voltage
   assign EX[1]  = ~SW[3];      // over current
   assign EX[2]  = ENABLE;      // H-bridge ENABLE
   assign EX[3]  = debug[2];    // Pin 4 D0
   assign EX[4]  = debug[3];    // Pin 5 D1
   assign EX[5]  = debug[8]; //VG;          // Pin 6 D2  M1_delayed
   assign EX[6]  = debug[9]; //ON;          // Pin 7 D3  M1
   assign EX[7]  = test[0];     // Pin 8 D4  b0
   assign EX[8]  = test[1];     // Pin 9 D5  b1
   assign EX[9]  = debug[14];   // Pin 10 ?
   assign EX[10] = debug[15];   // Pin 11 D6
   assign EX[11] = ENABLE;      // Pin 12 D7  (and LED 1)

   assign GPIO0[18] = Q[0]; //Q1;   // D12
   assign GPIO0[20] = Q[1]; //Q2;   // D13
   assign GPIO0[22] = Q[2]; //Q3;   // D14
   assign GPIO0[24] = Q[3]; //Q4;   // D15

   // connected to GPIO0
   // debug for Ci signals
   assign GPIO0[10] = ADC_B[13]; // D8   iC sign
   assign GPIO0[12] = debug[2]; // D9    S0
   assign GPIO0[14] = debug[3]; // D10   S1
   assign GPIO0[16] = debug[0]; // D11   b0
   // assign GPIO0[10] = debug[4]; // D8 
   // assign GPIO0[12] = debug[5]; // D9 
   // assign GPIO0[14] = debug[6]; // D10
   // assign GPIO0[16] = debug[7]; // D11

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
assign VG = cnt_startup > 8'd16; //10us to charge bootstrap capacitor

// create a RESET signal every time the ENABLE button is turned ON
// and the initialization sequence is terminated
assign ENABLE_RST = ~( VG^VG_PREV );



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
//    3. delta+phi  --> mixte modulation ensuring ZVS

// control law THETA in z
hybrid_control_theta_z #(.mu_z1(32'd160), .mu_z2(32'd90), .mu_Vg(32'd312000)
) HC_theta_z (
   .o_MOSFET( MOSFET_theta_z ),   // control signal for the four MOSFETs
   .o_sigma(  ),          // output switching variable
   .o_debug(  ),          // [16bit]
   .i_clock( clk_100M ),  // for sequential behavior
   .i_RESET( CPU_RESET & ENABLE_RST ), // reset signal
   .i_vC( ADC_A ),        // [14bit-signed] input related to z1
   .i_iC( ADC_B ),        // [14bit-signed] input related to z2
   .i_theta( theta_z )     // [32bit-signed] angle of the switching surface
);

// hybrid_control_theta HC_theta_inst (
//    .o_MOSFET( MOSFET_theta ),   // control signal for the four MOSFETs
//    .o_sigma(  ),          // output switching variable
//    .o_debug(  ),          // [16bit]
//    .i_clock( clk_100M ),  // for sequential behavior
//    .i_RESET( CPU_RESET ), // reset signal
//    .i_vC( ADC_A ),        // [14bit-signed] input related to z1
//    .i_iC( ADC_B ),        // [14bit-signed] input related to z2
//    .i_theta( theta )     // [32bit-signed] angle of the switching surface
// );

// control law THETA in x
hybrid_control_mixed #(.mu_x1(32'd160), .mu_x2(32'd90)
) HC_theta_x (
   .o_MOSFET( MOSFET_theta_x ),  // control signal for the four MOSFETs
   .o_sigma(  ),         // 2 bit for signed sigma -> {-1,0,1}
   .o_debug(  ),   
   .i_clock( clk_100M ),
   .i_RESET( CPU_RESET & ENABLE_RST ),   
   .i_vC( ADC_A ),      
   .i_iC( ADC_B ),      
   .i_delta( delta),    
   // .i_delta( 32'd180 + (~theta_x) + 1 ),    
   .i_phi( 32'd0 ),      
   .i_sigma( ) 
);

// control law PHI
hybrid_control_phi_x #(.mu_x1(32'd160), .mu_x2(32'd90)
) HC_phi (
   .o_MOSFET( MOSFET_phi ),  // control signal for the four MOSFETs
   .o_sigma(  ),         // 2 bit for signed sigma -> {-1,0,1}
   .o_debug( ),    // ? random currently
   .i_clock( clk_100M ), // ADA_DCO
   .i_RESET( CPU_RESET & ENABLE_RST ),    //
   .i_vC( ADC_A ),       //
   .i_iC( ADC_B ),       //
   .i_phi( phi )     // phi // pi/4 - 32'h0000004E
);


// control law PHI + DELTA
hybrid_control_mixed #(.mu_x1(32'd160), .mu_x2(32'd90)
) HC_delta (
   .o_MOSFET( MOSFET_delta ),  // control signal for the four MOSFETs
   .o_sigma(  ),         // 2 bit for signed sigma -> {-1,0,1}
   .o_debug(  ),   
   .i_clock( clk_100M ),
   .i_RESET( CPU_RESET & ENABLE_RST ),   
   .i_vC( ADC_A ),      
   .i_iC( ADC_B ),      
   .i_delta( delta ),    
   .i_phi( phi ),      
   .i_sigma( ) 
);

// ---------------------------------
// ----- control of the angles -----
// ---------------------------------
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
         .dec_btn(button[2]),
         .count(phi),
         .o_seg(SEG_PHI)
      );

   // DELTA (ZVS)
      value_control  #(
         .INTEGER_STEP(1),
         .INTEGER_MIN (0),
         .INTEGER_MAX (180),
         .N_BIT       (8) 
      ) delta_control (
         .i_CLK(clk_100M),
         .i_RST(CPU_RESET),
         .inc_btn(button[3]),
         .dec_btn(1'b0),
         .count(delta),
         .o_seg(SEG_DELTA)
      );

   // THETA in z-plane
      value_control  #(
         .INTEGER_STEP(5),
         .INTEGER_MIN (10),
         .INTEGER_MAX (180),
         .INTEGER_RST (180),
         .N_BIT       (8),
         .DP          (2'b10),
         .SHIFT       (1)
      ) theta_z_control (
         .i_CLK(clk_100M),
         .i_RST(button[0]),
         .inc_btn(button[1]),
         .dec_btn(button[2]),
         .count(theta_z),
         .o_seg(SEG_THETA_z)
      );

   // THETA in x-plane
      value_control  #(
         .INTEGER_STEP(5),
         .INTEGER_MIN (90),
         .INTEGER_MAX (180),
         .INTEGER_RST (180),
         .N_BIT       (8),
         .DP          (2'b10),
         .SHIFT       (1)
      ) theta_x_control (
         .i_CLK(clk_100M),
         .i_RST(button[0]),
         .inc_btn(button[1]),
         .dec_btn(button[2]),
         .count(theta_x),
         .o_seg(SEG_THETA_x)
      );

// +++ SEQUENTIAL BEHAVIOR +++
   always @(posedge clk_100M) begin
      VG_PREV <= VG;
   end

// +++ DEAD-TIME +++ //


   dead_time #(.DEADTIME(10), .N(4)) dead_time_inst_1(
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

// +++ DEBOUNCE +++ //

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

// +++ START-UP counter +++
   // -- counter for the bootstrap and charge the tank
   counter_up counter_up_inst    (
      .o_counter(cnt_startup), // Output of the counter
      .enable( ~VG & ENABLE),  // enable for counter, it stops when VG is active
      .clk(clk_1M),            // clock Input
      .reset(ENABLE)           // reset Input
   );

// +++ RECTIFIER DEBUG +++
   sensing_Ibat sensing_Ibat_inst(
      .Ibat_ADC(ADC_Ibat),    // ADC measure
      .Ibat_DEC(Ibat_DEC),    // converted measure
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
      // ADC_A    = ~ADA_DATA+14'b1;
      // DAA_copy = ~ADA_DATA+14'b1 + 14'd8191;
      if (ADA_OR) begin
         // we are in over-range
         if (ADA_DATA==14'h2000) begin
            ADC_A <= 14'h1FFF;
         end else begin
            ADC_A <= 14'h2000;
         end
      end else begin
         // inverse the polarity since it is inverted in the {CB}
         ADC_A <= ~ADA_DATA+14'b1;
      end

      DAA_copy = ~ADA_DATA+14'b1 + 14'd8191;
   end

   always @(posedge ADB_DCO) begin
      ADC_B    = ~ADB_DATA+14'b1;
      DAB_copy = ~ADB_DATA+14'b1 + 14'd8191;
   end

   LPF LPF_vC(
      .o_mean(vC_filt),
      .i_clock(clk_100k),
      .i_RESET(CPU_RESET),
      .i_data(ADC_A)
   );
   LPF LPF_iC(
      .o_mean(iC_filt),
      .i_clock(clk_100k),
      .i_RESET(CPU_RESET),
      .i_data(ADC_B)
   );

   always @(negedge ADC_BAT_V_EOC) begin
      ADC_Vbat    = ADC_BAT_V;
   end

   always @(negedge ADC_BAT_I_EOC) begin
      ADC_Ibat    = ADC_BAT_I;
   end

// +++ CONTROLLER MODE +++
   // choose the type of controller
   always  begin
      case (sw[2:1])
         2'b00 : begin // PHI+THETA
            MOSFET   <= MOSFET_delta;
            SEG_ctrl <= SEG_PHI;
         end
         2'b01 : begin  // THETA in z
            MOSFET   <= MOSFET_theta_z;
            SEG_ctrl <= SEG_THETA_z;
         end
         2'b10 : begin // THETA in x
            MOSFET   <= MOSFET_theta_x;
            SEG_ctrl <= SEG_DELTA;
         end
         2'b11 : begin // PHI
            MOSFET   <= MOSFET_phi;
            SEG_ctrl <= SEG_PHI;
         end
         default: begin // shows '--'
            MOSFET   <= 4'b0;
            SEG_ctrl <= 16'b10111111_10111111;
         end
      endcase
   end

// choose the deadtime
   always  begin
      case (DSW[3:2])
         2'b00 : begin // PHI+THETA
            Qout <= Q100;
         end
         2'b10 : begin  // THETA
            Qout <= Q200;
         end
         2'b01 : begin // PHI
            Qout <= Q400;
         end
         2'b11 : begin // PHI
            Qout <= Q600;
         end
         default: begin // shows '--'
            Qout <= 4'b0;
         end
      endcase
   end

// +++ 7-SEGMENTS DISPLAY +++
   // choose what to show on the display
   debug_display debug_display_inst (
      .SEG0(SEG0_dsw),
      .SEG1(SEG1_dsw),
      .SEL({DSW[7:4],DSW[1:0]}),
      .SEG_A(SEG_DELTA),
      .SEG_B(SEG_DELTA),
      .SEG_C(SEG_Vbat_HEX),
      .SEG_D(SEG_Ibat_HEX),
      .SEG_E(SEG_Vbat_DEC),
      .SEG_F(SEG_Ibat_DEC) 
   );


endmodule

