module memory #(
    parameter FILE_NAME  = "mem_init.hex",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input we,
    input [ADDR_WIDTH - 1:0] addr,
    input [DATA_WIDTH - 1:0] data,
    output reg [DATA_WIDTH - 1:0] out
);

  reg [DATA_WIDTH - 1:0] mem[2**ADDR_WIDTH - 1:0];

  initial begin
    $readmemh(FILE_NAME, mem);
  end

  always @(posedge clk) begin
    if (we) begin
      mem[addr] = data;
    end
    out <= mem[addr];
  end

endmodule
