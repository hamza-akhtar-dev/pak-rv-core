`ifndef CFU_PKG_SVH

`define CFU_PKG_SVH

    `include "riscv.svh"

    package cfu_pkg;

        typedef enum logic[3:0] 
        {  
            BEQ,
            BNE,
            BLT,
            BGE,
            BLTU,
            BGEU,
            JAL,
            JALR,
            NB  // no branch
        } cfuop_t;

        function automatic cfuop_t gen_cfuop_f
        (
            input logic [6:0] opcode,
            input logic [2:0] funct3
        );

            cfuop_t cfuop;

            if (opcode == `OPCODE_BRANCH)
            begin
                case(funct3)
                    `FUNCT3_BEQ:  cfuop = BEQ;
                    `FUNCT3_BNE:  cfuop = BNE;
                    `FUNCT3_BLT:  cfuop = BLT;
                    `FUNCT3_BGE:  cfuop = BGE;
                    `FUNCT3_BLTU: cfuop = BLTU;
                    `FUNCT3_BGEU: cfuop = BGEU;
                    default:      cfuop = BEQ;
                endcase
            end
            else if (opcode == `OPCODE_JALR)
            begin
                cfuop = JALR;
            end
            else if (opcode == `OPCODE_JAL)
            begin
                cfuop = JAL;
            end
            else
            begin
                cfuop = NB;
            end

            return cfuop;   

        endfunction
        
    endpackage

`endif
