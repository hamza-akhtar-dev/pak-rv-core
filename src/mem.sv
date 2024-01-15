// common memory for PakRV Core

module mem 
# (
    parameter DATA_WIDTH    = 32,
    parameter DMEM_SZ_IN_KB = 1,
    localparam ADDR_WIDTH   = 32,
    localparam MASK_SIZE    = DATA_WIDTH/8
) (
    input  logic                  clk,
    input  logic                  arst_n,
    input  logic [DATA_WIDTH-1:0] pc,
    output logic [DATA_WIDTH-1:0] inst_out,

    // data memory related things
    input  logic                  write_en,
    input  logic                  read_en,
    input  logic [ MASK_SIZE-1:0] mask,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  read_resp
);
    // shared instruction and data memory
    logic [DATA_WIDTH-1:0] memory [24'hff_ffff]; // some arbitrary memory for now only

    assign data_out  = read_en ? memory[addr[ADDR_WIDTH-1:2]] : '0;
    assign read_resp = read_en ? 1'b1 : 1'b0;   // read_resp = 1 means data loaded successfully

    assign inst_out = memory[pc[DATA_WIDTH-1:2] - 32'h8000_0000];    // load instruction with given PC

    `ifndef COMPLIANCE
        initial
        begin
            $readmemh("../verif/build/test.mem", memory);
        end
    `endif
    
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (write_en)
        begin
            if (mask[0]) memory[{addr[ADDR_WIDTH-1:2], 2'b0}][ 7: 0] <= data_in[ 7: 0];
            if (mask[1]) memory[{addr[ADDR_WIDTH-1:2], 2'b0}][15: 8] <= data_in[15: 8];
            if (mask[2]) memory[{addr[ADDR_WIDTH-1:2], 2'b0}][23:16] <= data_in[23:16];
            if (mask[3]) memory[{addr[ADDR_WIDTH-1:2], 2'b0}][31:24] <= data_in[31:24];
        end
    end

endmodule: mem
