# Modules 

## creation

```verilog
module <name> #(PARAM) (port_list)
   ... code ...
endmodule
```


## ports
`module` can have ports, they must be of one of the following type:
- `input`
- `output`
- `inout`
- 

```{note}
ports are considered by default of type `wire`
```

ports type can be defined in the port list or inside the module, not both.

```verilog
module test (
   input [3:0] a,
               b,
   output [7:0] data
);

wire [3:0] a, b;
reg  [7:0] data;

// ... code ...

endmodule

// OR

module test (
   input [3:0] a,
               b,
   output reg [7:0] data
);

// ... code ...

endmodule
```


### ports connection

   can be connected by order or by name.

   What is more robust is by name and is the method we used. This avoids easy mistakes with port order. non connected ports have a high value impedance `Z` by default.


## example
Example of a parametric module with ports. Moreover, it is instantiating a variable number of sub-module with a `for` loop


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
            .o_switch (o_switch[i]),
            .i_clk(i_clk),
            .i_reset (i_reset),
            .i_switch(i_switch[i])
         );
      end
   endgenerate

endmodule
```