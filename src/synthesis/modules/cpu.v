module cpu #(
    ADDR_WIDTH = 6,
    DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in,
    input [DATA_WIDTH-1:0] in,
    input control,
    output reg mem_we,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp,
);

// PC
reg pc_ld, pc_inc;
reg [5:0] pc_in;

register #(
    DATA_WIDTH = 6
) pc (
    .clk(clk),
    .rst_n(rst_n),
    .cl(0),
    .ld(pc_ld),
    .inc(pc_inc),
    .dec(0),
    .sr(0),
    .ir(0),
    .sl(0),
    .il(0),
    .in(pc_in),
    .out(pc)
);

// SP
register #(
    DATA_WIDTH = 6
) sp (
    .clk(clk),
    .rst_n(rst_n),
    .cl(0),
    .ld(0),
    .inc(control[1]),
    .dec(0),
    .sr(0),
    .ir(0),
    .sl(0),
    .il(0),
    .in(0),
    .out(sp)
);

// IR
reg ir_high_ld, ir_low_ld;
wire [15:0] ir_high_out, ir_low_out;

wire [3:0] op_code = ir_high_out[15:12];
wire op_a_mode = ir_high_out[11];
wire [2:0] op_a_addr = ir_high_out[10:8];
wire op_b_mode = ir_high_out[7];
wire [2:0] op_b_addr = ir_high_out[6:4];
wire op_c_mode = ir_high_out[3];
wire [2:0] op_c_addr = ir_high_out[2:0];
wire [15:0] op_const = ir_low_out;

register #(
    DATA_WIDTH = 16
) ir_high (
    .clk(clk),
    .rst_n(rst_n),
    .cl(0),
    .ld(ir_high_ld),
    .inc(0),
    .dec(0),
    .sr(0),
    .ir(0),
    .sl(0),
    .il(0),
    .in(mem_in),
    .out(ir_high_out)
);

register #(
    DATA_WIDTH = 16
) ir_low (
    .clk(clk),
    .rst_n(rst_n),
    .cl(0),
    .ld(ir_low_ld),
    .inc(0),
    .dec(0),
    .sr(0),
    .ir(0),
    .sl(0),
    .il(0),
    .in(mem_in),
    .out(ir_low_out)
);

// ACC
wire [15:0] a_out;

reg a_ld;
reg [15:0] a_in;

register #(
    DATA_WIDTH = 16
) a (
    .clk(clk),
    .rst_n(rst_n),
    .cl(0),
    .ld(a_ld),
    .inc(0),
    .dec(0),
    .sr(0),
    .ir(0),
    .sl(0),
    .il(0),
    .in(a_in),
    .out(a_out)
);

// ALU
wire [2:0] alu_op_code = op_code[2:0] - 1;
reg [15:0] alu_a_in, alu_b_in;
wire [15:0] alu_f_out;

alu #(
    DATA_WIDTH = 16
) alu_unit (
    .oc(alu_op_code),
    .a(alu_a_in),
    .b(alu_b_in),
    .f(alu_f_out)
);

// Output regs
reg [2:0] state_reg, state_next;
// reg [ADDR_WIDTH-1:0] mem_addr_reg, mem_addr_next;
// reg [DATA_WIDTH-1:0] mem_data_reg, mem_data_next;
reg [DATA_WIDTH-1:0] out_reg, out_next;

localparam IF, ID, EX1, EX2, EX3, EX4, IDLE = 0, 1, 2, 3, 4, 5, 6;
localparam MOV = 4'b0000, 
    ADD = 4'b0001, SUB = 4'b0010, MUL = 4'b0011, DIV = 4'b0100,
    IN = 4'b0111, OUT = 4'b1000,
    STOP = 4'b1111; 

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state_reg <= IF;
        // mem_addr_reg <= 0;
        // mem_data_reg <= 0;
        out_reg <= 0;
    end else begin
        state_reg <= state_next;
        // mem_addr_reg <= mem_addr_next;
        // mem_data_reg <= mem_data_next;
        out_reg <= out_next;
    end
