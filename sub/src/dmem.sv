// parametrized Data Memory

module dmem # (
    parameter DATA_WIDTH    = 32,
    parameter DMEM_SZ_IN_KB = 1,
    localparam ADDR_WIDTH   = $clog2(DMEM_SZ_IN_KB*1024),
    localparam MASK_SIZE    = DATA_WIDTH/8
) (
    input  logic                  clk,
    input  logic                  arst_n,
    input  logic                  write_en,
    input  logic [MASK_SIZE-1:0]  mask,
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
            if (mask[0]) data_memory[addr[ADDR_WIDTH-1:2]][7:0]   <= data_in[7:0];
            if (mask[1]) data_memory[addr[ADDR_WIDTH-1:2]][15:8]  <= data_in[15:8];
            if (mask[2]) data_memory[addr[ADDR_WIDTH-1:2]][23:16] <= data_in[23:16];
            if (mask[3]) data_memory[addr[ADDR_WIDTH-1:2]][31:24] <= data_in[31:24];
            else         data_memory[addr[ADDR_WIDTH-1:2]]        <= '0;
        end
        else
        begin
            data_memory[addr[ADDR_WIDTH-1:2]]        <= '0;
        end
    end

endmodule: dmem
