# PCB design

General consideration, power limit, path width, ...

Two resonant tanks will be built. One with low nominal quality factor and one with high nominal quality factor.

## High Q

Explain what was done in the lab, y compris les modifications. STILL NOT WORKING (voltage transformer is the bottle neck)

Make some consideration to improve the design (grid of capacitors)


## Low Q

Consideration and working components that are mounted



##	Generalities

 - Power input/output: HDR 2x10 (half connector per polarity)
 - Sensing SMA connectors + HDR 1x2 (for oscilloscope: before the 50 Ohm resistance)
GND of the SMA connector on the FPGA is connected to the common ADC ground. i.e. can create a common ground plate on the PCB.



### Components list 

|                    | values        | Description                 | code                  | manufacture |
|--------------------|---------------|-----------------------------|-----------------------|-------------|
| $L_{r}$            | 68uH (10uH)   | Power DC inductor           | AGP4233-683ME (103ME) | Coilcraft   |
| $C_{r}$            | 100nF (700nF) | 1kVDC – C0G (NP0) - SMD     | CKC21C104KDGLC7805    | Kemet       |
| $T_{r}$            | 1:1           | Lm=245uH                    | B65982E0012D001       | TDK         |
| $T_{1}$            | 1:ni          | toroid 12.7 × 7.15 × 4.9 mm | 5977000301 core       | Fair-Rite   |
| $T_{2}$            | nv:1          | toroid 12.7 × 7.15 × 4.9 mm | 5977000301 core       | Fair-Rite   |
| $R_{p1}$           | 100 kΩ        | through-hole resistance ¼W  | Precision \<1%        |             |
| $R_{p2}$           | 1 kΩ          | through-hole resistance ¼W  | Precision \<1%        |             |
| $R_{i}$            | 0.5 Ω         | through-hole resistance ¼W  | Precision \<1%        |             |
| $R_{\text{rcf}}$   | 50 Ω          | through-hole resistance ¼W  | Precision \<1%        |             |
| $R_{\text{rvf}}$   | 50 Ω          | through-hole resistance ¼W  | Precision \<1%        |             |
| $C_{\text{rcf}}$   | nF            | film capacitor              |                       |             |
| $C_{\text{rvf}}$   | nF            | film capacitor              |                       |             |
| **CONNECTORS**     |               |                             |                       |             |
| J3-J6              | ×2            | header 1×2                  |                       |             |
| J1-J2              | ×2            | Header 2×10                 |                       |             |
| TP                 | ×6            | Test point 1.6mm            |                       |             |
| SMA                | ×2            | FPGA connectors             | SMA-TH-vertical       |             |
| J7                 | ×1            | current jumper (wire)       |                       |             |




**RESONANT TANK**

| Units | Description                                                        | Code                    |
|-------|--------------------------------------------------------------------|-------------------------|
|       |                                                                    | **To buy?**             |
| ×10   | Multilayer Ceramic Capacitors - SMD/SMT 1kV 0.1uF 1812 10%         | CKC21C104KDGLC7805      |
|       |                                                                    | **Already in the lab?** |
| ×1    | Power Inductors - Leaded 68uH Shld 20% 24A 2.95mOhms               | AGP4233-683ME (Carlos)  |
| ×1    | Power Inductors - Leaded 10uH Shld 20% 24A 2.95mOhms               | AGP4233-103ME (Carlos)  |
| ×2    | Handcraft transformer. Two magnetizing inductance: 245uH and 30uH  | B65982E0012D001         |
| ×4    | Handcraft signal transformer                                       | core: 5977000301        |
| ×10   | \<1% resistor (¼W)                                                 |                         |
| ×4    | Film capacitor for filtering                                       |                         |
| ×12   | Test point 1.6mm                                                   |                         |
| ×12   | Test point 1mm                                                     |                         |
| ×4    | Coaxial Connectors 6 GHz, 50 Ohm SMA Jack or Plug, Cable Connector | SMA-J-P-H-ST-MT1        |
| ×4    | Header 2×10                                                        | HDR2x10                 |
| ×4    | Oscilloscope probe test point                                      | 129-0701-201(202)       |









## Note on the mounted components

Both
- wire jump for current probe: distance is good, diameter could be reduced. 1.5mm is the wire diameter. Cable code: *3.5mm (outer diam) MZ-3.2/100 RS: 803-4262 | style 1015*
- cable from the power transformer: diam x.x mm
- hole for current transformer: diam 3mm

```{note}
LOW Q has been completely characterize. There is a yellow paper with all the data. HIGH Q is partially characterize
```

|         |HIGH Q   |LOW Q   |
|---------|---------|--------|
|$L_r$    |68 μH    |10 μH   |
|$C_r$    |100.3 nF |850 nF  |
|$L_m$    |169 μH   |36 μH   |
|$n$      |1:1.268  |1:0.919 |
|$R_{pv1}$| ?       |4.67 kΩ |
|$R_{pv2}$| ?       |982 Ω   |
|$C_{rvf}$| ?       |5.3 nF  |
|$n_v$    | ???     |62:3    |
|$R_i$    |250 mΩ   |500 mΩ  |
|$C_{rcf}$| ?       |5.3 nF  |
|$n_i$    |0.5:14   |1.5:27  |








