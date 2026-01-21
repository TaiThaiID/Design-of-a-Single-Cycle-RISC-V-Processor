module opbsel(
	input  logic [31:0] i_ImmExt,
	input  logic [31:0] i_rs2_data,
	input  logic 		  i_opb_sel,
	output logic [31:0] o_operand_b
);

	assign o_operand_b = (i_opb_sel) ? i_ImmExt : i_rs2_data;
	
endmodule 