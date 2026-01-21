module adder32(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        c_in,      // 0: ADD, 1: SUB
    output logic [31:0] s,
    output logic        c_out 
);
	
	
	   logic [32:0] carry_tmp;
   	logic [31:0] temp;
	
	// Selection ADD or SUB 
    	assign temp = c_in ? ~b : b;

	// carry_tmp in
    	assign carry_tmp[0] = c_in;

	
	// --- 32 full adders ----
    full_adder fa0  (.a(a[0]),  .b(temp[0]),  .c_in(carry_tmp[0]),  .s(s[0]),  .c_out(carry_tmp[1]));
    full_adder fa1  (.a(a[1]),  .b(temp[1]),  .c_in(carry_tmp[1]),  .s(s[1]),  .c_out(carry_tmp[2]));
    full_adder fa2  (.a(a[2]),  .b(temp[2]),  .c_in(carry_tmp[2]),  .s(s[2]),  .c_out(carry_tmp[3]));
    full_adder fa3  (.a(a[3]),  .b(temp[3]),  .c_in(carry_tmp[3]),  .s(s[3]),  .c_out(carry_tmp[4]));
    full_adder fa4  (.a(a[4]),  .b(temp[4]),  .c_in(carry_tmp[4]),  .s(s[4]),  .c_out(carry_tmp[5]));
    full_adder fa5  (.a(a[5]),  .b(temp[5]),  .c_in(carry_tmp[5]),  .s(s[5]),  .c_out(carry_tmp[6]));
    full_adder fa6  (.a(a[6]),  .b(temp[6]),  .c_in(carry_tmp[6]),  .s(s[6]),  .c_out(carry_tmp[7]));
    full_adder fa7  (.a(a[7]),  .b(temp[7]),  .c_in(carry_tmp[7]),  .s(s[7]),  .c_out(carry_tmp[8]));
    full_adder fa8  (.a(a[8]),  .b(temp[8]),  .c_in(carry_tmp[8]),  .s(s[8]),  .c_out(carry_tmp[9]));
    full_adder fa9  (.a(a[9]),  .b(temp[9]),  .c_in(carry_tmp[9]),  .s(s[9]),  .c_out(carry_tmp[10]));
    full_adder fa10 (.a(a[10]), .b(temp[10]), .c_in(carry_tmp[10]), .s(s[10]), .c_out(carry_tmp[11]));
    full_adder fa11 (.a(a[11]), .b(temp[11]), .c_in(carry_tmp[11]), .s(s[11]), .c_out(carry_tmp[12]));
    full_adder fa12 (.a(a[12]), .b(temp[12]), .c_in(carry_tmp[12]), .s(s[12]), .c_out(carry_tmp[13]));
    full_adder fa13 (.a(a[13]), .b(temp[13]), .c_in(carry_tmp[13]), .s(s[13]), .c_out(carry_tmp[14]));
    full_adder fa14 (.a(a[14]), .b(temp[14]), .c_in(carry_tmp[14]), .s(s[14]), .c_out(carry_tmp[15]));
    full_adder fa15 (.a(a[15]), .b(temp[15]), .c_in(carry_tmp[15]), .s(s[15]), .c_out(carry_tmp[16]));
    full_adder fa16 (.a(a[16]), .b(temp[16]), .c_in(carry_tmp[16]), .s(s[16]), .c_out(carry_tmp[17]));
    full_adder fa17 (.a(a[17]), .b(temp[17]), .c_in(carry_tmp[17]), .s(s[17]), .c_out(carry_tmp[18]));
    full_adder fa18 (.a(a[18]), .b(temp[18]), .c_in(carry_tmp[18]), .s(s[18]), .c_out(carry_tmp[19]));
    full_adder fa19 (.a(a[19]), .b(temp[19]), .c_in(carry_tmp[19]), .s(s[19]), .c_out(carry_tmp[20]));
    full_adder fa20 (.a(a[20]), .b(temp[20]), .c_in(carry_tmp[20]), .s(s[20]), .c_out(carry_tmp[21]));
    full_adder fa21 (.a(a[21]), .b(temp[21]), .c_in(carry_tmp[21]), .s(s[21]), .c_out(carry_tmp[22]));
    full_adder fa22 (.a(a[22]), .b(temp[22]), .c_in(carry_tmp[22]), .s(s[22]), .c_out(carry_tmp[23]));
    full_adder fa23 (.a(a[23]), .b(temp[23]), .c_in(carry_tmp[23]), .s(s[23]), .c_out(carry_tmp[24]));
    full_adder fa24 (.a(a[24]), .b(temp[24]), .c_in(carry_tmp[24]), .s(s[24]), .c_out(carry_tmp[25]));
    full_adder fa25 (.a(a[25]), .b(temp[25]), .c_in(carry_tmp[25]), .s(s[25]), .c_out(carry_tmp[26]));
    full_adder fa26 (.a(a[26]), .b(temp[26]), .c_in(carry_tmp[26]), .s(s[26]), .c_out(carry_tmp[27]));
    full_adder fa27 (.a(a[27]), .b(temp[27]), .c_in(carry_tmp[27]), .s(s[27]), .c_out(carry_tmp[28]));
    full_adder fa28 (.a(a[28]), .b(temp[28]), .c_in(carry_tmp[28]), .s(s[28]), .c_out(carry_tmp[29]));
    full_adder fa29 (.a(a[29]), .b(temp[29]), .c_in(carry_tmp[29]), .s(s[29]), .c_out(carry_tmp[30]));
    full_adder fa30 (.a(a[30]), .b(temp[30]), .c_in(carry_tmp[30]), .s(s[30]), .c_out(carry_tmp[31]));
    full_adder fa31 (.a(a[31]), .b(temp[31]), .c_in(carry_tmp[31]), .s(s[31]), .c_out(carry_tmp[32]));


	// carry_tmp out 
   	assign c_out = carry_tmp[32];
    
endmodule
