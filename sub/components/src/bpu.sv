
// branch prediction unit

`include "riscv.svh"
`include "bpu_pkg.svh"

`define RESET_PC 32'h8000_0000

module bpu
    import bpu_pkg::WEAKLY_TAKEN;
    import bpu_pkg::STRONGLY_TAKEN;
    import bpu_pkg::WEAKLY_NOT_TAKEN;
    import bpu_pkg::STRONGLY_NOT_TAKEN;
#(
    parameter DATA_WIDTH = 32,
    parameter BHT_BTB_SIZE = 32
)(
    input  logic                  clk,
    input  logic                  arst_n,
    input  logic [DATA_WIDTH-1:0] pc,            // PC reg operating in fetch stage, for BHT and BTB addressing
    input  logic [DATA_WIDTH-1:0] inst_in,       // instruction input, for pre-decode of branch, jal and jalr
    input  logic                  br_taken,      // actual branch taken signal, prodcued by EXECUTE stage || Active high
    input  logic [DATA_WIDTH-1:0] br_target,     // actual branch target signal, prodcued by EXECUTE stage || contains PC where to go
    output logic                  predict_taken,
    output logic                  is_conditional_branch,
    output logic                  is_jalr,
    output logic                  is_jal,
    output logic [DATA_WIDTH-1:0] pc_reg,
    output logic [DATA_WIDTH-1:0] predict_pc
);

    localparam ADDR_WIDTH = $clog2(BHT_BTB_SIZE);       // number of bits required for the address

    logic [6:0] opcode;
    // logic       is_conditional_branch;    // check whether it's a branch instruction

    logic       is_branch_d;              // for sync with br_taken
    logic       is_branch_dd;             // for sync with br_taken

    assign opcode                = inst_in[6:0];
    assign is_conditional_branch = (opcode == `OPCODE_BRANCH);
    assign is_jal                = (opcode == `OPCODE_JAL);
    assign is_jalr               = (opcode == `OPCODE_JALR);

    logic                  bht_btb_valid     [0:BHT_BTB_SIZE-1];  // 1 bit valid
    logic            [1:0] bht_btb_state     [0:BHT_BTB_SIZE-1];  // 2 bits for states
    logic [DATA_WIDTH-1:0] bht_btb_target_pc [0:BHT_BTB_SIZE-1];  // 32 bits for predicted PC
    
    logic                  bht_btb_valid_data;                          // for read and write in BHT, BTB valid
    logic            [1:0] bht_btb_state_data;                          // for read and write in BHT, BTB state
    logic [DATA_WIDTH-1:0] bht_btb_target_pc_data;                      // for read and write in BHT, BTB target pc

    logic [ADDR_WIDTH-1:0] bht_btb_addr;

    assign bht_btb_addr           = pc[ADDR_WIDTH+1:2];
    assign bht_btb_valid_data     = bht_btb_valid[bht_btb_addr];
    assign bht_btb_state_data     = bht_btb_state[bht_btb_addr];
    assign bht_btb_target_pc_data = bht_btb_target_pc[bht_btb_addr];

    logic [DATA_WIDTH-1:0] pc8;
    logic [ADDR_WIDTH-1:0] pc8_addr;

    assign pc8 = pc + 32'd8;
    assign pc8_addr = pc8[ADDR_WIDTH+1:2];

    logic [DATA_WIDTH-1:0] jal_imm, jalr_imm;

    // creating sync signals
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            is_branch_d  <= 1'b0;
            is_branch_dd <= 1'b0;
        end
        else
        begin
            is_branch_d  <= is_conditional_branch;
            is_branch_dd <= is_branch_d;
        end
    end

    // update BHT and BTB
    always_ff @ (negedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            for (int i=0; i<BHT_BTB_SIZE; i++)     bht_btb_valid[i] <= 1'b0;
            for (int i=0; i<BHT_BTB_SIZE; i++)     bht_btb_state[i] <= WEAKLY_NOT_TAKEN;
        end
        else if (is_branch_dd)
        begin
            case({bht_btb_state_data, br_taken})
                {WEAKLY_TAKEN, 1'b1}: bht_btb_state[bht_btb_addr] <= STRONGLY_TAKEN;
                {WEAKLY_TAKEN, 1'b0}: bht_btb_state[bht_btb_addr] <= WEAKLY_NOT_TAKEN;

                {STRONGLY_TAKEN, 1'b1}: bht_btb_state[bht_btb_addr] <= STRONGLY_TAKEN;
                {STRONGLY_TAKEN, 1'b0}: bht_btb_state[bht_btb_addr] <= WEAKLY_TAKEN;
                
                {WEAKLY_NOT_TAKEN, 1'b1}: bht_btb_state[bht_btb_addr] <= WEAKLY_TAKEN;
                {WEAKLY_NOT_TAKEN, 1'b0}: bht_btb_state[bht_btb_addr] <= STRONGLY_NOT_TAKEN;
                
                {STRONGLY_NOT_TAKEN, 1'b1}: bht_btb_state[bht_btb_addr] <= WEAKLY_NOT_TAKEN;
                {STRONGLY_NOT_TAKEN, 1'b0}: bht_btb_state[bht_btb_addr] <= STRONGLY_NOT_TAKEN;
            endcase
            // predict_pc <= bht_btb_target_pc_data;
        end
    end

    always_ff @ (negedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            for (int i=0; i<BHT_BTB_SIZE; i++) bht_btb_target_pc[i] <= `RESET_PC;
        end
        else if (is_branch_dd && br_taken)
        begin
            bht_btb_target_pc[bht_btb_addr] <= br_target;
        end
    end

    assign jal_imm = {{11{inst_in[31]}}, inst_in[31], inst_in[19:12], inst_in[20], inst_in[30:21], 1'b0};
    assign jalr_imm = {{20{inst_in[31]}}, inst_in[31:20]};

    always_comb
    begin
        if (is_jal)
        begin
            predict_taken = is_branch_d ? 1'b0 : 1'b1;   // because conditional branch has not been resolved yet
            predict_pc    = pc + jal_imm;
        end
        // else if (is_jalr)
        // begin
        //     predict_taken = is_branch_d ? 1'b0 : 1'b1;   // because conditional branch has not been resolved yet
        //     predict_pc    = pc + jalr_imm;
        // end
        else if (is_conditional_branch)
        begin
            predict_taken = (bht_btb_state[pc8_addr] == WEAKLY_TAKEN) | (bht_btb_state[pc8_addr] == STRONGLY_TAKEN);
            predict_pc    = bht_btb_target_pc[pc8_addr];
        end
        else
        begin
            predict_taken = 1'b0;
            predict_pc    = `RESET_PC;
        end
    end

    // register pc for using in PC selection process in case of conditional branches
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n) pc_reg <= `RESET_PC;
        else if (is_conditional_branch) pc_reg <= pc;
    end
endmodule: bpu