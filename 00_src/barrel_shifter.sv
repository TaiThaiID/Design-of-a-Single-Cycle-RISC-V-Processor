module barrel_shifter(
		input [31:0] i_op_a,
		input [31:0] i_op_b,
		output[31:0] sll_result,
		output[31:0] srl_result,
		output[31:0] sra_result
);

	 //=================================================
    // Shift Operations
    //=================================================
    
    // SLL
    logic [31:0] sll_s0, sll_s1, sll_s2, sll_s3;
    assign sll_s0     = i_op_b[0] ? {i_op_a[30:0], 1'b0}   : i_op_a;
    assign sll_s1     = i_op_b[1] ? {sll_s0[29:0], 2'b0}   : sll_s0;
    assign sll_s2     = i_op_b[2] ? {sll_s1[27:0], 4'b0}   : sll_s1;
    assign sll_s3     = i_op_b[3] ? {sll_s2[23:0], 8'b0}   : sll_s2;
    assign sll_result = i_op_b[4] ? {sll_s3[15:0], 16'b0}  : sll_s3;
    
    // SRL
    logic [31:0] srl_s0, srl_s1, srl_s2, srl_s3;
    assign srl_s0     = i_op_b[0] ? {1'b0,  i_op_a[31:1]}  : i_op_a;
    assign srl_s1     = i_op_b[1] ? {2'b0,  srl_s0[31:2]}  : srl_s0;
    assign srl_s2     = i_op_b[2] ? {4'b0,  srl_s1[31:4]}  : srl_s1;
    assign srl_s3     = i_op_b[3] ? {8'b0,  srl_s2[31:8]}  : srl_s2;
    assign srl_result = i_op_b[4] ? {16'b0, srl_s3[31:16]} : srl_s3;
    
    // SRA
    logic [31:0] sra_s0, sra_s1, sra_s2, sra_s3;
    logic sign_bit;
    assign sign_bit   = i_op_a[31];
    assign sra_s0     = i_op_b[0] ? {sign_bit,       i_op_a[31:1]}  : i_op_a;
    assign sra_s1     = i_op_b[1] ? {{2{sign_bit}},  sra_s0[31:2]}  : sra_s0;
    assign sra_s2     = i_op_b[2] ? {{4{sign_bit}},  sra_s1[31:4]}  : sra_s1;
    assign sra_s3     = i_op_b[3] ? {{8{sign_bit}},  sra_s2[31:8]}  : sra_s2;
    assign sra_result = i_op_b[4] ? {{16{sign_bit}}, sra_s3[31:16]} : sra_s3;

	 
endmodule 