// Parameterized Register File

module rf 
# (
    parameter  DATA_WIDTH    = 32,
    parameter  NUM_REGISTERS = 32,
    localparam OP_ADDR_WIDTH = $clog2(NUM_REGISTERS)
) (
    input  logic                     arst_n,
    input  logic                     clk,
    input  logic                     wr_en_in,
    input  logic [OP_ADDR_WIDTH-1:0] rd_in,   // destination register address
    input  logic [   DATA_WIDTH-1:0] rd_data_in,
    input  logic [OP_ADDR_WIDTH-1:0] rs1_in,  // source register 1 address
    input  logic [OP_ADDR_WIDTH-1:0] rs2_in,  // source register 2 address
    output logic [   DATA_WIDTH-1:0] rs1_data_out,
    output logic [   DATA_WIDTH-1:0] rs2_data_out
);

    logic [DATA_WIDTH-1:0] reg_file [NUM_REGISTERS-1:0];

    // synchronous write
    always_ff @(negedge clk, negedge arst_n)
    begin
        if(~arst_n)
        begin
            reg_file <= '{default:'0};
        end
        else if (wr_en_in)
        begin
            reg_file[rd_in] <= rd_data_in;
        end
    end

    // asynchronous read
    assign rs1_data_out = reg_file[rs1_in];
    assign rs2_data_out = reg_file[rs2_in];

    // for debugging purpose
    final
    begin
        $writememh("rf.mem", reg_file, 0, 31);
    end

endmodule
