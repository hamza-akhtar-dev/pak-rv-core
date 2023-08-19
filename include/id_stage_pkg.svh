`ifndef ID_STAGE_PKG_SVH

`define ID_STAGE_PKG_SVH

    `include "riscv.svh"

    package id_stage_pkg;

        typedef struct packed 
        {
            logic [31:0] inst;
            // feedback from write back stage
            logic        wb_en;
            logic [ 4:0] wb_rd;
            logic [31:0] wb_data;
        } id_stage_in_t;

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
        } id_stage_out_t;

        function automatic logic[31:0] gen_imm_f 
        (
            input logic [31:0] inst
        );

            logic [31:0] imm;
            logic [ 6:0] opcode;

            opcode = inst[6:0];

            case(opcode)
                `OPCODE_ITYPE: imm = {{20{inst[31]}}, inst[31:20]};
                `OPCODE_STYPE: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
                `OPCODE_BTYPE: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
                `OPCODE_UTYPE: imm = {{12{inst[31]}}, inst[31:12]};
                `OPCODE_JTYPE: imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
                default: imm = 0;
            endcase

            return imm;

        endfunction

    endpackage

`endif
