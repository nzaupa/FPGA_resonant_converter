# Modules 

how to nest them


parametric and modular instantiation with `for` loop


```verilog

module debounce #(
      parameter DEBOUNCE_TIME = 5000,
      parameter N = 1
   )(
      output [N-1:0] o_switch,
      input  i_clk,
      input  i_reset,
      input  [N-1:0] i_switch 
   );

   genvar i;

   generate
      for (i = 0; i < N; i = i + 1) begin : DB
         debounce_core  #( .DEBOUNCE_TIME(DEBOUNCE_TIME) ) db_core(
            .o_switch(o_switch[i]),
            .i_clk(i_clk),
            .i_reset(i_reset),
            .i_switch(i_switch[i])
         );
      end
   endgenerate

endmodule
```