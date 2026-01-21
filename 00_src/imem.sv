//===================================================================================
// Module: imem (Instruction Memory)
// Description: A wrapper for the generic memory module, configured for read-only
//              instruction fetching. It takes a 32-bit byte address (PC) and
//              outputs the corresponding 32-bit instruction.
//===================================================================================

module imem(
	 input  logic [31:0] i_pc,
    output logic [31:0] o_instr
);
	logic [31:0] inst_mem [0:2047];
	logic [10:0] pc_word;
	
	initial begin
		$readmemh("./../02_test/isa_4b.hex", inst_mem);
	end
	
	assign pc_word = i_pc[12:2];
	
	assign o_instr = inst_mem[pc_word];

endmodule