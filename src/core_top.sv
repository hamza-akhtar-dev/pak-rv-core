// core_top contains core's pipeline and memory

module core_top
    import lsu_pkg::mem_to_lsu_s;
    import lsu_pkg::lsu_to_mem_s;
# (
    parameter DATA_WIDTH                = 32,
    parameter ADDR_WIDTH                = 32,
    parameter SUPPORT_BRANCH_PREDICTION = 1
)(
    input logic clk,
    input logic arst_n
);

    logic [DATA_WIDTH-1:0] mem_data_out;
    logic [DATA_WIDTH-1:0] mem_data_in;
    logic                  mem_we_in;
    logic                  mem_re_in;
    logic                  mem_w_success;
    logic                  mem_r_success;
    logic [3:0]            mem_mask_in;
    logic [ADDR_WIDTH-1:0] mem_addr_in;

    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] instruction;

    mem_to_lsu_s           mem_to_lsu;
    lsu_to_mem_s           lsu_to_mem;

    core # (
        .DATA_WIDTH                ( DATA_WIDTH                ),
        .SUPPORT_BRANCH_PREDICTION ( SUPPORT_BRANCH_PREDICTION )
    ) i_core (
        .clk                       ( clk                       ),
        .arst_n                    ( arst_n                    ),
        .pc                        ( pc                        ),
        .inst_in                   ( instruction               ),

        .mem_to_lsu                ( mem_to_lsu                ),
        .lsu_to_mem                ( lsu_to_mem                )
    );

    // lsu to mem (or core to main memory interface)
    assign mem_we_in   = lsu_to_mem.write_en;
    assign mem_re_in   = lsu_to_mem.read_en;
    assign mem_addr_in = lsu_to_mem.addr;
    assign mem_data_in = lsu_to_mem.data;
    assign mem_mask_in = lsu_to_mem.strb;

    // mem to lsu interface
    assign mem_to_lsu.w_success = mem_w_success;
    assign mem_to_lsu.r_success = mem_r_success;
    assign mem_to_lsu.data      = mem_data_out;

    mem # (
        .DATA_WIDTH  ( DATA_WIDTH    )
    ) i_mem (
        .clk         ( clk           ),
        .arst_n      ( arst_n        ),
        .pc          ( pc            ),
        .inst_out    ( instruction   ),
        .write_en    ( mem_we_in     ),
        .read_en     ( mem_re_in     ),
        .w_success   ( mem_w_success ),
        .r_success   ( mem_r_success ),
        .mask        ( mem_mask_in   ),
        .addr        ( mem_addr_in   ),
        .data_in     ( mem_data_in   ),
        .data_out    ( mem_data_out  )
    );

endmodule : core_top