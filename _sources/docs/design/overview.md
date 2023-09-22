# Overview

**Analysis of the requirements that we want to achieve**

Power specifications:
 - Battery voltage: 40V
 - Maximum Power: 500W
 - Maximum output current: 10A
Therefore, more or less, we have 10A current at the input, ...


ADC for the resonant tank are limited to 0.5V (1Vpp)

Bypass capacitors must be used near to all the power supply pins.

FPGA should have enough power to power-up the sensing circuit at battery level: 

$$ 5V @ 12A     \quad\mbox{and}\quad     3.3V @ 8A $$


## add some common knowledge
i.e. transformer model, how impedance move between primary and secondary



### BALUN circuit

It’s a circuit use to transform an unbalanced signal to a balanced one.
An input series-resistance is used for impedance matching to that the
output voltage corresponds to the input before the resistance (it is the
double of the one in **B+**)

<img src="attachment:media/image5.png" style="width:6.26806in;height:1.48542in" />

Figure 15: schematics of the BALUN circuit

### DSP 

The resolution that we can reach with a fft is equal to 1/time_window.
E.g. we are sampling at 100Mhz a window of 500us
(N=500us\*100Mhz=50000), the minimum frequency that we can discriminate
is 2kHz = 1/500us

