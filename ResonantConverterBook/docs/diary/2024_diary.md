# Diary 2024

## January 2024
Went back to work on it after a long period dedicated to the lecture at UPS.

1st week of January - Found a (the) problem in the state machine. Regularization cannot be applied to jumpsets signals since two out of four are only an impulse, therefore it cannot be regularized. We might think to different variable that could be controlled/regularized. To discover this I simulated the controller with ModelSim feeding waveform from a PSIM simulation (directly vC and iC of the ADC).

2nd week of January - Try to set up a simulator for the dynamics of the converter. So far it seems good, I discovered of the priority of arithmetic vs logic operations. This took me several hours of trial and error among ModelSim, PSIM and MATLAB.

9 January - Simulation module for LLC is working, a module to transform the output to an ADC like is missing.

30 January - start to write the draft for a Transaction paper and lunch the discussion on it.

March - start to going back to work on the charger application using what Carlos has prepared on the comparison with different Quality factors.

1 March - the $phi$-control law (and possibly also the $theta+phi$) can be cast as checking where the trajectory in $x$ (non-shifted coordinates) is in the phase-plane, without the need of the shift. This implies that just a state machine which ensures the right order (i.e. prevents to go back) should be enough.

12 March - start to put together the things used for the future TPIE paper


Long long break

During April, I mostly focus my self on the writing of the thesis. Trying to harmonize the mathematical description and modeling took more than expected.

3 May 2024 - Merge of the note on the design of the prototype on the thesis

5 May - Start of the 4-weeks period in Tarragona to try to ultimate the prototype.


