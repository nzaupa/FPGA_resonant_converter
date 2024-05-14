# Diary 2024

## January 2024
Went back to work on it after a long period dedicated to the lecture at UPS.

1st week of January - Found a (the) problem in the state machine. Regularization cannot be applied to jumpsets signals since two out of four are only an impulse, therefore it cannot be regularized. We might think to different variable that could be controlled/regularized. To discover this I simulated the controller with ModelSim feeding waveform from a PSIM simulation (directly vC and iC of the ADC).

2nd week of January - Try to set up a simulator for the dynamics of the converter. So far it seems good, I discovered of the priority of arithmetic vs logic operations. This took me several hours of trial and error among ModelSim, PSIM and MATLAB.

9 January - Simulation module for LLC is working, a module to transform the output to an ADC like is missing.

30 January - start to write the draft for a Transaction paper and lunch the discussion on it.

## Other

March - start to going back to work on the charger application using what Carlos has prepared on the comparison with different Quality factors.

1 March - the $phi$-control law (and possibly also the $theta+phi$) can be cast as checking where the trajectory in $x$ (non-shifted coordinates) is in the phase-plane, without the need of the shift. This implies that just a state machine which ensures the right order (i.e. prevents to go back) should be enough.

12 March - start to put together the things used for the future TPIE paper


Long long break

During April, I mostly focus my self on the writing of the thesis. Trying to harmonize the mathematical description and modeling took more than expected.

## May 2024

3 May 2024 - Merge of the note on the design of the prototype on the thesis

**--- Back in TGN and at Campus Sescelades, Planta 4 ---**

5 May - Start of the 4-weeks period in Tarragona to try to ultimate the prototype. I've arrived in Tarragona pretty fast (6h), but with the managing of the trains a bit sketchy.

6 May - Going back to the work and discuss with Carlos. Try to find the state-machine that is working and then implement the control law in x-coordinates, which should be more robust. There are problems with keeping up the signal and at startup. The signal $\sigma\rightarrow v_S$ seems delayed.


7 May - Checking for the delay: it is actually there, around 600ns. Using $\phi<<1$ creates more glitching. I do not know the reason. The definition of the set in x-coordinates was inverse (1 is negative and 0 positive).
It seems better by taking the zero zone as half plane. At least we cover the case phi=0.
In the end, using regularization, the controller in working with the state-machine in $x$

8 May - Improve the code for controlling values, now it goes up and down, thanks to ChatGPT: tip -> it was enough to manually recognize a button without going through the `posedge`/`negedge`. 
Characterization of the sensor for the current in the output of the rectifier: it takes a lot of time. Measure are done to first evaluate the curve of the sensor and then to link the sensed value to the digital value. When all the chain is known we can compensate for it and show a semi-exact representation.
The same thing is done for the voltage sensor.
The current sensor has an offset and it is pretty much linear.
Instead, the voltage sensor seems to have a slight distortion.

9 May - While testing the current sensor, the characteristic current-voltage remains constant; what does not remain constant in the HEX lecture in the FPGA. It changes every time... I have no idea of the reason. It has been a long day. The test for the output sensor have been done by connecting the power supply directly to the rectifier, without using the bridge.
Many things have been done
 - on the current sensor, change the OPAMP from follower to differential: connect the ground to the Vref point. In this way we are removing the offset and we have a wider range for the current. With the current resistor we can read up to 20A more or less.
 - on the voltage sensor I decrease the range of the input by changing the resistor of the voltage divider from 120 to 180 Ohm. We can go up to 60V before the input of the ACPL reaches the limit value of 200mV.
 - input/output curves have been obtained.
   - voltage: it is linear, but the ACPL seems to have a gain of 4.65 instead of 8.2 (from datasheet). The slop of the line is more or less 3
   - current: now it is linear, without the differential-opamp it seems that the turn ratio N was 0.5 but indeed it is 1. The inclination of the interpolating line is more or less 15.
Now, also the displays showing the decimal value are working. The wire connecting the blocks was not declared, but also I had a module doing the job `num2seg` that was not used.
We could tune in a finer way the sensor. Now it is not that bad, we have an error in the order of 0.2A and 2-7V (higher with higher voltage).

10 May - First thing in the morning... wake up late so that I can not go to the swimming pool :|. Apart from the jokes, I've connected back the H-bridge and all is still working. I had the $22.8\;\Omega$ load connected, I've been able to go down until 500mA more or less at the output with $\varphi=50$.
We can clearly see that also at the resonance the waveform is no more sinusoidal since the quality factor is low.
The open-loop version is at its final stage. I don't think there is more work to do. All the control laws with $\varphi$ are implemented in the $x$-plane and this enhanced the performance of the phase-shift modulation.
There is a problem with the mixed control. We can clearly see that the input voltage is asymmetric. This is due to the fact that there is a bias in the current $i_S$ that is read by the ADC. The reason in not clear since the other switch is correct.
Moreover, check with the oscilloscope, the voltage at the exit of the signal transformer is good and in phase with the measured current. What is shifted, is the current after the $49.9\;\Omega$ resistor.
I tried to change the position of the resistor in the PCB and to disconnect the capacitor, but this had no effect.

11 May - Working in the morning and "climbing" with Ramon and Julia in the afternoon at La Mussara, sector *Can Pistola*.

12 May - Working a bit and then bike ride in the afternoon. 75km long along the coast until Creixell and after towards the inside until Montserri and back through el Catller.

13 May - Try to set up the modules for the closed-loop. I spent much of the morning looking on ways to code a PI with fixed point numbers (i.e. integers).
Carlos suggested a nice book from Luca Corradini et al. *"Digital Control of High-Frequency Switched-Mode Power Converters"*, which contains useful tips for the implementation.
The biggest problem is the scaling having to use only integers numbers. 
Moreover, it is not yet clear how to design formally the closed-loop.
Apart from this, I've cleaned the TOP file and incorporate the debug on the 7 display into a module (the RTL view is cleaner).
The objective is to regulate the current up to 0.1A, but the PI is running with mA resolution to have a margin with the operations and avoid the numbers to be clamped to zero. We work with 32bit integers (probably this could be reduced).
In the end, the converter starts oscillating but it will stop since the control becomes $\varphi=\pi/2$. The objective will be to try to understand why it is going to saturate in that direction. We can see the value of $\varphi$ through the digital probe.

14 May - Starting by cleaning up a bit the TOP and debugging the PI. A problem stands in the saturation which is clamping positive values to the maximum and not the minimum.





