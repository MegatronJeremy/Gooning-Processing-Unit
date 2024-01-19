library verilog;
use verilog.vl_types.all;
entity cpu is
    generic(
        ADDR_WIDTH      : integer := 6;
        DATA_WIDTH      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        mem_in          : in     vl_logic_vector;
        \in\            : in     vl_logic_vector;
        mem_we          : out    vl_logic;
        mem_addr        : out    vl_logic_vector;
        mem_data        : out    vl_logic_vector;
        \out\           : out    vl_logic_vector;
        pc              : out    vl_logic_vector;
        sp              : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end cpu;
