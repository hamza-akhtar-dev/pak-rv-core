`ifndef EX_STAGE_PKG_SVH

`define EX_STAGE_PKG_SVH

    `include "alu_pkg.svh"
    `include "cfu_pkg.svh"
    `include "lsu_pkg.svh"

    package ex_stage_pkg;

        import alu_pkg::aluop_t;
        import cfu_pkg::cfuop_t;
        import lsu_pkg::lsuop_t;

        typedef struct packed
        {
            logic [ 4:0] rs1;
            logic [ 4:0] rs2;
            logic [ 4:0] rd;
            logic [31:0] opr_a;
            logic [31:0] opr_b;
            logic [31:0] imm;
            logic [31:0] pc;
            logic [31:0] pc4;
            // ctrl
            aluop_t      aluop;
            cfuop_t      cfuop;
            lsuop_t      lsuop;
            logic        rf_en;
            logic        dm_en;
            logic        opr_a_sel;
            logic        opr_b_sel;
            logic [ 1:0] wb_sel;
        } ex_stage_in_t;

        typedef struct packed
        {
            logic        rf_en;
            logic [ 4:0] rd;
            logic [31:0] opr_res;
        } ex_stage_in_frm_mem_t;

        typedef struct packed
        {
            logic        rf_en;
            logic [ 4:0] rd;
            logic [31:0] lsu_rdata;
        } ex_stage_in_frm_wb_t;

        typedef struct packed
        {
            logic        [ 4:0] rd;
            logic signed [31:0] opr_b;
            logic signed [31:0] opr_res;
            logic        [31:0] pc4;
            // ctrl
            lsuop_t             lsuop;
            logic               rf_en;
            logic               dm_en;
            logic        [ 1:0] wb_sel;
        } ex_stage_out_t;

        typedef struct packed 
        {
            logic               br_taken;
            logic signed [31:0] br_target;
        } ex_cfu_out_t;
        
    endpackage

`endif
