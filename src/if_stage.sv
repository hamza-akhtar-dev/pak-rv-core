// Instruction Fetch Stage

`include "if_stage_pkg.svh"

module if_stage 
    import if_stage_pkg::if_stage_out_t;
    import if_stage_pkg::if_stage_in_t;
# (
    parameter  DATA_WIDTH    = 32,
    parameter  IMEM_SZ_IN_KB = 1,
    localparam PC_SIZE       = 32
) (
    input  logic          clk,
    input  logic          arst_n,
    input  if_stage_in_t  if_stage_in,
    output if_stage_out_t if_stage_out,
    output logic [DATA_WIDTH-1:0] pc_out,
    output logic [DATA_WIDTH-1:0] pc4
);

    logic [   PC_SIZE-1:0] pc_in;    
    assign pc4   = pc_out + 'd4;
    assign pc_in = if_stage_in.br_taken ? if_stage_in.br_target : pc4;

    pc # (
        .PC_SIZE(PC_SIZE)
    ) i_pc (
        .clk    (clk               ),
        .arst_n (arst_n            ),
        .en_in  (~if_stage_in.stall),
        .pc_in  (pc_in             ),
        .pc_out (pc_out            )
    );
    
endmodule
