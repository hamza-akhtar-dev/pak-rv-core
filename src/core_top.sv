// core_top contains core's pipeline and memory

module core_top # (
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
    logic [3:0]            mem_mask_in;
    logic [ADDR_WIDTH-1:0] mem_addr_in;

    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] instruction;

    core # (
        .DATA_WIDTH                ( DATA_WIDTH                ),
        .SUPPORT_BRANCH_PREDICTION ( SUPPORT_BRANCH_PREDICTION )
    ) i_core (
        .clk                  (clk         ),
        .arst_n               (arst_n      ),
        .pc                   (pc          ),
        .inst_in              (instruction ),
        .core_in_mem_data_out (mem_data_out),
        .core_out_mem_addr_in (mem_addr_in ),
        .core_out_mem_data_in (mem_data_in ),
        .core_out_mem_we_in   (mem_we_in   ),
        .core_out_mem_mask_in (mem_mask_in )
    );

    mem # (
        .DATA_WIDTH (DATA_WIDTH  )
    ) i_mem (
        .clk        (clk         ),
        .arst_n     (arst_n      ),
        .pc         (pc          ),
        .inst_out   (instruction ),
        .write_en   (mem_we_in   ),
        .mask       (mem_mask_in ),
        .addr       (mem_addr_in ),
        .data_in    (mem_data_in ),
        .data_out   (mem_data_out)
    );

endmodule : core_top