// cic_ii_0_example_design.v

// Generated using ACDS version 20.1 720

`timescale 1 ps / 1 ps
module cic_ii_0_example_design (
		input  wire [1:0]  core_av_st_in_error,  //  core_av_st_in.error
		input  wire        core_av_st_in_valid,  //               .valid
		output wire        core_av_st_in_ready,  //               .ready
		input  wire [7:0]  core_av_st_in_data,   //               .data
		output wire [16:0] core_av_st_out_data,  // core_av_st_out.data
		output wire [1:0]  core_av_st_out_error, //               .error
		output wire        core_av_st_out_valid, //               .valid
		input  wire        core_av_st_out_ready, //               .ready
		input  wire        core_clock_clk,       //     core_clock.clk
		input  wire        core_reset_reset_n    //     core_reset.reset_n
	);

	wire  [16:0] core_out_data; // port fragment

	cic_ii_0_example_design_core core (
		.clk       (core_clock_clk),          //     clock.clk
		.reset_n   (core_reset_reset_n),      //     reset.reset_n
		.in_error  (core_av_st_in_error),     //  av_st_in.error
		.in_valid  (core_av_st_in_valid),     //          .valid
		.in_ready  (core_av_st_in_ready),     //          .ready
		.in_data   (core_av_st_in_data[7:0]), //          .data
		.out_data  (core_out_data[16:0]),     // av_st_out.data
		.out_error (core_av_st_out_error),    //          .error
		.out_valid (core_av_st_out_valid),    //          .valid
		.out_ready (core_av_st_out_ready),    //          .ready
		.clken     (1'b1)                     // (terminated)
	);

	assign core_av_st_out_data = { core_out_data[16:0] };

endmodule
