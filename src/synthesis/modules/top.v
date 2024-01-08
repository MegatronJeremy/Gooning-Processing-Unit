module top #(
    DIVISOR = 50_000_000,
    FILE_NAME = "mem_init.mif",
    ADDR_WIDTH = 6,
    DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [2:0] btn,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex
);

    wire clk_div_out;

    div #(
        DIVISOR = DIVISOR
    ) div (
        .clk(clk),
        .rst_n(rst_n),
        .clk_div(clk_div_out)
    );

    wire mem_we;
    wire [ADDR_WIDTH-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_data;
    wire [DATA_WIDTH-1:0] mem_out;

    memory #(
        FILE_NAME = FILE_NAME,
        ADDR_WIDTH = ADDR_WIDTH,
        DATA_WIDTH = DATA_WIDTH
    ) memory (
        .clk(clk_div_out),
        .we(mem_we),
        .addr(mem_addr),
        .data(mem_data),
        .out(mem_out)
    );

    wire [ADDR_WIDTH-1:0] pc_out, sp_out;

    cpu #(
        ADDR_WIDTH = ADDR_WIDTH,
        DATA_WIDTH = DATA_WIDTH
    ) cpu (
        .clk(clk_div_out),
        .rst_n(rst_n),
        .mem_in(mem_out),
        .in(sw[3:0]),
        .control(btn[0]),
        .mem_we(mem_we),
        .mem_addr(mem_addr),
        .mem_data(mem_data),
        .out(led[4:0]),
        .pc(pc_out),
        .sp(sp_out)
    );

    wire [3:0] sp_ones, sp_tens, pc_ones, pc_tens;

    bcd_pc bcd (
        .in(pc_out),
        .ones(pc_ones),
        .tens(pc_tens)
    );

    bcd_sp bcd (
        .in(sp_out),
        .ones(sp_ones),
        .tens(sp_tens)
    );

    ssd_pc_tens ssd (
        .in(pc_tens),
        .out(hex[27:21])
    );

    ssd_pc_ones ssd (
        .in(pc_ones).
        .out(hex[20:14])
    );

    ssd_sp_tens ssd (
        .in(sp_tens),
        .out(hex[13:7])
    );

    ssd_sp_ones ssd (
        .in(sp_ones),
        .out(hex[6:0])
    );

endmodule
