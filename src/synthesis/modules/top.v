module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex
);

  wire clk_div_out;

  clk_div #(
      .DIVISOR(DIVISOR)
  ) div (
      .clk  (clk),
      .rst_n(rst_n),
      .out  (clk_div_out)
  );

  wire mem_we;
  wire [ADDR_WIDTH-1:0] mem_addr;
  wire [DATA_WIDTH-1:0] mem_data;
  wire [DATA_WIDTH-1:0] mem_out;

  memory #(
      .FILE_NAME (FILE_NAME),
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) memory (
      .clk (clk_div_out),
      .we  (mem_we),
      .addr(mem_addr),
      .data(mem_data),
      .out (mem_out)
  );

  wire [ADDR_WIDTH-1:0] pc_out, sp_out;

  wire cpu_in = {{(DATA_WIDTH - 4) {1'b0}}, sw[3:0]};
  wire cpu_out = {{(DATA_WIDTH - 5) {1'b0}}, led[4:0]};

  cpu #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) cpu (
      .clk(clk_div_out),
      .rst_n(rst_n),
      .mem_in(mem_out),
      .in(cpu_in),
      .mem_we(mem_we),
      .mem_addr(mem_addr),
      .mem_data(mem_data),
      .out(cpu_out),
      .pc(pc_out),
      .sp(sp_out)
  );

  wire [3:0] sp_ones, sp_tens, pc_ones, pc_tens;

  bcd bcd_pc (
      .in  (pc_out),
      .ones(pc_ones),
      .tens(pc_tens)
  );

  bcd bcd_sp (
      .in  (sp_out),
      .ones(sp_ones),
      .tens(sp_tens)
  );

  ssd ssd_pc_tens (
      .in (pc_tens),
      .out(hex[27:21])
  );

  ssd ssd_pc_ones (
      .in (pc_ones),
      .out(hex[20:14])
  );

  ssd ssd_sp_tens (
      .in (sp_tens),
      .out(hex[13:7])
  );

  ssd ssd_sp_ones (
      .in (sp_ones),
      .out(hex[6:0])
  );

endmodule
