// Execute Stage

`include "ex_stage_pkg.svh"
`include "alu_pkg.svh"

module ex_stage
    import ex_stage_pkg::ex_stage_in_t;
    import ex_stage_pkg::ex_stage_out_t;
    import ex_stage_pkg::gen_aluop_f;
    import alu_pkg::aluop_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  ex_stage_in_t  ex_stage_in,
    output ex_stage_out_t ex_stage_out
);
    // TODO: add immediate selection here
        logic [ 4:0] shamt;
        logic [31:0] imm;

        assign shamt = ex_stage_in.shamt;
        assign imm   = ex_stage_in.imm;
    // -----------------------------------

    aluop_t alu_op;

    assign alu_op = gen_aluop_f(ex_stage_in.opcode, ex_stage_in.funct7, ex_stage_in.funct3);

    alu # (
        .DATA_WIDTH (DATA_WIDTH          )
    ) i_alu (
        .op         (alu_op              ),
        .opr_a      (ex_stage_in.opr_a   ),
        .opr_b      (ex_stage_in.opr_b   ),
        .opr_result (ex_stage_out.opr_res)
    );

    // propagate signals to next stage
    assign ex_stage_out.rd     = ex_stage_in.rd;
    assign ex_stage_out.wb_en  = ex_stage_in.wb_en;
    assign ex_stage_out.wb_sel = ex_stage_in.wb_sel;


endmodule: ex_stage
