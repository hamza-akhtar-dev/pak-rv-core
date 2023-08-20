`ifndef MEM_STAGE_PKG_SVH

`define MEM_STAGE_PKG_SVH

    package mem_stage_pkg;

        typedef struct packed 
        {
            logic        [ 4:0] rd;
            logic signed [31:0] opr_b;
            logic signed [31:0] opr_res;
            // ctrl
            logic               rf_en;
            logic               dm_en;
            logic        [ 1:0] wb_sel;
        } mem_stage_in_t;

        typedef struct packed 
        {
            logic signed [31:0] opr_res;
            logic        [31:0] dmem_rdata;
            logic        [ 4:0] rd;
            // ctrl
            logic               rf_en;
            logic        [ 1:0] wb_sel;
        } mem_stage_out_t;

    endpackage

`endif
