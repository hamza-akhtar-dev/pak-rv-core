// Load Store Unit

`include "lsu_pkg.svh"

module lsu
    import lsu_pkg::lsuop_t;
# (
    parameter DATA_WIDTH      = 32,
    parameter ADDR_WIDTH      = 32,
    localparam MASK_SIZE      = DATA_WIDTH/8,
    localparam BYTE_SIZE      = 8,
    localparam HALF_WORD_SIZE = 16
) (
    input  lsuop_t                       lsuop,

    input  logic signed [ADDR_WIDTH-1:0] addr_in,     //from alu out
    output logic signed [ADDR_WIDTH-1:0] addr_out,    //to dmem

    input  logic signed [DATA_WIDTH-1:0] data_s_in,   //data to be stored
    output logic signed [DATA_WIDTH-1:0] data_s_out,  //data to be stored manipulated by LSU

    input  logic signed [DATA_WIDTH-1:0] data_l_in,   //data to be loaded
    output logic signed [DATA_WIDTH-1:0] data_l_out,  //data to be loaded manipulated by LSU

    output logic [MASK_SIZE-1:0]  mask
);
 
    logic signed [BYTE_SIZE-1:0]      rdata_byte;
    logic signed [HALF_WORD_SIZE-1:0] rdata_hword;
    logic signed [DATA_WIDTH-1:0]     rdata_word;

    // there is no masking in case of LOAD BYTES and LOAD HALF WORDS
    // for this, we have to have mask in register file

    assign addr_out = addr_in;

    always_comb
    begin
        case(lsuop)
            lsu_pkg::LB, lsu_pkg::LBU:
            begin
                rdata_hword = '0;
                rdata_word  = '0;
                mask        = '0;
                data_s_out  = '0;

                case(addr_in[1:0])
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
                mask       = '0;
                data_s_out = '0;

                case(addr_in[1])
                    1'b0:    rdata_hword = data_l_in[15:0];
                    1'b1:    rdata_hword = data_l_in[31:16];
                    default: rdata_hword = '0;
                endcase
            end
            lsu_pkg::LW:
            begin
                rdata_byte  = '0;
                rdata_hword = '0;
                mask        = '0;
                data_s_out  = '0;
                rdata_word  = data_l_in;
            end
            lsu_pkg::SB:
            begin
                rdata_byte  = '0;
                rdata_hword = '0;
                rdata_word  = '0;

                case(addr_in[1:0])
                    2'b00:
                    begin
                        data_s_out[7:0] = data_s_in[7:0];
                        mask            = 4'b0001;
                    end
                    2'b01:
                    begin
                        data_s_out[15:8] = data_s_in[15:8];
                        mask             = 4'b0010;
                    end
                    2'b10:
                    begin
                        data_s_out[23:16] = data_s_in[23:16];
                        mask              = 4'b0100;
                    end
                    2'b11:
                    begin
                        data_s_out[31:24] = data_s_in[31:24];
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
                rdata_byte  = '0;
                rdata_hword = '0;
                rdata_word  = '0;

                case(addr_in[1])
                    1'b0:
                    begin
                        data_s_out[15:0] = data_s_in[15:0];
                        mask             = 4'b0011;
                    end
                    1'b1:
                    begin
                        data_s_out[31:16] = data_s_in[31:16];
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
                rdata_byte  = '0;
                rdata_hword = '0;
                rdata_word  = '0;

                data_s_out = data_s_in;
                mask       = 4'b1111;
            end
            default:
            begin
                rdata_byte  = '0;
                rdata_hword = '0;
                rdata_word  = '0;
                data_s_out  = '0;
                mask        = '0;
            end
        endcase
    end

    always_comb
    begin
        case(lsuop)
            lsu_pkg::LB :  data_l_out = {{24{rdata_byte[7]}},   rdata_byte };
            lsu_pkg::LBU:  data_l_out = {{24{1'b0}},            rdata_byte };
            lsu_pkg::LH :  data_l_out = {{16{rdata_hword[15]}}, rdata_hword};
            lsu_pkg::LHU:  data_l_out = {{16{1'b0}},            rdata_hword};
            lsu_pkg::LW :  data_l_out = {                       rdata_word };
            default     :  data_l_out = '0;
        endcase
    end

endmodule: lsu