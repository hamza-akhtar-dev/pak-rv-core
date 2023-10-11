`ifndef MEM_STAGE_PKG_SVH

`define MEM_STAGE_PKG_SVH

    `include "lsu_pkg.svh"

    package mem_stage_pkg;

        import lsu_pkg::lsuop_t;

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
        } mem_stage_in_t;

        typedef struct packed 
        {
            logic signed [31:0] opr_res;
            logic        [31:0] lsu_rdata;
            logic        [ 4:0] rd;
            logic        [31:0] pc4;
            // ctrl
            logic               rf_en;
            logic        [ 1:0] wb_sel;

            // to shared memory
            logic        [ 3:0] mask;
            logic        [31:0] core_out_mem_addr_in;
            logic        [31:0] core_out_mem_data_in;
        } mem_stage_out_t;

    endpackage

`endif
