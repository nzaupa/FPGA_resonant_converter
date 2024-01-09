%% INITIALIZE
clearvars
clc

time_scale = 1e-8; % (ns)

nbit = 14;

var_A = 'iC';
var_B = 'vC';

data = PSIM_import('test_vC_iC-low_real-1e-8-theta_165-phi_5.csv');

% iC_scaled = round( iC/max(abs(iC))*2^(nbit-1)*0.9 );
% vC_scaled = round( vC/max(abs(vC))*2^(nbit-1)*0.9 );





%%
t_min = 1; %20000;
t_max = 25000;

iC = dec2bin(data.ADC_iS,nbit);
vC = dec2bin(data.ADC_vC,nbit);


figure(3), clf, hold on
    stairs(data.t,data.ADC_iS)
    stairs(data.t,data.ADC_vC)
    stairs(data.t,data.Vs*100)
    xlim(data.t([t_min,t_max]))
    plot_layout(gca)

% optA.Color='b';
optA.LineStyle='--';
optA.Marker='o';

figure(4), clf, hold on
    plot_hybrid(gca,data.H_FPGA_z1,data.H_FPGA_z2,optA,[],2e5)
    plot(0,0,'kp','MarkerFaceColor','k','MarkerSize',10)
    plot_layout(gca)

% A_sign = [repmat(['0b'],size(iC,1),1) dec2bin(iC_scaled*4,14) ];
% B_sign = [repmat(['0b'],size(iC,1),1) dec2bin(vC_scaled*4,14) ];
% 
% A_sign = A_sign(:,1:end-2);
% B_sign = B_sign(:,1:end-2);

return
%% export to .v file

% _VariableName_ = _nbit_'b_bits_;

file_ID = fopen('iC_vC_test_165_5.v','w');

fprintf(file_ID,'// samplings of current and voltage\n');
fprintf(file_ID,'\n\n');

for i = t_min:t_max
    fprintf(file_ID,'clk_100M%c=%c1%cb1;\n',32,32,39);
    fprintf(file_ID,strcat(var_A,'%c=%c',num2str(nbit),'%cb',iC(i,:),'; // iC=%5i \n'),32,32,39,data.ADC_iS(i));
    fprintf(file_ID,strcat(var_B,'%c=%c',num2str(nbit),'%cb',vC(i,:),'; // vC=%5i \n'),32,32,39,data.ADC_vC(i));
    fprintf(file_ID,'#5;\nclk_100M%c=%c1%cb0;\n#5;\n',32,32,39);
end


%     fprintf(file_ID,'clk_100M%c=%c1%cb1;\n',32,32,39);
%     fprintf(file_ID,strcat(var_A,'%c=%c',num2str(nbit),'%cb',A_b(i,:),';\n'),32,32,39);
%     fprintf(file_ID,strcat(var_B,'%c=%c',num2str(nbit),'%cb',B_b(i,:),';\n'),32,32,39);
%     fprintf(file_ID,'#50;\nclk_100M%c=%c1%cb0;\n#50;\n',32,32,39);


fclose(file_ID);


    
    
