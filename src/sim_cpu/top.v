module top;

  reg  dut_clk;
  reg  dut_rst_n;
  wire clk_div_out;

  clk_div #(
      .DIVISOR(2)
  ) div (
      .clk  (dut_clk),
      .rst_n(dut_rst_n),
      .out  (clk_div_out)
  );

  wire mem_we;
  wire [5:0] mem_addr;
  wire [15:0] mem_data;
  wire [15:0] mem_out;

  memory #(
      .FILE_NAME ("mem_init.hex"),
      .ADDR_WIDTH(6),
      .DATA_WIDTH(16)
  ) memory (
      .clk (clk_div_out),
      .we  (mem_we),
      .addr(mem_addr),
      .data(mem_data),
      .out (mem_out)
  );

  wire [5:0] pc_out, sp_out;

  reg  [15:0] dut_cpu_in;
  wire [15:0] dut_cpu_out;

  cpu #(
      .ADDR_WIDTH(6),
      .DATA_WIDTH(16)
  ) cpu (
      .clk(clk_div_out),
      .rst_n(dut_rst_n),
      .mem_in(mem_out),
      .in(dut_cpu_in),
      .mem_we(mem_we),
      .mem_addr(mem_addr),
      .mem_data(mem_data),
      .out(dut_cpu_out),
      .pc(pc_out),
      .sp(sp_out)
  );

  integer i = 0;

  initial begin
    // Start cpu simulation
    dut_rst_n  = 1'b0;
    dut_rst_n  = #2 ~dut_rst_n;

    dut_cpu_in = 8;

    #200 dut_cpu_in = 9;
    #500 dut_cpu_in = 3;
  end

  initial begin
    dut_clk = 1'b0;
    forever begin
      #5 dut_clk = ~dut_clk;
    end
  end

  always @(posedge clk_div_out) begin
    $strobe(
        "time = %d, mem_in = %b, in = %b, mem_we = %b, mem_addr = %b, mem_data = %b, out = %b, pc = %b, sp = %b",
        $time, mem_out, dut_cpu_in, mem_we, mem_addr, mem_data, dut_cpu_out, pc_out, sp_out);
  end

endmodule
