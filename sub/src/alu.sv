// Arithmetic Logic Unit

module alu
    import alu_pkg::alu_op_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  alu_op_t               op,
    input  logic [DATA_WIDTH-1:0] opr_a,
    input  logic [DATA_WIDTH-1:0] opr_b,
    output logic [DATA_WIDTH-1:0] opr_result
);
    always_comb
    begin
        case(op)
            alu_pkg::ADD:  opr_result = opr_a + opr_b;
            alu_pkg::SUB:  opr_result = opr_a - opr_b;
            default: opr_result = 0;
        endcase
    end

endmodule
