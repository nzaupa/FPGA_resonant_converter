# PCB design

3 pins diode has been used due to the fast recovery time






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



### Mounted components

number in the () is the nominal one


|Filter   |                 | | |Current   |                | |Voltage  |                |
|---------|-----------------|-|-|----------|----------------|-|---------|----------------|
|$C_f$    |22 μF            | | |sens      |LEM HO 10P/SP33 | |sens     |ACPL-790B-000E  | 
|         |M108137228       | | |$R_{OCD}$ |18 kΩ           | |$R_{p1}$ |47.3 (47) kΩ    |
|$L_{f1}$ |2.2 μH           | | |$R_{if1}$ |3.89 (3.9) kΩ   | |$R_{p2}$ |121 (120) Ω     |
|$L_{f2}$ |2.2 μH           | | |$R_{if2}$ |10 (10) kΩ      | |$R_{vf}$ |? (3.3) kΩ      | 
|         |WE 7443762504022 | | |$C_{if}$  |3.35 (3.3) nF   | |$C_{vf}$ |? (10) nF [film]|
|$R_f$    |0.33 Ω @5%       | | |$R_{i1}$  |SC 0 Ω          | |$R_{v1}$ |10 (10) kΩ      |
|         |                 | | |$R_{i2}$  |OC $\infty$     | |$R_{v2}$ |12.15 (12) kΩ   |
|         |                 | | |          |                | |$C_v$    |1.03 (1) nF     |


- Diodes MBR B20100
- rail-to-rail OPAMP 


