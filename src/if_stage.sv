module if_stage
(
    input  logic        clk,
    input  logic        arst_n,
    input  logic [31:0] pc,
    output logic [31:0] instruction
);
    logic [31:0] instruction_memory [0:1023]; // Example instruction memory

    always_ff @(posedge clk or negedge arst_n)
    begin
        if (~arst_n)
        begin
            instruction <= 0;
        end
        else
        begin
            instruction <= instruction_memory[pc[31:2]];
        end
    end

endmodule
