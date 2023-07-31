//------------------------------------------------------------
// Project: HYBRID_CONTROL_PHI
// Author: Nicola Zaupa
// Date: (2022/02/03) (11:18:47)
// File: phi_control.v
//------------------------------------------------------------
// Description:
//
// enable to adjust the value of phi from the buttons
//------------------------------------------------------------

module phi_control (
   o_seg0,
   o_seg1,
   o_phi32,
   i_reset,
   i_increase,
   i_decrease
);

output [7:0]  o_seg0;
output [7:0]  o_seg1;
output [31:0] o_phi32;
input i_reset;
input i_increase;
input i_decrease;


reg  [8:0] angle, angle_sat;
wire [7:0] to_seg;
wire [6:0] segment_0, segment_1;
wire CLK;
// reg  [31:0] phi;

assign o_seg0 = { 1'b1 , segment_0 };
assign o_seg1 = { 1'b1 , segment_1 };
assign o_phi32 = angle_sat; // deg;
// assign o_phi32 = (angle_sat*32'd1787)>>10; // rad;

// assign phi = (angle_sat*32'd1787)>>10;

dec2seg dec2seg_inst (
   .o_seg(to_seg),
   .i_dec(angle_sat)
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
   angle_sat = 9'd0;
end

// always @( negedge i_reset or negedge i_decrease) begin
//    if (~i_reset) begin
//       counter <= 5'b0;
//    end else begin
//       if (~i_increase) begin
//          angle <= angle_sat + 9'd5;
//       end else begin
//          if (~i_decrease) begin
//             angle <= angle_sat + (~9'd5+1);
//          end
//       end
//    // end
// end

// Control the angle from the buttons
always @( negedge i_reset or negedge i_decrease  ) begin
   if (~i_reset)
      angle <= 9'd0;
   else if (~i_decrease)
      angle <= angle_sat + 9'd20;
end

// // Control the angle from the buttons
// always @( negedge i_reset or negedge i_decrease or negedge i_increase ) begin
//    if (~i_reset) begin
//       angle <= 9'd45;
//    end else begin
//       if (~i_increase) begin
//          angle <= angle_sat + 9'd5;
//       end else begin
//          if (~i_decrease) begin
//             angle <= angle_sat + (~9'd5+1);
//          end
//       end
//    end
// end

// control the limit for the angle in degree
always @( * ) begin
   if (angle>9'd90 & angle<9'd120)
      angle_sat <= 0;
   else if (angle[8])
      angle_sat <= 9'd90;
   else
      angle_sat <= angle;
end

// always @(angle_sat) begin
//    phi <= (angle_sat*32'd1787)>>10; // from deg to rad
// end


endmodule