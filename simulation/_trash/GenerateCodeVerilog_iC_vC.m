%% INITIALIZE
clearvars
clc

time_scale = 1e-8; % (ns)

nbit = 14;

var_A = 'iC';
var_B = 'vC';
var_C = 'sigma';

% data = PSIM_import('test_vC_iC-low_real-1e-8.csv');
data = PSIM_import('test_sigma.csv');

% iC_scaled = round( iC/max(abs(iC))*2^(nbit-1)*0.9 );
% vC_scaled = round( vC/max(abs(vC))*2^(nbit-1)*0.9 );





%%
t_min = 1+0*20000;
t_max = length(data.t)+0*25000;

iC = dec2bin(data.ADC_iS,nbit);
vC = dec2bin(data.ADC_vC,nbit);
sigma = dec2bin(round(data.Vs/23),1);
sigma = sigma(:,end-1:end);

figure(5), clf, hold on
    stairs(data.t,data.ADC_iS)
    stairs(data.t,data.ADC_vC)
    xlim(data.t([t_min,t_max]))
    plot_layout(gca)

% A_sign = [repmat(['0b'],size(iC,1),1) dec2bin(iC_scaled*4,14) ];
% B_sign = [repmat(['0b'],size(iC,1),1) dec2bin(vC_scaled*4,14) ];
% 
% A_sign = A_sign(:,1:end-2);
% B_sign = B_sign(:,1:end-2);

%% export to .v file

% _VariableName_ = _nbit_'b_bits_;

file_ID = fopen('iC_vC_test_and_sigma.v','w');

fprintf(file_ID,'// samplings of current and voltage\n');
fprintf(file_ID,'\n\n');

for i = t_min:t_max
    fprintf(file_ID,'CLK_ADC%c=%c1%cb1;\n',32,32,39);
    fprintf(file_ID,strcat(var_A,'%c=%c',num2str(nbit),'%cb',iC(i,:),'; // iC=%5i \n'),32,32,39,data.ADC_iS(i));
    fprintf(file_ID,strcat(var_B,'%c=%c',num2str(nbit),'%cb',vC(i,:),'; // vC=%5i \n'),32,32,39,data.ADC_vC(i));
    fprintf(file_ID,strcat(var_C,'%c=%c',num2str(2),'%cb',sigma(i,:),'; // sigma=%s \n'),32,32,39,sigma(i,:));
    fprintf(file_ID,'#5;\nclk_100M%c=%c1%cb0;\n#5;\n',32,32,39);
end



fclose(file_ID);


    
    
