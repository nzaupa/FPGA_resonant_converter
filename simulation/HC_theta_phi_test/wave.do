onerror {resume}
quietly virtual signal -install /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst { (context /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst )&{b1 , b0 }} b_theta_phi
quietly virtual signal -install /tb_hybrid_control_theta_phi/hybrid_control_phi_inst { (context /tb_hybrid_control_theta_phi/hybrid_control_phi_inst )&{b1 , b0 }} b_phi
quietly virtual signal -install /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst { (context /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst )&{C1_db , C2_db , C3_db , C4_db }} C_db_tp
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {JUMP SET PHI}
add wave -noupdate /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/b_phi
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Orange Red} /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/C1_db
add wave -noupdate -color {Orange Red} /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/C1
add wave -noupdate -divider <NULL>
add wave -noupdate /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/C2_db
add wave -noupdate -color Gold /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/C2
add wave -noupdate -divider <NULL>
add wave -noupdate /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/C3_db
add wave -noupdate -color Gold /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/C3
add wave -noupdate -divider <NULL>
add wave -noupdate /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/C4_db
add wave -noupdate -color Gold /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/C4
add wave -noupdate -clampanalog 1 -color {Violet Red} -format Analog-Step -height 30 -max 1.0 -min -1.0 -radix decimal /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/sigma
add wave -noupdate -divider {JUMP SET THETA-PHI}
add wave -noupdate /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/b_theta_phi
add wave -noupdate /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/C_db_tp
add wave -noupdate -color {Orange Red} /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/C1
add wave -noupdate -color Gold /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/C2
add wave -noupdate -color Gold /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/C3
add wave -noupdate -color Gold /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/C4
add wave -noupdate -clampanalog 1 -color {Violet Red} -format Analog-Step -height 30 -max 1.0 -min -1.0 -radix decimal /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/sigma
add wave -noupdate -clampanalog 1 -format Analog-Step -height 50 -max 305650000.0 -min -305650000.0 /tb_hybrid_control_theta_phi/hybrid_control_phi_inst/S1
add wave -noupdate -clampanalog 1 -format Analog-Step -height 50 -max 500000000.0 -min -500000000.0 /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/S2
add wave -noupdate -clampanalog 1 -format Analog-Step -height 70 -max 499999.99999999994 -min -500000.0 /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/Z1
add wave -noupdate -clampanalog 1 -format Analog-Step -height 70 -max 499999.99999999994 -min -500000.0 /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/Z2
add wave -noupdate /tb_hybrid_control_theta_phi/hybrid_control_theta_phi_inst/CLK_jump
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {59748954 ps} 0} {{Cursor 2} {248550466 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 209
configure wave -valuecolwidth 79
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {262500 ns}
