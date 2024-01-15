`ifndef AMO_PKG_SVH
`define AMO_PKG_SVH

    `include "riscv.svh"

    package amo_pkg;

        typedef enum logic[3:0] 
        {  
            AMOADD_W, 
            AMOSWAP_W, 
            AMOXOR_W, 
            AMOAND_W, 
            AMOOR_W, 
            AMOMIN_W, 
            AMOMAX_W, 
            AMOMINU_W, 
            AMOMAXU_W
        } amoop_t;

        function automatic amoop_t gen_amoop_f
        (
            input logic [6:0] opcode,
            input logic [4:0] funct5,
            input logic [2:0] funct3
        );

            amoop_t amoop;

            if (opcode == `OPCODE_AMO)
            begin
                case(funct5)
                    `FUNCT5_AMOADD_W : amoop = AMOADD_W; 
                    `FUNCT5_AMOSWAP_W: amoop = AMOSWAP_W; 
                    `FUNCT5_AMOXOR_W : amoop = AMOXOR_W; 
                    `FUNCT5_AMOAND_W : amoop = AMOAND_W; 
                    `FUNCT5_AMOOR_W  : amoop = AMOOR_W; 
                    `FUNCT5_AMOMIN_W : amoop = AMOMIN_W; 
                    `FUNCT5_AMOMAX_W : amoop = AMOMAX_W; 
                    `FUNCT5_AMOMINU_W: amoop = AMOMINU_W; 
                    `FUNCT5_AMOMAXU_W: amoop = AMOMAXU_W;
                    default          : amoop = AMOADD_W;
                endcase
            end
            else begin
                amoop = AMOADD_W;
            end

            return amoop;

        endfunction
        
        // AMO's computational unit interface
        typedef struct packed {
            logic        busy;
            logic [31:0] res;
        } acu_s;

        typedef struct packed {
            logic        wr_en;
            logic        rd_en;
            logic [31:0] addr;
            logic [ 3:0] mask;
            logic [31:0] data;
        } amo_mem_s;


        typedef enum logic [1:0]
        {
            AMO_IDLE,
            AMO_LOAD,
            AMO_CALC,
            AMO_DONE
        } state_t;

    endpackage

`endif