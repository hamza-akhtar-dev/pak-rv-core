
// Control Unit for the processor

module ctrl_unit #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  arst_n,
    input  logic [DATA_WIDTH-1:0] instruction,
    output logic                  rf_wr,
    output logic                  mem_wr,
    output logic [2:0]            imm_src
);

    enum logic [6:0] {
        LOAD     = 7'b0000011,
        STORE    = 7'b0100011,
        BRANCH   = 7'b1100011,
        JAL      = 7'b1101111,
        JALR     = 7'b1100111,
        R_TYPE   = 7'b0110011,
        I_TYPE   = 7'b0010011,
        U_1_TYPE = 7'b0110111,
        U_2_TYPE = 7'b0010111
    } instr_type_t;

    logic [6:0] opcode;
    assign opcode = instruction[6:0];

    always_comb
    begin
        case(opcode)
            I_TYPE: begin
                rf_wr   = 1'b1;
                mem_wr  = 1'b0;
                imm_src = 3'b000;
            end
            STORE: begin
                rf_wr   = 1'b0;
                mem_wr  = 1'b1;
                imm_src = 3'b001;
            end
            BRANCH: begin
                rf_wr   = 1'b0;
                mem_wr  = 1'b0;
                imm_src = 3'b010;
            end
            LOAD: begin
                rf_wr   = 1'b1;
                mem_wr  = 1'b0;
                imm_src = 3'b000;
            end
            R_TYPE: begin
                rf_wr   = 1'b1;
                mem_wr  = 1'b0;
                imm_src = 3'b000;
            end
            JAL: begin
                rf_wr   = 1'b0;
                mem_wr  = 1'b0;
                imm_src = 3'b011;
            end
            JALR: begin
                rf_wr   = 1'b0;
                mem_wr  = 1'b0;
                imm_src = 3'b011;
            end
            U_1_TYPE, U_2_TYPE: begin
                rf_wr   = 1'b1;
                mem_wr  = 1'b0;
                imm_src = 3'b100;
            end
            default: begin
                rf_wr   = 1'b0;
                mem_wr  = 1'b0;
                imm_src = 3'b000;
            end
        endcase
    end

endmodule: ctrl_unit