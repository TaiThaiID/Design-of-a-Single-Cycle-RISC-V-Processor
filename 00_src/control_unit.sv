//===================================================================================
// Module: Control Unit 
// Description: This module decodes RISC-V instructions and generates control signals
// 				 for the datapath components (ALU, Register File, Memory, PC, etc.)
//===================================================================================

module control_unit (
  // Instruction input
  input  logic [31:0] i_instr,      
  
  // Branch comparison inputs (from ALU/Comparator)
  input  logic        i_br_less,    
  input  logic        i_br_equal,   
  // Control outputs
  output logic        o_pc_sel,     // PC source select: 1 => branch/jump target, 0 => PC+4
  output logic        o_rd_wren,    // Register file write enable for rd
  output logic        o_insn_vld,   // Instruction valid & properly encoded flag
  output logic        o_br_un,      // Branch unsigned: 0 => unsigned compare (BLTU/BGEU), 1 => signed
  output logic        o_opa_sel,    // ALU operand A select: 0 => rs1, 1 => PC
  output logic        o_opb_sel,    // ALU operand B select: 0 => rs2, 1 => immediate
  output logic [3:0]  o_alu_op,     // ALU operation selector
  output logic        o_mem_wren,   // Memory write enable: 1 => Store instruction
  output logic [1:0]  o_wb_sel      // Write-back source: 00 => ALU, 01 => Load, 10 => PC+4
);

  // ====================================================================
  // Internal Signals - Instruction Field Extraction
  // ====================================================================
  logic [6:0] opcode;  
  logic [2:0] funct3;  
  logic [6:0] funct7;  
  
  // Extract instruction fields
  assign opcode = i_instr[6:0];
  assign funct3 = i_instr[14:12];
  assign funct7 = i_instr[31:25];

  // ====================================================================
  // Opcode Definitions
  // ====================================================================
  localparam OPC_RTYPE  = 7'b0110011;  
  localparam OPC_ITYPE  = 7'b0010011;  
  localparam OPC_LOAD   = 7'b0000011;  
  localparam OPC_STORE  = 7'b0100011;  
  localparam OPC_BRANCH = 7'b1100011;  
  localparam OPC_LUI    = 7'b0110111;  
  localparam OPC_AUIPC  = 7'b0010111;  
  localparam OPC_JAL    = 7'b1101111;  
  localparam OPC_JALR   = 7'b1100111;  

  // ====================================================================
  // ALU Operation Encodings
  // ====================================================================
  localparam ALU_ADD   = 4'b0000;  
  localparam ALU_SUB   = 4'b0001;  
  localparam ALU_SLL   = 4'b0010;  
  localparam ALU_SLT   = 4'b0011;  
  localparam ALU_SLTU  = 4'b0100;  
  localparam ALU_XOR   = 4'b0101;  
  localparam ALU_SRL   = 4'b0110;  
  localparam ALU_SRA   = 4'b0111;  
  localparam ALU_OR    = 4'b1000;  
  localparam ALU_AND   = 4'b1001;  
  localparam ALU_LUI   = 4'b1010;  
  localparam ALU_AUIPC = 4'b1011;  
  
  // ====================================================================
  // Write-Back Source Select Encodings
  // ====================================================================
  localparam WB_ALU = 2'b00;  
  localparam WB_LD  = 2'b01;  
  localparam WB_PC4 = 2'b10;  

  // ====================================================================
  // Raw Control Signals 
  // ====================================================================
  logic        pc_sel_raw;    
  logic        rd_wren_raw;   
  logic        mem_wren_raw;  
  logic [1:0]  wb_sel_raw;    
  logic [3:0]  alu_op_raw;    
  logic        opa_sel_raw;   
  logic        opb_sel_raw;   
  logic        br_un_raw;     

  // ====================================================================
  // Instruction Validity and Branch Taken Logic
  // ====================================================================
  logic insn_vld_tmp;  
  logic taken;         

  // ====================================================================
  // Main Instruction Decode Logic
  // ====================================================================
  always_comb begin
    // Default values - assume invalid instruction with safe defaults
    insn_vld_tmp = 1'b0;      // Invalid until proven valid
    pc_sel_raw   = 1'b0;      // Default to PC+4
    rd_wren_raw  = 1'b0;      // No register write
    mem_wren_raw = 1'b0;      // No memory write
    wb_sel_raw   = WB_ALU;    // Default write-back source
    alu_op_raw   = ALU_ADD;   // Default ALU operation
    opa_sel_raw  = 1'b0;      // Default operand A = rs1
    opb_sel_raw  = 1'b0;      // Default operand B = rs2
    br_un_raw    = 1'b1;      // Default to signed comparison
    taken        = 1'b0;      // Branch not taken by default

    case (opcode)
      // =======================================================================
      // R-Type Instructions: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
      // =======================================================================
      OPC_RTYPE: begin
        insn_vld_tmp = 1'b1;
        rd_wren_raw  = 1'b1;      // Write result to rd
        wb_sel_raw   = WB_ALU;    // Write back ALU result
        opa_sel_raw  = 1'b0;      // Operand A = rs1
        opb_sel_raw  = 1'b0;      // Operand B = rs2
        
        case (funct3)
          3'b000: alu_op_raw = (funct7[5]) ? ALU_SUB : ALU_ADD; 
          3'b001: alu_op_raw = ALU_SLL;   
          3'b010: alu_op_raw = ALU_SLT;   
          3'b011: alu_op_raw = ALU_SLTU;  
          3'b100: alu_op_raw = ALU_XOR;   
          3'b101: alu_op_raw = (funct7[5]) ? ALU_SRA : ALU_SRL;  
          3'b110: alu_op_raw = ALU_OR;    
          3'b111: alu_op_raw = ALU_AND;  
          default: insn_vld_tmp = 1'b0;   
        endcase
      end

      // =============================================================================
      // I-Type ALU Instructions: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
      // =============================================================================
      OPC_ITYPE: begin
        insn_vld_tmp = 1'b1;
        rd_wren_raw  = 1'b1;      // Write result to rd
        wb_sel_raw   = WB_ALU;    // Write back ALU result
        opa_sel_raw  = 1'b0;      // Operand A = rs1
        opb_sel_raw  = 1'b1;      // Operand B = immediate
        
        case (funct3)
          3'b000: alu_op_raw = ALU_ADD;   
          3'b010: alu_op_raw = ALU_SLT;   
          3'b011: alu_op_raw = ALU_SLTU;  
          3'b100: alu_op_raw = ALU_XOR;   
          3'b110: alu_op_raw = ALU_OR;    
          3'b111: alu_op_raw = ALU_AND;   
          
          3'b001: begin  
            alu_op_raw = ALU_SLL;
            if (~|(funct7 ^ 7'b0000000)) insn_vld_tmp = 1'b1;
            else                      insn_vld_tmp = 1'b0;
          end
          
          3'b101: begin  
            if      (~|(funct7 ^ 7'b0000000)) alu_op_raw = ALU_SRL;  
            else if (~|(funct7 ^ 7'b0100000)) alu_op_raw = ALU_SRA;  
            else                           insn_vld_tmp = 1'b0;   
          end
          
          default: insn_vld_tmp = 1'b0;
        endcase
      end

      // ================================================================
      // LOAD Instructions: LB, LH, LW, LBU, LHU
      // ================================================================
      OPC_LOAD: begin
        insn_vld_tmp = 1'b1;
        rd_wren_raw  = 1'b1;      // Write loaded data to rd
        wb_sel_raw   = WB_LD;     // Write back memory data
        opa_sel_raw  = 1'b0;      // Operand A = rs1 
        opb_sel_raw  = 1'b1;      // Operand B = immediate 
        alu_op_raw   = ALU_ADD;   // Calculate address: rs1 + imm
      end

      // ================================================================
      // STORE Instructions: SB, SH, SW
      // ================================================================
      OPC_STORE: begin
        // Valid only for byte (000), half (001), word (010)
        insn_vld_tmp = (~|(funct3 ^ 3'b000)) || (~|(funct3 ^ 3'b001)) || (~|(funct3 ^ 3'b010));
        mem_wren_raw = 1'b1;      // Enable memory write
        opa_sel_raw  = 1'b0;      // Operand A = rs1 
        opb_sel_raw  = 1'b1;      // Operand B = immediate 
        alu_op_raw   = ALU_ADD;   // Calculate address: rs1 + imm
      end

      // ================================================================
      // BRANCH Instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
      // ================================================================
      OPC_BRANCH: begin
        opa_sel_raw  = 1'b1;      // Operand A = PC 
        opb_sel_raw  = 1'b1;      // Operand B = immediate 
        alu_op_raw   = ALU_ADD;   // Calculate target: PC + imm

        // Determine if comparison should be unsigned
        // BLTU (110) and BGEU (111) use unsigned comparison
        br_un_raw = ~((~|(funct3 ^ 3'b110)) || (~|(funct3 ^ 3'b111)));

        case (funct3)
          3'b000: taken =  i_br_equal;  // BEQ
          3'b001: taken = ~i_br_equal;  // BNE
          3'b100: taken =  i_br_less;   // BLT
          3'b101: taken = ~i_br_less;   // BGE
          3'b110: taken =  i_br_less;   // BLTU
          3'b111: taken = ~i_br_less;   // BGEU
          default: taken = 1'b0;        // Invalid branch type - don't take
        endcase
        
        pc_sel_raw = taken;  // Update PC if branch is taken
       
        insn_vld_tmp = (~|(funct3 ^ 3'b000)) || (~|(funct3 ^ 3'b001)) ||
                       (~|(funct3 ^ 3'b100)) || (~|(funct3 ^ 3'b101)) ||
                       (~|(funct3 ^ 3'b110)) || (~|(funct3 ^ 3'b111));
      end

      // ================================================================
      // LUI:rd = imm << 12
      // ================================================================
      OPC_LUI: begin
        insn_vld_tmp = 1'b1;
        rd_wren_raw  = 1'b1;      // Write to rd
        wb_sel_raw   = WB_ALU;    // Write back ALU result
        opa_sel_raw  = 1'b0;      // Operand A = rs1 
        opb_sel_raw  = 1'b1;      // Operand B = immediate 
        alu_op_raw   = ALU_LUI;   // ALU: 0 + (imm<<12)
      end

      // ================================================================
      // AUIPC: rd = PC + (imm << 12)
      // ================================================================
      OPC_AUIPC: begin
        insn_vld_tmp = 1'b1;
        rd_wren_raw  = 1'b1;      // Write to rd
        wb_sel_raw   = WB_ALU;    // Write back ALU result
        opa_sel_raw  = 1'b1;      // Operand A = PC
        opb_sel_raw  = 1'b1;      // Operand B = immediate 
        alu_op_raw   = ALU_AUIPC; // ALU: PC + (imm << 12)
      end

      // ================================================================
      // JAL: rd = PC + 4, PC = PC + sign_extend(imm)
      // ================================================================
      OPC_JAL: begin
        insn_vld_tmp = 1'b1;
        rd_wren_raw  = 1'b1;      // Write return address to rd
        wb_sel_raw   = WB_PC4;    // Write back PC+4 
        pc_sel_raw   = 1'b1;      // Update PC to jump target
        opa_sel_raw  = 1'b1;      // Operand A = PC
        opb_sel_raw  = 1'b1;      // Operand B = immediate 
        alu_op_raw   = ALU_ADD;   // PC + imm
      end

      // ================================================================
      // JALR: Jump And Link Register
      // Format: imm[11:0] | rs1 | 000 | rd | opcode
      // Result: rd = PC + 4, PC = (rs1 + sign_extend(imm)) & ~1
      // Note: LSB of target address is cleared to ensure alignment
      // ================================================================
      OPC_JALR: begin
        insn_vld_tmp = (~|(funct3 ^ 3'b000));  // Only valid with funct3 = 000
        rd_wren_raw  = 1'b1;      // Write return address to rd
        wb_sel_raw   = WB_PC4;    // Write back PC+4 
        pc_sel_raw   = 1'b1;      // Update PC to jump target
        opa_sel_raw  = 1'b0;      // Operand A = rs1 
        opb_sel_raw  = 1'b1;      // Operand B = immediate 
        alu_op_raw   = ALU_ADD;   // rs1 + imm (LSB clear handled in PC logic)
      end

      // ================================================================
      // Default: Invalid/Unrecognized Opcode
      // ================================================================
      default: begin
        insn_vld_tmp = 1'b0;  
      end
    endcase
  end

  // ====================================================================
  // Output Assignments 
  // ====================================================================
  // When instruction is invalid, generate safe control signals that
  // act like a NOP (no operation) to prevent unintended side effects
  
  // Core validity and write enables 
  assign o_insn_vld = insn_vld_tmp;
  assign o_rd_wren  = rd_wren_raw  & insn_vld_tmp;  // Only write if valid
  assign o_mem_wren = mem_wren_raw & insn_vld_tmp;  // Only write memory if valid
  assign o_pc_sel   = pc_sel_raw   & insn_vld_tmp;  // Only jump/branch if valid

  // Branch unsigned: default to signed (1) for invalid instructions
  assign o_br_un = br_un_raw | (~insn_vld_tmp);
  
  // Mux selects: default to safe values (rs1, rs2, ADD) for invalid instructions
  assign o_opa_sel = insn_vld_tmp ? opa_sel_raw : 1'b0;  // Default to rs1
  assign o_opb_sel = insn_vld_tmp ? opb_sel_raw : 1'b0;  // Default to rs2
  assign o_alu_op  = insn_vld_tmp ? alu_op_raw  : ALU_ADD;   // Default to ADD
  assign o_wb_sel  = insn_vld_tmp ? wb_sel_raw  : WB_ALU;    // Default to ALU result

endmodule