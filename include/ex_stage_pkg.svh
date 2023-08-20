`ifndef EX_STAGE_PKG_SVH

`define EX_STAGE_PKG_SVH

    `include "alu_pkg.svh"

    package ex_stage_pkg;

        import alu_pkg::aluop_t;

        typedef struct packed 
        {
            logic [ 6:0] opcode;
            logic [ 6:0] funct7;
            logic [ 2:0] funct3;
            logic [ 4:0] shamt;
            logic [ 4:0] rd;
            logic [31:0] imm;
            logic [31:0] opr_a;
            logic [31:0] opr_b;
            // ctrl
            logic        wb_en;
            logic [ 1:0] wb_sel;
        } ex_stage_in_t;

        typedef struct packed 
        {
            logic signed [31:0] opr_res;
            logic        [ 4:0] rd;
            // ctrl
            logic               wb_en;
            logic        [ 1:0] wb_sel;
        } ex_stage_out_t;

        function automatic aluop_t gen_aluop_f
        (
            input logic [6:0] opcode,
            input logic [6:0] funct7,
            input logic [2:0] funct3
        );

            // TODO: add other cases

            aluop_t aluop;

            case (funct3)
                3'b000:  aluop = (funct7[5]) ? alu_pkg::SUB : alu_pkg::ADD;
                3'b001:  aluop = alu_pkg::SLL;
                3'b010:  aluop = alu_pkg::SLT;
                3'b011:  aluop = alu_pkg::SLTU;
                3'b100:  aluop = alu_pkg::XOR;
                3'b101:  aluop = (funct7[5]) ? alu_pkg::SRA : alu_pkg::SRL;
                3'b110:  aluop = alu_pkg::OR;
                3'b111:  aluop = alu_pkg::AND;
                default: aluop = alu_pkg::ADD;
            endcase

            return aluop;   

        endfunction
        
    endpackage

`endif
