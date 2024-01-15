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
    import amo_pkg::acu_s;
    import amo_pkg::amo_mem_s;
    import amo_pkg::state_t;
    import amo_pkg::AMO_IDLE;
    import amo_pkg::AMO_LOAD;
    import amo_pkg::AMO_CALC;
    import amo_pkg::AMO_DONE;
#(
    parameter DATA_WIDTH = 32
) (
    input  logic                     clk,
    input  logic                     arst_n,
    input  amoop_t                   amoop,
    input  logic                     is_amo,
    output amo_mem_s                 amo_to_mem_if,
    output amo_mem_s                 amo_to_rf_if,
    output logic                     amo_busy,

    input  logic                     is_data_loaded,  // 1: data is loaded from memory
    input  logic [   DATA_WIDTH-1:0] rs1_addr, 
    input  logic [   DATA_WIDTH-1:0] rs1_data,
    input  logic [   DATA_WIDTH-1:0] rs2_data
);

    acu_s acu;
    state_t current_state, next_state;

    logic mem_wr_req;
    logic rf_wr_req;
    logic mem_rd_req;
    logic start_calc;
    logic done_calc;

    logic [DATA_WIDTH-1:0] rs1_addr_ff;
    logic [DATA_WIDTH-1:0] rs1_data_ff;
    logic [DATA_WIDTH-1:0] rs2_data_ff;

    logic [DATA_WIDTH-1:0] amo_res;
    logic [DATA_WIDTH-1:0] dst_mem_data;
    logic [DATA_WIDTH-1:0] rf_data;
    logic [DATA_WIDTH-1:0] dst_rf_data;

    assign rf_data = (amo_busy & is_data_loaded) ? rs1_data_ff : '0;

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            current_state <= AMO_IDLE;
        end
        else
        begin
            current_state <= next_state;
        end
    end

    // AMO controller
    always_comb
    begin
        case(current_state)
            AMO_IDLE:
            begin
                mem_wr_req = 1'b0;
                rf_wr_req  = 1'b0;
                mem_rd_req = 1'b0;
                start_calc = 1'b0;
                if (is_amo)
                begin
                    next_state = AMO_LOAD;
                    amo_busy   = 1'b1;
                end
                else
                begin
                    next_state = AMO_IDLE;
                    amo_busy   = 1'b0;
                end
            end
            AMO_LOAD:
            begin
                mem_wr_req = 1'b0;
                mem_rd_req = 1'b1;
                rf_wr_req  = 1'b0;
                amo_busy   = 1'b1;
                start_calc = 1'b0;
                if (is_data_loaded)
                begin
                    next_state = AMO_CALC;
                end
                else
                begin
                    next_state = AMO_LOAD;
                end
            end
            AMO_CALC:
            begin
                mem_wr_req = 1'b0;
                mem_rd_req = 1'b0;
                rf_wr_req  = 1'b0;
                amo_busy   = 1'b1;
                start_calc = 1'b1;
                if (acu.busy)
                begin
                    next_state = AMO_CALC;
                end
                else
                begin
                    next_state = AMO_DONE;
                end
            end
            AMO_DONE:
            begin
                mem_wr_req = 1'b1;
                mem_rd_req = 1'b0;
                rf_wr_req  = 1'b1;
                amo_busy   = 1'b0;
                start_calc = 1'b0;
                next_state = AMO_IDLE;
            end
            default:
            begin
                mem_wr_req = 1'b0;
                mem_rd_req = 1'b0;
                rf_wr_req  = 1'b0;
                amo_busy   = 1'b0;
                next_state = AMO_IDLE;
            end
        endcase
    end

    // AMO's Computational Unit (ACU)
    always_comb
    begin
        acu.busy = 0;
        if (start_calc)
        begin
            case (amoop)
                AMOADD_W : acu.res = rs1_data_ff + rs2_data_ff;
                AMOSWAP_W: acu.res = rs2_data_ff;
                AMOXOR_W : acu.res = rs1_data_ff ^ rs2_data_ff;
                AMOAND_W : acu.res = rs1_data_ff & rs2_data_ff;
                AMOOR_W  : acu.res = rs1_data_ff | rs2_data_ff;
                AMOMIN_W : acu.res =    $signed(rs1_data_ff) <    $signed(rs2_data_ff) ? rs1_data_ff : rs2_data_ff;
                AMOMAX_W : acu.res =    $signed(rs1_data_ff) >    $signed(rs2_data_ff) ? rs1_data_ff : rs2_data_ff;
                AMOMINU_W: acu.res = ($unsigned(rs1_data_ff) < $unsigned(rs2_data_ff)) ? rs1_data_ff : rs2_data_ff;
                AMOMAXU_W: acu.res = ($unsigned(rs1_data_ff) > $unsigned(rs2_data_ff)) ? rs1_data_ff : rs2_data_ff;
                default:   acu.res = '0;
            endcase
            done_calc = 1'b1;
        end
        else
        begin
            acu.res   = '0;
            done_calc = 1'b0;
        end
    end

    assign amo_to_mem_if.addr  = rs1_addr_ff;
    assign amo_to_mem_if.wr_en = mem_wr_req;
    assign amo_to_mem_if.rd_en = mem_rd_req;
    assign amo_to_mem_if.data  = dst_mem_data;
    assign amo_to_mem_if.mask  = 4'b1111;

    assign amo_to_rf_if.addr  = '0;   // does not matter (already decoded)
    assign amo_to_rf_if.wr_en = rf_wr_req;
    assign amo_to_rf_if.rd_en = '0;   // does not matter
    assign amo_to_rf_if.data  = dst_rf_data;
    assign amo_to_rf_if.mask  = '0;   // does not matter

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            rs1_addr_ff <= '0;
            rs2_data_ff <= '0;
        end
        else if (is_amo)
        begin
            rs1_addr_ff <= rs1_addr;
            rs2_data_ff <= rs2_data;
        end
    end

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            rs1_data_ff <= '0;
        end
        else if (is_data_loaded)
        begin
            rs1_data_ff <= rs2_data;
        end
    end

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            dst_mem_data <= '0;
            dst_rf_data  <= '0;
        end
        else if (done_calc)
        begin
            dst_mem_data <= acu.res;
            dst_rf_data  <= rf_data;
        end
    end

endmodule: amo
