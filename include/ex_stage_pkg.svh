`ifndef EX_STAGE_PKG_SVH

`define EX_STAGE_PKG_SVH

    `include "alu_pkg.svh"
    `include "cfu_pkg.svh"

    package ex_stage_pkg;

        import alu_pkg::aluop_t;
        import cfu_pkg::cfuop_t;

        typedef struct packed 
        {
            logic [ 4:0] rd;
            logic [31:0] opr_a;
            logic [31:0] opr_b;
            logic [31:0] imm;
            // ctrl
            aluop_t      aluop;
            cfuop_t      cfuop;
            logic        rf_en;
            logic        dm_en;
            logic        opr_b_sel;
            logic [ 1:0] wb_sel;
        } ex_stage_in_t;

        typedef struct packed 
        {
            logic        [ 4:0] rd;
            logic signed [31:0] opr_b;
            logic signed [31:0] opr_res;
            // ctrl
            logic               rf_en;
            logic               dm_en;
            logic        [ 1:0] wb_sel;
            logic               br_taken;
        } ex_stage_out_t;
        
    endpackage

`endif
