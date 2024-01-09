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


## Converter Simulator
The objective is to have some blocks able to simulate, i.e. compute the next value, the current and voltage in a resonant convert. These values are used to test the part in a more realistic scenario.


### SRC simulator
The dynamics equations governing the SRC are the following

```{math}
:label: eq:SRC
\begin{align}
   \frac{ {\rm d} v_C}{{\rm d} t} &= \frac{1}{C} i_S \\
   \frac{ {\rm d} i_S}{{\rm d} t} &= \frac{1}{L} \left( V_g\sigma-v_C-v_o \right) \\
   \frac{ {\rm d} v_o}{{\rm d} t} &= -\frac{R_{eq}}{L} \left( v_C-V_g\sigma - \left( 1+\frac{L}{L_m} \right) v_o\right)
\end{align}
```


### LLC simulator




