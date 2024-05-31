% clc
clearvars
% program that test the simulation for the converter
% there is the need to check for integer compatibility



L   = 10   ;% uH
C   = 850   ;% nF
Lm  = 30    ;% uH
Req = 4200  ;% mOhm
Vg  = 24000 ;% mV
dt=10;




mu_1 = round( (dt*(2^20))/(1000*C));
mu_2 = round(-dt/L);
mu_3 = round( (dt*Vg)/L);
mu_4 = round(-(dt*Req*(2^10))/(L*1e6));
mu_5 = round(-(dt*Req*(2^17))*(1+L/Lm)/(L*1e6));
mu_6 = round( (dt*Req*Vg)/(L*1e6));

% mu_1 = round(mu_1);
% mu_2 = round(mu_2);
% mu_3 = round(mu_3);
% mu_4 = round(mu_4);
% mu_5 = round(mu_5);
% mu_6 = round(mu_6);

vC=0;
iS=0;
Vo=0;
sigma=1;

X=importdata("test_sigma.csv",',');
sigma = X.data(:,4);
sigma = round(sigma/23)';



for k=1:length(sigma)-1

    vC(k+1) = vC(k) + round(round(mu_1*iS(k))/2^20);
    iS(k+1) = iS(k) + round(mu_3*sigma(k)) + round(mu_2*(vC(k)+Vo(k)));
    Vo(k+1) = Vo(k) + round(round(mu_5*Vo(k))/2^17) + round(round(mu_4*vC(k))/2^10) + round(mu_6*sigma(k));


    % square wave generator
    %     if(mod(k,1000)==0)
    %         sigma(k+1)=-sigma(k);
    %     else
    %         sigma(k+1)= sigma(k);
    %     end
end

figure(3), clf, hold on
    stairs(vC)
    stairs(sigma*0.5e4,'--','LineWidth',1)
    stairs(iS/1000,'LineWidth',1)
%     stairs(iS)
%     stairs(Vo)
    legend('$v_C$','$\sigma$','$i_S$','$V_o$')
    plot_layout(gca)

    yline(28476)
    yline(12574)
    yline(5456558/1000)
    yline(6538060/1000)

    xlim([0,1e4])


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


