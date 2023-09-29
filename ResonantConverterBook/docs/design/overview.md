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




### DSP 

The resolution that we can reach with a fft is equal to 1/time_window.
E.g. we are sampling at 100Mhz a window of 500us
(N=500us\*100Mhz=50000), the minimum frequency that we can discriminate
is 2kHz = 1/500us

