// Core

module core # (
    parameter  DATA_WIDTH    = 32,
    parameter  IMEM_SZ_IN_KB = 1,
    parameter  DMEM_SZ_IN_KB = 1,
    localparam PC_SIZE       = 32
)(
    input  logic clk,
    input  logic arst_n
);
    // stage signals

    if_stage_out_t if_stage_out;

    id_stage_in_t  id_stage_in;
    id_stage_out_t id_stage_out;

    ex_stage_in_t  ex_stage_in;
    ex_stage_out_t ex_stage_out;

    mem_stage_in_t  mem_stage_in;
    mem_stage_out_t mem_stage_out;

    wb_stage_in_t  wb_stage_in;
    wb_stage_out_t wb_stage_out;

    // control signals

    logic wb_en;
    logic dm_en;
    logic wb_sel;

    // stage instantiations

    if_stage # (
        .DATA_WIDTH    (DATA_WIDTH   ),
        .IMEM_SZ_IN_KB (IMEM_SZ_IN_KB)
    ) i_if_stage (
        .clk           (clk          ),
        .arst_n        (arst_n       ),
        .if_stage_out  (if_stage_out )
    );

    ctrl_unit #(
        .DATA_WIDTH  (DATA_WIDTH  )
    ) i_ctrl_unit (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .id_stage_in (if_),
    );

    assign id_stage_in = if_stage_out;

    id_stage #(
        .DATA_WIDTH  (DATA_WIDTH  )
    ) i_id_stage (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .id_stage_in (id_stage_in ),
        .id_stage_out(id_stage_out)
    );

    ex_stage #(
        .DATA_WIDTH  (DATA_WIDTH  )
    ) i_ex_stage (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .ex_stage_in (ex_stage_in ),
        .ex_stage_out(ex_stage_out)
    );

    mem_stage #(
        .DATA_WIDTH  (DATA_WIDTH  )
    ) i_mem_stage (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .mem_stage_in (mem_stage_in ),
        .mem_stage_out(mem_stage_out)
    );

    wb_stage #(
        .DATA_WIDTH  (DATA_WIDTH  )
    ) i_wb_stage (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .wb_stage_in (wb_stage_in ),
        .wb_stage_out(wb_stage_out)
    );

endmodule: core
