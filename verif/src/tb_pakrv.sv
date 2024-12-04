`timescale 1 ns / 100 ps

// this test-bench has inputs ports because
// to do simulation using verilator, we need a cpp test-bench as well just to generate clock and reset

`define MEM        i_core_top.i_mem
`define RF         i_core_top.i_core.i_id_stage.i_rf

module tb_pakrv #(
    localparam DATA_WIDTH = 32
)(
    input logic clk,
    input logic arst_n
);

    string  instructions;
    integer time_out;
    integer signature_fp;
    integer clk_cycles_counter_fp;
    
    core_top # (
        .DATA_WIDTH ( DATA_WIDTH )
    ) i_core_top    (
        .clk        ( clk        ),
        .arst_n     ( arst_n     )
    );

    // dumping vcd for debugging purposes
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
        $display("\n\nTimeout has occured!\n\n");
        $finish;
    end

    // count number of clock cycles the program took
    integer number_of_cycles;
    initial
    begin
        number_of_cycles = 0;
        forever
        begin
            if (arst_n)
            begin
                @(posedge clk);
                number_of_cycles += 1;
            end
        end
    end

    initial
    begin
        forever
        begin
            @ (posedge clk);

            // dumping condition in the case of compliance testing
            if (`MEM.write_en && `MEM.addr == 32'h8E00_0000)
            begin
                $fwrite(signature_fp, "%h\n", `MEM.data_in);
            end

            // HALT condition in the case of compliance testing
            if (`MEM.write_en && `MEM.addr == 32'h8F00_0000)
            begin
                $fwrite(clk_cycles_counter_fp, "%150s ", instructions);
                $fwrite(clk_cycles_counter_fp, "%20d\n", number_of_cycles);
                $finish;
            end
        end
    end

    initial
    begin
        signature_fp          = $fopen("DUT-pakrv.signature", "w"); // signature dumping file
        clk_cycles_counter_fp = $fopen("clk_cycles.cycles", "a");

        if (signature_fp == 0)
        begin
            $display("Error opening file DUT-pakrv.signature for signature dumping");
            $finish;
        end
        if (clk_cycles_counter_fp == 0)
        begin
            $display("Error opening file clk_cycles.cycles for signature dumping");
            $finish;
        end

    end

    initial
    begin
        // Load instructions from given file (%s)
        if ($value$plusargs("imem=%s", instructions))
        begin
            $display("Loading Instruction Memory from %0s", instructions);
            $readmemh(instructions, i_core_top.i_mem.memory);
        end

        // if some instruction hangs, we should stop simulation after time time_out (%d)
        if($value$plusargs("time_out=%d", time_out))
        begin
            $display("Timeout set as %0d cycles\n", time_out);
        end
    end

endmodule
