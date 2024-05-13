//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2024/05/10) (10:05:01)
// File: debug.v
//------------------------------------------------------------
// Description:
// File that cointains module useful for debug
// 
// 1. choose what measurement to show i  the 7-segment display
// 
//------------------------------------------------------------




module debug_display (
   output [7:0] SEG0,
   output [7:0] SEG1,
   input  [7:0] DSW,
   input [15:0] digit_phi,
   input [15:0] digit_delta,
   input [15:0] SEG_Vbat_HEX,
   input [15:0] SEG_Ibat_HEX,
   input [15:0] SEG_Vbat_DEC,
   input [15:0] SEG_Ibat_DEC   
);

reg [7:0] SEG0_reg, SEG1_reg;
   
assign SEG0 = SEG0_reg;
assign SEG1 = SEG1_reg;

always  begin
   case (DSW)
      8'b000001 : begin // PHI
         SEG0_reg <= digit_phi[ 7:0];
         SEG1_reg <= digit_phi[15:8];
      end
      8'b000010 : begin // DEADTIME
         SEG0_reg <= digit_delta[ 7:0];
         SEG1_reg <= digit_delta[15:8];
      end
      8'b000100 : begin // Vbat HEX
         SEG0_reg <= SEG_Vbat_HEX[ 7:0];
         SEG1_reg <= SEG_Vbat_HEX[15:8];
      end
      8'b001000 : begin // Ibat HEX
         SEG0_reg <= SEG_Ibat_HEX[ 7:0];
         SEG1_reg <= SEG_Ibat_HEX[15:8];
      end
      8'b010000 : begin // Vbat DEC
         SEG0_reg <= SEG_Vbat_DEC[ 7:0];
         SEG1_reg <= SEG_Vbat_DEC[15:8];
      end
      8'b100000 : begin // Ibat DEC
         SEG0_reg <= SEG_Ibat_DEC[ 7:0];
         SEG1_reg <= SEG_Ibat_DEC[15:8];
      end
      default: begin // shows '--'
         SEG0_reg <= 8'b10111111;
         SEG1_reg <= 8'b10111111;
      end
   endcase
end

endmodule



module debug_display_new (
   output [7:0] SEG0,
   output [7:0] SEG1,
   input  [7:0] SEL,
   input [15:0] SEG_A,
   input [15:0] SEG_B,
   input [15:0] SEG_C,
   input [15:0] SEG_D,
   input [15:0] SEG_E,
   input [15:0] SEG_F,   
   input [15:0] SEG_G,  
   input [15:0] SEG_H   
);

reg [15:0] SEG_reg;
   
assign SEG0 = SEG_reg[ 7:0];
assign SEG1 = SEG_reg[15:8];

always  begin
   case (SEL)
      8'b00000001 : begin // PHI
         SEG_reg <= SEG_A;
      end
      8'b00000010 : begin // DEADTIME
         SEG_reg <= SEG_B;
      end
      8'b00000100 : begin // Vbat HEX
         SEG_reg <= SEG_C;
      end
      8'b00001000 : begin // Ibat HEX
         SEG_reg <= SEG_D;
      end
      8'b00010000 : begin // Vbat DEC
         SEG_reg <= SEG_E;
      end
      8'b00100000 : begin // Ibat DEC
         SEG_reg <= SEG_F;
      end
      8'b01000000 : begin // Ibat DEC
         SEG_reg <= SEG_G;
      end
      8'b10000000 : begin // Ibat DEC
         SEG_reg <= SEG_H;
      end
      default: begin // shows '--'
         SEG_reg <= 16'b10111111_10111111;
      end
   endcase
end

endmodule




