//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/01/19) (23:11:22)
// File: TOP_ResonantConverter_control.v
//------------------------------------------------------------
// Description:
// testbench code to test the control behavior
//------------------------------------------------------------



`timescale 1 ns / 1 ps
//`default_nettype none


module tb_TOP_ResonantConverter_control;

//=======================================================
//  REG/WIRE declarations
//=======================================================

reg     clk_main;
reg     clk_10;

//=======================================================
//  Structural coding
//=======================================================
TOP_ResonantConverter_control_MS TOP(
   //clock + reset
   .OSC(clk_main),
   .OSC_10M (clk_10)
   // .CPU_RESET(1'b1),
   // .EXT_RESET(1'b1),
   // .ADA_DATA(14'b0),
   // .ADB_DATA(14'b0),
   // .ADA_OR(1'b0),
   // .ADB_OR(1'b0),
   // .AD_SCLK(1'b0),
   // .AD_SDIO(1'b0),
   // .ADA_OE(1'b0),
   // .ADA_SPI_CS(1'b0),
   // .ADB_OE(1'b0),
   // .ADB_SPI_CS(1'b0),
   // .FPGA_CLK_A_N(1'b0),
   // .FPGA_CLK_A_P(1'b0),
   // .FPGA_CLK_B_N(1'b0),
   // .FPGA_CLK_B_P(1'b0),
   // //output bridge signal
   // .Q_POS(),
   // .Q_NEG(),
   // //debugging
   // .SW(4'b0001),      // switches on the main board
   // .LED(),     // LEDs on the main board
   // .LED_R(),   // red LEDs on the adaptor
   // .LED_G(),   // green LEDs on the adaptor
   // .VCC(),     // VCC connections for LEDs
   // .TB1(),
   // .TB2(),
   // .TB3()
);

always
   begin
      clk_main = 1'b1;
      #1.666
      clk_main = 1'b0;
      #1.666;
end

always
   begin
      clk_10 = 1'b1;
      #50
      clk_10 = 1'b0;
      #50;
end


endmodule




