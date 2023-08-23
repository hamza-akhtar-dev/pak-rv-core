// Memory Stage

`include "mem_stage_pkg.svh"

module mem_stage 
    import mem_stage_pkg::mem_stage_in_t;
    import mem_stage_pkg::mem_stage_out_t;
# (
    parameter DATA_WIDTH    = 32,
    parameter DMEM_SZ_IN_KB = 1
) (
    input logic            clk,
    input logic            arst_n,
    input  mem_stage_in_t  mem_stage_in,
    output mem_stage_out_t mem_stage_out
);
    dmem # (
        .DATA_WIDTH    (DATA_WIDTH                ),
        .DMEM_SZ_IN_KB (DMEM_SZ_IN_KB             )
    )  i_dmem (
        .clk           (clk                       ),
        .arst_n        (arst_n                    ),
        .write_en      (mem_stage_in.dm_en        ),
        .addr          (mem_stage_in.opr_res[9:0] ),  // TODO: make this parameterizable
        .data_in       (mem_stage_in.opr_b        ),
        .data_out      (mem_stage_out.dmem_rdata  )
    );

    assign mem_stage_out.opr_res = mem_stage_in.opr_res;
    assign mem_stage_out.rd      = mem_stage_in.rd;
    assign mem_stage_out.pc4     = mem_stage_in.pc4;
    assign mem_stage_out.rf_en   = mem_stage_in.rf_en;
    assign mem_stage_out.wb_sel  = mem_stage_in.wb_sel;

endmodule: mem_stage
