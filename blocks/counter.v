//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2023/07/27) (02:14:33)
// File: counter.v
//------------------------------------------------------------
// Description:
// ...
//------------------------------------------------------------

module counter_up    (
   output [7:0] o_counter, // Output of the counter
   input        enable,    // enable for counter
   input        clk,       // clock Input
   input        reset      // reset Input
);

//------------Internal Variables--------
reg [7:0] cnt;
assign o_counter = cnt;
//-------------Code Starts Here-------
always @(posedge clk or negedge reset)
   if (~reset) 
      cnt <= 8'b0 ;
   else if (enable)
      cnt <= cnt + 8'b1;
   


endmodule 


// module behav_counter( d, clk, clear, load, up_down, qd);

// // Port Declaration

// input   [7:0] d;
// input   clk;
// input   clear;
// input   load;
// input   up_down;
// output  [7:0] qd;

// reg     [7:0] cnt;

// always @ (posedge clk)
// begin
//     if (!clear)
//         cnt <= 8'h00;
//     else if (load)
//         cnt <= d;
//     else if (up_down)
//         cnt <= cnt + 1;
//     else
//         cnt <= cnt - 1;
// end 
 
 
//  assign qd = cnt;



// endmodule