//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/02/07) (17:27:45)
// File: dec2seg.v
//------------------------------------------------------------
// Description:
//
// transform a hexadecimal single number into the corresponding 
// rapresentation for a 7-segment display
//------------------------------------------------------------

module dec2seg (
   o_seg,
   i_dec
);

output [7:0]  o_seg;
input  [7:0]  i_dec;

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
   default: str = 8'h00;
endcase

end

endmodule