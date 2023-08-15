// Write Back Stage

module wb_stage
    import core_pkg::wb_sel_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  logic [DATA_WIDTH-1:0] alu_result_in,        // alu result
    input  logic [DATA_WIDTH-1:0] dmem_rdata_in,        // read data from data mem
    input  logic [DATA_WIDTH-1:0] pc_plus_4_in,         // pc + 4 for interrupts (store addr of next instruction)
    input  logic [1:0]            wb_sel_in,
    output logic [DATA_WIDTH-1:0] wb_data_out
);

    always_comb
    begin
        case(wb_sel_in)
            wb_sel_t::ALU_RESULT_SEL: wb_data_out = alu_result_in;
            wb_sel_t::DMEM_DATA_SEL : wb_data_out = dmem_rdata_in;
            wb_sel_t::PC_PLUS_4_SEL : wb_data_out = pc_plus_4_in;
            wb_sel_t::STRAY_SEL     : wb_data_out = '0;
            default                 : wb_data_out = '0;
        endcase
    end

endmodule: wb_stage