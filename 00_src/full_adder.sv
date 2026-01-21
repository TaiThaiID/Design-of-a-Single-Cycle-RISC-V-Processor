module full_adder (
    input  logic a,
    input  logic b,
    input  logic c_in,
    output logic s,
    output logic c_out
);
    assign s     = a ^ b ^ c_in;
    assign c_out = (a & b) | (a & c_in) | (b & c_in);
	 
endmodule
