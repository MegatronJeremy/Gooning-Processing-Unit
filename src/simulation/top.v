module top;

  reg  [2:0] dut_alu_oc;
  reg  [3:0] dut_alu_a;
  reg  [3:0] dut_alu_b;
  wire [3:0] dut_alu_f;

  alu dut_alu (
      .oc(dut_alu_oc),
      .a (dut_alu_a),
      .b (dut_alu_b),
      .f (dut_alu_f)
  );

  reg dut_clk;
  reg dut_rst_n;
  reg dut_cl;
  reg dut_ld;
  reg dut_inc;
  reg dut_dec;
  reg dut_sr;
  reg dut_ir;
  reg dut_sl;
  reg dut_il;
  reg [3:0] dut_reg_in;
  wire [3:0] dut_reg_out;

  register dut_register (
      .clk(dut_clk),
      .rst_n(dut_rst_n),
      .cl(dut_cl),
      .ld(dut_ld),
      .inc(dut_inc),
      .dec(dut_dec),
      .sr(dut_sr),
      .ir(dut_ir),
      .sl(dut_sl),
      .il(dut_il),
      .in(dut_reg_in),
      .out(dut_reg_out)
  );

  integer i = 0;

  initial begin
    // Start ALU simulation
    $monitor("time = %d, oc = %b, a = %b, b = %b, f = %b", $time, dut_alu_oc, dut_alu_a, dut_alu_b,
             dut_alu_f);

    for (i = 0; i < 2 ** (3 + 4 + 4); i = i + 1) begin
      if (i == {11'h400}) begin
        // temporarily pause when starting logic operations
        $stop;
      end

      {dut_alu_oc, dut_alu_a, dut_alu_b} = i;
      #5;
    end

    $stop;
    // Start register simulation
    dut_rst_n = 1'b0;
    dut_rst_n = #2 ~dut_rst_n;

    repeat (1000) begin
      {dut_cl, dut_ld, dut_inc, dut_dec, dut_sr, dut_ir, dut_sl, dut_il, dut_reg_in} 
        = $urandom_range(0, 2 ** 12 - 1);
      #10;
    end

    $finish;
  end

  initial begin
    dut_clk = 1'b0;
    forever begin
      #5 dut_clk = ~dut_clk;
    end
  end

  always @(dut_reg_out) begin
    $strobe(
        "time = %d, cl = %b, ld = %b, inc = %b, dec = %b, sr = %b, ir = %b, sl = %b, il = %b, in = %b, out = %b",
        $time, dut_cl, dut_ld, dut_inc, dut_dec, dut_sr, dut_ir, dut_sl, dut_il, dut_reg_in,
        dut_reg_out);
  end

endmodule
