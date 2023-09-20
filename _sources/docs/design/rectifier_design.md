# Rectifier


Essentially, the board consists in a power part with: rectifier, filter
and battery; and a sensing part with: voltage sensor, current sensor and
ADCs. The main objective is to control the current charging the battery
while ensuring galvanic isolation between the battery and the FPGA
(ideally, the FPGA should be isolated from both battery and H-bridge).



Figure 7: small overview of the main parts

The power supply for the electronics in the sensing part (ADCs + OPA)
can be taken from the FPGA, which has 3.3V and 5V pins on the GPIO
40-pin socket.

For the current, a Hall effect sensor is used; for the voltage, an
isolated operational amplifier is used. Outputs of the sensors are
actively filter with operational amplifiers (LPF). Finally, ADCs are
used to transform the signals in digital ones, directly connected to the
FPGA with a parallel interface.

## SCHEMATICS

### Rectifier and Filter

The rectifier is composed of four fast-recovery Schottky diodes and a
3<sup>rd</sup> filter low-pass filter.

**Analysis of the input waveform:** the current at the input is a
pulsating one
$i_{r}(t) = I_{r}\left| \sin\left( \text{ωt} \right) \right|$. The
average DC value is $\frac{2}{\pi}I_{r}$.

Maybe add some consideration on the harmonic decomposition: MATLAB
**FFT** analysis? Useful to understand the behavior of the filter.

Should we keep only the first harmonic?

Figure 8: Rectifier with the output filter

Diodes are subject to 50% of $i_{r}(t)$. The diodes need a heat-sink in
order to dissipate the heat. The ‘head’ is connected to the cathode and
must be isolated from the others (silicone + mica).  
Average forward current is equal to $\frac{I_{r}}{\pi}$. Two diodes from
Vishay are selected:

|               | $\mathbf{I_F}$ | $\mathbf{V_R}$ | $\mathbf{V_F}$ |
|---------------|----------------|----------------|----------------|
| VS-15TQ060-M3 | 15A            | 60V            | 0.56V          |
| FES16BT-E3/45 | 16A            | 100V           | 0.975V         |

The filter is composed of one capacitor, two inductors and a resistor.
The input is a pulsating wave and the filter has the objective to smooth
the oscillation (reduce the ripple).

We can write the following relation between input and output current in
the frequency domain:

$$I_{\text{bat}}(s) = H_{i}(s)I_{r}(s) - H_{v}(s)V_{\text{bat}}$$

The transfer functions are

$$ H_{i}(s) = \frac{R_{f}\left( 1 + s\frac{L_{f1}}{R_{f}} \right)}{s^{3}C_{f}L_{f1}L_{f2} + s^{2}R_{f}C_{f}(L_{f1} + L_{f2}) + sL_{f1} + R_{f}}$$
$$H_{s}(s) = \frac{sR_{f}C_{f}\left( 1 + s\frac{L_{f1}}{R_{f}} \right)}{s^{3}C_{f}L_{f1}L_{f2} + s^{2}R_{f}C_{f}\left( L_{f1} + L_{f2} \right) + sL_{f1} + R_{f}} $$ 

with DC gains $H_{i}(0) = 1$ and $H_{v}(0) = 0$. Therefore, since we can
consider the battery voltage almost constant, it has no influence on the
filtered current that fully depends on the rectified current. The DC
part is kept, and we have cut-off frequency at: need numerical solution!

Lower cut-off frequency (2<sup>nd</sup> order pole) depends mostly on
the reactive components and not on $R_{f}$. $R_{f}$ has an stronger
influence on the higher cut-off frequency (1<sup>st</sup> order pole).

**Choice of the inductors** $\mathbf{L}_{\mathbf{f}\mathbf{1}}$ **and**
$\mathbf{L}_{\mathbf{f}\mathbf{2}}$

We need inductors in the range 1uH-3uH. Würth Elektronik offers some
compact solutions; another solution is to use classical toroidal one
like the ones from Bourns

