
module if_stage # (
    parameter DW            = 32,
    parameter IMEM_SZ_IN_KB = 1,
    localparam PC_SIZE      = $clog2(IMEM_SZ_IN_KB*1024*8)
)(
    input  logic               clk,
    input  logic               arst_n,
    input  logic [PC_SIZE-1:0] pc,
    output logic [DW-1:0]      instruction
);

    logic [DW-1:0] instruction_memory [IMEM_SZ_IN_KB*1024*8/4]; // Example instruction memory, /4 to get num of words

    initial
    begin
        $readmemh("../verif/gen_machine_codes/build/machine_code.mem", instruction_memory);
    end

    always_ff @(posedge clk or negedge arst_n)
    begin
        if (~arst_n)
        begin
            instruction <= '0;
        end
        else
        begin
            instruction <= instruction_memory[pc[PC_SIZE-1:2]];
        end
    end

endmodule
