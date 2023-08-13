// Instruction Decode Stage

module id_stage 
# (
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  arst_n,
    input  logic [DATA_WIDTH-1:0] instruction,
    output logic [           6:0] opcode,
    output logic [           4:0] rd,
    output logic [           4:0] rs1,
    output logic [           4:0] rs2,
    output logic [           6:0] funct7,
    output logic [           2:0] funct3,
    output logic                  imm_sign_ext,
    output logic [          31:0] imm
);

    assign opcode       = instruction[ 6: 0];
    assign rd           = instruction[11: 7];
    assign rs1          = instruction[19:15];
    assign rs2          = instruction[24:20];
    assign funct7       = instruction[31:25];
    assign funct3       = instruction[14:12];
    assign imm_sign_ext = instruction[   31];
    assign imm          = { {20{imm_sign_ext}}, instruction[31:20] };
    
endmodule