end

always @(*) begin  
    state_next = state_reg;
    out_next = out_reg;

    mem_we = 0;
    mem_addr = 0;
    mem_data = 0;

    ir_high_ld = 0;
    ir_low_ld = 0;

    pc_in = 0;
    pc_inc = 0;
    pc_ld = 0;

    a_ld = 0;
    a_in = 0;

    alu_a_in = 0;
    alu_b_in = 0;

    case (state_reg)
        IF : begin
            // instruction fetch - load next instruction
            mem_addr = pc + ADDR_WIDTH'd8;

            pc_inc = 1;
            ir_high_ld = 1;
        end
        ID : begin
            case (op_code)
                MOV : begin
                    if (op_c_mode == 1) begin
                        // load second word
                        mem_addr = pc + ADDR_WIDTH'd8;

                        pc_inc = 1;
                        ir_low_ld = 1;

                        state_next = EX1;
                    end
                end 
                default:  state_next = EX1;
            endcase
        end
        EX1 : begin
            case (op_code)
                MOV : begin
                    if (op_c_mode == 0) begin
                        // load source
                        mem_addr = op_b_addr;
                        
                        state_next = EX2;
                    end else begin
                        // store to dest
                        mem_addr = op_a_addr;
                        mem_we = 1;

                        mem_data = op_const;

                        state_next = IF;
                    end 
                end 
                IN : begin
                    // store to dest if enabled
                    if (control) begin
                        mem_addr = op_a_addr;
                        mem_we = 1;

                        mem_data = in;

                        state_next = IF;
                    end else begin
                        // stay in the same state
                        state_next = EX1;
                    end
                end
                OUT : begin
                    // write from dest
                    mem_addr = op_a_addr

                    state_next = EX2;
                end
                ADD, SUB, MUL, DIV: begin
                    // load src b
                    mem_addr = op_b_addr;

                    state_next = EX2;
                end
                STOP: begin
                    mem_addr = op_a_addr;

                    state_next = EX2;
                end
                default: state_next = IF;
            endcase
        end
        EX2: begin
            case (op_code)
                MOV : begin
                    if (op_c_mode == 0) begin
                        // store to dest
                        mem_addr = op_a_addr;
                        mem_we = 1;

                        // chat is this legal?
                        mem_data = mem_in;

                        state_next = IF;
                    end
                end 
                OUT : begin
                    // write to output
                    out_next = mem_in;

                    state_next = IF;
                end
                ADD, SUB, MUL, DIV: begin
                    // store src b to acc, and load src c
                    a_in = mem_in;
                    a_ld = 1;

                    mem_addr = op_c_addr;

                    state_next = EX3;
                end
                STOP: begin
                    if (op_a_addr != 0) begin
                        out_next = mem_in;
                    end 

                    mem_addr = op_b_addr;

                    state_next = EX3;
                end
                default: state_next = IF;
            endcase
        end
        EX3: begin
            case (op_code)
                ADD, SUB, MUL, DIV: begin
                    // store result to mem
                    alu_a_in = a_out;
                    alu_b_in = mem_in;

                    mem_addr = op_a_addr;
                    mem_we = 1;

                    mem_data = alu_f_out;

                    state_next = IF;
                end 
                STOP: begin
                    if (op_b_addr != 0) begin
                        out_next = mem_in;
                    end 

                    mem_addr = op_c_addr;

                    state_next = EX4;
                end
                default: state_next = IF;
            endcase
        end
        EX4: begin
            case (op_code)
                STOP: begin
                    if (op_c_addr != 0) begin
                        out_next = mem_in;
                    end 

                    state_next = IDLE;
                end
                default: state_next = IF;
            endcase
        end
        IDLE: begin
            // do nothing
        end
    endcase
end

endmodule