|                                                                                                                           | code                | L               | $I_{R}$ | $I_{\text{sat}}$ | $R_{\text{DC}}$ |                                                                                  |
|---------------------------------------------------------------------------------------------------------------------------|---------------------|-----------------|-----------|--------------------|-------------------|----------------------------------------------------------------------------------|
| WE-HCFT                                                                                                                   | 7443762504010       | 1uH             | 39A       | 33A                | 0.86m             |  |
|                                                                                                                           |                     | 7443762504022   | 2.2uH     | 30A                | 23.8A             | 1.78m                                                                            |
|                                                                                                                           |                     |                 |           |                    |                   |                                                                                  |
| **BOURNS**                                                                                                                | **2100LL-1R0-V-RC** | **1uH**         | **21.4A** |                    | **2m**            | <img src="attachment:media/image2.png" style="width:0.456in;height:0.53835in" /> |
|                                                                                                                           |                     | 2100LL-1R5-V-RC | 1.5uH     | 18.5A              |                   | 3m                                                                               |
| **actual selection**                                                                                                      |                     |                 |           |                    |                   |                                                                                  |


https://www.coilcraft.com/en-us/products/power/shielded-inductors/high-current-flat-wire/agp-ver/agm2222/?skuId=30433


### Battery Voltage Sensing

The sensing of the battery voltage is done with an isolated op amp. The
voltage is initially reduced with a voltage divider and it is filtered
with a LPF. The sensor is the ACPL-790B-000E, which has a fix gain of
8.2 with differential input and output. The signal is then referenced to
ground with a differential op amp that includes also LPFs.


|         |         |
|---------|---------|
|<img src="attachment:media/image3.png" style="width:0.592in;height:0.50115in" />| Isolated opamp with $\pm 0.5\%$ High Gain Accuracy with fixed gain $\times8.2$. Supply voltage from 3V to 5.5V for the output side; 5V for the input side. 200kHz bandwidth. DIP-8 package. $V_{in+}\Leftrightarrow\pm$ 200mV recommended. Power consumption: 18.5mA on the input side and 12mA on the output side. The ACPL has an input resistance of 27kOhm |



Figure 9: Voltage sensing stage

In ideal condition (almost constant voltage on $R_{p2}$), the input
differential voltage corresponds to
$v_{\text{in}} = \frac{R_{p2}}{R_{p1} + R_{p2}}v_{\text{bat}}$ and the
cut-off frequency of the input filter is
$f_{\text{vi}} = \frac{1}{2\pi R_{\text{vf}}C_{\text{vf}}}$. We also
need $R_{\text{vf}} \gg R_{p2}$ to have a “simplified” version of the
cut-off frequency

Full transfer function $V_{\text{bat}} \rightarrow V_{\text{in}}$ is
$H(s) = \frac{R_{p2}}{R_{p1} + R_{p2}}\frac{1}{1 + s\left( R_{\text{vf}} + \frac{R_{p2}R_{p1}}{R_{p1} + R_{p2}} \right)C_{\text{vf}}}$

Take care that the input to the differential opamp has to have an
amplitude less than 200mV.

The final op amp has a static gain of $\frac{R_{v2}}{R_{v1}}$ and a
cut-off frequency of $f_{\text{vo}} = \frac{1}{2\pi R_{v2}C_{v}}$.

The total chain gain is:
$\gamma_{v_{\text{bat}}} = \frac{R_{p2}}{R_{p1} + R_{p2}}8.2\frac{R_{v2}}{R_{v1}}\ $
with two cut-off frequency for a LPF.



Figure 10: gain and filter chain under approximation

The voltage sensor needs to be powered from both sides. On the battery
side it requires a 5V supply. To ensure it we can take the battery
voltage and stabilize it through a linear regulator. We need to consider
that the drop voltage will be high, i.e. we are reducing to 5V and input
voltage of about 60V. One option that is able to bear this input voltage
is the ZXTR2105FF, which allows a maximum input voltage of 60V. Bypass
capacitors of 1uf and 10uF are suggested, 1uF in input highly suggested
with high input voltage. Are these capacitors available in SMD format?

