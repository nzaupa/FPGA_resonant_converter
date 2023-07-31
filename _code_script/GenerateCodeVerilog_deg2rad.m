%% GENERATE the case structure in Verilog
% computation of the sine and cosine using only integers

% multiplication factors
% theta x 100

mult_theta = 100;
%% theta
deg  = 0:180;
rad  = int32(deg*pi/180*mult_theta);

rad2 = int32(deg*1787)/1024;
%% FILE GENERATION
file_ID = fopen(strcat('deg2rad_',num2str(mult_theta),'.v'),'w');

% description
fprintf(file_ID,'// correspondance between deg and rad');
fprintf(file_ID,'// taking advanatges of look-up-table\n');
fprintf(file_ID,'// output angle is multiplied by x%i\n',mult_theta);

fprintf(file_ID,'\tcase(i_deg)\n');
for i = 1:length(deg)
    fprintf(file_ID,strcat('\t\t8%cd',num2str(deg(i)),...
        '\t:%co_rad%c=%c32%cd',num2str( rad(i) ),';\n'),39,32,32,32,39);
end
fprintf(file_ID,'\t\tdefault:%co_rad%c=%c32%cd314;\n\tendcase\n',32,32,32,39);

fclose(file_ID);

%% FILE GENERATION
num = 0:99;
dig1 = floor(num/10);
dig0 = floor(num-dig1*10);

file_ID = fopen(strcat('deg2seg_',num2str(1),'.v'),'w');

fprintf(file_ID,'case(i_dec)\n');
for i = 1:length(num)
    fprintf(file_ID,strcat('\t8%cd',num2str(num(i)),...
        '\t:%cstr%c=%c8%ch',num2str(dig1(i)),num2str(dig0(i)),';\n'),39,32,32,32,39);
end
fprintf(file_ID,'\tdefault:%cstr%c=%c8%ch00;\nendcase\n',32,32,32,39);

fclose(file_ID);


