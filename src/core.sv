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

    import id_stage_pkg ::id_stage_in_frm_ex_t;
    import id_stage_pkg ::id_hdu_out_t;
    import ex_stage_pkg ::ex_cfu_out_t;
    import ex_stage_pkg ::ex_stage_in_frm_mem_t;
    import ex_stage_pkg ::ex_stage_in_frm_wb_t;
# (
    parameter  DATA_WIDTH    = 32,
    parameter  IMEM_SZ_IN_KB = 1,
    parameter  DMEM_SZ_IN_KB = 1
) (
    input  logic                    clk,
    input  logic                    arst_n,
    output logic [DATA_WIDTH-1:0]   pc,
    input  logic [DATA_WIDTH-1:0]   inst_in,

    // data memory related ports
    input  logic [DATA_WIDTH-1:0]   core_in_mem_data_out,
    output logic [DATA_WIDTH-1:0]   core_out_mem_addr_in,
    output logic [DATA_WIDTH-1:0]   core_out_mem_data_in,
    output logic                    core_out_mem_we_in,
    output logic [DATA_WIDTH/8-1:0] core_out_mem_mask_in
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
    id_stage_in_frm_ex_t  id_stage_in_frm_ex;
    id_hdu_out_t          id_hdu_out;
    ex_cfu_out_t          ex_cfu_out;
    ex_stage_in_frm_mem_t ex_stage_in_frm_mem;
    ex_stage_in_frm_wb_t  ex_stage_in_frm_wb;

    logic [DATA_WIDTH-1:0] pc4;

    // external memory related connections
    logic [3:0]            mem_mask;
    logic [DATA_WIDTH-1:0] lsu_data_out;

    // stage instantiations
    if_stage # (
        .DATA_WIDTH    (DATA_WIDTH   ),
        .IMEM_SZ_IN_KB (IMEM_SZ_IN_KB)
    ) i_if_stage (
        .clk           (clk          ),
        .arst_n        (arst_n       ),
        .if_stage_in   (if_stage_in  ),
        .if_stage_out  (/*if_stage_out*/ ),
        .pc_out        (pc           ),
        .pc4           (pc4          )
    );

    assign if_stage_out.inst = inst_in;
    assign if_stage_out.pc   = pc;
    assign if_stage_out.pc4  = pc4;

    id_stage #(
        .DATA_WIDTH        (DATA_WIDTH        )
    ) i_id_stage (
        .clk               (clk               ),
        .arst_n            (arst_n            ),
        .wb_in             (wb_stage_out      ), // writeback interface
        .id_stage_in       (id_stage_in       ),
        .id_stage_in_frm_ex(id_stage_in_frm_ex),
        .id_stage_out      (id_stage_out      ),
        .id_hdu_out        (id_hdu_out        )
    );

    ex_stage #(
        .DATA_WIDTH         (DATA_WIDTH         )
    ) i_ex_stage (
        .ex_stage_in        (ex_stage_in        ),
        .ex_stage_in_frm_mem(ex_stage_in_frm_mem),
        .ex_stage_in_frm_wb (ex_stage_in_frm_wb ),
        .ex_stage_out       (ex_stage_out       ),
        .ex_cfu_out         (ex_cfu_out         )
    );

    mem_stage #(
        .DATA_WIDTH   (DATA_WIDTH           ),
        .DMEM_SZ_IN_KB(DMEM_SZ_IN_KB        )
    ) i_mem_stage (
        .clk          (clk                  ),
        .arst_n       (arst_n               ),
        .mem_stage_in (mem_stage_in         ),
        .mem_stage_out(mem_stage_out        ),
        .mem_data_out (core_in_mem_data_out ),
        .lsu_data_out (lsu_data_out         ),
        .mask         (mem_mask             ),
        .mem_data_in  (core_out_mem_data_in ),
        .mem_addr_in  (core_out_mem_addr_in )
    );

    wb_stage #(
    ) i_wb_stage (
        .wb_stage_in  (wb_stage_in  ),
        .wb_stage_out (wb_stage_out )
    );

    assign core_out_mem_we_in   = mem_stage_in.dm_en;
    assign core_out_mem_mask_in = mem_mask;

    // combinational connections
    always_comb
    begin
        if_stage_in.br_taken        = ex_cfu_out.br_taken;
        if_stage_in.br_target       = ex_cfu_out.br_target;
        if_stage_in.stall           = id_hdu_out.stall;
        ex_stage_in_frm_mem.rf_en   = mem_stage_in.rf_en;
        ex_stage_in_frm_mem.rd      = mem_stage_in.rd;
        ex_stage_in_frm_mem.opr_res = mem_stage_in.opr_res;
        ex_stage_in_frm_wb.rf_en    = wb_stage_in.rf_en;
        ex_stage_in_frm_wb.rd       = wb_stage_in.rd;
        ex_stage_in_frm_wb.wb_data  = wb_stage_out.wb_data;
        id_stage_in_frm_ex.rd       = ex_stage_in.rd;
        id_stage_in_frm_ex.wb_sel   = ex_stage_in.wb_sel;
    end

    // if -> id
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n | ex_cfu_out.br_taken) 
        begin
            id_stage_in  <= '0;
        end
        else if (~id_hdu_out.stall)
        begin
            id_stage_in  <= if_stage_out;
        end
    end

    // id -> ex
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n | id_hdu_out.flush | ex_cfu_out.br_taken) 
        begin
            ex_stage_in  <= '0;
        end
        else
        begin
            ex_stage_in  <= id_stage_out;
        end
    end

    // ex -> mem
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n) 
        begin
            mem_stage_in <= '0;
        end
        else
        begin
            mem_stage_in <= ex_stage_out;
        end
    end

    // mem -> wb
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n)
        begin
            wb_stage_in  <= '0;
        end
        else 
        begin
            wb_stage_in  <= mem_stage_out;
        end
    end

endmodule: core
