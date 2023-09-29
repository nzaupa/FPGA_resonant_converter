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


// The idea is to create a unique module that is able to manage
// manual variation of a value in an interval
// possible parameters:
//    - MIN
//    - MAX 
//    - V0 (initial value)
//    - STEP
// signals:
//    - UP
//    - DOWN
//    - RESET
//    - output



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



//------------------------------------------------------------
// Project: HYBRID_CONTROL_PHI
// Author: Nicola Zaupa
// Date: (2022/02/15) (12:47:08)
// File: angle_control_theta_phi.v
//------------------------------------------------------------
// Description:
//
// enable to adjust the value of phi from the buttons
//------------------------------------------------------------

module angle_control_theta_phi (
   o_seg0,
   o_seg1,
   o_theta,
   o_phi,
   i_reset,
   i_step_theta,
   i_step_phi
);

output [7:0]  o_seg0;
output [7:0]  o_seg1;
output [31:0] o_theta;
output [31:0] o_phi;
input i_reset;
input i_step_theta;
input i_step_phi;


reg  [8:0] theta, phi, theta_sat, phi_sat;
// wire [7:0] to_seg;
wire [6:0] segment_0, segment_1;
wire CLK;
// reg  [31:0] phi;

reg [4:0] cnt_phi, cnt_theta;

// assign o_seg0 = { ~cnt_phi[4]   , segment_0 };
// assign o_seg1 = { ~cnt_theta[4] , segment_1 };

assign o_seg0 = { ~phi[0]   , segment_0 };
assign o_seg1 = { ~theta[0] , segment_1 };


assign o_phi   = ( phi *32'd1787) >> 10; //phi;
assign o_theta = (theta*32'd1787) >> 10; //phi;


seven_segment seven_segment_0_inst(
   .o_seg(segment_0),
   .i_num(cnt_phi[3:0])
);

seven_segment seven_segment_1_inst(
   .o_seg(segment_1),
   .i_num(cnt_theta[3:0])
);

initial begin
   // theta_sat     = 9'd180;
   theta         = 9'd180;
   // phi_sat       = 9'd0;
   phi           = 9'd0;
   cnt_phi   = 0;
   cnt_theta = 0;
end


// Control the angle from the buttons
always @( negedge i_reset or negedge i_step_theta  ) begin
   if (~i_reset) begin
      theta     <= 9'd180;
      cnt_theta <= 0;
   end
   else if (~i_step_theta) begin
      theta     <= theta + (~9'd5+1);
      cnt_theta <= cnt_theta + 1;
   end
end

always @( negedge i_reset or negedge i_step_phi  ) begin
   if (~i_reset) begin
      phi     <= 9'd0;
      cnt_phi <= 0;
   end
   else if (~i_step_phi) begin
      phi     <= phi + 9'd2;
      cnt_phi <= cnt_phi + 1;
   end
end



// control the limit for the angle in degree
// always @( * ) begin
//    // if (theta<9'd30 & theta>9'h0FF)
//    //    theta_sat <= 9'd180;
//    // else
//       theta_sat <= theta;
// end

// always @( * ) begin
//    if (phi>9'd90)
//       phi_sat <= 9'd90;
//    else
//       phi_sat <= phi;
// end

// always @(angle_sat) begin
//    phi <= (angle_sat*32'd1787)>>10; // from deg to rad
// end


endmodule