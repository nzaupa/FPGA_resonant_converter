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




