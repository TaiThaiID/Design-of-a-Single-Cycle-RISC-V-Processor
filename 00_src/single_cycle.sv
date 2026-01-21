module single_cycle (
    input  logic         i_clk     ,
    input  logic         i_reset   ,
    input  logic [31:0]  i_io_sw   ,
    output logic [31:0]  o_io_ledr ,
    output logic [31:0]  o_io_ledg ,
    output logic [31:0]  o_io_lcd  ,
    output logic [ 6:0]  o_io_hex0 ,
    output logic [ 6:0]  o_io_hex1 ,
    output logic [ 6:0]  o_io_hex2 ,
    output logic [ 6:0]  o_io_hex3 ,
    output logic [ 6:0]  o_io_hex4 ,
    output logic [ 6:0]  o_io_hex5 ,
    output logic [ 6:0]  o_io_hex6 ,
    output logic [ 6:0]  o_io_hex7 ,
    output logic [31:0]  o_pc_debug,
    output logic         o_insn_vld
);

	
	//==========================================
	//	Internal Signals 
	//==========================================
	logic 		 pc_sel;
	logic 		 opa_sel;
	logic 		 opb_sel;
	logic [ 3:0] alu_op;
	logic        br_un;
	logic        mem_wren;
	logic [ 1:0] wb_sel;
	logic        rd_wren;
	logic 		 insn_vld;
	logic [31:0] instr;
	logic        br_equal;
	logic        br_less;
	
	//==========================================
	//	Datapath 
	//==========================================
	
	datapath u_datapath(
		// -- Global Signals --
			.i_clk(i_clk),
			.i_reset(i_reset),
			.i_io_sw(i_io_sw),
			.o_io_ledr(o_io_ledr),
			.o_io_ledg(o_io_ledg),
			.o_io_lcd(o_io_lcd),
			.o_io_hex0(o_io_hex0),
			.o_io_hex1(o_io_hex1),
			.o_io_hex2(o_io_hex2),
			.o_io_hex3(o_io_hex3),
			.o_io_hex4(o_io_hex4),
			.o_io_hex5(o_io_hex5),
			.o_io_hex6(o_io_hex6),
			.o_io_hex7(o_io_hex7),
			.o_pc_debug(o_pc_debug),
			.o_insn_vld(o_insn_vld),
		// -- Control Signals from Control Unit --
			.i_pc_sel(pc_sel),
			.i_opa_sel(opa_sel),      
			.i_opb_sel(opb_sel),     
			.i_alu_op(alu_op),      
			.i_br_un(br_un),       
			.i_mem_wren(mem_wren),    
			.i_wb_sel(wb_sel),      
			.i_rd_wren(rd_wren),    
			.i_insn_vld(insn_vld),	
		// -- Outputs to Control Unit --
			.o_instr(instr),       
			.o_br_equal(br_equal),    
			.o_br_less(br_less)     
	);
	
	
	//===========================================
	//	Control Unit 
	//===========================================
	
	control_unit u_control_unit (
		// Instruction input
			.i_instr(instr),      
	  
	  // Branch comparison inputs (from ALU/Comparator)
			.i_br_less(br_less),    
			.i_br_equal(br_equal),   
	  // Control outputs
			.o_pc_sel(pc_sel),     
			.o_rd_wren(rd_wren),    
			.o_insn_vld(insn_vld),  
			.o_br_un(br_un),      
			.o_opa_sel(opa_sel),    
			.o_opb_sel(opb_sel),    
			.o_alu_op(alu_op),     
			.o_mem_wren(mem_wren),  
			.o_wb_sel(wb_sel)     
	);
	
endmodule : single_cycle
