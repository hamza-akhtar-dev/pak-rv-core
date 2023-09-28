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
    input  logic [ MASK_SIZE-1:0] mask,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out
);
    logic [DATA_WIDTH-1:0] data_memory [28'h3ff_ffff];
    integer write_sig;
    integer debug;
    assign data_out = data_memory[addr[ADDR_WIDTH-1:2]];

    assign inst_out = data_memory[pc[DATA_WIDTH-1:2] - 32'h8000_0000];    // load instruction with given PC

    `ifndef COMPLIANCE
        initial
        begin
            $readmemh("../verif/gen_machine_codes/build/machine_code.mem", data_memory);
        end
    `endif

    initial
    begin
        forever
        begin
            @(posedge clk);
            if (write_en && addr == 32'h8E00_0000)
            begin
                $fwrite(write_sig, "%h\n", data_in);
            end
            if (write_en && addr == 32'h8F00_0000)
            begin
                $finish;
            end
        end
    end

    initial
    begin
        write_sig = $fopen("DUT-pakrv.signature", "w"); // Open file for writing
        if (write_sig == 0)
        begin
            $display("Error opening file for writing");
            $finish;
        end
    end
    
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (write_en)
        begin
            if (mask[0]) data_memory[addr[ADDR_WIDTH-1:2]][ 7: 0] <= data_in[ 7: 0];
            if (mask[1]) data_memory[addr[ADDR_WIDTH-1:2]][15: 8] <= data_in[15: 8];
            if (mask[2]) data_memory[addr[ADDR_WIDTH-1:2]][23:16] <= data_in[23:16];
            if (mask[3]) data_memory[addr[ADDR_WIDTH-1:2]][31:24] <= data_in[31:24];
        end
    end

    // for debugging purpose
    // final
    // begin
    //     $writememh("dmem.mem", data_memory, 32'h8000_0000, 32'h8000_0100);
    // end

endmodule: mem
