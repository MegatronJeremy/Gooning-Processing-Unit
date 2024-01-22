module bcd (
    input  [5:0] in,
    output [3:0] ones,
    output [3:0] tens
);

  wire [5:0] ones_ext = in % 6'd10;
  wire [5:0] tens_ext = in / 6'd10;

  assign ones = ones_ext[3:0];
  assign tens = tens_ext[3:0];

endmodule
