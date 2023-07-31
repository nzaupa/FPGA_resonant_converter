%% INITIALIZE
clearvars
clc

time_scale = 1e-9; % (ns)

freq_sin = 50e3;
freq_ADC = 10e6;

nbit = 14;

var_A = 'SIGNAL_A';
var_B = 'SIGNAL_B';

% twos complement
tc = 1;

%% GENERATE SIGNALS
number_period = 3;
phase_A = 0;
phase_B = pi/2;

t = 0:inv(freq_ADC):number_period/freq_sin-inv(freq_ADC);

sign_A = sin(2*pi*freq_sin*t+phase_A);
sign_B = sin(2*pi*freq_sin*t+phase_B);

% binarize the signal
sign_A_b = sign_A*(2^(nbit-tc)-1);
sign_B_b = sign_B*(2^(nbit-tc)-1);

A_b = dec2twobin(sign_A_b,nbit);
B_b = dec2twobin(sign_B_b,nbit);

figure(1), clf, hold on
    stairs(t,sign_A_b)
    stairs(t,sign_B_b)
    
    grid on
    grid minor

    
%% LOAD SIGNALS
load('data_real.mat')
t = (0:length(z1)-1)*(t(2)-t(1));
t_S = t;
sample = 1:10:10000;
t  = t(sample); t_S = t;
vC = vC(sample);
iC = iC(sample);
z1 = z1(sample);
z2 = z2(sample);
sigma_S= sigma(sample);

freq_ADC = inv(t(2)-t(1));

sign_A = vC/100;
sign_B = iC/3;

% binarize the signal
sign_A_b = sign_A*(2^(nbit-tc)-1);
sign_B_b = sign_B*(2^(nbit-tc)-1);

A_b = dec2twobin(sign_A_b,nbit);
B_b = dec2twobin(sign_B_b,nbit);

figure(1), clf, hold on
    stairs(t,sign_A_b)
    stairs(t,sign_B_b)
    
    grid on
    grid minor
    
% _VariableName_ = _nbit_'b_bits_;

file_ID = fopen('SRC_simulink_10MSPS_two_compl.v','w');
fprintf(file_ID,'// Data from SRC simulation in Simulink\n');
fprintf(file_ID,'// frequency ADC: %i MSPS\n',freq_ADC/1e6);
fprintf(file_ID,'\n\n');

for i = 1:length(t)
    fprintf(file_ID,strcat(var_A,'%c=%c',num2str(nbit),'%cb',A_b(i,:),';\n'),32,32,39);
    fprintf(file_ID,strcat(var_B,'%c=%c',num2str(nbit),'%cb',B_b(i,:),';\n'),32,32,39);
    fprintf(file_ID,'#%i;\n',round(inv(freq_ADC*time_scale)));

end

fclose(file_ID);


%% export to .v file

% _VariableName_ = _nbit_'b_bits_;

file_ID = fopen('sine_10MSPS_two_compl.v','w');

fprintf(file_ID,'// timing for creating two sin waves\n');
fprintf(file_ID,'// phase shift: A = %i, B = %i\n',phase_A*180/pi,phase_B*180/pi);
fprintf(file_ID,'// frequency waves: %i kHz\n',freq_sin/1e3);
fprintf(file_ID,'// frequency ADC: %i MSPS\n',freq_ADC/1e6);
fprintf(file_ID,'\n\n');

for i = 1:length(t)
    fprintf(file_ID,strcat(var_A,'%c=%c',num2str(nbit),'%cb',A_b(i,:),';\n'),32,32,39);
    fprintf(file_ID,strcat(var_B,'%c=%c',num2str(nbit),'%cb',B_b(i,:),';\n'),32,32,39);
    fprintf(file_ID,'#%i;\n',inv(freq_ADC*time_scale));

end

fclose(file_ID);

%% COMPARE IDEAL WITH

B = readtable('list_ModelSim_simulink.txt');
A = table2cell(B);

t  = [A{2:end,1}]'/1e3;
vC = [A{2:end,3}]';
iC = [A{2:end,4}]';
% z1 = [A{2:end,11}]';
% z2 = [A{2:end,12}]';
jumpM = [A{2:end,7}]';
sigM  = -[A{2:end,8}]';

s2  = [A{2:end,13}]';
j1  = [A{2:end,11}]';
j2  = [A{2:end,12}]';



    
    
sigma    = zeros(size(t));
sigma(1) = 1;
z1   = zeros(size(t));
z2   = zeros(size(t));
jump = zeros(size(t));
for i=1:length(sigma)
    z1(i)   = vC(i)-sigma(i)*1966;
    z2(i)   = iC(i);
    jump(i) = z1(i)*sin(theta)*1000+...
              z2(i)*cos(theta)*1000;
    sigma(i+1) = -sign(jump(i));%(jump(i)<0)*2-1;
end
sigma(end) = [];

figure(1), clf, hold on
    plot(t,vC)
    plot(t,iC)
    plot(t,jumpM/1000,'LineWidth',1.5)
    plot(t,sigM*max(jumpM)*0.9/1000,':','LineWidth',1.5)
    plot(t,sigma*max(jumpM)*0.9/1000,'+','LineWidth',1.5)
    plot(t,j1/1000,'--or','LineWidth',1.5)
    plot(t,j2/1000,'--ob','LineWidth',1.5)
    plot(t,s2*max(jumpM)*0.8/1000,'om','LineWidth',1.5)
    plot(t_S*1e9,sigma_S*max(jumpM)*1.1/1000,'x','LineWidth',1.2)
    legend('v','i','j','s','s_cpt','j1','j2','s2')
    grid on
    grid minor
    
figure(2), clf, hold on
    plot(t,z1-2e4,'x')
    plot(t,z2-2e4,'x')
    plot(t,jumpM/1000,'LineWidth',1.5)
    plot(t,sigM*max(jumpM)*0.9/1000,':','LineWidth',1.5)
    plot(t,sigma*max(jumpM)*0.9/1000,'+','LineWidth',1.5)
    plot(t,j1/1000,'--or','LineWidth',1.5)
    plot(t,j2/1000,'--ob','LineWidth',1.5)
    plot(t,s2*max(jumpM)*0.8/1000,'om','LineWidth',1.5)
    yline(-2e4)
    legend('v','i','j','s','s_cpt','j1','j2','s2')
    grid on
    grid minor
    
    

