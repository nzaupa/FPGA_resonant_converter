This folder contains the `*.sof` files that can be directly uploaded to the FPGA

 - `TOP_HybridControl_theta_phi_OL-20240510-working_final.sof`: this files contains all the things to test the control laws in open-loop.
   - $\theta$-control is implemented as the day 0
   - $\varphi$-control is implemented in the $z$-plane
   - $(\varphi,\delta)$-control is implemented in the $x$-plane
   - There is the possibility to change with external buttons
     - $\varphi$ button
     - $\delta$ button
     - dead-time with dip-switch
     - show ADC values on 7-segment display

 - `someother`