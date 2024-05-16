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

```{figure} ../images/diary/scope_sensing_current_1-20240510.png
---
width: 400px
---
Distortion in the tank current sensing. Current (yellow), voltage after the transformer (green), voltage after the 49.9Ohm or at the input of the ADC card (purple).
```

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
Nice tutorial on operators <https://documentation-rp-test.readthedocs.io/en/latest/tutorfpga04.html>.
I'm spending a lot of time in debugging the saturation...
In the end, it is working by restraining the value of phi to 7-bit (64 max), which is a kind of brute force saturation.
I've tested the saturation block alone and they are working fine.
In the end, I make it work by cutting down the computed valued of $phi$ to `8bit=sign+7bit`. In my opinion it should work also with the 32 bit, but for some reasons it was always limiting to the maximum value. Probably there were some bit that were given problem, so that the phi after the PI was larger than 90, but due to some other reason, and the most useful information was standing in the first bits.
Final consideration: it is WORKING. Strange but true, now I need to show how to compute the gains based on some design specification.

```{figure} ../images/diary/scope_CL_UP_DOWN.png
---
width: 400px
---
Output current (green) that stabilizes to different set-points changed with the buttons. In yellow the input current.
```


15 May - An archive copy of the code has been created. The converter starts to work badly over some level of input voltage, essentially there is noise entering the tank sensing. Also, working with high currents, heat up a lot the converter (resonant capacitor and inductor, load, and cables).
It seems that the sensing range for the tank is respected, anyway it starts doing nap-nap (n'importe quoi ×2).
I'm trying to understand the behavior of the tank+filter in open loop in order to have a bare model of the system. Yet, I'm not able to remember why the behavior is asymmetric with a resistive load. Ok, the damping in the resonant tank changes ($R_{eq}$), but not the one in the filter.
Probably we can see them as two separated blocks:
 - the tank with its second order response (LLC is 3rd, answer to sinusoidal should be 2nd...)
 - the filter with its second order LPF characteristic.
Essentially, the tank is modulating the current envelope, while the filter is smoothing this envelope.
> When increasing the input voltage, the resonant tank start glitching (switching $\sigma$ when not expected). I tried to extend the regularization time in the control: no difference.
For the asymmetry for low $\varphi$ the problem is coming from the current sensing that is introducing an asymmetric scaling.
Trying to solve this by connecting two resistors directly to the output of the signal transformer (there are four 49.9Ohm resistors that connect the transformer to the ADC): this hasn't solved the problem, even, it seems to amplify more the noise. Just some extra work since the layout was more complicated than expected.


```{figure} ../images/diary/scope_sensing_current_2-20240515.png
---
width: 400px
---
Distortion in the tank current sensing, still there after the layout changes. Current (yellow), voltage after the transformer (purple), voltage after the 49.9Ohm or at the input of the ADC card (green).
```

In the night I fixed the problem with the simulation analysis. There was a wrong consideration in the `DSP_analysis.m` (loc is empty if there is no peak); then there was an error in the implementation of $\theta$-control law in the $x$-plane (it can actually re-cross the line if there is no shift, so the jump set definition must be different). Fixed the integration step to 10ns, 5ns for $\theta$ in the $z$-plane since needs more precision. Moreover, having a variable integration step was giving problem with the FFT.
Finally, I don't see the advantage of the control law in the $z$-plane, the one in the $x$ plane from Ricardo seems better (lower frequency peak and nicer input-output relation).



16 May - Start to stare at the electronic load. The behavior with a battery as a load is pretty different, a higher output current can be reached with higher values of $\varphi$.
I'm trying to make the code more robust by adding an over-voltage protection and a restart when it turns OFF when not desired. End: OverVoltage works, the RESTART does not (it is more complicated since it could make the RESET signal remaining low causing the converter to stay OFF).

In the afternoon I tried to connect the electronic load (EL). More or less it works, but it is hard to turn on the converter due to the Over Voltage protection.
Setup: EL at 20V and Vg=24V.
Essentially, at the turn-ON the EL voltage goes higher than the selected 20V, specifically higher than the OV limit, causing the converter to shut down. What we can see from the oscilloscope is that the voltage at the output is rising and then it goes down. TO overcome the protection problem, we can turn on the converter in OL with $\varphi=50$, then we can go down with $\varphi$ until we match a current value and the reference, at that point we switch to the CL control. This works and then we can regulate from 0.5A to 5A.
**If we remove the OV protection**, the converter starts "normally" and reaches the desired operating point. But, what is interesting is the behavior at the turning-ON: Vout rises and then drops, and it does this few times (~5) in a triangular fashion, until it stabilize to the set Vout. In the meanwhile, the current drained by the load has spikes, they disappear once the voltage is stable and then the current converges towards the desired point.

```{figure} ../images/diary/scope_ElectronicLoad_startup.png
---
width: 400px
---
Current (purple) and voltage (green) at the electronic load during the startup phase.
```






