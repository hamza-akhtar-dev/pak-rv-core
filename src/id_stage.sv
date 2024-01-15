// Instruction Decode Stage

`include "id_stage_pkg.svh"
`include "wb_stage_pkg.svh"

module id_stage
    import id_stage_pkg::id_stage_in_t;
    import id_stage_pkg::id_stage_in_frm_ex_t;
    import id_stage_pkg::id_stage_out_t;
    import id_stage_pkg::id_hdu_out_t;
    import wb_stage_pkg::wb_stage_out_t;
    import id_stage_pkg::gen_imm_f;
    import id_stage_pkg::gen_zimm_f;
# (
    parameter DATA_WIDTH = 32
) (
    input  logic                clk,
    input  logic                arst_n,
    input  wb_stage_out_t       wb_in, // writeback interface
    input  id_stage_in_t        id_stage_in,
    input  id_stage_in_frm_ex_t id_stage_in_frm_ex,
    output id_stage_out_t       id_stage_out,
    output id_hdu_out_t         id_hdu_out
);
    logic [4:0] rs1;
    logic [4:0] rs2;

    assign rs1 = id_stage_in.inst[19:15];
    assign rs2 = id_stage_in.inst[24:20];

    rf # (
        .DATA_WIDTH   (DATA_WIDTH        )
    ) i_rf (
        .clk          (clk               ),
        .arst_n       (arst_n            ),
        // write back interface
        .wr_en_in     (wb_in.rf_en       ),
        .rd_in        (wb_in.rd          ),
        .rd_data_in   (wb_in.wb_data     ),
        // read interface
        .rs1_in       (rs1               ),
        .rs2_in       (rs2               ),
        .rs1_data_out (id_stage_out.opr_a),
        .rs2_data_out (id_stage_out.opr_b)
    );

    logic [6:0] opcode;
    logic [6:0] funct7;
    logic [4:0] funct5;
    logic [2:0] funct3;

    assign opcode = id_stage_in.inst[ 6: 0];
    assign funct7 = id_stage_in.inst[31:25];
    assign funct5 = id_stage_in.inst[31:27];
    assign funct3 = id_stage_in.inst[14:12];

    // injecting control signals
    ctrl_unit #(
    ) i_ctrl_unit (
        .opcode      (opcode                ),
        .funct7      (funct7                ),
        .funct5      (funct5                ),
        .funct3      (funct3                ),
        .aluop       (id_stage_out.aluop    ),
        .cfuop       (id_stage_out.cfuop    ),
        .lsuop       (id_stage_out.lsuop    ),
        .csrop       (id_stage_out.csrop    ),
        .amoop       (id_stage_out.amoop    ),
        .rf_en       (id_stage_out.rf_en    ),
        .dm_wr_en    (id_stage_out.dm_wr_en ),
        .dm_rd_en    (id_stage_out.dm_rd_en ),
        .csr_wr_en   (id_stage_out.csr_wr_en),
        .is_amo      (id_stage_out.is_amo   ),
        .opr_a_sel   (id_stage_out.opr_a_sel),
        .opr_b_sel   (id_stage_out.opr_b_sel),
        .wb_sel      (id_stage_out.wb_sel   )
    );

    hdu #(
    ) i_hdu (
        .rs1           (rs1                      ),
        .rs2           (rs2                      ),
        .rd_frm_ex     (id_stage_in_frm_ex.rd    ),
        .wb_sel_frm_ex (id_stage_in_frm_ex.wb_sel),
        .stall         (id_hdu_out.stall         ),
        .flush         (id_hdu_out.flush         )
    );

    assign id_stage_out.rd  = id_stage_in.inst[11:7];

    // immediate generation
    assign id_stage_out.imm  = gen_imm_f(id_stage_in.inst);
    assign id_stage_out.zimm = gen_zimm_f(id_stage_in.inst);

    // propagate signals to next stage
    assign id_stage_out.rs1 = rs1;
    assign id_stage_out.rs2 = rs2;
    assign id_stage_out.pc  = id_stage_in.pc;
    assign id_stage_out.pc4 = id_stage_in.pc4;

endmodule
