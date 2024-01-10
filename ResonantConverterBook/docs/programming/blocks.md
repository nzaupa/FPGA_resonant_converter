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


### LLC simulator
We can model the part before the rectifier considering an equivalent resistor as load. This is reasonable since the input current and voltage of the rectifier are in-phase.
The three state that we chose to describe the system are $(v_C,i_S,v_o)$, the dynamical equations are:are

```{math}
:label: eq:SRC
\begin{align}
   \frac{ {\rm d} v_C}{{\rm d} t} &= \frac{1}{C} i_S \\
   \frac{ {\rm d} i_S}{{\rm d} t} &= \frac{1}{L} \left( V_g\sigma-v_C-v_o \right) \\
   \frac{ {\rm d} v_o}{{\rm d} t} &= -\frac{R_{eq}}{L} \left( v_C-V_g\sigma + \left( 1+\frac{L}{L_m} \right) v_o\right)
\end{align}
```

Now, we want to move toward a digital implementation of a module that can simulate the behavior, i.e. integrate the differential equations. Since it is quite a simple dynamics, we can rely on explicit Euler integration scheme:

```{math}
:label: eq:Euler
\begin{equation}
   \dot x = f(x) \quad\rightarrow\quad x^{k+1}=x^k+\delta_t f(x^k)
\end{equation}
```

Moreover, in the FPGA we can only work (in our setting) with integer numbers, therefore we need to ensure sufficient precision to not lose too much information. With this is mind, we apply the following modifications:
- All the parameters are described by integers. 
- The states are described by submultiples.
- Relative magnitude will be joined together.
- If a constant appear to be smaller than zero in magnitude, we can adjust by multiply and divide by a power of two (which then correspond to a logic shift).

With this in mind, we can apply the following change of dimensions:

$$ v_C \rightarrow v_{C_{[mV]}}10^{-3} \qquad i_S\rightarrow i_{S_{[\mu A]}}10^{-6} \qquad v_o \rightarrow v_{o_{[mV]}}10^{-3}$$
$$ L\rightarrow L_{[\mu H]} 10^{-6} \qquad   C\rightarrow C_{[nF]} 10^{-9} \qquad L_m\rightarrow L_{m{[\mu H]}} 10^{-6}  $$
$$ R_{eq}\rightarrow R_{eq[m\Omega]} 10^{-3} \qquad V_g \rightarrow V_{g{[mV]}}10^{-3}\qquad  \delta_t\rightarrow \delta_{t{[ns]}} 10^{-9}  $$

With these transformations, we can write the following equivalent discrete dynamical equations

<!-- ```{math} -->
<!-- \begin{align} -->
$$
   v_{C_{[mV]}}^{k+1}    &= v_{C_{[mV]}}^k    + \frac{\delta_{t[ns]} 10^{-3}}{C_{[nF]}} i_{S_{[\mu A]}} \\
   i_{S_{[\mu A]}}^{k+1} &= i_{S_{[\mu A]}}^k + \frac{\delta_{t[ns]}}{L_{[\mu H]}} \left( V_{g{[mV]}}\sigma^k-v_{C_{[mV]}}^k-v_{o_{[mV]}}^k \right) \\
   v_{o_{[mV]}}^{k+1}    &= v_{o_{[mV]}}^k    -\frac{R_{eq[m\Omega]}\delta_{t[ns]}}{L_{[\mu H]}} \left( v_{C_{[mV]}}^k-V_{g{[mV]}}\sigma^k + \left( 1+\frac{L_{[\mu H]}}{L_{m{[\mu H]}}} \right) v_{o_{[mV]}}^k\right) 
$$
<!-- \end{align} -->
<!-- ``` -->

where we can highlight the coefficient multiplying the variables and scale them in order to have only integer operations

$$
   v_{C_{[mV]}}^{k+1}    &= v_{C_{[mV]}}^k    + \underbrace{\frac{\delta_{t[ns]} 2^{20}}{C_{[nF]}10^{3}}}_{\mu_1} i_{S_{[\mu A]}}^k \frac{1}{2^{20}} \\
   i_{S_{[\mu A]}}^{k+1} &= i_{S_{[\mu A]}}^k 
    \underbrace{-\frac{\delta_{t[ns]}}{L_{[\mu H]}}}_{\mu_2} \left(v_{C_{[mV]}}^k+v_{o_{[mV]}}^k \right)
   +\underbrace{\frac{\delta_{t[ns] }V_{g{[mV]}}}{L_{[\mu H]}}}_{\mu_3} \sigma^k\\
   v_{o_{[mV]}}^{k+1}    &= v_{o_{[mV]}}^k 
    \underbrace{-\frac{R_{eq[m\Omega]}\delta_{t[ns]}2^{10}}{L_{[\mu H]}10^6}}_{\mu_4} v_{C_{[mV]}}^k \frac{1}{2^{10}}
    \underbrace{-\frac{R_{eq[m\Omega]}\delta_{t[ns]}2^{17}}{L_{[\mu H]}10^6} \left( 1+\frac{L_{[\mu H]}}{L_{m{[\mu H]}}} \right)}_{\mu_5} v_{o_{[mV]}}^k \frac{1}{2^{17}}
   +\underbrace{\frac{R_{eq[m\Omega]}\delta_{t[ns]}V_{g{[mV]}}}{L_{[\mu H]}10^6}}_{\mu_6} \sigma^k 
$$

```{note}
Indeed, going to an integer representation of the parameters is pretty useless if then we combine them all in a unique constant.
```

In a compact way, we can write:

$$
   v_{C_{[mV]}}^{k+1}    &= v_{C_{[mV]}}^k    + {\mu_1} \cdot i_{S_{[\mu A]}}^k \cdot  \frac{1}{2^{20}} \\
   i_{S_{[\mu A]}}^{k+1} &= i_{S_{[\mu A]}}^k + {\mu_2}  \left(v_{C_{[mV]}}^k+v_{o_{[mV]}}^k \right) +{\mu_3} \cdot \sigma^k\\
   v_{o_{[mV]}}^{k+1}    &= v_{o_{[mV]}}^k    + {\mu_4} \cdot v_{C_{[mV]}}^k \cdot \frac{1}{2^{10}} + {\mu_5} \cdot v_{o_{[mV]}}^k \cdot \frac{1}{2^{17}} + {\mu_6} \cdot \sigma^k 
$$

