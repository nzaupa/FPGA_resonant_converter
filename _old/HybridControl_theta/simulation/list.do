onerror {resume}
add list -width 33 /tb_hybrid_control/HC_inst/i_vC
add list /tb_hybrid_control/HC_inst/i_iC
add list /tb_hybrid_control/HC_inst/z1
add list /tb_hybrid_control/HC_inst/z2
add list /tb_hybrid_control/HC_inst/jump
add list /tb_hybrid_control/HC_inst/sigma
add list /tb_hybrid_control/HC_half_inst/z1
add list /tb_hybrid_control/HC_half_inst/z2
add list /tb_hybrid_control/HC_half_inst/jump_1
add list /tb_hybrid_control/HC_half_inst/jump_2
add list /tb_hybrid_control/HC_half_inst/sigma
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
