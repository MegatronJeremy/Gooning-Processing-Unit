library verilog;
use verilog.vl_types.all;
entity memory is
    generic(
        FILE_NAME       : string  := "mem_init.hex";
        ADDR_WIDTH      : integer := 6;
        DATA_WIDTH      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        we              : in     vl_logic;
        addr            : in     vl_logic_vector;
        data            : in     vl_logic_vector;
        \out\           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FILE_NAME : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end memory;
