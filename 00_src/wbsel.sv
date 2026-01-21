module wbsel(
	input  logic [31:0] i_pc_four,
	input  logic [31:0] i_alu_data,
	input  logic [31:0] i_ld_data,
	input  logic [1:0]  i_wb_sel,
	output logic [31:0] o_wb_data
);

	always_comb begin
        unique case (i_wb_sel)
            2'b00:   o_wb_data = i_alu_data;   // R-type, I-type (non-load)
            2'b01:   o_wb_data = i_ld_data ;   // Load instructions
            2'b10:   o_wb_data = i_pc_four;    // JAL, JALR instructions
            default: o_wb_data = 32'b0;        // Default case
        endcase
    end
	

endmodule 