For flexibility, a choice between battery voltage and external supply is
possible through a jumper.

Figure 11: 5V linear voltage regulator on the battery side

### Battery Current Sensing

The current is sensed with a Hall Effect sensor (HO 10-P or HO 6-P). The
sensor measures the current that is flowing through a wire winded on it
($N$ turns). The output voltage depends on a fixed gain and on an offset
defined by $V_{\text{ref}}$.

$$v_{\text{sens}} = 0.1 \times N \times i_{\text{bat}} + V_{\text{ref}} \qquad ???$$

|         |         |
|---------|---------|
| **HO 6-P**  | Hall effect sensor. Theoretical sensitivity of 100 mV/A. Measure primary current range $\pm$20A. Primary nominal rms current 6A. The internal reference is set to 2.5V (measure current around zero) and supply voltage (FPGA side) is 5V. Current consumption of 19-25 mA. Output range $V_{out}-V_{ref}=\left[-2,2\right] At I_P=0$ the output voltage is $V_{out}=V_{ref}+V_{OE}$ |
| **HO 10-P** | Theoretical sensitivity of 80 mV/A. Measure primary current range $\pm$25A. Primary nominal rms current 10A. |



Figure 12: Operational principle of HO x-P

$$V_{\text{out}} = 0.08N_pI_p + \epsilon + V_{\text{OE}},\quad\quad V_{\text{OE}} \in \lbrack -10,10\rbrack\text{mV}$$

The output of the sensor is then conditioned in order to attenuate the
amplitude and filter it with a LPF. There is a first stage reducing and
filtering, then the opamp could be use either to as a voltage follower
or an amplifier (gain>1).


Figure 13: Current sensing stage

