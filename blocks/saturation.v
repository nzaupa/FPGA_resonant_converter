//------------------------------------------------------------
// Project: HYBRID_CONTROL
// Author: Nicola Zaupa
// Date: (2024/05/14) (14:23:45)
// File: saturation.v
//------------------------------------------------------------
// Description:
// ...
//------------------------------------------------------------



//------------------------------------------------------------
// Description:
// This modules implements a saturation element.
// If the input value exceed the limits, 
// it is clamped to the extreme
//
// signed or unsigned, this is the real question
// it depends on where are the saturation limits
// we can limit to the case where we know that UPPER and LOWER
// are positive values
// ------------------------------------------------------------


// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// this module is working perfectly with positive numbers
module saturation_positive #(
   parameter UPPER_LIMIT = 100,
   parameter LOWER_LIMIT = 0,
   parameter N_BIT = 32
) (
   input  [N_BIT-1:0] u,     // input      - u
   output [N_BIT-1:0] u_sat, // saturation - sat(u)
   output [N_BIT  :0] u_dz   // dead-zone  - dz(u) = u - sat(u)
);

// in general the dead-zone can be negative, that is why we 
// consider one bit more with respect the other numbers there 
// are considered positive on their full scale

reg [N_BIT-1:0] u_sat_reg;

assign u_sat = u_sat_reg;
assign u_dz  = u + (~u_sat+1);

always @(u) begin
   if (u>UPPER_LIMIT) begin
      u_sat_reg <= UPPER_LIMIT;
   end
   else if (u<LOWER_LIMIT) begin
      u_sat_reg <= LOWER_LIMIT;
   end
   else begin
      u_sat_reg <= u;
   end
end

endmodule




// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// this module is considering signed number
// but the limits are considered to be positive
// this is workin good 
module saturation #(
   parameter UPPER_LIMIT = 100,
   parameter LOWER_LIMIT = 0,
   parameter N_BIT = 32
) (
   input  [N_BIT-1:0] u,     // u
   output [N_BIT-1:0] u_sat, // sat(u)
   output [N_BIT-1:0] u_dz   // dz(u) = u - sat(u)
);

reg [N_BIT-1:0] u_sat_reg;

assign u_sat = u_sat_reg;
assign u_dz  = u + (~u_sat+1);

always @(u) begin
   if (~u[N_BIT-1]) begin
      // if the number is positive
      if (u>=UPPER_LIMIT) begin
         u_sat_reg <= UPPER_LIMIT;
      end
      else if (u<=LOWER_LIMIT) begin
         u_sat_reg <= LOWER_LIMIT;
      end
      else begin
         u_sat_reg <= u;
      end
   end else begin
      // the number is negative
      u_sat_reg <= LOWER_LIMIT;
   end
   
end

endmodule
