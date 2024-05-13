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
   input  [7:0] DSW

);
   

always  begin
   case (DSW[7:0])
      8'b00000001 : begin // PHI
         SEG0_reg <= digit_0_phi;
         SEG1_reg <= digit_1_phi;
      end
      8'b00000010 : begin // ZVS
         SEG0_reg <= digit_0_theta;
         SEG1_reg <= digit_1_theta;
      end
      8'b00000100 : begin // DEADTIME
         SEG0_reg <= digit_0_phi;
         SEG1_reg <= digit_1_phi;
      end
      8'b00010000 : begin // Vbat HEX
         SEG0_reg <= SEG_Vbat_HEX[ 7:0];
         SEG1_reg <= SEG_Vbat_HEX[15:8];
      end
      8'b00100000 : begin // Ibat HEX
         SEG0_reg <= SEG_Ibat_HEX[ 7:0];
         SEG1_reg <= SEG_Ibat_HEX[15:8];
      end
      8'b01000000 : begin // Vbat DEC
         SEG0_reg <= SEG_Vbat_DEC[ 7:0];
         SEG1_reg <= SEG_Vbat_DEC[15:8];
      end
      8'b10000000 : begin // Ibat DEC
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




