`ifndef IF_STAGE_PKG_SVH

`define IF_STAGE_PKG_SVH

    package if_stage_pkg;

        typedef struct packed 
        {
            logic               br_taken;
            logic signed [31:0] br_target;
            logic               stall;
        } if_stage_in_t;


        typedef struct packed 
        {
            logic [31:0] inst;
            logic [31:0] pc;
            logic [31:0] pc4;
        } if_stage_out_t;

    endpackage

`endif
