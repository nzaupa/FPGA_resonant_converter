%% INITIALIZE
clearvars
clc

time_scale = 1e-9; % (ns)

freq_sin = 50e3;
freq_ADC = 10e6;

nbit = 14;

var_A = 'SIGNAL_A';
var_B = 'SIGNAL_B';


%%
number_period = 1;
phase_A = 0;
phase_B = 0;

t = 0:inv(freq_ADC):number_period/freq_sin-inv(freq_ADC);

sign_A = sin(2*pi*freq_sin*t+phase_A);
sign_B = sin(2*pi*freq_sin*t+phase_B);

sign_A = [sign_A zeros(size(sign_A))];
sign_B = [sign_B zeros(size(sign_B))];
t = [t t+t(2)-t(1)+t(end)];

% binarize the signal

sign_A_b = (sign_A+1)/(abs(max(sign_A))+abs(min(sign_B)))*(2^nbit-1);
sign_B_b = (sign_B+1)/abs((max(sign_B))+abs(min(sign_B)))*(2^nbit-1);

A_b = dec2bin(sign_A_b,nbit);
B_b = dec2bin(sign_B_b,nbit);

tmp = (sign_A_b-8191).*(sign_B_b-8191)/8191;

A_sign = [repmat(['0b'],size(A_b,1),1) dec2bin(sign_A_b,14) repmat(['00s16'],size(A_b,1),1)];
B_sign = [repmat(['0b'],size(A_b,1),1) dec2bin(sign_A_b,14) repmat(['00s16'],size(B_b,1),1)];

A_tmp = bin2dec(A_sign);
B_tmp = bin2dec(B_sign);

figure(1), clf, hold on
    stairs(t,sign_A_b)
    stairs(t,sign_B_b)
%     stairs(t,A_tmp)
%     stairs(t,B_tmp)
%     stairs(t,tmp)
%     stairs(t,(tmp>0)*max(tmp))
    
    grid on
    grid minor



%% export to .v file

% _VariableName_ = _nbit_'b_bits_;

file_ID = fopen('sine_10MSPS_zero.v','w');

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

%% GENERATE running CODE SINE-COSINE

file_ID = fopen('sine_10MSPS_periodic_zero.v','w');

fprintf(file_ID,'// timing for creating two sin waves\n');
fprintf(file_ID,'// phase shift: A = %i, B = %i\n',phase_A*180/pi,phase_B*180/pi);
fprintf(file_ID,'// frequency waves: %i kHz\n',freq_sin/1e3);
fprintf(file_ID,'// frequency ADC: %i MSPS\n',freq_ADC/1e6);
fprintf(file_ID,'// number of samples: %i\n',length(A_b));
fprintf(file_ID,'\n\n');

fprintf(file_ID,'initial begin\n');
fprintf(file_ID,'\ti = 0;\n');

for i = 1:length(t)
    fprintf(file_ID,strcat('\t',var_A,'[',num2str(i-1),']','%c=%c',num2str(nbit),'%cb',A_b(i,:),';\n'),32,32,39);
    fprintf(file_ID,strcat('\t',var_B,'[',num2str(i-1),']','%c=%c',num2str(nbit),'%cb',B_b(i,:),';\n'),32,32,39);
end

fprintf(file_ID,'end\n');
fclose(file_ID);





%%
tt = 0:inv(freq_ADC*100):0.5/freq_sin;

figure(2); clf, hold on
    grid on
    grid minor
    plot(tt,sin(2*pi*freq_sin*tt)*100)
    yline(1)
    yline(2)
    yline(3)

    
%%
jump = (sign_A_b-8191-1966)*707-(sign_B_b-8191)*707;

figure(3); clf, hold on
    grid on
    grid minor
    stairs(0:length(t)-1,jump/max(abs(jump)))%*max((sign_B_b-8191)))
    stairs(0:length(t)-1,(jump<0))%*max((sign_B_b-8191)))
%     plot(0:length(t)-1,(sign_B_b-8191))
% ylim([-0.1,1.1])
% xlim([0,20])

%% sin approximation

% sin(pi*x/2) = 1/2(x^3-3x)

x = 0:0.01:2;
tb1 = sin(pi*x/2);
tb2 = -1/2*(x.^3-3*x);

figure(4), clf, hold on
plot(x,tb1,'r')
plot(x,tb2,'b')
grid on
grid minor
legend('sin','approx')


%% theta
theta  = 0:314;
stheta = round(sin(theta/100)*100);
ctheta = round(cos(theta/100)*100);
figure(5), clf, hold on

plot(theta/100,stheta,'-o','MarkerSize',2)
plot(theta/100,ctheta,'-o','MarkerSize',2)
grid on
grid minor



    
    
