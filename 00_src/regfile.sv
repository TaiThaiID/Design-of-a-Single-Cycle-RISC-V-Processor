//==============================================================================
// Module: regfile
// Description: 32x32-bit register file for RISC-V processor
//              - 2 asynchronous read ports
//              - 1 synchronous write port
//==============================================================================

module regfile(
    input  logic        i_clk,
    input  logic        i_reset,      // active-low
    input  logic [4:0]  i_rs1_addr,
    input  logic [4:0]  i_rs2_addr,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data,
    input  logic [4:0]  i_rd_addr,
    input  logic [31:0] i_rd_data,
    input  logic        i_rd_wren
);

  // 32 x 32-bit registers (x0..x31)
  logic [31:0] registers [31:0];
  logic rs1_nonzero;
  logic rs2_nonzero;

  //==========================================
  // Synchronous write
  //==========================================
  always_ff @(posedge i_clk or negedge i_reset) begin
			 if (!i_reset) begin
			
				  registers[0]  <= 32'b0;
				  registers[1]  <= 32'b0;
				  registers[2]  <= 32'b0;
				  registers[3]  <= 32'b0;
				  registers[4]  <= 32'b0;
				  registers[5]  <= 32'b0;
				  registers[6]  <= 32'b0;
				  registers[7]  <= 32'b0;
				  registers[8]  <= 32'b0;
				  registers[9]  <= 32'b0;
				  registers[10] <= 32'b0;
				  registers[11] <= 32'b0;
				  registers[12] <= 32'b0;
				  registers[13] <= 32'b0;
				  registers[14] <= 32'b0;
				  registers[15] <= 32'b0;
				  registers[16] <= 32'b0;
				  registers[17] <= 32'b0;
				  registers[18] <= 32'b0;
				  registers[19] <= 32'b0;
				  registers[20] <= 32'b0;
				  registers[21] <= 32'b0;
				  registers[22] <= 32'b0;
				  registers[23] <= 32'b0;
				  registers[24] <= 32'b0;
				  registers[25] <= 32'b0;
				  registers[26] <= 32'b0;
				  registers[27] <= 32'b0;
				  registers[28] <= 32'b0;
				  registers[29] <= 32'b0;
				  registers[30] <= 32'b0;
				  registers[31] <= 32'b0;
				  
			 end else begin
						if (i_rd_wren & (|i_rd_addr)) begin
							registers[i_rd_addr] <= i_rd_data;
						end
			 end
  end

  
  assign rs1_nonzero = |i_rs1_addr;  
  assign rs2_nonzero = |i_rs2_addr;

  //==========================================
  // Asynchronous read
  //==========================================
  assign o_rs1_data = registers[i_rs1_addr] & {32{rs1_nonzero}};
  assign o_rs2_data = registers[i_rs2_addr] & {32{rs2_nonzero}};

endmodule
