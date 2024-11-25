`ifndef LSU_PKG_SVH

`define LSU_PKG_SVH

    `include "riscv.svh"

    package lsu_pkg;

        typedef enum logic[4:0] 
        {
            LB,
            LH,
            LW,
            LBU,
            LHU,
            SB,
            SH,
            SW
        } lsuop_t;

        function automatic lsuop_t gen_lsuop_f 
        (
            input logic [6:0] opcode,
            input logic [2:0] funct3
        );

            if (opcode == `OPCODE_LOAD)
            begin
                case(funct3)
                    `FUNCT3_LB : gen_lsuop_f = LB;
                    `FUNCT3_LH : gen_lsuop_f = LH;
                    `FUNCT3_LW : gen_lsuop_f = LW;
                    `FUNCT3_LBU: gen_lsuop_f = LBU;
                    `FUNCT3_LHU: gen_lsuop_f = LHU;
                    default    : gen_lsuop_f = LB;
                endcase
            end
            else if (opcode == `OPCODE_STORE)
            begin
                case(funct3)
                    `FUNCT3_SB: gen_lsuop_f = SB;
                    `FUNCT3_SH: gen_lsuop_f = SH;
                    `FUNCT3_SW: gen_lsuop_f = SW;
                    default   : gen_lsuop_f = SB;
                endcase
            end
            else
            begin
                gen_lsuop_f = LB;
            end

        endfunction

        typedef struct packed {
            logic        write_en;
            logic        read_en;
            lsuop_t      lsuop;
            logic [31:0] addr;
            logic [31:0] data;      // valid in case of store operation
        } core_to_lsu_s;

        typedef struct packed {
            logic [31:0] addr;
            logic [31:0] data;
            logic        write_en;
        } lsu_to_core_s;

        typedef struct packed {
            logic        w_success;   // data write success
            logic        r_success;   // data read success
            logic [31:0] data;
        } mem_to_lsu_s;

        typedef struct packed {
            logic        write_en;
            logic        read_en;
            logic [31:0] addr;
            logic [31:0] data;
            logic [ 3:0] strb;
        } lsu_to_mem_s;

    endpackage

`endif
