module pcsel(
	input  logic [31:0] i_alu_data,
	input  logic [31:0] i_pc_four,
	input  logic 		  i_pc_sel,
	output logic [31:0] o_pc_next
);

	assign o_pc_next = (i_pc_sel) ? i_alu_data : i_pc_four;
	
endmodule 