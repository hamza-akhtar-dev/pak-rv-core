// Execute Stage

`include "ex_stage_pkg.svh"
`include "alu_pkg.svh"

module ex_stage
    import ex_stage_pkg::ex_stage_in_t;
    import ex_stage_pkg::ex_stage_out_t;
    import ex_stage_pkg::ex_cfu_out_t;
    import alu_pkg::aluop_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  ex_stage_in_t  ex_stage_in,
    output ex_stage_out_t ex_stage_out,
    output ex_cfu_out_t   ex_cfu_out
);

    logic signed [DATA_WIDTH-1:0] opr_a;
    logic signed [DATA_WIDTH-1:0] opr_b;
    logic signed [DATA_WIDTH-1:0] opr_res;

    // second operand selection
    assign opr_a = (ex_stage_in.opr_a_sel) ? ex_stage_in.pc : ex_stage_in.opr_a;
    assign opr_b = (ex_stage_in.opr_b_sel) ? ex_stage_in.imm : ex_stage_in.opr_b;

    alu # (
        .DATA_WIDTH (DATA_WIDTH       )
    ) i_alu (
        .aluop      (ex_stage_in.aluop),
        .opr_a      (opr_a            ),
        .opr_b      (opr_b            ),
        .opr_result (opr_res          )
    );

    cfu # (
        .DATA_WIDTH(DATA_WIDTH         )
    ) i_cfu (
        .cfuop     (ex_stage_in.cfuop  ),
        .opr_a     (ex_stage_in.opr_a  ),
        .opr_b     (ex_stage_in.opr_b  ),
        .br_taken  (ex_cfu_out.br_taken)
    );

    // propagate signals to next stage
    assign ex_stage_out.opr_res = opr_res;
    assign ex_stage_out.opr_b   = ex_stage_in.opr_b;
    assign ex_stage_out.rd      = ex_stage_in.rd;
    assign ex_stage_out.pc4     = ex_stage_in.pc4;
    assign ex_stage_out.rf_en   = ex_stage_in.rf_en;
    assign ex_stage_out.dm_en   = ex_stage_in.dm_en;
    assign ex_stage_out.wb_sel  = ex_stage_in.wb_sel;
    assign ex_stage_out.lsuop   = ex_stage_in.lsuop;

    // combinational signals
    assign ex_cfu_out.br_target = opr_res;


endmodule: ex_stage
