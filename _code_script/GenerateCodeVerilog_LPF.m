%% INITIALIZE
clearvars
clc

%% export to .v file

% _VariableName_ = _nbit_'b_bits_;

n = 32;

file_ID = fopen(strcat('LPF_central_code_n',num2str(n),'.v'),'w');

fprintf(file_ID,'// Moving average filter on %i samples\n\n',n);

fprintf(file_ID,'// INTERNAL VARIABLE\n');
for i = 1:n
    fprintf(file_ID,strcat('reg signed [31:0] z',num2str(i),';\n'));
end

fprintf(file_ID,'\n// assign output variable\n');
fprintf(file_ID,'assign o_mean = z1');
for i = 2:n
    fprintf(file_ID,strcat(' + z',num2str(i)));
end
fprintf(file_ID,';');

fprintf(file_ID,'\n\n// variable initialization\ninitial begin\n');
for i = 1:n
    fprintf(file_ID,strcat('\tz',num2str(i),'%c=%c32%cb0;\n'),32,32,39);
end
fprintf(file_ID,'end\n\n');

fprintf(file_ID,'always @(posedge i_clock or negedge i_RESET) begin\n');
fprintf(file_ID,'\tif (~i_RESET) begin\n');
for i = 1:n
    fprintf(file_ID,strcat('\t\tz',num2str(i),'%c<=%c32%cb0;\n'),32,32,39);
end
fprintf(file_ID,'\tend else begin\n');
fprintf(file_ID,'\t\tz1 <= i_data>>%i;\n',log(n)/log(2));
for i = 2:n
    fprintf(file_ID,strcat('\t\tz',num2str(i),'%c<=%cz',num2str(i-1),';\n'),32,32);
end
fprintf(file_ID,'\tend\nend\n\n');

fclose(file_ID);

