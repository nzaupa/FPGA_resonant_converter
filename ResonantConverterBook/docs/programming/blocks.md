# Modules

Here we introduce the models that has been created in order to deal with the programming and repetitive/similar tasks.



```verilog
module debounce_core #(
      parameter DEBOUNCE_TIME = 5000
   )(
      output o_switch,
      input  i_clk,
      input  i_reset,
      input  i_switch
   );
```


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

```


