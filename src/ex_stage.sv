// Execute Stage

`include "ex_stage_pkg.svh"
`include "alu_pkg.svh"

module ex_stage
    import ex_stage_pkg::ex_stage_in_t;
    import ex_stage_pkg::ex_stage_in_frm_mem_t;
    import ex_stage_pkg::ex_stage_in_frm_wb_t;
    import ex_stage_pkg::ex_stage_out_t;
    import ex_stage_pkg::ex_cfu_out_t;
    import alu_pkg     ::aluop_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  ex_stage_in_t         ex_stage_in,
    input  ex_stage_in_frm_mem_t ex_stage_in_frm_mem,
    input  ex_stage_in_frm_wb_t  ex_stage_in_frm_wb,
    output ex_stage_out_t        ex_stage_out,
    output ex_cfu_out_t          ex_cfu_out
);

    logic [1:0] for_a;
    logic [1:0] for_b;

    logic signed [DATA_WIDTH-1:0] for_opr_a;
    logic signed [DATA_WIDTH-1:0] for_opr_b;
    logic signed [DATA_WIDTH-1:0] opr_a;
    logic signed [DATA_WIDTH-1:0] opr_b;
    logic signed [DATA_WIDTH-1:0] opr_res;

    // forwarding unit
    fu # (
    ) i_fu (
        .rs1          (ex_stage_in.rs1          ),
        .rs2          (ex_stage_in.rs2          ),
        .rf_en_frm_mem(ex_stage_in_frm_mem.rf_en),
        .rd_frm_mem   (ex_stage_in_frm_mem.rd   ),
        .rf_en_frm_wb (ex_stage_in_frm_wb.rf_en ),
        .rd_frm_wb    (ex_stage_in_frm_wb.rd    ),
        .for_a        (for_a                    ),
        .for_b        (for_b                    )
    );

    // forwarding the operands
    always_comb
    begin
        case(for_a)
            2'b00:   for_opr_a = ex_stage_in.opr_a;
            2'b01:   for_opr_a = ex_stage_in_frm_mem.opr_res;
            2'b10:   for_opr_a = ex_stage_in_frm_wb.wb_data;
            default: for_opr_a = 'b0;
        endcase
        case(for_b)
            2'b00:   for_opr_b = ex_stage_in.opr_b;
            2'b01:   for_opr_b = ex_stage_in_frm_mem.opr_res;
            2'b10:   for_opr_b = ex_stage_in_frm_wb.wb_data;
            default: for_opr_b = 'b0;
        endcase
    end

    // second operand selection
    assign opr_a = (ex_stage_in.opr_a_sel) ? ex_stage_in.pc  : for_opr_a;
    assign opr_b = (ex_stage_in.opr_b_sel) ? ex_stage_in.imm : for_opr_b;

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
        .opr_a     (for_opr_a          ),
        .opr_b     (for_opr_b          ),
        .br_taken  (ex_cfu_out.br_taken)
    );

    // propagate signals to next stage
    assign ex_stage_out.opr_res = opr_res;
    assign ex_stage_out.opr_a   = for_opr_a;
    assign ex_stage_out.opr_b   = for_opr_b;
    assign ex_stage_out.imm     = ex_stage_in.imm;
    assign ex_stage_out.zimm    = ex_stage_in.zimm;
    assign ex_stage_out.rd      = ex_stage_in.rd;
    assign ex_stage_out.pc4     = ex_stage_in.pc4;
    assign ex_stage_out.rf_en   = ex_stage_in.rf_en;
    assign ex_stage_out.dm_wr_en= ex_stage_in.dm_wr_en;
    assign ex_stage_out.dm_rd_en= ex_stage_in.dm_rd_en;
    assign ex_stage_out.csr_wr_en = ex_stage_in.csr_wr_en;
    assign ex_stage_out.wb_sel  = ex_stage_in.wb_sel;
    assign ex_stage_out.lsuop   = ex_stage_in.lsuop;
    assign ex_stage_out.csrop   = ex_stage_in.csrop;
    assign ex_stage_out.amoop   = ex_stage_in.amoop;
    assign ex_stage_out.is_amo  = ex_stage_in.is_amo;

    // combinational signals
    assign ex_cfu_out.br_target = opr_res;


endmodule: ex_stage
