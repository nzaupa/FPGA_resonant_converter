// correspondance between deg and rad// taking advanatges of look-up-table
// output angle is multiplied by x100
	case(i_deg)
		8'd0	: o_rad = 32'd0;
		8'd1	: o_rad = 32'd2;
		8'd2	: o_rad = 32'd3;
		8'd3	: o_rad = 32'd5;
		8'd4	: o_rad = 32'd7;
		8'd5	: o_rad = 32'd9;
		8'd6	: o_rad = 32'd10;
		8'd7	: o_rad = 32'd12;
		8'd8	: o_rad = 32'd14;
		8'd9	: o_rad = 32'd16;
		8'd10	: o_rad = 32'd17;
		8'd11	: o_rad = 32'd19;
		8'd12	: o_rad = 32'd21;
		8'd13	: o_rad = 32'd23;
		8'd14	: o_rad = 32'd24;
		8'd15	: o_rad = 32'd26;
		8'd16	: o_rad = 32'd28;
		8'd17	: o_rad = 32'd30;
		8'd18	: o_rad = 32'd31;
		8'd19	: o_rad = 32'd33;
		8'd20	: o_rad = 32'd35;
		8'd21	: o_rad = 32'd37;
		8'd22	: o_rad = 32'd38;
		8'd23	: o_rad = 32'd40;
		8'd24	: o_rad = 32'd42;
		8'd25	: o_rad = 32'd44;
		8'd26	: o_rad = 32'd45;
		8'd27	: o_rad = 32'd47;
		8'd28	: o_rad = 32'd49;
		8'd29	: o_rad = 32'd51;
		8'd30	: o_rad = 32'd52;
		8'd31	: o_rad = 32'd54;
		8'd32	: o_rad = 32'd56;
		8'd33	: o_rad = 32'd58;
		8'd34	: o_rad = 32'd59;
		8'd35	: o_rad = 32'd61;
		8'd36	: o_rad = 32'd63;
		8'd37	: o_rad = 32'd65;
		8'd38	: o_rad = 32'd66;
		8'd39	: o_rad = 32'd68;
		8'd40	: o_rad = 32'd70;
		8'd41	: o_rad = 32'd72;
		8'd42	: o_rad = 32'd73;
		8'd43	: o_rad = 32'd75;
		8'd44	: o_rad = 32'd77;
		8'd45	: o_rad = 32'd79;
		8'd46	: o_rad = 32'd80;
		8'd47	: o_rad = 32'd82;
		8'd48	: o_rad = 32'd84;
		8'd49	: o_rad = 32'd86;
		8'd50	: o_rad = 32'd87;
		8'd51	: o_rad = 32'd89;
		8'd52	: o_rad = 32'd91;
		8'd53	: o_rad = 32'd93;
		8'd54	: o_rad = 32'd94;
		8'd55	: o_rad = 32'd96;
		8'd56	: o_rad = 32'd98;
		8'd57	: o_rad = 32'd99;
		8'd58	: o_rad = 32'd101;
		8'd59	: o_rad = 32'd103;
		8'd60	: o_rad = 32'd105;
		8'd61	: o_rad = 32'd106;
		8'd62	: o_rad = 32'd108;
		8'd63	: o_rad = 32'd110;
		8'd64	: o_rad = 32'd112;
		8'd65	: o_rad = 32'd113;
		8'd66	: o_rad = 32'd115;
		8'd67	: o_rad = 32'd117;
		8'd68	: o_rad = 32'd119;
		8'd69	: o_rad = 32'd120;
		8'd70	: o_rad = 32'd122;
		8'd71	: o_rad = 32'd124;
		8'd72	: o_rad = 32'd126;
		8'd73	: o_rad = 32'd127;
		8'd74	: o_rad = 32'd129;
		8'd75	: o_rad = 32'd131;
		8'd76	: o_rad = 32'd133;
		8'd77	: o_rad = 32'd134;
		8'd78	: o_rad = 32'd136;
		8'd79	: o_rad = 32'd138;
		8'd80	: o_rad = 32'd140;
		8'd81	: o_rad = 32'd141;
		8'd82	: o_rad = 32'd143;
		8'd83	: o_rad = 32'd145;
		8'd84	: o_rad = 32'd147;
		8'd85	: o_rad = 32'd148;
		8'd86	: o_rad = 32'd150;
		8'd87	: o_rad = 32'd152;
		8'd88	: o_rad = 32'd154;
		8'd89	: o_rad = 32'd155;
		8'd90	: o_rad = 32'd157;
		8'd91	: o_rad = 32'd159;
		8'd92	: o_rad = 32'd161;
		8'd93	: o_rad = 32'd162;
		8'd94	: o_rad = 32'd164;
		8'd95	: o_rad = 32'd166;
		8'd96	: o_rad = 32'd168;
		8'd97	: o_rad = 32'd169;
		8'd98	: o_rad = 32'd171;
		8'd99	: o_rad = 32'd173;
		8'd100	: o_rad = 32'd175;
		8'd101	: o_rad = 32'd176;
		8'd102	: o_rad = 32'd178;
		8'd103	: o_rad = 32'd180;
		8'd104	: o_rad = 32'd182;
		8'd105	: o_rad = 32'd183;
		8'd106	: o_rad = 32'd185;
		8'd107	: o_rad = 32'd187;
		8'd108	: o_rad = 32'd188;
		8'd109	: o_rad = 32'd190;
		8'd110	: o_rad = 32'd192;
		8'd111	: o_rad = 32'd194;
		8'd112	: o_rad = 32'd195;
		8'd113	: o_rad = 32'd197;
		8'd114	: o_rad = 32'd199;
		8'd115	: o_rad = 32'd201;
		8'd116	: o_rad = 32'd202;
		8'd117	: o_rad = 32'd204;
		8'd118	: o_rad = 32'd206;
		8'd119	: o_rad = 32'd208;
		8'd120	: o_rad = 32'd209;
		8'd121	: o_rad = 32'd211;
		8'd122	: o_rad = 32'd213;
		8'd123	: o_rad = 32'd215;
		8'd124	: o_rad = 32'd216;
		8'd125	: o_rad = 32'd218;
		8'd126	: o_rad = 32'd220;
		8'd127	: o_rad = 32'd222;
		8'd128	: o_rad = 32'd223;
		8'd129	: o_rad = 32'd225;
		8'd130	: o_rad = 32'd227;
		8'd131	: o_rad = 32'd229;
		8'd132	: o_rad = 32'd230;
		8'd133	: o_rad = 32'd232;
		8'd134	: o_rad = 32'd234;
		8'd135	: o_rad = 32'd236;
		8'd136	: o_rad = 32'd237;
		8'd137	: o_rad = 32'd239;
		8'd138	: o_rad = 32'd241;
		8'd139	: o_rad = 32'd243;
		8'd140	: o_rad = 32'd244;
		8'd141	: o_rad = 32'd246;
		8'd142	: o_rad = 32'd248;
		8'd143	: o_rad = 32'd250;
		8'd144	: o_rad = 32'd251;
		8'd145	: o_rad = 32'd253;
		8'd146	: o_rad = 32'd255;
		8'd147	: o_rad = 32'd257;
		8'd148	: o_rad = 32'd258;
		8'd149	: o_rad = 32'd260;
		8'd150	: o_rad = 32'd262;
		8'd151	: o_rad = 32'd264;
		8'd152	: o_rad = 32'd265;
		8'd153	: o_rad = 32'd267;
		8'd154	: o_rad = 32'd269;
		8'd155	: o_rad = 32'd271;
		8'd156	: o_rad = 32'd272;
		8'd157	: o_rad = 32'd274;
		8'd158	: o_rad = 32'd276;
		8'd159	: o_rad = 32'd278;
		8'd160	: o_rad = 32'd279;
		8'd161	: o_rad = 32'd281;
		8'd162	: o_rad = 32'd283;
		8'd163	: o_rad = 32'd284;
		8'd164	: o_rad = 32'd286;
		8'd165	: o_rad = 32'd288;
		8'd166	: o_rad = 32'd290;
		8'd167	: o_rad = 32'd291;
		8'd168	: o_rad = 32'd293;
		8'd169	: o_rad = 32'd295;
		8'd170	: o_rad = 32'd297;
		8'd171	: o_rad = 32'd298;
		8'd172	: o_rad = 32'd300;
		8'd173	: o_rad = 32'd302;
		8'd174	: o_rad = 32'd304;
		8'd175	: o_rad = 32'd305;
		8'd176	: o_rad = 32'd307;
		8'd177	: o_rad = 32'd309;
		8'd178	: o_rad = 32'd311;
		8'd179	: o_rad = 32'd312;
		8'd180	: o_rad = 32'd314;
		default: o_rad = 32'd314;
	endcase
