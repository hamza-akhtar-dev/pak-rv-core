
module pak_rv_core # (
    parameter DATA_WIDTH    = 32,
    parameter IMEM_SZ_IN_KB = 1,
    parameter DMEM_SZ_IN_KB = 1,
    localparam PC_SIZE      = $clog2(IMEM_SZ_IN_KB*1024*8)
)(
    input  logic clk,
    input  logic arst_n
);

    logic [PC_SIZE-1:0]    pc_in;       // next pc
    logic [PC_SIZE-1:0]    pc_out;      // current pc
    logic [DATA_WIDTH-1:0] instruction;
    logic                  rf_wr;
    logic                  dmem_wr;
    logic [2:0]            imm_src;

    pc # (
        .PC_SIZE ( PC_SIZE )
    ) i_pc (
        .clk     ( clk     ),
        .arst_n  ( arst_n  ),
        .pc_in   ( pc_in   ),
        .pc_out  ( pc_out  )
    );

    assign pc_in = pc_out + 4;

    if_stage # (
        .DATA_WIDTH    ( DATA_WIDTH    ),
        .IMEM_SZ_IN_KB ( IMEM_SZ_IN_KB )
    ) i_if_stage (
        .clk         ( clk         ),
        .arst_n      ( arst_n      ),
        .pc          ( pc_out      ),
        .instruction ( instruction )
    );


    ctrl_unit #(
        .DATA_WIDTH  ( DATA_WIDTH  )
    ) i_ctrl_unit (
        .clk         ( clk         ),
        .arst_n      ( arst_n      ),
        .instruction ( instruction ),
        .rf_wr       ( rf_wr       ),
        .mem_wr      ( dmem_wr     ),
        .imm_src     ( imm_src     )
    );


    dmem # (
        .DATA_WIDTH    ( DATA_WIDTH    ),
        .DMEM_SZ_IN_KB ( DMEM_SZ_IN_KB )
    ) i_dmem (
        .clk           ( clk           ),
        .arst_n        ( arst_n        ),
        .write_en      ( dmem_wr       ),
        .addr          (               ),
        .data_in       (               ),
        .data_out      (               )
    );

endmodule: pak_rv_core