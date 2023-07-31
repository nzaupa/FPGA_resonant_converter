%% GENERATE the case structure in Verilog
% computation of the sine and cosine using only integers

% multiplication factors
% theta x 100
% sin   x 1000
% cos   x 1000

mult_theta  = 100;
mult_sincos = 1000;

%% theta
% theta  = -314:628;
theta  = -pi*mult_theta:1:2*pi*mult_theta;
stheta = round(sin(theta/mult_theta)*mult_sincos);
ctheta = round(cos(theta/mult_theta)*mult_sincos);

figure(5), clf, hold on
    plot(theta/mult_theta,stheta,'-o','MarkerSize',2)
    plot(theta/mult_theta,ctheta,'-o','MarkerSize',2)
    grid on
    grid minor


%% FILE GENERATION
file_ID = fopen(strcat('trig_',num2str(mult_theta),'_',num2str(mult_sincos),'_ext.v'),'w');

% description
fprintf(file_ID,'// computation of sine and cosine using integers\n');
fprintf(file_ID,'// taking advanatges of look-up-table\n');
fprintf(file_ID,'// input angle is multiplied by x%i\n',mult_theta);
fprintf(file_ID,'// trigonometric output is multiplied by x%i\n',mult_sincos);
fprintf(file_ID,'// input angle range is [-pi,2*pi]\n\n');



fprintf(file_ID,'\tcase(i_theta)\n');
for i = 1:length(theta)
    fprintf(file_ID,strcat('\t\t32%ch',bin2hex(dec2twobin( theta(i),32 )),...
        ':%cr_sin%c=%c32%ch',bin2hex(dec2twobin( stheta(i),32 )),';\n'),39,32,32,32,39);
end
fprintf(file_ID,'\t\tdefault:%cr_sin%c=%c32%ch00000000;\n\tendcase\n',32,32,32,39);

fprintf(file_ID,'\n\tcase(i_theta)\n');
for i = 1:length(theta)
    fprintf(file_ID,strcat('\t\t32%ch',bin2hex(dec2twobin( theta(i),32 )),...
        ':%cr_cos%c=%c32%ch',bin2hex(dec2twobin( ctheta(i),32 )),';\n'),39,32,32,32,39);
end
fprintf(file_ID,'\t\tdefault:%cr_cos%c=%c32%ch00000000;\n\tendcase\n',32,32,32,39);


fclose(file_ID);


%%

