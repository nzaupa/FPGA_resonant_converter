clc
clearvars
% program that test the simulation for the converter
% there is the need to check for integer compatibility



L   = 10   ;% uH
C   = 850   ;% nF
Lm  = 36    ;% uH
Req = 10000 ;% mOhm
Vg  = 48000 ;% mV
dt=10;

mu_1 =  (dt*2^20)/(C*1000);
mu_2 =  (dt*Vg)/L;
mu_3 = -dt/L;
mu_4 = -dt/L;
mu_5 = -(dt*Req*2^17)*(1+L/Lm)/(L*1e6);
mu_6 = -(dt*Req*2^10)/(L*1e6);
mu_7 =  (dt*Req*Vg)/(1e6*L);

mu_1 = round(mu_1);
mu_2 = round(mu_2);
mu_3 = round(mu_3);
mu_4 = round(mu_4);
mu_5 = round(mu_5);
mu_6 = round(mu_6);
mu_7 = round(mu_7);

% mu_1 =  12047;
% mu_2 =  48000;
% mu_3 = -1;
% mu_4 = -1;
% mu_5 =  -1675;
% mu_6 = -10;
% mu_7 =  480;


vC=0;
iS=0;
Vo=0;
sigma=1;

X=importdata("test_sigma.csv",',');
sigma = X.data(:,4);
sigma = round(sigma/23)';



for k=1:length(sigma)-1
%     vC(k+1) = vC(k) + mu_1/2^10*iS(k);
%     iS(k+1) = iS(k) + mu_2*sigma(k) + mu_3*vC(k) + mu_4*Vo(k);
%     Vo(k+1) = Vo(k) + mu_5/2^17*Vo(k) + mu_6/2^10*vC(k) + mu_7*sigma(k);

    vC(k+1) = vC(k) + round(round(mu_1*iS(k))/2^20);
    iS(k+1) = iS(k) + round(mu_2*sigma(k)) + round(mu_3*vC(k)) + round(mu_4*Vo(k));
    Vo(k+1) = Vo(k) + round(round(mu_5*Vo(k))/2^17) + round(round(mu_6*vC(k))/2^10) + round(mu_7*sigma(k));


    % square wave generator
%     if(mod(k,1000)==0)
%         sigma(k+1)=-sigma(k);
%     else
%         sigma(k+1)= sigma(k);
%     end
end

figure(3), clf, hold on
    stairs(vC)
    stairs(sigma)
    stairs(iS/1000)
%     stairs(iS)
    stairs(Vo)
    legend('$v_C$','$\sigma$','$i_S$','$V_o$')
    plot_layout(gca)

% plot test to check for decimal accurancy
%     stairs(round(round(mu_1*iS)/2^20),'k--')
%     stairs(round(mu_2*sigma),'r--')
%     stairs(round(round(mu_3*vC)),'b--')
%     stairs(round(round(mu_5*Vo)/2^17),'g-')
%     stairs(round(round(mu_6*vC)/2^10),'m-')
%     stairs(round(mu_7*sigma),'c-')
% d4=round(round(mu_5*Vo)/2^17) + round(round(mu_6*vC)/2^10) + round(mu_7*sigma);
% stairs(d4,'ko')

% xlim([0,10])

return
%% WORKING SIMULATION with uA and mV
L   = 10e-6    ;% uH
C   = 850e-9   ;% nF
Lm  = 36e-6    ;% uH
Req = 10 ;% mOhm
Vg  = 48    ;% V
dt=10e-9;

vC=0;
iS=0;
Vo=0;
sigma=1;

for k=1:10000
    vC(k+1) = vC(k) + dt/C/1000*iS(k);
    iS(k+1) = iS(k) + dt/L*1000*(-vC(k)-Vo(k)) + dt/L*Vg*1e6*sigma(k);
    Vo(k+1) = Vo(k) - dt*Req/L*(1+L/Lm)*Vo(k) - dt*Req/L*vC(k) + dt*Req/L*Vg*1000*sigma(k) ;

    % square wave generator
    if(mod(k,1000)==0)
        sigma(k+1)=-sigma(k);
    else
        sigma(k+1)= sigma(k);
    end
end


figure(2), clf, hold on
    stairs(vC)
    stairs(sigma)
    stairs(iS/1000)
    stairs(Vo)
    legend('$v_C$','$\sigma$','$i_S$','$V_o$')
    plot_layout(gca)


