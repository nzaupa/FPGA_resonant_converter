//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/08/03) (13:25:48)
// File: display_7seg.v
//------------------------------------------------------------
// Description:
// This file contains the modules for interfacing with the 
// 7-segment displays. 
// On Altera DE4, 0 corresponds to segment ON
// 
// hex2seg:
//    transform an exadecimal number to corresponding segments
//    from 0 to F + Z for the dash '-'. it does not manage the
//    decimal point
// 
// dec2hex:
//    take a two digit decimal number and output the corresponding
//    hexadecimal representation which can be then transformed 
//    into the segments to turn ON
// 
// 
//    8bit = {dp,g,f,e,d,c,b,a}
//    
//        ---a---
//       ¦       ¦
//       f       b
//       ¦       ¦
//        ---g--- 
//       ¦       ¦
//       e       c
//       ¦       ¦
//        ---d--- ⨀ dp
// 
//     0    1    2    3    4    5    6    7    8    9
//     _         _    _         _    _    _    _    _  
//    | |    |   _|   _|  |_|  |_   |_     |  |_|  |_| 
//    |_|    |  |_    _|    |   _|  |_|    |  |_|   _| 
//    
//     A    B    C    D    E    F    Z
//     _         _         _    _       
//    |_|  |_   |     _|  |_   |_    _  
//    | |  |_|  |_   |_|  |_   |        
//------------------------------------------------------------

module hex2seg (
   output [6:0] o_seg,
   input  [3:0] i_num
);

always @(i_num) begin
case(i_num)
      4'h0: o_seg <= 7'b1000000;
      4'h1: o_seg <= 7'b1111001;
      4'h2: o_seg <= 7'b0100100;
      4'h3: o_seg <= 7'b0110000;
      4'h4: o_seg <= 7'b0011001;
      4'h5: o_seg <= 7'b0010010;
      4'h6: o_seg <= 7'b0000010;
      4'h7: o_seg <= 7'b1111000;
      4'h8: o_seg <= 7'b0000000;
      4'h9: o_seg <= 7'b0010000;
      4'hA: o_seg <= 7'b0001000;
      4'hB: o_seg <= 7'b0000011;
      4'hC: o_seg <= 7'b1000110;
      4'hD: o_seg <= 7'b0100001;
      4'hE: o_seg <= 7'b0000110;
      4'hF: o_seg <= 7'b0001110;
      default: o_seg <= 7'b0111111; // '-'
endcase
end

endmodule

module dec2hex (
   output [7:0] o_seg,
   input  [7:0] i_dec
);

reg    [7:0] str;
assign o_seg = str;

always @( i_dec ) begin

