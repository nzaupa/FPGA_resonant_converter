---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.11.5
kernelspec:
  display_name: Python 3
  language: python
  name: python3
# header-includes:
#   - \usepackage{siunitx}
---

# SOTA in battery charging with

-   FHA: First Harmonic Analysis

-   OBC: On Board Charger

## Why our method is worth a paper

Here I try to collect a not-complete list of reasons why our
contribution is meaningful.

-   ensure soft-switching, ZVS (we should look also at ZCS for the
    rectifier);

-   self-sustained oscillations;

-   no time (angle) dependency in the control law thanks to the phase
    plane approach;

-   wide range of conversion ratios with a narrow range of operating
    frequencies - optimal magnetics;

-   ...

Some open question:

1.  How much is it important a bidirectional converter for OBC?

2.  how feasible is this control approach with low-cost electronics?

3.  ...

## Battery charger design



A complete and complex analysis of the design and **modeling** is given
in {cite:p}`deng2014` where an LLC resonant converter for EV
battery charging is studied. The worst-case operating point is
identified and used for the design with the aim to globally ensure ZVS.
FHA is used in above-resonance region, while for the below-resonance
region a specific mode analysis is used. Big challenges are coming from
the charging profile that is nonlinear in V--I.

There are several works in the literature addressing the modeling and
control of resonant converters. For the battery charging application,
the mostly considered topology is the LLC. We can find two main branches
in the literature: one concerning the resonant converters them-self,
without a particular application; and one that considers the battery
charger problem where the load now is time-varying depending on the
charging profile, which is usually nonlinear. Moreover, al lot of works
have they focus on the circuit/components design and few tackles the
*control problem comprehensively*.

### Some survey on these topics. 

A pretty complete overview on resonant converter is given in
{cite:p}`salem2018`. Several topologies are discussed and it can be a good
source of references. Section 4 is dedicated to *series resonant
convert* with: the different operating modes, problems related to the
control, possible control solutions (Section 5).

{cite:p}`safayatullah2022` is a pretty broad survey on Power converters
topologies and control methods for EV fast charging. LLC is the first
discussed in section V-A (control in VIII-A). There is also the DAB
(Dual Active Bridge) in section V-B/C (control in VIII-B) and multilevel
converters. This could be another source of references.

#### Resonant converter focus:

Looking into the literature, we have modeling oriented papers and
control oriented papers. In modeling, the most used technique is First
Harmonic Approximation (FHA), which most of the time is good since the
waveforms are sinusoidal, but it happens in the limiting (e.g. lower
power) that this assumption fails and then the modeling technique should
change. A good paper on these different modeling approaches is
{cite:p}`deng2014` where, looking at the battery charging application, they do
a wide study on the different operating conditions.

To overcome some of this problem the adopted solutions are of two
kind: 1) change the control of the full-/half- bridge configuration; 2)
change the topology of the circuit.

## Control of resonant converter

Regarding the controls technique we have:

-   **Fixed-frequency**: this kind of control law keep the frequency
    constant and change other parameters of the input. From
    {cite:p}`burdio2001`, we can identify:

    -   phase-shift or clamped mode (similar to our three-level solution
        {cite:p}`zaupa2023resonant`);

    -   asymmetrical duty-cycle;

    -   asymmetrical clamped-mode.

-   **Variable-frequency**: these techniques offer good soft-switching
    properties, the downside is that performance is usually affected by
    the wide range of frequency requested. From {cite:p}`youssef2004`, we can
    highlight:

    -   variable frequency (for example through a VCO[^1]) is one of the
        most common technique since it offers an easy implementation but
        the frequency range is very wide;

    -   self-sustained oscillation like in
        {cite:p}`bonache-samaniego2020,zaupa2023resonantTCST` in which the
        converter sets its operating point at the resonant frequency
        without needing to know it;

    -   self-sustained phase-shift proposed in {cite:p}`youssef2006` in which,
        together with the self-oscillating behavior, also the
        phase-modulation technique is used in order to reduce the
        frequency range.

    Usually, the biggest counterpart of these techniques is the big
    range of frequencies in which the converter has to operate, which
    from one side complicates the control implementation and on the
    other side it makes hard to optimize the magnetics of the circuit.
    Therefore, one research axe has been devoted to find control
    techniques that allows reducing the frequency range.

