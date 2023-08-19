// Write Back Stage

module wb_stage 
(
    input  wb_stage_in_t  wb_stage_in,
    output wb_stage_out_t wb_stage_out
);

    always_comb
    begin
        case(wb_stage_in.wb_sel)
            1'b0: wb_stage_out.wb_data = wb_stage_in.opr_res;
            1'b1: wb_stage_out.wb_data = wb_stage_in.dmem_rdata;
        endcase
    end

endmodule: wb_stage
