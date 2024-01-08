module moduleName #(
    DATA_WIDTH = 16
) (
    input [2:0] in,
    input [DATA_WIDTH-1:0] a,
    input [DATA_WIDTH-1:0] b,
    output [DATA_WIDTH-1:0] f
);

    assign f =  (in == 3'b000) ? a + b :
                    (in == 3'b001) ? a - b :
                    (in == 3'b010) ? a * b :
                    (in == 3'b011) ? a / b :
                    (in == 3'b100) ? ~a :
                    (in == 3'b101) ? a ^ b :
                    (in == 3'b110) ? a | b :
                    (in == 3'b111) ? a & b :
                    DATA_WIDTH'b0;

endmodule
