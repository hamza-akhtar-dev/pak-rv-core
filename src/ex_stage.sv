module
    import alu_pkg::alu_op_t;
(
    input  alu_op_t     op;
    input  logic signed [31:0] opr_a,
    input  logic signed [31:0] opr_b,
    output logic signed [31:0] opr_result,
);

    always_comb
    begin
        case(op):
            ADD:  opr_result = opr_a + opr_b;
            SUB:  opr_result = opr_a - opr_b;
            AND:  opr_result = opr_a & opr_b;
            OR:   opr_result = opr_a | opr_b;
            XOR:  opr_result = opr_a ^ opr_b;
            SLL:  opr_result = opr_a << opr_b;
            SRL:  opr_result = opr_a >> opr_b;
            SRA:  opr_result = opr_a >>> opr_b;
            SLT:  opr_result = (opr_a < opr_b) ? 1 : 0;
            SLTU: opr_result = ($unsigned(opr_a) < $unsigned(opr_b)) ? 1 : 0;
            default: opr_result = 0;
        endcase
    end

endmodule