### Frequency modulation

Many works in the literature use this kind of control since it is to
implement. Usually, a PI controller and a Voltage Controlled Oscillator
are sufficient. Few recent works that use this technique, which are
cited in this report, are: {cite:p}`qin2022, cittanti2022, saadati2022`

In {cite:p}`cittanti2022` two loops are used for the control (outer for the
voltage and inner for the current). Full analysis of the 7th order model
is done with reduction to 3rd order. The aim of one closed-loop is to
keep the performance constant when the operating point is changing. The
application is EV fast charging. The implemented control is LUT-based
feed-forward with adaptive gain (through a lookup-table).

A bit out of track wrt other works, {cite:p}`saadati2022` proposes a novel
**analog controller** design procedure for LLC resonant converter for
battery charging. They tackle both the design of the converter and the
design of the controller. About the controller, they build a model based
on FHA that is then linearized from which a least-square procedure is
used to obtain the unknown parameters of the controller.

### Frequency and phase-shift modulation

Next, I try to focus more on the solutions that involve frequency and
phase shift modulation (amplitude modulation). Contributions in this
direction are more limited and I think that there could be some margin
for our work "$\theta+\varphi$".

#### Youssef 2006:

This mixed solution was initially (wrt what I've found) presented in
{cite:p}`youssef2006`. The focus is only on resonant converters and the
techniques combines self-sustained oscillation with phase shift
modulation. The objective is to reduce the frequency range while
maintaining ZVS. Also the design procedure is discussed. The controller
is composed of two loops: the inner one adjusts the phase shift to
ensure ZVS, and the outer one adjusts the output voltage. The controller
is implemented analogically, i.e. without a micro-controller. For the
analysis *"Generalized sampling data modeling"* is used.

#### Bojarski 2014:

More recent works
{cite:p}`bojarski2014multiphase, bojarski2015multilevel, bojarski2016prototype`
propose a so called *"phase-frequency control"* for the wireless battery
charging case (the topology is similar to OBC). Essentially, the control
try to keep the frequency nearer to the resonant one while maintaining
ZVS, the output is regulated by changing the phase-shift. In
{cite:p}`bojarski2015multilevel` the number of levels it's not clear and it
uses a topology with 12 switches. {cite:p}`bojarski2016prototype` presents a
25 kW prototype, it shows that the control is implemented in an FPGA and
it provides the scheme.

More recently, works dealing with multilevel resonant converters are the
following.

In {cite:p}`peter2021`, a three-level single stage LLC converter is proposed.
The control scheme is dual: frequency modulation is used to regulate the
output voltage and PWM is used to control the dc-bus voltage.

In {cite:p}`alatai2022` they use a 5-levels converter (2 full-bridge). Reading
it fast is not clear how the control law is implemented and it seems
more that they are doing constant voltage control.

### Topology changes

In {cite:p}`liu2017` a **three-phase** with 3-levels converter is presented. To
have the three levels ($V_{in}/2$) a half-bridge topology is used.

In {cite:p}`ta2020`, a new slightly different topology is proposed, it keeps
LLC properties allowing different modulation schemes:

1.  Full-Bridge Converter with Frequency Modulation (FBFM);

2.  Dual-Phase Half-Bridge LLC (D-LCC);

3.  Single-Phase half-bridge LLC.

Essentially, by having a full-bridge configuration for the switches and
a transformer with a central point, it is possible to activate the
switches so that the topology is different. An interesting point for the
design is that the magnetizing inductance can be kept low, so that it
can be integrated in the transformer. ZVS is guaranteed in all modes.

In {cite:p}`li2020bidirectional_obc`, a bidirectional LLC charger is proposed.
The topology is similar to a dual-active-bridge since the rectification
is active. This paper is frequently cited for OBC with LLC. It mainly
contains the design procedure.

{cite:p}`qin2022` proposes a higher order resonant tank that induces better
properties. Essentially they are adding degrees of freedom to the design
by using, at the place of the capacitor, a block given by two capacitors
and an inductor. Classical frequency modulation control is adopted.

In {cite:p}`li2023`, a slightly different topology is presented. The resonant
tank is on the secondary side of the transformer and the resonant
elements connection is made in a different way. The resonant tank has a
T shape. Battery is modeled as a resistance (its value is determined by
the charging curve). The converter behaves either as a LCL or a LC,
depending on the charging mode, CC and CV respectively.

In {cite:p}`wu2023` different topologies for HF AC-DC converters are discussed.
They include DAB (page 7) and resonant LLC (page 8). There is also a
3-levels (5-levels if we consider all positive and negative) with
half-bridge topology.

# Reference example for the prototype - OBC LLC

We consider the On Board Charger (OCB) case equipped with a LLC
converter as a reference for the design. An example can be found in the
following ON Semiconductor design:
[OBC--TND6318/D](https://www.onsemi.com/pub/Collateral/TND6318-D.PDF)
(this work has as reference {cite:p}`deng2014`). At this
[link](https://www.onsemi.com/PowerSolutions/content.do?id=19106), there
are other designs at different power ratings

-   TND6318 -- 10 kW -- 80-140 kHz

-   TND6320 -- 6.6 kW -- 39-690 kHz

-   TND6327 -- 33 kW -- 39-690 kHz

Specifications for OBC--TND6318/D:

-   Input voltage $\beta$ $700\pm\SI{35}{V}$

-   Output voltage $200/\SI{450}{V}$

-   Output current $0/\SI{40}{A}$

-   Maximum output power $\SI{10}{kW}$

-   Maximum switching frequency 400 kHz

Switching frequency range \[80-140 kHz\] is higher than our target. The
converter is composed of the following two stages: AC--DC and DC--DC
(ensures galvanic isolation).

# Works done so far for the charging with resonant converter

# Discrete-time description

We might consider a lower sampling frequency. At that point we should
consider a discrete-analysis of the system.

# Prototype changes needed

In our last meeting, we discussed about a low voltage prototype (48 V -
max. 500 W) and two resonant tanks:

1\) High Q tank, with Lr = 68 uH and 1:1.5 transformer with Lm = 245 uH.

2\) Low Q tank, with Lr = 10 uH and 1:1 transformer with Lm = 33 uH.

## Transformer

{cite:p}`ta2020`: the magnetizing inductance can be kept low, so that it can be
integrated in the transformer. This allows higher power density.

## Sensing circuit

## Resonant Tank

{cite:p}`desimone2008` guidelines for the construction of a transformer for a
LLC converter which includes all inductors inside it [IEEE
link](https://ieeexplore.ieee.org/document/4581225)
\[$f_r=\SI{120}{kHz}$, $L_r=\SI{56}{\mu H}$, $L_p=\si{305}{\mu +H}$\]

## Power stage

Missing proper power diodes

missing good points for sensing (rn totem of probes in order to sense
voltages)

## Rectifier

## Rectifier Sensing

ADC used by Carlos:
[AD7822](https://www.analog.com/en/products/ad7822.html#product-overview)

Remember to look at the number of bits available con the card in
addition to the control one.

-   8-bit

-   1-4-8 single ended input

-   Supply $\SI{3}{V}$ or $\SI{5}{V}$

-   input range\
    $\SI{0}{V}$ to $\SI{2}{V_{pp}}$ with $V_{DD}=\SI{3}{V}$\
    $\SI{0}{V}$ to $\SI{2.5}{V_{pp}}$ with $V_{DD}=\SI{5}{V}$

-   $\SI{420}{ns}$ of conversion time - 2 MSPS (500 ns)

[^1]: Voltage Controlled Oscillator

