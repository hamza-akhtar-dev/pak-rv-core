
`ifndef CSR_PKG_SVH

`define CSR_PKG_SVH

    `include "riscv.svh"

    package csr_pkg;

        typedef enum logic[2:0] 
        {  
            CSRRW, 
            CSRRS, 
            CSRRC, 
            CSRRWI, 
            CSRRSI, 
            CSRRCI
        } csrop_t;

        function automatic csrop_t gen_csrop_f
        (
            input logic [6:0] opcode,
            input logic [2:0] funct3
        );

            csrop_t csrop;

            if (opcode == `OPCODE_CSR)
            begin
                case (funct3)
                    `FUNCT3_CSRRW:  csrop = CSRRW; 
                    `FUNCT3_CSRRS:  csrop = CSRRS; 
                    `FUNCT3_CSRRC:  csrop = CSRRC; 
                    `FUNCT3_CSRRWI: csrop = CSRRWI; 
                    `FUNCT3_CSRRSI: csrop = CSRRSI; 
                    `FUNCT3_CSRRCI: csrop = CSRRCI;
                    default: csrop = CSRRW;
                endcase
            end
            else begin
                csrop = CSRRW;
            end

            return csrop;

        endfunction
        
    endpackage

`endif
