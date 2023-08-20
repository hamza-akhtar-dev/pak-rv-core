
`ifndef ALU_PKG_SVH

`define ALU_PKG_SVH

    `include "riscv.svh"

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

        function automatic aluop_t gen_aluop_f
        (
            input logic [6:0] opcode,
            input logic [6:0] funct7,
            input logic [2:0] funct3
        );

            aluop_t aluop;
            if (opcode == `OPCODE_OP)
            begin
                case(funct3)
                    `FUNCT3_ADD_SUB:
                    begin
                        case(funct7)
                            `FUNCT7_VAR1: aluop = ADD;
                            `FUNCT7_VAR2: aluop = SUB;
                            default:      aluop = ADD;
                        endcase
                    end
                    `FUNCT3_SLL:  aluop = SLL;
                    `FUNCT3_SLT:  aluop = SLT;
                    `FUNCT3_SLTU: aluop = SLTU;
                    `FUNCT3_XOR:  aluop = XOR;
                    `FUNCT3_SRL_SRA:
                    begin
                        case(funct7)
                            `FUNCT7_VAR1: aluop = SRL;
                            `FUNCT7_VAR2: aluop = SRA;
                            default:      aluop = SRL;
                        endcase
                    end
                    `FUNCT3_OR:   aluop = OR;
                    `FUNCT3_AND:  aluop = AND;
                    default:      aluop = ADD;
                endcase
            end
            else if (opcode == `OPCODE_OPIMM)
            begin
                case(funct3)
                    `FUNCT3_ADD_SUB: aluop = ADD;
                    `FUNCT3_SLL:     aluop = SLL;
                    `FUNCT3_SLT:     aluop = SLT;
                    `FUNCT3_SLTU:    aluop = SLTU;
                    `FUNCT3_XOR:     aluop = XOR;
                    `FUNCT3_SRL_SRA:
                    begin
                        case(funct7)
                            `FUNCT7_VAR1: aluop = SRL;
                            `FUNCT7_VAR2: aluop = SRA;
                            default:      aluop = SRL;
                        endcase
                    end
                    `FUNCT3_OR:   aluop = OR;
                    `FUNCT3_AND:  aluop = AND;
                    default:      aluop = ADD;
                endcase
            end
            else
            begin
                aluop = ADD;
            end

            return aluop;   

        endfunction
        
    endpackage

`endif
