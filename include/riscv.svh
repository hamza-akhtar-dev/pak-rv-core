`ifndef RISCV_SVH

`define RISCV_SVH

    `define OPCODE_OP     7'b0110011
    `define OPCODE_OPIMM  7'b0010011
    `define OPCODE_LOAD   7'b0000011
    `define OPCODE_STORE  7'b0100011
    `define OPCODE_BRANCH 7'b1100011
    `define OPCODE_JALR   7'b1100111
    `define OPCODE_JAL    7'b1101111
    `define OPCODE_LUI    7'b0110111
    `define OPCODE_AUIPC  7'b0010111

    `define FUNCT3_ADD_SUB 3'b000
    `define FUNCT3_SLL     3'b001
    `define FUNCT3_SLT     3'b010
    `define FUNCT3_SLTU    3'b011
    `define FUNCT3_XOR     3'b100
    `define FUNCT3_SRL_SRA 3'b101
    `define FUNCT3_OR      3'b110
    `define FUNCT3_AND     3'b111

    `define FUNCT7_VAR1 7'b0000000
    `define FUNCT7_VAR2 7'b0100000

`endif
