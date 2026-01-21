module pcplus4(
    input  logic [31:0] i_pc,
    output logic [31:0] o_pc_four
);
    adder32 pc_plus_four (
        .a     (i_pc),
        .b     (32'd4),   
        .c_in  (1'b0),
        .s     (o_pc_four)   
    );

endmodule 
