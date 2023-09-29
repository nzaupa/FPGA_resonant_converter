# Sensing


```{margin} 
   <sup>1</sup> Indeed, the FPGA is then connected to the resonant tank through the gate driver of the H-bridge. We might think to isolate also the drivers but it not extremely necessary.
```
The current and the voltage on the capacitor $C_r$ are measured in order to close the loop and ensure the oscillation.
Two sensing circuits are used to measure these quantities. Thanks to the use of signal transformer, the resonant tank is galvanically isolated from the sensing output, i.e. the FPGA<sup>1</sup>. 
The transformer design procedure is described in [](sec:signal_transformer).

Every sensing circuit must have the least influence possible on the resonant tank.

The output of the transformers need to be interfaced with a [](sec:BALUN) which is embedded in the daughter board of the FPGA. Essentially, we can see it as a $49.9\;\Omega$ resistor in parallel with the output of the sensing circuit. Remember that, the voltage that is read by the ADC is the double of the output, i.e. apart from filtering behavior, it corresponds to the voltage out of the transformer. (the two $49.9\;\Omega$ resistors are dividing in half the voltage, which is the doubled by the BALUN circuit thanks to a transformer).
The limit voltage is $0.5\;V$.

Practically, every sensing stage is connected with a SMA connector via a coaxial cable to the ADC board.


## Current Sensing

The capacitor current corresponds to the input current of the resonant tank. A current-transformer is used to sense it and to ensure isolation. 
The primary current is reduced at the secondary according to the transformation ratio $1:n_i$, which is then transformed to a voltage thanks to the resistor $R_i$. The best choice is to have the least number of windings at the primary, so that the magnetizing inductance is negligible with respect to the resonant inductance $L_r$.

The static equation relating input current $i_S$ and output voltage $v_{R_i}$ is

$$ v_{R_i} = \frac{1}{n_i}\frac{100 R_i}{100+R_i}i_S \approx \frac{R_i}{n_i}i_S$$

where the approximation is valid in the case $R_i\ll100\Omega$.

The dissipated (AC) power on $R_i$ is approximately $P_{R_i}\approx \frac{R_i}{n_i^2}\frac{I_{S}^2}{2} $, where $I_{S}$ is the peak value ($i_S$ is an AC signal so we should consider the RMS value for the power or the peak divided by $\sqrt{2}$).

The equivalent resistance at the primary side is: $R_{T1,eq}=\frac{R_i}{n_i^2}$.
 

 
```{figure} ../images/RT_current_sensing.png
---
width: 500px
---
Current sensing circuit
```
A transfer function can be written between input and output:

$$ TF = \frac{V_{ADC}}{I_S} $$

Where $V_{ADC}$ indicates the voltage that is than transformed to binary code (double of the voltage on the filter capacitor).

The output of $T_1$ is connected to a SMA connector through a low pass filter with cut-off frequency $f_{rcf}=\frac{1}{\pi\ R_{rcf}C_{rcf}}$.  $R_{rcf}=49.9\Omega$ for impedance matching with the input stage of the ADC. 

```{figure} ../images/RT_current_sensing_table.png
---
width: 700px
---
```

```{note}
Small interface to calculate de maximum current from ADC data and values of the components.

```

## Voltage Sensing

After have experience some problem with high voltage sensing, we can generalize the acquisition chain as:
- capacitor grid reducing of an integer factor. e.g. $3\times3$ grid ($9$ capacitors) reduces of a factor $3$. It is suggested to keep it symmetric with an odd number. We might think of some other configurations. The important is that the equivalent capacitance is $C_r$ (does not waste power);
- voltage divider with 3 resistor to attenuate the voltage (waste power);
- signal transformer: connected to the central resistor, step down the voltage and ensure galvanic isolation.

```{warning}
These considerations are important for high voltage and, indeed, they haven't been tested.
```

The voltage is initially attenuated by a grid of capacitors (the resonant ones) of a factor $n_c$, then by a voltage divider by a factor $\frac{R_{pv2}}{R_{pv1}+R_{pv2}+R_{pv3}}$, which is then attenuated by a signal transformer with transformation ratio $n_v:1$. Therefore, we have that the voltage read by the ADC corresponds to 

$$ v_{T2_{sec}}=\frac{1}{n_i n_v}\frac{R_{pv2}}{R_{pv1}+R_{pv2}+R_{pv3}}v_{C_r} $$

Equivalent resistance at the primary is $R_{T2,eq}=2R_{rvf}n_v^2$ and we need to have that $R_{pv2}\ll R_{T2,eq}$.
 
 
```{figure} ../images/RT_voltage_sensing.png
---
width: 500px
---
Voltage sensing circuit
```
A transfer function can be written between input and output:

$$ TF = \frac{V_{ADC}}{V_{C_r}} $$

Where $V_{ADC}$ indicates the voltage that is than transformed to binary code (double of the voltage on the filter capacitor).

