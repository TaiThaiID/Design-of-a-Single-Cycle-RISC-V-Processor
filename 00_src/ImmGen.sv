//==============================================================================
// Module: ImmGen
// Description: Immediate Generator for RV32I instruction set
//              - Extracts and sign-extends immediate fields
//              - Supports I, S, B, U, and J instruction formats
//==============================================================================

module ImmGen (
  input  logic [31:0] i_instr,
  output logic [31:0] o_ImmExt
);

  //=================================
  // Opcodes
  //=================================
	localparam OPIMM  = 7'b0010011;   // I-type: Immediate arithmetic
	localparam LOAD   = 7'b0000011;   // I-type: Load
	localparam STORE  = 7'b0100011;   // S-type: Store
	localparam BRANCH = 7'b1100011;   // B-type: Conditional branch
	localparam JAL    = 7'b1101111;   // J-type: Jump and link
	localparam JALR   = 7'b1100111;   // I-type: Jump and link register
	localparam LUI    = 7'b0110111;   // U-type: Load upper immediate
	localparam AUIPC  = 7'b0010111;   // U-type: Add upper immediate to PC


  //=================================
  // Immediate Extraction Logic
  //=================================
  always_comb begin
		 unique case (i_instr[6:0])
		 
				OPIMM, LOAD, JALR: // I-type
							 o_ImmExt = {{20{i_instr[31]}}, i_instr[31:20]};

				STORE: 		// S-type
							 o_ImmExt = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};

				BRANCH: 		// B-type
							 o_ImmExt = {{19{i_instr[31]}}, i_instr[31], i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};

				JAL: 			// J-type
							 o_ImmExt = {{11{i_instr[31]}}, i_instr[31], i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};
							 
				LUI, AUIPC: // U-type
							 o_ImmExt = {i_instr[31:12], 12'b0};
							 
				default:  o_ImmExt = 32'b0;
				
		 endcase
  end
  
endmodule
