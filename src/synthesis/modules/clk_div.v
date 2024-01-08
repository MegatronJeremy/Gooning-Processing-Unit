module clk_div #(
    DIVISOR = 50_000_000
) (
    input  clk,
    input  rst_n,
    output out
);

  integer cnt_reg, cnt_next;
  assign out = (cnt_reg < DIVISOR / 2) ? 1'b1 : 1'b0;

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      cnt_reg <= 0;
    end else begin
      cnt_reg <= cnt_next;
    end
  end

  always @(*) begin
    cnt_next = cnt_reg + 1;

    if (cnt_reg == DIVISOR - 1) begin
      cnt_next = 0;
    end
  end

endmodule
