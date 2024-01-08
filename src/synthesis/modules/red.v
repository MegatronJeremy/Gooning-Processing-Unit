module red (
    input  rst_n,
    input  clk,
    input  in,
    output out
);

  // rising edge detector
  reg [1:0] ff_next, ff_reg;

  assign out = ~ff_reg[1] && ff_reg[0];

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      ff_reg <= 0;
    end else begin
      ff_reg <= ff_next;
    end
  end

  always @(*) begin
    ff_next[1] = ff_reg[0];
    ff_next[0] = in;
  end

endmodule
