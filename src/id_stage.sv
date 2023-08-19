// Instruction Decode Stage

`include "id_stage_pkg.svh"

module id_stage
    import id_stage_pkg::id_stage_in_t;
    import id_stage_pkg::id_stage_out_t;
    import id_stage_pkg::gen_imm_f;
# (
    parameter DATA_WIDTH = 32
) (
    input  logic          clk,
    input  logic          arst_n,
    input  id_stage_in_t  id_stage_in,
    output id_stage_out_t id_stage_out
);
    logic [4:0] rs1;
    logic [4:0] rs2;

    assign rs1 = id_stage_in.inst[19:15];
    assign rs2 = id_stage_in.inst[24:20];

    rf # (
        .DATA_WIDTH(DATA_WIDTH)
    ) i_rf (
        .clk          (clk                ),
        .arst_n       (arst_n             ),
        .wr_en_in     (id_stage_in.wb_en  ),
        .rs1_in       (rs1                ),
        .rs2_in       (rs2                ),
        .rd_in        (id_stage_in.wb_rd  ),
        .rd_data_in   (id_stage_in.wb_data),
        .rs1_data_out (id_stage_out.opr_a ),
        .rs2_data_out (id_stage_out.opr_b )
    );

    assign id_stage_out.opcode = id_stage_in.inst[ 6: 0];
    assign id_stage_out.funct7 = id_stage_in.inst[31:25];
    assign id_stage_out.funct3 = id_stage_in.inst[14:12];
    assign id_stage_out.rd     = id_stage_in.inst[11: 7];
    assign id_stage_out.shamt  = id_stage_in.inst[24:20];

    // immediate generation
    assign id_stage_out.imm    = gen_imm_f(id_stage_in.inst);

endmodule
