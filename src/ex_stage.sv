// Execute Stage

module ex_stage
# (
    parameter DATA_WIDTH     = 32,
    parameter NUM_REGISTERS  = 32,
    localparam ADDRESS_WIDTH = $clog2(NUM_REGISTERS)    // TODO: change its name
) (
    input  logic [DATA_WIDTH-1:0]    pc_in,
    input  logic [6:0]               opcode,
    input  logic [ADDRESS_WIDTH-1:0] rs1_in,
    input  logic [ADDRESS_WIDTH-1:0] rs2_in,
    input  logic [DATA_WIDTH-1:0]    imm_in,
    output logic                     br_taken_out,
    output logic [DATA_WIDTH-1:0]    alu_result_out
);

    function alu_op_t ins_op2alu_op
    (
        input ins_op_t ins_op;
    );

        alu_op_t alu_op;

        case (ins_op.opcode)
            I_TYPE:
                case(ins.op.funct3)
                    ADD: alu_op = alu_op_pkg::ADD;
                    SUB: alu_op = alu_op_pkg::SUB;
                    default:
                endcase
            default: 
        endcase        
        
    endfunction



    alu # (
        .DATA_WIDTH ( DATA_WIDTH     )
    ) i_alu (
        .op         ( alu_op         ),
        .opr_a      ( rs1_in         ),
        .opr_b      ( rs2_in         ),
        .opr_result ( alu_result_out )
    );

endmodule: ex_stage