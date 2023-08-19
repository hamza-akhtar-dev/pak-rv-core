// Control Unit

`include "riscv.svh"

module ctrl_unit #(
    parameter DATA_WIDTH = 32
)(
    input  logic       clk,
    input  logic       arst_n,
    input  logic [6:0] opcode,
    output logic       wb_en,
    output logic       dmem_en,
    output logic [1:0] wb_sel
);

    always_comb
    begin
        case(opcode)
            `OPCODE_ITYPE: 
            begin
                wb_en   = 1'b1;
                dmem_en = 1'b0;
                wb_sel  = 2'b00;
            end
            default:
            begin
                wb_en   = 1'b0;
                dmem_en = 1'b0;
                wb_sel  = 2'b00;
            end
        endcase
    end

endmodule: ctrl_unit
