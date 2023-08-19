`ifndef IF_STAGE_PKG_SVH

`define IF_STAGE_PKG_SVH

    package if_stage_pkg;

        typedef struct packed 
        {
            logic [31:0] inst;
        } if_stage_out_t;

    endpackage

`endif
