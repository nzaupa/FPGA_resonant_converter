%% TEST WITH OSCILLOSCOPE DATA
clearvars
clc
% A1 = readmatrix('tek0000ALL.csv');
% A2 = readmatrix('tek0001ALL.csv');
% A3 = readmatrix('tek0002ALL.csv');
% A4 = readmatrix('tek0003ALL.csv');
% A5 = readmatrix('tek0004ALL.csv');
A6 = readmatrix('tek0006ALL.csv');
%%
sample = 5000016:10:5100016;
A = A6;

tt = A(sample,1);
iC = A(sample,2)*2;
vC = A(sample,3)*2;
si = A(sample,4);

[a,b] = butter(5,0.05);%2*pi*1e6);
vC_f  = filtfilt(a,b,vC);
iC_f  = filtfilt(a,b,iC);
si_f  = filtfilt(a,b,si);


sigma    = zeros(size(tt));
sigma(1) = 1;
z1   = zeros(size(tt));
z2   = zeros(size(tt));
jump = zeros(size(tt));
for i=1:length(sigma)
    z1(i)   = (vC_f(i))-sigma(i)*1966/8191*0.5;
    z2(i)   = (iC_f(i));
    jump(i) = z1(i)*700-z2(i)*707;
    sigma(i+1) = (jump(i)<0)*2-1;
end
sigma(end) = [];

k = 1e6;
figure(2), clf, hold on
%     plot(t*1e7,vC)
%     plot(t,iC)
%     plot(t,si/10)
    plot(tt*k,sigma*0.2,'LineWidth',1.5)
    plot(tt*k,vC_f,'-','LineWidth',1.5)
    plot(tt*k,iC_f,'LineWidth',1.5)
    plot(tt*k,si_f/10,'LineWidth',1.5)
    plot(tt*k,jump/1000,'LineWidth',1.2)
    grid on
    grid minor
    xlim([0,4e-5]*k)
    legend('\sigma','v_C','i_C','\sigma-osc','jump')
    xlabel('$t\ (\mu s)$','Interpreter','latex')
    















