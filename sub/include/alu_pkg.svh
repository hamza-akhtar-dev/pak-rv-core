
`ifndef ALU_PKG_SVH

`define ALU_PKG_SVH

    package alu_pkg;

        typedef enum logic[3:0] 
        {  
            ADD, 
            SUB, 
            AND, 
            OR, 
            XOR, 
            SLL, 
            SRL, 
            SRA, 
            SLT, 
            SLTU
        } aluop_t;
        
    endpackage

`endif
