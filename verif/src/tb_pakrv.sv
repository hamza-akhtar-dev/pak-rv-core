`timescale 1 ns / 100 ps

// this test-bench has inputs ports because
// to do simulation using verilator, we need a cpp test-bench as well

module tb_pakrv (
    input logic clk,
    input logic arst_n
);

    logic [1023:0]              instructions;
    int                         time_out;

    core_top # (
        .DATA_WIDTH    ( 32     )
    ) i_core_top (
        .clk           ( clk    ),
        .arst_n        ( arst_n )
    );

    // dumping for debugging purposes
    initial
    begin
        $dumpfile("pakrv_dump.vcd");
        $dumpvars;
    end

    // Time out Block
    initial
    begin
        for (int i = 0; i < time_out; i++)
        begin
            @(posedge clk);
        end
        $finish;
    end

    initial
    begin
        // Load instructions from given file (%s)
        if ($value$plusargs("imem=%s", instructions))
        begin
            $display("Loading Instruction Memory from %0s", instructions);
            $readmemh(instructions, i_core_top.i_mem.data_memory);
        end

        // if some instruction hangs, we should stop simulation after time time_out (%d)
        if($value$plusargs("time_out=%d", time_out))
        begin
            $display("Timeout set as %0d cycles\n", time_out);
        end
    end

endmodule
