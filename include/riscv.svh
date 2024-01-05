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
    `define OPCODE_CSR    7'b1110011
    `define OPCODE_AMO    7'b0101111

    `define FUNCT3_ADD_SUB 3'b000
    `define FUNCT3_SLL     3'b001
    `define FUNCT3_SLT     3'b010
    `define FUNCT3_SLTU    3'b011
    `define FUNCT3_XOR     3'b100
    `define FUNCT3_SRL_SRA 3'b101
    `define FUNCT3_OR      3'b110
    `define FUNCT3_AND     3'b111

    `define FUNCT3_LB   3'b000
    `define FUNCT3_LH   3'b001
    `define FUNCT3_LW   3'b010
    `define FUNCT3_LBU  3'b100
    `define FUNCT3_LHU  3'b101
    `define FUNCT3_SB   3'b000
    `define FUNCT3_SH   3'b001
    `define FUNCT3_SW   3'b010
    
    `define FUNCT3_BEQ  3'b000
    `define FUNCT3_BNE  3'b001
    `define FUNCT3_BLT  3'b100
    `define FUNCT3_BGE  3'b101
    `define FUNCT3_BLTU 3'b110
    `define FUNCT3_BGEU 3'b111

    `define FUNCT3_CSRRW  3'b001
    `define FUNCT3_CSRRS  3'b010
    `define FUNCT3_CSRRC  3'b011
    `define FUNCT3_CSRRWI 3'b101
    `define FUNCT3_CSRRSI 3'b110
    `define FUNCT3_CSRRCI 3'b111

    `define FUNCT5_AMOADD_W  5'b00000
    `define FUNCT5_AMOSWAP_W 5'b00001
    `define FUNCT5_AMOXOR_W  5'b00010
    `define FUNCT5_AMOAND_W  5'b01100
    `define FUNCT5_AMOOR_W   5'b01010
    `define FUNCT5_AMOMIN_W  5'b10000
    `define FUNCT5_AMOMAX_W  5'b10100
    `define FUNCT5_AMOMINU_W 5'b11000
    `define FUNCT5_AMOMAXU_W 5'b11100

    `define FUNCT7_VAR1 7'b0000000
    `define FUNCT7_VAR2 7'b0100000

`endif
