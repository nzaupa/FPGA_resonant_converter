//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/17) (16:53:46)
// File: param_control.v
//------------------------------------------------------------
// Description:
// it generate a square waveform with a choosen frequency 
// and output the value on the 7-segment display
// this specific let us control a parameter with a specific step 
// in the specific we are using it for the frequency
// frequency range : 10kHz -> 100kHz (step 1kHz)
// the 'period'is refered to a clock frequency of 100MHz
//------------------------------------------------------------


module frequency_control (
   o_period,
   o_seg0,
   o_seg1,
   i_reset,
   i_increase1,
   i_decrease1,
   i_increase5,
   i_decrease5
);

output [31:0] o_period;
output [7:0]  o_seg0;
output [7:0]  o_seg1;
input i_reset;
input i_increase1;
input i_decrease1;
input i_increase5;
input i_decrease5;

reg [7:0] frequency;
reg [31:0] period;


wire [7:0] to_seg;
wire [6:0] segment_0, segment_1;

assign o_seg0 = { 1'b0 , segment_0 };
assign o_seg1 = { 1'b1 , segment_1 };

assign o_period = period;

dec2seg dec2seg_inst (
   .o_seg(to_seg),
   .i_dec(frequency)
);

seven_segment seven_segment_0_inst(
   .o_seg(segment_0),
   .i_num(to_seg[3:0])
);

seven_segment seven_segment_1_inst(
   .o_seg(segment_1),
   .i_num(to_seg[7:4])
);

initial begin
   frequency <= 8'd70;
   period = 1000;
end

// // Control the angle from the buttons
// always @( negedge i_reset or negedge i_decrease1 or negedge i_increase1 or negedge i_decrease5 or negedge i_increase5) begin
//    if(~i_reset)
//       frequency <= 8'd70;
//    else begin
//       case({i_decrease1,i_increase1,i_decrease5,i_increase5})
//          // zero is the active button
//          4'b0111: frequency <= frequency + (~8'b1+1); //decrease -1
//          4'b1011: frequency <= frequency + 8'b1;      //increase +1
//          4'b1101: frequency <= frequency + (~8'b0000_0101+1); //decrease -5
//          4'b1110: frequency <= frequency + 8'b0000_0101;      //increase +5
//          default:frequency <= frequency;
//       endcase
//    end
// end

// Control the frequency from the buttons
always @( negedge i_reset or negedge i_decrease1) begin
   if(~i_reset)
      frequency <= 8'd10;
   else if (~i_decrease1)
      frequency <= frequency + 8'd1;
end

// // Control the frequency from the buttons
// always @( negedge i_reset or negedge i_decrease1 or negedge i_decrease5) begin
//    if(~i_reset)
//       frequency <= 8'd10;
//    else 
//       case({i_decrease1,i_decrease5})
//          2'b01: frequency <= frequency + 8'd1;
//          2'b10: frequency <= frequency + 8'd5;
//          default: frequency <= frequency;
//       endcase
// end

// control the limit for the angle in degree
always @( frequency ) begin
   case(frequency)
		8'd010: period = 32'd5000;
		8'd011: period = 32'd4545;
		8'd012: period = 32'd4167;
		8'd013: period = 32'd3846;
		8'd014: period = 32'd3571;
		8'd015: period = 32'd3333;
		8'd016: period = 32'd3125;
		8'd017: period = 32'd2941;
		8'd018: period = 32'd2778;
		8'd019: period = 32'd2632;
		8'd020: period = 32'd2500;
		8'd021: period = 32'd2381;
		8'd022: period = 32'd2273;
		8'd023: period = 32'd2174;
		8'd024: period = 32'd2083;
		8'd025: period = 32'd2000;
		8'd026: period = 32'd1923;
		8'd027: period = 32'd1852;
		8'd028: period = 32'd1786;
		8'd029: period = 32'd1724;
		8'd030: period = 32'd1667;
		8'd031: period = 32'd1613;
		8'd032: period = 32'd1563;
		8'd033: period = 32'd1515;
		8'd034: period = 32'd1471;
		8'd035: period = 32'd1429;
		8'd036: period = 32'd1389;
		8'd037: period = 32'd1351;
		8'd038: period = 32'd1316;
		8'd039: period = 32'd1282;
		8'd040: period = 32'd1250;
		8'd041: period = 32'd1220;
		8'd042: period = 32'd1190;
		8'd043: period = 32'd1163;
		8'd044: period = 32'd1136;
		8'd045: period = 32'd1111;
		8'd046: period = 32'd1087;
		8'd047: period = 32'd1064;
		8'd048: period = 32'd1042;
		8'd049: period = 32'd1020;
		8'd050: period = 32'd1000;
		8'd051: period = 32'd980;
		8'd052: period = 32'd962;
		8'd053: period = 32'd943;
		8'd054: period = 32'd926;
		8'd055: period = 32'd909;
		8'd056: period = 32'd893;
		8'd057: period = 32'd877;
		8'd058: period = 32'd862;
		8'd059: period = 32'd847;
		8'd060: period = 32'd833;
		8'd061: period = 32'd820;
		8'd062: period = 32'd806;
		8'd063: period = 32'd794;
		8'd064: period = 32'd781;
		8'd065: period = 32'd769;
		8'd066: period = 32'd758;
		8'd067: period = 32'd746;
		8'd068: period = 32'd735;
		8'd069: period = 32'd725;
		8'd070: period = 32'd714;
		8'd071: period = 32'd704;
		8'd072: period = 32'd694;
		8'd073: period = 32'd685;
		8'd074: period = 32'd676;
		8'd075: period = 32'd667;
		8'd076: period = 32'd658;
		8'd077: period = 32'd649;
		8'd078: period = 32'd641;
		8'd079: period = 32'd633;
		8'd080: period = 32'd625;
		8'd081: period = 32'd617;
		8'd082: period = 32'd610;
		8'd083: period = 32'd602;
		8'd084: period = 32'd595;
		8'd085: period = 32'd588;
		8'd086: period = 32'd581;
		8'd087: period = 32'd575;
		8'd088: period = 32'd568;
		8'd089: period = 32'd562;
		8'd090: period = 32'd556;
		8'd091: period = 32'd549;
		8'd092: period = 32'd543;
		8'd093: period = 32'd538;
		8'd094: period = 32'd532;
		8'd095: period = 32'd526;
		8'd096: period = 32'd521;
		8'd097: period = 32'd515;
		8'd098: period = 32'd510;
		8'd099: period = 32'd505;
		8'd100: period = 32'd500;
		default: period = 32'd500;
	endcase
end


endmodule