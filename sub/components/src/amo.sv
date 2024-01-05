// AMO (Atomic Memory Operation) instructions are used to implement atomic memory operations.

/* 
 * The AMO instructions atomically load a data value from the address in rs1,
 * place the value into register rd,
 * apply a binary operator to the loaded value and the original value in rs2,
 * then store the result back to the original address in rs1.
*/

`include "amo_pkg.svh"

module amo
    import amo_pkg::amoop_t;
    import amo_pkg::AMOADD_W;
    import amo_pkg::AMOSWAP_W;
    import amo_pkg::AMOXOR_W;
    import amo_pkg::AMOAND_W;
    import amo_pkg::AMOOR_W;
    import amo_pkg::AMOMIN_W;
    import amo_pkg::AMOMAX_W;
    import amo_pkg::AMOMINU_W;
    import amo_pkg::AMOMAXU_W;
#(
    parameter DATA_WIDTH = 32
) (
    input  logic                     clk,
    input  logic                     arst_n,
    input  amoop_t                   amoop,
    input  logic [   DATA_WIDTH-1:0] rs1_data,
    input  logic [   DATA_WIDTH-1:0] rs2_data,
    input  logic                     wr_en_in,
    output logic [   DATA_WIDTH-1:0] rd_data_out,  // data to be stored in rd
    output logic                     mem_wr_req,   // memory write request
    output logic [   DATA_WIDTH-1:0] mem_addr_out, // addr where to store modified data in memory
    output logic [   DATA_WIDTH-1:0] mem_data_out, // modified data to be stored in memory
    output logic [ DATA_WIDTH/8-1:0] mem_mask_out
);

    logic [DATA_WIDTH-1:0] rd_data;

    always_ff @(posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            rd_data <= '0;
        end
        else if (wr_en_in)
        begin
            case (amoop)
                AMOADD_W : rd_data <= $signed(rs1_data) + $signed(rs2_data);
                AMOSWAP_W: rd_data <= $signed(rs2_data);
                AMOXOR_W : rd_data <= $signed(rs1_data) ^ $signed(rs2_data);
                AMOAND_W : rd_data <= $signed(rs1_data) & $signed(rs2_data);
                AMOOR_W  : rd_data <= $signed(rs1_data) | $signed(rs2_data);
                AMOMIN_W : rd_data <= ($signed(rs1_data) < $signed(rs2_data)) ? $signed(rs1_data) : $signed(rs2_data);
                AMOMAX_W : rd_data <= ($signed(rs1_data) > $signed(rs2_data)) ? $signed(rs1_data) : $signed(rs2_data);
                AMOMINU_W: rd_data <= (rs1_data < rs2_data) ? rs1_data : rs2_data;
                AMOMAXU_W: rd_data <= (rs1_data > rs2_data) ? rs1_data : rs2_data;
                default:   rd_data <= '0;
            endcase
        end
    end

    // store modified data (by AMOs) in memory
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            mem_wr_req   <= '0;
            mem_addr_out <= '0;
            rd_data_out  <= '0;
            // mem_data_out <= '0;
        end
        else if (wr_en_in)
        begin
            mem_wr_req   <= '1;
            mem_addr_out <= rs1_data;
            rd_data_out  <= rs1_data;
            // mem_data_out <= rd_data;
        end
        else
        begin
            mem_wr_req   <= '0;
            mem_addr_out <= '0;
            rd_data_out  <= '0;
        end
    end

    assign mem_data_out = rd_data;
    assign mem_mask_out = 4'b1111;
    // assign rd_data_out  = rs1_data;

endmodule: amo
