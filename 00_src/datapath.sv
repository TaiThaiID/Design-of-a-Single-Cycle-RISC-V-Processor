//===================================================================================
// Module: datapath
// Description: Implements the datapath for the single-cycle RISC-V processor.
//              Connects all major functional units including PC, Register File,
//              ALU, and interfaces with the LSU and Control Unit.
//              Based on the block diagram
//===================================================================================

module datapath (
    // -- Global Signals --
    input  logic        i_clk,
    input  logic        i_reset,
	 input  logic [31:0] i_io_sw,
	 output logic [31:0] o_io_ledr,
	 output logic [31:0] o_io_ledg,
	 output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,
    output logic [31:0] o_io_lcd,
    output logic [31:0] o_pc_debug,
	 output logic		   o_insn_vld,
	 

    // -- Control Signals from Control Unit --
    input  logic        i_pc_sel,      // 0: PC+4, 1: ALU result (for branches/jumps)
    input  logic        i_opa_sel,     // Selects Operand A for ALU
    input  logic        i_opb_sel,     // Selects Operand B for ALU
    input  logic [3:0]  i_alu_op,      // ALU operation code
    input  logic        i_br_un,       // Branch unsigned signal for BRC
    input  logic        i_mem_wren,    // Write enable for LSU
    input  logic [1:0]  i_wb_sel,      // Write-back MUX selector
    input  logic        i_rd_wren,     // Write enable for Register File
	 input  logic 			i_insn_vld,

    // -- Outputs to Control Unit --
    output logic [31:0] o_instr,       // Instruction fetched from memory
    output logic        o_br_equal,    // BRC equal result
    output logic        o_br_less     // BRC less-than result
);

    //=================================================
    //  Internal Wires and Signals
    //=================================================
    logic [31:0] pc;
	 logic [31:0] pc_next;
	 logic [31:0] pc_four;
    logic [31:0] rs1_data;
	 logic [31:0] rs2_data;
    logic [31:0] ImmExt;
    logic [31:0] operand_a;
	 logic [31:0] operand_b;
    logic [31:0] alu_data;
    logic [31:0] ld_data; // Data loaded from LSU
    logic [31:0] wb_data; // Data to be written back to Regfile


    //=================================================
    //  1. Instruction Fetch (IF) Stage
    //=================================================

    // Program Counter (PC) Register
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

    // Adder for PC + 4
    pcplus4 pc_plus_four(
		  .i_pc (pc),
		  .o_pc_four (pc_four)
	 );

    // PCSel to select the next PC value
    // Jumps/Branches take the ALU result, otherwise PC+4
    pcsel pcsel(
		  .i_alu_data   (alu_data),
		  .i_pc_four    (pc_four),
		  .i_pc_sel     (i_pc_sel),
		  .o_pc_next    (pc_next)
	 );

    // Instruction Memory
    imem imem (
        .i_pc    (pc),
        .o_instr (o_instr)
    );

    //========================================================
    //  2. Instruction Decode (ID) Stage & Register File Read
    //========================================================

    // Register File instance
    // Reads are asynchronous, writes are on the rising clock edge.
    regfile register_file (
        .i_clk      (i_clk),
        .i_reset    (i_reset),
        .i_rs1_addr (o_instr[19:15]), // Extract rs1 address
        .i_rs2_addr (o_instr[24:20]), // Extract rs2 address
        .o_rs1_data (rs1_data),
        .o_rs2_data (rs2_data),
        .i_rd_addr  (o_instr[11:7]),  // Extract rd address
        .i_rd_data  (wb_data),
        .i_rd_wren  (i_rd_wren)
    );

    // Immediate Generator
    ImmGen immediate_generator (
        .i_instr   (o_instr),
        .o_ImmExt  (ImmExt)
    );

    // Branch Comparison Unit (BRC)
    brc branch_comparison_unit (
        .i_rs1_data (rs1_data),
        .i_rs2_data (rs2_data),
        .i_br_un    (i_br_un),
        .o_br_less  (o_br_less),
        .o_br_equal (o_br_equal)
    );

    //=================================================
    //  3. Execute (EX) Stage
    //=================================================

    // OpASel for ALU Operand A
    // Selects between rs1 data or the current PC
    opasel opasel (
		  .i_pc 		   (pc),
		  .i_rs1_data  (rs1_data),
		  .i_opa_sel   (i_opa_sel),
		  .o_operand_a (operand_a)
	 );

    // OpBSel for ALU Operand B
    // Selects between rs2 data or the immediate value
    opbsel opbsel (
		  .i_ImmExt 	(ImmExt),
		  .i_rs2_data  (rs2_data),
		  .i_opb_sel   (i_opb_sel),
		  .o_operand_b (operand_b)
	 );

    // Arithmetic Logic Unit (ALU)
    alu main_alu (
        .i_op_a     (operand_a),
        .i_op_b     (operand_b),
        .i_alu_op   (i_alu_op),
        .o_alu_data (alu_data)
    );

    //=================================================
    //  4. Memory Access (MEM) Stage
    //=================================================

    // Load-Store Unit (LSU) instance
    lsu load_store_unit (
        .i_clk       (i_clk),
        .i_reset     (i_reset),
		  .i_funct3 	(o_instr[14:12]),
        .i_lsu_addr  (alu_data),
        .i_st_data   (rs2_data),
        .i_lsu_wren  (i_mem_wren),
        .o_ld_data   (ld_data),
        .o_io_ledr   (o_io_ledr),
        .o_io_ledg   (o_io_ledg),
		  .o_io_hex0	(o_io_hex0),
		  .o_io_hex1	(o_io_hex1),
		  .o_io_hex2	(o_io_hex2),
		  .o_io_hex3	(o_io_hex3),
		  .o_io_hex4	(o_io_hex4),
		  .o_io_hex5	(o_io_hex5),
		  .o_io_hex6	(o_io_hex6),
		  .o_io_hex7	(o_io_hex7),
		  .o_io_lcd		(o_io_lcd),
        .i_io_sw     (i_io_sw)
    );


    //=================================================
    //  5. Write-Back (WB) Stage
    //=================================================

    // WBSel for Write-Back data selection
    // Selects what data to write back into the register file.
    wbsel wbsel (
		  .i_pc_four (pc_four),
		  .i_alu_data (alu_data),
		  .i_ld_data (ld_data),
		  .i_wb_sel (i_wb_sel),
		  .o_wb_data (wb_data)
	 );
	 
	 //===============================================
	 //       PC Debug and insn_vld
	 //===============================================
	 
	 always_ff@(posedge i_clk or negedge i_reset) begin
		if(!i_reset)begin
			o_pc_debug <= 32'b0;
		end else begin
			o_pc_debug <= pc;
		end
	 end
	 
	always_ff@(posedge i_clk or negedge i_reset) begin
		if(!i_reset)begin
			o_insn_vld <= 1'b0;
		end else begin
			o_insn_vld <= i_insn_vld;
		end
	 end
endmodule