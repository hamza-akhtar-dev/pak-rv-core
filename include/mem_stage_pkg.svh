`ifndef MEM_STAGE_PKG_SVH

`define MEM_STAGE_PKG_SVH

    `include "lsu_pkg.svh"

    package mem_stage_pkg;

        typedef struct packed 
        {
            logic        [ 4:0] rd;
            logic signed [31:0] opr_b;
            logic signed [31:0] opr_res;
            // ctrl
            lsuop_t             lsuop;
            logic               rf_en;
            logic               dm_en;
            logic        [ 1:0] wb_sel;
        } mem_stage_in_t;

        typedef struct packed 
        {
            logic signed [31:0] opr_res;
            logic        [31:0] dmem_rdata;
            logic        [31:0] lsu_rdata;  // data to be loaded in RF from DMEM but manipulated by LSU
            logic        [ 4:0] rd;
            // ctrl
            logic               rf_en;
            logic        [ 1:0] wb_sel;
        } mem_stage_out_t;

    endpackage

`endif
