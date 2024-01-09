# Unified model



```{figure} ../images/OC/OC_scheme_2nd.png
---
width: 400px
name: fig:circuits
---
Equivalent circuits associated with the parallel resonant converter
(PRC, top) and series resonant converter (SRC, bottom).
``` 

## Unifying coordinate change



We address parallel and series resonant converters (PRC and SRC, respectively), whose circuits are shown in {numref}`fig:circuits`,
where $v_C$ and $i_C$ denote the voltage and the current in the capacitor.
Both configurations exhibit a (parallel or series) resonant tank driven by an H-bridge applying a supply voltage $v_s$ equal to either $V_g$ or $-V_g$ to the left terminal, where $V_g$ is an external DC supply.
The H-bridge is modeled here by a binary variable $\sigma \in \{-1,1\}$ describing the switch position, so that 
$v_s = V_g$ when $\sigma =1$ and $v_s = -V_g$ when $\sigma = -1$ (in summary $v_s = \sigma V_g$).


The linear equations governing 
the current and voltage evolution of $v_C$ and $i_C$ for the parallel configuration at the top of {numref}`fig:circuits` are the following ones:

$$
L \frac{ {\rm d} i_L}{{\rm d} t} = \sigma V_g -v_C , \quad
C \frac{ {\rm d} v_C}{{\rm d} t} = i_L - \frac{v_C}{R}.
$$ (eq:parallel)

We emphasize that the last term, $\left( i_L -\frac{v_C}{R}\right)$, is the current $i_C$ flowing in the capacitor.
Similarly, the linear equations governing the series configuration at the bottom of {numref}`fig:circuits` correspond to:

$$
	L \frac{ {\rm d} i_L}{{\rm d} t} = \sigma V_g -v_C - R i_L, \quad
	C \frac{ {\rm d} v_C}{{\rm d} t} = i_C.
$$ (eq:series)

Note that in this case $i_L=i_C$.
The novel approach proposed there stems from
introducing the next input-dependent quantities for the converters

$$
	z_1 := \frac{v_C}{V_g} - \sigma, \quad
	z_2:=\frac{1}{V_g}\sqrt{\frac{L}{C}} i_C,
$$ (eq:z_change)

the first one clearly corresponding to a transformed voltage and 
the second one being a transformed current.

Keeping in mind that any variation of $\sigma \in \{-1, 1\}$ must be instantaneous,
so that $\dot \sigma = 0$,
we may compute the differential equations governing the evolution of variables $z:=(z_1,z_2)$ in {eq}`eq:z_change`.
As shown in \cite{ADHS}, the dynamics is the same for the two circuits
and corresponds to the following damped oscillator

$$
  \dot z_1 = \omega z_2, \quad \dot z_2 = -\omega z_1 - \beta z_2
$$ (eq:z_dot)

where $\omega := \left(\sqrt{LC}\right)^{-1}$ is the natural frequency and $\beta>0$ is the inverse of the time constant of the exponential decay associated with each one of the linear circuits:

$$
	\beta_{\text{PRC}}:= \frac{1}{RC}, \quad
	\beta_{\text{SRC}}:= \frac{R}{L}.
$$ (eq:beta)

Since the coordinates $(z_1,z_2)$ depend on the input $\sigma$, they experience an instantaneous change when $\sigma$ is toggled. In particular, since $\sigma$ toggles between $-1$ and $+1$, namely
$\sigma^+ = -\sigma$, 
then {eq}`eq:z_change` provides, for both circuits:

$$
(z_1^+, z_2^+, \sigma^+) = (z_1 +2 \sigma, z_2, -\sigma),
$$ (eq:z_plus)

where we emphasize that $\sigma$ represents the switch position before the update and $\sigma^+$ represents its position after the update (and similarly for the other variables).
