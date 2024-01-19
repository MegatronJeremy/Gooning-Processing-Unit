module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in,
    input [DATA_WIDTH-1:0] in,
    output reg mem_we,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp
);

  // PC
  reg pc_ld, pc_inc;
  reg [5:0] pc_in;

  register #(
      .DATA_WIDTH(6)
  ) pc_reg (
      .clk(clk),
      .rst_n(rst_n),
      .cl(1'b0),
      .ld(pc_ld),
      .inc(pc_inc),
      .dec(1'b0),
      .sr(1'b0),
      .ir(1'b0),
      .sl(1'b0),
      .il(1'b0),
      .in(pc_in),
      .out(pc)
  );

  reg [5:0] sp_in;

  // SP
  register #(
      .DATA_WIDTH(6)
  ) sp_reg (
      .clk(clk),
      .rst_n(rst_n),
      .cl(1'b0),
      .ld(1'b0),
      .inc(1'b0),
      .dec(1'b0),
      .sr(1'b0),
      .ir(1'b0),
      .sl(1'b0),
      .il(1'b0),
      .in(sp_in),
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
      .DATA_WIDTH(16)
  ) ir_high (
      .clk(clk),
      .rst_n(rst_n),
      .cl(1'b0),
      .ld(ir_high_ld),
      .inc(1'b0),
      .dec(1'b0),
      .sr(1'b0),
      .ir(1'b0),
      .sl(1'b0),
      .il(1'b0),
      .in(mem_in),
      .out(ir_high_out)
  );

  register #(
      .DATA_WIDTH(16)
  ) ir_low (
      .clk(clk),
      .rst_n(rst_n),
      .cl(1'b0),
      .ld(ir_low_ld),
      .inc(1'b0),
      .dec(1'b0),
      .sr(1'b0),
      .ir(1'b0),
      .sl(1'b0),
      .il(1'b0),
      .in(mem_in),
      .out(ir_low_out)
  );

  // ACC
  wire [15:0] a_out;

  reg a_ld;
  reg [15:0] a_in;

  register #(
      .DATA_WIDTH(16)
  ) a_reg (
      .clk(clk),
      .rst_n(rst_n),
      .cl(1'b0),
      .ld(a_ld),
      .inc(1'b0),
      .dec(1'b0),
      .sr(1'b0),
      .ir(1'b0),
      .sl(1'b0),
      .il(1'b0),
      .in(a_in),
      .out(a_out)
  );

  // ALU
  wire [2:0] alu_op_code = op_code[2:0] - 1;
  reg [15:0] alu_a_in, alu_b_in;
  wire [15:0] alu_f_out;

  alu #(
      .DATA_WIDTH(16)
  ) alu_unit (
      .in(alu_op_code),
      .a (alu_a_in),
      .b (alu_b_in),
      .f (alu_f_out)
  );

  // Output regs
  reg [3:0] state_reg, state_next;
  reg [1:0] loading_reg, loading_next;
  reg [1:0] storing_reg, storing_next;
  reg [DATA_WIDTH-1:0] out_reg, out_next;

  assign out = out_reg;

  localparam DIRECT = 0, INDIRECT1 = 1, INDIRECT2 = 2, DONE = 3;
  localparam IF1 = 0, IF2 = 1, ID = 2, EX1 = 3, EX2 = 4, EX3 = 5, EX4 = 6, EX5 = 7, IDLE = 8;
  localparam MOV = 4'b0000, 
    ADD = 4'b0001, SUB = 4'b0010, MUL = 4'b0011, DIV = 4'b0100,
    IN = 4'b0111, OUT = 4'b1000,
    STOP = 4'b1111;

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      state_reg <= IF1;
      out_reg <= 0;
      loading_reg <= DONE;
      storing_reg <= DONE;
    end else begin
      state_reg <= state_next;
      out_reg <= out_next;
      loading_reg <= loading_next;
      storing_reg <= storing_next;
    end
  end

  function reg load(input reg [5:0] addr, input reg mode);
    begin
      if (loading_next == DONE) begin
        if (mode == 0) begin
          loading_next = DIRECT;
        end else begin
          loading_next = INDIRECT1;
        end
      end

      case (loading_next)
        DIRECT: begin
          mem_addr = addr;

          loading_next = DONE;

          load = 1;
        end
        INDIRECT1: begin
          mem_addr = addr;

          loading_next = INDIRECT2;

          load = 0;
        end
        INDIRECT2: begin
          mem_addr = mem_in;

          loading_next = DONE;

          load = 1;
        end
        default: load = 1;
      endcase
    end
  endfunction

  function reg store(input reg [5:0] addr, input reg [15:0] data, input reg mode);
    begin
      if (storing_next == DONE) begin
        if (mode == 0) begin
          storing_next = DIRECT;
        end else begin
          storing_next = INDIRECT1;
        end
      end

      case (storing_next)
        DIRECT: begin
          mem_addr = addr;
          mem_we = 1;

          mem_data = data;

          storing_next = DONE;

          store = 1;
        end
        INDIRECT1: begin
          // first load address to store to (just like load)
          mem_addr = addr;

          storing_next = INDIRECT2;

          store = 0;
        end
        INDIRECT2: begin
          mem_addr = mem_in;  // address is data from previous cycle
          mem_we = 1;

          mem_data = data;

          storing_next = DONE;

          store = 1;
        end
        default: store = 1;
      endcase
    end
  endfunction

  always @(*) begin
    state_next = state_reg;
    loading_next = loading_reg;
    storing_next = storing_reg;
    out_next = out_reg;

    mem_we = 0;
    mem_addr = 0;
    mem_data = 0;

    ir_high_ld = 0;
    ir_low_ld = 0;

    pc_in = 0;
    pc_inc = 0;
    pc_ld = 0;

    sp_in = 0;

    a_ld = 0;
    a_in = 0;

    alu_a_in = 0;
    alu_b_in = 0;

    case (state_reg)
      IF1: begin
        // instruction fetch - load next instruction
        mem_addr   = pc + 8;

        state_next = IF2;
      end
      IF2: begin
        pc_inc = 1;
        ir_high_ld = 1;

        state_next = ID;
      end
      ID: begin
        case (op_code)
          MOV: begin
            if (op_c_mode == 1) begin
              // load second word
              mem_addr = pc + 8;

              pc_inc = 1;
              ir_low_ld = 1;
            end

            state_next = EX1;
          end
          default: state_next = EX1;
        endcase
      end
      EX1: begin
        case (op_code)
          MOV: begin
            if (op_c_mode == 0) begin
              // load source
              if (load(op_b_addr, op_b_mode) == 0) begin
                state_next = EX1;
              end else begin
                state_next = EX2;
              end
            end else begin
              // store to dest
              if (store(op_a_addr, op_const, op_a_mode) == 0) begin
                state_next = EX1;
              end else begin
                state_next = IF1;
              end
            end
          end
          IN: begin
            // store to dest asynchronously
            if (store(op_a_addr, in, op_a_mode) == 0) begin
              state_next = EX1;
            end else begin
              state_next = IF1;
            end
          end
          OUT: begin
            // write from dest
            if (load(op_a_addr, op_a_mode) == 0) begin
              state_next = EX1;
            end else begin
              state_next = EX2;
            end
          end
          ADD, SUB, MUL, DIV: begin
            // load src b
            if (load(op_b_addr, op_b_mode) == 0) begin
              state_next = EX1;
            end else begin
              state_next = EX2;
            end
          end
          STOP: begin
            if (op_a_addr != 0) begin
              // write from dest
              if (load(op_a_addr, op_a_mode) == 0) begin
                state_next = EX1;
              end else begin
                state_next = EX2;
              end
            end else begin
              state_next = EX2;
            end
          end
          default: state_next = IF1;
        endcase
      end
      EX2: begin
        case (op_code)
          MOV: begin
            // store to dest
            if (store(op_a_addr, mem_in, op_a_mode) == 0) begin
              state_next = EX2;
            end else begin
              state_next = IF1;
            end
          end
          OUT: begin
            // write to output
            out_next   = mem_in;

            state_next = IF1;
          end
          ADD, SUB, MUL, DIV: begin
            // store src b to acc
            a_in = mem_in;
            a_ld = 1;

            state_next = EX3;
          end
          STOP: begin
            if (op_a_addr != 0) begin
              out_next = mem_in;
            end

            if (op_b_addr != 0) begin
              // write from dest
              if (load(op_b_addr, op_b_mode) == 0) begin
                state_next = EX2;
              end else begin
                state_next = EX3;
              end
            end else begin
              state_next = EX3;
            end
          end
          default: state_next = IF1;
        endcase
      end
      EX3: begin
        case (op_code)
          ADD, SUB, MUL, DIV: begin
            // load src c
            if (load(op_c_addr, op_c_mode) == 0) begin
              state_next = EX3;
            end else begin
              state_next = EX4;
            end

            state_next = EX4;
          end
          STOP: begin
            if (op_b_addr != 0) begin
              out_next = mem_in;
            end

            if (op_c_addr != 0) begin
              // write from dest
              if (load(op_c_addr, op_c_mode) == 0) begin
                state_next = EX3;
              end else begin
                state_next = EX4;
              end
            end else begin
              state_next = EX4;
            end
          end
          default: state_next = IF1;
        endcase
      end
      EX4: begin
        case (op_code)
          ADD, SUB, MUL, DIV: begin
            // store result to acc first
            alu_a_in = a_out;
            alu_b_in = mem_in;

            a_in = alu_f_out;
            a_ld = 1;

            state_next = EX5;
          end

          STOP: begin
            if (op_c_addr != 0) begin
              out_next = mem_in;
            end

            state_next = IDLE;
          end
          default: state_next = IF1;
        endcase
      end
      EX5: begin
        case (op_code)
          ADD, SUB, MUL, DIV: begin
            if (store(op_a_addr, a_out, op_a_mode) == 0) begin
              state_next = EX5;
            end else begin
              state_next = IF1;
            end
          end
          default: state_next = IF1;
        endcase
      end
      IDLE: begin
        // do nothing
      end
    endcase
  end
endmodule
