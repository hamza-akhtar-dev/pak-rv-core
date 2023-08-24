// Control Flow Unit

`include "cfu_pkg.svh"

module cfu
    import cfu_pkg::cfuop_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  cfuop_t                       cfuop,
    input  logic signed [DATA_WIDTH-1:0] opr_a,
    input  logic signed [DATA_WIDTH-1:0] opr_b,
    output logic                         br_taken
);
   
    always_comb 
    begin
        case (cfuop)
            cfu_pkg::BEQ:  br_taken = (opr_a == opr_b) ? 1 : 0;
            cfu_pkg::BNE:  br_taken = (opr_a != opr_b) ? 1 : 0;
            cfu_pkg::BLT:  br_taken = (opr_a <  opr_b) ? 1 : 0;
            cfu_pkg::BGE:  br_taken = (opr_a >= opr_b) ? 1 : 0;
            cfu_pkg::BLTU: br_taken = (opr_a <  opr_b) ? 1 : 0;
            cfu_pkg::BGEU: br_taken = (opr_a >= opr_b) ? 1 : 0;
            cfu_pkg::JAL:  br_taken = 1;
            cfu_pkg::JALR: br_taken = 1;
            cfu_pkg::NB:   br_taken = 0;
            default:       br_taken = 0;
        endcase
    end

endmodule
