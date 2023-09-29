# ADCs

```{margin} 
<sup>1</sup> Version AD7825 has two ADCs on the same chip and the output bits are
shared.
```
The last stage for the sensing is in an ADC. The AD7822<sup>1</sup> is used, it
is a 8-bit half-flash ADC. It has a conversion time of 420ns and the
output bits are in parallel. It can be supplied with 3V or 5V, with
respectively input range of **2Vpp** or **2.5Vpp**.

<u>The ground is shared with the FPGA and it is different from the one
of the battery by design choice.</u>

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




```{figure} ../images/RC_ADC_connections.png
---
width: 500px
---
Circuit for the ADC
```
