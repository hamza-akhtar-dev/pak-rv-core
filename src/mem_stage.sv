// Memory Stage

`include "mem_stage_pkg.svh"
`include "amo_pkg.svh"

module mem_stage 
    import mem_stage_pkg::mem_stage_in_t;
    import mem_stage_pkg::mem_stage_out_t;
    import amo_pkg      ::amo_mem_s;
# (
    parameter DATA_WIDTH    = 32,
    parameter DMEM_SZ_IN_KB = 1,
    parameter NUM_CS_REGISTERS = `NUM_CS_REGISTERS,
    localparam MASK_SIZE    = DATA_WIDTH/8
) (
    input  logic                    clk,
    input  logic                    arst_n,
    output logic                    stall_req,
    input  logic [DATA_WIDTH-1:0]   mem_data_in,
    input  logic                    mem_resp_in,
    input  mem_stage_in_t           mem_stage_in,
    output mem_stage_out_t          mem_stage_out,
    output amo_mem_s                amo_to_mem_if
);

    logic [DATA_WIDTH-1:0] dmem_addr_in;
    logic [DATA_WIDTH-1:0] dmem_data_in;
    logic [DATA_WIDTH-1:0] dmem_rdata;

    logic [DATA_WIDTH-1:0]   lsu_data_out;
    logic [DATA_WIDTH/8-1:0] lsu_mem_mask;

    logic [DATA_WIDTH-1:0]   mem_addr;
    logic [DATA_WIDTH-1:0]   amo_mem_addr;
    logic [DATA_WIDTH-1:0]   amo_mem_data;
    logic [DATA_WIDTH/8-1:0] amo_mem_mask;
    logic [DATA_WIDTH-1:0]   amo_rd_data_out;
    logic [DATA_WIDTH-1:0]   core_out_mem_data_in;
    logic                    amo_mem_wr_req;

    amo_mem_s                amo_to_rf_if;

    dmem # (
        .DATA_WIDTH    (DATA_WIDTH        ),
        .DMEM_SZ_IN_KB (DMEM_SZ_IN_KB     )
    )  i_dmem (
        .clk           (clk               ),
        .arst_n        (arst_n            ),
        .write_en      (mem_stage_in.dm_wr_en),
        .mask          (lsu_mem_mask      ),
        .addr          (dmem_addr_in      ),  // TODO: make this parameterizable
        .data_in       (dmem_data_in      ),
        .data_out      (dmem_rdata        )
    );

    assign mem_stage_out.core_out_mem_addr_in = amo_busy ? amo_mem_addr : mem_addr;
    assign mem_stage_out.core_out_mem_data_in = amo_mem_wr_req ? amo_mem_data : core_out_mem_data_in;

    lsu # (
        .DATA_WIDTH (DATA_WIDTH                        )
    ) i_lsu (
        .lsuop      (mem_stage_in.lsuop                ),
        .addr_in    (mem_stage_in.opr_res              ),
        .addr_out   (mem_addr                          ),
        .data_s_in  (mem_stage_in.opr_b                ),
        .data_s_out (core_out_mem_data_in              ),
        .data_l_in  (mem_data_in                       ),
        .data_l_out (mem_stage_out.lsu_rdata           ),
        .mask       (lsu_mem_mask                      )
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

    logic [DATA_WIDTH-1:0] rs1_data;
    logic [DATA_WIDTH-1:0] rs2_data;

    assign rs1_data = mem_data_in;
    assign rs2_data = mem_stage_in.opr_b;

    logic is_amo;
    logic amo_busy;
    logic amo_rf_wr_req;

    amo #(
        .DATA_WIDTH   ( DATA_WIDTH             )
    ) i_amo (
        .clk          ( clk                    ),
        .arst_n       ( arst_n                 ),
        .amoop        ( mem_stage_in.amoop     ),
        .is_amo       ( mem_stage_in.is_amo    ),
        .amo_busy     ( amo_busy               ),
        .amo_to_mem_if( amo_to_mem_if          ),
        .amo_to_rf_if ( amo_to_rf_if           ),
        .is_data_loaded( mem_resp_in           ),
        .rs1_addr     ( mem_stage_in.opr_a     ),
        .rs1_data     ( mem_data_in            ),  // rs1
        .rs2_data     ( mem_stage_in.opr_b     )   // rs2
    );

    assign mem_stage_out.amo_busy  = amo_busy;
    assign mem_stage_out.mask      = amo_busy           ? amo_mem_mask       : lsu_mem_mask;
    assign mem_stage_out.opr_res   = amo_to_rf_if.wr_en ? amo_to_rf_if.data  : mem_stage_in.opr_res;
    assign mem_stage_out.rd        = mem_stage_in.rd;
    assign mem_stage_out.pc4       = mem_stage_in.pc4;
    assign mem_stage_out.rf_en     = mem_stage_in.rf_en | amo_to_rf_if.wr_en;
    assign mem_stage_out.wb_sel    = mem_stage_in.wb_sel;

    assign stall_req               = amo_busy;

endmodule: mem_stage
