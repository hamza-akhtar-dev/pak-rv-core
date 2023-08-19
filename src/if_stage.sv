// Instruction Fetch Stage

`include "if_stage_pkg.svh"

module if_stage 
    import if_stage_pkg::if_stage_out_t;
# (
    parameter  DATA_WIDTH    = 32,
    parameter  IMEM_SZ_IN_KB = 1,
    localparam PC_SIZE       = $clog2(IMEM_SZ_IN_KB*1024*8)
) (
    input  logic          clk,
    input  logic          arst_n,
    output if_stage_out_t if_stage_out
);

    logic [DATA_WIDTH-1:0] instruction_memory [IMEM_SZ_IN_KB*1024*8/4]; // Example instruction memory, /4 to get num of words

    logic [PC_SIZE-1:0] pc_in;
    logic [PC_SIZE-1:0] pc_out;

    initial
    begin
        $readmemh("../verif/gen_machine_codes/build/machine_code.mem", instruction_memory);
    end

    pc # (
        .PC_SIZE(PC_SIZE)
    ) i_pc (
        .clk   (clk   ),
        .arst_n(arst_n),
        .pc_in (pc_in ),
        .pc_out(pc_out)
    );

    assign pc_in = pc_out + 'd4;

    // asychronous instruction read
    assign if_stage_out.inst = instruction_memory[pc_out[PC_SIZE-1:2]];

endmodule
