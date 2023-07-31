//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/01/27) (23:16:45)
// File: seven_segment.v
//------------------------------------------------------------
// Description:
//
// return the 7bit number corresponding to the hexadecimal input number
//------------------------------------------------------------

module seven_segment (
   o_seg,
   i_num
);

output [6:0]  o_seg;
input  [3:0]  i_num;

reg [6:0] str;
assign o_seg = str;

always @(i_num) begin
case(i_num)
      4'h0: str = 7'b1000000;
      4'h1: str = 7'b1111001;
      4'h2: str = 7'b0100100;
      4'h3: str = 7'b0110000;
      4'h4: str = 7'b0011001;
      4'h5: str = 7'b0010010;
      4'h6: str = 7'b0000010;
      4'h7: str = 7'b1111000;
      4'h8: str = 7'b0000000;
      4'h9: str = 7'b0010000;
      4'hA: str = 7'b0001000;
      4'hB: str = 7'b0000011;
      4'hC: str = 7'b1000110;
      4'hD: str = 7'b0100001;
      4'hE: str = 7'b0000110;
      4'hF: str = 7'b0001110;
      default: str = 7'b1111111;
endcase
end

endmodule