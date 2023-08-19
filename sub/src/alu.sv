// Arithmetic Logic Unit

`include "alu_pkg.svh"

module alu
    import alu_pkg::aluop_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  aluop_t                      op,
    input  logic signed [DATA_WIDTH-1:0] opr_a,
    input  logic signed [DATA_WIDTH-1:0] opr_b,
    output logic signed [DATA_WIDTH-1:0] opr_result
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
