%% INITIALIZE
clearvars
clc

time_scale = 1e-9; % (ns)

nbit = 14;

var_A = 'SIGNAL_A';
var_B = 'SIGNAL_B';

% create the fictituis data set
load('data/Experimental/data_exp_R101.mat')
data   = DATA(31).full;
t_tmp  = data.t-data.t(1);
iC_tmp = data.iC_bare;
vC_tmp = data.vC_bare;
fs     = 100e6;
t      = 0:1/fs:t_tmp(end);
dif    = abs(t_tmp-t);
[M,I]  = min(dif);
t      = t_tmp(I);
iC     = iC_tmp(I);
vC     = vC_tmp(I);

iC_scaled = round( iC/max(abs(iC))*2^(nbit-1)*0.9 );
vC_scaled = round( vC/max(abs(vC))*2^(nbit-1)*0.9 );





%%

A_b = dec2bin(iC_scaled,nbit);
B_b = dec2bin(vC_scaled,nbit);

A_sign = [repmat(['0b'],size(A_b,1),1) dec2bin(iC_scaled*4,14) ];
B_sign = [repmat(['0b'],size(A_b,1),1) dec2bin(vC_scaled*4,14) ];

A_sign = A_sign(:,1:end-2);
B_sign = B_sign(:,1:end-2);

%% export to .v file

% _VariableName_ = _nbit_'b_bits_;

file_ID = fopen('iC_loop_test.v','w');

fprintf(file_ID,'// samplings of current and voltage\n');
fprintf(file_ID,'\n\n');

for i = 1:length(t)
    fprintf(file_ID,'CLK_ADC%c=%c1%cb1;\n',32,32,39);
    fprintf(file_ID,strcat(var_A,'%c=%c',num2str(nbit),'%cb',A_b(i,:),';\n'),32,32,39);
    fprintf(file_ID,strcat(var_B,'%c=%c',num2str(nbit),'%cb',B_b(i,:),';\n'),32,32,39);
    fprintf(file_ID,'#50;\nCLK_ADC%c=%c1%cb0;\n#50;\n',32,32,39);
end



fclose(file_ID);


    
    
