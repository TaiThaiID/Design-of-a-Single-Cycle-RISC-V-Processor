//==============================================================================
// Module: alu
// Description: 32-bit Arithmetic Logic Unit (ALU) for RISC-V processor
//              Supports 10 operations: ADD, SUB, SLT, SLTU, AND, OR, XOR,
//              SLL, SRL, SRA
// 
// Key Features:
//   - Single 32-bit adder reused for ADD, SUB, SLT, and SLTU operations
//   - 5-stage barrel shifters for all shift operations
//   - No use of synthesizable operators (-, <, >, <<, >>, >>>)
//
//==============================================================================


module alu(
    input  logic [31:0] i_op_a,
    input  logic [31:0] i_op_b,
    input  logic [3:0]  i_alu_op,
    output logic [31:0] o_alu_data
);

    // ALU Operation Encoding
    localparam ALU_ADD  = 4'b0000;
	 localparam ALU_SUB  = 4'b0001;
	 localparam ALU_SLL  = 4'b0010;
	 localparam ALU_SLT  = 4'b0011;
	 localparam ALU_SLTU = 4'b0100;
	 localparam ALU_XOR  = 4'b0101;
	 localparam ALU_SRL  = 4'b0110;
	 localparam ALU_SRA  = 4'b0111;
	 localparam ALU_OR   = 4'b1000;
	 localparam ALU_AND  = 4'b1001;
	 localparam ALU_LUI  = 4'b1010;
	 localparam ALU_AUIPC= 4'b1011;

    //=================================================
    // Adder Mode Control 
	 // Determines whether the adder performs ADD or SUB
    //=================================================
    logic adder_sub_mode;
    
    always_comb begin
       unique case (i_alu_op)
            ALU_SUB,      			
            ALU_SLT,      			
            ALU_SLTU:     			
                adder_sub_mode = 1'b1;  // SUB mode
            default:
                adder_sub_mode = 1'b0;  // ADD mode
        endcase
    end
    
    //=================================================
    // Single 32-bit Adder/Subtractor
    //=================================================
    logic [31:0] add_sub;
    logic        c_out;
    
    adder32 u_add_sub (
        .a     (i_op_a),
        .b     (i_op_b),
        .c_in  (adder_sub_mode),  // 0: ADD, 1: SUB
        .c_out (c_out),
        .s   (add_sub)
        // When ALU_ADD:  add_sub = a + b
        // When ALU_SUB:  add_sub = a - b
        // When ALU_SLT:  add_sub = a - b (used for comparison)
        // When ALU_SLTU: add_sub = a - b (used for carry check)
    );
    
    //=================================================
    // SLT/SLTU: Use adder result for comparison
    //=================================================
    logic slt_result, sltu_result;
    logic overflow;
    
    // Overflow detection 
	 // Overflow occurs when subtracting numbers with different signs
    // and the result has a different sign than the minuend
    assign overflow = (i_op_a[31] ^ i_op_b[31]) & (i_op_a[31] ^ add_sub[31]);
    
    // SLT: Signed comparison (a < b)?
    // Logic: If (a-b) is negative without overflow, or positive with overflow → a < b
    assign slt_result = add_sub[31] ^ overflow;
    
    // SLTU: Unsigned comparison (a < b)?
    // Logic: If a - b generates no borrow (c_out = 1) → a >= b
    //        If a - b generates borrow (c_out = 0) → a < b
    assign sltu_result = ~c_out;
    
    //=================================================
    // Shift Operations
    //=================================================
    logic [31:0] sll_result, srl_result, sra_result;
    
    barrel_shifter shift_op(
			.i_op_a 		(i_op_a),
			.i_op_b 		(i_op_b),
			.sll_result (sll_result),
			.srl_result (srl_result),
			.sra_result (sra_result)
	 );
	 
	 //=================================================
    // LUI/AUIPC 
    //=================================================
	 logic [31:0] lui_result;
	 logic 		  co_unused;
	 
	 adder32 u_lui (
        .a     (32'b0),
        .b     (i_op_b),
        .c_in  (1'b0),  
        .s   (lui_result),
		  .c_out (co_unused)
		);  
    
    //=======================================================
    // ALU Output Multiplexer
    // Selects the appropriate result based on operation code
    //=======================================================
    always_comb begin
        unique case (i_alu_op)
            ALU_ADD:  o_alu_data = add_sub;              // Addition: a + b
            ALU_SUB:  o_alu_data = add_sub;              // Subtraction: a - b
            ALU_SLT:  o_alu_data = {31'b0, slt_result};  // Set if less than (signed)
            ALU_SLTU: o_alu_data = {31'b0, sltu_result}; // Set if less than (unsigned)
            ALU_AND:  o_alu_data = i_op_a & i_op_b;      // Bitwise AND
            ALU_OR:   o_alu_data = i_op_a | i_op_b;      // Bitwise OR
            ALU_XOR:  o_alu_data = i_op_a ^ i_op_b;      // Bitwise XOR
            ALU_SLL:  o_alu_data = sll_result;           // Shift left logical
            ALU_SRL:  o_alu_data = srl_result;           // Shift right logical
            ALU_SRA:  o_alu_data = sra_result;           // Shift right arithmetic
				ALU_LUI:  o_alu_data = lui_result;				// Load upper immediate 
				ALU_AUIPC:o_alu_data = add_sub;					// Adds an upper immediate
				
            default:  o_alu_data = 32'b0;                // Default: output zero
        endcase
    end

endmodule
