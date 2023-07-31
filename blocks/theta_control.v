//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2021/02/07) (19:16:45)
// File: theta_control.v
//------------------------------------------------------------
// Description:
//
// enable to adjust the value of theta from the buttons
//------------------------------------------------------------

module theta_control (
   o_seg0,
   o_seg1,
   o_theta32,
   i_reset,
   i_increase,
   i_decrease
);

output [7:0]  o_seg0;
output [7:0]  o_seg1;
output [31:0] o_theta32;
input i_reset;
input i_increase;
input i_decrease;


reg  signed [8:0] angle, angle_sat;
wire [7:0] to_seg;
wire [6:0] segment_0, segment_1;
// reg  [31:0] theta;

assign o_seg0 = { ~angle_sat[0] , segment_0 };
assign o_seg1 = {      1'b1     , segment_1 };
assign o_theta32 = angle_sat;  // deg
// assign o_theta32 = (angle_sat*32'sd1787)>>10; // rad





dec2seg dec2seg_inst (
   .o_seg(to_seg),
   .i_dec(angle_sat>>1)
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
   angle_sat = 9'sd180;
end

// Control the angle from the buttons
always @( negedge i_reset or negedge i_decrease or negedge i_increase ) begin
   if (~i_reset) begin
      angle <= 9'sd180;
   end else begin
      if (~i_increase) begin
         angle <= angle_sat+9'sd5;
      end else begin
         if (~i_decrease) begin
            angle <= angle_sat+(~9'sd5+9'sd1);
         end
      end
   end
end

// control the limit for the angle in degree
// always @( angle ) begin
//    if (angle>9'sd180)
//       angle_sat <= 9'sd5;
//    else if (angle<9'sd5)
//       angle_sat <= 9'sd180;
//    else
//       angle_sat <= angle;
// end

// control the limit for the angle in degree
always @( angle ) begin
   if (angle>9'sd180)
      angle_sat <= 9'sd30;
   else if (angle<9'sd30)
      angle_sat <= 9'sd180;
   else
      angle_sat <= angle;
end


endmodule