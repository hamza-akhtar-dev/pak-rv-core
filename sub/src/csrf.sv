// Parameterized Control Status Register File

module csrf 
# (
    parameter  DATA_WIDTH    = 32,
    parameter  NUM_REGISTERS = 4096,
    localparam OP_ADDR_WIDTH = $clog2(NUM_REGISTERS)
) (
    input  logic                     arst_n,
    input  logic                     clk,
    
    // common read/write address
    input  logic [OP_ADDR_WIDTH-1:0] addr_in,

    // write interface
    input  logic                     wr_en_in,
    input  logic [   DATA_WIDTH-1:0] wr_data_in,
    input  logic [   DATA_WIDTH-1:0] wr_mask_in,

    // read interface
    output logic [   DATA_WIDTH-1:0] rd_data_out
);

    logic [DATA_WIDTH-1:0] cs_reg_file [NUM_REGISTERS-1:0];

    // synchronous write
    always_ff @(negedge clk, negedge arst_n)
    begin
        if(~arst_n)
        begin
            cs_reg_file <= '{default:'0};
        end
        else if (wr_en_in)
        begin
            cs_reg_file[addr_in] <= (cs_reg_file[addr_in] & ~wr_mask_in) | (wr_data_in & wr_mask_in);
        end
    end

    // asynchronous read
    assign rd_data_out = cs_reg_file[addr_in];

    // for debugging purpose
    final
    begin
        $writememh("csrf.mem", cs_reg_file, 0, NUM_REGISTERS-1);
    end

endmodule
