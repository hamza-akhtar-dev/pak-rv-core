
`ifndef AMO_PKG_SVH

`define AMO_PKG_SVH

    `include "riscv.svh"

    package amo_pkg;

        typedef enum logic[3:0] 
        {  
            LR,
            SC,
            SWAP,
            ADD,
            XOR,
            AND,
            OR,
            MIN,
            MAX,
            MINU,
            MAXU
        } amoop_t;

        function automatic amoop_t gen_amoop_f
        (
            input logic [4:0] funct5
        );

            amoop_t amoop;

            case (funct5)
                `FUNCT5_LR  : amoop = LR;
                `FUNCT5_SC  : amoop = SC;
                `FUNCT5_SWAP: amoop = SWAP;
                `FUNCT5_ADD : amoop = ADD;
                `FUNCT5_XOR : amoop = XOR;
                `FUNCT5_AND : amoop = AND;
                `FUNCT5_OR  : amoop = OR;
                `FUNCT5_MIN : amoop = MIN;
                `FUNCT5_MAX : amoop = MAX;
                `FUNCT5_MINU: amoop = MINU;
                default     : amoop = MAXU;
            endcase

            return amoop;   

        endfunction
        
    endpackage

`endif
