// Control Status Module
`include "csr_pkg.svh"

module csr
    import csr_pkg::csrop_t;
    import csr_pkg::CSRRW; 
    import csr_pkg::CSRRS; 
    import csr_pkg::CSRRC; 
    import csr_pkg::CSRRWI; 
    import csr_pkg::CSRRSI; 
    import csr_pkg::CSRRCI;
# (
    parameter  DATA_WIDTH    = 32,
    parameter  NUM_REGISTERS = 4096,
    localparam OP_ADDR_WIDTH = $clog2(NUM_REGISTERS),
    parameter  PC_SIZE       = 32
) (
    input logic                      clk,
    input logic                      arst_n,
    
    // csr control signals
    csrop_t                          csrop,
    input  logic [   DATA_WIDTH-1:0] rs1_data,
    input  logic [   DATA_WIDTH-1:0] zimm,

    // read/write interface
    input  logic [OP_ADDR_WIDTH-1:0] addr_in,
    input  logic                     wr_en_in,
    output logic [   DATA_WIDTH-1:0] rd_data_out
);

    logic [DATA_WIDTH-1:0] wr_data_in;
    logic [DATA_WIDTH-1:0] wr_mask_in;

    logic [DATA_WIDTH-1:0] rd_data;

    always_comb
    begin
        case(csrop)
            CSRRW:
            begin
                wr_data_in = rs1_data;
                wr_mask_in = ~'b0;
            end
            CSRRS:
            begin
                wr_data_in = rs1_data;
                wr_mask_in = rs1_data;
            end
            CSRRC:
            begin
                wr_data_in = ~rs1_data;
                wr_mask_in = rs1_data;
            end
            CSRRWI:
            begin
                wr_data_in = zimm;
                wr_mask_in = ~'b0;
            end
            CSRRSI:
            begin
                wr_data_in = zimm;
                wr_mask_in = zimm;
            end
            CSRRCI:
            begin
                wr_data_in = ~zimm;
                wr_mask_in = zimm;
            end
            default:
            begin
                wr_data_in = 'b0;
                wr_mask_in = 'b0;
            end
        endcase
    end

    csrf # (
        .DATA_WIDTH    (DATA_WIDTH   ),
        .NUM_REGISTERS (NUM_REGISTERS)
    ) i_csr_regfile (
        .clk           (clk          ),
        .arst_n        (arst_n       ),
        .addr_in       (addr_in      ),
        .wr_en_in      (wr_en_in     ),
        .wr_data_in    (wr_data_in   ),
        .wr_mask_in    (wr_mask_in   ),
        .rd_data_out   (rd_data      )
    );

    // buffer the read data to assure atomicity
    always_ff @(negedge clk, negedge arst_n)
    begin
        if(~arst_n)
        begin
            rd_data_out <= 'b0;
        end
        else
        begin
            rd_data_out <= rd_data;
        end
    end

endmodule