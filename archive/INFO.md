This folder contains the `*.sof` files that can be directly uploaded to the FPGA

 - `TOP_HybridControl_theta_phi_OL-20240510-working.sof`: this files contains all the things to test the control laws in open-loop.
   - $\theta$-control is implemented as the day 0
   - $\varphi$-control is implemented in the $z$-plane
   - $(\varphi,\delta)$-control is implemented in the $x$-plane
   - There is the possibility to change with external buttons
     - $\varphi$ button
     - $\delta$ button
     - dead-time with dip-switch
     - show ADC values on 7-segment display

 - `TOP_HybridControl_theta_phi_OL-20240510-working_x.sof`: this files contains an updated version of the one before. The control law with PHI has been implemented in the $x$-plane. This improved the range in which the control law is able to work. Essentially, now it can go full range with the angle.
   - $\theta$-control is implemented as the day 0
   - $\varphi$-control is implemented in the $x$-plane
   - $(\varphi,\delta)$-control is implemented in the $x$-plane
   - There is the possibility to change with external buttons
     - $\varphi$ button
     - $\delta$ button
     - dead-time with dip-switch
     - show ADC values on 7-segment display