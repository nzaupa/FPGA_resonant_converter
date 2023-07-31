clc
clearvars

format long

B = readtable('output_sim_corrected.txt');
A = table2cell(B);

t          = [A{2:end,1}]'/1e3; %ns
iC         = [A{2:end,8}]';
x_prev     = [A{2:end,9}]'; 
x_dot      = [A{2:end,10}]';
x_dot_prev = [A{2:end,11}]';
peak_in    = A(2:end,12);
peak       = ( cellfun(@str2num,peak_in,'UniformOutput',0));
peak       = cellfun(@mean,peak);

peak_detected = [A{2:end,5}]';
iC_filt = [A{2:end,13}]';
iC_diff_filt_bin = reshape([A{2:end,14}]',size(t,1),length([A{2:end,14}]')/size(t,1));





%%
iC_diff_filt_bin(iC_diff_filt_bin=='x') = '0';

iC_diff_filt_bin = [ repmat('0b',length(iC_diff_filt_bin),1) iC_diff_filt_bin repmat('s32',length(iC_diff_filt_bin),1) ];

iC_diff_filt = bin2dec(iC_diff_filt_bin);


%%
figure(33), clf, hold on

plot(t,iC)
% plot(t,iC_diff_filt/max(iC_diff_filt)*max(iC),':')
plot(t,x_prev,'*')
plot(t,peak,'o')

