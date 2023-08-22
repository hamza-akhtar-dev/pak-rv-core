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

    localparam MASK_SIZE = DATA_WIDTH/8;

    logic [DATA_WIDTH-1:0] dmem_addr_in;
    logic [DATA_WIDTH-1:0] dmem_data_in;
    logic [MASK_SIZE-1:0]  mask;

    dmem # (
        .DATA_WIDTH    (DATA_WIDTH                ),
        .DMEM_SZ_IN_KB (DMEM_SZ_IN_KB             )
    )  i_dmem (
        .clk           (clk                       ),
        .arst_n        (arst_n                    ),
        .write_en      (mem_stage_in.dm_en        ),
        .mask          (mask                      ),
        .addr          (dmem_addr_in              ),  // TODO: make this parameterizable
        .data_in       (dmem_data_in              ),
        .data_out      (mem_stage_out.dmem_rdata  )
    );

    // ports description can be found in Pak-RV-Core/sub/src/lsu.sv
    lsu # (
        .DATA_WIDTH (DATA_WIDTH              )
    ) i_lsu (
        .lsuop      (mem_stage_in.lsuop      ),

        .addr_in    (mem_stage_in.opr_res    ),
        .addr_out   (dmem_addr_in            ),

        .data_s_in  (mem_stage_in.opr_b      ),
        .data_s_out (dmem_data_in            ),

        .data_l_in  (mem_stage_out.dmem_rdata),
        .data_l_out (mem_stage_out.lsu_rdata ),

        .mask       (mask                    )
    );

    assign mem_stage_out.opr_res = mem_stage_in.opr_res;
    assign mem_stage_out.rd      = mem_stage_in.rd;
    assign mem_stage_out.rf_en   = mem_stage_in.rf_en;
    assign mem_stage_out.wb_sel  = mem_stage_in.wb_sel;

endmodule: mem_stage
