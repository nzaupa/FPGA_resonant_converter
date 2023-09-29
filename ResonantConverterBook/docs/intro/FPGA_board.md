
# FPGA board

explanation of the peculiarities of the board, ADC extension included.


## Daughter board with ADCs and DACs


(sec:BALUN)=
### BALUN circuit

BALUN (*balanced-unbalanced*) is a circuit use to transform an unbalanced signal to a balanced one.
Usually, an input series-resistance is used for impedance matching so that the
output voltage corresponds to the input before the resistance (it is the
double of the one in **B+**-**B-**)

```{figure} ../images/FPGA_balun.png
---
width: 500px
---
Schematics BALUN circuit in the daughter board.
```

More info at this <a href = "https://www.digikey.com/en/articles/understanding-the-rf-balun-and-its-transformative-function" target="_blank"> link</a> from Digikey.



