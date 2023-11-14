// Write Back Stage

`include "wb_stage_pkg.svh"

module wb_stage 
    import wb_stage_pkg::wb_stage_in_t;
    import wb_stage_pkg::wb_stage_out_t;
(
    input  wb_stage_in_t  wb_stage_in,
    output wb_stage_out_t wb_stage_out
);

    always_comb
    begin
        case(wb_stage_in.wb_sel)
            2'b00:   wb_stage_out.wb_data = wb_stage_in.opr_res;
            2'b01:   wb_stage_out.wb_data = wb_stage_in.lsu_rdata;
            2'b10:   wb_stage_out.wb_data = wb_stage_in.pc4;
            2'b11:   wb_stage_out.wb_data = wb_stage_in.csr_rdata;
            default: wb_stage_out.wb_data = 0;
        endcase
    end

    assign wb_stage_out.rd = wb_stage_in.rd;
    assign wb_stage_out.rf_en = wb_stage_in.rf_en;

endmodule: wb_stage
