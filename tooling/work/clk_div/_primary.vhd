library verilog;
use verilog.vl_types.all;
entity clk_div is
    generic(
        DIVISOR         : integer := 50000000
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        \out\           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DIVISOR : constant is 1;
end clk_div;
