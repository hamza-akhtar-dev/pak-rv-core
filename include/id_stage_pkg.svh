`ifndef ID_STAGE_PKG_SVH

`define ID_STAGE_PKG_SVH

    `include "riscv.svh"

    `include "alu_pkg.svh"
    `include "cfu_pkg.svh"
    `include "lsu_pkg.svh"
    `include "csr_pkg.svh"

    import alu_pkg::aluop_t;
    import cfu_pkg::cfuop_t;
    import lsu_pkg::lsuop_t;
    import csr_pkg::csrop_t;

    package id_stage_pkg;

        typedef struct packed 
        {
            logic [31:0] inst;
            logic [31:0] pc;
            logic [31:0] pc4;
        } id_stage_in_t;

        typedef struct packed
        {
            logic [4:0] rd;
            logic [1:0] wb_sel;
        } id_stage_in_frm_ex_t;

        typedef struct packed 
        {
            logic [ 4:0] rs1;
            logic [ 4:0] rs2;
            logic [ 4:0] rd;
            logic [31:0] opr_a;
            logic [31:0] opr_b;
            logic [31:0] imm;
            logic [31:0] zimm;
            logic [31:0] pc;
            logic [31:0] pc4;
            // ctrl
            aluop_t      aluop;
            cfuop_t      cfuop;
            lsuop_t      lsuop;
            csrop_t      csrop;
            logic        rf_en;
            logic        dm_en;
            logic        csr_wr_en;
            logic        opr_a_sel;
            logic        opr_b_sel;
            logic [ 1:0] wb_sel;
        } id_stage_out_t;

        typedef struct packed
        {
            logic stall;
            logic flush;
        } id_hdu_out_t;

        function automatic logic[31:0] gen_imm_f 
        (
            input logic [31:0] inst
        );

            logic [31:0] imm;
            logic [ 6:0] opcode;

            opcode = inst[6:0];

            case(opcode)
                `OPCODE_OPIMM, `OPCODE_LOAD, `OPCODE_JALR: // I-type
                begin
                    imm = {{20{inst[31]}}, inst[31:20]};
                end
                `OPCODE_STORE: // S-type
                begin     
                    imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
                end
                `OPCODE_BRANCH: // B-type
                begin
                    imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
                end
                `OPCODE_LUI, `OPCODE_AUIPC: // U-type
                begin 
                    imm = {inst[31:12], 12'b0};
                end
                `OPCODE_JAL: // J-type
                begin      
                    imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
                end
                `OPCODE_CSR: // CSR Instructions
                begin
                    imm = {20'b0, inst[31:20]};
                end
                default: 
                begin
                    imm = 0;
                end
            endcase

            return imm;

        endfunction

        function automatic logic [31:0] gen_zimm_f
        (
            input logic [31:0] instr
        );

            return {27'b0, instr[19:15]};            

        endfunction

    endpackage

`endif
