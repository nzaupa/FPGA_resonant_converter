# Resonant Converters

Resonant	converters are well-known in the power electronics industry due to numerous advantages, including soft-switching and high power densities, as confirmed by the including inductive heating and battery charging {cite}`inductive,battery` context, to cite a few.
Their conventional control includes frequency and amplitude modulation, typically relying on small signal models, which are dependent on the operating point.
Early works focus their attention on unifying the characterization of several topologies using high-order models, which are then analyzed using first-harmonic approaches or linearization  {cite}`BH91,CU92`.
As an alternative, several state plane-based approaches have been proposed, where the input switching is derived from current and voltage measurements in the converter.
In state-plane control approaches, the dynamics can be simpler, streamlining the design of controllers, which can show improved regulation performance and a more immediate hardware realization.	Some of these approaches drive the resonant converter in a self-oscillating way, without the need of external oscillators. One of the inherent advantages of self-oscillation is that the converter can be operated at the resonant frequency with no compensation for parameters variations in the components of the resonant tank.
State-plane trajectories were used in {cite}`SO91` to describe the steady-state operating point with conventional controllers, but the potential of state plane-based switching was only explored in follow up works. 
A trajectory tracking approach is used in {cite}`SI04`. where no self-oscillating mechanism is exploited.
Self-oscillation is instead adopted in {cite}`SI02`. where a state plane-based solution is proposed, based on two controllers: one for the startup and one for the steady-state.
The stability of the induced limit cycle with the switching mechanism for the start-up is analyzed in {cite}`HE03` with a Poincaré map.
Further developments in that direction include {cite}`Molla2012,Molla2015,Afshang2016` that analyze series resonant converters with switched affine models, followed by {cite}`SamaniegoIET16,SamaniegoK,ElAroudi` that demonstrate that state-plane based methods can outperform the dynamics of conventional approaches.
Nonetheless, the above state-plane control solutions also have limitations, one of them (resolved here) being the assumption that the resonant tank has a sufficiently high quality factor $Q$ {cite}`SamaniegoIET16,ElAroudi`.

For providing rigorous guarantees, a full nonlinear dynamics perspective on these ON-OFF type of feedbacks
naturally calls for the use of a hybrid dynamical systems formalism: an area where powerful stability analysis tools have been recently developed in {cite}`TeelBook12` with a Lyapunov approach.
Several relevant power electronics challenges have been addressed with these tools recently, such as the hybrid control of inverters in {cite}`ChaiSanfeliceACC14,TorquatiCCTA17` and DC-DC converters in
{cite}`theunisse2015robust,AlbeaTAC19,sferlazza2019min,sferlazza2020hybrid`.
Nonetheless, these approaches are not applicable to resonant conversion, where the switching frequency does not correspond to a small ripple, but to the main AC component of the power transfer. 

In our preliminary conference results {cite}`ADHS`. we proposed a novel unifying second-order input-dependent (or hybrid) coordinate transformation to analyze the dynamics of second-order parallel and series resonant converters (PRC, SRC).
Differently from the phasor circuit-based steady-state analysis leading to the
high-order unifying models in {cite}`BH91,CU92`. our state-plane low-dimensional coordinates allow specifying a state-plane control law based on a reference input corresponding to an angle $\theta \in (0,\pi]$, identifying suitable sectors in this new hybrid coordinate system, independently of the load.
It is worth pointing out that thanks to the proposed approach the dynamics are unified, but not in the sense of a unique model that can be particularized for different cases. The proposed change of coordinates describes both converters with the same dynamics equations and without increasing their order.
Different from the two-controllers scheme of {cite}`SI02`. our self-oscillating solution only requires one controller. 
Moreover, our self-oscillation mechanism overcomes the stringent bound on the quality factor assumed in {cite}`SamaniegoIET16,ElAroudi`: our only mild requirement on the quality factor is that the dynamics of the resonant tank must be underdamped.
In {cite}`ADHS`. we also discussed in depth the PRC configuration, showing a desirable dependence of the output amplitude and frequency on the reference input $\theta$. 
We also proved rigorously the existence of a unique nontrivial hybrid limit cycle, but only for the specific case $\theta = \frac{\pi}{2}$, leaving the same result for the whole range $\theta \in (0,\pi]$ as a conjecture.


