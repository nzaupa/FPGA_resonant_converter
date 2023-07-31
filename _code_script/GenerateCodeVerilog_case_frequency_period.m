%% GENERATE the case structure in Verilog
% computation of the number of 'steps' to generate a square waveform given
% the frequency in kHz for a clock of 100MHz (10ns)
clc
clearvars
%% frequency 10kHz -> 100kHz
frequency = 10:100;

step = round(100e6 ./ (frequency*1e3)/2); % amplitude of one cycle
%% FILE GENERATION
file_ID = fopen(strcat('frequency_',num2str(frequency(1)),'kHz_',num2str(frequency(end)),'kHz_step_1kHz_ext.v'),'w');
% file_ID = 1;

% description
fprintf(file_ID,'// computation of number of step for a given frequency in kHz\n');
% fprintf(file_ID,'// taking advanatges of look-up-table\n');
% fprintf(file_ID,'// input angle is multiplied by x%i\n',mult_theta);
% fprintf(file_ID,'// trigonometric output is multiplied by x%i\n',mult_sincos);
% fprintf(file_ID,'// input angle range is [-pi,2*pi]\n\n');


fprintf(file_ID,'\tcase(frequency)\n');
for i = 1:length(frequency)
    fprintf(file_ID,strcat('\t\t8%cd%03.f',...
        ':%cperiod%c=%c32%cd%.f;\n'),39,frequency(i),32,32,32,39,step(i));
end
fprintf(file_ID,'\t\tdefault:%cperiod%c=%c32%cd500;\n\tendcase\n',32,32,32,39);


fclose(file_ID);


%%

