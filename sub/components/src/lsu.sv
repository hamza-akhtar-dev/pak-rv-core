// Load Store Unit
// For more information, please refer to docs/riscv-spec-isa-user-manual-volume1-unprivileged.pdf

`include "lsu_pkg.svh"

module lsu
    import lsu_pkg::lsuop_t;
    import lsu_pkg::core_to_lsu_s;
    import lsu_pkg::lsu_to_core_s;
    import lsu_pkg::mem_to_lsu_s;
    import lsu_pkg::lsu_to_mem_s;
# (
    parameter DATA_WIDTH      = 32,
    localparam MASK_SIZE      = DATA_WIDTH/8
) (

    input  core_to_lsu_s core_to_lsu_i,   // from memory stage
    output lsu_to_core_s lsu_to_core_o,   // give to write back unit

    input  mem_to_lsu_s  mem_to_lsu_i,
    output lsu_to_mem_s  lsu_to_mem_o
);

    logic signed [ 7:0]    rdata_byte;
    logic signed [15:0]    rdata_hword;
    logic signed [31:0]    rdata_word;

    logic [MASK_SIZE-1:0]  mask;

    logic [DATA_WIDTH-1:0] data_l_in;
    logic [DATA_WIDTH-1:0] data_l_out;
    logic [DATA_WIDTH-1:0] data_s_in;
    logic [DATA_WIDTH-1:0] data_s_out;

    logic                  rf_wr_en;
    logic                  r_success, w_success; // memory read and write success signals

    logic [DATA_WIDTH-1:0] core_addr;              // address came from core, for byte, halfword operations
    lsuop_t                lsuop;                  // lsuop got from previous stage

    // lsu to core
    assign lsu_to_core_o.data     = data_l_out;
    assign lsu_to_core_o.write_en = rf_wr_en;

    // mem to lsu
    assign data_l_in = mem_to_lsu_i.data;
    assign r_success = mem_to_lsu_i.r_success; 
    assign w_success = mem_to_lsu_i.w_success;

    // lsu to mem
    assign lsu_to_mem_o.write_en = core_to_lsu_i.write_en;
    assign lsu_to_mem_o.read_en  = core_to_lsu_i.read_en;
    assign lsu_to_mem_o.addr     = core_to_lsu_i.addr;
    assign lsu_to_mem_o.data     = data_s_out;
    assign lsu_to_mem_o.strb     = mask;

    // next state determining signals
    assign lsuop     = core_to_lsu_i.lsuop;
    assign core_addr = core_to_lsu_i.addr;
    assign data_s_in = core_to_lsu_i.data;

    always_comb
    begin
        case(lsuop)
            lsu_pkg::LB, lsu_pkg::LBU:
            begin
                rdata_hword = '0;
                rdata_word  = '0;

                case(core_addr[1:0])
                    2'b00:   rdata_byte = data_l_in[7:0];
                    2'b01:   rdata_byte = data_l_in[15:8];
                    2'b10:   rdata_byte = data_l_in[23:16];
                    2'b11:   rdata_byte = data_l_in[31:24];
                    default: rdata_byte = '0;
                endcase
            end
            lsu_pkg::LH, lsu_pkg::LHU:
            begin
                rdata_byte = '0;
                rdata_word = '0;

                case(core_addr[1])
                    1'b0:    rdata_hword = data_l_in[15:0];
                    1'b1:    rdata_hword = data_l_in[31:16];
                    default: rdata_hword = '0;
                endcase
            end
            lsu_pkg::LW:
            begin
                rdata_byte  = '0;
                rdata_hword = '0;
                rdata_word  = data_l_in;
            end
            default:
            begin
                rdata_byte  = '0;
                rdata_hword = '0;
                rdata_word  = '0;
            end
        endcase
    end
    
    always_comb
    begin
        case(lsuop)
            lsu_pkg::SB:
            begin
                case(core_addr[1:0])
                    2'b00:
                    begin
                        data_s_out[7:0] = data_s_in[7:0];
                        mask            = 4'b0001;
                    end
                    2'b01:
                    begin
                        data_s_out[15:8] = data_s_in[7:0];
                        mask             = 4'b0010;
                    end
                    2'b10:
                    begin
                        data_s_out[23:16] = data_s_in[7:0];
                        mask              = 4'b0100;
                    end
                    2'b11:
                    begin
                        data_s_out[31:24] = data_s_in[7:0];
                        mask              = 4'b1000;
                    end
                    default:
                    begin
                        data_s_out = '0;
                        mask       = 4'b0000;
                    end
                endcase
            end 
            lsu_pkg::SH:
            begin
                case(core_addr[1])
                    1'b0:
                    begin
                        data_s_out[15:0] = data_s_in[15:0];
                        mask             = 4'b0011;
                    end
                    1'b1:
                    begin
                        data_s_out[31:16] = data_s_in[15:0];
                        mask              = 4'b1100;
                    end
                    default:
                    begin
                        data_s_out = '0;
                        mask       = '0;
                    end
                endcase
            end
            lsu_pkg::SW:
            begin
                data_s_out = data_s_in;
                mask       = 4'b1111;
            end
            default:
            begin
                data_s_out  = '0;
                mask        = '0;
            end
        endcase
    end

    always_comb
    begin
        if (r_success)
        begin
            case(lsuop)
                lsu_pkg::LB :  data_l_out = {{24{rdata_byte[7]}},   rdata_byte };
                lsu_pkg::LBU:  data_l_out = {{24{1'b0}},            rdata_byte };
                lsu_pkg::LH :  data_l_out = {{16{rdata_hword[15]}}, rdata_hword};
                lsu_pkg::LHU:  data_l_out = {{16{1'b0}},            rdata_hword};
                lsu_pkg::LW :  data_l_out = {                       rdata_word };
                default     :  data_l_out = '0;
            endcase
            rf_wr_en = 1'b1;
        end
        else
        begin
            data_l_out = '0;
            rf_wr_en   = 1'b0;
        end
    end

endmodule: lsu
