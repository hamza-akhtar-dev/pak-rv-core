// core_top contains core's pipeline and memory

module core_top
    import amo_pkg::amo_mem_s;
# (
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input logic clk,
    input logic arst_n
);

    logic [DATA_WIDTH-1:0] mem_data_out;
    logic [DATA_WIDTH-1:0] mem_data_in;
    logic                  mem_we_in;
    logic [3:0]            mem_mask_in;
    logic [ADDR_WIDTH-1:0] mem_addr_in;

    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] instruction;

    logic                  mem_re_in;
    logic                  read_resp;
    amo_mem_s              amo_to_mem_if;

    core # (
        .DATA_WIDTH           (DATA_WIDTH  )
    ) i_core (
        .clk                  (clk         ),
        .arst_n               (arst_n      ),
        .pc                   (pc          ),
        .inst_in              (instruction ),
        .core_in_mem_data_out (mem_data_out),
        .core_in_mem_read_resp(read_resp   ),
        .core_out_mem_re_in   (mem_re_in   ),
        .core_out_mem_addr_in (mem_addr_in ),
        .core_out_mem_data_in (mem_data_in ),
        .core_out_mem_we_in   (mem_we_in   ),
        .core_out_mem_mask_in (mem_mask_in ),
        .amo_to_mem_if        (amo_to_mem_if)
    );

    mem # (
        .DATA_WIDTH (DATA_WIDTH  )
    ) i_mem (
        .clk        (clk         ),
        .arst_n     (arst_n      ),
        .pc         (pc          ),
        .inst_out   (instruction ),
        .write_en   (mem_we_in   ),
        .read_en    (mem_re_in   ),
        .mask       (mem_mask_in ),
        .addr       (mem_addr_in ),
        .data_in    (mem_data_in ),
        .data_out   (mem_data_out),
        .read_resp  (read_resp   )
    );

endmodule : core_top