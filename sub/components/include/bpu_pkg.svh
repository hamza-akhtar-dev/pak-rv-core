
`ifndef BPU_PKG_SVH

`define BPU_PKG_SVH

    package bpu_pkg;

        typedef enum logic[1:0] 
        {  
            WEAKLY_TAKEN,
            STRONGLY_TAKEN,
            WEAKLY_NOT_TAKEN,
            STRONGLY_NOT_TAKEN
        } state_t;
        
    endpackage

`endif
