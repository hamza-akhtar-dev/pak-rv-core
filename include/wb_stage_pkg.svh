`ifndef WB_STAGE_PKG_SVH

`define WB_STAGE_PKG_SVH

    package wb_stage_pkg;

        typedef struct packed 
        {
            logic signed [31:0] opr_res;
            logic        [31:0] lsu_rdata;
            logic        [ 4:0] rd;
            logic        [31:0] pc4;
            // ctrl
            logic               rf_en;
            logic        [ 1:0] wb_sel;

            // to shared memory (redundant for wb stage)
            logic        [ 3:0] mask;
            logic        [31:0] core_out_mem_addr_in;
            logic        [31:0] core_out_mem_data_in;
        } wb_stage_in_t;

        typedef struct packed 
        {
            logic [31:0] wb_data;
            logic [ 4:0] rd;
            // ctrl
            logic        rf_en;
        } wb_stage_out_t;

    endpackage

`endif
