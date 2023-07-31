// Moving average filter on 16 samples

// INTERNAL VARIABLE
reg signed [31:0] z1;
reg signed [31:0] z2;
reg signed [31:0] z3;
reg signed [31:0] z4;
reg signed [31:0] z5;
reg signed [31:0] z6;
reg signed [31:0] z7;
reg signed [31:0] z8;
reg signed [31:0] z9;
reg signed [31:0] z10;
reg signed [31:0] z11;
reg signed [31:0] z12;
reg signed [31:0] z13;
reg signed [31:0] z14;
reg signed [31:0] z15;
reg signed [31:0] z16;

// assign output variable
assign o_mean = z1 + z2 + z3 + z4 + z5 + z6 + z7 + z8 + z9 + z10 + z11 + z12 + z13 + z14 + z15 + z16;

// variable initialization
initial begin
	z1 = 32'b0;
	z2 = 32'b0;
	z3 = 32'b0;
	z4 = 32'b0;
	z5 = 32'b0;
	z6 = 32'b0;
	z7 = 32'b0;
	z8 = 32'b0;
	z9 = 32'b0;
	z10 = 32'b0;
	z11 = 32'b0;
	z12 = 32'b0;
	z13 = 32'b0;
	z14 = 32'b0;
	z15 = 32'b0;
	z16 = 32'b0;
end

always @(posedge i_clock or negedge i_RESET) begin
	if (~i_RESET) begin
		z1 <= 32'b0;
		z2 <= 32'b0;
		z3 <= 32'b0;
		z4 <= 32'b0;
		z5 <= 32'b0;
		z6 <= 32'b0;
		z7 <= 32'b0;
		z8 <= 32'b0;
		z9 <= 32'b0;
		z10 <= 32'b0;
		z11 <= 32'b0;
		z12 <= 32'b0;
		z13 <= 32'b0;
		z14 <= 32'b0;
		z15 <= 32'b0;
		z16 <= 32'b0;
	end else begin
		z1 <= i_data>>2;
		z2 <= z1;
		z3 <= z2;
		z4 <= z3;
		z5 <= z4;
		z6 <= z5;
		z7 <= z6;
		z8 <= z7;
		z9 <= z8;
		z10 <= z9;
		z11 <= z10;
		z12 <= z11;
		z13 <= z12;
		z14 <= z13;
		z15 <= z14;
		z16 <= z15;
	end
end

