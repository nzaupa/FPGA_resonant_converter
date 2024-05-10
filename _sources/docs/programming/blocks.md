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

In the end, we reach this representation that can be implemented in an FPGA.
To compute the parameters we have the following Python script
```python
# parameters
L   = 10    # uH
C   = 850   # nF
Lm  = 36    # uH
Req = 10000 # mOhm
Vg  = 48000 # mV
dt  = 10    # ns

print('Considering integer operations')
print('  mu_1 = '+str(round( (dt*(2**20))/(1000*C),2)))
print('  mu_2 = '+str(round(-dt/L,2)))
print('  mu_3 = '+str(round( (dt*Vg)/L,2)))
print('  mu_4 = '+str(round(-(dt*Req*(2**10))/(L*1e6),2)))
print('  mu_5 = '+str(round(-(dt*Req*(2**17))*(1+L/Lm)/(L*1e6),2)))
print('  mu_6 = '+str(round( (dt*Req*Vg)/(L*1e6),2)))

```

Computation of the gain without considering the normalization wrt the unit of measure
```matlab
mu(1) = round( (dt*(2^20))/(1000*Cr),2);
mu(2) = round(-dt/Lr*1e3,2);
mu(3) = round( (dt*Vg*1e6)/Lr,2);
mu(4) = round(-(dt*Req*(2^10))/(Lr),2);
mu(5) = round(-(dt*Req*(2^17))*(1+Lr/Lm)/(Lr),2);
mu(6) = round( (dt*Req*Vg)/(Lr*1e-3),2);
```


Then, the modules code is the following (take care of the priority of the arithmetic operations over logic one):

```verilog
module simulator_LLC #(
   parameter mu_1 =  12,
   parameter mu_2 = -1,
   parameter mu_3 =  48000,
   parameter mu_4 = -10,
   parameter mu_5 = -1675,
   parameter mu_6 =  480
)(
   output signed [31:0]  vC_p, 
   output signed [31:0]  iS_p, 
   output signed [31:0]  Vo_p,    
   input                 CLK,    
   input                 RESET,   
   input  signed [1:0]   sigma
);

// INTERNAL VARIABLE
integer vC; // equivalent to reg signed [31:0] vC;
integer iS;
integer Vo;

wire signed [31:0] sigma_32;

// assign output variable
assign vC_p = vC;
assign iS_p = iS;
assign Vo_p = Vo; 
assign sigma_32   = { {30{sigma[1]}} , sigma };

// variable initialization
initial begin
   vC = 0;
   iS = 0;
   Vo = 0;
end

always @(posedge CLK or negedge RESET) begin
   if (~RESET) begin
      vC <= 0;
      iS <= 0;
      Vo <= 0;
   end else begin
      vC <= vC + ((mu_1*iS)>>>20);
      iS <= iS + mu_2*(vC + Vo) + mu_3*sigma_32;
      Vo <= Vo + ((mu_4*vC)>>>10) + ((mu_5*Vo)>>>17) + mu_6*sigma_32;
   end
end

endmodule
```

