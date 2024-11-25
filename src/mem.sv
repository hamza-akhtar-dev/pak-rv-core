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

    // instruction memory interface
    input  logic [DATA_WIDTH-1:0] pc,
    output logic [DATA_WIDTH-1:0] inst_out,

    // data memory related things
    input  logic                  write_en,
    input  logic                  read_en,

    output logic                  w_success,
    output logic                  r_success,

    input  logic [ MASK_SIZE-1:0] mask,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out
);
    // shared instruction and data memory
    logic [DATA_WIDTH-1:0] memory [24'hff_ffff]; // some arbitrary memory for now only

    assign inst_out = memory[pc[DATA_WIDTH-1:2] - 32'h8000_0000];    // load instruction with given PC

    `ifndef COMPLIANCE
        initial
        begin
            $readmemh("../verif/build/test.mem", memory);
        end
    `endif

    // synchronous write
    always_ff @ (posedge clk)
    begin
        if (write_en)
        begin
            if (mask[0]) memory[addr[ADDR_WIDTH-1:2]][ 7: 0] <= data_in[ 7: 0];
            if (mask[1]) memory[addr[ADDR_WIDTH-1:2]][15: 8] <= data_in[15: 8];
            if (mask[2]) memory[addr[ADDR_WIDTH-1:2]][23:16] <= data_in[23:16];
            if (mask[3]) memory[addr[ADDR_WIDTH-1:2]][31:24] <= data_in[31:24];
            w_success <= 1'b1;
        end
        else
        begin
            w_success <= 1'b0;
        end
    end

    // asynchronous read
    always_comb
    begin
        if (read_en)
        begin
            data_out  = memory[addr[ADDR_WIDTH-1:2]];
            r_success = 1'b1;
        end
        else
        begin
            data_out  = '0;
            r_success = 1'b0;
        end
    end

endmodule: mem