case(i_dec)
   8'd0  : str = 8'h00;
   8'd1  : str = 8'h01;
   8'd2  : str = 8'h02;
   8'd3  : str = 8'h03;
   8'd4  : str = 8'h04;
   8'd5  : str = 8'h05;
   8'd6  : str = 8'h06;
   8'd7  : str = 8'h07;
   8'd8  : str = 8'h08;
   8'd9  : str = 8'h09;
   8'd10 : str = 8'h10;
   8'd11 : str = 8'h11;
   8'd12 : str = 8'h12;
   8'd13 : str = 8'h13;
   8'd14 : str = 8'h14;
   8'd15 : str = 8'h15;
   8'd16 : str = 8'h16;
   8'd17 : str = 8'h17;
   8'd18 : str = 8'h18;
   8'd19 : str = 8'h19;
   8'd20 : str = 8'h20;
   8'd21 : str = 8'h21;
   8'd22 : str = 8'h22;
   8'd23 : str = 8'h23;
   8'd24 : str = 8'h24;
   8'd25 : str = 8'h25;
   8'd26 : str = 8'h26;
   8'd27 : str = 8'h27;
   8'd28 : str = 8'h28;
   8'd29 : str = 8'h29;
   8'd30 : str = 8'h30;
   8'd31 : str = 8'h31;
   8'd32 : str = 8'h32;
   8'd33 : str = 8'h33;
   8'd34 : str = 8'h34;
   8'd35 : str = 8'h35;
   8'd36 : str = 8'h36;
   8'd37 : str = 8'h37;
   8'd38 : str = 8'h38;
   8'd39 : str = 8'h39;
   8'd40 : str = 8'h40;
   8'd41 : str = 8'h41;
   8'd42 : str = 8'h42;
   8'd43 : str = 8'h43;
   8'd44 : str = 8'h44;
   8'd45 : str = 8'h45;
   8'd46 : str = 8'h46;
   8'd47 : str = 8'h47;
   8'd48 : str = 8'h48;
   8'd49 : str = 8'h49;
   8'd50 : str = 8'h50;
   8'd51 : str = 8'h51;
   8'd52 : str = 8'h52;
   8'd53 : str = 8'h53;
   8'd54 : str = 8'h54;
   8'd55 : str = 8'h55;
   8'd56 : str = 8'h56;
   8'd57 : str = 8'h57;
   8'd58 : str = 8'h58;
   8'd59 : str = 8'h59;
   8'd60 : str = 8'h60;
   8'd61 : str = 8'h61;
   8'd62 : str = 8'h62;
   8'd63 : str = 8'h63;
   8'd64 : str = 8'h64;
   8'd65 : str = 8'h65;
   8'd66 : str = 8'h66;
   8'd67 : str = 8'h67;
   8'd68 : str = 8'h68;
   8'd69 : str = 8'h69;
   8'd70 : str = 8'h70;
   8'd71 : str = 8'h71;
   8'd72 : str = 8'h72;
   8'd73 : str = 8'h73;
   8'd74 : str = 8'h74;
   8'd75 : str = 8'h75;
   8'd76 : str = 8'h76;
   8'd77 : str = 8'h77;
   8'd78 : str = 8'h78;
   8'd79 : str = 8'h79;
   8'd80 : str = 8'h80;
   8'd81 : str = 8'h81;
   8'd82 : str = 8'h82;
   8'd83 : str = 8'h83;
   8'd84 : str = 8'h84;
   8'd85 : str = 8'h85;
   8'd86 : str = 8'h86;
   8'd87 : str = 8'h87;
   8'd88 : str = 8'h88;
   8'd89 : str = 8'h89;
   8'd90 : str = 8'h90;
   8'd91 : str = 8'h91;
   8'd92 : str = 8'h92;
   8'd93 : str = 8'h93;
   8'd94 : str = 8'h94;
   8'd95 : str = 8'h95;
   8'd96 : str = 8'h96;
   8'd97 : str = 8'h97;
   8'd98 : str = 8'h98;
   8'd99 : str = 8'h99;
   default: str = 8'hZ;
endcase

end

endmodule

// left here for compatibility for the moment
module dec2seg (
   output [7:0] o_seg,
   input  [7:0] i_dec
);

reg    [7:0] str;
assign o_seg = str;

always @( i_dec ) begin

