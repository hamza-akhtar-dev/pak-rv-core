// Instruction Fetch Stage

`include "if_stage_pkg.svh"

module if_stage 
    import if_stage_pkg::if_stage_out_t;
    import if_stage_pkg::if_stage_in_t;
# (
    parameter  DATA_WIDTH                = 32,
    parameter  IMEM_SZ_IN_KB             = 1,
    parameter  SUPPORT_BRANCH_PREDICTION = 1,
    localparam PC_SIZE                   = 32
) (
    input  logic                  clk,
    input  logic                  arst_n,
    input  if_stage_in_t          if_stage_in,
    output if_stage_out_t         if_stage_out
);

    logic                  is_conditional_branch;
    logic [   PC_SIZE-1:0] pc_out;  
    logic [   PC_SIZE-1:0] pc4;  
    logic                  is_jalr;
    logic                  is_jal;
    logic                  predict_taken;
    logic [DATA_WIDTH-1:0] predict_pc;

    logic [   PC_SIZE-1:0] pc_in;  
    logic [DATA_WIDTH-1:0] pc_coditional_branch;
    logic                  is_jalr_d, is_jalr_dd;

    assign pc4   = pc_out + 'd4;

    generate
        if (SUPPORT_BRANCH_PREDICTION == 1)
        begin: syncing_signals_for_bpu

            logic predict_taken_d, predict_taken_dd;
            logic is_conditional_branch_d, is_conditional_branch_dd;

            always_ff @ (posedge clk, negedge arst_n)
            begin
                if (~arst_n | if_stage_in.misprediction)
                begin
                    predict_taken_d <= 1'b0;
                    predict_taken_dd <= 1'b0;            
                end
                else if (~if_stage_in.stall)
                begin
                    predict_taken_d <= predict_taken;
                    predict_taken_dd <= predict_taken_d;
                end
            end


            always_ff @ (posedge clk, negedge arst_n)
            begin
                if (~arst_n | if_stage_in.misprediction)
                begin
                    is_conditional_branch_d  <= 1'b0;
                    is_conditional_branch_dd <= 1'b0;
                    is_jalr_d                <= 1'b0;
                    is_jalr_dd               <= 1'b0;
                end
                else if (~if_stage_in.stall)
                begin
                    is_conditional_branch_d  <= is_conditional_branch;
                    is_conditional_branch_dd <= is_conditional_branch_d;
                    is_jalr_d                <= is_jalr;
                    is_jalr_dd               <= is_jalr_d;
                end
            end

            always_comb
            begin
                if (is_conditional_branch_dd | is_jalr_dd)
                begin
                    if      ( if_stage_in.br_taken)                                        pc_in = if_stage_in.br_target;
                    else if (!if_stage_in.br_taken &&  predict_taken_dd)                   pc_in = pc_coditional_branch + 32'd4;
                    else if (!if_stage_in.br_taken && !predict_taken_dd && !predict_taken) pc_in = pc4; // ~ predict taken handles hazards of conditional branch followed by conditional or unconditional branches
                    else                                                                   pc_in = predict_pc;
                end
                else if (predict_taken)
                begin
                    pc_in = predict_pc;
                end
                else if (is_jalr_dd)
                begin
                    pc_in = if_stage_in.br_target;
                end
                else
                begin
                    pc_in = pc4;
                end
            end
        end

        else
        begin
            assign pc_in = if_stage_in.br_taken ? if_stage_in.br_target : pc4;
        end
    endgenerate

    pc # (
        .PC_SIZE(PC_SIZE)
    ) i_pc (
        .clk    (clk               ),
        .arst_n (arst_n            ),
        .en_in  (~if_stage_in.stall),
        .pc_in  (pc_in             ),
        .pc_out (pc_out            )
    );

    generate
        if (SUPPORT_BRANCH_PREDICTION == 1)
        begin: BPU
            bpu #(
                .DATA_WIDTH            ( DATA_WIDTH                   ),
                .BHT_BTB_SIZE          ( 32                           )
            ) i_bpu (
                .clk                   ( clk                          ),
                .arst_n                ( arst_n                       ),
                .pc                    ( pc_out                       ),
                .inst_in               ( if_stage_in.instruction      ),
                .br_taken              ( if_stage_in.br_taken         ),
                .br_target             ( if_stage_in.br_target        ),
                .predict_taken         ( predict_taken                ),
                .is_conditional_branch ( is_conditional_branch        ),
                .is_jalr               ( is_jalr                      ),
                .is_jal                ( is_jal                       ),
                .pc_reg                ( pc_coditional_branch         ),
                .predict_pc            ( predict_pc                   )
            );
        end
    endgenerate

    // driving signals for next stage
    assign if_stage_out.inst                  = if_stage_in.instruction;
    assign if_stage_out.pc                    = pc_out;
    assign if_stage_out.pc4                   = pc4;
    assign if_stage_out.is_conditional_branch = is_conditional_branch;
    assign if_stage_out.is_jalr               = is_jalr;
    assign if_stage_out.is_jal                = is_jal;
    assign if_stage_out.predict_taken         = predict_taken;
    assign if_stage_out.predict_pc            = predict_pc;

endmodule
