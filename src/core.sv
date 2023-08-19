// Core

`include "if_stage_pkg.svh"
`include "id_stage_pkg.svh"
`include "ex_stage_pkg.svh"
`include "mem_stage_pkg.svh"
`include "wb_stage_pkg.svh"

module core 
    import id_stage_pkg ::id_stage_in_t;
    import ex_stage_pkg ::ex_stage_in_t;
    import mem_stage_pkg::mem_stage_in_t;
    import wb_stage_pkg ::wb_stage_in_t;
    import if_stage_pkg ::if_stage_out_t;
    import id_stage_pkg ::id_stage_out_t;
    import ex_stage_pkg ::ex_stage_out_t;
    import mem_stage_pkg::mem_stage_out_t;
    import wb_stage_pkg ::wb_stage_out_t;
# (
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

    logic       wb_en;
    logic [1:0] wb_sel;

    // stage instantiations

    if_stage # (
        .IMEM_SZ_IN_KB (IMEM_SZ_IN_KB)
    ) i_if_stage (
        .clk           (clk          ),
        .arst_n        (arst_n       ),
        .if_stage_out  (if_stage_out )
    );

    assign id_stage_in = {if_stage_out, wb_stage_out.wb_en, wb_stage_out.wb_rd, wb_stage_out.wb_data};

    id_stage #(
    ) i_id_stage (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .id_stage_in (id_stage_in ),
        .id_stage_out(id_stage_out)
    );

    ctrl_unit #(
    ) i_ctrl_unit (
        .clk         (clk                  ),
        .arst_n      (arst_n               ),
        .opcode      (id_stage_in.inst[6:0]),
        .wb_en       (wb_en                ),
        .wb_sel      (wb_sel               )
    );
    assign id_stage_out.wb_en  = wb_en;
    assign id_stage_out.wb_sel = wb_sel;

    assign ex_stage_in = id_stage_out;

    ex_stage #(
    ) i_ex_stage (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .ex_stage_in (ex_stage_in ),
        .ex_stage_out(ex_stage_out)
    );

    assign mem_stage_in = ex_stage_out;

    mem_stage #(
    ) i_mem_stage (
        .clk          (clk         ),
        .arst_n       (arst_n      ),
        .mem_stage_in (mem_stage_in ),
        .mem_stage_out(mem_stage_out)
    );

    assign wb_stage_in = mem_stage_out;

    wb_stage #(
    ) i_wb_stage (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .wb_stage_in (wb_stage_in ),
        .wb_stage_out(wb_stage_out)
    );

endmodule: core
