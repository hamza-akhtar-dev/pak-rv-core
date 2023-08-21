// parametrized Data Memory

module dmem # (
    parameter DATA_WIDTH    = 32,
    parameter DMEM_SZ_IN_KB = 1,
    localparam ADDR_WIDTH   = $clog2(DMEM_SZ_IN_KB*1024)
) (
    input  logic                  clk,
    input  logic                  arst_n,
    input  logic                  write_en,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out
);
    logic [DATA_WIDTH-1:0] data_memory [(DMEM_SZ_IN_KB*1024)/4];

    assign data_out = data_memory[addr[ADDR_WIDTH-1:2]];

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            data_memory <= '{default: '0};
        end
        else if (write_en)
        begin
            data_memory[addr[ADDR_WIDTH-1:2]] <= data_in;
        end
    end

endmodule: dmem