case(i_dec)
   8'd0  : str = 8'h00;
   8'd1  : str = 8'h01;
   8'd2  : str = 8'h02;
   8'd3  : str = 8'h03;
   8'd4  : str = 8'h04;
   8'd5  : str = 8'h05;
   8'd6  : str = 8'h06;
   8'd7  : str = 8'h07;
   8'd8  : str = 8'h08;
   8'd9  : str = 8'h09;
   8'd10 : str = 8'h10;
   8'd11 : str = 8'h11;
   8'd12 : str = 8'h12;
   8'd13 : str = 8'h13;
   8'd14 : str = 8'h14;
   8'd15 : str = 8'h15;
   8'd16 : str = 8'h16;
   8'd17 : str = 8'h17;
   8'd18 : str = 8'h18;
   8'd19 : str = 8'h19;
   8'd20 : str = 8'h20;
   8'd21 : str = 8'h21;
   8'd22 : str = 8'h22;
   8'd23 : str = 8'h23;
   8'd24 : str = 8'h24;
   8'd25 : str = 8'h25;
   8'd26 : str = 8'h26;
   8'd27 : str = 8'h27;
   8'd28 : str = 8'h28;
   8'd29 : str = 8'h29;
   8'd30 : str = 8'h30;
   8'd31 : str = 8'h31;
   8'd32 : str = 8'h32;
   8'd33 : str = 8'h33;
   8'd34 : str = 8'h34;
   8'd35 : str = 8'h35;
   8'd36 : str = 8'h36;
   8'd37 : str = 8'h37;
   8'd38 : str = 8'h38;
   8'd39 : str = 8'h39;
   8'd40 : str = 8'h40;
   8'd41 : str = 8'h41;
   8'd42 : str = 8'h42;
   8'd43 : str = 8'h43;
   8'd44 : str = 8'h44;
   8'd45 : str = 8'h45;
   8'd46 : str = 8'h46;
   8'd47 : str = 8'h47;
   8'd48 : str = 8'h48;
   8'd49 : str = 8'h49;
   8'd50 : str = 8'h50;
   8'd51 : str = 8'h51;
   8'd52 : str = 8'h52;
   8'd53 : str = 8'h53;
   8'd54 : str = 8'h54;
   8'd55 : str = 8'h55;
   8'd56 : str = 8'h56;
   8'd57 : str = 8'h57;
   8'd58 : str = 8'h58;
   8'd59 : str = 8'h59;
   8'd60 : str = 8'h60;
   8'd61 : str = 8'h61;
   8'd62 : str = 8'h62;
   8'd63 : str = 8'h63;
   8'd64 : str = 8'h64;
   8'd65 : str = 8'h65;
   8'd66 : str = 8'h66;
   8'd67 : str = 8'h67;
   8'd68 : str = 8'h68;
   8'd69 : str = 8'h69;
   8'd70 : str = 8'h70;
   8'd71 : str = 8'h71;
   8'd72 : str = 8'h72;
   8'd73 : str = 8'h73;
   8'd74 : str = 8'h74;
   8'd75 : str = 8'h75;
   8'd76 : str = 8'h76;
   8'd77 : str = 8'h77;
   8'd78 : str = 8'h78;
   8'd79 : str = 8'h79;
   8'd80 : str = 8'h80;
   8'd81 : str = 8'h81;
   8'd82 : str = 8'h82;
   8'd83 : str = 8'h83;
   8'd84 : str = 8'h84;
   8'd85 : str = 8'h85;
   8'd86 : str = 8'h86;
   8'd87 : str = 8'h87;
   8'd88 : str = 8'h88;
   8'd89 : str = 8'h89;
   8'd90 : str = 8'h90;
   8'd91 : str = 8'h91;
   8'd92 : str = 8'h92;
   8'd93 : str = 8'h93;
   8'd94 : str = 8'h94;
   8'd95 : str = 8'h95;
   8'd96 : str = 8'h96;
   8'd97 : str = 8'h97;
   8'd98 : str = 8'h98;
   8'd99 : str = 8'h99;
   default: str = 8'hZ;
endcase

end

endmodule

// take a 2 digit number and the decimal position
// directly output a string with the two segments
module num2seg (
   output [15:0] o_SEG,
   input   [7:0] i_num,
   input   [1:0] i_DP
);

reg [7:0] num_hex;
assign o_SEG[7] = i_DP[0];
assign o_SEG[15] = i_DP[1];

dec2hex dec2hex_inst (
   .o_seg(num_hex),
   .i_dec(i_num)
);

hex2seg hex2seg_0 (
   .o_seg(o_SEG[6:0]),
   .i_num(num_hex[3:0])
);

hex2seg hex2seg_1 (
   .o_seg(o_SEG[14:8]),
   .i_num(num_hex[7:4])
);


endmodule


