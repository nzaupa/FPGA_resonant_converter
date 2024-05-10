# LAB electronics tips


Representation of unit of measure standard <https://www.nist.gov/pml/special-publication-811/nist-guide-si-chapter-7-rules-and-style-conventions-expressing-values>

```
7.1 Value and numerical value of a quantity

The value of a quantity is its magnitude expressed as the product of a number and a unit, and the number multiplying the unit is the numerical value of the quantity expressed in that unit.

More formally, the value of quantity A can be written as A = {A}[A], where {A} is the numerical value of A when the value of A is expressed in the unit [A]. The numerical value can therefore be written as {A} = A / [A], which is a convenient form for use in figures and tables. Thus, to eliminate the possibility of misunderstanding, an axis of a graph or the heading of a column of a table can be labeled "t/°C" instead of "t (°C)" or "Temperature (°C)." Similarly, an axis or column heading can be labeled "E/(V/m)" instead of "E (V/m)" or "Electric field strength (V/m)."

Examples:

In the SI, the value of the velocity of light in vacuum is c = 299 792 458 m/s exactly. The number 299 792 458 is the numerical value of c when c is expressed in the unit m/s, and equals c/(m/s).
The ordinate of a graph is labeled T/(103 K), where T is thermodynamic temperature and K is the unit symbol for kelvin, and has scale marks at 0, 1, 2, 3, 4, and 5. If the ordinate value of a point on a curve in the graph is estimated to be 3.2, the corresponding temperature is T / (103 K) = 3.2 or T = 3200 K. Notice the lack of ambiguity in this form of labeling compared with "Temperature (103 K)."
An expression such as ln(p/MPa), where p is the quantity symbol for pressure and MPa is the unit symbol for megapascal, is perfectly acceptable, because p/MPa is the numerical value of p when p is expressed in the unit MPa and is simply a number.
Notes:

For the conventions concerning the grouping of digits, see Sec. 10.5.3.
An alternative way of writing c/(m/s) is {c}m/s, meaning the numerical value of c when c is expressed in the unit m/s.
```

## Standard resistance table

Table with E12 and E24 series

<https://eepower.com/resistor-guide/resistor-standards-and-codes/resistor-values/#>

table with color code

<https://www.calculator.net/resistor-calculator.html>


<table class="cinfoT" align="center">
	<tbody><tr valign="bottom" align="center">
		<td class="cinfoHd">Color</td>
		<td class="cinfoHdL">1<sup>st</sup>, 2<sup>nd</sup>, 3<sup>rd</sup><br>Band Significant Figures</td>
		<td class="cinfoHdL">Multiplier</td>
		<td class="cinfoHdL">Tolerance</td>
		<td class="cinfoHdL">Temperature Coefficient</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#000;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Black</td>
		<td align="center">0</td>
		<td align="center">× 1</td>
		<td>&nbsp;</td>
		<td align="center">250 ppm/K (U)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#964b00;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Brown</td>
		<td align="center">1</td>
		<td align="center">× 10</td>
		<td>±1% (F)</td>
		<td align="center">100 ppm/K (S)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#ff0000;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Red</td>
		<td align="center">2</td>
		<td align="center">× 100</td>
		<td>±2% (G)</td>
		<td align="center">50 ppm/K (R)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#ffa500;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Orange</td>
		<td align="center">3</td>
		<td align="center">× 1K</td>
		<td>±0.05% (W)</td>
		<td align="center">15 ppm/K (P)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#ffff00;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Yellow</td>
		<td align="center">4</td>
		<td align="center">× 10K</td>
		<td>±0.02% (P)</td>
		<td align="center">25 ppm/K (Q)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#9acd32;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Green</td>
		<td align="center">5</td>
		<td align="center">× 100K</td>
		<td>±0.5% (D)</td>
		<td align="center">20 ppm/K (Z)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#6495ed;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Blue</td>
		<td align="center">6</td>
		<td align="center">× 1M</td>
		<td>±0.25% (C)</td>
		<td align="center">10 ppm/K (Z)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#9400d3;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Violet</td>
		<td align="center">7</td>
		<td align="center">× 10M</td>
		<td>±0.1% (B)</td>
		<td align="center">5 ppm/K (M)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#a0a0a0;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Grey</td>
		<td align="center">8</td>
		<td align="center">× 100M</td>
		<td>±0.01% (L)</td>
		<td align="center">1 ppm/K (K)</td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#fff;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			White</td>
		<td align="center">9</td>
		<td align="center">× 1G</td>
		<td>&nbsp;</td>
		<td></td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#cfb53b;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Gold</td>
		<td>&nbsp;</td>
		<td align="center">× 0.1</td>
		<td>±5% (J)</td>
		<td></td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#c0c0c0;width:18px;display:inline-block;border: 1px solid #000;">&nbsp;</div>
			Silver</td>
		<td>&nbsp;</td>
		<td align="center">× 0.01</td>
		<td>±10% (K)</td>
		<td></td>
	</tr>
	<tr>
		<td nowrap=""><div style="background-color:#fff;width:18px;display:inline-block;border: 1px solid #fff;">&nbsp;</div>
			None</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>±20% (M)</td>
		<td>&nbsp;</td>
	</tr>
</tbody></table>




