# Computation of the constants for the LLC simulator


# parameters
L   = 10    # uH
C   = 850   # nF
Lm  = 30    # uH
Req = 4200  # mOhm
Vg  = 24000 # mV
dt  = 10    # ns

print('Considering integer operations')
print('  mu_1 = '+str(round( (dt*(2**20))/(1000*C),2)))
print('  mu_2 = '+str(round(-dt/L,2)))
print('  mu_3 = '+str(round( (dt*Vg)/L,2)))
print('  mu_4 = '+str(round(-(dt*Req*(2**10))/(L*1e6),2)))
print('  mu_5 = '+str(round(-(dt*Req*(2**17))*(1+L/Lm)/(L*1e6),2)))
print('  mu_6 = '+str(round( (dt*Req*Vg)/(L*1e6),2)))

# # parameters
# L   = 10    # uH
# C   = 850   # nF
# Lm  = 36    # uH
# Req = 10000 # mOhm
# Vg  = 48    # V
# dt  = 10    # ns

# print('Considering integer operations')
# print('  mu_1 = '+str(round( (dt*(2**20))/(1000*C),2)))
# print('  mu_2 = '+str(round( (dt*Vg*1000)/L,2)))
# print('  mu_3 = '+str(round(-dt/L,2)))
# print('  mu_4 = '+str(round(-dt/L,2)))
# print('  mu_5 = '+str(round(-(dt*Req*(2**17))*(1+L/Lm)/(L*1e6),2)))
# print('  mu_6 = '+str(round(-(dt*Req*(2**10))/(L*1e6),2)))
# print('  mu_7 = '+str(round( (dt*Req*Vg)/(L*1000),2)))
