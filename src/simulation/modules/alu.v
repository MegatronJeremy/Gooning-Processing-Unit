module alu (
    input  [2:0] oc,
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] f
);

  assign f =  (oc == 3'b000) ? a + b :
                (oc == 3'b001) ? a - b :
                (oc == 3'b010) ? a * b :
                (oc == 3'b011) ? a / b :
                (oc == 3'b100) ? ~a :
                (oc == 3'b101) ? a ^ b :
                (oc == 3'b110) ? a | b :
                (oc == 3'b111) ? a & b :
                4'b0;

endmodule
