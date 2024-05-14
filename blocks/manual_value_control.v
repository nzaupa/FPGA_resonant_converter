//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2024/05/14) (17:51:02)
// File: manual_value_control.v
//------------------------------------------------------------
// Description:
// modules that manage a value through buttons
//------------------------------------------------------------

module value_control #(
   parameter INTEGER_STEP = 1,   // Step size for each button press
   parameter INTEGER_MIN  = 0,   // Minimum count value
   parameter INTEGER_MAX  = 255, // Maximum count value
   parameter INTEGER_RST  = 0,   // Initial count value
   parameter N_BIT        = 8,   // Number of bits of the counter
   parameter DP           = 3
)(
   input              i_CLK,
   input              i_RST,
   input              inc_btn,
   input              dec_btn,
   output [N_BIT-1:0] count,
   output [7:0]       o_seg0,
   output [7:0]       o_seg1,
   output [15:0]      o_seg
);

// Parameters for step size and range

// Internal registers to hold the count value and previous button states
reg [N_BIT-1:0] count_reg;
reg inc_btn_prev, dec_btn_prev;
wire [6:0] segment_0, segment_1;

// Output register
assign count  = count_reg;
assign o_seg0 = o_seg[ 7:0]; //{ 1'b1 , segment_0 };
assign o_seg1 = o_seg[15:8]; //{ 1'b1 , segment_1 };
// assign o_seg  = {o_seg1,o_seg0};

num2seg num2seg_cnt (
   .o_SEG(o_seg),
   .i_num(count_reg),
   .i_DP(DP)
);

initial begin
   count_reg = INTEGER_RST;
end


// Counter logic
always @(posedge i_CLK or negedge i_RST) begin
    if (~i_RST) begin
        count_reg    <= INTEGER_RST;
        inc_btn_prev <= 1'b0;
        dec_btn_prev <= 1'b0;
    end else begin
        // Check for button press and update count
        if (~inc_btn && inc_btn_prev) begin
            if (count_reg + INTEGER_STEP <= INTEGER_MAX)
                count_reg <= count_reg + INTEGER_STEP;
            else
                count_reg <= INTEGER_MAX;
        end
        if (~dec_btn && dec_btn_prev) begin
            if (count_reg - INTEGER_STEP >= INTEGER_MIN)
                count_reg <= count_reg - INTEGER_STEP;
            else
                count_reg <= INTEGER_MIN;
        end
        // Store current button states
        inc_btn_prev <= inc_btn;
        dec_btn_prev <= dec_btn;
    end
end


endmodule

