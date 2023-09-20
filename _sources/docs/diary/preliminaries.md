# Preliminary work

Power specifications:
 - Battery voltage: 40V
 - Maximum Power: 500W
 - Maximum output current: 10A
Therefore, more or less, we have 10A current at the input, ...


ADC for the resonant tank are limited to 0.5V (1Vpp)

Bypass capacitors must be used near to all the power supply pins.

FPGA should have enough power to power-up the sensing circuit at battery level: 

$$ 5V @ 12A     and     3.3V @ 8A $$
