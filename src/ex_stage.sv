// Execute Stage

`include "ex_stage_pkg.svh"

module ex_stage
    import ex_stage_pkg::ex_stage_in_t;
    import ex_stage_pkg::ex_stage_out_t;
    import ex_stage_pkg::aluop_t;
    import ex_stage_pkg::gen_aluop_f;
# (
    parameter DATA_WIDTH     = 32,
    parameter NUM_REGISTERS  = 32,
    localparam ADDRESS_WIDTH = $clog2(NUM_REGISTERS)
) (
    input ex_stage_in_t  ex_stage_in,
    input ex_stage_out_t ex_stage_out
);

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

    // signal bypassed to next stage
    assign ex_stage_out.rd = ex_stage_in.rd;

endmodule: ex_stage