Then, the output of $T_2$ is connected to a SMA connector through a low pass filter with cut-off frequency $f_{rvf}=\frac{1}{\pi\ R_{rvf}C_{rvf}}$.  $R_{rvf}=49.9\Omega$ for impedance matching with the input stage of the ADC.


```{caution}
It's really import to consider the magnetizing inductance of the signal transformer. Its effect should be negligible and to evaluate this we can consider the equivalent impedance at the resonance frequency. Essentially, $Z_{eq} // R_{T2,eq}$ must be higher that $R_{pv2}$.
```

 
```{figure} ../images/RT_voltage_sensing_table.png
---
width: 700px
---
```



## EXTRA

need to understand where an how to put this






|  |  |  |
| ----------- | ----------- |  ----------- |
| $n_i$ | 20       | $\gamma_{ri,ADC}=0.0135$ |
| $R_i$ | 270 $mΩ$ | $\max\{I_s\}=37.0\ A$ |



<table>
<colgroup>
<col style="width: 8%" />
<col style="width: 14%" />
<col style="width: 32%" />
<col style="width: 13%" />
<col style="width: 30%" />
</colgroup>
<thead>
<tr class="header">
<th><span class="math display"><em>n</em><sub><em>i</em></sub></span></th>
<th>20</th>
<th rowspan="2"><p><span class="math display"><em>γ</em><sub><em>r</em><em>i</em>, <em>A</em><em>D</em><em>C</em></sub> = 0.0135</span></p>
<p><span class="math display">max {<em>I</em><sub><em>s</em></sub>} = 37.0 <em>A</em></span></p></th>
<th>20</th>
<th rowspan="2"><p><span class="math display"><em>γ</em><sub><em>r</em><em>v</em>, <em>A</em><em>D</em><em>C</em></sub> = 0.028</span></p>
<p><span class="math display">max {<em>I</em><sub><em>s</em></sub>} = 17.9 <em>A</em></span></p></th>
</tr>
<tr class="odd">
<th><span class="math display"><em>R</em><sub><em>i</em></sub></span></th>
<th>270 mΩ</th>
<th>560 mΩ</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><span class="math display"><em>R</em><sub>rcf</sub></span></td>
<td>49.9 Ω</td>
<td rowspan="2"><span class="math display"><em>f</em><sub>rcf</sub> = 318<em>k</em><em>H</em><em>z</em></span></td>
<td colspan="2" rowspan="2">* Q high: Ri is at the limit might need to lower it</td>
</tr>
<tr class="even">
<td><span class="math display"><em>C</em><sub>rcf</sub></span></td>
<td>10 nF</td>
</tr>
</tbody>
</table>




<table>
<colgroup>
<col style="width: 8%" />
<col style="width: 13%" />
<col style="width: 31%" />
<col style="width: 13%" />
<col style="width: 32%" />
</colgroup>
<thead>
<tr class="header">
<th><span class="math display"><em>n</em><sub><em>v</em></sub></span></th>
<th>20</th>
<th rowspan="3"><p><span class="math display"><em>γ</em><sub><em>r</em><em>v</em><em>i</em>, <em>A</em><em>D</em><em>C</em></sub> = 495 × 10<sup>−6</sup></span></p>
<p><span class="math display">max {<em>V</em><sub><em>c</em></sub>} = 1010<em>V</em></span></p></th>
<th>20</th>
<th rowspan="3"><p><span class="math display"><em>γ</em><sub><em>r</em><em>v</em><em>i</em>, <em>A</em><em>D</em><em>C</em></sub> = 1.47 × 10<sup>−3</sup></span></p>
<p><span class="math display">max {<em>V</em><sub><em>c</em></sub>} = 57<em>V</em></span></p></th>
</tr>
<tr class="odd">
<th><span class="math display"><em>R</em><sub><em>p</em><em>v</em>1</sub></span></th>
<th>100 kΩ</th>
<th>4.7 kΩ</th>
</tr>
<tr class="header">
<th><span class="math display"><em>R</em><sub><em>p</em><em>v</em>2</sub></span></th>
<th>1 kΩ</th>
<th>1 kΩ</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><span class="math display"><em>R</em><sub>rvf</sub></span></td>
<td>49.9 Ω</td>
<td rowspan="2"><span class="math display"><em>f</em><sub>rcf</sub> = 318<em>k</em><em>H</em><em>z</em></span></td>
<td colspan="2" rowspan="2">* Q low: we might reduce <span class="math inline"><em>n</em><sub><em>v</em></sub> <em>a</em><em>n</em><em>d</em> <em>i</em><em>n</em><em>c</em><em>r</em><em>e</em><em>a</em><em>s</em><em>e</em> <em>R</em>_{<em>p</em><em>v</em>1}</span> we should keep the total resistance not too low (10mA)</td>
</tr>
<tr class="even">
<td><span class="math display"><em>C</em><sub>rvf</sub></span></td>
<td>10 nF</td>
</tr>
</tbody>
</table>

