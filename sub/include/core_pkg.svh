`ifndef CORE_PKG_SVH

`define CORE_PKG_SVH

    package core_pkg;

        typedef enum logic [6:0] {
            LOAD     = 7'b0000011,
            STORE    = 7'b0100011,
            BRANCH   = 7'b1100011,
            JAL      = 7'b1101111,
            JALR     = 7'b1100111,
            R_TYPE   = 7'b0110011,
            I_TYPE   = 7'b0010011,
            U_1_TYPE = 7'b0110111,
            U_2_TYPE = 7'b0010111
        } opcode_t;

        typedef enum logic [2:0] {
            LB  = 3'b000,
            LBU = 3'b100,
            LH  = 3'b001,
            LHU = 3'b101,
            LW  = 3'b010
        } load_funct3_t;

        typedef enum logic [2:0] {
            SB = 3'b000,
            SH = 3'b001,
            SW = 3'b010
        } store_funct3_t;

        typedef enum logic [1:0] { 
            ALU_RESULT_SEL,
            DMEM_DATA_SEL,
            PC_PLUS_4_SEL,
            STRAY_SEL
        } wb_sel_t;

    endpackage

`endif