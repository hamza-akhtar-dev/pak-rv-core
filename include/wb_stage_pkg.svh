`ifndef WB_STAGE_PKG_SVH

`define WB_STAGE_PKG_SVH

    package wb_stage_pkg;

        typedef struct packed 
        {
            logic signed [31:0] opr_res;
            logic        [31:0] dmem_rdata;
            logic        [ 4:0] rd;
            // ctrl
            logic               wb_en;
            logic        [ 1:0] wb_sel;
        } wb_stage_in_t;

        typedef struct packed 
        {
            logic [31:0] wb_data;
            logic [ 4:0] rd;
            // ctrl
            logic        wb_en;
        } wb_stage_out_t;

    endpackage

`endif
