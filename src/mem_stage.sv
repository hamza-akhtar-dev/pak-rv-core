// Memory Stage

`include "mem_stage_pkg.svh"

module mem_stage 
    import mem_stage_pkg::mem_stage_in_t;
    import mem_stage_pkg::mem_stage_out_t;
# (
    parameter DATA_WIDTH       = 32,
    parameter NUM_CS_REGISTERS = `NUM_CS_REGISTERS
) (
    input  logic                    clk,
    input  logic                    arst_n,
    input  logic [DATA_WIDTH-1:0]   mem_data_in,
    input  mem_stage_in_t           mem_stage_in,
    output mem_stage_out_t          mem_stage_out
);

    lsu # (
        .DATA_WIDTH ( DATA_WIDTH                         )
    ) i_lsu (
        .lsuop      ( mem_stage_in.lsuop                 ),
        .addr_in    ( mem_stage_in.opr_res               ),
        .addr_out   ( mem_stage_out.core_out_mem_addr_in ),
        .data_s_in  ( mem_stage_in.opr_b                 ),
        .data_s_out ( mem_stage_out.core_out_mem_data_in ),
        .data_l_in  ( mem_data_in                        ),
        .data_l_out ( mem_stage_out.lsu_rdata            ),
        .mask       ( mem_stage_out.mask                 )
    );

    csr # (
        .DATA_WIDTH    ( DATA_WIDTH              ),
        .NUM_REGISTERS ( NUM_CS_REGISTERS        )
    ) i_csr (
        .clk           ( clk                     ),
        .arst_n        ( arst_n                  ),

        .csrop         ( mem_stage_in.csrop      ),
        .rs1_data      ( mem_stage_in.opr_a      ),
        .zimm          ( mem_stage_in.zimm       ),

        .addr_in       ( mem_stage_in.imm[11:0]  ),
        .wr_en_in      ( mem_stage_in.csr_wr_en  ),
        .rd_data_out   ( mem_stage_out.csr_rdata )
    );

    assign mem_stage_out.opr_res   = mem_stage_in.opr_res;
    assign mem_stage_out.rd        = mem_stage_in.rd;
    assign mem_stage_out.pc4       = mem_stage_in.pc4;
    assign mem_stage_out.rf_en     = mem_stage_in.rf_en;
    assign mem_stage_out.wb_sel    = mem_stage_in.wb_sel;

endmodule: mem_stage
