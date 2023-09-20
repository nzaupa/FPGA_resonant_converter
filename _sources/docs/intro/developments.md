# Developments

### Works done so far for the charging with resonant converter

## Discrete-time description

We might consider a lower sampling frequency. At that point we should
consider a discrete-analysis of the system.

## Prototype changes needed

In our last meeting, we discussed about a low voltage prototype (48 V -
max. 500 W) and two resonant tanks:

1\) High Q tank, with Lr = 68 uH and 1:1.5 transformer with Lm = 245 uH.

2\) Low Q tank, with Lr = 10 uH and 1:1 transformer with Lm = 33 uH.

### Transformer

{cite:p}`ta2020`: the magnetizing inductance can be kept low, so that it can be
integrated in the transformer. This allows higher power density.

### Sensing circuit

### Resonant Tank

{cite:p}`desimone2008` guidelines for the construction of a transformer for a
LLC converter which includes all inductors inside it [IEEE
link](https://ieeexplore.ieee.org/document/4581225)
\[$f_r=\SI{120}{kHz}$, $L_r=\SI{56}{\mu H}$, $L_p=\si{305}{\mu +H}$\]

### Power stage

Missing proper power diodes

missing good points for sensing (rn totem of probes in order to sense
voltages)

### Rectifier

### Rectifier Sensing

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