The LPF cut-off frequency is
$f_{i} = \frac{1}{2\pi\left( R_{if1}\text{//}R_{if2} \right)C_{\text{if}}}$
with DC gain $\frac{R_{if2}}{R_{if1} + R_{if2}}$ and the gain of the op
amp is $1 + \frac{R_{i2}}{R_{i1}}$



### ADC 
```{margin} 
<sup>1</sup> Version AD7825 has two ADCs on the same chip and the output bits are
shared.
```
The last stage for the sensing is in an ADC. The AD7822<sup>1</sup> is used, it
is a 8-bit half-flash ADC. It has a conversion time of 420ns and the
output bits are in parallel. It can be supplied with 3V or 5V, with
respectively input range of **2Vpp** or **2.5Vpp**.

<u>The ground is shared with the FPGA and it is different from the one
of the battery by design.</u>

LINK to PDF file <a href = "Moon_2011_Schematic Boost Converter FPGA.pdf" target="_blank"> Moon converter. </a>

<!-- Pin connections:

<table>
<colgroup>
<col style="width: 45%" />
<col style="width: 54%" />
</colgroup>
<tbody>
<tr class="odd">
<td><ul>
<li><p>To GND</p>
<ul>
<li><p>VMID (through 100nF cap)</p></li>
<li><p>VREF (through 100nF cap)</p></li>
<li><p>AGND</p></li>
<li><p>DGND</p></li>
<li><p>CS</p></li>
</ul></li>
</ul></td>
<td><ul>
<li><p>RD with EOC to FPGA with 1k resistor</p></li>
<li><p>CONVST to FPGA with 1k resistor</p></li>
<li><p>PD to VDD</p></li>
<li><p>VDD with bypass (through 100nF , 10uF)</p></li>
</ul></td>
</tr>
</tbody>
</table> -->

Pin connections:
 - **To GND**
   - VMID (through 100nF cap)
   - VREF (through 100nF cap)
   - AGND
   - DGND
   - CS	
 - **RD** with **EOC** to FPGA with 1k resistor
 - **CONVST** to FPGA with 1k resistor
 - **PD** to **VDD**
 - **VDD** with bypass (through 100nF , 10uF)


Figure 14: Circuit for the ADC

## PCB board

### Connectors

-   Power input/output: banana connectors
-   40pin GPIO connector for the FPGA: TSS-120-02-G-D
-   Extra strip for extra pin and FPGA debugging

### Components list (BOM)

|            | values       | Description                                      | code                         | manufacture         |
|------------|--------------|--------------------------------------------------|------------------------------|---------------------|
| RECTIFIER  |              |                                                  |                              |                     |
| D1-D4      | ×4           | Schottky diode 60V and 15A                       | VS-15TQ060-M3                | Vishay              |
|            |              | Alternative 100V and 16A                         | FES16BT-E3/45                | Vishay              |
|            | ×1           | heat sink for the diodes and isolation with mica |                              |                     |
| x          |              | Heat sink (need holes on the pcb)                | CR101-75AE(VE)               | Ohmite              |
|            |              | Clip for TO-220                                  | CLA-TO-21E                   |                     |
| Cf         | 10 μF        | CAP FILM 100VDC (63VAC)                          | MMK22.5106K100D19L4TRAY      | Kemet               |
| Lf1        | 1uH (2.1μH)  | TOROID INDUCTOR 1uH LOW LOSS VERTCL MT           | 2100LL-1R0-V-RC              | BOURNS              |
| Lf2        | 1uH (2μH)    | TOROID INDUCTOR 1uH LOW LOSS VERTCL MT           | 2100LL-1R0-V-RC              | BOURNS              |
| Rf         | 250 Ω        | through-hole resistance ¼W                       |                              |                     |
| ADC        |              |                                                  |                              |                     |
| U1-U2      | ×2           | 8-bit ADC (PDIP)                                 | AD7822BNZ                    | ANALOG DEVICES      |
| ×4         | 1 kΩ         | SMD                                              | For ADC-FPGA connection      |                     |
| ×6         | 100nF        | SMD                                              | standard                     |                     |
| ×2         | 10 uF        | polarized capacitor 25V                          |                              |                     |
| SENSING    |              |                                                  |                              |                     |
| U3         | ×1           | 10A/6A current sensor                            | ~~HO 10-P~~ / **HO 6-P**     | LEM                 |
| U4         | ×1           | PDIP 3V ×8.2+0.5%                                | ACPL-790B-000E               | Broadcom Limited    |
| U5         | ×1           | operational amplifier (PDIP)                     | MCP6271(2)                   | Microchip           |
|            | alternatives | operational amplifier (SOIC)                     | OPA2350                      | TI                  |
|            |              | 4.5V                                             | TLC070                       | TI                  |
|            |              | PDIP, still stocks but no more produced          | OPA350                       | TI                  |
| U6         | ×1           | 5V voltage regulator (SOT)                       | ZXTR2105FF-7                 | DIODES incorporated |
|            | ×13          | through-hole resistance ¼W                       |                              |                     |
|            | ×9           | SMD resistor                                     |                              |                     |
|            | ×4           | SMD capacitor                                    |                              |                     |
|            | ×8           | Film capacitor standard                          |                              |                     |
| CONNECTORS |              |                                                  |                              |                     |
| J1-J4      | ×4           | Banana connectors                                |                              |                     |
| J14-J13    | ×2           | Terminal block                                   | Screw block with 9.53mm step |                     |
| TP         | ×6           | Test point 1.6mm                                 | For Vt, Vr and Vbat          |                     |
| JP1        | ×1           | current jumper 20mm                              |                              |                     |
| J5         |              | 40pin connector to FPGA                          | TSS-120-02-G-D               | SAMTEC              |
| J6         |              | HDR 1×3                                          | 5V 3.3V selection            |                     |
| J7         |              | HDR 1×5                                          | For H-bridge                 |                     |
| J8         |              | HDR 2×6                                          | Extra pin                    |                     |
| J9         |              | HDR 1×2                                          | External Vcc, battery side   |                     |
| J10        |              | HDR 1×3                                          | Selection for 5V regulator   |                     |
| J11-J12    | ×2           | HDR 1×2                                          | ADC input for oscilloscope   |                     |
| TP         | ×2           | Test point 1mm                                   | ADC input                    |                     |





