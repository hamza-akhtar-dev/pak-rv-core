`timescale 1 ns / 100 ps

module tb_pakrv(input bit clk, input bit arst_n);

logic [1023:0]              firmware;
logic [1023:0]              max_cycles;
logic [1023:0]              main_time = '0;

localparam IMEM_SZ_IN_KB = 1;


  core # (
      .DATA_WIDTH    ( 32     ),
      .IMEM_SZ_IN_KB ( IMEM_SZ_IN_KB  ),
      .DMEM_SZ_IN_KB ( 1      )
  ) i_core (
      .clk           ( clk    ),
      .arst_n        ( arst_n )
  );

  initial
  begin
    $dumpfile("pakrv_dump.vcd");
    $dumpvars;
  end

  initial
  begin

    // Load hex instructions
    if($value$plusargs("imem=%s", firmware)) begin
      $display("Loading Instruction Memory from %0s", firmware);
      $readmemh(firmware, i_core.i_if_stage.instruction_memory);
    end

    if($value$plusargs("max_cycles=%d", max_cycles)) begin
      $display("Timeout set as %0d cycles\n", max_cycles);
    end
  end

endmodule
