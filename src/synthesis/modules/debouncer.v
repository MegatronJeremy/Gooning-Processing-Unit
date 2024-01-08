module debouncer #(
    parameter WIDTH = 2
) (
    input  clk,
    input  rst_n,
    input  in,
    output out
);

  // debouncer 
  reg [WIDTH - 1:0] cnt_next, cnt_reg;
  reg [1:0] ff_next, ff_reg;
  reg out_reg, out_next;

  assign changed = ff_reg[0] ^ ff_reg[1];
  assign stable = cnt_reg == {WIDTH{1'b1}} ? 1'b1 : 1'b0;
  assign out = out_reg;

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      ff_reg  <= 0;
      cnt_reg <= 0;
      out_reg <= 0;
    end else begin
      ff_reg  <= ff_next;
      cnt_reg <= cnt_next;
      out_reg <= out_next;
    end
  end

  always @(*) begin
    ff_next[1] = ff_reg[0];
    ff_next[0] = in;
    cnt_next   = changed ? 0 : cnt_reg + 1;
    out_next   = stable ? ff_reg[1] : out_reg;
  end

endmodule
