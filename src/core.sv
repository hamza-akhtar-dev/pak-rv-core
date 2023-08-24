// Core

`include "if_stage_pkg.svh"
`include "id_stage_pkg.svh"
`include "ex_stage_pkg.svh"
`include "mem_stage_pkg.svh"
`include "wb_stage_pkg.svh"

module core 
    import if_stage_pkg ::if_stage_in_t;
    import id_stage_pkg ::id_stage_in_t;
    import ex_stage_pkg ::ex_stage_in_t;
    import mem_stage_pkg::mem_stage_in_t;
    import wb_stage_pkg ::wb_stage_in_t;
    import if_stage_pkg ::if_stage_out_t;
    import id_stage_pkg ::id_stage_out_t;
    import ex_stage_pkg ::ex_stage_out_t;
    import mem_stage_pkg::mem_stage_out_t;
    import wb_stage_pkg ::wb_stage_out_t;

    import ex_stage_pkg ::ex_cfu_out_t;
# (
    parameter  DATA_WIDTH    = 32,
    parameter  IMEM_SZ_IN_KB = 1,
    parameter  DMEM_SZ_IN_KB = 1
) (
    input  logic clk,
    input  logic arst_n
);
    // stage signals
    if_stage_in_t  if_stage_in;
    if_stage_out_t if_stage_out;

    id_stage_in_t  id_stage_in;
    id_stage_out_t id_stage_out;

    ex_stage_in_t  ex_stage_in;
    ex_stage_out_t ex_stage_out;

    mem_stage_in_t  mem_stage_in;
    mem_stage_out_t mem_stage_out;

    wb_stage_in_t  wb_stage_in;
    wb_stage_out_t wb_stage_out;

    // combinational connection signals
    ex_cfu_out_t   ex_cfu_out;

    // stage instantiations
    if_stage # (
        .DATA_WIDTH    (DATA_WIDTH   ),
        .IMEM_SZ_IN_KB (IMEM_SZ_IN_KB)
    ) i_if_stage (
        .clk           (clk          ),
        .arst_n        (arst_n       ),
        .if_stage_in   (if_stage_in  ),
        .if_stage_out  (if_stage_out )
    );

    id_stage #(
        .DATA_WIDTH  (DATA_WIDTH  )
    ) i_id_stage (
        .clk         (clk         ),
        .arst_n      (arst_n      ),
        .wb_in       (wb_stage_out), // writeback interface
        .id_stage_in (id_stage_in ),
        .id_stage_out(id_stage_out)
    );

    ex_stage #(
        .DATA_WIDTH  (DATA_WIDTH  )
    ) i_ex_stage (
        .ex_stage_in (ex_stage_in ),
        .ex_stage_out(ex_stage_out),
        .ex_cfu_out  (ex_cfu_out  )
    );

    mem_stage #(
        .DATA_WIDTH   (DATA_WIDTH   ),
        .DMEM_SZ_IN_KB(DMEM_SZ_IN_KB)
    ) i_mem_stage (
        .clk          (clk          ),
        .arst_n       (arst_n       ),
        .mem_stage_in (mem_stage_in ),
        .mem_stage_out(mem_stage_out)
    );

    wb_stage #(
    ) i_wb_stage (
        .wb_stage_in  (wb_stage_in  ),
        .wb_stage_out (wb_stage_out )
    );

    // combinational connections
    always_comb
    begin
        if_stage_in = ex_cfu_out;
    end

    // pipeline registers
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n) 
        begin
            id_stage_in  <= '0;
            ex_stage_in  <= '0;
            mem_stage_in <= '0;
            wb_stage_in  <= '0;
        end
        else 
        begin
            id_stage_in  <= if_stage_out;
            ex_stage_in  <= id_stage_out;
            mem_stage_in <= ex_stage_out;
            wb_stage_in  <= mem_stage_out;
        end
    end

endmodule: core
